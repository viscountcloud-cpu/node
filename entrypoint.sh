#!/bin/bash
cd /home/container || exit 1

# 🎨 Warna tema - elegan, lembut, profesional
TITLE='\033[1;38;5;111m'   # biru indigo lembut
ACCENT='\033[1;38;5;81m'   # cyan lembut
TEXT='\033[1;37m'           # putih terang
SUBTLE='\033[0;37m'         # abu terang
RESET='\033[0m'
BOLD='\033[1m'

# 🧩 Informasi dasar sistem
HOSTNAME=$(hostname)
DATE=$(date "+%Y-%m-%d")
NODE_IP=$(hostname -I | awk '{print $1}')
MEMORY=$(free -m | awk '/Mem:/ {printf "%.0fMi / %.0fMi", $3, $2}')
DISK=$(df -h /home/container | awk 'NR==2 {print $3 " / " $2}')
UPTIME=$(uptime -p | sed 's/up //')
CHROME_PATH=$PUPPETEER_EXECUTABLE_PATH

# 🧩 Versi software
NODE_VER=$(node -v)
NPM_VER=$(npm -v)
PM2_VER=$(pm2 -v)
GIT_VER=$(git --version | awk '{print $3}')
PY_VER=$(python3 --version 2>&1 | awk '{print $2}')
FFMPEG_VER=$(ffmpeg -version 2>&1 | head -n 1 | awk '{print $3}')

# Ganti variable startup
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')

clear
echo -e ""
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e "${TITLE}${BOLD}              SERVER INFORMATION${RESET}"
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e ""

printf "${SUBTLE}%-14s${RESET}${TEXT}: %s\n" "Hostname"   "$HOSTNAME"
printf "${SUBTLE}%-14s${RESET}${TEXT}: %s\n" "Node IP"    "$NODE_IP"
printf "${SUBTLE}%-14s${RESET}${TEXT}: %s\n" "Memory"     "$MEMORY"
printf "${SUBTLE}%-14s${RESET}${TEXT}: %s\n" "Disk"       "$DISK"
printf "${SUBTLE}%-14s${RESET}${TEXT}: %s\n" "Date"       "$DATE"
printf "${SUBTLE}%-14s${RESET}${TEXT}: %s\n" "Uptime"     "$UPTIME"

echo -e ""
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e "${TITLE}${BOLD}              INSTALLED VERSIONS${RESET}"
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e ""

printf "${SUBTLE}%-14s${RESET}${TEXT}: %s\n" "Node.js"    "$NODE_VER"
printf "${SUBTLE}%-14s${RESET}${TEXT}: %s\n" "NPM"        "$NPM_VER"
printf "${SUBTLE}%-14s${RESET}${TEXT}: %s\n" "PM2"        "$PM2_VER"
printf "${SUBTLE}%-14s${RESET}${TEXT}: %s\n" "Git"        "$GIT_VER"
printf "${SUBTLE}%-14s${RESET}${TEXT}: %s\n" "Python"     "$PY_VER"
printf "${SUBTLE}%-14s${RESET}${TEXT}: %s\n" "FFmpeg"     "$FFMPEG_VER"
printf "${SUBTLE}%-14s${RESET}${TEXT}: %s\n" "Chrome"     "$CHROME_PATH"

echo -e ""
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e "${TITLE}${BOLD}              STARTING SERVER${RESET}"
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e ""

eval ${MODIFIED_STARTUP}
