#!/bin/bash
# rtorrent upgrade/downgrade/reinstall script

if [[ ! -f /install/.rtorrent.lock ]]; then
  echo "rTorrent no está instalado."
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

if [[ -f /tmp/.install.lock ]]; then
  export log="/root/logs/install.log"
else
  export log="/dev/null"
fi
. /etc/swizzin/sources/functions/rtorrent
whiptail_rtorrent

user=$(cat /root/.master.info | cut -d: -f1)
rutorrent="/srv/rutorrent/"
users=($(cat /etc/htpasswd | cut -d ":" -f 1))

for u in "${users[@]}"; do
  systemctl stop rtorrent@${u}
done

if [[ -n $noexec ]]; then
	mount -o remount,exec /tmp
	noexec=1
fi

isdeb=$(dpkg -l | grep rtorrent)
if [[ -z $isdeb ]]; then
	echo "Borrando binarios y librerias viejas de rTorrent ... ";remove_rtorrent_legacy
fi
	echo "Comprobar dependencias rTorrent ... ";depends_rtorrent
	echo "Compilando xmlrpc-c desde la fuente ... ";build_xmlrpc-c
	echo "Compilando libtorrent desde la fuente ... ";build_libtorrent_rakshasa
	echo "Compilando rtorrent desde la fuente ... ";build_rtorrent
  
if [[ -n $noexec ]]; then
	mount -o remount,noexec /tmp
fi

for u in "${users[@]}"; do
	if grep -q localhost /home/$u/.rtorrent.rc; then sed -i 's/localhost/127.0.0.1/g' /home/$u/.rtorrent.rc; fi
  systemctl start rtorrent@${u}
done
