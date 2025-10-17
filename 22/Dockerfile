FROM ubuntu:22.04

LABEL author="FanDev" maintainer="FanDev404@pterodactyl.io"

# --- Instalasi dasar & Node.js ---
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

# --- Konfigurasi npm agar bisa digunakan di semua direktori ---
RUN mkdir -p /home/container/.npm-global \
    && chown -R container:container /home/container \
    && npm config set prefix '/home/container/.npm-global' \
    && echo 'export PATH=$PATH:/home/container/.npm-global/bin' >> /home/container/.bashrc

ENV PATH="/home/container/.npm-global/bin:${PATH}"
ENV HOME="/home/container"

# --- Siapkan direktori writable untuk Chrome ---
RUN mkdir -p /home/container/.local/share/applications \
    && mkdir -p /home/container/.cache \
    && mkdir -p /home/container/.chrome-cache \
    && chown -R container:container /home/container

# --- Direktori kerja utama ---
WORKDIR /home/container

# --- Install Puppeteer ---
RUN npm init -y && npm install puppeteer

# --- Puppeteer environment ---
ENV PUPPETEER_EXECUTABLE_PATH="/usr/bin/google-chrome-stable"
ENV PUPPETEER_DISABLE_SANDBOX=true
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# --- Nonaktifkan sandbox & aktifkan cache Chrome lokal ---
# Perintah "--no-sandbox" dan "--disable-setuid-sandbox" penting untuk mencegah error "setuid sandbox"
ENV CHROME_ARGS="--no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage --disable-gpu --disable-crash-reporter --no-zygote --single-process --disable-extensions --user-data-dir=/home/container/.chrome-cache"

USER container

# --- Copy entrypoint ---
COPY ../entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
