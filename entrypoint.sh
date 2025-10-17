#!/bin/bash
cd /home/container || exit 1

# 🎨 Warna tema (elegan & profesional)
ACCENT='\033[1;34m'     # biru lembut
DIM='\033[0;37m'        # abu muda
TEXT='\033[1;37m'       # putih terang
BOLD='\033[1m'
RESET='\033[0m'

# Konfigurasi umum
HOSTNAME='luckycat'
DATE=$(date "+%Y-%m-%d %H:%M:%S")
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Prompt shell
PS1='\[\e[1;34m\]\u@\h \[\e[0;37m\]\w \$ \[\e[0m\]'
export PS1

# Ganti variable startup (misal: STARTUP="node index.js")
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')

# Pastikan folder cache Chrome ada
mkdir -p /home/container/.chrome-cache
chmod -R 700 /home/container/.chrome-cache

# 🧩 Auto sandbox mode detection
if [ "$(id -u)" -eq 0 ]; then
    SANDBOX_MODE="ENABLED"
    export CHROME_ARGS="--headless=new \
        --disable-gpu \
        --disable-dev-shm-usage \
        --disable-background-networking \
        --disable-translate \
        --no-first-run \
        --mute-audio \
        --user-data-dir=/home/container/.chrome-cache"
else
    SANDBOX_MODE="DISABLED"
    export CHROME_ARGS="--headless=new \
        --no-sandbox \
        --disable-setuid-sandbox \
        --no-zygote \
        --single-process \
        --disable-dev-shm-usage \
        --disable-gpu \
        --disable-cache \
        --disk-cache-size=0 \
        --ignore-certificate-errors \
        --disable-background-networking \
        --disable-crash-reporter \
        --mute-audio \
        --user-data-dir=/home/container/.chrome-cache"
    export CHROME_DEVEL_SANDBOX=0
fi

# 💾 Pastikan file penting Chrome tidak error
mkdir -p /home/container/.local/share/applications
touch /home/container/.local/share/applications/mimeapps.list

# Tampilkan informasi environment
clear
echo -e ""
echo -e "${ACCENT}${BOLD}┌──────────────────────────────────────────────────┐${RESET}"
echo -e "${ACCENT}${BOLD}│${RESET}             ${TEXT}Server Environment Info${RESET}              ${ACCENT}${BOLD}│${RESET}"
echo -e "${ACCENT}${BOLD}└──────────────────────────────────────────────────┘${RESET}"
echo -e ""
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Server Name"       "Docker Images"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Hostname"          "$HOSTNAME"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Internal IP"       "$INTERNAL_IP"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Date"              "$DATE"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Creator"           "decode.id"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "APT Version"       "$(apt -v | head -n 1)"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Node.js Version"   "$(node -v)"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "NPM Version"       "$(npm -v)"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Chrome path"    "$PUPPETEER_EXECUTABLE_PATH"
echo -e ""
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e "${TEXT}${BOLD}Launching container process...${RESET}"
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e ""

# Jalankan script Node
eval ${MODIFIED_STARTUP} &
MAIN_PID=$!

# 🧠 Setelah startup jalan, cek apakah Puppeteer/Playwright bisa pakai Chrome
sleep 3

if pgrep -f "node.*puppeteer" >/dev/null; then
    echo -e "${TEXT}[OK] Puppeteer process detected.${RESET}"
else
    echo -e "${DIM}[WARN] Puppeteer not detected. Trying fallback to Playwright...${RESET}"
    if [ -f "package.json" ] && grep -q "playwright" package.json; then
        echo -e "${ACCENT}[INFO] Running Playwright fallback.${RESET}"
        npx playwright install-deps
        npx playwright install chromium
        node -e "const { chromium } = require('playwright'); chromium.launch({ headless: true, args: process.env.CHROME_ARGS.split(' ') }).then(async b=>{const p=await b.newPage();await p.goto('https://example.com');console.log('Playwright fallback loaded');await b.close();});"
    else
        echo -e "${DIM}[WARN] Playwright not installed. Skipping fallback.${RESET}"
    fi
fi

wait ${MAIN_PID}
