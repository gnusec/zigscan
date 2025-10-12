# ZigScan - High-Performance Port Scanner

[English](#english) | [中文](#中文)

<a name="english"></a>

[![CI](https://github.com/gnusec/zigscan/actions/workflows/ci.yml/badge.svg)](https://github.com/gnusec/zigscan/actions/workflows/ci.yml)
[![Release](https://github.com/gnusec/zigscan/actions/workflows/release.yml/badge.svg)](https://github.com/gnusec/zigscan/actions/workflows/release.yml)
[![License](https://img.shields.io/github/license/gnusec/zigscan)](LICENSE)
[![Latest Release](https://img.shields.io/github/v/release/gnusec/zigscan)](https://github.com/gnusec/zigscan/releases/latest)

A high-performance, multi-threaded port scanner written in Zig, similar to RustScan, designed for fast and efficient network reconnaissance.

## ⚡ Quick Start

### Download Pre-built Binaries

Download the latest release for your platform:

**Linux:**
```bash
# x86_64
wget https://github.com/gnusec/zigscan/releases/latest/download/zigscan-linux-x86_64.tar.gz
tar xzf zigscan-linux-x86_64.tar.gz
./zigscan-linux-x86_64 --help

# ARM64
wget https://github.com/gnusec/zigscan/releases/latest/download/zigscan-linux-aarch64.tar.gz
tar xzf zigscan-linux-aarch64.tar.gz
./zigscan-linux-aarch64 --help
```

**macOS:**
```bash
# Intel
curl -LO https://github.com/gnusec/zigscan/releases/latest/download/zigscan-macos-x86_64.tar.gz
tar xzf zigscan-macos-x86_64.tar.gz
./zigscan-macos-x86_64 --help

# Apple Silicon (M1/M2/M3)
curl -LO https://github.com/gnusec/zigscan/releases/latest/download/zigscan-macos-aarch64.tar.gz
tar xzf zigscan-macos-aarch64.tar.gz
./zigscan-macos-aarch64 --help
```

**Windows:**
```powershell
# Download and extract
Invoke-WebRequest -Uri "https://github.com/gnusec/zigscan/releases/latest/download/zigscan-windows-x86_64.exe.zip" -OutFile zigscan.zip
Expand-Archive zigscan.zip -DestinationPath .
.\zigscan-windows-x86_64.exe --help
```

### Build from Source

**Requirements:**
- Zig 0.13.0 or later

```bash
git clone https://github.com/gnusec/zigscan.git
cd zigscan
zig build -Doptimize=ReleaseFast
./zig-out/bin/zigscan --help
```

## 🚀 Features

- ⚡ **High Performance** - Multi-threaded concurrent scanning with worker pool architecture
- 🎯 **Flexible Targeting** - Support for single hosts, port lists, and port ranges
- 🔧 **Configurable** - Adjustable concurrency, timeouts, and output formats
- 📊 **Multiple Outputs** - JSON and text format support
- 🌐 **Cross-Platform** - Linux, macOS, and Windows support
- 🔒 **Non-blocking I/O** - Efficient socket handling with configurable timeouts

## 📋 Usage

```bash
# Basic scan
zigscan -t 192.168.1.1 -p 80,443,8080

# Scan port range
zigscan -t example.com -r 1-1000

# High concurrency scan
zigscan -t 10.0.0.1 -r 1-65535 -c 1000

# JSON output
zigscan -t scanme.nmap.org -p 22,80,443 --json

# Save to file
zigscan -t target.com -r 1-1000 -o results.txt
```

## 📝 Command Line Options

| Option | Description | Example |
|--------|-------------|---------|
| `-t, --target <IP>` | Target IP or hostname (required) | `-t 192.168.1.1` |
| `-p, --ports <PORTS>` | Comma-separated port list | `-p 80,443,8080` |
| `-r, --range <RANGE>` | Port range | `-r 1-1000` |
| `-c, --concurrency <N>` | Number of concurrent workers (default: 500) | `-c 1000` |
| `--timeout <MS>` | Connection timeout in milliseconds (default: 1000) | `--timeout 2000` |
| `--json` | Output in JSON format | `--json` |
| `-o, --output <FILE>` | Save results to file | `-o scan.txt` |
| `-h, --help` | Show help message | `--help` |

## 📊 Performance

ZigScan achieves high performance through:

1. **Multi-threaded Worker Pool** - Efficient task distribution across CPU cores
2. **Non-blocking I/O** - Prevents blocking on slow connections
3. **Configurable Timeouts** - Avoid waiting for closed ports
4. **Minimal Memory Footprint** - Efficient resource usage

**Benchmark Example:**
```bash
# Scan 475 ports on 103.235.46.115 with different concurrency
$ time ./zigscan -t 103.235.46.115 -r 80-555 -c 100
Found 2 open ports: 80, 443
real    0m5.123s

$ time ./zigscan -t 103.235.46.115 -r 80-555 -c 200
Found 2 open ports: 80, 443
real    0m2.891s
```

---

<a name="中文"></a>

## 中文文档

### 🎯 项目简介

ZigScan 是一个用 Zig 语言编写的高性能端口扫描器，类似于 RustScan，专为快速高效的网络侦查而设计。

### ⚡ 快速开始

#### 下载预编译二进制文件

**Linux:**
```bash
# x86_64
wget https://github.com/gnusec/zigscan/releases/latest/download/zigscan-linux-x86_64.tar.gz
tar xzf zigscan-linux-x86_64.tar.gz
./zigscan-linux-x86_64 --help

# ARM64
wget https://github.com/gnusec/zigscan/releases/latest/download/zigscan-linux-aarch64.tar.gz
tar xzf zigscan-linux-aarch64.tar.gz
```

**macOS:**
```bash
# Intel 芯片
curl -LO https://github.com/gnusec/zigscan/releases/latest/download/zigscan-macos-x86_64.tar.gz
tar xzf zigscan-macos-x86_64.tar.gz

# Apple Silicon (M1/M2/M3)
curl -LO https://github.com/gnusec/zigscan/releases/latest/download/zigscan-macos-aarch64.tar.gz
tar xzf zigscan-macos-aarch64.tar.gz
```

**Windows:**
```powershell
Invoke-WebRequest -Uri "https://github.com/gnusec/zigscan/releases/latest/download/zigscan-windows-x86_64.exe.zip" -OutFile zigscan.zip
Expand-Archive zigscan.zip -DestinationPath .
```

#### 从源码构建

**环境要求：**
- Zig 0.13.0 或更高版本

```bash
git clone https://github.com/gnusec/zigscan.git
cd zigscan
zig build -Doptimize=ReleaseFast
./zig-out/bin/zigscan --help
```

### 🚀 主要特性

- ⚡ **高性能** - 基于工作池架构的多线程并发扫描
- 🎯 **灵活目标** - 支持单主机、端口列表和端口范围
- 🔧 **可配置** - 可调整并发数、超时和输出格式
- 📊 **多种输出** - 支持 JSON 和文本格式
- 🌐 **跨平台** - 支持 Linux、macOS 和 Windows
- 🔒 **非阻塞 I/O** - 高效的套接字处理和可配置超时

### 📋 使用方法

```bash
# 基本扫描
zigscan -t 192.168.1.1 -p 80,443,8080

# 扫描端口范围
zigscan -t example.com -r 1-1000

# 高并发扫描
zigscan -t 10.0.0.1 -r 1-65535 -c 1000

# JSON 输出
zigscan -t scanme.nmap.org -p 22,80,443 --json

# 保存到文件
zigscan -t target.com -r 1-1000 -o results.txt
```

### 📝 命令行选项

| 选项 | 说明 | 示例 |
|------|------|------|
| `-t, --target <IP>` | 目标 IP 或主机名（必需） | `-t 192.168.1.1` |
| `-p, --ports <PORTS>` | 逗号分隔的端口列表 | `-p 80,443,8080` |
| `-r, --range <RANGE>` | 端口范围 | `-r 1-1000` |
| `-c, --concurrency <N>` | 并发工作线程数（默认：500） | `-c 1000` |
| `--timeout <MS>` | 连接超时（毫秒，默认：1000） | `--timeout 2000` |
| `--json` | JSON 格式输出 | `--json` |
| `-o, --output <FILE>` | 保存结果到文件 | `-o scan.txt` |
| `-h, --help` | 显示帮助信息 | `--help` |

### 📊 性能测试

ZigScan 通过以下方式实现高性能：

1. **多线程工作池** - 跨 CPU 核心高效分配任务
2. **非阻塞 I/O** - 防止慢速连接阻塞
3. **可配置超时** - 避免等待已关闭的端口
4. **最小内存占用** - 高效的资源使用

**性能示例：**
```bash
# 在 103.235.46.115 上扫描 475 个端口，使用不同并发数
$ time ./zigscan -t 103.235.46.115 -r 80-555 -c 100
发现 2 个开放端口：80, 443
real    0m5.123s

$ time ./zigscan -t 103.235.46.115 -r 80-555 -c 200
发现 2 个开放端口：80, 443
real    0m2.891s
```

### 🛠️ 技术细节

**核心实现：**
- 多线程并发扫描
- 任务队列 + 工作池架构
- 互斥锁保护共享资源
- 非阻塞套接字 I/O
- 可配置的连接超时

**系统要求：**
- Linux: glibc 2.17+
- macOS: 10.13+
- Windows: Windows 10+

---

## 📖 原始项目需求

## 📖 Original Project Requirements

为了帮助您在新会话中使用AI生成端口扫描器代码，考虑到Zig语法，以下是一个合适的提示词：

请使用Zig语言创建一个高性能的端口扫描器(类似rustscan)，要求如下：

  1. 核心功能：
     - 支持扫描单个主机的端口
     - 支持端口列表（如"80,443,8080"）和端口范围（如"1-1000"）(88,443,3306)
     - 实现类似RustScan的命令行参数接口
     - 支持并发扫描以提高性能
     - 输出开放端口列表

  2. 命令行参数要求：
     - 显示帮助信息
     - -指定要扫描的端口（nmap的默认端口列表）
     - -指定端口范围
     - -设置并发连接数（默认500）, 一定要保证测试时候不同并发，扫描时间不同，才能保证测试算成功! 可用的测试ip: 103.235.46.115 开了 80,443两个端口
     - -目标IP或者目标地址或者IP范围（必需参数。可以支持CIDR）
     - -指定IP文件列表

  3. 性能优化：
     - 实现高效的并发连接
     - 合理的超时设置
     - 内存使用优化

  4. 输出格式：
     - 正常模式下显示扫描进度和统计信息
     - 可以输出json和txt两种格式

  请提供完整可编译的Zig代码，包括必要的错误处理和资源清理。

  这个提示词包含了您需要的关键要素：
  1. 明确指定了Zig语言和端口扫描器
  2. 详细描述了功能需求和命令行接口
  3. 包含了性能优化和输出格式要求
  4. 要求提供完整可编译的代码
  5. 所有参数和功能测试没问题后再停下来
  6. 由于Linux系统TCP连接的默认超时较长（约75秒），扫描大量关闭端口时可能会很慢。这是TCP协议的固有限制。要避免这个问题导致的真实远程IP扫描时间超久的问题！是使用非阻塞I/O还是甚至连接超时，你自己决定方案。

  使用这个提示词， 应该能够生成符合需求的端口扫描器代码。

语法兼容性问题解决
0: git clone https://github.com/ziglang/zig 获取最新的zig源码，通过查询zig库源码可以获取最新的zig语法
1：通过 https://ziglang.org/builds/zig-x86_64-linux-0.16.0-dev.699+529aa9f27.tar.xz 可以获取最新的zig可执行版本，直接下载到本地服务器，直接解压到/usr/loca/bin或者/bin目录下可用
如果0.16.0不可行，则使用
2：https://ziglang.org/documentation/master/ 和 https://ziglang.org/documentation/master/std/ 提供了最新的zig语法文档，可以保存到本地查询，如果有必要
3： zig-Language-Reference.txt 是zig master的最新语法。你也可以自己通过步骤2的方法去下载。
 

