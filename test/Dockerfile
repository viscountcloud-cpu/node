FROM ubuntu:22.04

LABEL author="FanDev" maintainer="FanDev404@pterodactyl.io"

# ========================================
# 🧩 Dasar sistem
# ========================================
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl wget gnupg ca-certificates build-essential git unzip zip python3 python3-pip jq dnsutils ffmpeg nginx \
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
# 🧩 Install Google Chrome and Install Cloudflared (full deps)
# ========================================
RUN apt-get update -y \
    && apt-get install -y wget gnupg ca-certificates --no-install-recommends \
    && wget -q -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && wget -q -O /tmp/cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb \
    && apt-get install -y -f /tmp/cloudflared.deb || apt-get -fy install \
    && apt-get install -y -f /tmp/google-chrome.deb || apt-get -fy install \
    && rm -f /tmp/cloudflared.deb \
    && rm -f /tmp/google-chrome.deb \
    && rm -rf /var/lib/apt/lists/*

# ========================================
# 🧩 forward request and error logs to docker log collector
# ========================================
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    ln -sf /usr/bin/cloudflared /usr/bin/cr

# ========================================
# 🧩 Buat user container
# ========================================
RUN groupadd -g 998 container \
    && useradd -m -u 998 -g container -d /home/container -s /bin/bash container \
    && chown -R container:container /home/container

# ========================================
# 🧩 Lingkungan Puppeteer / Chrome
# ========================================
ENV CHROME_BIN=/usr/bin/google-chrome-stable
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable
ENV HOME=/home/container
ENV PM2_LIMIT=3
# ========================================
# 🧩 Direktori temporary Nginx bawaan
# ========================================
WORKDIR /app
WORKDIR /etc
WORKDIR /nginx
WORKDIR /webroot
    
# ========================================
# 🧩 Copy entrypoint & bash_custom
# ========================================
COPY --chown=container:container app/entrypoint.sh /app/entrypoint.sh
COPY --chown=container:container app/bash_custom /app/bash_custom
COPY --chown=container:container default/nginx.conf /nginx/default.conf
COPY --chown=container:container webroot/index.html /webroot/index.html
COPY --chown=container:container /app/debian_chroot /etc/debian_chroot



# COPY --chown=container:container pm2_limit.sh /usr/local/bin/pm2

RUN chmod +x /app/entrypoint.sh /app/bash_custom /nginx/default.conf /webroot/index.html

# ========================================
# 🧩 User dan direktori kerja
# ========================================
USER container
WORKDIR /home/container

# ========================================
# 🚀 Jalankan container
# ========================================
CMD ["/bin/bash", "/app/entrypoint.sh"]
