#!/bin/bash
# ruTorrent removal
# by ajvulcan
#
# SERVIDOR HD 

users=($(cut -d: -f1 < /etc/htpasswd))

rm -rf /srv/rutorrent
rm -rf /etc/nginx/apps/rutorrent.conf

if [[ ! -f /install/.flood.lock ]]; then
  rm -rf /etc/nginx/apps/rindex.conf
  for u in "${users[@]}"; do
    rm -f /etc/nginx/apps/${u}.scgi.conf
  done
fi
rm -rf /install/.rutorrent.lock
systemctl reload nginx