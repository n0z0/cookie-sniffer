@echo off
chcp 65001 > nul
title Build Cookie Sniffer Proxy

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║              Cookie Sniffer Proxy - Build Script             ║
echo ║                    Windows Build Tool                       ║
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
echo.

REM Clean previous builds
if exist "cookie-sniffer.exe" (
    echo 🧹 Cleaning previous build...
    del cookie-sniffer.exe
)

REM Download dependencies
echo 📦 Installing dependencies...
go mod tidy

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to install dependencies!
    echo.
    pause
    exit /b 1
)

echo ✅ Dependencies installed!
echo.

REM Build binary
echo 🔨 Building proxy binary...
go build -ldflags "-s -w" -o cookie-sniffer.exe main.go

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Build failed!
    echo.
    pause
    exit /b 1
)

REM Check if binary was created
if exist "cookie-sniffer.exe" (
    echo ✅ Build successful!
    echo.
    
    REM Get file size
    for %%A in (cookie-sniffer.exe) do set size=%%~zA
    echo 📁 Binary: cookie-sniffer.exe
    echo 💾 Size: %size% bytes
    echo.
    
    echo 🚀 Ready to run!
    echo.
    echo Commands:
    echo   run-windows.bat    ^- Run proxy dengan UI
    echo   cookie-sniffer.exe ^- Run proxy directly
    echo.
    
) else (
    echo ❌ Binary not created!
    echo.
)

pause