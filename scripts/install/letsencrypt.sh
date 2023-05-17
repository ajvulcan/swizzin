#!/bin/bash
# Let's Encrypt Install
# 
# by Ajvulcan
#
# -- SERVIDOR HD --
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#

if [[ ! -f /install/.nginx.lock ]]; then
    echo "Este script está diseñado para ser usado en conjunción con nginx, pero no está instalado. Por favor, instálelo primero."
    exit 1
fi    

. /etc/swizzin/sources/functions/letsencrypt
ip=$(ip route get 1 | sed -n 's/^.*src \([0-9.]*\) .*$/\1/p')

if [[ -z $LE_HOSTNAME ]]; then
    echo -e "Introduce el nombre de dominio a vincular con LE"
    read -e hostname
else
    hostname=$LE_HOSTNAME
fi

read -p "¿Quieres aplicar este certificado a tu configuración de servidor HD por defecto? (s/n) " yn
case $yn in
  [Ss] )
      main=yes
      ;;
  [Nn] )
      main=no
      ;;
  * ) echo "Por favor, responde (s)i o (n)o.";;
esac

if [[ $main == yes ]]; then
  sed -i "s/server_name .*;/server_name $hostname;/g" /etc/nginx/sites-enabled/default
fi

if [[ -n $LE_CF_API ]] || [[ -n $LE_CF_EMAIL ]] || [[ -n $LE_CF_ZONE ]]; then
    LE_BOOL_CF=yes
fi

read -p "¿Está tu DNS gestionada por CloudFlare? (s/n) " yn
case $yn in
  [Ss] )
      cf=yes
      ;;
  [Nn] )
      cf=no
      ;;
  * ) echo "Por favor, responde (s)i o (n)o.";;
esac

if [[ ${cf} == yes ]]; then

  if [[ $hostname =~ (\.cf$|\.ga$|\.gq$|\.ml$|\.tk$) ]]; then
    echo "ERROR Cloudflare no soporta llamadas API para los siguientes TLDs: cf, .ga, .gq, .ml, or .tk"
    exit 1
  fi
  
  if [[ -n $LE_CF_ZONE ]]; then
        LE_CF_ZONEEXISTS=no
  fi
  
  if [[ -z $LE_CF_ZONEEXISTS ]]; then
     read -p "¿Existe ya el registro para este subdominio? (s/n) " yn
    case $yn in
      [Ss] )
      record=yes
      ;;
      [Nn] )
      record=no
      ;;
      * )
      echo "Por favor, responde (s)i o (n)o."
      ;;
    esac
  else
      [[ $LE_CF_ZONEEXISTS = "yes" ]] && zone=yes
      [[ $LE_CF_ZONEEXISTS = "no" ]] && zone=no
  fi
  
      if [[ -z $LE_CF_API ]]; then
        echo -e "Introduce la key de API de CF"
        read -e api
    else
        api=$LE_CF_API
    fi

    if [[ -z $LE_CF_EMAIL ]]; then
        echo -e "CF Email"
        read -e email
    else
        api=$LE_CF_EMAIL
    fi

  export CF_Key="${api}"
  export CF_Email="${email}"

  valid=$(curl -X GET "https://api.cloudflare.com/client/v4/user" -H "X-Auth-Email: $email" -H "X-Auth-Key: $api" -H "Content-Type: application/json")
  if [[ $valid == *"\"success\":false"* ]]; then
    message="LA LLAMADA A LA API HA FALLADO. INCLUYENDO RESULTADOS:\n$valid"
    echo -e "$message"
    exit 1
  fi

  if [[ ${record} == no ]]; then
  
      if [[ -z $LE_CF_ZONE ]]; then
          echo "Nombre de zona (example.com)"
          read -e zone
      else
          zone=$LE_CF_ZONE
      fi
      
    zoneid=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$zone" -H "X-Auth-Email: $email" -H "X-Auth-Key: $api" -H "Content-Type: application/json" | grep -Po '(?<="id":")[^"]*' | head -1 )
    addrecord=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records" -H "X-Auth-Email: $email" -H "X-Auth-Key: $api" -H "Content-Type: application/json" --data "{\"id\":\"$zoneid\",\"type\":\"A\",\"name\":\"$hostname\",\"content\":\"$ip\",\"proxied\":true}")
    if [[ $addrecord == *"\"success\":false"* ]]; then
      message="LA ACTUALIZACIÓN DE API HA FALLADO. INCLUYENDO RESULTADOS:\n$addrecord"
      echo -e "$message"
      exit 1
    else
      message="Registro DNS añadido para $hostname en $ip"
      echo "$message"
    fi
  fi
fi

apt-get -y -q install socat > /dev/null 2>&1

if [[ ! -f /root/.acme.sh/acme.sh ]]; then
    echo "Instalando script ACME"
    curl https://get.acme.sh | sh >> /dev/null 2>&1
    echo "hecho"
fi

mkdir -p /etc/nginx/ssl/${hostname}
chmod 700 /etc/nginx/ssl

/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt || {
    echo "No se pudo establecer el certificado de autoridad por defecto a Let's Encrypt. Actualizando acme.sh para reintentar."
    /root/.acme.sh/acme.sh --upgrade || {
        echo -e "No se pudo actualizar acme.sh."
        exit 1
    }
    /root/.acme.sh/acme.sh --set-default-ca --server letsencrypt || {
        echo -e "No se pudo establecer el certificado de autoridad por defecto a Let's Encrypt"
        exit 1
    }
    echo "acme.sh se ha actualizado con éxito."
}

echo "Registrando certificados"
if [[ ${cf} == yes ]]; then
  /root/.acme.sh/acme.sh --force --issue --dns dns_cf -d ${hostname} || { 
    echo "ERROR: No se pudo obtener el certificado. Por favior, comprueba tu info y prueba de nuevo"; 
    exit 1; 
    }
else
  if [[ $main = yes ]]; then
    /root/.acme.sh/acme.sh --force --issue --nginx -d ${hostname}|| { 
        echo "ERROR: No se pudo obtener el certificado. Por favior, comprueba tu info y prueba de nuevo"; 
        exit 1; 
      }
  else
    systemctl stop nginx
    /root/.acme.sh/acme.sh --force --issue --standalone -d ${hostname} --pre-hook "systemctl stop nginx" --post-hook "systemctl start nginx" >> /dev/null 2>&1 || { 
        echo "ERROR: No se pudo obtener el certificado. Por favior, comprueba tu info y prueba de nuevo"; 
        exit 1; 
    }
    sleep 1
    systemctl start nginx
  fi
fi
echo "Certificado adquirido"

echo "Instalando certificado"
/root/.acme.sh/acme.sh --force --install-cert -d ${hostname} --key-file /etc/nginx/ssl/${hostname}/key.pem --fullchain-file /etc/nginx/ssl/${hostname}/fullchain.pem --ca-file /etc/nginx/ssl/${hostname}/chain.pem --reloadcmd "systemctl reload nginx"
if [[ $main == yes ]]; then
  sed -i "s/ssl_certificate .*/ssl_certificate \/etc\/nginx\/ssl\/${hostname}\/fullchain.pem;/g" /etc/nginx/sites-enabled/default
  sed -i "s/ssl_certificate_key .*/ssl_certificate_key \/etc\/nginx\/ssl\/${hostname}\/key.pem;/g" /etc/nginx/sites-enabled/default
fi
echo "Certificado instalado"

# Add LE certs to ZNC, if installed.
if [[ -f /install/.znc.lock ]]; then
  le_znc_hook
fi

# Add LE certs to VSFTPD, if installed.
if [[ -f /install/.vsftpd.lock ]]; then
  le_vsftpd_hook
  systemctl restart vsftpd
fi


if [[ -f /install/.webmin.lock ]]; then
#Actualiza la configuración de webmin.

# Webmin nginx installer
# by ajvulcan for SERVIDOR HD

MASTER=$(cut -d: -f1 < /root/.master.info)

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

sed -i '/referers/d' /etc/webmin/config
sed -i '/webprefix/d' /etc/webmin/config
sed -i '/no_frame_options/d' /etc/webmin/config

cat >> /etc/webmin/config << EOF
webprefix=/webmin
webprefixnoredir=1
referers=${hostname}
no_frame_options=1
EOF

#Reiniciamos servicios.
systemctl reload webmin

echo 'RECUERDA actualizar la configuración de encriptación SSL en WEBMIN'
fi

#Finaliza instalación
systemctl reload nginx

#Crea fichero para configurar servicios de streaming
if [[ -d /root/.acme.sh/${hostname}_ecc ]]; then
        carpeta_hostname="${hostname}_ecc"
    else
        carpeta_hostname="${hostname}"
fi
cd ~/.acme.sh/${carpeta_hostname}/
echo "Introduce una contraseña para el certificado de streaming:"
read str_pass
openssl pkcs12 -export -out streaming-cert.pkfx -inkey ${hostname}.key -in ${hostname}.cer -certfile fullchain.cer -passout pass:$str_pass
mv streaming-cert.pkfx /usr/local/etc/
chmod 644 /usr/local/etc/streaming-cert.pkfx

echo "¡Ya tienes certificado disponible!, configura Plex o Emby con el certificado correspondiente"
echo "ruta del certificado: /usr/local/etc/streaming-cert.pkfx"
echo "clave de cifrado: ${str_pass}"
echo "Certificado de dominio personalizado, para plex :  https://${hostname}:32400, para otro simplemente usa ${hostname}"
echo "Fichero de configuración disponible en /root/cert_streaming.info para futuras consultas."

echo "Datos de Certificado:" > /root/cert_streaming.info
echo "Ruta: /usr/local/etc/streaming-cert.pkfx" >> /root/cert_streaming.info
echo "clave de cifrado: ${str_pass}" >> /root/cert_streaming.info
echo "Certificado de dominio personalizado, para plex :  https://${hostname}:32400, para otro simplemente usa ${hostname}" >> /root/cert_streaming.info

echo "Letsencrypt instalado"
