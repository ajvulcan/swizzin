#!/bin/bash
# ruTorrent installation wrapper
#
# SERVIDOR HD

if [[ ! -f /install/.nginx.lock ]]; then
  echo "nginx no está instalado, ruTorrent requiere un servidor web. Por favor, instala nginx antes."
  exit 1
fi

if [[ ! -f /install/.rtorrent.lock ]]; then
  echo "ruTorrent is una interfaz para rTorrent, el cual no está instalado. Saliendo."
  exit 1
fi

bash /usr/local/bin/swizzin/nginx/rutorrent.sh
systemctl reload nginx
touch /install/.rutorrent.lock