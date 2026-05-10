#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo "     Base Host Build - Ubuntu 24.04    "
echo "======================================"

# --- OS Check ---
if ! grep -q "Ubuntu" /etc/os-release; then
    echo "This script is intended for Ubuntu systems only."
    exit 1
fi

echo "[+] Updating system..."
sudo apt update -y
sudo apt upgrade -y

echo "[+] Installing base packages..."
sudo apt install -y \
    curl \
    git \
    ufw \
    nginx \
    certbot \
    python3-certbot-nginx \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    net-tools \
    htop

echo "[+] Checking Node.js..."
if ! command -v node >/dev/null 2>&1; then
    echo "[+] Installing Node.js (v22)..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt install -y nodejs
fi

echo "[+] Enabling services..."
sudo systemctl enable ssh
sudo systemctl restart ssh

sudo systemctl enable nginx
sudo systemctl restart nginx

echo "[+] Testing Nginx configuration..."
sudo nginx -t

echo "[+] Adding GitHub to known_hosts..."
mkdir -p ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null

echo ""
echo "======================================"
echo " Base Host Build Complete"
echo "======================================"

echo ""
echo "System Info:"
hostnamectl
echo ""
ip -br a
echo ""
