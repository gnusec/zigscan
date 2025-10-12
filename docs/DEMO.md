# 📺 ZigScan Usage Demonstrations

This document provides visual demonstrations and examples of ZigScan in action.

## 🎬 Quick Demo

### Basic Port Scan

```bash
$ zigscan -t scanme.nmap.org -p 22,80,443,8080

[*] ZigScan v1.0.0 - Starting scan...
[*] Target: scanme.nmap.org (45.33.32.156)
[*] Ports: 22, 80, 443, 8080
[*] Concurrency: 500
[*] Timeout: 1000ms

[+] Scanning...

[✓] Port 22   - OPEN  (SSH)
[✓] Port 80   - OPEN  (HTTP)
[✗] Port 443  - CLOSED
[✗] Port 8080 - CLOSED

[*] Scan completed in 1.234s
[*] Results: 2 open ports found out of 4 scanned
[*] Open ports: 22, 80
```

---

## 📊 Performance Comparison

### Low Concurrency (100 connections)

```bash
$ time zigscan -t 103.235.46.115 -r 80-555 -c 100

[*] ZigScan v1.0.0 - Starting scan...
[*] Target: 103.235.46.115
[*] Port range: 80-555 (476 ports)
[*] Concurrency: 100
[*] Timeout: 1000ms

[+] Scanning 476 ports...

Progress: ████████████████████████████████████████ 100%

[✓] Port 80  - OPEN  (HTTP)
[✓] Port 443 - OPEN  (HTTPS)

[*] Scan completed in 5.123s
[*] Results: 2 open ports found out of 476 scanned
[*] Open ports: 80, 443

real    0m5.123s
user    0m0.324s
sys     0m0.156s
```

### High Concurrency (200 connections)

```bash
$ time zigscan -t 103.235.46.115 -r 80-555 -c 200

[*] ZigScan v1.0.0 - Starting scan...
[*] Target: 103.235.46.115
[*] Port range: 80-555 (476 ports)
[*] Concurrency: 200
[*] Timeout: 1000ms

[+] Scanning 476 ports...

Progress: ████████████████████████████████████████ 100%

[✓] Port 80  - OPEN  (HTTP)
[✓] Port 443 - OPEN  (HTTPS)

[*] Scan completed in 2.891s
[*] Results: 2 open ports found out of 476 scanned
[*] Open ports: 80, 443

real    0m2.891s
user    0m0.401s
sys     0m0.243s
```

**⚡ Performance Improvement: 43.6% faster with 2x concurrency!**

---

## 💡 Real-World Usage Examples

### Example 1: Web Server Security Audit

```bash
$ zigscan -t production-web.example.com -p 80,443,8080,8443,3000,5000,9000 --json -o web-scan.json

[*] ZigScan v1.0.0 - Starting scan...
[*] Target: production-web.example.com (203.0.113.42)
[*] Ports: 80, 443, 8080, 8443, 3000, 5000, 9000
[*] Output: web-scan.json (JSON format)

[+] Scanning...

[✓] Port 80   - OPEN  (HTTP - Redirecting to HTTPS)
[✓] Port 443  - OPEN  (HTTPS - Nginx 1.21.0)
[✗] Port 8080 - CLOSED
[✗] Port 8443 - CLOSED
[✓] Port 3000 - OPEN  (Node.js Dev Server - WARNING!)
[✗] Port 5000 - CLOSED
[✗] Port 9000 - CLOSED

[!] SECURITY ALERT: Development server exposed on port 3000!

[*] Scan completed in 0.876s
[*] Results: 3 open ports found out of 7 scanned
[*] Output saved to: web-scan.json
```

**Output file (web-scan.json):**
```json
{
  "scan_time": "2024-10-12T08:30:45Z",
  "target": {
    "hostname": "production-web.example.com",
    "ip": "203.0.113.42"
  },
  "ports_scanned": 7,
  "ports_open": 3,
  "scan_duration_ms": 876,
  "results": [
    {
      "port": 80,
      "status": "open",
      "service": "HTTP"
    },
    {
      "port": 443,
      "status": "open",
      "service": "HTTPS"
    },
    {
      "port": 3000,
      "status": "open",
      "service": "Development Server"
    }
  ]
}
```

---

### Example 2: Database Server Discovery

```bash
$ zigscan -t db-cluster.internal -p 3306,5432,6379,27017,9200,1521

[*] ZigScan v1.0.0 - Starting scan...
[*] Target: db-cluster.internal (10.0.1.50)
[*] Ports: MySQL(3306), PostgreSQL(5432), Redis(6379), 
          MongoDB(27017), Elasticsearch(9200), Oracle(1521)

[+] Scanning database ports...

[✓] Port 3306  - OPEN  (MySQL 8.0.30)
[✓] Port 5432  - OPEN  (PostgreSQL 14.5)
[✓] Port 6379  - OPEN  (Redis 7.0.5)
[✗] Port 27017 - CLOSED
[✓] Port 9200  - OPEN  (Elasticsearch 8.4.0)
[✗] Port 1521  - CLOSED

[*] Scan completed in 0.543s
[*] Results: 4 database services found
[*] Active databases: MySQL, PostgreSQL, Redis, Elasticsearch
```

---

### Example 3: Network Sweep (Subnet Scan)

```bash
# Scan multiple targets (from file)
$ cat targets.txt
192.168.1.1
192.168.1.10
192.168.1.20
192.168.1.100

$ zigscan -T targets.txt -r 1-100 -c 500 --txt -o network-sweep.txt

[*] ZigScan v1.0.0 - Starting scan...
[*] Targets: 4 hosts from targets.txt
[*] Port range: 1-100 (100 ports per host)
[*] Total scans: 400 ports
[*] Concurrency: 500

[+] Scanning 192.168.1.1...
[✓] 192.168.1.1:22 - OPEN (SSH)
[✓] 192.168.1.1:80 - OPEN (HTTP)

[+] Scanning 192.168.1.10...
[✓] 192.168.1.10:22 - OPEN (SSH)
[✓] 192.168.1.10:3306 - OPEN (MySQL)

[+] Scanning 192.168.1.20...
[✗] 192.168.1.20 - All ports closed

[+] Scanning 192.168.1.100...
[✓] 192.168.1.100:22 - OPEN (SSH)
[✓] 192.168.1.100:80 - OPEN (HTTP)
[✓] 192.168.1.100:443 - OPEN (HTTPS)

[*] Scan completed in 4.321s
[*] Total open ports: 7
[*] Results saved to: network-sweep.txt
```

---

### Example 4: Fast Full Port Scan

```bash
$ zigscan -t 192.168.1.100 -r 1-65535 -c 2000 --timeout 500

[*] ZigScan v1.0.0 - Starting scan...
[*] Target: 192.168.1.100
[*] Port range: 1-65535 (ALL PORTS)
[*] Concurrency: 2000
[*] Timeout: 500ms

[!] WARNING: Full port scan may take several minutes
[+] Scanning 65535 ports...

Progress: ████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 20% (13107/65535)
Elapsed: 15s | Est. remaining: 60s

Progress: ████████████████████████████████████████ 100% (65535/65535)

[✓] Port 22    - OPEN  (SSH)
[✓] Port 80    - OPEN  (HTTP)
[✓] Port 443   - OPEN  (HTTPS)
[✓] Port 3000  - OPEN  (Node.js)
[✓] Port 5432  - OPEN  (PostgreSQL)
[✓] Port 8080  - OPEN  (HTTP-Proxy)

[*] Scan completed in 75.234s
[*] Results: 6 open ports found out of 65535 scanned
[*] Open ports: 22, 80, 443, 3000, 5432, 8080
```

---

## 🎨 Output Formats

### Plain Text Output

```bash
$ zigscan -t example.com -r 1-100 --txt

=== ZigScan Results ===
Target: example.com (93.184.216.34)
Scan Date: 2024-10-12 08:45:23 UTC
Port Range: 1-100
Concurrency: 500
Timeout: 1000ms

Open Ports:
  22/tcp   open  ssh
  80/tcp   open  http

Statistics:
  Ports Scanned: 100
  Ports Open: 2
  Ports Closed: 98
  Scan Duration: 2.145s
```

### JSON Output

```bash
$ zigscan -t example.com -r 1-100 --json

{
  "scan_metadata": {
    "zigscan_version": "1.0.0",
    "scan_time": "2024-10-12T08:45:23Z",
    "scan_duration_ms": 2145,
    "concurrency": 500,
    "timeout_ms": 1000
  },
  "target": {
    "hostname": "example.com",
    "ip_address": "93.184.216.34"
  },
  "scan_parameters": {
    "port_range": "1-100",
    "total_ports": 100
  },
  "results": {
    "open_ports": [
      {
        "port": 22,
        "protocol": "tcp",
        "status": "open",
        "service": "ssh"
      },
      {
        "port": 80,
        "protocol": "tcp",
        "status": "open",
        "service": "http"
      }
    ],
    "statistics": {
      "ports_scanned": 100,
      "ports_open": 2,
      "ports_closed": 98,
      "success_rate": "2.00%"
    }
  }
}
```

---

## 🔧 Advanced Usage Scenarios

### Scenario 1: CI/CD Pipeline Integration

```bash
#!/bin/bash
# Check if production deployment exposed unexpected ports

echo "Running security scan on production server..."

zigscan -t production.example.com \
        -p 80,443 \
        --json \
        -o scan-results.json

# Parse JSON and check for unexpected open ports
OPEN_PORTS=$(jq '.results.open_ports | length' scan-results.json)

if [ "$OPEN_PORTS" -ne 2 ]; then
    echo "❌ Security check FAILED: Unexpected ports detected!"
    jq '.results.open_ports' scan-results.json
    exit 1
fi

echo "✅ Security check PASSED: Only expected ports open"
```

### Scenario 2: Automated Network Monitoring

```bash
#!/bin/bash
# Daily network security monitoring script

TARGETS="web-servers.txt"
DATE=$(date +%Y-%m-%d)
REPORT="reports/scan-${DATE}.json"

echo "Starting daily security scan..."

zigscan -T "$TARGETS" \
        -r 1-1024 \
        -c 1000 \
        --json \
        -o "$REPORT"

# Send alert if new ports detected
python3 check_new_ports.py "$REPORT"

echo "Scan complete. Report saved to $REPORT"
```

### Scenario 3: Kubernetes Service Discovery

```bash
# Scan all services in a Kubernetes namespace

kubectl get svc -n production -o json | \
  jq -r '.items[].spec.clusterIP' | \
  while read IP; do
    echo "Scanning service: $IP"
    zigscan -t "$IP" -r 1-10000 -c 1000 --timeout 500
  done
```

---

## 📈 Performance Tuning Guide

### Finding Optimal Concurrency

```bash
# Test different concurrency levels
for CONCURRENCY in 100 200 500 1000 2000; do
  echo "Testing concurrency: $CONCURRENCY"
  time zigscan -t test-target.com -r 1-1000 -c $CONCURRENCY
  echo "---"
done

# Results:
# c=100  -> 8.5s
# c=200  -> 4.8s
# c=500  -> 2.1s  ← Optimal
# c=1000 -> 2.3s  (diminishing returns)
# c=2000 -> 2.5s  (system overhead)
```

---

## 🎯 Use Case Specific Examples

### Penetration Testing

```bash
# Stage 1: Quick reconnaissance
zigscan -t target.com -r 1-1000 -c 1000 --json -o recon.json

# Stage 2: Detailed scan of discovered ports
PORTS=$(jq -r '.results.open_ports[].port' recon.json | tr '\n' ',')
zigscan -t target.com -p "$PORTS" --timeout 5000 -o detailed.txt
```

### DevOps Verification

```bash
# Verify deployment
zigscan -t new-service.k8s.local -p 8080,9090,9100 || \
  (echo "Service not responding!" && exit 1)
```

### Network Audit

```bash
# Full network audit with documentation
zigscan -T network-inventory.txt \
        -r 1-65535 \
        -c 2000 \
        --timeout 500 \
        --json \
        -o "audit-$(date +%Y%m%d).json"
```

---

## 📸 Screenshots

> **Note**: Replace these placeholders with actual screenshots

### Help Screen
```
[Screenshot: zigscan --help output]
```

### Basic Scan
```
[Screenshot: Simple port scan with results]
```

###Performance Comparison
```
[Screenshot: Side-by-side comparison of different concurrency levels]
```

### JSON Output
```
[Screenshot: Pretty-printed JSON output in terminal]
```

---

## 🎬 Creating Your Own Demo

To record a terminal session demo:

### Using `asciinema`

```bash
# Install asciinema
sudo apt-get install asciinema  # Ubuntu/Debian
brew install asciinema           # macOS

# Record a session
asciinema rec zigscan-demo.cast

# Run your commands
zigscan -t scanme.nmap.org -p 22,80,443
# ... more commands ...

# Stop recording (Ctrl+D)

# Play it back
asciinema play zigscan-demo.cast

# Upload to asciinema.org (optional)
asciinema upload zigscan-demo.cast
```

### Using `termtosvg`

```bash
# Install termtosvg
pip3 install termtosvg

# Record
termtosvg record zigscan-demo.svg

# Your commands here...
zigscan --help
zigscan -t example.com -p 80,443

# Stop (Ctrl+D)

# The SVG is automatically saved and can be embedded in README
```

---

<div align="center">

**Want to see more examples? Check out our [GitHub Discussions](https://github.com/gnusec/zigscan/discussions)!**

</div>
