FROM ubuntu:22.04

LABEL author="FanDev" maintainer="FanDev404@pterodactyl.io"

# ========================================
# 🧩 Dasar sistem
# ========================================
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl wget gnupg ca-certificates build-essential ffmpeg git unzip zip python3 python3-pip jq dnsutils nginx supervisor \
        libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev libpixman-1-dev libpangocairo-1.0-0 \
        libx11-xcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxi6 libxrandr2 libxrender1 libxss1 \
        libxtst6 libcups2 libnss3 libatk1.0-0 libatk-bridge2.0-0 libgtk-3-0 libxkbfile1 libgbm1 libasound2 \
        fonts-liberation libappindicator3-1 xdg-utils \
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
RUN wget -q -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get install -y -f /tmp/google-chrome.deb || apt-get -fy install \
    && rm -f /tmp/google-chrome.deb \
    && rm -rf /var/lib/apt/lists/*

# ========================================
# 🧩 Buat user container (tetap ada)
# ========================================
RUN groupadd -g 997 container \
    && useradd -m -u 997 -g container -d /home/container -s /bin/bash container

# ========================================
# 🧩 Lingkungan Puppeteer / Chrome
# ========================================
ENV CHROME_BIN=/usr/bin/google-chrome-stable
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable
ENV PUPPETEER_DISABLE_SANDBOX=true
ENV NODE_ENV=production
ENV HOME=/home/container
ENV PM2_LIMIT=1

# ========================================
# 🧩 Siapkan direktori sistem penting
# ========================================
RUN mkdir -p /app /nginx /var/log/nginx /var/lib/nginx/body /var/lib/nginx/proxy \
    /var/lib/nginx/fastcgi /var/lib/nginx/uwsgi /var/lib/nginx/scgi /home/container/logs

# ========================================
# 🧩 Override konfigurasi log nginx agar tidak ke /var/log
# ========================================
RUN echo 'error_log /dev/stderr;\naccess_log /dev/stdout;' > /etc/nginx/conf.d/logs.conf

# ========================================
# 🧩 Copy file konfigurasi & entrypoint
# ========================================
COPY --chown=container:container entrypoint.sh /app/entrypoint.sh
COPY --chown=container:container bash_custom /app/bash_custom
COPY --chown=container:container supervisord.conf /app/supervisord.conf
COPY --chown=container:container nginx/default.conf /nginx/default.conf
COPY --chown=container:container logs/access.log /var/log/nginx/access.log
COPY --chown=container:container logs/error.log /var/log/nginx/error.log

RUN chmod +x /app/entrypoint.sh /app/bash_custom /app/supervisord.conf /nginx/default.conf

# ========================================
# 🧩 Pastikan izin penuh untuk semua user
# ========================================
RUN chmod -R 777 /nginx /var/log/nginx /home/container /var/lib/nginx /app

# ========================================
# 🧩 Jalankan sebagai root
# ========================================
USER root
WORKDIR /home/container

# ========================================
# 🚀 Jalankan container
# ========================================
CMD ["/bin/bash", "/app/entrypoint.sh"]
