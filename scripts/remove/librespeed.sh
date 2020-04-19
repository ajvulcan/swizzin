#!/bin/bash
# Desinstalador de Librespeed para Servidor HD
# Author: hwcltjn
#
function _removeLibreSpeed() {
  sudo rm -r /srv/librespeed
  sudo rm /etc/nginx/apps/librespeed.conf
  sudo rm /install/.librespeed.lock
  service nginx reload
}

_removeLibreSpeed 