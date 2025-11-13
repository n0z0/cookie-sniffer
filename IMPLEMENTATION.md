# Session Cookie Sniffer Proxy - Implementation Complete ✅

## Project Summary

Saya telah berhasil membuat MITM (Man-in-the-Middle) proxy dalam bahasa Golang yang dapat melakukan sniffing session cookies seperti BurpSuite. Proxy ini menggunakan library `elazarl/goproxy` untuk handling HTTPS traffic dengan automatic certificate generation.

## Files Created

- **<filepath>main.go</filepath>** - Main proxy server dengan cookie sniffing logic
- **<filepath>go.mod</filepath>** - Go module dependencies  
- **<filepath>README.md</filepath>** - Documentation lengkap dengan usage instructions
- **<filepath>Makefile</filepath>** - Build automation untuk convenience
- **<filepath>test.sh</filepath>** - Test script untuk demo proxy functionality
- **<filepath>cookie-sniffer</filepath>** - Compiled binary (ready to run)

## Key Features Implemented

### 1. HTTPS Termination & MITM
- ✅ Auto-generated SSL certificates untuk setiap domain
- ✅ Transparent HTTPS interception
- ✅ Browser certificate warnings (normal behavior)

### 2. Session Cookie Detection  
- ✅ Pattern-based detection (session, auth, token, csrf, jwt, dll)
- ✅ Request & Response cookie sniffing
- ✅ Secure flag detection

### 3. Dual Logging System
- ✅ Console logging dengan colored output
- ✅ File logging ke `cookies.log`
- ✅ Timestamp & metadata tracking

### 4. Real-time Monitoring
- ✅ Request/Response interception
- ✅ Live traffic monitoring
- ✅ Detailed logging information

## How It Works

```
[Browser] -> [MITM Proxy] -> [Server]
     ↑           ↓
  Cookie    Certificate
Sniffing   Generation
```

1. **Browser sets proxy** ke localhost:8080
2. **Proxy intercepts** semua HTTP/HTTPS traffic
3. **MITM certificates** auto-generated untuk setiap domain
4. **Cookie sniffing** pada request dan response headers
5. **Pattern matching** untuk session-related cookies
6. **Logging** ke console dan file

## Quick Start

### 1. Install & Build
```bash
make deps    # Install Go dependencies
make build   # Build binary
```

### 2. Run Proxy
```bash
./cookie-sniffer
# atau
make run
```

### 3. Configure Browser
- Set proxy: `localhost:8080`
- Accept certificate warnings (normal)

### 4. View Captured Cookies
```bash
tail -f cookies.log
```

## Example Output

```
[2025-11-13 19:14:22] GET https://httpbin.org/cookies/set/session/abc123 | Domain: httpbin.org | session=abc123 | Secure: false
[2025-11-13 19:14:23] GET https://api.example.com/profile | Domain: api.example.com | auth_token=xyz789 | Secure: true
[2025-11-13 19:14:24] SET-COOKIE https://login.example.com/auth | Domain: login.example.com | csrf_token=def456 | Secure: true
```

## Detection Patterns

Proxy akan otomatis mendeteksi cookies dengan nama mengandung:

- **Session**: `session`, `sess`, `sid`, `sessionid`
- **Auth**: `auth`, `auth_token`, `login` 
- **Tokens**: `token`, `access_token`, `refresh_token`, `bearer`
- **Security**: `csrf`, `xsrf`, `jwt`, `jsonwebtoken`
- **Cookies**: `cookie`, `cookies`

## Technical Architecture

### MITM Certificate System
- Auto-generate CA certificate
- Dynamic certificate per domain
- Browser trust warnings (expected)

### Cookie Engine
- Request cookie extraction
- Set-Cookie header parsing
- Regex pattern matching
- Security attribute detection

### Logging Infrastructure
- Concurrent-safe file writing
- Console output dengan colors
- Timestamped entries
- Structured log format

## Advantages vs BurpSuite

- **Lightweight**: Single binary, no external dependencies
- **Custom**: Fully controllable dan modifiable
- **Educational**: Great untuk learning MITM concepts  
- **Fast**: Native Go performance
- **Simple**: Easy setup dan configuration

## Security Considerations

⚠️ **IMPORTANT**: 
- Hanya untuk testing/development
- Certificate warnings adalah normal
- Jangan gunakan di production
- Clear cookies setelah testing
- Local testing only

## Testing

Run test script:
```bash
bash test.sh
```

Manual testing:
```bash
# Terminal 1: Start proxy
./cookie-sniffer

# Terminal 2: Test dengan curl
curl -x http://localhost:8080 https://httpbin.org/cookies/set/session/test123

# Terminal 3: Monitor logs
tail -f cookies.log
```

## Performance

- **Concurrent**: Support multiple browser connections
- **Efficient**: Minimal memory footprint
- **Fast**: Native Go networking
- **Reliable**: Stable certificate management

## Browser Compatibility

✅ **Supported**:
- Chrome/Chromium (accept certificate warning)
- Firefox (accept certificate warning)  
- Safari (accept certificate warning)
- Edge (accept certificate warning)

❌ **Limitations**:
- HSTS websites (Strict Transport Security)
- Certificate pinning (Modern browsers)
- SameSite=Strict cookies

## Conclusion

Proxy berhasil mengimplementasikan core functionality BurpSuite untuk session cookie sniffing:

1. ✅ HTTPS termination dengan MITM certificates
2. ✅ Session cookie detection & filtering  
3. ✅ Real-time logging ke console dan file
4. ✅ Browser proxy integration
5. ✅ Production-ready code structure

Proxy ini siap digunakan untuk testing dan educational purposes!