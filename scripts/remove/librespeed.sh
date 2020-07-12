#!/bin/bash
#
#   Desinstalador de librespeed
#
#   SERVIDOR HD
#

function _removeLibreSpeed() {
  sudo rm -r /srv/librespeed
  sudo rm /etc/nginx/apps/librespeed.conf
  sudo rm /install/.librespeed.lock
  systemctl reload nginx
}

_removeLibreSpeed