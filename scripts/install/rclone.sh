#!/bin/bash
#
# [Servidor HD :: Install rclone]
#
# by Ajvulcan
#
#  -- Servidor HD --
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.

if [[ -f /tmp/.install.lock ]]; then
  OUTTO="/root/logs/install.log"
elif [[ -f /install/.panel.lock ]]; then
  OUTTO="/srv/panel/db/output.log"
else
  OUTTO="/root/logs/swizzin.log"
fi
MASTER=$(cut -d: -f1 < /root/.master.info)

echo "Descargando e instalando rclone ..." >>"${OUTTO}" 2>&1;

#necesitamos la librería de fuse
apt-get -y update >> $OUTTO 2>&1
apt-get -y install fuse >> $OUTTO 2>&1

# Comprueba sistema operativo y descarga el último rclone para el mismo.
curl https://rclone.org/install.sh | sudo bash

# Asegurarse que descarga e instala sin error antes de proceder.
if [ $? -eq 0 ]; then
    echo "Añadiendo servicio de montaje de rclone..." >>"${OUTTO}" 2>&1;

cat >/etc/systemd/system/rclone@.service<<EOF
[Unit]
Description=rclonemount
After=network.target

[Service]
Type=simple
User=%i
Group=%i
ExecStartPre=/bin/mkdir -p /home/%i/NUBE/GDRIVE
ExecStart=/usr/bin/rclone mount --allow-other %i: /home/%i/NUBE/GDRIVE
ExecStop=/bin/fusermount -u /home/%i/NUBE/GDRIVE
ExecStop=/bin/rmdir /home/%i/NUBE/GDRIVE
Restart=on-failure
RestartSec=30
StartLimitInterval=60s
StartLimitBurst=3

[Install]
WantedBy=multi-user.target

EOF

cat > /etc/fuse.conf<<EOF2
# /etc/fuse.conf - Configuration file for Filesystem in Userspace (FUSE)

# Set the maximum number of FUSE mounts allowed to non-root users.
# The default is 1000.
#mount_max = 1000

# Allow non-root users to specify the allow_other or allow_root mount options.
user_allow_other
EOF2

    touch /install/.rclone.lock

    echo "rclone instalación completa!" >>"${OUTTO}" 2>&1;
else
    echo "Un error ha ocurrido durante la instalación de rclone." >>"${OUTTO}" 2>&1;
fi
echo >>"${OUTTO}" 2>&1;
echo >>"${OUTTO}" 2>&1;
echo "Cierra esta ventana de diálogo para actualizar tu navegador" >>"${OUTTO}" 2>&1;

echo "Recuerda, para ejecutar rclone debes adaptar tu circustancia al servicio (mismo nombre en configuración que de usuario)"
echo "... o modificar el servicio que se encuentra en: /etc/systemd/system/rclone@.service"
echo "Después inicialo con systemctl enable rclone@usuario, ejecutalo cambiando el enable por start y acuérdate de correr systemctl daemon-reload"