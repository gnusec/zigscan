#!/bin/bash

# Test script for ZigScan port scanner
# This demonstrates various features and validates the implementation

set -e

echo "======================================"
echo "ZigScan Test Suite"
echo "======================================"
echo ""

# Ensure the binary exists
if [ ! -f "./zig-out/bin/zigscan" ]; then
    echo "Error: zigscan binary not found. Please run 'zig build' first."
    exit 1
fi

SCANNER="./zig-out/bin/zigscan"
TEST_IP="103.235.46.115"  # Test IP with ports 80,443 open

echo "Test 1: Help message"
echo "--------------------"
$SCANNER --help
echo ""

echo "Test 2: Scan specific ports on test IP"
echo "---------------------------------------"
$SCANNER -t $TEST_IP -p 80,443
echo ""

echo "Test 3: Scan port range with custom timeout"
echo "--------------------------------------------"
$SCANNER -t $TEST_IP -r 70-90 --timeout 500
echo ""

echo "Test 4: JSON output format"
echo "--------------------------"
$SCANNER -t $TEST_IP -p 80,443,8080 --json
echo ""

echo "Test 5: TXT output to file"
echo "--------------------------"
$SCANNER -t $TEST_IP -p 22,80,443,3306 --txt -o test_results.txt
cat test_results.txt
rm -f test_results.txt
echo ""

echo "Test 6: Test with low concurrency (should be slower)"
echo "-----------------------------------------------------"
echo "Scanning 20 ports with concurrency=5..."
$SCANNER -t $TEST_IP -r 1-20 -c 5 --timeout 300 | grep "completed in"
echo ""

echo "Test 7: Test with high concurrency (should be faster)"
echo "------------------------------------------------------"
echo "Scanning 20 ports with concurrency=20..."
$SCANNER -t $TEST_IP -r 1-20 -c 20 --timeout 300 | grep "completed in"
echo ""

echo "======================================"
echo "All tests completed successfully!"
echo "======================================"
