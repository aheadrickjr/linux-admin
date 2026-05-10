#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$HOME/linux-admin"
SCRIPTS_DIR="$BASE_DIR/scripts"

pause() {
  echo
  read -r -p "Press Enter to continue..."
}

while true; do
  clear
  echo "======================================"
  echo "          Linux Admin Menu"
  echo "======================================"
  echo "1. Run Base Host Build"
  echo "2. Show Network Info"
  echo "3. Show SSH Status"
  echo "4. Git HTTPS + PAT Setup"
  echo "5. Nginx + SSL Setup (DNS Required)"
  echo "6. Daily NucBox / OpenClaw Health Check"
  echo "7. Open Shell"
  echo "8. Edit Base Host Build Script"
  echo "9. Exit"
  echo "======================================"
  read -r -p "Select an option: " choice

  case "$choice" in
    1)
      bash "$SCRIPTS_DIR/10_base_host_build.sh"
      pause
      ;;
    2)
      bash "$SCRIPTS_DIR/20_network_info.sh"
      pause
      ;;
    3)
      bash "$SCRIPTS_DIR/30_ssh_status.sh"
      pause
      ;;
    4)
      bash "$SCRIPTS_DIR/40_git_pat_setup.sh"
      pause
      ;;
    5)
      bash "$SCRIPTS_DIR/50_nginx_ssl_setup.sh"
      pause
      ;;
    6)
      bash "$SCRIPTS_DIR/60_daily_nucbox_check.sh"
      pause
      ;;
    7)
      bash
      ;;
    8)
      nano "$SCRIPTS_DIR/10_base_host_build.sh"
      ;;
    9)
      echo "Exiting."
      exit 0
      ;;
    *)
      echo "Invalid option."
      pause
      ;;
  esac
done
