FROM ubuntu:22.04

LABEL author="FanDev" maintainer="FanDev404@pterodactyl.io"

# ========================================
# 🧩 Dasar sistem
# ========================================
RUN apt-get update -y \
    && apt-get install -y curl wget gnupg ca-certificates build-essential --no-install-recommends \
    && apt-get install -y chromium-browser ffmpeg git imagemagick python3 sqlite3 dnsutils zip tar iproute2 iputils-ping fonts-liberation xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# ========================================
# 🧩 Node.js, npm, dan PM2
# ========================================
RUN curl -fsSL https://deb.nodesource.com/setup_23.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest pm2 \
    && npm config set fund false \
    && npm config set audit false \
    && npm config set progress false

# ========================================
# 🧩 Install Google Chrome (full deps)
# ========================================
RUN apt-get update -y \
    && apt-get install -y wget gnupg ca-certificates --no-install-recommends \
    && wget -q -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get install -y -f /tmp/google-chrome.deb || apt-get -fy install \
    && rm -f /tmp/google-chrome.deb \
    && rm -rf /var/lib/apt/lists/*

# ========================================
# 🧩 Buat user container dan pastikan /etc/passwd valid
# ========================================
RUN groupadd -g 997 container \
    && useradd -m -u 997 -g container -d /home/container -s /bin/bash container \
    && echo "container:x:997:997:Container User:/home/container:/bin/bash" >> /etc/passwd \
    && chmod 644 /etc/passwd \
    && chown -R container:container /home/container

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
ENV PM2_LIMIT=3

# ========================================
# 🧩 PM2 wrapper (limit proses tanpa kill server)
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
# 🧩 Copy entrypoint
# ========================================
COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

# ========================================
# 🧩 User dan direktori kerja
# ========================================
WORKDIR /home/container

# ========================================
# 🚀 Jalankan container
# ========================================
CMD ["/entrypoint.sh"]
