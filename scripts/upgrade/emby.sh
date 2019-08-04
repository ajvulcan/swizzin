#!/bin/bash
# Simple tool to grab the latest release of emby
#
# SERVIDOR HD

current=$(curl -L -s -H 'Accept: application/json' https://github.com/MediaBrowser/Emby.Releases/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
cd /tmp
wget -q -O emby.dpkg https://github.com/MediaBrowser/Emby.Releases/releases/download/${current}/emby-server-deb_${current}_amd64.deb
#dpkg -i emby.dpkg >> /dev/null 2>&1
dpkg -i emby.dpkg
rm emby.dpkg

#Cambio de usuario de emby para los permisos.
username=$(cat /root/.master.info | cut -d: -f1)
echo '...'
sleep 15
echo "cambiando usuario emby a "${username}" "
echo ${username}
systemctl disable emby-server --now
chown -R $username:$username /var/lib/emby
systemctl enable emby-server@$username --now
systemctl restart emby-server@$username

#username=$(cat /root/.master.info | cut -d: -f1)
#echo 'starting...'
#sleep 10
#echo "emby user changing to "${username}" "
#systemctl disable emby-server --now
#echo 'emby service disabled...'
#sleep 5
#chown -R $username:$username /var/lib/emby
#echo 'permissions changed'
#systemctl enable emby-server@$username --now
#echo 'service started'

#echo 'Stopping emby service...'
#service emby-server stop
#echo 'change emby username'
#username=$(cat /root/.master.info | cut -d: -f1)
#sed -i 's/.*setuid.*/setuid '$username'/' /etc/init/emby-server.conf
#chown -R $username:$username /var/lib/emby
#echo 'permissions changed'
#service emby-server start
#echo 'service started...'

#apt-get install acl
#setfacl -m user:emby:rx /home/<usuario>
