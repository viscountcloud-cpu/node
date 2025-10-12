FROM ubuntu:22.04

LABEL author="FanDev" maintainer="FanDev404@pterodactyl.io"

# --- Instalasi dasar dan Node.js ---
RUN apt-get update -y \
    && apt-get install -y curl gnupg wget ca-certificates --no-install-recommends \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && apt-get install -y --no-install-recommends \
        chromium-browser ffmpeg git imagemagick python3 sqlite3 dnsutils zip tar iproute2 iputils-ping build-essential \
    && rm -rf /var/lib/apt/lists/*

# --- Instalasi Google Chrome ---
RUN wget -q -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get install -y /tmp/google-chrome.deb || apt-get -fy install \
    && rm /tmp/google-chrome.deb \
    && rm -rf /var/lib/apt/lists/*

# --- Buat user non-root ---
RUN groupadd -g 997 container \
    && useradd -m -u 997 -d /home/container -g container -s /bin/bash container

# --- Buat direktori npm global untuk user container ---
RUN mkdir -p /home/container/.npm-global \
    && chown -R container:container /home/container

# --- Set environment npm global path ---
ENV NPM_CONFIG_PREFIX=/home/container/.npm-global
ENV PATH=/home/container/.npm-global/bin:$PATH
ENV HOME=/home/container
ENV PUPPETEER_EXECUTABLE_PATH="/usr/bin/chromium-browser"
ENV PUPPETEER_DISABLE_SANDBOX=true

# --- Ganti ke user container dan install package ---
USER container
WORKDIR /home/container

RUN npm install -g npm@latest typescript ts-node @types/node puppeteer

# --- Copy entrypoint ---
USER root
COPY ../../entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown container:container /entrypoint.sh

# --- Kembali ke user non-root ---
USER container

CMD ["/bin/bash", "/entrypoint.sh"]
