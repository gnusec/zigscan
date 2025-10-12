# ZigScan - High-Performance Port Scanner

[![CI](https://github.com/gnusec/zigscan-template/actions/workflows/ci.yml/badge.svg)](https://github.com/gnusec/zigscan-template/actions/workflows/ci.yml)
[![Release](https://github.com/gnusec/zigscan-template/actions/workflows/release.yml/badge.svg)](https://github.com/gnusec/zigscan-template/actions/workflows/release.yml)
[![License](https://img.shields.io/github/license/gnusec/zigscan-template)](LICENSE)
[![Latest Release](https://img.shields.io/github/v/release/gnusec/zigscan-template)](https://github.com/gnusec/zigscan-template/releases/latest)

A high-performance port scanner written in Zig, similar to RustScan, designed for fast and efficient network port scanning.

## ⚡ Quick Start

### Download Pre-built Binaries

Download the latest release for your platform:

**Linux:**
```bash
# x86_64
wget https://github.com/gnusec/zigscan-template/releases/latest/download/zigscan-linux-x86_64.tar.gz
tar xzf zigscan-linux-x86_64.tar.gz

# ARM64
wget https://github.com/gnusec/zigscan-template/releases/latest/download/zigscan-linux-aarch64.tar.gz
tar xzf zigscan-linux-aarch64.tar.gz
```

**macOS:**
```bash
# Intel
curl -LO https://github.com/gnusec/zigscan-template/releases/latest/download/zigscan-macos-x86_64.tar.gz
tar xzf zigscan-macos-x86_64.tar.gz

# Apple Silicon (M1/M2)
curl -LO https://github.com/gnusec/zigscan-template/releases/latest/download/zigscan-macos-aarch64.tar.gz
tar xzf zigscan-macos-aarch64.tar.gz
```

**Windows:**
```powershell
# Download and extract zigscan-windows-x86_64.exe.zip
Invoke-WebRequest -Uri "https://github.com/gnusec/zigscan-template/releases/latest/download/zigscan-windows-x86_64.exe.zip" -OutFile zigscan.zip
Expand-Archive zigscan.zip
```

### Build from Source

Requirements:
- Zig 0.13.0 or later

```bash
git clone https://github.com/gnusec/zigscan-template.git
cd zigscan-template
zig build
./zig-out/bin/zigscan --help
```
1：通过 https://ziglang.org/builds/zig-x86_64-linux-0.16.0-dev.699+529aa9f27.tar.xz 可以获取最新的zig可执行版本，直接下载到本地服务器，直接解压到/usr/loca/bin或者/bin目录下可用
如果0.16.0不可行，则使用
2：https://ziglang.org/documentation/master/ 和 https://ziglang.org/documentation/master/std/ 提供了最新的zig语法文档，可以保存到本地查询，如果有必要
3： zig-Language-Reference.txt 是zig master的最新语法。你也可以自己通过步骤2的方法去下载。
 

