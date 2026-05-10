# filename: scripts/30_ssh_status.sh
#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo "             SSH Status               "
echo "======================================"

echo
echo "[+] SSH Service Status"
sudo systemctl status ssh --no-pager || true

echo
echo "[+] Effective SSHD Settings"
sudo sshd -T | grep -E 'passwordauthentication|permitrootlogin|pubkeyauthentication|allowusers' || true

echo
echo "[+] SSH Config Sources"
sudo grep -RniE 'PasswordAuthentication|PermitRootLogin|PubkeyAuthentication|AllowUsers' \
    /etc/ssh/sshd_config /etc/ssh/sshd_config.d 2>/dev/null || true
