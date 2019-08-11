#!/bin/bash
#
# [Servidor HD :: Desinstalar PlexDrive]
#
# Autor : ajvulcan
#
# Servidor HD Copyright (C) 2019
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.

  rm -f  /usr/local/bin/plexdrive
  rm -f /install/.plexdrive.lock

echo "PlexDrive desinstalado."