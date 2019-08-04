#!/bin/bash
#
# [Servidor HD :: Install Emby package]
#
# Original Author:   JMSolo
# Modified for Swizzin by liara
# Forked and modified for Servidor HD by ajvulcan
#
# Servidor HD Copyright (C) 2019
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.

DISTRO=$(lsb_release -is)
CODENAME=$(lsb_release -cs)
if [[ -f /tmp/.install.lock ]]; then
  OUTTO="/root/logs/install.log"
elif [[ -f /install/.panel.lock ]]; then
  OUTTO="/srv/panel/db/output.log"
else
  OUTTO="/dev/null"
fi
username=$(cut -d: -f1 < /root/.master.info)

if [[ -f /install/.nginx.lock ]]; then
echo "Ajustando la configuración nginx de emby ... " >>"${OUTTO}" 2>&1;
  echo "Ajustando la configuración nginx de emby ... "
  bash /usr/local/bin/swizzin/nginx/emby.sh
  service nginx reload
fi

echo "Instalando las llaves y fuentes de emby o descargando el binario ... " >>"${OUTTO}" 2>&1;
echo "Instalando las llaves y fuentes de emby o descargando el binario ... "
  if [[ $DISTRO == Debian ]]; then
    version=$(grep VERSION= /etc/os-release| cut -d "\"" -f 2 | cut -d " " -f1).0
    echo "deb http://download.opensuse.org/repositories/home:/emby/$(lsb_release -is)_${version}/ /" > /etc/apt/sources.list.d/emby-server.list
    wget --quiet http://download.opensuse.org/repositories/home:emby/$(lsb_release -is)_${version}/Release.key -O - | apt-key add - > /dev/null 2>&1
  elif [[ $DISTRO == Ubuntu ]]; then
    if [[ $CODENAME =~ ("artful"|"bionic") ]]; then
      current=$(curl -L -s -H 'Accept: application/json' https://github.com/MediaBrowser/Emby.Releases/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
      cd /tmp
      wget -q -O emby.dpkg https://github.com/MediaBrowser/Emby.Releases/releases/download/${current}/emby-server-deb_${current}_amd64.deb
      dpkg -i emby.dpkg >> $OUTTO 2>&1
      rm emby.dpkg
    else
      version=$(grep VERSION= /etc/os-release | cut -d "\"" -f 2 | cut -d " " -f1 | cut -d. -f1-2)
      #sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/emby/x$(lsb_release -is)_${version}/ /' > /etc/apt/sources.list.d/emby-server.list"
      #wget --quiet http://download.opensuse.org/repositories/home:emby/x$(lsb_release -is)_${version}/Release.key -O - | apt-key add - > /dev/null 2>&1
      current=$(curl -L -s -H 'Accept: application/json' https://github.com/MediaBrowser/Emby.Releases/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
      cd /tmp
      wget -q -O emby.dpkg https://github.com/MediaBrowser/Emby.Releases/releases/download/${current}/emby-server-deb_${current}_amd64.deb
    fi
  fi

echo "Actualizando sistema & instalando emby server ... " >>"${OUTTO}" 2>&1;
echo "Actualizando sistema & instalando emby server ... "
    apt-get -y update >/dev/null 2>&1
    #apt-get install -y --allow-unauthenticated -f emby-server >/dev/null 2>&1
    dpkg -i emby.dpkg
    rm emby.dpkg
    echo
    sleep 5

    if [[ -f /etc/emby-server.conf ]]; then
      printf "\n" >> /etc/emby-server.conf
      echo "EMBY_USER="${username}"" >> /etc/emby-server.conf
      echo "EMBY_GROUP="${username}"" >> /etc/emby-server.conf
    fi

#Cambio de usuario de emby para permisos.
service emby-server stop >/dev/null 2>&1
username=$(cat /root/.master.info | cut -d: -f1)
echo '...'
sleep 15
echo "cambiando usuario emby a "${username}" "
echo ${username}
systemctl disable emby-server --now
chown -R $username:$username /var/lib/emby
systemctl enable emby-server@$username --now
systemctl restart emby-server@$username

    #systemctl restart emby-server >/dev/null 2>&1
    touch /install/.emby.lock
    echo

echo "¡Instalación de emby completada!" >>"${OUTTO}" 2>&1;
echo "¡Instalación de emby completada!"
    sleep 5
    echo >>"${OUTTO}" 2>&1;
    echo >>"${OUTTO}" 2>&1;
    echo "Cierra esta ventana para actualizar tu navegador" >>"${OUTTO}" 2>&1;

    exit
