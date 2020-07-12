#!/bin/bash
#
# [Servidor HD :: Install Emby package]
#
# Adapted for Servidor HD by ajvulcan
#
# -- Servidor HD --
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.


if [[ -f /tmp/.install.lock ]]; then
  log="/root/logs/install.log"
else
  log="/root/logs/swizzin.log"
fi
username=$(cut -d: -f1 < /root/.master.info)

if [[ ! $(command -v mono) ]]; then
  echo "Instalando mono ... "
  . /etc/swizzin/sources/functions/mono
  mono_repo_setup
  apt-get install -y libmono-cil-dev >> ${log} 2>&1
fi

echo "Instalando emby desde GitHub ... "
  current=$(curl -L -s -H 'Accept: application/json' https://github.com/MediaBrowser/Emby.Releases/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
  cd /tmp
  wget -q -O emby.dpkg https://github.com/MediaBrowser/Emby.Releases/releases/download/${current}/emby-server-deb_${current}_amd64.deb
  dpkg -i emby.dpkg >> $log 2>&1
  rm emby.dpkg

if [[ -f /etc/emby-server.conf ]]; then
  printf "\nEMBY_USER="${username}"\nEMBY_GROUP="${username}"\n" >> /etc/emby-server.conf
fi

if [[ -f /install/.nginx.lock ]]; then
echo "Ajustando configuración de emby ... "
  bash /usr/local/bin/swizzin/nginx/emby.sh
  systemctl reload nginx
fi

usermod -a -G ${username} emby

systemctl restart emby-server >/dev/null 2>&1
touch /install/.emby.lock

echo "Emby instalado: quizás necesites acceder primero para configurar la conexión segura, para ello abre en una ventana nueva"
echo "la dirección de tu server de esta forma http://(dirección del server):8096/ y configura los datos correspondientes"
echo "con los datos obtenidos de letsencrypt para acceder a través del https."

#Cambio de usuario de emby para permisos.
#service emby-server stop >/dev/null 2>&1
#username=$(cat /root/.master.info | cut -d: -f1)
#echo '...'
#sleep 15
#echo "cambiando usuario emby a "${username}" "
#echo ${username}
#systemctl disable emby-server --now
#chown -R $username:$username /var/lib/emby
#systemctl enable emby-server@$username --now
#systemctl restart emby-server@$username