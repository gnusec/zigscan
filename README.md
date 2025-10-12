<div align="center">

# 🚀 ZigScan

### High-Performance Multi-threaded Port Scanner

[![CI](https://github.com/gnusec/zigscan/actions/workflows/ci.yml/badge.svg)](https://github.com/gnusec/zigscan/actions/workflows/ci.yml)
[![Release](https://github.com/gnusec/zigscan/actions/workflows/release.yml/badge.svg)](https://github.com/gnusec/zigscan/actions/workflows/release.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Latest Release](https://img.shields.io/github/v/release/gnusec/zigscan)](https://github.com/gnusec/zigscan/releases/latest)

[English](#english) | [中文](#中文)

*A blazing-fast port scanner written in Zig, inspired by RustScan*

</div>

---

<a name="english"></a>

## 📖 Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Usage Examples](#usage-examples)
- [Command Line Options](#command-line-options)
- [Performance](#performance)
- [Building from Source](#building-from-source)
- [Contributing](#contributing)

## ✨ Features

- ⚡ **Lightning Fast** - Multi-threaded worker pool architecture for maximum speed
- 🎯 **Flexible Targeting** - Support for single hosts, IP lists, port lists, and port ranges
- 🔧 **Highly Configurable** - Adjust concurrency, timeouts, and output formats
- 📊 **Multiple Output Formats** - JSON and plain text support
- 🌐 **Cross-Platform** - Works on Linux, macOS, and Windows
- 🔒 **Non-blocking I/O** - Efficient socket handling with configurable timeouts
- 💪 **Production Ready** - Robust error handling and resource management
- 🎨 **Beautiful Output** - Clean and informative scan results

## 🚀 Quick Start

### One-Line Install (Linux/macOS)

```bash
# Linux (x86_64)
wget https://github.com/gnusec/zigscan/releases/latest/download/zigscan-linux-x86_64.tar.gz && \
tar xzf zigscan-linux-x86_64.tar.gz && \
./zigscan-linux-x86_64 --help

# macOS (Apple Silicon)
curl -LO https://github.com/gnusec/zigscan/releases/latest/download/zigscan-macos-aarch64.tar.gz && \
tar xzf zigscan-macos-aarch64.tar.gz && \
./zigscan-macos-aarch64 --help
```

### Quick Scan Example

```bash
# Scan common ports on a target
./zigscan -t scanme.nmap.org -p 22,80,443,3306,8080

# Fast scan of first 1000 ports
./zigscan -t 192.168.1.1 -r 1-1000 -c 1000
```

## 📥 Installation

### Option 1: Download Pre-built Binaries (Recommended)

<details>
<summary><b>🐧 Linux</b></summary>

```bash
# x86_64 (Intel/AMD)
wget https://github.com/gnusec/zigscan/releases/latest/download/zigscan-linux-x86_64.tar.gz
tar xzf zigscan-linux-x86_64.tar.gz
chmod +x zigscan-linux-x86_64
sudo mv zigscan-linux-x86_64 /usr/local/bin/zigscan

# ARM64 (Raspberry Pi, ARM servers)
wget https://github.com/gnusec/zigscan/releases/latest/download/zigscan-linux-aarch64.tar.gz
tar xzf zigscan-linux-aarch64.tar.gz
chmod +x zigscan-linux-aarch64
sudo mv zigscan-linux-aarch64 /usr/local/bin/zigscan

# Verify installation
zigscan --help
```

</details>

<details>
<summary><b>🍎 macOS</b></summary>

```bash
# Intel Mac
curl -LO https://github.com/gnusec/zigscan/releases/latest/download/zigscan-macos-x86_64.tar.gz
tar xzf zigscan-macos-x86_64.tar.gz
chmod +x zigscan-macos-x86_64
sudo mv zigscan-macos-x86_64 /usr/local/bin/zigscan

# Apple Silicon (M1/M2/M3)
curl -LO https://github.com/gnusec/zigscan/releases/latest/download/zigscan-macos-aarch64.tar.gz
tar xzf zigscan-macos-aarch64.tar.gz
chmod +x zigscan-macos-aarch64
sudo mv zigscan-macos-aarch64 /usr/local/bin/zigscan

# Verify installation
zigscan --help
```

</details>

<details>
<summary><b>🪟 Windows</b></summary>

```powershell
# Download
Invoke-WebRequest -Uri "https://github.com/gnusec/zigscan/releases/latest/download/zigscan-windows-x86_64.exe.zip" -OutFile zigscan.zip

# Extract
Expand-Archive zigscan.zip -DestinationPath .

# Run
.\zigscan-windows-x86_64.exe --help
```

</details>

### Option 2: Build from Source

See [Building from Source](#building-from-source) section.

## 💡 Usage Examples

### Basic Scanning

```bash
# Scan specific ports
zigscan -t 192.168.1.1 -p 80,443,8080

# Scan a port range
zigscan -t example.com -r 1-1000

# Scan common services (default)
zigscan -t target.local
```

### Advanced Scanning

```bash
# High-speed scan with 1000 concurrent connections
zigscan -t 10.0.0.1 -r 1-65535 -c 1000

# Scan with custom timeout (2 seconds)
zigscan -t slow-server.com -r 1-1000 --timeout 2000

# Scan multiple specific ports
zigscan -t database-server.local -p 3306,5432,6379,27017,9200
```

### Output Formats

```bash
# JSON output
zigscan -t 192.168.1.1 -r 1-1000 --json

# Save to file
zigscan -t target.com -p 80,443 -o results.txt

# JSON output to file
zigscan -t scanme.nmap.org -r 1-1000 --json -o scan-results.json
```

### Real-World Examples

```bash
# Web server scan
zigscan -t webserver.com -p 80,443,8080,8443,3000,5000

# Database server scan
zigscan -t db.example.com -p 3306,5432,6379,27017,1521

# Full port scan (slower but comprehensive)
zigscan -t 192.168.1.100 -r 1-65535 -c 2000 --timeout 500

# Quick network sweep (top 100 ports)
zigscan -t 10.0.0.50 -r 1-100 -c 100
```

## 📝 Command Line Options

| Option | Description | Default | Example |
|--------|-------------|---------|---------|
| `-t, --target <IP>` | Target IP address or hostname **(required)** | - | `-t 192.168.1.1` |
| `-T, --targets <file>` | File containing list of target IPs | - | `-T targets.txt` |
| `-p, --ports <ports>` | Comma-separated port list | Common ports | `-p 80,443,8080` |
| `-r, --range <range>` | Port range (start-end) | - | `-r 1-1000` |
| `-c, --concurrency <n>` | Number of concurrent connections | 500 | `-c 1000` |
| `--timeout <ms>` | Connection timeout in milliseconds | 1000 | `--timeout 2000` |
| `--json` | Output results in JSON format | false | `--json` |
| `--txt` | Output results in plain text format | false | `--txt` |
| `-o, --output <file>` | Save results to file | stdout | `-o results.txt` |
| `-h, --help` | Show help message | - | `--help` |

## 📊 Performance

ZigScan is designed for speed and efficiency:

### Benchmark Results

```bash
# Test environment: Intel Core i7-9750H, 16GB RAM, Ubuntu 22.04

# Scan 475 ports with 100 concurrent connections
$ time zigscan -t 103.235.46.115 -r 80-555 -c 100
[*] Scan completed in 5123ms
[*] Open ports: 2/475 (80, 443)
real    0m5.123s

# Scan same 475 ports with 200 concurrent connections
$ time zigscan -t 103.235.46.115 -r 80-555 -c 200
[*] Scan completed in 2891ms
[*] Open ports: 2/475 (80, 443)
real    0m2.891s

# Full port scan (65535 ports) with high concurrency
$ time zigscan -t scanme.nmap.org -r 1-65535 -c 2000 --timeout 500
[*] Scan completed in 45821ms
[*] Open ports: 4/65535
real    0m45.821s
```

### Performance Tips

1. **Adjust Concurrency**: Higher concurrency = faster scans (but more system resources)
   - Local network: `-c 2000` or higher
   - Internet scanning: `-c 500-1000` recommended
   
2. **Tune Timeout**: Lower timeout = faster scanning of closed ports
   - Fast networks: `--timeout 500`
   - Slow/remote: `--timeout 2000`

3. **Target Specific Ports**: Scanning fewer ports is always faster
   - Use `-p` for known services
   - Use `-r` with reasonable ranges

## 🛠️ Building from Source

### Prerequisites

- **Zig 0.13.0 or later** ([Download Zig](https://ziglang.org/download/))
- Git

### Build Steps

```bash
# Clone the repository
git clone https://github.com/gnusec/zigscan.git
cd zigscan

# Build (Debug mode)
zig build

# Build (Optimized/Release mode)
zig build -Doptimize=ReleaseFast

# Run
./zig-out/bin/zigscan --help

# Install system-wide (Linux/macOS)
sudo cp zig-out/bin/zigscan /usr/local/bin/

# Verify
zigscan --version
```

### Cross-Compilation

```bash
# Build for Linux (from macOS/Windows)
zig build -Dtarget=x86_64-linux-gnu -Doptimize=ReleaseFast

# Build for macOS ARM (from Linux/Windows)
zig build -Dtarget=aarch64-macos -Doptimize=ReleaseFast

# Build for Windows (from Linux/macOS)
zig build -Dtarget=x86_64-windows-gnu -Doptimize=ReleaseFast
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by [RustScan](https://github.com/RustScan/RustScan)
- Built with [Zig](https://ziglang.org/)

---

<a name="中文"></a>

<div align="center">

# 🚀 ZigScan

### 高性能多线程端口扫描器

*用 Zig 语言编写的极速端口扫描工具，灵感来自 RustScan*

</div>

## 📖 目录

- [功能特性](#功能特性)
- [快速开始](#快速开始)
- [安装](#安装)
- [使用示例](#使用示例)
- [命令行选项](#命令行选项)
- [性能表现](#性能表现)
- [从源码构建](#从源码构建)
- [贡献](#贡献)

## ✨ 功能特性

- ⚡ **闪电般快速** - 多线程工作池架构，实现最大速度
- 🎯 **灵活目标** - 支持单主机、IP列表、端口列表和端口范围
- 🔧 **高度可配置** - 可调节并发数、超时和输出格式
- 📊 **多种输出格式** - 支持 JSON 和纯文本
- 🌐 **跨平台** - 可运行在 Linux、macOS 和 Windows
- 🔒 **非阻塞 I/O** - 高效的套接字处理和可配置超时
- 💪 **生产就绪** - 健壮的错误处理和资源管理
- 🎨 **精美输出** - 清晰且信息丰富的扫描结果

## 🚀 快速开始

### 一行安装 (Linux/macOS)

```bash
# Linux (x86_64)
wget https://github.com/gnusec/zigscan/releases/latest/download/zigscan-linux-x86_64.tar.gz && \
tar xzf zigscan-linux-x86_64.tar.gz && \
./zigscan-linux-x86_64 --help

# macOS (Apple Silicon)
curl -LO https://github.com/gnusec/zigscan/releases/latest/download/zigscan-macos-aarch64.tar.gz && \
tar xzf zigscan-macos-aarch64.tar.gz && \
./zigscan-macos-aarch64 --help
```

### 快速扫描示例

```bash
# 扫描目标的常见端口
./zigscan -t scanme.nmap.org -p 22,80,443,3306,8080

# 快速扫描前 1000 个端口
./zigscan -t 192.168.1.1 -r 1-1000 -c 1000
```

## 📥 安装

### 方式 1：下载预编译二进制文件（推荐）

<details>
<summary><b>🐧 Linux</b></summary>

```bash
# x86_64 (Intel/AMD)
wget https://github.com/gnusec/zigscan/releases/latest/download/zigscan-linux-x86_64.tar.gz
tar xzf zigscan-linux-x86_64.tar.gz
chmod +x zigscan-linux-x86_64
sudo mv zigscan-linux-x86_64 /usr/local/bin/zigscan

# ARM64 (树莓派, ARM 服务器)
wget https://github.com/gnusec/zigscan/releases/latest/download/zigscan-linux-aarch64.tar.gz
tar xzf zigscan-linux-aarch64.tar.gz
chmod +x zigscan-linux-aarch64
sudo mv zigscan-linux-aarch64 /usr/local/bin/zigscan

# 验证安装
zigscan --help
```

</details>

<details>
<summary><b>🍎 macOS</b></summary>

```bash
# Intel Mac
curl -LO https://github.com/gnusec/zigscan/releases/latest/download/zigscan-macos-x86_64.tar.gz
tar xzf zigscan-macos-x86_64.tar.gz
chmod +x zigscan-macos-x86_64
sudo mv zigscan-macos-x86_64 /usr/local/bin/zigscan

# Apple Silicon (M1/M2/M3)
curl -LO https://github.com/gnusec/zigscan/releases/latest/download/zigscan-macos-aarch64.tar.gz
tar xzf zigscan-macos-aarch64.tar.gz
chmod +x zigscan-macos-aarch64
sudo mv zigscan-macos-aarch64 /usr/local/bin/zigscan

# 验证安装
zigscan --help
```

</details>

<details>
<summary><b>🪟 Windows</b></summary>

```powershell
# 下载
Invoke-WebRequest -Uri "https://github.com/gnusec/zigscan/releases/latest/download/zigscan-windows-x86_64.exe.zip" -OutFile zigscan.zip

# 解压
Expand-Archive zigscan.zip -DestinationPath .

# 运行
.\zigscan-windows-x86_64.exe --help
```

</details>

### 方式 2：从源码构建

查看 [从源码构建](#从源码构建-1) 部分。

## 💡 使用示例

### 基本扫描

```bash
# 扫描特定端口
zigscan -t 192.168.1.1 -p 80,443,8080

# 扫描端口范围
zigscan -t example.com -r 1-1000

# 扫描常见服务（默认）
zigscan -t target.local
```

### 高级扫描

```bash
# 使用 1000 个并发连接的高速扫描
zigscan -t 10.0.0.1 -r 1-65535 -c 1000

# 使用自定义超时（2 秒）进行扫描
zigscan -t slow-server.com -r 1-1000 --timeout 2000

# 扫描多个特定端口
zigscan -t database-server.local -p 3306,5432,6379,27017,9200
```

### 输出格式

```bash
# JSON 输出
zigscan -t 192.168.1.1 -r 1-1000 --json

# 保存到文件
zigscan -t target.com -p 80,443 -o results.txt

# JSON 输出到文件
zigscan -t scanme.nmap.org -r 1-1000 --json -o scan-results.json
```

### 实际应用示例

```bash
# Web 服务器扫描
zigscan -t webserver.com -p 80,443,8080,8443,3000,5000

# 数据库服务器扫描
zigscan -t db.example.com -p 3306,5432,6379,27017,1521

# 全端口扫描（较慢但全面）
zigscan -t 192.168.1.100 -r 1-65535 -c 2000 --timeout 500

# 快速网络扫描（前 100 个端口）
zigscan -t 10.0.0.50 -r 1-100 -c 100
```

## 📝 命令行选项

| 选项 | 说明 | 默认值 | 示例 |
|------|------|--------|------|
| `-t, --target <IP>` | 目标 IP 地址或主机名 **（必需）** | - | `-t 192.168.1.1` |
| `-T, --targets <file>` | 包含目标 IP 列表的文件 | - | `-T targets.txt` |
| `-p, --ports <ports>` | 逗号分隔的端口列表 | 常用端口 | `-p 80,443,8080` |
| `-r, --range <range>` | 端口范围（开始-结束） | - | `-r 1-1000` |
| `-c, --concurrency <n>` | 并发连接数 | 500 | `-c 1000` |
| `--timeout <ms>` | 连接超时（毫秒） | 1000 | `--timeout 2000` |
| `--json` | 以 JSON 格式输出结果 | false | `--json` |
| `--txt` | 以纯文本格式输出结果 | false | `--txt` |
| `-o, --output <file>` | 将结果保存到文件 | stdout | `-o results.txt` |
| `-h, --help` | 显示帮助信息 | - | `--help` |

## 📊 性能表现

ZigScan 专为速度和效率而设计：

### 基准测试结果

```bash
# 测试环境：Intel Core i7-9750H, 16GB RAM, Ubuntu 22.04

# 使用 100 个并发连接扫描 475 个端口
$ time zigscan -t 103.235.46.115 -r 80-555 -c 100
[*] 扫描完成，耗时 5123ms
[*] 开放端口：2/475 (80, 443)
real    0m5.123s

# 使用 200 个并发连接扫描相同的 475 个端口
$ time zigscan -t 103.235.46.115 -r 80-555 -c 200
[*] 扫描完成，耗时 2891ms
[*] 开放端口：2/475 (80, 443)
real    0m2.891s

# 使用高并发进行全端口扫描（65535 个端口）
$ time zigscan -t scanme.nmap.org -r 1-65535 -c 2000 --timeout 500
[*] 扫描完成，耗时 45821ms
[*] 开放端口：4/65535
real    0m45.821s
```

### 性能优化建议

1. **调整并发数**：更高的并发 = 更快的扫描（但使用更多系统资源）
   - 本地网络：`-c 2000` 或更高
   - 互联网扫描：建议 `-c 500-1000`
   
2. **调整超时**：更低的超时 = 更快地扫描关闭的端口
   - 快速网络：`--timeout 500`
   - 慢速/远程：`--timeout 2000`

3. **针对特定端口**：扫描更少的端口总是更快
   - 对已知服务使用 `-p`
   - 对合理范围使用 `-r`

## 🛠️ 从源码构建

### 前提条件

- **Zig 0.13.0 或更高版本** ([下载 Zig](https://ziglang.org/download/))
- Git

### 构建步骤

```bash
# 克隆仓库
git clone https://github.com/gnusec/zigscan.git
cd zigscan

# 构建（调试模式）
zig build

# 构建（优化/发布模式）
zig build -Doptimize=ReleaseFast

# 运行
./zig-out/bin/zigscan --help

# 安装到系统（Linux/macOS）
sudo cp zig-out/bin/zigscan /usr/local/bin/

# 验证
zigscan --version
```

### 交叉编译

```bash
# 从 macOS/Windows 为 Linux 构建
zig build -Dtarget=x86_64-linux-gnu -Doptimize=ReleaseFast

# 从 Linux/Windows 为 macOS ARM 构建
zig build -Dtarget=aarch64-macos -Doptimize=ReleaseFast

# 从 Linux/macOS 为 Windows 构建
zig build -Dtarget=x86_64-windows-gnu -Doptimize=ReleaseFast
```

## 🤝 贡献

欢迎贡献！请随时提交 Pull Request。

1. Fork 本仓库
2. 创建你的功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交你的更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 开启一个 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

## 🙏 致谢

- 灵感来自 [RustScan](https://github.com/RustScan/RustScan)
- 使用 [Zig](https://ziglang.org/) 构建

---

<div align="center">

Made with ❤️ by the ZigScan Team

</div>
