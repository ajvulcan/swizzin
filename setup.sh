#!/bin/bash
#################################################################################
# Installation script for servidor HD
# Many credits to QuickBox for the package repo
#
# Package installers copyright Servidor HD (2019) where applicable.
# All other work copyright Swizzin (2017)
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#
#################################################################################

time=$(date +"%s")

if [[ $EUID -ne 0 ]]; then
  echo "Servidor HD requiere que el usuario sea root. Haz su o sudo -s y vuelve a ejecutar ..."
  exit 1
fi

_os() {
  if [ ! -d /install ]; then mkdir /install ; fi
  if [ ! -d /root/logs ]; then mkdir /root/logs ; fi
  export log=/root/logs/install.log
  echo "Comprobando versión de sistema operativo ... "
  apt-get -y -qq update >> ${log} 2>&1
  apt-get -y -qq install lsb-release >> ${log} 2>&1
  distribution=$(lsb_release -is)
  release=$(lsb_release -rs)
  codename=$(lsb_release -cs)
    if [[ ! $distribution =~ ("Debian"|"Ubuntu") ]]; then
      echo "Tu distribución ($distribution) no es compatible. Servidor HD requires Ubuntu o Debian." && exit 1
    fi
    if [[ ! $codename =~ ("xenial"|"bionic"|"jessie"|"stretch"|"buster") ]]; then
      echo "Tu versión ($codename) de $distribution no es compatible." && exit 1
    fi
  echo "He detectado que estás usando: $distribution $release."
}

function _preparation() {
  echo "Actualizando sistema y dependencias."
  if [[ $distribution = "Ubuntu" ]]; then
    echo "Comprobando repositorios disponibles"
    if [[ -z $(which add-apt-repository) ]]; then
      apt-get install -y -q software-properties-common >> ${log} 2>&1
    fi
    add-apt-repository universe >> ${log} 2>&1
    add-apt-repository multiverse >> ${log} 2>&1
    add-apt-repository restricted -u >> ${log} 2>&1
  fi
  apt-get -q -y update >> ${log} 2>&1
  apt-get -q -y upgrade >> ${log} 2>&1
  apt-get -q -y install whiptail git sudo curl wget lsof fail2ban apache2-utils vnstat tcl tcl-dev build-essential dirmngr apt-transport-https python-pip nano iotop nload htop hdparm >> ${log} 2>&1
  nofile=$(grep "DefaultLimitNOFILE=500000" /etc/systemd/system.conf)
  if [[ ! "$nofile" ]]; then echo "DefaultLimitNOFILE=500000" >> /etc/systemd/system.conf; fi
  echo "Clonando Servidor HD al equipo ..."
  git clone https://github.com/ajvulcan/swizzin.git /etc/swizzin >> ${log} 2>&1
  ln -s /etc/swizzin/scripts/ /usr/local/bin/swizzin
  chmod -R 700 /etc/swizzin/scripts 
}

function _nukeovh() {
  grsec=$(uname -a | grep -i grs)
  if [[ -n $grsec ]]; then
    echo
    echo -e "Tu servidor está corriendo la siguiente versión de kernel: $(uname -r)"
    echo -e "Mientras no se requiera el cambio, kernels con grsec no están recomentados por conflictos con el panel y otros paquetes."
    echo
    echo -ne "¿Te gustaría que Servidor HD intalara una distribución del kernel? (Por defecto: Y) "; read input
      case $input in
        [yY] | [yY][Ee][Ss] | "" ) kernel=yes; echo "El nuevo kernel será instalado, se requerirá reiniciar."  ;;
        [nN] | [nN][Oo] ) echo "El instalador continuará. Si cambias de idea más adelante, ejecuta `box rmgrsec` después de la instalación." ;;
      *) kernel=yes; echo "El nuevo kernel será instalado, se requerirá reiniciar."  ;;
      esac
      if [[ $kernel == yes ]]; then
        if [[ $DISTRO == Ubuntu ]]; then
          apt-get install -q -y linux-image-generic >>"${OUTTO}" 2>&1
        elif [[ $DISTRO == Debian ]]; then
          arch=$(uname -m)
          if [[ $arch =~ ("i686"|"i386") ]]; then
            apt-get install -q -y linux-image-686 >>"${OUTTO}" 2>&1
          elif [[ $arch == x86_64 ]]; then
            apt-get install -q -y linux-image-amd64 >>"${OUTTO}" 2>&1
          fi
        fi
        mv /etc/grub.d/06_OVHkernel /etc/grub.d/25_OVHkernel
        update-grub >>"${OUTTO}" 2>&1
      fi
  fi
}

function _skel() {
  rm -rf /etc/skel
  cp -R /etc/swizzin/sources/skel /etc/skel
}

function _intro() {
  whiptail --title "Instalador de Servidor HD" --msgbox "¡Bienvenido!" 15 50
}

function _adduser() {
  while [[ -z $user ]]; do
    user=$(whiptail --inputbox "Introduce nombre de usuario" 9 30 3>&1 1>&2 2>&3); exitstatus=$?; if [ "$exitstatus" = 1 ]; then exit 0; fi
    if [[ $user =~ [A-Z] ]]; then
      read -n 1 -s -r -p "Los nombres de usuario no pueden contener mayúsculas. Pulsa enter para probar otra vez."
      printf "\n"
      user=
    fi
  done
  while [[ -z "${pass}" ]]; do
    pass=$(whiptail --inputbox "Introduce contraseña de usuario. Déjalo vacío para generar una." 9 30 3>&1 1>&2 2>&3); exitstatus=$?; if [ "$exitstatus" = 1 ]; then exit 0; fi
    if [[ -z "${pass}" ]]; then
      pass="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c16)"
    fi
    if [[ -n $(which cracklib-check) ]]; then 
      echo "Cracklib detectado. Comprobando la fortaleza de la contraseña."
      sleep 1
      str="$(cracklib-check <<<"$pass")"
      check=$(grep OK <<<"$str")
      if [[ -z $check ]]; then
        read -n 1 -s -r -p "La contraseña no ha pasado la comprobación de cracklib. Pulsa cualquier tecla para volver a introducir una."
        printf "\n"
        pass=
      else
        echo "OK."
      fi
    fi
  done
  echo "$user:$pass" > /root/.master.info
  if [[ -d /home/"$user" ]]; then
    echo "El directorio de usuario ya existe ... "
    #_skel
    #cd /etc/skel
    #cp -R * /home/$user/
    echo "Cambiando contraseña a una nueva"
    chpasswd<<<"${user}:${pass}"
    htpasswd -b -c /etc/htpasswd $user $pass
    mkdir -p /etc/htpasswd.d/
    htpasswd -b -c /etc/htpasswd.d/htpasswd.${user} $user $pass
    chown -R $user:$user /home/${user}
  else
    echo -e "Creando nuevo usuario \e[1;95m$user\e[0m ... "
    #_skel
    useradd "${user}" -m -G www-data -s /bin/bash
    chpasswd<<<"${user}:${pass}"
    htpasswd -b -c /etc/htpasswd $user $pass
    mkdir -p /etc/htpasswd.d/
    htpasswd -b -c /etc/htpasswd.d/htpasswd.${user} $user $pass
  fi

  if grep ${user} /etc/sudoers.d/swizzin >/dev/null 2>&1 ; then echo "Sin modificación a sudoers ... " ; else	echo "${user}	ALL=(ALL:ALL) ALL" >> /etc/sudoers.d/swizzin ; fi
  echo "D /var/run/${user} 0750 ${user} ${user} -" >> /etc/tmpfiles.d/${user}.conf
  systemd-tmpfiles /etc/tmpfiles.d/${user}.conf --create

  chmod 750 /home/${user}

  #añade usuario a lista emby
  htpasswd -b -c /etc/htpasswd.d/htpasswd.emby $user $pass
  echo "Añado el usuario ${user} a acceso emby (/etc/htpasswd.d/htpasswd.emby) "
  
  #añade al usuario al grupo sshuser
  groupadd sshuser
  adduser ${user} sshuser
  
  #Crea carpeta de descargas para usuario administrador
  mkdir /home/${user}/DESCARGAS
  chmod 777 /home/${user}/DESCARGAS
  chown $user:$user /home/${user}/DESCARGAS
  #Crea carpeta personal de admin
  mkdir /home/${user}/PERSONAL
  chmod 770 /home/${user}/PERSONAL
  chown $user:$user /home/${user}/PERSONAL
  echo "Carpetas de DESCARGA y PERSONAL creadas para el usuario ${user}"

  #Nube, para rclone o plexdrive
  mkdir /home/${user}/NUBE
  chmod 775 /home/${user}/NUBE
  chown $user:$user /home/${user}/NUBE
}

function _choices() {
  packages=()
  extras=()
  guis=()
  #locks=($(find /usr/local/bin/swizzin/install -type f -printf "%f\n" | cut -d "-" -f 2 | sort -d))
  locks=(nginx rtorrent deluge autodl panel vsftpd ffmpeg quota)
  for i in "${locks[@]}"; do
    app=${i}
    if [[ ! -f /install/.$app.lock ]]; then
      packages+=("$i" '""')
    fi
  done
  whiptail --title "Instalar Software" --checklist --noitem --separate-output "Elige programas y funcionalidades." 15 26 7 "${packages[@]}" 2>/root/results; exitstatus=$?; if [ "$exitstatus" = 1 ]; then exit 0; fi
  #readarray packages < /root/results
  results=/root/results

  if grep -q nginx "$results"; then
    if [[ -n $(pidof apache2) ]]; then
      if (whiptail --title "apache2 conflicto" --yesno --yes-button "¡Púrgalo!" --no-button "Deshabilitar" "ADVERTENCIA: El instalador ha detectado que apache2 está ya instalado. Para continuar el instalador debe o purgar apache 2 o deshabilitarlo." 8 78); then
        export apache2=purge
      else
        export apache2=disable
      fi
    fi
  fi
  if grep -q rtorrent "$results"; then
    gui=(rutorrent flood)
    for i in "${gui[@]}"; do
      app=${i}
      if [[ ! -f /install/.$app.lock ]]; then
        guis+=("$i" '""')
      fi
    done
    whiptail --title "rTorrent GUI" --checklist --noitem --separate-output "Opcional: Selecciona una interfaz para rtorrent" 15 26 7 "${guis[@]}" 2>/root/guis; exitstatus=$?; if [ "$exitstatus" = 1 ]; then exit 0; fi
    readarray guis < /root/guis
    for g in "${guis[@]}"; do
      g=$(echo $g)
      sed -i "/rtorrent/a $g" /root/results
    done
    rm -f /root/guis
    . /etc/swizzin/sources/functions/rtorrent
    whiptail_rtorrent
  fi
  if grep -q deluge "$results"; then
    . /etc/swizzin/sources/functions/deluge
    whiptail_deluge
  fi
  if [[ $(grep -s rutorrent "$gui") ]] && [[ ! $(grep -s nginx "$results") ]]; then
      if (whiptail --title "nginx conflicto" --yesno --yes-button "Instalar nginx" --no-button "Desinstalar ruTorrent" "ADVERTENCIA: se ha detectado que rutorrent va a ser instalado sin nginx, sin el servidor web no se puede mostrar una web, lógicamente. Para continuar se ha de instalar ngnix o quitar ruTorrent de la lista de instalaciones." 8 78); then
        sed -i '1s/^/nginx\n/' /root/results
        touch /tmp/.nginx.lock
      else
        sed -i '/rutorrent/d' /root/results
      fi
  fi

  while IFS= read -r result
  do
    touch /tmp/.$result.lock
  done < "$results"

  locksextra=($(find /usr/local/bin/swizzin/install -type f -printf "%f\n" | cut -d "." -f 1 | sort -d))
  for i in "${locksextra[@]}"; do
    app=${i}
    if [[ ! -f /tmp/.$app.lock ]]; then
      extras+=("$i" '""')
    fi
  done
  whiptail --title "Instalar Software" --checklist --noitem --separate-output "Selecciona algún extra a gusto del consumidor, si quieres." 15 26 7 "${extras[@]}" 2>/root/results2; exitstatus=$?; if [ "$exitstatus" = 1 ]; then exit 0; fi
  results2=/root/results2
}

function _install() {
  touch /tmp/.install.lock
  begin=$(date +"%s")
  readarray result < /root/results
  for i in "${result[@]}"; do
    result=$(echo $i)
    echo -e "Instalando ${result}"
    bash /usr/local/bin/swizzin/install/${result}.sh
    rm /tmp/.$result.lock
  done
  rm /root/results
  readarray result < /root/results2
  for i in "${result[@]}"; do
    result=$(echo $i)
    echo -e "Instalando ${result}"
    bash /usr/local/bin/swizzin/install/${result}.sh
  done
  rm /root/results2
  rm /tmp/.install.lock
  termin=$(date +"%s")
  difftimelps=$((termin-begin))
  echo "La instalación del paquete ha llevado $((difftimelps / 60)) minutos y $((difftimelps % 60)) segundos"
}

function _post {
  ip=$(ip route get 1 | sed -n 's/^.*src \([0-9.]*\) .*$/\1/p')
  echo "export PATH=\$PATH:/usr/local/bin/swizzin" >> /root/.bashrc
  #echo "export PATH=\$PATH:/usr/local/bin/swizzin" >> /home/$user/.bashrc
  #chown ${user}: /home/$user/.profile
  echo "Defaults    secure_path = /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin/swizzin" > /etc/sudoers.d/secure_path
  if [[ $distribution = "Ubuntu" ]]; then
    echo 'Defaults  env_keep -="HOME"' > /etc/sudoers.d/env_keep
  fi

#Da permiso solo a usuarios seleccionados para SSH
cat >> /etc/ssh/sshd_config <<EOF

#Solo permite acceso al usuario maestro o seleccionado
AllowGroups sshuser
EOF
service ssh restart

  echo "¡Instalación completa!"
  echo ""
  echo "Ya puedes logearte con el siguiente usuario: ${user}:${pass}"
  echo ""
  if [[ -f /install/.nginx.lock ]]; then
    echo "Puedes acceder a Servidor HD en https://${user}:${pass}@${ip}"
    echo ""
  fi
  if [[ -f /install/.deluge.lock ]]; then
    echo "Tu puerto del demonio deluge es $(grep daemon_port /home/${user}/.config/deluge/core.conf | cut -d: -f2 | cut -d"," -f1)"
    echo "Tu puerto de la web de deluge es $(grep port /home/${user}/.config/deluge/web.conf | cut -d: -f2 | cut -d"," -f1)"
    echo ""
  fi
  echo -e "\e[1m\e[31mPor favor, reinicia el sistema para que todas las funciones estén operativas.\e[0m"
}

_os
_preparation
_nukeovh
_skel
_intro
_adduser
_choices
_install
_post
