#!/bin/bash
#
# [Servidor HD :: Remove AutoDL-IRSSI package]
#
# Servidor HD 
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#

users=($(cut -d: -f1 < /etc/htpasswd))
rm -rf /srv/rutorrent/plugins/autodl-irssi
  for u in "${users[@]}"; do
    systemctl disable --now irssi@${u}
    rm -rf /home/${u}/.autodl
    rm -rf /home/${u}/.irssi
  done
rm /etc/systemd/system/irssi@.service
rm /install/.autodl.lock
