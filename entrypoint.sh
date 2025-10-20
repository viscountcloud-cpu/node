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
NGINX_CONF="/home/container/.nginx/nginx.conf"
# Ganti variable startup (misal: STARTUP="node index.js")
MODIFIED_STARTUP=$(echo -e ${CMD_RUN} | sed -e 's/{{/${/g' -e 's/}}/}/g')


if [[ "${SETUP_NGINX}" == "ON" ]]; then
    mkdir -p /home/container/.nginx
    if [[ ! -f "$NGINX_CONF" ]]; then
    cat <<EOF > "$NGINX_CONF"
worker_processes auto;
pid /tmp/nginx.pid;
daemon off;

events {
    worker_connections 768;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 10048;

    types {
        text/html html htm shtml;
        text/css css;
        text/xml xml;
        image/gif gif;
        image/jpeg jpeg jpg;
        application/javascript js;
        application/atom+xml atom;
        application/rss+xml rss;
        text/mathml mml;
        text/plain txt;
        text/vnd.sun.j2me.app-descriptor jad;
        text/vnd.wap.wml wml;
        text/x-component htc;
        image/png png;
        image/tiff tif tiff;
        image/vnd.wap.wbmp wbmp;
        image/x-icon ico;
        image/x-jng jng;
        image/x-ms-bmp bmp;
        image/svg+xml svg svgz;
        image/webp webp;
        application/font-woff woff;
        application/java-archive jar war ear;
        application/json json;
        application/mac-binhex40 hqx;
        application/msword doc;
        application/pdf pdf;
        application/postscript ps eps ai;
        application/rtf rtf;
        application/vnd.apple.mpegurl m3u8;
        application/vnd.ms-excel xls;
        application/vnd.ms-fontobject eot;
        application/vnd.ms-powerpoint ppt;
        application/vnd.wap.wmlc wmlc;
        application/vnd.google-earth.kml+xml kml;
        application/vnd.google-earth.kmz kmz;
        application/x-7z-compressed 7z;
        application/x-cocoa cco;
        application/x-java-archive-diff jardiff;
        application/x-java-jnlp-file jnlp;
        application/x-makeself run;
        application/x-perl pl pm;
        application/x-pilot prc pdb;
        application/x-rar-compressed rar;
        application/x-redhat-package-manager rpm;
        application/x-sea sea;
        application/x-shockwave-flash swf;
        application/x-stuffit sit;
        application/x-tcl tcl tk;
        application/x-x509-ca-cert der pem crt;
        application/x-xpinstall xpi;
        application/xhtml+xml xhtml;
        application/xspf+xml xspf;
        application/zip zip;
        application/octet-stream bin exe dll;
        application/octet-stream deb;
        application/octet-stream dmg;
        application/octet-stream iso img;
        application/octet-stream msi msp msm;
        application/vnd.openxmlformats-officedocument.wordprocessingml.document docx;
        application/vnd.openxmlformats-officedocument.spreadsheetml.sheet xlsx;
        application/vnd.openxmlformats-officedocument.presentationml.presentation pptx;
        audio/midi mid midi kar;
        audio/mpeg mp3;
        audio/ogg ogg;
        audio/x-m4a m4a;
        audio/x-realaudio ra;
        video/3gpp 3gpp 3gp;
        video/mp2t ts;
        video/mp4 mp4;
        video/mpeg mpeg mpg;
        video/quicktime mov;
        video/webm webm;
        video/x-flv flv;
        video/x-m4v m4v;
        video/x-mng mng;
        video/x-ms-asf asx asf;
        video/x-ms-wmv wmv;
        video/x-msvideo avi;
    }

    default_type application/octet-stream;

    proxy_temp_path /tmp;
    client_body_temp_path /tmp;
    fastcgi_temp_path /tmp;
    uwsgi_temp_path /tmp;
    scgi_temp_path /tmp;

    server {
        listen 80;
        server_name ${DOMAIN};

        access_log /dev/null;
        
        root /home/container;
        index index.html;

        client_max_body_size 100m;
        client_body_timeout 120s;
        sendfile off;
        
        location / {
            proxy_pass http://${INTERNAL_IP}:${PORT};
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $http_host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF
    fi
    nginx -c "$NGINX_CONF"
else 
    if [[ -d /home/container/.nginx ]]; then
       rm -rf /home/container/.nginx
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
    exec bash --init-file /bash_custom
else
    eval ${MODIFIED_STARTUP}
fi
