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

# Prompt
PS1='\[\e[1;34m\]\u@\h \[\e[0;37m\]\w \$ \[\e[0m\]'
export PS1

# Ganti variable startup
MODIFIED_STARTUP=$(echo -e bash -c ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')

clear
echo -e ""
echo -e "${ACCENT}${BOLD}┌──────────────────────────────────────────────────┐${RESET}"
echo -e "${ACCENT}${BOLD}│${RESET}              ${TEXT}Server Environment Info${RESET}               ${ACCENT}${BOLD}│${RESET}"
echo -e "${ACCENT}${BOLD}└──────────────────────────────────────────────────┘${RESET}"
echo -e ""

# Info tampil elegan seperti tabel
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Server Name"       "Docker Images"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Hostname"          "$HOSTNAME"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Internal IP"       "$INTERNAL_IP"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Date"              "$DATE"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Creator"           "decode.id"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "APT Version"       "$(apt -v | head -n 1)"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Node.js Version"   "$(node -v)"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "NPM Version"       "$(npm -v)"
echo -e ""
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e "${TEXT}${BOLD}Launching container process...${RESET}"
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e ""

# Jalankan server
eval ${MODIFIED_STARTUP}
