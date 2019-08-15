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
apt-get purge -y webmin >> /etc/null
echo ""
apt autoremove
#Eliminamos la fuente
sed -i '/.*webmin.*/d' /etc/apt/sources.list >> /etc/null

rm /install/.webmin.lock

echo ""