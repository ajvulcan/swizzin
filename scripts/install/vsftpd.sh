#!/bin/bash
# vsftpd installer for Servidor HD
# by ajvulcan
#
# SERVIDOR HD
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#
if [[ -f /tmp/.install.lock ]]; then
  log="/root/logs/install.log"
else
  log="/root/logs/swizzin.log"
fi

. /etc/swizzin/sources/functions/letsencrypt

apt-get -y update >> $log 2>&1
apt-get -y install vsftpd ssl-cert>> $log 2>&1

user=$(cat /root/.master.info | cut -d: -f1)

cat > /etc/vsftpd.chroot_list <<VSCHROOT
${user}
VSCHROOT

cat > /etc/vsftpd.conf <<VSC
listen=NO
listen_ipv6=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
force_dot_files=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
utf8_filesystem=YES
require_ssl_reuse=NO
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
ssl_enable=YES
pam_service_name=vsftpd
secure_chroot_dir=/var/run/vsftpd/empty

#ascii_upload_enable=YES
#ascii_download_enable=YES
ftpd_banner=Bienvenido al servicio FTP.

#############################################
#Uncomment these lines to enable FXP support#
#############################################
#pasv_promiscuous=YES
#port_promiscuous=YES

###################
#Set a custom port#
###################
listen_port=990

#Enjaular
chroot_local_user=YES
chroot_list_enable=YES
# (default follows)
chroot_list_file=/etc/vsftpd.chroot_list

#Otros
ssl_ciphers=HIGH
hide_ids=YES
allow_writeable_chroot=YES

#PARA MONITORIZAR
setproctitle_enable=YES

VSC

# Check for LE cert, and copy it if available.
le_vsftpd_hook

systemctl restart vsftpd

touch /install/.vsftpd.lock
