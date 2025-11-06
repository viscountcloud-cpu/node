FROM ubuntu:22.04

LABEL author="FanDev" maintainer="FanDev404@pterodactyl.io"

# ========================================
# 🧩 Dasar sistem
# ========================================
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl wget gnupg ca-certificates build-essential git unzip zip python3 python3-pip jq dnsutils ffmpeg \
        libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev libpixman-1-dev libpangocairo-1.0-0 \
        libx11-xcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxi6 libxrandr2 libxrender1 libxss1 \
        libxtst6 libcups2 libnss3 libatk1.0-0 libatk-bridge2.0-0 libgtk-3-0 libxkbfile1 libgbm1 libasound2 \
        fonts-liberation \
        libappindicator3-1 \
        xdg-utils \
    && rm -rf /var/lib/apt/lists/*
    
# ========================================
# 🧩 Node.js, npm, dan PM2
# ========================================
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest pm2 \
    && npm config set fund false \
    && npm config set audit false \
    && npm config set progress false

# ========================================
# 🧩 Install Google Chrome (full deps)
# ========================================
RUN apt-get update -y \
    && apt-get install -y wget gnupg ca-certificates --no-install-recommends \
    && wget -q -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get install -y -f /tmp/google-chrome.deb || apt-get -fy install \
    && rm -f /tmp/google-chrome.deb \
    && rm -rf /var/lib/apt/lists/*

# ========================================
# 🧩 Buat user container dan pastikan /etc/passwd valid
# ========================================
RUN groupadd -g 997 container \
    && useradd -m -u 997 -g container -d /home/container -s /bin/bash container \
    && chown -R container:container /home/container

# ========================================
# 🧩 Lingkungan Puppeteer / Chrome
# ========================================
ENV CHROME_BIN=/usr/bin/google-chrome-stable
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable
ENV HOME=/home/container
ENV PM2_LIMIT=3

# ========================================
# 🧩 Copy entrypoint & bash_custom
# ========================================
# COPY --chown=container:container entrypoint.sh /entrypoint.sh
COPY --chown=container:container app/bash_custom /app/bash_custom
# COPY --chown=container:container pm2_limit.sh /usr/local/bin/pm2

RUN chmod +x /entrypoint.sh /bash_custom

# ========================================
# 🧩 User dan direktori kerja
# ========================================
USER container
WORKDIR /home/container

# ========================================
# 🚀 Jalankan container
# ========================================
CMD ["/bin/bash", "
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
PORT=${PORT:-3000}



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


mkdir -p /home/container/.nginx/logs
mkdir -p /home/container/.nginx/tmp

# Jika file nginx.conf belum ada, copy dari default
if [ ! -f /home/container/.nginx/nginx.conf ]; then
    cp /nginx/default.conf /home/container/.nginx/nginx.conf
fi

if [ -f /home/container/.nginx/nginx.conf ]; then
    sed -i "s|listen [0-9]*;|listen ${PORT};|g" /home/container/.nginx/nginx.conf
    # sed -i "s|server_name .*;|server_name ${DOMAIN};|g" /home/container/.nginx/nginx.conf
fi

# supervisord -c /app/supervisord.conf
# nginx -c /home/container/.nginx/nginx.conf

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
if [[ "${SETUP_NGINX}" == "ON" ]]; then
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e "                ${TEXT}${BOLD}Nginx Information${RESET}"
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e ""
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Localhost" "http://${INTERNAL_IP}:${PORT}"
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
"]
