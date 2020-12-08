#!/bin/bash
#
# Nginx configuration for LibreSpeed
#
# SERVIDOR HD

if [[ ! -f /etc/nginx/apps/librespeed.conf ]]; then
	cat > /etc/nginx/apps/librespeed.conf <<RAP
location /librespeed {
  alias /srv/librespeed;
  client_max_body_size 50M;
  client_body_buffer_size 128k;

  auth_basic "What's the password?";
  auth_basic_user_file /etc/htpasswd;
}
RAP
fi
