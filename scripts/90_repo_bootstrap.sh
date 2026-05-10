#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo "   Linux Repo Bootstrap (GitHub)      "
echo "======================================"

REPO_NAME="linux-base-install"
GITHUB_USER="aheadrickjr"
REPO_URL="https://github.com/${GITHUB_USER}/${REPO_NAME}.git"

SRC_DIR="$HOME/linux-admin"
DEST_DIR="$HOME/${REPO_NAME}"

echo "[+] Creating repo directory at $DEST_DIR"
mkdir -p "$DEST_DIR/scripts"

echo "[+] Copying scripts and menu..."
cp "$SRC_DIR/linux_admin_menu.sh" "$DEST_DIR/"
cp "$SRC_DIR/scripts/"*.sh "$DEST_DIR/scripts/"

echo "[+] Creating README.md..."
cat <<'EOF' > "$DEST_DIR/README.md"
# linux-base-install

Generic Linux base install and admin framework (Ubuntu-first).

## Purpose

Provides a reusable baseline for Linux host setup and administration without tying to any application stack.

## Features

- Base host build (Ubuntu 24.04)
- Network inspection
- SSH status review
- Git HTTPS + PAT workflow
- Nginx + SSL setup (DNS Required)

## Structure

- linux_admin_menu.sh
- scripts/

## Usage

chmod +x linux_admin_menu.sh scripts/*.sh
./linux_admin_menu.sh

## Notes

- No secrets, PATs, or credentials stored in this repo
- SSL requires DNS to already be configured
- Git uses HTTPS + PAT (no credential-store)
EOF

cd "$DEST_DIR"

echo "[+] Initializing git repo..."
git init
git branch -M main

echo "[+] Adding files..."
git add .

echo "[+] Creating initial commit..."
git commit -m "Initial Linux base install framework"

echo "[+] Adding remote..."
git remote add origin "$REPO_URL" || true

echo "[+] Preparing secure PAT push..."

read -rp "Enter GitHub Username: " GH_USER
read -rsp "Enter GitHub PAT (hidden): " GH_PAT
echo

AUTH_HEADER=$(printf "%s:%s" "$GH_USER" "$GH_PAT" | base64 | tr -d '\n')

echo "[+] Pushing to GitHub..."
git -c http.extraHeader="Authorization: Basic $AUTH_HEADER" push -u origin main

unset GH_PAT
unset AUTH_HEADER

echo
echo "======================================"
echo "     Repo Bootstrap Complete          "
echo "======================================"
echo "Repo: $REPO_URL"
echo "Location: $DEST_DIR"
