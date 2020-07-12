#!/bin/bash
#
# [Servidor HD :: Install Rapidleech package]
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
#

if [[ ! -f /install/.nginx.lock ]]; then
  echo "ERROR:servidor web no detectado. Instala nginx y reinicia el panel, por favor."
  exit 1
fi
MASTER=$(cut -d: -f1 < /root/.master.info)
if [[ -f /tmp/.install.lock ]]; then
  OUTTO="/root/logs/install.log"
elif [[ -f /install/.panel.lock ]]; then
  OUTTO="/srv/panel/db/output.log"
else
  OUTTO="/root/logs/swizzin.log"
fi
function _installRapidleech1() {
  sudo git clone https://github.com/Th3-822/rapidleech.git  /home/"${MASTER}"/rapidleech >/dev/null 2>&1
}
function _installRapidleech2() {
  touch /install/.rapidleech.lock
  chown "${MASTER}":"${MASTER}" -R /home/"${MASTER}"/rapidleech
}
function _installRapidleech3() {
  if [[ -f /install/.nginx.lock ]]; then
    bash /usr/local/bin/swizzin/nginx/rapidleech.sh
    systemctl reload nginx
  fi
}
function _installRapidleech4() {
  systemctl reload nginx
}
function _installRapidleech5() {
    echo "¡Instalación de rapidleech completada!" >>"${OUTTO}" 2>&1;
    sleep 5
    echo >>"${OUTTO}" 2>&1;
    echo >>"${OUTTO}" 2>&1;
    echo "Cierra para refrescar el navegador" >>"${OUTTO}" 2>&1;
    systemctl reload nginx
}
function _installRapidleech6() {
    exit
}

echo "Instalando rapidleech ... " >>"${OUTTO}" 2>&1;_installRapidleech1
echo "Consigurando permisos de rapidleech ... " >>"${OUTTO}" 2>&1;_installRapidleech2
echo "Configurando servidor web para rapidleech ... " >>"${OUTTO}" 2>&1;_installRapidleech3
echo "Recargando servidor web ... " >>"${OUTTO}" 2>&1;_installRapidleech4
_installRapidleech5
_installRapidleech6
