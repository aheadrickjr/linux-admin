# filename: scripts/50_nginx_ssl_setup.sh
#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo "      Nginx + SSL Setup (DNS Required)"
echo "======================================"
echo
echo "This workflow requires:"
echo "  - DNS for your domain/subdomain to already point to this server"
echo "  - Ports 80 and 443 to be reachable"
echo "  - Nginx to already be installed"
echo

read -rp "Continue with Nginx + SSL setup? (y/N): " PROCEED
if [[ ! "$PROCEED" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

read -rp "Enter domain name (example: app.example.com): " DOMAIN
if [[ -z "${DOMAIN:-}" ]]; then
    echo "Domain is required."
    exit 1
fi

read -rp "Enter upstream app host [127.0.0.1]: " APP_HOST
APP_HOST="${APP_HOST:-127.0.0.1}"

read -rp "Enter upstream app port [3000]: " APP_PORT
APP_PORT="${APP_PORT:-3000}"

read -rp "Enter email for Certbot notifications: " CERTBOT_EMAIL
if [[ -z "${CERTBOT_EMAIL:-}" ]]; then
    echo "Email is required for Certbot."
    exit 1
fi

NGINX_SITE="/etc/nginx/sites-available/${DOMAIN}"
NGINX_ENABLED="/etc/nginx/sites-enabled/${DOMAIN}"

echo "[+] Writing Nginx site config for ${DOMAIN} ..."
sudo tee "$NGINX_SITE" >/dev/null <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN};

    location / {
        proxy_pass http://${APP_HOST}:${APP_PORT};
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

echo "[+] Enabling site ..."
sudo ln -sf "$NGINX_SITE" "$NGINX_ENABLED"

if [[ -f /etc/nginx/sites-enabled/default ]]; then
    echo "[+] Disabling default Nginx site ..."
    sudo rm -f /etc/nginx/sites-enabled/default
fi

echo "[+] Testing Nginx config ..."
sudo nginx -t

echo "[+] Reloading Nginx ..."
sudo systemctl reload nginx

echo
echo "DNS Required Confirmation"
echo "The domain must already resolve to this server before SSL issuance."
read -rp "Run Certbot now for ${DOMAIN}? (y/N): " RUN_CERTBOT

if [[ "$RUN_CERTBOT" =~ ^[Yy]$ ]]; then
    echo "[+] Running Certbot ..."
    sudo certbot --nginx -d "$DOMAIN" -m "$CERTBOT_EMAIL" --agree-tos --no-eff-email

    echo "[+] Testing renewal ..."
    sudo certbot renew --dry-run
else
    echo "[!] Skipping SSL issuance for now."
fi

echo
echo "======================================"
echo "      Nginx + SSL Workflow Done       "
echo "======================================"
echo "Domain  : ${DOMAIN}"
echo "Upstream: ${APP_HOST}:${APP_PORT}"
