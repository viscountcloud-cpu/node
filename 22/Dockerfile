FROM ubuntu:22.04

LABEL author="FanDev" maintainer="FanDev404@pterodactyl.io"

# ========================================
# 🧩 Dasar sistem
# ========================================
RUN apt-get update -y \
    && apt-get install -y curl wget gnupg ca-certificates build-essential \
        git unzip zip python3 python3-pip jq \
        libx11-xcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxi6 \
        libxrandr2 libxrender1 libxss1 libxtst6 libcups2 libnss3 libatk1.0-0 \
        libatk-bridge2.0-0 libpangocairo-1.0-0 libgtk-3-0 libxkbfile1 libgbm1 \
        libasound2 \
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
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
ENV PUPPETEER_DISABLE_SANDBOX=true
ENV CHROME_DEVEL_SANDBOX=0
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null
ENV NODE_ENV=production
ENV HOME=/home/container
ENV PM2_LIMIT=3

# ========================================
# 🧩 Copy entrypoint & bash_custom
# ========================================
COPY --chown=container:container entrypoint.sh /entrypoint.sh
COPY --chown=container:container bash_custom /bash_custom
# COPY --chown=container:container pm2_limit.sh /usr/local/bin/pm2

RUN chmod +x /entrypoint.sh /bash_custom

# ========================================
# 🧩 User dan direktori kerja
# ========================================
USER container
WORKDIR /home/container

# ========================================
# 🚀 Jalankan container
# ========================================
CMD ["/bin/bash", "/entrypoint.sh"]
