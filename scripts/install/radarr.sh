#!/bin/bash
#
# [Servidor HD :: Install Radarr package]
#
# by Ajvulcan
#
# -- Servidor HD --
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#################################################################################
function _string() { perl -le 'print map {(a..z,A..Z,0..9)[rand 62] } 0..pop' 15 ; }
#################################################################################

function _installRadarrIntro() {
  echo "Radarr va a ser instalado ahora." >>"${OUTTO}" 2>&1;
  echo "Este proceso llevará hasta 2 minutos." >>"${OUTTO}" 2>&1;
  echo "Espere hasta que se complete el proceso, por favor." >>"${OUTTO}" 2>&1;
  # output to box
  echo "Radarr va a ser instalado ahora.."
  echo "Este proceso llevará hasta 2 minutos."
  echo "Espere hasta que se complete el proceso, por favor."
  echo
  sleep 5
}

function _installRadarrDependencies() {
  # output to box
  echo "Instalando dependencias ... "
  mono_repo_setup
}

function _installRadarrCode() {
  # output to box
  apt-get -y -q update > /dev/null 2>&1
  apt-get install -y libmono-cil-dev curl mediainfo >/dev/null 2>&1
  echo "Instalando Radar ... "
  if [[ ! -d /opt ]]; then mkdir /opt; fi
  cd /opt
  wget $( curl -s https://api.github.com/repos/Radarr/Radarr/releases | grep linux.tar.gz | grep browser_download_url | head -1 | cut -d \" -f 4 ) > /dev/null 2>&1
  tar -xvzf Radarr.*.linux.tar.gz >/dev/null 2>&1
  rm -rf /opt/Radarr.*.linux.tar.gz
  touch /install/.radarr.lock
}

function _installRadarrConfigure() {
  # output to box
  echo "Configurando Radar ... "
cat > /etc/systemd/system/radarr.service <<EOF
[Unit]
Description=Radarr Daemon
After=syslog.target network.target

[Service]
User=${username}
Group=${username}
Type=simple
ExecStart=/usr/bin/mono /opt/Radarr/Radarr.exe -nobrowser
TimeoutStopSec=20
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF


  mkdir -p /home/${username}/.config
  chown -R ${username}:${username} /home/${username}/.config
#  chmod 775 /home/${username}/.config
  chown -R ${username}:${username} /opt/Radarr/
  systemctl daemon-reload
  systemctl enable radarr.service > /dev/null 2>&1
  systemctl start radarr.service

  if [[ -f /install/.nginx.lock ]]; then
    sleep 10
    bash /usr/local/bin/swizzin/nginx/radarr.sh
    systemctl reload nginx
  fi
}

function _installRadarrFinish() {
  # output to dashboard
  echo "¡Instalación de radarr completada!" >>"${OUTTO}" 2>&1;
  echo "Puedes acceder en  : http://$ip/radarr" >>"${OUTTO}" 2>&1;
  echo >>"${OUTTO}" 2>&1;
  echo >>"${OUTTO}" 2>&1;
  echo "Close this dialog box to refresh your browser" >>"${OUTTO}" 2>&1;
  # output to box
  echo "¡Instalación de radarr completada!"
  echo "Puedes acceder en  : http://$ip/radarr"
  echo
  echo "Cierra para refrescar el navegador."
}

function _installRadarrExit() {
	exit 0
}

if [[ -f /tmp/.install.lock ]]; then
  OUTTO="/root/logs/install.log"
elif [[ -f /install/.panel.lock ]]; then
  OUTTO="/srv/panel/db/output.log"
else
  OUTTO="/root/logs/swizzin.log"
fi
username=$(cut -d: -f1 < /root/.master.info)
distribution=$(lsb_release -is)
version=$(lsb_release -cs)
. /etc/swizzin/sources/functions/mono
ip=$(curl -s http://whatismyip.akamai.com)

_installRadarrIntro
echo "Instalando dependencias ... " >>"${OUTTO}" 2>&1;_installRadarrDependencies
echo "Instalando Radar ... " >>"${OUTTO}" 2>&1;_installRadarrCode
echo "Configurando Radar ... " >>"${OUTTO}" 2>&1;_installRadarrConfigure
_installRadarrFinish
_installRadarrExit
