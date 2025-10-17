FROM ubuntu:22.04

LABEL author="FanDev" maintainer="FanDev404@pterodactyl.io"

# ========================================
# 🧩 Instalasi dasar
# ========================================
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
    && apt-get install -y curl gnupg wget ca-certificates fonts-liberation libasound2 libatk-bridge2.0-0 \
       libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libglib2.0-0 \
       libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 \
       libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 lsb-release xdg-utils \
       --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# ========================================
# 🧩 Node.js & npm
# ========================================
RUN curl -fsSL https://deb.nodesource.com/setup_23.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest \
    && npm config set fund false \
    && npm config set audit false \
    && npm config set progress false

# ========================================
# 🧩 Install Google Chrome (stable)
# ========================================
RUN apt-get update -y \
    && apt-get install -y wget gnupg ca-certificates --no-install-recommends \
    && wget -q -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get install -y -f /tmp/google-chrome.deb || apt-get -fy install \
    && rm -f /tmp/google-chrome.deb

# ========================================
# 🧩 Buat user container (tanpa akses root)
# ========================================
RUN useradd -m -d /home/container container \
    && mkdir -p /home/container/.chrome-cache \
    && chown -R container:container /home/container \
    && chmod -R 700 /home/container/.chrome-cache

# ========================================
# 🧩 Set environment untuk Chrome & Puppeteer
# ========================================
ENV CHROME_BIN=/usr/bin/google-chrome-stable
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV CHROME_DEVEL_SANDBOX=0
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null
ENV NODE_ENV=production
ENV HOME=/home/container
ENV PATH=$PATH:/home/container/node_modules/.bin

# ========================================
# 🧩 Copy entrypoint
# ========================================
COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

USER container
WORKDIR /home/container

# ========================================
# 🚀 Default Command
# ========================================
CMD ["/bin/bash", "/entrypoint.sh"]
