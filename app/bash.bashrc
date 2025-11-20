[ -z "$PS1" ] && return

if ! [ -n "${SUDO_USER}" -a -n "${SUDO_PS1}" ]; then
  PS1="root@${HOST_NAME}:\w\$ "
fi

export CLOUDFLARED_HOME="/home/container/.cloudflared"


if [[ "${SETUP_NGINX}" == "ON" ]]; then
    mkdir -p /home/container/.nginx
    mkdir -p /home/container/webroot
    mkdir -p /home/container/.cloudflared/logs
    if [ ! -f /home/container/.nginx/default.conf ]; then
        cp /nginx/default.conf /home/container/.nginx/default.conf
        sed -i "s|listen [0-9]*;|listen ${PORT};|g" /home/container/.nginx/default.conf
        if [[ "$DOMAIN" != example.com ]]; then
            sed -i "s|server_name .*;|server_name ${DOMAIN};|g" /home/container/.nginx/default.conf
        else
            sed -i "s|server_name .*;|server_name localhost;|g" /home/container/.nginx/default.conf
        fi
    fi
    if [ ! -f /home/container/webroot/index.html ]; then
        cp /webroot/index.html /home/container/webroot/index.html
    fi
    if [ -f /home/container/.nginx/default.conf ]; then
        nginx -c /home/container/.nginx/default.conf
    fi










    TUNNEL_NAME="ServerWeb-${HOSTNAME}"
    TUNNEL_FILE="$CLOUDFLARED_HOME/${HOSTNAME}.json"
    CONFIG_FILE="$CLOUDFLARED_HOME/config.yml"
    CERT_FILE="$CLOUDFLARED_HOME/cert.pem"
    CLOUDFLARED_BIN="$(command -v cloudflared || echo /usr/local/bin/cloudflared)"
    if [ ! -f "$CERT_FILE" ]; then
        "$CLOUDFLARED_BIN" login
    else
        if [ ! -f "$TUNNEL_FILE" ]; then
            "$CLOUDFLARED_BIN" tunnel create "$TUNNEL_NAME" >/dev/null 2>&1 &
            FOUND_JSON=$(ls "$CLOUDFLARED_HOME"/*.json 2>/dev/null | head -n 1)
            if [ -n "$FOUND_JSON" ] && [ "$FOUND_JSON" != "$TUNNEL_FILE" ]; then
                mv "$FOUND_JSON" "$TUNNEL_FILE"
            fi
        fi
        if [[ "$DOMAIN" != example.com ]]; then
            "$CLOUDFLARED_BIN" tunnel route dns "$TUNNEL_NAME" "$DOMAIN" \
        >> "${CLOUDFLARED_HOME}/logs/dns.out.log" \
        2>> "${CLOUDFLARED_HOME}/logs/dns.err.log" &
        fi
        cat > "$CONFIG_FILE" <<EOF
tunnel: ${TUNNEL_NAME}
credentials-file: ${TUNNEL_FILE}

ingress:
  - hostname: ${DOMAIN}
    service: http://localhost:$SERVER_PORT
  - service: http_status:404
EOF
        if ! pgrep -f "cloudflared tunnel run" >/dev/null; then
            "$CLOUDFLARED_BIN" tunnel run \
        >> "${CLOUDFLARED_HOME}/logs/run.out.log" \
        2>> "${CLOUDFLARED_HOME}/logs/run.err.log" &
        fi
    fi
fi




if [ -d "/home/container/.nvm" ]; then
    export NVM_DIR="/home/container/.nvm"
else
    export NVM_DIR="/app/.nvm"
fi



[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"


if [ ! -e "$HOME/.sudo_as_admin_successful" ] && [ ! -e "$HOME/.hushlogin" ] ; then
    case " $(groups) " in *\ admin\ *|*\ sudo\ *)
    if [ -x /usr/bin/sudo ]; then
	cat <<-EOF
	To run a command as administrator (user "root"), use "sudo <command>".
	See "man sudo_root" for details.
	
	EOF
    fi
    esac
fi

if [ -x /usr/lib/command-not-found -o -x /usr/share/command-not-found/command-not-found ]; then
	function command_not_found_handle {
	        # check because c-n-f could've been removed in the meantime
                if [ -x /usr/lib/command-not-found ]; then
		   /usr/lib/command-not-found -- "$1"
                   return $?
                elif [ -x /usr/share/command-not-found/command-not-found ]; then
		   /usr/share/command-not-found/command-not-found -- "$1"
                   return $?
		else
		   printf "%s: command not found\n" "$1" >&2
		   return 127
		fi
	}
fi
