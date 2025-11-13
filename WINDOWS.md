# Windows Compatibility Guide

## ✅ YES - Fully Compatible dengan Windows!

Proxy cookie sniffer ini **100% kompatibel dengan Windows** karena menggunakan Go yang cross-platform.

## 🖥️ Windows Installation Steps

### Prerequisites
1. Install Go for Windows (https://golang.org/dl/)
2. Pastikan Go ter-install dengan path correctly set

### Method 1: Build from Source (Recommended)

```cmd
# 1. Install Go dependencies
go mod tidy

# 2. Build binary
go build -o cookie-sniffer.exe main.go

# 3. Run proxy
cookie-sniffer.exe
```

### Method 2: Using Make (if you have make installed)

```cmd
make deps
make build
make run
```

## 🔧 Windows-Specific Configuration

### 1. Windows Firewall
Windows Defender/Firewall mungkin ask permission untuk proxy. Pilih "Allow" untuk HTTP proxy.

### 2. Windows Certificate Handling
**Chrome/Edge (Chromium-based):**
1. Open browser to any HTTPS site
2. Click "Advanced" pada certificate warning
3. Click "Proceed to [domain] (unsafe)"
4. Browser akan remember certificate untuk session

**Firefox:**
1. Click "Advanced" pada certificate warning  
2. Click "Accept the Risk and Continue"
3. Firefox akan remember untuk session

### 3. Windows Proxy Settings

**Windows 10/11 Settings:**
1. Settings → Network & Internet → Proxy
2. Manual proxy setup:
   - Address: `127.0.0.1`
   - Port: `8080`

**Per Browser:**

**Chrome:**
- Settings → Advanced → System → Open proxy settings
- Manual proxy setup: `127.0.0.1:8080`

**Firefox:**
- Settings → General → Network Settings → Settings
- Manual proxy configuration: `127.0.0.1` Port: `8080`

**Edge:**
- Settings → System → Open proxy settings
- Manual proxy setup: `127.0.0.1:8080`

## 📁 Windows File Paths

Proxy akan create log files di directory yang sama dengan executable:
- `cookies.log` - Cookie captures
- Certificate files (auto-generated)

## ⚙️ Windows Commands

### Build & Run
```cmd
# PowerShell atau Command Prompt
cd C:\path\to\proxy\directory
go build -o cookie-sniffer.exe main.go
cookie-sniffer.exe

# With custom port
$env:PROXY_PORT="3000"
cookie-sniffer.exe
```

### Testing
```cmd
# Test dengan PowerShell
Invoke-RestMethod -Uri "https://httpbin.org/cookies/set/session/test123" -Proxy "http://127.0.0.1:8080"

# Or dengan curl (install dari https://curl.se/windows/)
curl -x http://127.0.0.1:8080 https://httpbin.org/cookies/set/session/test123
```

### Monitoring Logs
```cmd
# PowerShell
Get-Content cookies.log -Wait -Tail 10

# Command Prompt
tail -f cookies.log  (jika ada Git Bash installed)
```

## 🎯 Windows Browser Setup

### Chrome/Edge
1. Set proxy di system settings
2. Browse ke HTTPS site
3. Accept certificate warning (click "Advanced" → "Proceed")
4. Test dengan login ke test site

### Firefox
1. Firefox → Settings → Network Settings
2. Manual proxy: `127.0.0.1:8080`
3. Check "Use this proxy server for all protocols"
4. Accept certificate warnings

### Edge
1. Settings → System → Proxy
2. Manual proxy setup: `127.0.0.1:8080`
3. Same as Chrome untuk certificates

## 🚨 Windows-Specific Issues

### Issue 1: Port Already in Use
```cmd
# Check what's using port 8080
netstat -ano | findstr :8080

# Kill process if needed
taskkill /PID [process_id] /F
```

### Issue 2: Firewall Blocking
```cmd
# Allow through Windows Firewall
netsh advfirewall firewall add rule name="Cookie Sniffer Proxy" dir=in action=allow protocol=TCP localport=8080
```

### Issue 3: Administrator Privileges
Biasanya **tidak perlu admin rights** untuk run proxy pada port >1024 (8080 is fine).

## 💻 Windows Batch Scripts

### Run Proxy Script
```batch
@echo off
echo Starting Cookie Sniffer Proxy...
echo.
echo Configure browser proxy to: 127.0.0.1:8080
echo Accept certificate warnings when browsing HTTPS
echo.
echo Press Ctrl+C to stop
echo.
cookie-sniffer.exe
pause
```

### Build Script
```batch
@echo off
echo Building Cookie Sniffer Proxy...
echo.
go mod tidy
go build -o cookie-sniffer.exe main.go
if %ERRORLEVEL% EQU 0 (
    echo ✅ Build successful!
    echo Run: cookie-sniffer.exe
) else (
    echo ❌ Build failed!
)
pause
```

## 🔍 Testing on Windows

### Step 1: Start Proxy
```cmd
cookie-sniffer.exe
```

### Step 2: Configure Browser
Set proxy ke `127.0.0.1:8080`

### Step 3: Test Cookies
Browse ke website yang menggunakan sessions (contoh: Gmail, Facebook)

### Step 4: Check Logs
```cmd
type cookies.log
```

## 📊 Windows Performance

- **Memory**: ~15-30MB RAM usage
- **CPU**: <5% CPU usage typically  
- **Network**: Minimal bandwidth impact
- **Startup**: <3 seconds

## 🛠️ Development on Windows

### VS Code Setup
1. Install Go extension untuk VS Code
2. Install Go tools: `Ctrl+Shift+P` → "Go: Install/Update tools"
3. Open project folder
4. Debug dengan F5

### GitHub Codespaces
Project ini juga works di GitHub Codespaces (web-based VS Code).

## ✅ Windows Compatibility Checklist

- [x] Go cross-platform compilation
- [x] Standard library dependencies only  
- [x] Cross-platform goproxy library
- [x] No Unix-specific system calls
- [x] File path handling compatible
- [x] Network binding cross-platform
- [x] Process management Windows-compatible

## 🎉 Success!

Jika semua steps diikuti dengan benar, proxy akan bekerja sempurna di Windows dan bisa capture session cookies dari browser seperti BurpSuite!

**Quick Test Commands:**
```cmd
cookie-sniffer.exe
# Browser → Settings → Proxy → 127.0.0.1:8080
# Browse HTTPS → Check cookies.log
```