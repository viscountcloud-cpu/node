#!/bin/bash
cd /home/container || exit 1


MODIFIED_STARTUP=$(echo -e ${CMD_RUN} | sed -e 's/{{/${/g' -e 's/}}/}/g')

# ========================================
#        SERVER INFORMATION
# ========================================
clear
echo -e ""
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e "                ${TEXT}${BOLD}Server Information${RESET}"
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e ""
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Hostname" "$HOST_NAME"
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

printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Localhost" "http://${NODE_IP}:${PORT}"
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


eval ${MODIFIED_STARTUP}
