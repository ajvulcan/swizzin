#!/bin/bash
#
# [Servidor HD :: Install syncthing]
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

if [[ -f /tmp/.install.lock ]]; then
  OUTTO="/root/logs/install.log"
else
  OUTTO="/root/logs/swizzin.log"
fi
MASTER=$(cut -d: -f1 < /root/.master.info)

echo "Añadiendo repositorio Syncthing ... " >>"${OUTTO}" 2>&1;
curl -s https://syncthing.net/release-key.txt | sudo apt-key add - > /dev/null 2>&1
echo "deb http://apt.syncthing.net/ syncthing release" > /etc/apt/sources.list.d/syncthing.list

echo "Instalando Syncthing ... " >>"${OUTTO}" 2>&1;
sudo apt-get -q update > /dev/null 2>&1
sudo apt-get -qy install syncthing > /dev/null 2>&1

echo "Configurando Syncthing & comenzando ... " >>"${OUTTO}" 2>&1;
cat > /etc/systemd/system/syncthing@.service <<SYNC
[Unit]
Description=Syncthing - Open Source Continuous File Synchronization for %i
Documentation=man:syncthing(1)
After=network.target
Wants=syncthing-inotify@.service

[Service]
User=%i
ExecStart=/usr/bin/syncthing -no-browser -no-restart -logflags=0
Restart=on-failure
SuccessExitStatus=3 4
RestartForceExitStatus=3 4

[Install]
WantedBy=multi-user.target
SYNC

systemctl enable syncthing@${MASTER} > /dev/null 2>&1
systemctl start syncthing@${MASTER} > /dev/null 2>&1

if [[ -f /install/.nginx.lock ]]; then
  bash /usr/local/bin/swizzin/nginx/syncthing.sh
  systemctl reload nginx
fi

touch /install/.syncthing.lock
echo "Instalación de Syncthing completada!" >>"${OUTTO}" 2>&1
echo >>"${OUTTO}" 2>&1
echo >>"${OUTTO}" 2>&1
echo "Cierra esta ventana para actualizar tu explorador" >>"${OUTTO}" 2>&1
