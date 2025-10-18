#!/bin/bash
export PM2_HOME=/home/container/.pm2
LIMIT=${PM2_LIMIT:-3}

# Hitung jumlah proses PM2 yang sedang berjalan
CURRENT=$(pm2 jlist | jq length 2>/dev/null || echo 0)

# Jika start dan limit tercapai, jangan jalankan
if [[ "$1" == "start" ]]; then
    if [[ "$LIMIT" -ne 0 && "$CURRENT" -ge "$LIMIT" ]]; then
        echo "⚠️ PM2 limit of $LIMIT processes reached. Skipping new start." >&2
        exit 0
    fi
fi

# Jalankan PM2 asli
exec /usr/bin/pm2 "$@"
