#!/bin/bash
# Node update check
# author: liara
# mod: ajvulcan
#
#   SERVIDOR HD

if [[ -f /etc/apt/sources.list.d/nodesource.list ]]; then
  if ! grep -q 10 /etc/apt/sources.list.d/nodesource.list; then
    echo "Actualizando nodejs a versión 10 LTS"
    sed -iE 's/[0-9]+/10/g' nodesource.list
    apt -y -q  update > /dev/null 2>&1
    apt -y -q upgrade > /dev/null 2>&1
  fi
fi