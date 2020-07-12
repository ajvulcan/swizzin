#!/bin/bash
#
# Quassel Installer
#
# by ajvulcan
#
# Servidor HD Copyright (C) 
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#
#################################################################################

if [[ -f /tmp/.install.lock ]]; then
  OUTTO="/root/logs/install.log"
else
  OUTTO="/root/logs/swizzin.log"
fi
distribution=$(lsb_release -is)
codename=$(lsb_release -cs)
IP=$(ip route get 1 | sed -n 's/^.*src \([0-9.]*\) .*$/\1/p')
user=$(cut -d: -f1 < /root/.master.info)
. /etc/swizzin/sources/functions/backports

echo "Instalando Quassel PPA (Ubuntu) o obteniendo el último backport (Debian) ... "

if [[ $distribution == Ubuntu ]]; then
  echo "Instalando Quassel PPA"
  apt-get install -q -y software-properties-common > /dev/null 2>&1
	apt-add-repository ppa:mamarley/quassel -y >/dev/null 2>&1
	apt-get -q -y update >/dev/null 2>&1
  apt-get -q -y install quassel-core >/dev/null 2>&1
else
  if [[ $codename == "buster" ]]; then
    echo "bajando latest release"
    apt-get -y -q install quassel-core > /dev/null 2>&1
  elif [[ $codename == "stretch" ]]; then
    check_debian_backports
    echo "bajando latest backport"
    apt-get -y -q install quassel-core > /dev/null 2>&1
  else
    echo "bajando latest backport"
    wget -r -l1 --no-parent --no-directories -A "quassel-core*.deb" https://iskrembilen.com/quassel-packages-debian/ >/dev/null 2>&1
    dpkg -i quassel-core* >/dev/null 2>&1
    rm quassel-core*
    apt-get install -f -y -q >/dev/null 2>&1
  fi
fi

mv /etc/init.d/quasselcore /etc/init.d/quasselcore.BAK
systemctl enable --now quasselcore

echo "¡Quassel ya ha sido instalado! "
echo "Por favor, instala el cliente de quassel en un ordenador personal "
echo "y conecta al nuevo nucleo creado "
echo "${IP}:4242 para configurar tu cuenta"

touch /install/.quassel.lock
