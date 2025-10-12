FROM ubuntu:22.04

LABEL author="FanDev" maintainer="FanDev404@pterodactyl.io"

# --- Instalasi dasar dan Node.js ---
RUN apt-get update -y \
    && apt-get install -y curl gnupg wget ca-certificates --no-install-recommends \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && apt-get install -y --no-install-recommends \
        chromium-browser ffmpeg git imagemagick python3 sqlite3 dnsutils zip tar iproute2 iputils-ping build-essential \
    && npm install -g npm@latest typescript ts-node @types/node \
    && rm -rf /var/lib/apt/lists/*

# --- Instalasi Google Chrome ---
RUN wget -q -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get install -y /tmp/google-chrome.deb || apt-get -fy install \
    && rm /tmp/google-chrome.deb \
    && rm -rf /var/lib/apt/lists/*

# --- Buat user non-root yang terisolasi ---
RUN groupadd -g 997 container \
    && useradd -m -u 997 -d /home/container -g container -s /bin/bash container

# --- Batasi akses user hanya ke /home/container ---
RUN chown -R container:container /home/container \
    && chmod 700 /home/container

WORKDIR /home/container

# --- Inisialisasi npm di folder user ---
USER container
RUN npm init -y && npm install puppeteer

# --- Set environment Puppeteer ---
ENV PUPPETEER_EXECUTABLE_PATH="/usr/bin/google-chrome-stable"
ENV PUPPETEER_DISABLE_SANDBOX=true
ENV HOME=/home/container

# --- Copy entrypoint ---
USER root
COPY ../../entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown container:container /entrypoint.sh

USER container

# --- Jalankan startup ---
CMD ["/bin/bash", "/entrypoint.sh"]
