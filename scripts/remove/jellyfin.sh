#!/usr/bin/env bash
#
<<<<<<< HEAD
# Set the required variables
username="$(cat /root/.master.info | cut -d: -f1)"
#
# Define the removal function for jellyfin.
=======
#   SERVIDOR HD
#

# VARIABLES
username="$(cat /root/.master.info | cut -d: -f1)"

# FUNCIONES.
>>>>>>> master
function remove_jellyfin() {
    systemctl stop "jellyfin.service"
    #
    systemctl disable "jellyfin.service"
    #
    rm -f "/etc/systemd/system/jellyfin.service"
    #
    kill -9 $(ps xU ${username} | grep "/opt/jellyfin/jellyfin -d /home/${username}/.config/Jellyfin$" | awk '{print $1}') >/dev/null 2>&1
    #
    rm -rf "/opt/jellyfin"
    rm -rf "/opt/ffmpeg"
    rm -rf "/home/${username}/.config/Jellyfin"
    #
    if [[ -f /install/.nginx.lock ]]; then
        rm -f "/etc/nginx/apps/jellyfin.conf"
<<<<<<< HEAD
        service nginx reload
=======
        systemctl reload nginx
>>>>>>> master
    fi
    #
    rm -f "/install/.jellyfin.lock"
}
#
<<<<<<< HEAD
# run the removal function
=======
# EJECUCION
>>>>>>> master
remove_jellyfin