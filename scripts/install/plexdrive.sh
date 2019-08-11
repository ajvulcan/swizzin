#!/bin/bash
#
# [Servidor HD :: Install PlexDrive]
#
# Author   : ajvulcan
#
# Servidor HD Copyright (C) 2019
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.

if [[ -f /tmp/.install.lock ]]; then
  OUTTO="/root/logs/install.log"
elif [[ -f /install/.panel.lock ]]; then
  OUTTO="/srv/panel/db/output.log"
else
  OUTTO="/dev/null"
fi

echo "Instalando PlexDrive ..."

#necesitamos la librería de fuse (si no está instalada)
apt-get -y update >> $OUTTO 2>&1
apt-get -y install fuse >> $OUTTO 2>&1

#Descargo binario de plexdrive
current=$(curl -L -s -H 'Accept: application/json' https://github.com/dweidenfeld/plexdrive/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
cd /tmp
wget -q -O plexdrive https://github.com/dweidenfeld/plexdrive/releases/download/${current}/plexdrive-linux-amd64
#Permisos y puesta a servicio del sistema
chown root:root plexdrive
chmod 755 plexdrive
mv plexdrive /usr/local/bin/plexdrive

touch /install/.plexdrive.lock

    echo "¡plexdrive instalación completa!" >>"${OUTTO}" 2>&1;

echo >>"${OUTTO}" 2>&1;
echo >>"${OUTTO}" 2>&1;
echo "Cierra esta ventana de diálogo para actualizar tu navegador" >>"${OUTTO}" 2>&1;
