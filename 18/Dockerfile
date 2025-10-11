FROM ubuntu:22.04

LABEL author="FanDev" maintainer="FanDev404@pterodactyl.io"

RUN apt-get update -y \
    && apt-get install -y curl gnupg wget ca-certificates --no-install-recommends \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get install -y --no-install-recommends \
        chromium-browser ffmpeg git imagemagick python3 sqlite3 dnsutils zip tar iproute2 iputils-ping build-essential \
    && npm install -g npm@latest typescript ts-node @types/node \
    && useradd -m -d /home/container container \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/container
RUN npm init -y && npm install puppeteer

ENV PUPPETEER_EXECUTABLE_PATH="/usr/bin/chromium-browser"
ENV PUPPETEER_DISABLE_SANDBOX=true

USER container
COPY ../entrypoint.sh /entrypoint.sh


CMD ["/bin/bash", "/entrypoint.sh"]
