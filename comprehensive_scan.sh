#!/bin/bash
# comprehensive_scan.sh

echo "=== Starting Comprehensive Vulnerability Assessment ==="

# 1. Live host detection
echo "[1/5] Checking for live hosts..."
cat external_targets_clean.txt | httpx -silent -threads 50 -timeout 5 > live_hosts.txt
echo "    Found $(wc -l < live_hosts.txt) live hosts"

# 2. Technology detection
echo "[2/5] Detecting technologies..."
cat live_hosts.txt | httpx -silent -tech-detect -status-code -title > technology_stack.txt

# 3. Critical vulnerability scan
echo "[3/5] Scanning for critical vulnerabilities..."
cat live_hosts.txt | nuclei \
  -t /root/.local/nuclei-templates/ \
  -severity critical,high \
  -rate-limit 100 \
  -concurrency 20 \
  -o critical_results.txt

# 4. Common web vulnerabilities
echo "[4/5] Scanning for common web vulnerabilities..."
cat live_hosts.txt | nuclei \
  -t /root/.local/nuclei-templates/vulnerabilities/ \
  -severity medium,high,critical \
  -o web_vulnerabilities.txt

# 5. Exposed panels and misconfigurations
echo "[5/5] Scanning for exposed panels..."
cat live_hosts.txt | nuclei \
  -t /root/.local/nuclei-templates/exposed-panels/ \
  -t /root/.local/nuclei-templates/misconfiguration/ \
  -o exposed_panels.txt

echo "=== Scan Complete ==="
echo "Results saved to:"
echo "  - live_hosts.txt ($(wc -l < live_hosts.txt) hosts)"
echo "  - technology_stack.txt"
echo "  - critical_results.txt"
echo "  - web_vulnerabilities.txt"
echo "  - exposed_panels.txt"
