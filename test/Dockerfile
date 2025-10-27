FROM ubuntu:22.04

LABEL author="FanDev" maintainer="FanDev404@pterodactyl.io"

# ========================================
# 🧩 Base system
# ========================================
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl wget gnupg ca-certificates build-essential ffmpeg git unzip zip python3 python3-pip jq dnsutils nginx supervisor \
        libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev libpixman-1-dev libpangocairo-1.0-0 \
        libx11-xcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxi6 libxrandr2 libxrender1 libxss1 \
        libxtst6 libcups2 libnss3 libatk1.0-0 libatk-bridge2.0-0 libgtk-3-0 libxkbfile1 libgbm1 libasound2 \
        fonts-liberation libappindicator3-1 xdg-utils sudo \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ========================================
# 🧩 Node.js & PM2
# ========================================
RUN curl -fsSL https://deb.nodesource.com/setup_23.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest pm2 \
    && npm config set fund false \
    && npm config set audit false \
    && npm config set progress false \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ========================================
# 🧩 Chrome for Puppeteer
# ========================================
RUN apt-get update -y \
    && apt-get install -y wget gnupg ca-certificates --no-install-recommends \
    && wget -q -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get install -y -f /tmp/google-chrome.deb || apt-get -fy install \
    && rm -f /tmp/google-chrome.deb \
    && rm -rf /var/lib/apt/lists/*

# ========================================
# 🧩 User setup
# ========================================
RUN groupadd -g 997 container && \
    useradd -m -u 997 -g container -s /bin/bash container && \
    mkdir -p /home/container && chown -R container:container /home/container

# ========================================
# 🧩 Environment
# ========================================
ENV CHROME_BIN=/usr/bin/google-chrome-stable
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable
ENV PUPPETEER_DISABLE_SANDBOX=true
ENV NODE_ENV=production
ENV HOME=/home/container
ENV PM2_LIMIT=1

# ========================================
# 🧩 Copy configuration
# ========================================
COPY --chown=container:container entrypoint.sh /entrypoint.sh
COPY --chown=container:container bash_custom /bash_custom
COPY --chown=container:container nginx/default.conf /etc/nginx/sites-enabled/default

RUN chmod +x /entrypoint.sh /bash_custom

# ========================================
# 🧩 Supervisor (untuk Nginx + App)
# ========================================
RUN mkdir -p /etc/supervisor/conf.d
COPY <<EOF /etc/supervisor/conf.d/supervisord.conf
[supervisord]
logfile=/home/container/supervisord.log
pidfile=/home/container/supervisord.pid
nodaemon=false

[program:nginx]
command=/usr/sbin/nginx -c /home/container/.nginx/nginx.conf -g 'daemon off;'
autostart=true
autorestart=true
stdout_logfile=/home/container/.nginx/nginx-out.log
stderr_logfile=/home/container/.nginx/nginx-err.log

[program:app]
directory=/home/container
command=/bin/bash /entrypoint.sh
autostart=true
autorestart=true
user=container
stdout_logfile=/home/container/app/app.log
stderr_logfile=/home/container/app/app-error.log
EOF

# ========================================
# 🚀 Run supervisor
# ========================================
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
