@echo off
chcp 65001 > nul
title Cookie Sniffer Proxy

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║               Cookie Sniffer Proxy - Windows                 ║
echo ║                    Session Cookie MITM Proxy                 ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

REM Check if Go is installed
where go >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Go tidak ditemukan!
    echo Please install Go from: https://golang.org/dl/
    echo.
    pause
    exit /b 1
)

echo ✅ Go found: 
go version

REM Check if binary exists
if not exist "cookie-sniffer.exe" (
    echo.
    echo 🔨 Building proxy binary...
    go mod tidy > nul 2>&1
    go build -o cookie-sniffer.exe main.go
    
    if %ERRORLEVEL% NEQ 0 (
        echo ❌ Build failed! Please check the code.
        echo.
        pause
        exit /b 1
    )
    
    echo ✅ Build successful!
)

echo.
echo 🚀 Starting Cookie Sniffer Proxy...
echo.
echo 📍 Configuration:
echo    - Proxy Address: 127.0.0.1:8080
echo    - Log File: cookies.log
echo    - MITM Certificates: Auto-generated
echo.
echo 🌐 Browser Setup:
echo    1. Set proxy to: 127.0.0.1:8080
echo    2. Accept certificate warnings (normal)
echo    3. Browse HTTPS websites
echo.
echo ⏹️  Press Ctrl+C to stop
echo.
echo ════════════════════════════════════════════════════════════════

REM Start the proxy
cookie-sniffer.exe

echo.
echo 👋 Proxy stopped.
pause