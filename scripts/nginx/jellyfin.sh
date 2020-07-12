#!/usr/bin/env bash
#
# SERVIDOR HD
#

# VARIABLES
username="$(cat /root/.master.info | cut -d: -f1)"
#
# FUNCIONES
function reused_commands () {
    sed -r 's#<string>0.0.0.0</string>#<string>127.0.0.1</string>#g' -i "/home/${username}/.config/Jellyfin/config/system.xml"
    sed -r 's#<BaseUrl />#<BaseUrl>/jellyfin</BaseUrl>#g' -i "/home/${username}/.config/Jellyfin/config/system.xml"
}
#
#INSTALACION NUEVA
if [[ ! -f /install/.jellyfin.lock ]]; then
    app_port_http="$1"
    app_port_https="$2"
    #
    reused_commands
fi
#
# REINSTALACION
if [[ -f /install/.jellyfin.lock ]]; then
    systemctl stop jellyfin
    app_port_https="$(sed -rn 's#(.*)<HttpsPortNumber>(.*)</HttpsPortNumber>#\2#p' "/home/${username}/.config/Jellyfin/config/system.xml")"
    #
    reused_commands
    #
    systemctl start jellyfin
fi
#
# CONFIGURACION NGINX PARA JELLYFIN
cat > /etc/nginx/apps/jellyfin.conf <<-NGINGCONF
location /jellyfin {
    proxy_pass https://127.0.0.1:${app_port_https};
    #
    proxy_pass_request_headers on;
    #
    proxy_set_header Host \$host;
    #
    proxy_http_version 1.1;
    #
    proxy_set_header X-Real-IP              \$remote_addr;
    proxy_set_header X-Forwarded-For        \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto      \$scheme;
    proxy_set_header X-Forwarded-Protocol   \$scheme;
    proxy_set_header X-Forwarded-Host       \$http_host;
    #
    proxy_set_header Upgrade                \$http_upgrade;
    proxy_set_header Connection             \$http_connection;
    #
    proxy_set_header X-Forwarded-Ssl        on;
    #
    proxy_redirect                          off;
    proxy_buffering                         off;
    auth_basic                              off;
}
NGINGCONF