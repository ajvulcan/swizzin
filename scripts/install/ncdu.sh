#!/bin/bash
#
# [Servidor HD :: Install NCDU]
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

#Actualizamos base de datos e instalamos ncdu
echo ""
echo "Instalando ncdu, espere ..."
echo ""

apt-get -y update >> $OUTTO 2>&1
apt-get -y install ncdu >> $OUTTO 2>&1

#Añadimos script de abertura intuitiva
cat > /etc/swizzin/scripts/disco_analizador <<EOF
#Ejecución intuitiva de ncdu
sudo ncdu /
EOF
chmod 770 /etc/swizzin/scripts/disco_analizador

#Instalación completa
touch /install/.ncdu.lock
echo ""
echo "NCDU instalado. Podrás ejecutarlo también escribiendo 'disco_analizador' en la consola de comandos" >> $OUTTO 2>&1