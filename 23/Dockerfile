FROM ubuntu:22.04

LABEL author="FanDev" maintainer="FanDev404@pterodactyl.io"

RUN apt-get update -y \
    && apt-get install -y curl gnupg wget ca-certificates --no-install-recommends \
    && curl -fsSL https://deb.nodesource.com/setup_23.x | bash - \
    && apt-get install -y nodejs \
    && apt-get install -y --no-install-recommends \
        chromium-browser ffmpeg git imagemagick python3 sqlite3 dnsutils zip tar iproute2 iputils-ping build-essential \
   
    && rm -rf /var/lib/apt/lists/*

# Download dan install Google Chrome
RUN wget -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get install -y /tmp/google-chrome.deb || apt-get -fy install \
    && rm /tmp/google-chrome.deb 
    
RUN groupadd -g 997 container && useradd -m -d /home/container -g container container

WORKDIR /home/container
RUN npm init -y && npm install puppeteer \
    && npm install -g npm@latest typescript ts-node @types/node \
    && npm install -g pm2@latest

ENV PUPPETEER_EXECUTABLE_PATH="/usr/bin/chromium-browser"
ENV PUPPETEER_DISABLE_SANDBOX=true

USER container
COPY ../entrypoint.sh /entrypoint.sh


CMD ["/bin/bash", "/entrypoint.sh"]
