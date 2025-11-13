#!/bin/bash

# Test script for Cookie Sniffer Proxy

echo "🚀 Cookie Sniffer Proxy Test Script"
echo "=================================="

# Check if proxy binary exists
if [ ! -f "cookie-sniffer" ]; then
    echo "❌ cookie-sniffer binary not found. Run 'make build' first."
    exit 1
fi

echo "✅ Cookie sniffer binary found"

# Start proxy in background
echo "📡 Starting proxy server..."
./cookie-sniffer &
PROXY_PID=$!

# Wait for proxy to start
echo "⏳ Waiting for proxy to start..."
sleep 2

# Test with curl
echo "🔍 Testing with curl (this will show certificate warning, that's normal)..."
curl -x http://localhost:8080 -L https://httpbin.org/cookies/set/session/test123 2>/dev/null

echo "📋 Checking logs..."
if [ -f "cookies.log" ]; then
    echo "✅ Found cookies.log file"
    echo "📝 Recent cookie captures:"
    tail -5 cookies.log
else
    echo "⚠️  cookies.log not found yet"
fi

# Stop proxy
echo "🛑 Stopping proxy server..."
kill $PROXY_PID 2>/dev/null

echo "✅ Test completed!"
echo ""
echo "To use the proxy manually:"
echo "1. Run: ./cookie-sniffer"
echo "2. Configure browser proxy to localhost:8080"
echo "3. Browse to HTTPS websites"
echo "4. Check cookies.log for captured session cookies"