#!/bin/bash
#
# [Servidor HD :: Install webmin]
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

#Instalando webmin
echo ''
echo 'Añadiendo repositorios ...'
echo ''

cat >> /etc/apt/sources.list <<EOF
#webmin
deb https://download.webmin.com/download/repository sarge contrib
EOF

#Añadimos claves
cd /root
wget http://www.webmin.com/jcameron-key.asc >> $OUTTO 2>&1
apt-key add jcameron-key.asc >> $OUTTO 2>&1

#Actualizamos base de datos e instalamos
echo ""
echo "Instalando webmin, espere ..."
echo ""

apt-get -y update >> $OUTTO 2>&1
apt-get -y install apt-transport-https >> $OUTTO 2>&1
apt-get -y install webmin >> $OUTTO 2>&1
rm jcameron-key.asc

#Configuramos webmin para que lo muestre en nuestro dashboard
echo "no_frame_options=1" >> /etc/webmin/config

#Instalación completa
touch /install/.webmin.lock
echo ""
echo "Webmin instalado." >> $OUTTO 2>&1