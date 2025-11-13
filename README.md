# Session Cookie Sniffer Proxy

MITM (Man-in-the-Middle) proxy dalam bahasa Golang untuk sniffing session cookies seperti BurpSuite.

## 🌟 Platform Support

✅ **Fully Cross-Platform:**
- **Linux** - Fully supported
- **Windows** - Fully supported (see Windows guide)
- **macOS** - Fully supported
- **Docker** - Compatible

📖 **Platform-Specific Guides:**
- [Windows Guide](WINDOWS.md) - Detailed Windows setup & troubleshooting

## Fitur

- **HTTPS Termination**: Proxy dapat mengintercept HTTPS traffic dengan auto-generated certificates
- **Session Cookie Detection**: Otomatis mendeteksi session cookies dengan patterns seperti session, auth, token, csrf, jwt, dll.
- **Dual Logging**: Log cookies ke console dan file `cookies.log`
- **Real-time Monitoring**: Monitoring real-time untuk request dan response
- **Secure Flag Detection**: Mendeteksi cookies dengan Secure flag

## 🚀 Quick Start by Platform

### Linux/macOS
```bash
make deps && make build && make run
```

### Windows
```cmd
build-windows.bat
run-windows.bat
```

## Instalasi & Running

### Prerequisites
- Go 1.19 atau lebih baru

### 1. Install Dependencies
```bash
go mod tidy
```

### 2. Build dan Run
```bash
# Linux/macOS
go build -o cookie-sniffer
./cookie-sniffer

# Windows  
go build -o cookie-sniffer.exe
cookie-sniffer.exe
```

### 3. Konfigurasi Browser
Set proxy browser Anda ke:
- Host: `localhost` atau `127.0.0.1`
- Port: `8080`

### 4. Handle Certificate Warning
Pertama kali browsing HTTPS, browser akan show certificate warning. Ini normal untuk MITM proxy. Klik "Advanced" kemudian "Proceed to [domain] (unsafe)" atau "Trust this certificate".

## Konfigurasi

### Environment Variables
```bash
export PROXY_PORT=8080  # Default: 8080
./cookie-sniffer
```

### Custom Port
```bash
export PROXY_PORT=3128
./cookie-sniffer
```

## Output Format

Console output:
```
[2025-11-13 19:12:11] GET https://example.com/login | Domain: example.com | session_id=abc123def456 | Secure: true
[2025-11-13 19:12:15] SET-COOKIE https://example.com/login | Domain: example.com | auth_token=xyz789 | Secure: true
```

File output (`cookies.log`):
```
[2025-11-13 19:12:11] GET https://example.com/login | Domain: example.com | session_id=abc123def456 | Secure: true
[2025-11-13 19:12:15] SET-COOKIE https://example.com/login | Domain: example.com | auth_token=xyz789 | Secure: true
```

## Session Cookie Patterns

Proxy akan otomatis mendeteksi cookies dengan nama yang mengandung:

**Session & Authentication:**
- `session`, `sess`, `sid`, `sessionid`, `jsessionid`
- `auth`, `authentication`, `auth_token`
- `login`, `remember`, `remember_me`

**Security Tokens:**
- `token`, `access_token`, `refresh_token`
- `bearer`, `bearer_token`
- `csrf`, `xsrf`, `_csrf`, `csrf_token`
- `jwt`, `jsonwebtoken`

**Cookies:**
- `cookie`, `cookies`

## How It Works

1. **HTTPS Termination**: Proxy auto-generate SSL certificates untuk setiap domain
2. **MITM**: Proxy transparan di tengah komunikasi browser-server
3. **Cookie Sniffing**: Intercept semua cookies dalam request dan response
4. **Pattern Matching**: Filter hanya session cookies dengan regex patterns
5. **Logging**: Log ke console dan file dengan timestamp

## Security Notes

- **Testing Only**: Hanya untuk testing/development
- **Browser Warning**: Certificate warnings adalah normal untuk MITM
- **Local Testing**: Jangan gunakan di production atau network yang tidak trusted
- **Clear Cookies**: Clear cookies setelah testing

## Troubleshooting

### Browser Can't Connect
1. Pastikan proxy server sudah running di port 8080
2. Check firewall settings
3. Restart browser setelah set proxy

### Certificate Warnings
1. Klik "Advanced" → "Proceed" untuk trust certificate
2. Atau import certificate manual ke browser trust store

### No Cookies Captured
1. Check console output untuk aktivitas
2. Pastikan browsing ke website dengan session cookies
3. Check pattern matching - mungkin nama cookies tidak match pattern

## Example Usage

```bash
# Terminal 1: Start proxy
./cookie-sniffer

# Terminal 2: Test with curl
curl -x http://localhost:8080 https://httpbin.org/cookies/set/session/abc123

# Check logs
tail -f cookies.log
```

## Caveats

- Website dengan HSTS (HTTP Strict Transport Security) mungkin tidak bisa di-MITM
- Browser modern dengan certificate pinning tidak bisa di-MITM
- Some secure cookies dengan SameSite=Strict tidak bisa diinterfere
- Website dengan CSP (Content Security Policy) strict mungkin blo k proxy connection

## License

Educational/Training purposes only. Use responsibly!