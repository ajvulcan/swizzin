#!/bin/bash
# rtorrent upgrade/downgrade/reinstall script
#
#	SERVIDOR HD

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

user=$(cut -d: -f1 < /root/.master.info)
rutorrent="/srv/rutorrent/"
users=($(cut -d: -f1 < /etc/htpasswd))

for u in "${users[@]}"; do
  systemctl stop rtorrent@${u}
done

if [[ -n $noexec ]]; then
	mount -o remount,exec /tmp
	noexec=1
fi

isdeb=$(dpkg -l | grep rtorrent)
echo "Borrando binarios y librerias viejas de rTorrent ...";

if [[ -z $isdeb ]]; then
	remove_rtorrent_legacy
else
  	remove_rtorrent
fi
	echo "Comprobar dependencias rTorrent ... ";depends_rtorrent
	if [[ ! $rtorrentver == repo ]]; then
 	  echo "Compilando xmlrpc-c desde la fuente ...  ";build_xmlrpc-c
 	  echo "Compilando libtorrent desde la fuente ... ";build_libtorrent_rakshasa
	  echo "Compilando rtorrent desde la fuente ... ";build_rtorrent
	else
  	  echo "Installing rtorrent with apt-get ... ";rtorrent_apt
	fi
	
if [[ -n $noexec ]]; then
	mount -o remount,noexec /tmp
fi

for u in "${users[@]}"; do
	if grep -q localhost /home/$u/.rtorrent.rc; then sed -i 's/localhost/127.0.0.1/g' /home/$u/.rtorrent.rc; fi
  systemctl start rtorrent@${u}
done
