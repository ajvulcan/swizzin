#!/bin/bash
# Deluge upgrade/downgrade/reinstall script
# Author: liara
# Mod: ajvulcan
#
# SERVIDOR HD

if [[ ! -f /install/.deluge.lock ]]; then
  echo "Deluge no está instalado. ¿Que esperas conseguir ejecutando este script?"
  exit 1
fi

if [[ -f /tmp/.install.lock ]]; then
  export log="/root/logs/install.log"
else
  export log="/dev/null"
fi

. /etc/swizzin/sources/functions/deluge
whiptail_deluge
whiptail_libtorrent_rasterbar
dver=$(deluged -v | grep deluged | grep -oP '\d+\.\d+\.\d+')
if [[ $dver == 1.3* ]] && [[ $deluge == master ]]; then
  echo "Detectada actualización más moderna. Haciendo copia de seguridad de datos."
fi
users=($(cut -d: -f1 < /etc/htpasswd))
noexec=$(grep "/tmp" /etc/fstab | grep noexec)

for u in "${users[@]}"; do
    if [[ $dver == 1.3* ]] && [[ $deluge == master ]]; then
      echo "'/home/${u}/.config/deluge' -> '/home/$u/.config/deluge.$$'"
      cp -a /home/${u}/.config/deluge /home/${u}/.config/deluge.$$
    fi
done

if [[ -n $noexec ]]; then
  mount -o remount,exec /tmp
  noexec=1
fi

echo "Comprobando por método obsoleto de instalación de deluge."; remove_ltcheckinstall
echo "Reconstruyendo libtorrent ... "; build_libtorrent_rasterbar
cleanup_deluge
echo "Actualizando Deluge. Por favor, espera ... "; build_deluge

if [[ -n $noexec ]]; then
	mount -o remount,noexec /tmp
fi

if [[ -f /install/.nginx.lock ]]; then
  echo "Reconfigurando configuraciones deluge de ngnix"
  bash /usr/local/bin/swizzin/nginx/deluge.sh
  service nginx reload
fi

echo "Modificando servicio web y lista de hosts ... "; dweb_check

for u in "${users[@]}"; do
  echo "Ejecutando comprobación ltconfig ..."; ltconfig
  systemctl try-restart deluged@${u}
  systemctl try-restart deluge-web@${u}
done
