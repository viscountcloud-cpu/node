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
# 🧩 Direktori temporary Nginx bawaan
# ========================================
WORKDIR /app
WORKDIR /etc
WORKDIR /nginx
WORKDIR /webroot

# ========================================
# 🧩 Node.js, npm, dan PM2, nvm
# ========================================
ENV NVM_DIR=/root/.nvm

RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest pm2 \
    && npm config set fund false \
    && npm config set audit false \
    && npm config set progress false

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && . "$NVM_DIR/nvm.sh" \
    && nvm install 16 \
    && nvm install 17 \
    && nvm install 18 \
    && nvm install 19 \
    && nvm install 20 \
    && nvm install 22 \
    && nvm install 23 \
    && nvm install 24 \
    && nvm alias default 24 \
    && nvm use 24

RUN mv /root/.nvm /app/.nvm
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
# 🧩 Buat user server
# ========================================
RUN groupadd -g 997 server \
    && useradd -m -u 998 -g server -d /home/container -s /bin/bash server \
    && chown -R server:server /home/container

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
COPY --chown=server:server app/entrypoint.sh /app/entrypoint.sh
COPY --chown=server:server default/nginx.conf /nginx/default.conf
COPY --chown=server:server webroot/index.html /webroot/index.html
COPY --chown=server:server app/bash.bashrc /etc/bash.bashrc
COPY --chown=server:server app/.nvm /app/.nvm/*

RUN chmod +x /app/entrypoint.sh /nginx/default.conf /webroot/index.html /app/.nvm

# ========================================
# 🧩 User dan direktori kerja
# ========================================
USER server
WORKDIR /home/container

# ========================================
# 🚀 Jalankan server
# ========================================
CMD ["/bin/bash", "/app/entrypoint.sh"]
