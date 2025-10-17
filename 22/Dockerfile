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

# --- Siapkan folder Chrome & cache ---
RUN mkdir -p /home/container/.local/share/applications \
    && mkdir -p /home/container/.cache \
    && mkdir -p /home/container/.chrome-cache \
    && chown -R container:container /home/container

WORKDIR /home/container

# --- Install Puppeteer (Playwright juga bisa ditambah nanti) ---
RUN npm init -y && npm install puppeteer

# --- Puppeteer defaults ---
ENV PUPPETEER_EXECUTABLE_PATH="/usr/bin/google-chrome-stable"
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Copy entrypoint
COPY ../entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER container
CMD ["/bin/bash", "/entrypoint.sh"]
