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
# Ganti variable startup (misal: STARTUP="node index.js")
MODIFIED_STARTUP=$(echo -e ${CMD_RUN} | sed -e 's/{{/${/g' -e 's/}}/}/g')


if [[ "${SETUP_NGINX}" == "ON" ]]; then
    mkdir -p /home/container/.nginx
    if [[ ! -f /home/container/.nginx/nginx.conf ]]; then
    cat <<'EOF' > /home/container/.nginx/nginx.conf
worker_processes auto;
pid /tmp/nginx.pid;
daemon off;

events { worker_connections 768; }

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;

    server {
        listen 80;
        server_name localhost;

        root /home/container;
        index index.html;

        location / {
            proxy_pass http://${INTERNAL_IP}:3000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
        }
    }
}
EOF
    fi
fi

# ========================================
#        SERVER INFORMATION
# ========================================
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
    exec bash --init-file /bash_custom
else
    eval ${MODIFIED_STARTUP}
fi
