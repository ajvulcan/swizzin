#!/bin/bash
#
#  SERVIDOR HD
#

if [[ -f /etc/apt/sources.list.d/plexmediaserver.list ]]; then
  if grep -q "/deb/" /etc/apt/sources.list.d/plexmediaserver.list; then
      echo "Actualizando el repositorio apt para plex"
      echo "deb https://downloads.plex.tv/repo/deb public main" > /etc/apt/sources.list.d/plexmediaserver.list
      apt-get update -y -q
  fi     
fi