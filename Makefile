# Makefile for Cookie Sniffer Proxy

.PHONY: build run clean deps build-windows clean-windows dev-windows

# Build the proxy (Unix/Mac/Linux)
build:
	go build -o cookie-sniffer main.go

# Build for Windows
build-windows:
	go build -o cookie-sniffer.exe main.go

# Run the proxy (Unix/Mac/Linux)
run:
	./cookie-sniffer

# Install dependencies
deps:
	go mod tidy

# Build and run in one command (Unix/Mac/Linux)
start: deps build run

# Clean build artifacts (Unix/Mac/Linux)
clean:
	rm -f cookie-sniffer
	rm -f *.log

# Clean build artifacts (Windows)
clean-windows:
	del cookie-sniffer.exe >nul 2>&1
	del *.log >nul 2>&1

# Run with custom port (Unix/Mac/Linux)
dev:
	PROXY_PORT=3000 ./cookie-sniffer

# Run with custom port (Windows)
dev-windows:
	set PROXY_PORT=3000
	cookie-sniffer.exe

# Show help
help:
	@echo "Cookie Sniffer Proxy - Makefile Commands:"
	@echo ""
	@echo "make deps          - Install Go dependencies"
	@echo "make build         - Build the proxy executable (Unix/Mac/Linux)"
	@echo "make build-windows - Build the proxy executable (Windows)"
	@echo "make run           - Run the proxy"
	@echo "make start         - Build and run the proxy"
	@echo "make dev           - Run proxy on port 3000 (Unix/Mac/Linux)"
	@echo "make dev-windows   - Run proxy on port 3000 (Windows)"
	@echo "make clean         - Remove build artifacts and logs (Unix/Mac/Linux)"
	@echo "make clean-windows - Remove build artifacts and logs (Windows)"
	@echo "make help          - Show this help message"
	@echo ""
	@echo "Environment Variables:"
	@echo "PROXY_PORT    - Port to run proxy (default: 8080)"
	@echo ""
	@echo "Windows Users:"
	@echo "  Use build-windows.bat and run-windows.bat for easier Windows setup"