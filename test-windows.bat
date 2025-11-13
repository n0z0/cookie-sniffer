@echo off
chcp 65001 > nul
title Test Cookie Sniffer Proxy

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║               Cookie Sniffer Proxy - Test Suite              ║
echo ║                    Windows Test Script                      ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

REM Check if binary exists
if not exist "cookie-sniffer.exe" (
    echo ❌ cookie-sniffer.exe not found!
    echo Please run build-windows.bat first.
    echo.
    pause
    exit /b 1
)

echo ✅ Found cookie-sniffer.exe
echo.

REM Start proxy in background
echo 📡 Starting proxy server...
start /B "" cookie-sniffer.exe

REM Wait for proxy to start
echo ⏳ Waiting for proxy to start...
timeout /t 3 > nul

echo 🔍 Testing with curl...
REM Try curl test
curl -x http://localhost:8080 -L "https://httpbin.org/cookies/set/session/test123" --connect-timeout 5 > nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✅ Proxy connection successful!
) else (
    echo ⚠️  Curl test failed - this is normal if curl is not installed
)

echo.
echo 📋 Checking for cookie captures...
if exist "cookies.log" (
    echo ✅ Found cookies.log file
    echo.
    echo 📝 Recent cookie captures:
    type cookies.log | findstr /R ".*"
    echo.
    echo 💡 If you see cookie entries above, the proxy is working!
    echo.
    echo 🎯 Next Steps:
    echo    1. Configure browser proxy: 127.0.0.1:8080
    echo    2. Browse HTTPS websites
    echo    3. Check cookies.log for captures
    echo.
    echo 🛑 Press any key to stop proxy...
    pause > nul
    
    REM Kill proxy process
    taskkill /F /IM cookie-sniffer.exe > nul 2>&1
    
) else (
    echo ⚠️  cookies.log not found yet
    echo.
    echo 🎯 Manual Testing:
    echo    1. The proxy is running in background
    echo    2. Configure browser proxy: 127.0.0.1:8080
    echo    3. Browse HTTPS websites with session cookies
    echo    4. Check cookies.log for captures
    echo.
    echo 🛑 Press any key to stop proxy...
    pause > nul
    
    REM Kill proxy process
    taskkill /F /IM cookie-sniffer.exe > nul 2>&1
)

echo 👋 Proxy stopped.
echo.
echo ✅ Test completed!
echo.
pause