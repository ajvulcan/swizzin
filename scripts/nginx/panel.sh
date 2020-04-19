#!/bin/bash
# Servidor HD dashboard installer for Swizzin
#
echo "HOST = '127.0.0.1'" >> /opt/swizzin/swizzin/swizzin.cfg

cat > /etc/nginx/apps/panel.conf <<'EON'
location / {
 #rewrite ^/panel/(.*) /$1 break;
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Host $host;
  proxy_set_header X-Forwarded-Proto $scheme;
  proxy_set_header Origin "";
  proxy_pass http://127.0.0.1:8333;
  proxy_http_version 1.1;
  proxy_set_header Upgrade $http_upgrade;
  proxy_set_header Connection "Upgrade";
}

EON