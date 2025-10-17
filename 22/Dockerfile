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
       --no-install-recommends \FROM ubuntu:22.04

LABEL author="FanDev" maintainer="FanDev404@pterodactyl.io"

# ========================================
# 🧩 Dasar
# ========================================
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
    && apt-get install -y curl wget gnupg ca-certificates build-essential --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# ========================================
# 🧩 Node.js, npm, dan PM2 (limitasi proses)
# ========================================
RUN curl -fsSL https://deb.nodesource.com/setup_23.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest pm2 \
    && npm config set fund false && npm config set audit false && npm config set progress false

# ========================================
# 🧩 Install Google Chrome (dengan perbaikan dep)
# ========================================
RUN apt-get update -y \
    && apt-get install -y wget gnupg ca-certificates --no-install-recommends \
    && wget -q -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get install -y -f /tmp/google-chrome.deb || apt-get -fy install \
    && rm -f /tmp/google-chrome.deb

# ========================================
# 🧩 Setup user & direktori container
# ========================================
RUN groupadd -g 997 container \
    && useradd -m -d /home/container -g container container \
    && mkdir -p /home/container/.chrome-cache \
    && chown -R container:container /home/container \
    && chmod -R 700 /home/container/.chrome-cache

# ========================================
# 🧩 Atur permission Chrome untuk user container
# ========================================
# Izinkan non-root menjalankan chrome binary, tapi tidak menulis ke /usr/bin
RUN chmod 755 /usr/bin/google-chrome-stable \
    && chown root:container /usr/bin/google-chrome-stable

# ========================================
# 🧩 Lingkungan Puppeteer / Chrome
# ========================================
ENV CHROME_BIN=/usr/bin/google-chrome-stable
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_DISABLE_SANDBOX=true
ENV CHROME_DEVEL_SANDBOX=0
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null
ENV NODE_ENV=production
ENV HOME=/home/container
ENV PATH=$PATH:/home/container/node_modules/.bin

# ========================================
# 🧩 Batasi PM2 agar hanya bisa jalankan 3 proses
# ========================================
RUN echo '#!/bin/bash\n' \
         'COUNT=$(pm2 list | grep -c "online")\n' \
         'if [ "$COUNT" -ge 3 ]; then\n' \
         '  echo "❌ PM2 process limit reached (3 max)."\n' \
         '  exit 1\n' \
         'else\n' \
         '  pm2 "$@"\n' \
         'fi' > /usr/local/bin/pm2safe \
    && chmod +x /usr/local/bin/pm2safe

# ========================================
# 🧩 Copy entrypoint
# ========================================
COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

USER container
WORKDIR /home/container

# ========================================
# 🚀 CMD
# ========================================
CMD ["/bin/bash", "/entrypoint.sh"]

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
