#!/bin/bash
# Temporary upgrade script for the panel until panel becomes more self-sufficient

if [[ -f /install/.panel.lock ]]; then
  if ! dpkg -s acl > /dev/null 2>&1; then
    echo "Modificando ACLs para el grupo swizzin para prevenir problemas con panel..."
    apt-get -y -q install acl
    setfacl -m g:swizzin:rx /home/*
  fi 

  cd /opt/swizzin/swizzin
  
  #git reset HEAD --hard
  echo "Haciendo pull de nuevos commits"
  
  git pull 2> /dev/null || { PANELRESET=1; }
  
  if [[ $PANELRESET == 1 ]]; then
    echo "Working around unclean git repo"
    git fetch origin master
    cp -a core/custom core/custom.tmp
    echo "Reseteando el repositorio de git"
    git reset --hard origin/master
    mv core/custom.tmp/* core/custom/
    rm -r core/custom.tmp
  fi
  
  echo "Reiniciando el panel"
  systemctl restart panel
  echo "¡Hecho!"
fi 