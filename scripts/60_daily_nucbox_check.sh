#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="$HOME/linux-admin/logs"
TODAY="$(date +%F)"
LOG_FILE="$LOG_DIR/daily-check-$TODAY.log"

mkdir -p "$LOG_DIR"

{
  echo "======================================"
  echo "NUCBOX / OPENCLAW DAILY CHECK"
  echo "Date: $(date)"
  echo "Host: $(hostname)"
  echo "======================================"
  echo

  echo "## UPTIME"
  uptime
  echo

  echo "## MEMORY"
  free -m
  echo

  echo "## DISK"
  df -h
  echo

  echo "## IP ADDRESS"
  hostname -I
  echo

  echo "## OPENCLAW PROCESS"
  pgrep -af openclaw || echo "WARNING: OpenClaw process not found."
  echo

  echo "## OPENCLAW PORT 18789"
  ss -tulnp | grep ':18789' || echo "WARNING: Port 18789 not listening."
  echo

  echo "## NGINX STATUS"
  systemctl is-active nginx || true
  systemctl --no-pager status nginx || true
  echo

  echo "## RECENT SYSTEM ERRORS"
  journalctl -p 3 -xb --no-pager | tail -50 || true
  echo

  echo "======================================"
  echo "CHECK COMPLETE"
  echo "Log saved to: $LOG_FILE"
  echo "======================================"

} | tee "$LOG_FILE"
