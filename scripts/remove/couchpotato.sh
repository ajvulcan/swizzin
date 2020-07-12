#!/bin/bash
#
# [Servidor HD :: Remove couchpotato package]
#
# Author             :   QuickBox.IO | liara
#
# Servidor HD Copyright (C) 2019
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#

user=$(cut -d: -f1 < /root/.master.info)
systemctl disable --now couchpotato > /dev/null 2>&1
rm /etc/systemd/system/couchpotato.service
rm -rf /opt/couchpotato
rm -rf /home/${user}/.config/couchpotato
rm -rf /opt/.venv/couchpotato
if [ -z "$(ls -A /opt/.venv)" ]; then
   rm -rf  /opt/.venv
fi
rm -f /etc/nginx/apps/couchpotato.conf
systemctl reload nginx
rm /install/.couchpotato.lock
