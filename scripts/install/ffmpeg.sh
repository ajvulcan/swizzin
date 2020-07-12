#!/bin/bash
#
# [SERVIDOR HD :: Install ffmpeg package]
#
# by ajvulcan
#
# -- SERVIDOR HD --
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.

export distribution=$(lsb_release -is)
export release=$(lsb_release -rs)
export codename=$(lsb_release -cs)
if [[ -f /tmp/.install.lock ]]; then
  log="/root/logs/install.log"
elif [[ -f /install/.panel.lock ]]; then
  log="/srv/panel/db/output.log"
else
  log="/root/logs/swizzin.log"
fi

apt-get -y install ffmpeg >> $log 2>&1

touch /install/.ffmpeg.lock
