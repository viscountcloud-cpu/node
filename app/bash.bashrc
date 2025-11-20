
[ -z "$PS1" ] && return

if ! [ -n "${SUDO_USER}" -a -n "${SUDO_PS1}" ]; then
  PS1="root@${HOST_NAME}:\w\$ "
fi


export CLOUDFLARED_HOME="/home/container/.cloudflared"

if [[ "${SETUP_NGINX}" == "ON" ]]; then
    TUNNEL_NAME="ServerWeb-${HOSTNAME}"
    TUNNEL_FILE="$CLOUDFLARED_HOME/${TUNNEL_NAME}.json"
    CONFIG_FILE="$CLOUDFLARED_HOME/config.yml"
    CLOUDFLARED_BIN="$(command -v cloudflared || echo /usr/local/bin/cloudflared)"
    if [ ! -f "$TUNNEL_FILE" ]; then
        "$CLOUDFLARED_BIN" tunnel create "$TUNNEL_NAME"
        FOUND_JSON=$(ls "$CLOUDFLARED_HOME"/*.json 2>/dev/null | head -n 1)
        #FOUND_JSON=${CLOUDFLARED_HOME}/${FOUND_JSON}
        if [ ! "$FOUND_JSON" = "$NEW_JSON_PATH" ]; then
            mv "$FOUND_JSON" "$TUNNEL_FILE"
        fi

        cat > "$CONFIG_FILE" <<EOF
tunnel: ${TUNNEL_NAME}
credentials-file: ${TUNNEL_FILE}

ingress:
  - hostname: ${DOMAIN}
    service: http://localhost:$SERVER_PORT
  - service: http_status:404
EOF

        if ! pgrep -f "cloudflared tunnel run ${TUNNEL_NAME}" >/dev/null; then
            echo "[Cloudflared] Menjalankan tunnel ${TUNNEL_NAME}..."
            nohup "$CLOUDFLARED_BIN" tunnel run "$TUNNEL_NAME" --config "$CONFIG_FILE" >/dev/null 2>&1 &
        elif ! pgrep -f "cr tunnel run ${TUNNEL_NAME}" >/dev/null; then
            echo "[Cloudflared] Menjalankan tunnel ${TUNNEL_NAME}..."
            nohup "$CLOUDFLARED_BIN" tunnel run "$TUNNEL_NAME" --config "$CONFIG_FILE" >/dev/null 2>&1 &
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


NVM_BIN="$(command -v nvm)"

if [[ "${NODE_VERSION}" == "24" ]]; then
    "$NVM_BIN" use 24
elif [[ "${NODE_VERSION}" == "23" ]]; then
    "$NVM_BIN" use 23
elif [[ "${NODE_VERSION}" == "22" ]]; then
    "$NVM_BIN" use 22
elif [[ "${NODE_VERSION}" == "21" ]]; then
    "$NVM_BIN" use 21
elif [[ "${NODE_VERSION}" == "20" ]]; then
    "$NVM_BIN" use 20
elif [[ "${NODE_VERSION}" == "19" ]]; then
    "$NVM_BIN" use 19
elif [[ "${NODE_VERSION}" == "18" ]]; then
    "$NVM_BIN" use 18
elif [[ "${NODE_VERSION}" == "17" ]]; then
    "$NVM_BIN" use 17
elif [[ "${NODE_VERSION}" == "16" ]]; then
    "$NVM_BIN" use 16
fi

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
