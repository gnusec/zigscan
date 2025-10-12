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
# 说明：对目标 192.168.1.1 的 80、443、8080 端口进行扫描

# Scan a port range
zigscan -t scanme.nmap.org -r 1-1000
# 说明：扫描 1-1000 的连续端口范围

# JSON output saved to file
zigscan -t 103.235.46.115 -p 22,80,443 --json -o results.json
# 说明：输出 JSON 格式并保存到 results.json

# 控制并发（越大越快，但占用更多资源）
zigscan -t 103.235.46.115 -r 1-200 -c 200
# 说明：并发数设置为 200，加快扫描速度

# 自定义超时（毫秒）
zigscan -t 103.235.46.115 -p 22,80,443 --timeout 300
# 说明：将连接超时设置为 300ms，缩短对关闭端口的等待时间
```

## 📖 Help（完整帮助）

执行：

```bash
zigscan --help
```

输出：

```
ZigScan - High-performance Port Scanner
Version: 1.0.0

Usage: zigscan [options]

Options:
  -h, --help              Show this help message
  -t, --target <IP>       Target IP address or hostname (required)
  -T, --targets <file>    File containing list of target IPs
  -p, --ports <ports>     Port list (e.g., 80,443,8080)
  -r, --range <range>     Port range (e.g., 1-1000)
  -c, --concurrency <n>   Number of concurrent connections (default: 500)
  --timeout <ms>          Connection timeout in milliseconds (default: 1000)
  --json                  Output results in JSON format
  --txt                   Output results in TXT format
  -o, --output <file>     Output file path

Examples:
  zigscan -t 192.168.1.1 -p 80,443,8080
  zigscan -t 103.235.46.115 -r 1-1000 -c 100
  zigscan -t scanme.nmap.org -p 22,80,443 --json -o results.json
```

## 🔧 Zig 编译器版本

建议使用最新 Zig 编译器进行构建，下载地址：
- 官方下载页：https://ziglang.org/download/
- 示例（Linux x86_64 开发版）：https://ziglang.org/builds/zig-x86_64-linux-0.16.0-dev.699+529aa9f27.tar.xz



