FROM ubuntu:22.04

LABEL author="FanDev" maintainer="FanDev404@pterodactyl.io"

# ========================================
# 🧩 Dasar sistem
# ========================================
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl wget gnupg ca-certificates build-essential git unzip zip python3 python3-pip jq dnsutils ffmpeg nginx sudo \
        libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev libpixman-1-dev libpangocairo-1.0-0 \
        libx11-xcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxi6 libxrandr2 libxrender1 libxss1 \
        libxtst6 libcups2 libnss3 libatk1.0-0 libatk-bridge2.0-0 libgtk-3-0 libxkbfile1 libgbm1 libasound2 \
        fonts-liberation \
        libappindicator3-1 \
        xdg-utils \
    && rm -rf /var/lib/apt/lists/*
    
# ========================================
# 🧩 Buat user container dan pastikan /etc/passwd valid
# ========================================
RUN groupadd -g 997 container \
    && useradd -m -u 997 -g container -d /home/container -s /bin/bash container \
    && chown -R container:container /home/container

# ========================================
# 🧩 Copy entrypoint & bash_custom
# ========================================
COPY --chown=container:container app/entrypoint.sh /app/entrypoint.sh
COPY --chown=container:container app/bash_custom /app/bash_custom
COPY --chown=container:container default/nginx.conf /nginx/default.conf
COPY --chown=container:container default/nginx.conf /home/container/.nginx/nginx.conf
# COPY --chown=container:container pm2_limit.sh /usr/local/bin/pm2

RUN chmod +x /app/entrypoint.sh /app/bash_custom /nginx/default.conf
# ========================================
# 🧩 create directory
# ========================================
WORKDIR /home/container/.nginx/logs

# ========================================
# 🧩 Node.js, npm, dan PM2
# ========================================
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest pm2 \
    && npm config set fund false \
    && npm config set audit false \
    && npm config set progress false 
    # && nginx -c /home/container/.nginx/nginx.conf

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
# 🧩 Lingkungan Puppeteer / Chrome
# ========================================
ENV CHROME_BIN=/usr/bin/google-chrome-stable
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=false
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
ENV PUPPETEER_DISABLE_SANDBOX=true
ENV CHROME_DEVEL_SANDBOX=0
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null
ENV NODE_ENV=production
ENV HOME=/home/container
ENV PM2_LIMIT=3

# ========================================
# 🧩 User dan direktori kerja
# ========================================
USER container

# ========================================
# 🚀 Jalankan container
# ========================================
CMD ["/bin/bash", "/app/entrypoint.sh"]
