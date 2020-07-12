#!/bin/bash
#
# [SERVIDOR HD :: Remove subsonic package]
#
# BY AJVULCAN
#
# SERVIDOR HD
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#

dpkg -r subsonic
rm /etc/systemd/system/subsonic.service
rm -rf /srv/subsonic
rm -rf /var/subsonic
rm -rf /usr/share/subsonic
rm -f /etc/nginx/apps/subsonic.conf
rm -f /install/.subsonic.lock
systemctl reload nginx
