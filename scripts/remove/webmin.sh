#!/bin/bash
# Uninstall for webmin package on Servidor HD
# [servidor HD :: Uninstaller for Webmin package]
# Author: ajvulcan
#
# Servidor HD Copyright (C) 2019
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#

#Simplemente lo desinstalamos.
if [[ -f /tmp/.install.lock ]]; then
  log="/root/logs/install.log"
else
  log="/root/logs/swizzin.log"
fi

apt-get remove webmin -yq >> $log 2>&1
rm -rf /etc/webmin

#Eliminamos la fuente
sed -i '/.*webmin.*/d' /etc/apt/sources.list >> /etc/null
rm /etc/apt/sources.list.d/webmin.list

if [[ -f /install/.nginx.lock ]]; then 
    rm /etc/nginx/apps/webmin.conf
    systemctl reload nginx
fi

rm /install/.webmin.lock

echo "Webmin desinstalado"