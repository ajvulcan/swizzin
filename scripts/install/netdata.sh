#! /bin/bash
# Netdata installer for SERVIDOR HD
# by ajvulcan

if [[ -f /tmp/.install.lock ]]; then
  log="/root/logs/install.log"
elif [[ -f /install/.panel.lock ]]; then
  log="/srv/panel/db/output.log"
else
  log="/root/logs/swizzin.log"
fi

bash <(curl -LsS https://my-netdata.io/kickstart.sh) --non-interactive >> $log 2>&1

if [[ -f /install/.nginx.lock ]]; then
  bash /usr/local/bin/swizzin/nginx/netdata.sh
  systemctl reload nginx
fi

touch /install/.netdata.lock
