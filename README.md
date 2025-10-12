# ZigScan - High-Performance Port Scanner

[![CI](https://github.com/gnusec/zigscan/actions/workflows/ci.yml/badge.svg)](https://github.com/gnusec/zigscan/actions/workflows/ci.yml)
[![Release](https://github.com/gnusec/zigscan/actions/workflows/release.yml/badge.svg)](https://github.com/gnusec/zigscan/actions/workflows/release.yml)
[![License](https://img.shields.io/github/license/gnusec/zigscan)](LICENSE)
[![Latest Release](https://img.shields.io/github/v/release/gnusec/zigscan)](https://github.com/gnusec/zigscan/releases/latest)

A high-performance port scanner written in Zig, similar to RustScan, designed for fast and efficient network port scanning.

## ⚡ Quick Start

### Download Pre-built Binaries

Download the latest release for your platform:

**Linux:**
```bash
# x86_64
wget https://github.com/gnusec/zigscan/releases/latest/download/zigscan-linux-x86_64.tar.gz
tar xzf zigscan-linux-x86_64.tar.gz

# ARM64
wget https://github.com/gnusec/zigscan/releases/latest/download/zigscan-linux-aarch64.tar.gz
tar xzf zigscan-linux-aarch64.tar.gz
```

**macOS:**
```bash
# Intel
curl -LO https://github.com/gnusec/zigscan/releases/latest/download/zigscan-macos-x86_64.tar.gz
tar xzf zigscan-macos-x86_64.tar.gz

# Apple Silicon (M1/M2)
curl -LO https://github.com/gnusec/zigscan/releases/latest/download/zigscan-macos-aarch64.tar.gz
tar xzf zigscan-macos-aarch64.tar.gz
```

**Windows:**
```powershell
# Download and extract zigscan-windows-x86_64.exe.zip
Invoke-WebRequest -Uri "https://github.com/gnusec/zigscan/releases/latest/download/zigscan-windows-x86_64.exe.zip" -OutFile zigscan.zip
Expand-Archive zigscan.zip
```

### Build from Source

Requirements:
- Zig 0.13.0 or later

```bash
git clone https://github.com/gnusec/zigscan.git
cd zigscan
zig build
./zig-out/bin/zigscan --help
```

## 🚀 Examples

Quick examples; see more in [USAGE.md](USAGE.md):

```bash
# Scan specific ports
zigscan -t 192.168.1.1 -p 80,443,8080

# Scan a port range
zigscan -t scanme.nmap.org -r 1-1000

# JSON output saved to file
zigscan -t 103.235.46.115 -p 22,80,443 --json -o results.json
```


