FROM ubuntu:22.04

LABEL author="FanDev" maintainer="FanDev404@pterodactyl.io"

# ========================================
# 🧩 Dasar sistem
# ========================================
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
    && apt-get install -y curl wget gnupg ca-certificates build-essential --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# ========================================
# 🧩 Node.js, npm, dan PM2
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
# 🧩 Buat user container
# ========================================
RUN groupadd -g 997 container && useradd -m -d /home/container -g container container

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
ENV PM2_LIMIT=3

# ========================================
# 🧩 PM2 wrapper – limitasi jumlah proses tanpa mematikan server
# ========================================
RUN echo '#!/bin/bash' > /usr/local/bin/pm2safe && \
    echo 'LIMIT=${PM2_LIMIT:-3}' >> /usr/local/bin/pm2safe && \
    echo 'CURRENT=$(pm2 jlist | jq length 2>/dev/null || echo 0)' >> /usr/local/bin/pm2safe && \
    echo 'if [ "$1" = "start" ]; then' >> /usr/local/bin/pm2safe && \
    echo '  if [ "$CURRENT" -ge "$LIMIT" ]; then' >> /usr/local/bin/pm2safe && \
    echo '    echo "⚠️ PM2 limit of $LIMIT processes reached. Skipping new start." >&2' >> /usr/local/bin/pm2safe && \
    echo '    exit 0' >> /usr/local/bin/pm2safe && \
    echo '  fi' >> /usr/local/bin/pm2safe && \
    echo 'fi' >> /usr/local/bin/pm2safe && \
    echo 'pm2 "$@"' >> /usr/local/bin/pm2safe && \
    chmod +x /usr/local/bin/pm2safe

# ========================================
# 🧩 Tambah utilitas jq (untuk baca JSON dari pm2 jlist)
# ========================================
RUN apt-get update -y && apt-get install -y jq --no-install-recommends && rm -rf /var/lib/apt/lists/*

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
