#!/bin/bash
#
# eliminador de plex para SERVIDOR HD
# by ajvulcan
#
# SERVIDOR HD
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#

function _removePlex() {
  dpkg -r plexmediaserver >/dev/null 2>&1
  sudo apt-get -y purge plexmediaserver >/dev/null 2>&1
  rm -f /etc/systemd/system/plexmediaserver.service
  systemctl daemon-reload >/dev/null 2>&1
  rm -rf /var/lib/plexmediaserver
  rm -rf /usr/lib/plexmediaserver
  rm /etc/init/plexmediaserver.conf >/dev/null 2>&1
  rm /etc/default/plexmediaserver >/dev/null 2>&1
  rm /install/.plex.lock
  userdel plex >/dev/null 2>&1
}

_removePlex
