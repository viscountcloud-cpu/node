#!/bin/bash
cd /home/container || exit 1

# === Warna tema (elegan & profesional) ===
ACCENT='\033[1;34m'     # biru lembut
DIM='\033[0;37m'        # abu muda
TEXT='\033[1;37m'       # putih terang
BOLD='\033[1m'
RESET='\033[0m'



# Informasi sistem
DATE=$(date "+%Y-%m-%d")
UPTIME=$(uptime -p | sed 's/up //')
MEMORY=$(free -h | awk '/Mem:/ {print $3 " / " $2}')
DISK=$(df -h /home | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
DOMAIN=${DOMAIN:-localhost}
PORT=${SERVER_PORT:-${PORT:-8080}}



# === IP publik (lebih andal, dengan fallback) ===
if command -v dig >/dev/null 2>&1; then
    NODE_IP=$(dig +short myip.opendns.com @resolver1.opendns.com 2>/dev/null)
fi
if [[ -z "$NODE_IP" ]]; then
    NODE_IP=$(curl -s https://api.ipify.org 2>/dev/null || echo "Unavailable")
fi
NODE_IP=${NODE_IP:-"Unavailable"}

# === Region (deteksi otomatis dari IP publik) ===
if [[ "$NODE_IP" != "Unavailable" && -n "$NODE_IP" ]]; then
    NODE_REGION=$(curl -s "http://ip-api.com/json/${NODE_IP}" | jq -r '.country')
    if [[ -z "$NODE_REGION" || "$NODE_REGION" == "null" ]]; then
        NODE_REGION="UNKNOWN"
    fi
else
    NODE_REGION="UNKNOWN"
fi

# Informasi software
NODE_VERSION=$(node -v)
NPM_VERSION=$(npm -v)
GIT_VERSION=$(git --version 2>/dev/null | awk '{print $3}')
CHROME_PATH=${PUPPETEER_EXECUTABLE_PATH:-/usr/bin/google-chrome-stable}
HOSTNAME=${HOST_NAME}
MODIFIED_STARTUP=$(echo -e ${CMD_RUN} | sed -e 's/{{/${/g' -e 's/}}/}/g')


# Jika file nginx.conf belum ada, copy dari default
if [ ! -f /home/container/.nginx/default.conf ]; then
    mkdir -p /home/container/.nginx/logs
    mkdir -p /home/container/.nginx/tmp
    mkdir -p /home/container/webroot
    cp /nginx/default.conf /home/container/.nginx/default.conf
    cp /webroot/index.html /home/container/webroot/index.html
fi

if [ -f /home/container/.nginx/default.conf ]; then
    sed -i "s|listen [0-9]*;|listen ${PORT};|g" /home/container/.nginx/default.conf
    sed -i "s|server_name .*;|server_name ${DOMAIN};|g" /home/container/.nginx/default.conf
fi


# CLOUD_DIR="${HOME}/.cloudflared"
# CLOUD_CERTS="$CLOUD_DIR/cert.pem"
# CLOUDFLARED_BIN=$(command -v cloudflared || true)
# CF_URL=""
# CF_CONFIG_FILE=""
# TUNNEL_NAME=""

# if [[ "${SETUP_NGINX}" == "ON" ]]; then
#     if [[ -n "$CLOUDFLARED_BIN" ]]; then
#         mkdir -p "$CLOUD_DIR"
#         CLOUD_AUTHED=false
#         for f in "${CLOUD_CERTS[@]}"; do
#             [[ -f "$f" ]] && CLOUD_AUTHED=true && break
#         done
#         if [[ "$CLOUD_AUTHED" != true ]]; then
#             CF_OUT=$(timeout 6s "$CLOUDFLARED_BIN" login 2>&1 || true)
#             CF_URL=$(printf '%s' "$CF_OUT" | grep -oE 'https?://[^ )]+' | head -n1 || true)
#             CF_URL=${CF_URL:-""}
#         else
#             if [[ "$DOMAIN" != "localhost" && -n "$DOMAIN" && -n "$CLOUDFLARED_BIN" ]]; then
#                 TUNNEL_NAME=${TUNNEL_NAME:-"mycontainer-tunnel"}
#                 TUNNEL_EXIST=$($CLOUDFLARED_BIN tunnel list 2>/dev/null | grep -w "$TUNNEL_NAME" || true)
#                 [[ -z "$TUNNEL_EXIST" ]] && $CLOUDFLARED_BIN tunnel create "$TUNNEL_NAME"
#                 CF_CONFIG_FILE="$CLOUD_DIR/$TUNNEL_NAME.yml"
#                 cat > "$CF_CONFIG_FILE" <<EOL
# tunnel: $TUNNEL_NAME
# credentials-file: $CLOUD_DIR/$TUNNEL_NAME.json

# ingress:
#   - hostname: $DOMAIN
#     service: http://localhost:$PORT
#   - service: http_status:404
# EOL

#                 $CLOUDFLARED_BIN tunnel --config "$CF_CONFIG_FILE" run & 
#                 nginx -c /home/container/.nginx/default.conf
#             else
#                CF_TEMP_OUT=$($CLOUDFLARED_BIN tunnel --url "http://localhost:$PORT" 2>&1 | grep -oE 'https://[^ ]+' | head -n1 || true)
#                nginx -c /home/container/.nginx/default.conf
#             fi
#         fi
#     fi
# fi 

# supervisord -c /app/supervisord.conf

# ========================================
#        SERVER INFORMATION
# ========================================
clear
echo -e ""
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e "                ${TEXT}${BOLD}Server Information${RESET}"
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e ""
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Hostname" "$HOSTNAME"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Region" "$NODE_REGION"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "IP Node" "$NODE_IP"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Date" "$DATE"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Memory" "$MEMORY"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Disk" "$DISK"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Uptime" "$UPTIME"
echo -e ""
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e "                ${TEXT}${BOLD}Software Information${RESET}"
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e ""
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Node.js" "$NODE_VERSION"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "npm" "$NPM_VERSION"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Git" "$GIT_VERSION"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Chrome Path" "$CHROME_PATH"
echo -e ""
if [[ "${SETUP_NGINX}" == "ON" ]]; then
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e "                ${TEXT}${BOLD}Cloudfired Informatio${RESET}"
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e ""

printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Localhost" "http://${INTERNAL_IP}:${PORT}"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Domain" "https://${DOMAIN}"
    # if [[ "$CF_URL" != "" ]]; then
    #     if [[ "$CF_CONFIG_FILE" != "" ]]; then
    #         printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Cloudfire Config" "${CF_CONFIG_FILE}"
    #     fi
    #     if [[ "$TUNNEL_NAME" != "" ]]; then
    #         printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Cloudfired Tunnel" "${TUNNEL_NAME}"
    #     fi
    #     printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Cloudfired Login" "${CF_URL}"
    # else
    #     printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Localhost" "http://${INTERNAL_IP}:${PORT}"
    #     printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Domain" "https://${DOMAIN}"
    # fi
echo -e ""
fi
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e "${TEXT}${BOLD}Launching container process...${RESET}"
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e ""


if [[ -z "${PM2_LIMIT_START}" ]]; then
    PM2_LIMIT=3
else
    if [[ "${PM2_LIMIT_START}" == "0" ]]; then
        PM2_LIMIT=0
    elif [[ "${PM2_LIMIT_START}" == "1" ]]; then
        PM2_LIMIT=1
    elif [[ "${PM2_LIMIT_START}" == "2" ]]; then
        PM2_LIMIT=2
    elif [[ "${PM2_LIMIT_START}" == "3" ]]; then
        PM2_LIMIT=3
    elif [[ "${PM2_LIMIT_START}" == "4" ]]; then
        PM2_LIMIT=4
    elif [[ "${PM2_LIMIT_START}" == "5" ]]; then
        PM2_LIMIT=5
    else
        PM2_LIMIT=3
    fi
fi

export PM2_LIMIT


if [[ -z "${MODIFIED_STARTUP}" || "${MODIFIED_STARTUP}" == "bash" ]]; then
    exec bash --init-file /app/bash_custom
else
    eval ${MODIFIED_STARTUP}
fi
