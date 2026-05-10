# filename: scripts/20_network_info.sh
#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo "           Network Information        "
echo "======================================"

echo
echo "[+] Hostname"
hostnamectl || true

echo
echo "[+] Interfaces"
ip -br a

echo
echo "[+] Full Interface Details"
ip a

echo
echo "[+] Routes"
ip route

echo
echo "[+] DNS Resolver Status"
if command -v resolvectl >/dev/null 2>&1; then
    resolvectl status || true
else
    echo "resolvectl not available on this host."
fi
