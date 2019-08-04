#!/bin/bash
# Guard yer wires with wireguard vpn
# Author: liara
# Servidor HD Copyright (C) 2019
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
  OUTTO="/dev/null"
fi
distribution=$(lsb_release -is)
ip=$(ip route get 1 | sed -n 's/^.*src \([0-9.]*\) .*$/\1/p')
u=$(cut -d: -f1 < /root/.master.info)
IFACE=($(ip link show|grep -i broadcast|grep -m1 UP |cut -d: -f 2|cut -d@ -f 1|sed -e 's/ //g'))
MASTER=$(ip link show|grep -i broadcast|grep -e MASTER |cut -d: -f 2|cut -d@ -f 1|sed -e 's/ //g')

if [[ -n $MASTER ]]; then
  iface=$MASTER
else
  iface=${IFACE[0]}
fi

function _selectiface () {
  echo "Por favor, selecciona el interfaz correcto de la lista siguiente:"
  select seliface in "${IFACE[@]}"; do
    case $seliface in
      *) iface=$seliface; break;;
    esac
  done
  echo "Tu interfaz se ha establecido como $iface"
}

echo "El instalador ha detectado que $iface es tu interfaz principal, ¿es correcto?"
  select yn in "yes" "no"; do
    case $yn in
        yes ) break;;
        no ) _selectiface; break;;
    esac
done

echo "Perfecto. Espera un poco a que Wireguard se instale ..."

if [[ $distribution == "Debian" ]]; then
    echo "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable.list
    printf 'Package: *\nPin: release a=unstable\nPin-Priority: 150\n\nPackage: *\nPin: release a=stretch-backports\nPin-Priority: 250' > /etc/apt/preferences.d/limit-unstable
elif [[ $distribution == "Ubuntu" ]]; then
    add-apt-repository -y ppa:wireguard/wireguard >> $OUTTO 2>&1
fi

#Instala los headers del kernel actual necesarios y wireguard.
apt-get -q update >> $OUTTO 2>&1
apt-get install linux-headers-$(uname -r)
apt-get -y install wireguard qrencode >> $OUTTO 2>&1


if [[ ! -d /etc/wireguard ]]; then
    mkdir /etc/wireguard
fi

mkdir -p /home/$u/.wireguard/{server,client}

cd /home/$u/.wireguard/server
wg genkey | tee wg$(id -u $u).key | wg pubkey > wg$(id -u $u).pub

cd /home/$u/.wireguard/client
wg genkey | tee $u.key | wg pubkey > $u.pub

chown $u: /home/$u/.wireguard
chmod -R 700 /home/$u/.wireguard

serverpriv=$(cat /home/$u/.wireguard/server/wg$(id -u $u).key)
serverpub=$(cat /home/$u/.wireguard/server/wg$(id -u $u).pub)
peerpriv=$(cat /home/$u/.wireguard/client/$u.key)
peerpub=$(cat /home/$u/.wireguard/client/$u.pub)

net=$(id -u $u | cut -c 1-3)
sub=$(id -u $u | rev | cut -c 1 | rev)
subnet=10.$net.$sub.

cat > /etc/wireguard/wg$(id -u $u).conf <<EOWGS
[Interface]
Address = ${subnet}1
SaveConfig = true
PostUp = iptables -A FORWARD -i wg$(id -u $u) -j ACCEPT; iptables -A FORWARD -i wg$(id -u $u) -o $iface -m state --state RELATED,ESTABLISHED -j ACCEPT; iptables -A FORWARD -i $iface -o wg$(id -u $u) -m state --state RELATED,ESTABLISHED -j ACCEPT; iptables -t nat -A POSTROUTING -o $iface -s ${subnet}0/24 -j SNAT --to-source $ip
PostDown = iptables -D FORWARD -i wg$(id -u $u) -j ACCEPT; iptables -D FORWARD -i wg$(id -u $u) -o $iface -m state --state RELATED,ESTABLISHED -j ACCEPT; iptables -D FORWARD -i $iface -o wg$(id -u $u) -m state --state RELATED,ESTABLISHED -j ACCEPT; iptables -t nat -A POSTROUTING -o $iface -s ${subnet}0/24 -j SNAT --to-source $ip
ListenPort = 5$(id -u $u)
PrivateKey = $serverpriv

[Peer]
PublicKey = $peerpub
AllowedIPs = ${subnet}2/32
EOWGS


#[Interface]
#Address = ${subnet}1
#PrivateKey = $serverpriv
#ListenPort = 5$(id -u $u)

#[Peer]
#PublicKey = $peerpub
#AllowedIPs = ${subnet}2/32

cat > /home/$u/.wireguard/$u.conf << EOWGC
[Interface]
Address = ${subnet}2/24
PrivateKey = $peerpriv
ListenPort = 21841
# The DNS value may be changed if you have a personal preference
DNS = 1.1.1.1
# Uncomment this line if you are having issues with DNS leak
#BlockDNS = true


[Peer]
PublicKey = $serverpub
Endpoint = $ip:5$(id -u $u)
AllowedIPs = 0.0.0.0/0

# This is for if you're behind a NAT and
# want the connection to be kept alive.
#PersistentKeepalive = 25
EOWGC

chown -R root:root /etc/wireguard/
chmod 700 /etc/wireguard
sudo chmod -R og-rwx /etc/wireguard/*
echo ""
modprobe wireguard
systemctl daemon-reload
systemctl enable --now wg-quick@wg$(id -u $u)
systemctl start wg-quick@wg$(id -u $u)

echo "Wireguard se ha habilitado (wg$(id -u $u)). Tu configuración de cliente es:"
echo ""
cat /home/$u/.wireguard/$u.conf

echo ""
echo "Puedes acceder a esta configuración en cualquier momento en ~/.wireguard/$u.conf"
echo ""
echo "Puedes generar un código QR para configurar tu VPN en dispositivos móviles con este comando:"
echo "qrencode -t ansiutf8 < ~/.wireguard/$u.conf"

echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

sysctl -p > /dev/null 2>&1

touch /install/.wireguard.lock