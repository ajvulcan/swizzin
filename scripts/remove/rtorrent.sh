#!/bin/bash
#
# servidor HD
#
users=($(cut -d: -f1 < /etc/htpasswd))

export log=/dev/null
read -n 1 -s -r -p "Esto borrara rTorrent y todos los interfaces asociados (ruTorrent/Flood). Presiona una tecla para continuar."
printf "\n"

for u in ${users}; do
  systemctl disable rtorrent@${u}
  systemctl stop rtorrent@${u}
  rm -f /home/${u}/.rtorrent.rc
done

. /etc/swizzin/sources/functions/rtorrent
isdeb=$(dpkg -l | grep rtorrent)
echo "Borrando antiguos binarios de rTorrent y librerías ... ";
if [[ -z $isdeb ]]; then
	remove_rtorrent_legacy
else
  remove_rtorrent
fi

#apt-get -y remove mktorrent mediainfo
for a in rutorrent flood; do
  if [[ -f /install/.$a.lock ]]; then
    /usr/local/bin/swizzin/remove/$a.sh
  fi
done
rm /etc/systemd/system/rtorrent@.service
rm /install/.rtorrent.lock