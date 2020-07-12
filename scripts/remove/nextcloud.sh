#!/bin/bash
# nextcloud uninstaller
#
#   SERVIDOR HD

echo -n -e "Introduce la contraseña root mysql para poder borrar la base de datos nextcloud y el usuario.\n"
read -s -p "Password: " 'password'
rm -rf /srv/nextcloud
rm /etc/nginx/apps/nextcloud.conf
systemctl reload nginx
host=$(mysql -u root --password="$password" --execute="select host from mysql.user where user = 'nextcloud';" | grep -E "localhost|127.0.0.1")
mysql --user="root" --password="$password" --execute="DROP DATABASE nextcloud;"
mysql --user="root" --password="$password" --execute="DROP USER nextcloud@$host;"
rm /install/.nextcloud.lock
