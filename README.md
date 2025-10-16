# ZigScan - High-Performance Port Scanner

[![CI](https://github.com/gnusec/zigscan/actions/workflows/ci.yml/badge.svg)](https://github.com/gnusec/zigscan/actions/workflows/ci.yml)
[![Release](https://github.com/gnusec/zigscan/actions/workflows/release.yml/badge.svg)](https://github.com/gnusec/zigscan/actions/workflows/release.yml)
[![License](https://img.shields.io/github/license/gnusec/zigscan)](LICENSE)
[![Latest Release](https://img.shields.io/github/v/release/gnusec/zigscan)](https://github.com/gnusec/zigscan/releases/latest)

A high-performance port scanner written in Zig, similar to RustScan, designed for fast and efficient network port scanning.

### 10s Quick Demo

<p align="center">
  <img src="assets/cli-demo.svg" alt="zigscan CLI demo animation" />
  <br/>
  <sub>If the animation does not play in your viewer, open the raw file or view on GitHub web.</sub>
  
</p>

## ⚡ Quick Start

### Downloads (v0.1.2)

Stable builds (static preferred, dynamic fallback when required):

| OS | Arch | Libc | Target | Download |
|---|---|---|---|---|
| Linux | x86_64 | glibc | x86_64-linux-gnu | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-x86_64-linux-gnu.tar.gz |
| Linux | aarch64 | glibc | aarch64-linux-gnu | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-aarch64-linux-gnu.tar.gz |
| Linux | armv7 (armhf) | glibc | arm-linux-gnueabihf | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-arm-linux-gnueabihf.tar.gz |
| Linux | x86 (i386) | glibc | x86-linux-gnu | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-x86-linux-gnu.tar.gz |
| Linux | riscv64 | glibc | riscv64-linux-gnu | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-riscv64-linux-gnu.tar.gz |
| Linux | x86_64 | musl | x86_64-linux-musl | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-x86_64-linux-musl.tar.gz |
| Linux | aarch64 | musl | aarch64-linux-musl | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-aarch64-linux-musl.tar.gz |
| macOS | x86_64 | - | x86_64-macos | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-x86_64-macos.tar.gz |
| macOS | aarch64 (Apple Silicon) | - | aarch64-macos | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-aarch64-macos.tar.gz |

Experimental builds (allowed to fail in CI; availability may vary): Windows x86_64/aarch64/x86, loongarch64, mips/mipsel/mips64/mips64el (gnu/musl), ppc64le, s390x, riscv32, riscv64-musl, arm-musleabihf.

#### Experimental Downloads (v0.1.2)

| OS | Arch | Libc | Target | Download |
|---|---|---|---|---|
| Windows | x86_64 | - | x86_64-windows | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-x86_64-windows.zip |
| Windows | aarch64 | - | aarch64-windows | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-aarch64-windows.zip |
| Windows | x86 | - | x86-windows | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-x86-windows.zip |
| Linux | loongarch64 | glibc | loongarch64-linux-gnu | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-loongarch64-linux-gnu.tar.gz |
| Linux | mips | musl | mips-linux-musl | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-mips-linux-musl.tar.gz |
| Linux | mipsel | musl | mipsel-linux-musl | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-mipsel-linux-musl.tar.gz |
| Linux | mips64 | musl | mips64-linux-musl | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-mips64-linux-musl.tar.gz |
| Linux | mips64el | musl | mips64el-linux-musl | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-mips64el-linux-musl.tar.gz |
| Linux | mips | glibc | mips-linux-gnu | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-mips-linux-gnu.tar.gz |
| Linux | mipsel | glibc | mipsel-linux-gnu | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-mipsel-linux-gnu.tar.gz |
| Linux | mips64 | glibc | mips64-linux-gnu | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-mips64-linux-gnu.tar.gz |
| Linux | mips64el | glibc | mips64el-linux-gnu | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-mips64el-linux-gnu.tar.gz |
| Linux | powerpc64le | glibc | powerpc64le-linux-gnu | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-powerpc64le-linux-gnu.tar.gz |
| Linux | s390x | glibc | s390x-linux-gnu | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-s390x-linux-gnu.tar.gz |
| Linux | riscv32 | glibc | riscv32-linux-gnu | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-riscv32-linux-gnu.tar.gz |
| Linux | riscv64 | musl | riscv64-linux-musl | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-riscv64-linux-musl.tar.gz |
| Linux | armv7 (armhf) | musl | arm-linux-musleabihf | https://github.com/gnusec/zigscan/releases/download/v0.1.2/zigscan-arm-linux-musleabihf.tar.gz |

### Build from Source

Requirements:
- Zig 0.16 (nightly, master)

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
Version: 0.1.2

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



