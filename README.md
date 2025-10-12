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
 

