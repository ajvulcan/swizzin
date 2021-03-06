#!/bin/bash
#
# Tautulli installer para SERVIDOR HD
#
# by ajvulcan
#
# Servidor HD 
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#
if [[ -f /tmp/.install.lock ]]; then
  log="/root/logs/install.log"
else
  log="/root/logs/swizzin.log"
fi
MASTER=$(cut -d: -f1 < /root/.master.info)

apt-get -y -q install python3 >>"${log}" 2>&1
cd /opt
echo "Clonando último repositorio de Tautulli"
git clone https://github.com/Tautulli/Tautulli.git tautulli

echo "Añadiendo usuario y configurando Tautulli"
adduser --system --no-create-home tautulli >>"${log}" 2>&1

echo "Ajustando permisos"
chown tautulli:nogroup -R /opt/tautulli

echo "Habilitando la configuración en systemd de Tautulli"
cat > /etc/systemd/system/tautulli.service <<PPY
[Unit]
Description=Tautulli - Stats for Plex Media Server usage
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/python3 /opt/tautulli/Tautulli.py --quiet --daemon --nolaunch --config /opt/tautulli/config.ini --datadir /opt/tautulli
GuessMainPID=no
Type=forking
User=tautulli
Group=nogroup

[Install]
WantedBy=multi-user.target
PPY

systemctl enable --now tautulli > /dev/null 2>&1

if [[ -f /install/.nginx.lock ]]; then
  while [ ! -f /opt/tautulli/config.ini ]
  do
    sleep 2
  done
  bash /usr/local/bin/swizzin/nginx/tautulli.sh
  systemctl reload nginx
fi
touch /install/.tautulli.lock

echo "instalación de Tautulli completa!"
