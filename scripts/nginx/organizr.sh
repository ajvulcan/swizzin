#!/bin/bash
# ruTorrent installation and nginx configuration
# 
# SERVIDOR HD

if [[ -f /tmp/.install.lock ]]; then
  export log="/root/logs/install.log"
else
  log="/root/logs/swizzin.log"
fi

if [[ ! -f /install/.nginx.lock ]]; then
  echo "nginx no está instalado, es necesario, instálelo antes."
  exit 1
fi
#shellcheck source=sources/functions/php
. /etc/swizzin/sources/functions/php

###################################

phpv=$(php_v_from_nginxconf)
sock="php${phpv}-fpm"

echo "Instalando la configuración de Nginx para organizr"
if [[ ! -f /etc/nginx/apps/organizr.conf ]]; then
cat > /etc/nginx/apps/organizr.conf <<RUM
location /organizr {
  alias /srv/organizr;
  location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/run/php/$sock.sock;
    fastcgi_param SCRIPT_FILENAME /srv\$fastcgi_script_name;
    fastcgi_buffers 32 32k;
    fastcgi_buffer_size 32k;
  }
}
RUM
fi

# blacklist_path="/etc/php/$phpv/opcache-blacklist.txt"

# if [[ ! -f $blacklist_path ]]; then 
#   touch "$blacklist_path"
# fi
# echo "/srv/organizr/*" >> "$blacklist_path"
# echo "opcache.blacklist_filename=$blacklist_path" >> /etc/php/$phpv/fpm/php.ini

# reload_php_fpm

chown -R www-data:www-data /srv/organizr
systemctl reload nginx
