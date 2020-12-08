#! /bin/bash
# Webmin nginx installer
# by ajvulcan for SERVIDOR HD

MASTER=$(cut -d: -f1 < /root/.master.info)

echo -e "Introduce el nombre de dominio a vincular"
read -e hostname

if [[ ! -f /etc/nginx/apps/webmin.conf ]]; then

cat > /etc/nginx/apps/webmin.conf <<WEBC
location /webmin/ {
    include /etc/nginx/snippets/proxy.conf;
    # Tell nginx that we want to proxy everything here to the local webmin server
    # Last slash is important
    proxy_pass https://127.0.0.1:10000/;
    proxy_redirect https://${hostname} /webmin;
    proxy_set_header Host ${hostname}:10000;
    auth_basic "What's the password?";
    auth_basic_user_file /etc/htpasswd.d/htpasswd.${MASTER};
}
WEBC
fi

#referers=${referers}

cat >> /etc/webmin/config << EOF
webprefix=/webmin
webprefixnoredir=1
referers=${hostname}
no_frame_options=1
EOF

cat >> /etc/webmin/miniserv.conf << EOF
bind=127.0.0.1
sockets=
EOF

systemctl reload webmin
systemctl reload nginx 
