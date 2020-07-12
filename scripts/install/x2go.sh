#!/bin/bash
#
# x2go installer
#
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
#################################################################################

if [[ -f /tmp/.install.lock ]]; then
  log="/root/logs/install.log"
else
  log="/root/logs/swizzin.log"
fi

distribution=$(lsb_release -is)
release=$(lsb_release -cs)
echo -n "Installing Xfce4 (this may take a bit) ... "
apt-get install -y xfce4 >> ${log} 2>&1
#Desabilita ligthdn porque causa problemas de suspensión en ubuntu.
systemctl disable --now lightdm >> ${log} 2>&1

echo -n "Instalando repositorios x2go ... "

if [[ $distribution == Ubuntu ]]; then
	apt-get install -q -y software-properties-common >> ${log} 2>&1
	apt-add-repository ppa:x2go/stable -y >> ${log} 2>&1
	apt-get -y update >> ${log} 2>&1
else

cat >/etc/apt/sources.list.d/x2go.list<<EOF
# X2Go Repository (release builds)
deb http://packages.x2go.org/debian ${release} main
# X2Go Repository (sources of release builds)
deb-src http://packages.x2go.org/debian ${release} main
# X2Go Repository (nightly builds)
#deb http://packages.x2go.org/debian ${release} heuler
# X2Go Repository (sources of nightly builds)
#deb-src http://packages.x2go.org/debian ${release} heuler
EOF

apt-get -y update>> ${log} 2>&1
apt-key --keyring /etc/apt/trusted.gpg.d/x2go.gpg adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E1F958385BFE2B6E >> ${log} 2>&1

apt-get -y update >> ${log} 2>&1
apt-get -y install x2go-keyring >> ${log} 2>&1 && apt-get update >> ${log} 2>&1
fi


echo -n "Instalando X2go (puede llevar un rato) ... "
apt-get -y install x2goserver x2goserver-xsession >> ${log} 2>&1
apt-get -y install pulseaudio >> ${log} 2>&1

touch /install/.x2go.lock