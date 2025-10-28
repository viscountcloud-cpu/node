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
        fonts-liberation \
        libappindicator3-1 \
        xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# ========================================
# 🧩 Build Nginx manual (tanpa apt)
# ========================================
# ========================================
# 🧩 Build Nginx manual (tanpa apt)
# ========================================
# RUN apt update && apt install -y \
#     build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev curl && \
#     cd /tmp && \
#     curl -O http://nginx.org/download/nginx-1.29.2.tar.gz && \
#     tar zxvf nginx-1.29.2.tar.gz && cd nginx-1.29.2 && \
#     ./configure \
#         --prefix=/usr/share/nginx \
#         --conf-path=/etc/nginx/nginx.conf \
#         --pid-path=/home/container/.nginx/tmp/nginx.pid \
#         --lock-path=/home/container/.nginx/tmp/nginx.lock \
#         --modules-path=/usr/lib/nginx/modules \
#         \
#         # 📂 Simpan semua file sementara di direktori milik user
#         --http-client-body-temp-path=/home/container/.nginx/body \
#         --http-fastcgi-temp-path=/home/container/.nginx/fastcgi \
#         --http-proxy-temp-path=/home/container/.nginx/proxy \
#         --http-scgi-temp-path=/home/container/.nginx/scgi \
#         --http-uwsgi-temp-path=/home/container/.nginx/uwsgi \
#         \
#         # 🧾 Arahkan log ke stdout/stderr agar cocok untuk Docker
#         --error-log-path=/dev/stderr \
#         --http-log-path=/dev/stdout \
#         \
#         # 🔐 Modul dan fitur penting
#         --with-compat \
#         --with-threads \
#         --with-file-aio \
#         --with-pcre-jit \
#         --with-http_ssl_module \
#         --with-http_v2_module \
#         --with-http_stub_status_module \
#         --with-http_realip_module \
#         --with-http_auth_request_module \
#         --with-http_slice_module \
#         --with-http_gunzip_module \
#         --with-http_gzip_static_module \
#         --with-http_sub_module \
#         --with-http_addition_module \
#         --with-http_dav_module \
#         \
#         # 📊 Tambahan opsional
#         --with-http_flv_module \
#         --with-http_mp4_module \
#         --with-stream \
#         --with-stream_ssl_module \
#         --with-stream_realip_module \
#         --with-stream_ssl_preread_module \
#         --with-mail=dynamic \
#         --with-mail_ssl_module \
#         \
#         # ⚙️ Opsi build untuk keamanan dan performa seperti di Ubuntu
#         --with-cc-opt='-g -O2 -ffile-prefix-map=/build/nginx=. -flto=auto -ffat-lto-objects -fstack-protector-strong -Wformat -Werror=format-security -fPIC -Wdate-time -D_FORTIFY_SOURCE=2' \
#         --with-ld-opt='-Wl,-Bsymbolic-functions -flto=auto -ffat-lto-objects -Wl,-z,relro -Wl,-z,now -fPIC' && \
#     make && make install && \
#     ln -s /usr/local/nginx/sbin/nginx /usr/sbin/nginx && \
#     rm -rf /tmp/nginx*

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
# 🧩 Buat user container non-root
# ========================================
RUN groupadd -g 997 container \
    && useradd -m -u 997 -g container -d /home/container -s /bin/bash container \
    && mkdir -p /home/container \
    && chown -R container:container /home/container

# RUN groupadd -g 997 container && useradd -m -d /home/container -g container container

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
# 🧩 create directory
# ========================================
WORKDIR /app
WORKDIR /nginx
# WORKDIR /var/log/nginx
WORKDIR /var/lib/nginx/body
WORKDIR /var/lib/nginx/proxy
WORKDIR /var/lib/nginx/fastcgi
WORKDIR /var/lib/nginx/uwsgi
WORKDIR /var/lib/nginx/scgi
WORKDIR /etc/nginx
# ========================================
# 🧩 Copy entrypoint & bash_custom & nginx
# ========================================
COPY --chown=container:container app/entrypoint.sh /app/entrypoint.sh
COPY --chown=container:container app/bash_custom /app/bash_custom
COPY --chown=container:container app/supervisord.conf /app/supervisord.conf
COPY --chown=container:container default/nginx.conf /nginx/default.conf
# COPY --chown=container:container logs/access.log /var/log/nginx/access.log
# COPY --chown=container:container logs/error.log /var/log/nginx/error.log
COPY --chown=container:container nginx/* /etc/nginx/
RUN chmod +x /app/entrypoint.sh /app/bash_custom /app/supervisord.conf /nginx/default.conf /etc/nginx/
# /var/log/nginx/access.log /var/log/nginx/error.log

# COPY ../entrypoint.sh /entrypoint.sh
# COPY ../bash_custom /bash_custom

# ========================================
# 🧩 User dan direktori kerja
# ========================================
USER container
WORKDIR /home/container

# ========================================
# 🚀 Jalankan container
# ========================================
CMD ["/bin/bash", "/app/entrypoint.sh"]
