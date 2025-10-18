#!/bin/bash
cd /home/container || exit 1

# === Perbaiki user agar tidak muncul "I have no name!" ===
if ! whoami &>/dev/null; then
    if [ -w /etc/passwd ]; then
        echo "container:x:$(id -u):$(id -g):Container User:/home/container:/bin/bash" >> /etc/passwd
    fi
fi

# === Pastikan direktori dan kepemilikan benar ===
chown -R container:container /home/container 2>/dev/null || true

# === Jalankan sebagai user container ===
if [ "$(id -u)" -eq 0 ]; then
    exec gosu container /bin/bash "$0" "$@"
fi

# === Ubah prompt shell agar tampil seperti "server@hostname:~" ===
export PS1="\[\033[1;36m\]server@\[\033[1;34m\]\h\[\033[0m\]:\[\033[1;37m\]\w\[\033[0m\]\$ "

# 🎨 Warna tema (elegan & profesional)
ACCENT='\033[1;34m'     # biru lembut
DIM='\033[0;37m'        # abu muda
TEXT='\033[1;37m'       # putih terang
BOLD='\033[1m'
RESET='\033[0m'

# Informasi sistem
HOSTNAME=$(hostname)
DATE=$(date "+%Y-%m-%d")
UPTIME=$(uptime -p | sed 's/up //')
MEMORY=$(free -h | awk '/Mem:/ {print $3 " / " $2}')
DISK=$(df -h /home | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')
NODE_IP=$(dig +short myip.opendns.com @resolver1.opendns.com 2>/dev/null || echo "Unavailable")

# Informasi software
NODE_VERSION=$(node -v)
NPM_VERSION=$(npm -v)
GIT_VERSION=$(git --version 2>/dev/null | awk '{print $3}')
CHROME_PATH=${PUPPETEER_EXECUTABLE_PATH:-/usr/bin/google-chrome-stable}

# Ganti variable startup (misal: STARTUP="node index.js")
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')

# ========================================
#        SERVER INFORMATION
# ========================================
echo -e ""
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e "                ${TEXT}${BOLD}Server Information${RESET}"
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e ""
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Hostname" "$HOSTNAME"
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

# 🚀 Jalankan server utama
eval ${MODIFIED_STARTUP}
