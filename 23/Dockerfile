FROM ubuntu:22.04

LABEL author="FanDev" maintainer="FanDev404@pterodactyl.io"

RUN apt-get update -y \
    && apt-get install -y curl gnupg wget ca-certificates --no-install-recommends \
    && wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && curl -fsSL https://deb.nodesource.com/setup_23.x | bash - \
    && apt-get install -y nodejs \
    && apt-get install -y --no-install-recommends \
        chromium-browser ffmpeg git imagemagick python3 sqlite3 dnsutils zip tar iproute2 iputils-ping build-essential \
    && npm install -g npm@latest typescript ts-node @types/node \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 997 container && useradd -m -d /home/container -g container container

WORKDIR /home/container
RUN npm init -y && npm install puppeteer

ENV PUPPETEER_EXECUTABLE_PATH="/usr/bin/chromium-browser"
ENV PUPPETEER_DISABLE_SANDBOX=true

USER container
COPY ../entrypoint.sh /entrypoint.sh


CMD ["/bin/bash", "/entrypoint.sh"]


FROM ubuntu:22.04

LABEL author="FanDev" maintainer="FanDev404@pterodactyl.io"

# Instal dependensi dasar dan Node.js
RUN apt-get update -y \
    && apt-get install -y curl gnupg wget ca-certificates --no-install-recommends \
    && curl -fsSL https://deb.nodesource.com/setup_23.x | bash - \
    && apt-get install -y nodejs

# Unduh dan instal Google Chrome .deb
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get install -y ./google-chrome-stable_current_amd64.deb \
    && rm google-chrome-stable_current_amd64.deb

# Instal paket tambahan yang dibutuhkan oleh Puppeteer dan Chrome
RUN apt-get install -y --no-install-recommends \
        chromium-browser ffmpeg git imagemagick python3 sqlite3 dnsutils zip tar iproute2 iputils-ping build-essential \
        fonts-liberation libasound2 libatk-bridge2.0-0 libatk1.0-0 libcups2 libdrm2 libxkbcommon0 libxcomposite1 \
        libxdamage1 libxrandr2 libgbm1 libxshmfence1 libpango-1.0-0 libnss3 libxss1 libgtk-3-0 xdg-utils \
    && npm install -g npm@latest typescript ts-node @types/node \
    && rm -rf /var/lib/apt/lists/*

# Buat user non-root (container)
RUN groupadd -g 997 container && useradd -m -d /home/container -g container container

WORKDIR /home/container

# Inisialisasi dan instal Puppeteer
RUN npm init -y && npm install puppeteer

# Set environment variable untuk Puppeteer
ENV PUPPETEER_EXECUTABLE_PATH="/usr/bin/google-chrome-stable"
ENV PUPPETEER_DISABLE_SANDBOX=true

USER container

COPY ../entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
