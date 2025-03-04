#!/bin/bash
# rTorrent installer
# by ajvulcan
# -- Servidor HD --
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#
function _string() { perl -le 'print map {(a..z,A..Z,0..9)[rand 62] } 0..pop' 15 ; }

function _rconf() {
cat >/home/${user}/.rtorrent.rc<<EOF
# -- START HERE --
directory.default.set = /home/${user}/DESCARGAS
encoding.add = UTF-8
encryption = allow_incoming,try_outgoing,enable_retry
execute.nothrow = chmod,777,/home/${user}/.config/rpc.socket
execute.nothrow = chmod,777,/home/${user}/.sessions
network.port_random.set = yes
network.port_range.set = $port-$portend
network.scgi.open_local = /var/run/${user}/.rtorrent.sock
schedule2 = chmod_scgi_socket, 0, 0, "execute2=chmod,\"g+w,o=\",/var/run/${user}/.rtorrent.sock"
network.tos.set = throughput
pieces.hash.on_completion.set = no
protocol.pex.set = no
schedule = watch_directory,5,5,load.start=/home/${user}/rwatch/*.torrent
session.path.set = /home/${user}/.sessions/
throttle.global_down.max_rate.set = 0
throttle.global_up.max_rate.set = 0
throttle.max_peers.normal.set = 100
throttle.max_peers.seed.set = -1
throttle.max_uploads.global.set = 100
throttle.min_peers.normal.set = 1
throttle.min_peers.seed.set = -1
trackers.use_udp.set = yes

#otros
dht.mode.set = disable
#pieces.memory.max.set = 8000M

# Preallocate files; reduces defragmentation on filesystems.
system.file.allocate.set = yes

#Cambio de permisos.
method.set_key = event.download.finished,change_permission,"execute=chmod,-R,g-rwx,$d.get_base_path="

execute = {sh,-c,/usr/bin/php /srv/rutorrent/php/initplugins.php ${user} &}

# -- END HERE --
EOF

chown ${user}.${user} -R /home/${user}/.rtorrent.rc
chmod 444 /home/${user}/.rtorrent.rc

}

#Directorios usados por rtorrent
function _makedirs() {
	mkdir -p /home/${user}/DESCARGAS 2>> $log
	mkdir -p /home/${user}/.sessions
	mkdir -p /home/${user}/rwatch
	chown -R ${user}.${user} /home/${user}/{.sessions,rwatch} 2>> $log
	usermod -a -G www-data ${user} 2>> $log
	usermod -a -G ${user} www-data 2>> $log
}

#Servicio de rtorrent
_systemd() {
cat >/etc/systemd/system/rtorrent@.service<<EOF
[Unit]
Description=rTorrent
After=network.target

[Service]
Type=forking
KillMode=none
User=%i
ExecStartPre=-/bin/rm -f /home/%i/.sessions/rtorrent.lock
ExecStart=/usr/bin/screen -d -m -fa -S rtorrent /usr/bin/rtorrent
ExecStop=/usr/bin/screen -X -S rtorrent quit
WorkingDirectory=/home/%i/
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl enable -q --now rtorrent@${user} 2>> $log
}

export DEBIAN_FRONTEND=noninteractive

if [[ -f /tmp/.install.lock ]]; then
  export log="/root/logs/install.log"
else
  log="/root/logs/swizzin.log"
fi
. /etc/swizzin/sources/functions/rtorrent
noexec=$(grep "/tmp" /etc/fstab | grep noexec)
user=$(cut -d: -f1 < /root/.master.info)
rutorrent="/srv/rutorrent/"
port=$((RANDOM%64025+1024))
portend=$((${port} + 1500))

if [[ -n $1 ]]; then
	user=$1
	_makedirs
	_rconf
	exit 0
fi

whiptail_rtorrent

if [[ -n $noexec ]]; then
	mount -o remount,exec /tmp
	noexec=1
fi

echo "Instalando dependencias de rTorrent ... ";depends_rtorrent

		if [[ ! $rtorrentver == repo ]]; then
			echo "Compilando xmlrpc-c desde fuente ...";build_xmlrpc-c
			echo "Compilando libtorrent desde fuente ... ";build_libtorrent_rakshasa
			echo "Compilando rtorrent desde fuente ... ";build_rtorrent
		else
			echo "Instalando rtorrent con apt-get ... ";rtorrent_apt
		fi		
		#echo "Compilando rtorrent desde fuente ... ";build_rtorrent
		echo "Montando estructura de directorios de ${user} ... ";_makedirs
		echo "Configurando rtorrent.rc ... ";_rconf;_systemd

if [[ -n $noexec ]]; then
	mount -o remount,noexec /tmp
fi
		touch /install/.rtorrent.lock
