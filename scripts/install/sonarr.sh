#!/bin/bash
#
# [Servidor HD :: Install Sonarr-NzbDrone package]
#
# by Ajvulcan
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

function _installSonarrintro() {
  echo "Sonarr será instalado ahora." >>"${log}" 2>&1;
  echo "Este proceso llevará hasta 2 minutos." >>"${log}" 2>&1;
  echo "Por favor, espera hasta que se complete" >>"${log}" 2>&1;
  # output to box
  echo "Sonarr será instalado ahora."
  echo "Este proceso llevará hasta 2 minutos."
  echo "Por favor, espera hasta que se complete."
  echo
}

function _installSonarr1() {
  mono_repo_setup
}

function _installSonarr2() {
  apt-get install apt-transport-https screen -y >> ${log} 2>&1
  if [[ $distribution == "Ubuntu" ]]; then
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xA236C58F409091A18ACA53CBEBFF6B99D9B78493 >> ${log} 2>&1
  elif [[ $distribution == "Debian" ]]; then
    #buster friendly
    apt-key --keyring /etc/apt/trusted.gpg.d/nzbdrone.gpg adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xA236C58F409091A18ACA53CBEBFF6B99D9B78493 >> ${log} 2>&1
    #older style -- buster friendly should work on stretch
    #gpg --keyserver http://keyserver.ubuntu.com --recv 0xA236C58F409091A18ACA53CBEBFF6B99D9B78493 >/dev/null 2>&1
    #gpg --export 0xA236C58F409091A18ACA53CBEBFF6B99D9B78493 > /etc/apt/trusted.gpg.d/nzbdrone.gpg
  fi
  echo "deb https://apt.sonarr.tv/ master main" | tee /etc/apt/sources.list.d/sonarr.list >> ${log} 2>&1
}

function _installSonarr3() {
  apt-get -y update >> ${log} 2>&1
  if [[ $distribution == Debian ]]; then
    apt-get install -y mono-devel >> ${log} 2>&1
  fi
}

function _installSonarr4() {
  apt-get install -y nzbdrone >> ${log} 2>&1
  touch /install/.sonarr.lock
}

function _installSonarr5() {
  chown -R "${username}":"${username}" /opt/NzbDrone
}

function _installSonarr6() {
  cat > /etc/systemd/system/sonarr@.service <<SONARR
[Unit]
Description=nzbdrone
After=syslog.target network.target
[Service]
Type=forking
KillMode=process
User=%i
ExecStart=/usr/bin/screen -f -a -d -m -S nzbdrone mono /opt/NzbDrone/NzbDrone.exe
ExecStop=-/bin/kill -HUP
WorkingDirectory=/home/%i/
[Install]
WantedBy=multi-user.target
SONARR

  systemctl enable --now sonarr@${username} >> ${log} 2>&1
  sleep 10

  if [[ -f /install/.nginx.lock ]]; then
    sleep 10
    bash /usr/local/bin/swizzin/nginx/sonarr.sh
    systemctl reload nginx
  fi
}

function _installSonarr9() {
  echo "Sonarr Install Complete!" >>"${log}" 2>&1;
  echo >>"${log}" 2>&1;
  echo >>"${log}" 2>&1;
  echo "Close this dialog box to refresh your browser" >>"${log}" 2>&1;
}

function _installSonarr10() {
  exit
}

if [[ -f /tmp/.install.lock ]]; then
  log="/root/logs/install.log"
else
  log="/root/logs/swizzin.log"
fi
. /etc/swizzin/sources/functions/mono
username=$(cut -d: -f1 < /root/.master.info)
distribution=$(lsb_release -is)
version=$(lsb_release -cs)

_installSonarrintro
_installSonarr1
echo "Añadiendo repositorios fuente para Sonarr-Nzbdrone ... " >>"${log}" 2>&1;_installSonarr2
echo "Actualizando tu sistema con las nuevas fuentes ... " >>"${log}" 2>&1;_installSonarr3
echo "Instalando Sonarr-Nzbdrone ... " >>"${log}" 2>&1;_installSonarr4
echo "Configurando permisos para ${username} ... " >>"${log}" 2>&1;_installSonarr5
echo "Configurando Sonarr como un servicio y habilitándolo ... " >>"${log}" 2>&1;_installSonarr6
_installSonarr9
_installSonarr10
