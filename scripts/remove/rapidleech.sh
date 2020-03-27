#!/bin/bash
#
# [Servidor HD :: Uninstaller for Rapidleech package]
#
# Author             :   QuickBox.IO
#
# Servidor HD Copyright (C) 2019
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#
MASTER=$(cut -d: -f1 < /root/.master.info)
OUTTO="/root/quick-box.log"

function _removeRapidleech() {
  sudo rm -r  /home/"${MASTER}"/rapidleech
  sudo rm /etc/nginx/apps/rapidleech.conf
  sudo rm /install/.rapidleech.lock
  service nginx reload
}

_removeRapidleech
