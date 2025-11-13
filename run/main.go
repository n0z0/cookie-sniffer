package main

import (
	"bufio"
	"crypto/rand"
	"crypto/rsa"
	"crypto/tls"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/pem"
	"flag"
	"fmt"
	"io"
	"log"
	"math/big"
	"net"
	"os"
	"strings"
	"sync"
	"time"
)

var (
	caCertFile = "ca.crt"
	caKeyFile  = "ca.key"
	proxyPort  = flag.String("port", "8080", "Port for the proxy to listen on")
)

// Fungsi untuk membuat atau memuat CA Root
func getCA() (*tls.Certificate, error) {
	if _, err := os.Stat(caCertFile); os.IsNotExist(err) {
		log.Println("CA certificate not found. Generating a new one...")
		if err := generateCA(); err != nil {
			return nil, fmt.Errorf("failed to generate CA: %v", err)
		}
		log.Printf("CA generated successfully. Please install '%s' in your browser/system.\n", caCertFile)
	}

	cert, err := tls.LoadX509KeyPair(caCertFile, caKeyFile)
	if err != nil {
		return nil, fmt.Errorf("failed to load CA key pair: %v", err)
	}

	return &cert, nil
}

// Fungsi untuk membuat CA Root jika belum ada
func generateCA() error {
	priv, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		return err
	}

	notBefore := time.Now()
	notAfter := notBefore.Add(365 * 24 * time.Hour)
	serialNumberLimit := new(big.Int).Lsh(big.NewInt(1), 128)
	serialNumber, err := rand.Int(rand.Reader, serialNumberLimit)
	if err != nil {
		return err
	}

	template := x509.Certificate{
		SerialNumber: serialNumber,
		Subject: pkix.Name{
			Organization: []string{"MITM Proxy CA"},
			CommonName:   "MITM Proxy Root CA",
		},
		NotBefore:             notBefore,
		NotAfter:              notAfter,
		KeyUsage:              x509.KeyUsageKeyEncipherment | x509.KeyUsageDigitalSignature | x509.KeyUsageCertSign,
		ExtKeyUsage:           []x509.ExtKeyUsage{x509.ExtKeyUsageServerAuth},
		BasicConstraintsValid: true,
		IsCA:                  true,
	}

	derBytes, err := x509.CreateCertificate(rand.Reader, &template, &template, &priv.PublicKey, priv)
	if err != nil {
		return err
	}

	certOut, err := os.Create(caCertFile)
	if err != nil {
		return err
	}
	pem.Encode(certOut, &pem.Block{Type: "CERTIFICATE", Bytes: derBytes})
	certOut.Close()

	keyOut, err := os.OpenFile(caKeyFile, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0600)
	if err != nil {
		return err
	}
	pem.Encode(keyOut, &pem.Block{Type: "RSA PRIVATE KEY", Bytes: x509.MarshalPKCS1PrivateKey(priv)})
	keyOut.Close()

	return nil
}

// Fungsi untuk membuat sertifikat palsu untuk domain tertentu
func generateCertForHost(host string, caCert *x509.Certificate, caKey *rsa.PrivateKey) (tls.Certificate, error) {
	priv, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		return tls.Certificate{}, err
	}

	notBefore := time.Now()
	notAfter := notBefore.Add(24 * time.Hour)
	serialNumberLimit := new(big.Int).Lsh(big.NewInt(1), 128)
	serialNumber, err := rand.Int(rand.Reader, serialNumberLimit)
	if err != nil {
		return tls.Certificate{}, err
	}

	template := x509.Certificate{
		SerialNumber: serialNumber,
		Subject: pkix.Name{
			Organization: []string{"MITM Proxy"},
			CommonName:   host,
		},
		DNSNames:    []string{host},
		NotBefore:   notBefore,
		NotAfter:    notAfter,
		KeyUsage:    x509.KeyUsageKeyEncipherment | x509.KeyUsageDigitalSignature,
		ExtKeyUsage: []x509.ExtKeyUsage{x509.ExtKeyUsageServerAuth},
	}

	derBytes, err := x509.CreateCertificate(rand.Reader, &template, caCert, &priv.PublicKey, caKey)
	if err != nil {
		return tls.Certificate{}, err
	}

	cert := tls.Certificate{
		Certificate: [][]byte{derBytes},
		PrivateKey:  priv,
	}

	return cert, nil
}

func handleRequest(clientConn net.Conn, ca *tls.Certificate) {
	defer clientConn.Close()

	reader := bufio.NewReader(clientConn)
	requestLine, err := reader.ReadString('\n')
	if err != nil {
		log.Printf("Error reading request line: %v", err)
		return
	}

	parts := strings.Split(requestLine, " ")
	if len(parts) < 3 {
		log.Printf("Invalid request line: %s", requestLine)
		return
	}

	method := parts[0]
	host := parts[1]

	log.Printf("Received %s request for %s", method, host)

	if method == "CONNECT" {
		handleHTTPS(clientConn, host, ca)
	} else {
		handleHTTP(clientConn, reader, host)
	}
}

func handleHTTP(clientConn net.Conn, reader *bufio.Reader, host string) {
	serverConn, err := net.Dial("tcp", host)
	if err != nil {
		log.Printf("Error connecting to server %s: %v", host, err)
		return
	}
	defer serverConn.Close()

	// --- PERBAIKAN ---
	// Tulis data yang sudah dibaca dan berada di buffer reader ke server
	bufferedBytes := reader.Buffered()
	if bufferedBytes > 0 {
		bufferedData, err := reader.Peek(bufferedBytes)
		if err != nil {
			log.Printf("Error peeking buffer: %v", err)
			return
		}
		_, err = serverConn.Write(bufferedData)
		if err != nil {
			log.Printf("Error writing buffered data to server: %v", err)
			return
		}
	}

	// Relay data antara client dan server
	var wg sync.WaitGroup
	wg.Add(2)

	go func() {
		defer wg.Done()
		io.Copy(serverConn, reader)
	}()

	go func() {
		defer wg.Done()
		io.Copy(clientConn, serverConn)
	}()

	wg.Wait()
	// --- AKHIR PERBAIKAN ---
}

func handleHTTPS(clientConn net.Conn, host string, ca *tls.Certificate) {
	_, err := clientConn.Write([]byte("HTTP/1.1 200 Connection established\r\n\r\n"))
	if err != nil {
		log.Printf("Error writing 200 response to client: %v", err)
		return
	}

	hostname, _, err := net.SplitHostPort(host)
	if err != nil {
		log.Printf("Error parsing host %s: %v", host, err)
		return
	}

	caCert, err := x509.ParseCertificate(ca.Certificate[0])
	if err != nil {
		log.Printf("Error parsing CA certificate: %v", err)
		return
	}

	fakeCert, err := generateCertForHost(hostname, caCert, ca.PrivateKey.(*rsa.PrivateKey))
	if err != nil {
		log.Printf("Error generating fake certificate for %s: %v", hostname, err)
		return
	}

	tlsConfig := &tls.Config{
		Certificates: []tls.Certificate{fakeCert},
	}
	tlsClientConn := tls.Server(clientConn, tlsConfig)
	defer tlsClientConn.Close()

	if err := tlsClientConn.Handshake(); err != nil {
		log.Printf("Error during TLS handshake with client: %v", err)
		return
	}
	log.Printf("TLS handshake with client for %s successful", hostname)

	tlsServerConn, err := tls.Dial("tcp", host, &tls.Config{
		ServerName: hostname,
	})
	if err != nil {
		log.Printf("Error connecting to real server %s via TLS: %v", host, err)
		return
	}
	defer tlsServerConn.Close()

	log.Printf("Connected to real server %s", host)

	var wg sync.WaitGroup
	wg.Add(2)

	go func() {
		defer wg.Done()
		io.Copy(tlsServerConn, tlsClientConn)
	}()

	go func() {
		defer wg.Done()
		io.Copy(tlsClientConn, tlsServerConn)
	}()

	wg.Wait()
}

func main() {
	flag.Parse()

	ca, err := getCA()
	if err != nil {
		log.Fatalf("Failed to get CA: %v", err)
	}

	listener, err := net.Listen("tcp", ":"+*proxyPort)
	if err != nil {
		log.Fatalf("Failed to start proxy on port %s: %v", *proxyPort, err)
	}
	defer listener.Close()

	log.Printf("MITM Proxy listening on port %s", *proxyPort)
	log.Printf("IMPORTANT: Make sure '%s' is installed and trusted by your browser/system.", caCertFile)

	for {
		clientConn, err := listener.Accept()
		if err != nil {
			log.Printf("Error accepting connection: %v", err)
			continue
		}

		go handleRequest(clientConn, ca)
	}
}
