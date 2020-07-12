#!/bin/bash
<<<<<<< HEAD
# Desinstalador de Librespeed para Servidor HD
# Author: hwcltjn
#
=======
#
#   Desinstalador de librespeed
#
#   SERVIDOR HD
#

>>>>>>> master
function _removeLibreSpeed() {
  sudo rm -r /srv/librespeed
  sudo rm /etc/nginx/apps/librespeed.conf
  sudo rm /install/.librespeed.lock
<<<<<<< HEAD
  service nginx reload
}

_removeLibreSpeed 
=======
  systemctl reload nginx
}

_removeLibreSpeed
>>>>>>> master
