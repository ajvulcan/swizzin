#!/bin/bash
#
# [Servidor HD :: Install webmin]
#
# Author   : ajvulcan
#
# Servidor HD Copyright (C) 2019
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

_instalar_webmin () {
  #Instalando webmin
  echo 'Añadiendo repositorios ...'
  echo "deb https://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list

  #Añadimos claves
  cd /root
  wget http://www.webmin.com/jcameron-key.asc >> $log 2>&1
  sudo apt-key add jcameron-key.asc >> $log 2>&1
  rm jcameron-key.asc

  #Actualizamos base de datos e instalamos
  echo "Instalando webmin, espere ..."

  apt-get update >> $log 2>&1
  apt-get -y install apt-transport-https >> $log 2>&1
  apt-get install webmin -yq >> $log 2>&1

  #Instalación completa
  touch /install/.webmin.lock
  echo
  echo "Webmin instalado." 
}

_instalar_webmin

if [[ -f /install/.nginx.lock ]]; then
  bash /etc/swizzin/scripts/nginx/webmin.sh
fi




