[ -z "$PS1" ] && return

if ! [ -n "${SUDO_USER}" -a -n "${SUDO_PS1}" ]; then
  PS1="root@${HOST_NAME}:\w\$ "
fi

export CLOUDFLARED_HOME="/home/container/.cloudflared"
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
DOMAIN=${DOMAIN:-example.com}
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




if [[ "${SETUP_NGINX}" == "ON" ]]; then
    mkdir -p /home/container/.nginx
    mkdir -p /home/container/webroot
    mkdir -p /home/container/.cloudflared/logs
    if [ ! -f /home/container/.nginx/default.conf ]; then
        cp /nginx/default.conf /home/container/.nginx/default.conf
        sed -i "s|listen [0-9]*;|listen ${PORT};|g" /home/container/.nginx/default.conf
    fi
    if [ ! -f /home/container/webroot/index.html ]; then
        cp /webroot/index.html /home/container/webroot/index.html
    fi
    if [[ "$WEBROOT" != "/home/container" ]]; then
        sed -i "s|root .*;|root ${WEBROOT};|g" /home/container/.nginx/default.conf
    fi
    TUNNEL_NAME="ServerWeb-${HOSTNAME}"
    TUNNEL_FILE="$CLOUDFLARED_HOME/${HOSTNAME}.json"
    CONFIG_FILE="$CLOUDFLARED_HOME/config.yml"
    CERT_FILE="$CLOUDFLARED_HOME/cert.pem"
    CLOUDFLARED_BIN="$(command -v cloudflared || echo /usr/local/bin/cloudflared)"
    if [ ! -f "$CERT_FILE" ]; then
        "$CLOUDFLARED_BIN" login
    else
        if [ ! -f "$TUNNEL_FILE" ]; then
            "$CLOUDFLARED_BIN" tunnel create "$TUNNEL_NAME" >/dev/null 2>&1 &
            FOUND_JSON=$(ls "$CLOUDFLARED_HOME"/*.json 2>/dev/null | head -n 1)
            if [ -n "$FOUND_JSON" ] && [ "$FOUND_JSON" != "$TUNNEL_FILE" ]; then
                mv "$FOUND_JSON" "$TUNNEL_FILE"
            fi
        fi
        if [[ "$DOMAIN" != example.com ]]; then
            CHECK_DOMAIN=$(grep server_name /home/container/.nginx/default.conf | awk '{print $2}' | sed 's/;//')
            if [[ "$CHECK_DOMAIN" != "$DOMAIN" ]]; then
                sed -i "s|server_name .*;|server_name ${DOMAIN};|g" /home/container/.nginx/default.conf
                "$CLOUDFLARED_BIN" tunnel route dns "$TUNNEL_NAME" "$DOMAIN" \
                    >> "${CLOUDFLARED_HOME}/logs/dns.out.log" \
                    2>> "${CLOUDFLARED_HOME}/logs/dns.err.log" &
                cat > "$CONFIG_FILE" <<EOF
tunnel: ${TUNNEL_NAME}
credentials-file: ${TUNNEL_FILE}

ingress:
  - hostname: ${DOMAIN}
    service: http://localhost:$SERVER_PORT
  - service: http_status:404
EOF
            fi
        else
            sed -i "s|server_name .*;|server_name localhost;|g" /home/container/.nginx/default.conf
        fi
        if [ -f /home/container/.nginx/default.conf ]; then
            nginx -c /home/container/.nginx/default.conf
        fi
        "$CLOUDFLARED_BIN" tunnel run \
            >> "${CLOUDFLARED_HOME}/logs/run.out.log" \
            2>> "${CLOUDFLARED_HOME}/logs/run.err.log" &

    fi
else 
    rm -rf /home/container/.nginx
    rm -rf /home/container/webroot
fi


if [ -d "/home/container/.nvm" ]; then
    export NVM_DIR="/home/container/.nvm"
else
    export NVM_DIR="/app/.nvm"
fi


[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

if [[ "${NODEJS_VERSION}" == "24" ]]; then
    nvm use 24
elif [[ "${NODEJS_VERSION}" == "23" ]]; then
    nvm use 23
elif [[ "${NODEJS_VERSION}" == "22" ]]; then
    nvm use 22
elif [[ "${NODEJS_VERSION}" == "21" ]]; then
    nvm use 21
elif [[ "${NODEJS_VERSION}" == "20" ]]; then
    nvm use 20
elif [[ "${NODEJS_VERSION}" == "19" ]]; then
    nvm use 19
elif [[ "${NODEJS_VERSION}" == "18" ]]; then
    nvm use 18
elif [[ "${NODEJS_VERSION}" == "17" ]]; then
    nvm use 17
elif [[ "${NODEJS_VERSION}" == "16" ]]; then
    nvm use 16
fi

# Informasi software
NODE_VERSION=$(node -v)
NPM_VERSION=$(npm -v)
NVM_VERSION=$(nvm -v)
GIT_VERSION=$(git --version 2>/dev/null | awk '{print $3}')
CHROME_PATH=${PUPPETEER_EXECUTABLE_PATH:-/usr/bin/google-chrome-stable}
# HOSTNAME=${HOST_NAME}

if [ ! -e "$HOME/.sudo_as_admin_successful" ] && [ ! -e "$HOME/.hushlogin" ] ; then
    case " $(groups) " in *\ admin\ *|*\ sudo\ *)
    if [ -x /usr/bin/sudo ]; then
	cat <<-EOF
	To run a command as administrator (user "root"), use "sudo <command>".
	See "man sudo_root" for details.
	
	EOF
    fi
    esac
fi

if [ -x /usr/lib/command-not-found -o -x /usr/share/command-not-found/command-not-found ]; then
	function command_not_found_handle {
	        # check because c-n-f could've been removed in the meantime
                if [ -x /usr/lib/command-not-found ]; then
		   /usr/lib/command-not-found -- "$1"
                   return $?
                elif [ -x /usr/share/command-not-found/command-not-found ]; then
		   /usr/share/command-not-found/command-not-found -- "$1"
                   return $?
		else
		   printf "%s: command not found\n" "$1" >&2
		   return 127
		fi
	}
fi


if [[ "$WEBROOT" != "/home/container" && "$SETUP_NGINX" == "ON" ]]; then
    cd "$WEBROOT"
fi

check_url() {
    local url="$1"
    if curl --silent --head --fail "$url" >/dev/null 2>&1; then
        echo "🟢"
    else
        echo "🔴"
    fi
}

# URL
LOCAL_URL="http://${NODE_IP}:${PORT}"
DOMAIN_URL="https://${DOMAIN}"

# Cek status
LOCAL_STATUS=$(check_url "$LOCAL_URL")
if [[ "$DOMAIN" != example.com ]]; then
    DOMAIN_STATUS=$(check_url "$DOMAIN_URL")
fi

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
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "nvm" "$NVM_VERSION"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Git" "$GIT_VERSION"
printf "${DIM}%-18s${RESET}${TEXT}: %s\n" "Chrome Path" "$CHROME_PATH"
echo -e ""
if [[ "${SETUP_NGINX}" == "ON" ]]; then
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e "                ${TEXT}${BOLD}Cloudfired Informatio${RESET}"
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e ""
printf "${DIM}%-18s${RESET}${TEXT}: %s %s\n" "Localhost" "$LOCAL_URL" "$LOCAL_STATUS"
if [[ "$DOMAIN" != example.com ]]; then
    printf "${DIM}%-18s${RESET}${TEXT}: %s %s\n" "Domain" "$DOMAIN_URL" "$DOMAIN_STATUS"
fi
echo -e ""
fi
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e "${TEXT}${BOLD}Launching container process...${RESET}"
echo -e "${ACCENT}${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e ""


if [[ "${AUTO_INSTALL}" == "ON" ]]; then
    if [[ "${CMD_RUN}" == "npm start" ]]; then
        npm i && npm start
    else
        npm i
    fi
elif [[ "${CMD_RUN}" == "npm start" ]]; then
    npm start
fi
