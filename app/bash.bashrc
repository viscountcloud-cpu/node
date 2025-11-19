
[ -z "$PS1" ] && return

if ! [ -n "${SUDO_USER}" -a -n "${SUDO_PS1}" ]; then
  PS1="root@${HOST_NAME}:\w\$ "
fi


export CLOUDFLARED_HOME="/home/container/.cloudflared"

if [ ! -L /root/.cloudflared ]; then
    rm -rf /root/.cloudflared 2>/dev/null
    ln -s "$CLOUDFLARED_HOME" /root/.cloudflared
fi

if [ ! -L /etc/cloudflared ]; then
    rm -rf /etc/cloudflared 2>/dev/null
    ln -s "$CLOUDFLARED_HOME" /etc/cloudflared
fi

if [[ "${SETUP_NGINX}" == "ON" ]]; then
    TUNNEL_NAME="${HOSTNAME}"
    TUNNEL_FILE="$CLOUDFLARED_HOME/${TUNNEL_NAME}.json"
    CONFIG_FILE="$CLOUDFLARED_HOME/config.yml"
    CLOUDFLARED_BIN="$(command -v cloudflared || echo /usr/local/bin/cloudflared)"
    if [ ! -f "$TUNNEL_FILE" ]; then
        "$CLOUDFLARED_BIN" tunnel create "$TUNNEL_NAME"
        FOUND_JSON=$(ls "$CLOUDFLARED_HOME"/*.json 2>/dev/null | head -n 1)
        if [ ! "$FOUND_JSON" = "$NEW_JSON_PATH" ]; then
            mv "${CLOUDFLARED_HOME}/${FOUND_JSON}" "$TUNNEL_FILE"
        fi

        cat > "$CONFIG_FILE" <<EOF
tunnel: ${TUNNEL_NAME}
credentials-file: ${TUNNEL_FILE}

ingress:
    service: http://localhost:3000
  - service: http_status:404

proxy-dns: true
proxy-dns-address: 0.0.0.0
proxy-dns-port: 53
proxy-dns-upstream:
  - https://1.1.1.1/dns-query
  - https://1.0.0.1/dns-query
EOF
    echo "[Cloudflared] Tunnel berhasil dibuat."
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
