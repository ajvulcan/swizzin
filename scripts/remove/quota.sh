#!/bin/bash
#
# [Servidor HD :: Remove quotas]
#
#################################################################################
username=$(cut -d: -f1 < /root/.master.info)

sed -i 's/,usrjquota=aquota.user,jqfmt=vfsv1//g' /etc/fstab
apt-get remove -y -q quota >/dev/null 2>&1
rm /etc/sudoers.d/quota
rm /install/.quota.lock
