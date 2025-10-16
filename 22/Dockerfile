FROM ubuntu:22.04

LABEL author="FanDev" maintainer="FanDev404@pterodactyl.io"

# --- Instalasi dasar dan Node.js ---
RUN apt-get update -y \
    && apt-get install -y curl gnupg wget ca-certificates --no-install-recommends \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && apt-get install -y --no-install-recommends \
        chromium-browser ffmpeg git imagemagick python3 sqlite3 dnsutils zip tar iproute2 iputils-ping build-essential

# --- Pastikan NPM global path dapat digunakan oleh user biasa ---
RUN mkdir -p /usr/local/lib/node_modules \
    && npm install -g npm@latest typescript ts-node @types/node \
    && ln -sf /usr/bin/node /usr/local/bin/node \
    && ln -sf /usr/bin/npm /usr/local/bin/npm

# --- Instal Google Chrome (Puppeteer akan pakai ini) ---
RUN wget -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get install -y /tmp/google-chrome.deb || apt-get -fy install \
    && rm /tmp/google-chrome.deb

# --- Buat user container ---
RUN groupadd -g 997 container && useradd -m -d /home/container -g container container

# --- Pastikan user container bisa gunakan npm di semua direktori ---
RUN mkdir -p /home/container/.npm-global \
    && chown -R container:container /home/container \
    && npm config set prefix '/home/container/.npm-global' \
    && echo 'export PATH=$PATH:/home/container/.npm-global/bin' >> /etc/profile \
    && echo 'export PATH=$PATH:/home/container/.npm-global/bin' >> /home/container/.bashrc

# --- Set PATH agar npm global tetap tersedia untuk semua user termasuk non-login shell ---
ENV PATH="/home/container/.npm-global/bin:${PATH}"

# --- Direktori kerja utama ---
WORKDIR /home/container

# --- Instal puppeteer (lokal) ---
RUN npm init -y && npm install puppeteer

# --- Set variabel lingkungan untuk Puppeteer ---
ENV PUPPETEER_EXECUTABLE_PATH="/usr/bin/google-chrome-stable"
ENV PUPPETEER_DISABLE_SANDBOX=true

# --- Ganti ke user container ---
USER container

# --- Copy entrypoint ---
COPY ../../entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
