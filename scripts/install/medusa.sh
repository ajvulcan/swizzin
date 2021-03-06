#! /bin/bash
# Medusa installer for servidor HD
# by ajvulcan

if [[ -f /tmp/.install.lock ]]; then
  log="/root/logs/install.log"
elif [[ -f /install/.panel.lock ]]; then
  log="/srv/panel/db/output.log"
else
  log="/root/logs/swizzin.log"
fi
user=$(cut -d: -f1 < /root/.master.info)
. /etc/swizzin/sources/functions/utils

if [[ $(systemctl is-active sickgear) == "active" ]]; then
  active=sickgear
fi

if [[ $(systemctl is-active sickchill) == "active" ]]; then
  active=sickchill
fi

if [[ -n $active ]]; then
  echo "SickChill, Medusa y Sickgear no pueden funcionar al mismo tiempo."
  echo "¿Quieres desabilitar $active y continuar con la instalación?"
  echo "No te preocupes, tu instalación permanecerá en /opt/$active"
  while true; do
  read -p "¿Quieres deshabilitar $active? " yn
      case "$yn" in
          [Yy]|[Yy][Ee][Ss]) disable=yes; break;;
          [Nn]|[Nn][Oo]) disable=; break;;
          *) echo "Por favir, responde (s)i o (n)o.";;
      esac
  done
  if [[ $disable == "yes" ]]; then
    systemctl disable --now ${active}
  else
    exit 1
  fi
fi

mkdir -p /opt/.venv
chown ${user}: /opt/.venv

apt-get -y -q update >> $log 2>&1
apt-get -y -q install git-core openssl libssl-dev python3 python3-venv >> $log 2>&1
python3 -m venv /opt/.venv/medusa

chown -R ${user}: /opt/.venv/medusa

install_rar

cd /opt/
git clone https://github.com/pymedusa/Medusa.git medusa >> ${log} 2>&1
chown -R ${user}:${user} medusa

cat > /etc/systemd/system/medusa.service <<MSD
[Unit]
Description=Medusa
After=syslog.target network.target

[Service]
Type=forking
GuessMainPID=no
User=${user}
Group=${user}
ExecStart=/opt/.venv/medusa/bin/python3 /opt/medusa/SickBeard.py -q --daemon --nolaunch --datadir=/opt/medusa
ExecStop=-/bin/kill -HUP

[Install]
WantedBy=multi-user.target
MSD

systemctl enable --now medusa >>$log 2>&1

if [[ -f /install/.nginx.lock ]]; then
  bash /usr/local/bin/swizzin/nginx/medusa.sh
  systemctl reload nginx
fi

touch /install/.medusa.lock
