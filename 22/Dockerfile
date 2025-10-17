FROM ubuntu:22.04

LABEL author="FanDev" maintainer="FanDev404@pterodactyl.io"

# --- Instalasi dasar dan Node.js ---
RUN apt-get update -y \
    && apt-get install -y curl gnupg wget ca-certificates --no-install-recommends \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && apt-get install -y --no-install-recommends \
        chromium-browser ffmpeg git imagemagick python3 sqlite3 dnsutils zip tar iproute2 iputils-ping build-essential fonts-liberation xdg-utils \
    && npm install -g npm@latest typescript ts-node @types/node

# --- Install Google Chrome ---
RUN wget -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get install -y /tmp/google-chrome.deb || apt-get -fy install \
    && rm /tmp/google-chrome.deb

# --- Buat user container ---
RUN groupadd -g 997 container && useradd -m -d /home/container -g container container

# --- Konfigurasi npm global ---
RUN mkdir -p /home/container/.npm-global \
    && npm config set prefix '/home/container/.npm-global' \
    && echo 'export PATH=$PATH:/home/container/.npm-global/bin' >> /home/container/.bashrc

ENV PATH="/home/container/.npm-global/bin:${PATH}"
ENV HOME="/home/container"

# --- Siapkan direktori cache Chrome ---
RUN mkdir -p /home/container/.local/share/applications \
    && mkdir -p /home/container/.cache \
    && mkdir -p /home/container/.chrome-cache \
    && chown -R container:container /home/container

# --- Direktori kerja ---
WORKDIR /home/container

# --- Install Puppeteer (bisa dipakai juga untuk Playwright) ---
RUN npm init -y && npm install puppeteer

# --- Variabel untuk Chrome ---
ENV PUPPETEER_EXECUTABLE_PATH="/usr/bin/google-chrome-stable"
ENV PUPPETEER_DISABLE_SANDBOX=true
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# --- Chrome args (disamakan dengan konfigurasi Playwright) ---
ENV CHROME_ARGS="\
--headless=new \
--no-sandbox \
--disable-setuid-sandbox \
--disable-dev-shm-usage \
--disable-gpu \
--disable-cache \
--disable-application-cache \
--disable-offline-load-stale-cache \
--disable-accelerated-2d-canvas \
--disk-cache-size=0 \
--no-zygote \
--no-first-run \
--ignore-certificate-errors \
--aggressive-tab-discard \
--disable-crash-reporter \
--disable-extensions \
--disable-background-networking \
--disable-background-timer-throttling \
--disable-backgrounding-occluded-windows \
--disable-client-side-phishing-detection \
--disable-default-apps \
--mute-audio \
--user-data-dir=/home/container/.chrome-cache"

# Jalankan sebagai user non-root
USER container

# Copy entrypoint dari parent folder ke root container
COPY ../entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
