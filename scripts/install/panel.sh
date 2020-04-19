#!/bin/bash
# Servidor HD Dashboard
#
if [[ -f /tmp/.install.lock ]]; then
  log="/root/logs/install.log"
else
  log="/root/logs/swizzin.log"
fi

if [[ ! -f /install/.nginx.lock ]]; then
  echo "¡Este paquete requiere nginx para su instalación!"
  read -p "Presiona la tecla enter para proceder con la instalación de nginx antes de la de panel."
  bash /usr/local/bin/swizzin/install/nginx.sh
fi

master=$(cut -d: -f1 < /root/.master.info)

apt-get -y -q install python3-venv git acl > /dev/null 2>&1
mkdir -p /opt/swizzin/
python3 -m venv /opt/swizzin/venv
git clone https://github.com/ajvulcan/swizzin_dashboard.git /opt/swizzin/swizzin >> ${log} 2>&1
/opt/swizzin/venv/bin/pip install -r /opt/swizzin/swizzin/requirements.txt >> ${log} 2>&1
useradd -r swizzin > /dev/null 2>&1
chown -R swizzin: /opt/swizzin
setfacl -m g:swizzin:rx /home/*
mkdir -p /etc/nginx/apps

if [[ -f /install/.deluge.lock ]]; then
  touch /install/.delugeweb.lock
fi

if [[ $master == $(id -nu 1000) ]]; then
  :
else
  echo "ADMIN_USER = '$master'" >> /opt/swizzin/swizzin/swizzin.cfg
fi

if [[ -f /install/.nginx.lock ]]; then
  bash /usr/local/bin/swizzin/nginx/panel.sh
  systemctl reload nginx
fi

cat > /etc/systemd/system/panel.service <<EOS
[Unit]
Description=Servidor HD panel service
After=nginx.service
[Service]
Type=simple
User=swizzin
ExecStart=/opt/swizzin/venv/bin/python swizzin.py
WorkingDirectory=/opt/swizzin/swizzin
Restart=on-failure
TimeoutStopSec=300
[Install]
WantedBy=multi-user.target
EOS

cat > /etc/sudoers.d/panel <<EOSUD
#Defaults  env_keep -="HOME"
Defaults:swizzin !logfile
Defaults:swizzin !syslog
Defaults:swizzin !pam_session
Cmnd_Alias   CMNDS = /usr/bin/quota, /bin/systemctl
swizzin     ALL = (ALL) NOPASSWD: CMNDS
EOSUD

systemctl enable --now panel > ${log} 2>&1

touch /install/.panel.lock
