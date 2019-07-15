#!/bin/bash
# Nginx configuration for Shell in a Box
# Author: liara
# Copyright (C) 2017 Swizzin
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
MASTER=$(cat /root/.master.info | cut -d: -f1)
isactive=$(systemctl is-active shellinabox)
if [[ ! -f /etc/nginx/apps/shell.conf ]]; then
  cat > /etc/nginx/apps/shell.conf <<RAD
location /shell/ {
  include /etc/nginx/snippets/proxy.conf;
  proxy_pass        http://127.0.0.1:4200;
  auth_basic "What's the password?";
  auth_basic_user_file /etc/htpasswd.d/htpasswd.${MASTER};
}
RAD
fi
if [[ -z $(grep disable-ssl /etc/default/shellinabox) ]]; then
    sed -i 's/SHELLINABOX_ARGS="/SHELLINABOX_ARGS="--disable-ssl /g' /etc/default/shellinabox
fi
if [[ -z $(grep localhost-only /etc/default/shellinabox) ]]; then
    sed -i 's/SHELLINABOX_ARGS="/SHELLINABOX_ARGS="--localhost-only /g' /etc/default/shellinabox
fi

if [[ -z $(grep 00+Green\ on\ Black.css /etc/default/shellinabox) ]]; then
    sed -i "s/SHELLINABOX_ARGS=\"/SHELLINABOX_ARGS=\"--css '\/etc\/shellinabox\/options-available\/00+Green\\ on\\ Black.css' /g" /etc/default/shellinabox
fi

#Fichero de tema verde sobre negro
cat > /etc/shellinabox/options-available/00+Green\ on\ Black.css <<EOF
#vt100 #cursor.bright {
  background-color: green;
  color: black;
}
#vt100 #scrollable {
  color: #0D9A00;
  background-color: #000000;
}
#vt100 #scrollable.inverted {
  color: #000000;
  background-color: #0D9A00;
}
#vt100 .ansi15 {
  color: #000000;
}
#vt100 .bgAnsi0 {
  background-color: #0D9A00;
}
#vt100 #cursor.dim {
  background-color: black;
  opacity:          0.2;
  -moz-opacity:     0.2;
  filter:           alpha(opacity=20);
}
#vt100 .ansiDef {
  color:            green;
}
#vt100 .ansiDefR {
  color:            #000000;
}
#vt100 .bgAnsiDef {
  background-color: #000000;
}
#vt100 .bgAnsiDefR {
  background-color: green;
}

#vt100 #scrollable.inverted .ansiDef {
  color:            #000000;
}

#vt100 #scrollable.inverted .ansiDefR {
  color:            green;
}

#vt100 #scrollable.inverted .bgAnsiDef {
  background-color: green;
}

#vt100 #scrollable.inverted .bgAnsiDefR {
  background-color: #000000;
}
EOF

systemctl reload nginx

if [[ $isactive == "active" ]]; then
  systemctl restart shellinabox
fi
