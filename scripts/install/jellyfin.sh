#!/usr/bin/env bash
#
# authors: liara userdocs
#
# adapted for SERVIDOR HD by ajvulcan
#
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
########
######## Variables Start
########
#
# Obtiene las credenciales de usuario principal.
username="$(cat /root/.master.info | cut -d: -f1)"
password="$(cat /root/.master.info | cut -d: -f2)"
#
# Generamos puertos aleatorios entre el 10001 y el 32001.
app_port_http="$(shuf -i 10001-32001 -n 1)" && while [[ "$(ss -ln | grep -co ''"${app_port_http}"'')" -ge "1" ]]; do app_port_http="$(shuf -i 10001-32001 -n 1)"; done
app_port_https="$(shuf -i 10001-32001 -n 1)" && while [[ "$(ss -ln | grep -co ''"${app_port_https}"'')" -ge "1" ]]; do app_port_https="$(shuf -i 10001-32001 -n 1)"; done
#
# Obtengo la ipV4 externa.
ip_address="$(curl -s4 icanhazip.com)"
#
#  Ruta de instalación
install_dir="/opt/jellyfin"
#
# Ruta donde instalar ffmpeg.
install_ffmpeg="/opt/ffmpeg"
#
# Directorio temporal de instalación.
install_tmp="/tmp/jellyfin"
#
########
######## Variables End
########
#
########
######## Application script starts.
########
#
# Incluye las funciones globales requeridas para el script.
. /etc/swizzin/sources/functions/ssl
#
# Genera los certificados ssl usando la función importada.
create_self_ssl "${username}"
#
# Generamos el certificado ssl especifico para mono dede los certificados por defecto creados anteriormente.
openssl pkcs12 -export -nodes -out "/home/${username}/.ssl/${username}-self-signed.pfx" -inkey "/home/${username}/.ssl/${username}-self-signed.key" -in "/home/${username}/.ssl/${username}-self-signed.crt" -passout pass:
#
# Creamos los directorios
mkdir -p "$install_dir"
mkdir -p "$install_ffmpeg"
mkdir -p "$install_tmp"
mkdir -p "/home/${username}/.config/Jellyfin/config"
#
# Descarga y extracción de los datos.
wget -qO "$install_tmp/jellyfin.tar.gz" "$(curl -s https://api.github.com/repos/jellyfin/jellyfin/releases/latest | grep -Po 'ht(.*)linux-amd64(.*)gz')" > /dev/null 2>&1
tar -xvzf "$install_tmp/jellyfin.tar.gz" --strip-components=1 -C "$install_dir" > /dev/null 2>&1
#
# Descarga de FFmpeg prebuilt binary al directorio temporal
wget -qO "$install_tmp/ffmpeg.tar.xz" "https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz"
#
# Guardamos el directorio para usarlo más adelante en los comandos
ffmpeg_dir_name="$(tar tf "$install_tmp/ffmpeg.tar.xz" | head -1 | cut -f1 -d"/")"
#
# Extraemos el paquete al directorio temporal
tar xf "$install_tmp/ffmpeg.tar.xz" -C "$install_tmp"
#
# Borramos ficheros no necesarios.
rm -rf "$install_tmp/$ffmpeg_dir_name"/{manpages,model,GPLv3.txt,readme.txt}
#
# Copiamos los binarios requeridos.
cp "$install_tmp/$ffmpeg_dir_name"/* "$install_ffmpeg"
#
# Permisos
chmod -R 700 "$install_ffmpeg"
#
# Borramos directorio temporal no necesario ya.
rm -rf "$install_tmp" > /dev/null 2>&1
#
## Creación de ficheros de configuración
#
# Crear encoding.xml para definir el ffmpeg customizado.
cat > "/home/${username}/.config/Jellyfin/config/encoding.xml" <<-CONFIG
<?xml version="1.0"?>
<EncodingOptions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <TranscodingTempPath>/home/${username}/.config/Jellyfin/transcoding-temp</TranscodingTempPath>
  <EncoderAppPath>$install_ffmpeg/ffmpeg</EncoderAppPath>
  <EncoderAppPathDisplay>$install_ffmpeg/ffmpeg</EncoderAppPathDisplay>
</EncodingOptions>
CONFIG
#
# Crear dnla.xml para desabilitar DLNA
cat > "/home/${username}/.config/Jellyfin/config/dlna.xml" <<-CONFIG
<?xml version="1.0"?>
<DlnaOptions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <EnablePlayTo>false</EnablePlayTo>
  <EnableServer>false</EnableServer>
  <EnableDebugLog>false</EnableDebugLog>
  <BlastAliveMessages>false</BlastAliveMessages>
  <SendOnlyMatchedHost>true</SendOnlyMatchedHost>
  <ClientDiscoveryIntervalSeconds>60</ClientDiscoveryIntervalSeconds>
  <BlastAliveMessageIntervalSeconds>1800</BlastAliveMessageIntervalSeconds>
</DlnaOptions>
CONFIG
#
# Crea system.xml. Fichero principal de configuración.
cat > "/home/${username}/.config/Jellyfin/config/system.xml" <<-CONFIG
<?xml version="1.0"?>
<ServerConfiguration xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <LogFileRetentionDays>3</LogFileRetentionDays>
  <IsStartupWizardCompleted>false</IsStartupWizardCompleted>
  <EnableUPnP>false</EnableUPnP>
  <PublicPort>${app_port_http}</PublicPort>
  <PublicHttpsPort>${app_port_https}</PublicHttpsPort>
  <HttpServerPortNumber>${app_port_http}</HttpServerPortNumber>
  <HttpsPortNumber>${app_port_https}</HttpsPortNumber>
  <EnableHttps>true</EnableHttps>
  <EnableNormalizedItemByNameIds>false</EnableNormalizedItemByNameIds>
  <CertificatePath>/home/${username}/.ssl/${username}-self-signed.pfx</CertificatePath>
  <IsPortAuthorized>true</IsPortAuthorized>
  <AutoRunWebApp>true</AutoRunWebApp>
  <EnableRemoteAccess>true</EnableRemoteAccess>
  <CameraUploadUpgraded>false</CameraUploadUpgraded>
  <CollectionsUpgraded>false</CollectionsUpgraded>
  <EnableCaseSensitiveItemIds>true</EnableCaseSensitiveItemIds>
  <DisableLiveTvChannelUserDataName>false</DisableLiveTvChannelUserDataName>
  <PreferredMetadataLanguage>en</PreferredMetadataLanguage>
  <MetadataCountryCode>US</MetadataCountryCode>
  <SortReplaceCharacters>
    <string>.</string>
    <string>+</string>
    <string>%</string>
  </SortReplaceCharacters>
  <SortRemoveCharacters>
    <string>,</string>
    <string>&amp;</string>
    <string>-</string>
    <string>{</string>
    <string>}</string>
    <string>'</string>
  </SortRemoveCharacters>
  <SortRemoveWords>
    <string>the</string>
    <string>a</string>
    <string>an</string>
  </SortRemoveWords>
  <MinResumePct>5</MinResumePct>
  <MaxResumePct>90</MaxResumePct>
  <MinResumeDurationSeconds>300</MinResumeDurationSeconds>
  <LibraryMonitorDelay>60</LibraryMonitorDelay>
  <EnableDashboardResponseCaching>true</EnableDashboardResponseCaching>
  <ImageSavingConvention>Compatible</ImageSavingConvention>
  <MetadataOptions>
    <MetadataOptions>
      <ItemType>Book</ItemType>
      <DisabledMetadataSavers />
      <LocalMetadataReaderOrder />
      <DisabledMetadataFetchers />
      <MetadataFetcherOrder />
      <DisabledImageFetchers />
      <ImageFetcherOrder />
    </MetadataOptions>
    <MetadataOptions>
      <ItemType>Movie</ItemType>
      <DisabledMetadataSavers />
      <LocalMetadataReaderOrder />
      <DisabledMetadataFetchers />
      <MetadataFetcherOrder />
      <DisabledImageFetchers />
      <ImageFetcherOrder />
    </MetadataOptions>
    <MetadataOptions>
      <ItemType>MusicVideo</ItemType>
      <DisabledMetadataSavers />
      <LocalMetadataReaderOrder />
      <DisabledMetadataFetchers>
        <string>The Open Movie Database</string>
      </DisabledMetadataFetchers>
      <MetadataFetcherOrder />
      <DisabledImageFetchers>
        <string>The Open Movie Database</string>
      </DisabledImageFetchers>
      <ImageFetcherOrder />
    </MetadataOptions>
    <MetadataOptions>
      <ItemType>Series</ItemType>
      <DisabledMetadataSavers />
      <LocalMetadataReaderOrder />
      <DisabledMetadataFetchers>
        <string>TheMovieDb</string>
      </DisabledMetadataFetchers>
      <MetadataFetcherOrder />
      <DisabledImageFetchers>
        <string>TheMovieDb</string>
      </DisabledImageFetchers>
      <ImageFetcherOrder />
    </MetadataOptions>
    <MetadataOptions>
      <ItemType>MusicAlbum</ItemType>
      <DisabledMetadataSavers />
      <LocalMetadataReaderOrder />
      <DisabledMetadataFetchers>
        <string>TheAudioDB</string>
      </DisabledMetadataFetchers>
      <MetadataFetcherOrder />
      <DisabledImageFetchers />
      <ImageFetcherOrder />
    </MetadataOptions>
    <MetadataOptions>
      <ItemType>MusicArtist</ItemType>
      <DisabledMetadataSavers />
      <LocalMetadataReaderOrder />
      <DisabledMetadataFetchers>
        <string>TheAudioDB</string>
      </DisabledMetadataFetchers>
      <MetadataFetcherOrder />
      <DisabledImageFetchers />
      <ImageFetcherOrder />
    </MetadataOptions>
    <MetadataOptions>
      <ItemType>BoxSet</ItemType>
      <DisabledMetadataSavers />
      <LocalMetadataReaderOrder />
      <DisabledMetadataFetchers />
      <MetadataFetcherOrder />
      <DisabledImageFetchers />
      <ImageFetcherOrder />
    </MetadataOptions>
    <MetadataOptions>
      <ItemType>Season</ItemType>
      <DisabledMetadataSavers />
      <LocalMetadataReaderOrder />
      <DisabledMetadataFetchers>
        <string>TheMovieDb</string>
      </DisabledMetadataFetchers>
      <MetadataFetcherOrder />
      <DisabledImageFetchers />
      <ImageFetcherOrder />
    </MetadataOptions>
    <MetadataOptions>
      <ItemType>Episode</ItemType>
      <DisabledMetadataSavers />
      <LocalMetadataReaderOrder />
      <DisabledMetadataFetchers>
        <string>The Open Movie Database</string>
        <string>TheMovieDb</string>
      </DisabledMetadataFetchers>
      <MetadataFetcherOrder />
      <DisabledImageFetchers>
        <string>The Open Movie Database</string>
        <string>TheMovieDb</string>
      </DisabledImageFetchers>
      <ImageFetcherOrder />
    </MetadataOptions>
  </MetadataOptions>
  <EnableAutomaticRestart>true</EnableAutomaticRestart>
  <SkipDeserializationForBasicTypes>false</SkipDeserializationForBasicTypes>
  <BaseUrl />
  <UICulture>en-US</UICulture>
  <SaveMetadataHidden>false</SaveMetadataHidden>
  <ContentTypes />
  <RemoteClientBitrateLimit>0</RemoteClientBitrateLimit>
  <EnableFolderView>false</EnableFolderView>
  <EnableGroupingIntoCollections>false</EnableGroupingIntoCollections>
  <DisplaySpecialsWithinSeasons>true</DisplaySpecialsWithinSeasons>
  <LocalNetworkSubnets />
  <LocalNetworkAddresses>
    <string>0.0.0.0</string>
  </LocalNetworkAddresses>
  <CodecsUsed />
  <IgnoreVirtualInterfaces>false</IgnoreVirtualInterfaces>
  <EnableExternalContentInSuggestions>true</EnableExternalContentInSuggestions>
  <RequireHttps>false</RequireHttps>
  <IsBehindProxy>false</IsBehindProxy>
  <EnableNewOmdbSupport>false</EnableNewOmdbSupport>
  <RemoteIPFilter />
  <IsRemoteIPFilterBlacklist>false</IsRemoteIPFilterBlacklist>
  <ImageExtractionTimeoutMs>0</ImageExtractionTimeoutMs>
  <PathSubstitutions />
  <EnableSimpleArtistDetection>true</EnableSimpleArtistDetection>
  <UninstalledPlugins />
</ServerConfiguration>
CONFIG
#
# Crea fichero que lanza y para el servicio de jellyfin.
cat > "/etc/systemd/system/jellyfin.service" <<-SERVICE
[Unit]
Description=Jellyfin
After=network.target
[Service]
User=${username}
Group=${username}
UMask=002
Type=simple
WorkingDirectory=$install_dir
ExecStart=$install_dir/jellyfin -d /home/${username}/.config/Jellyfin
TimeoutStopSec=20
KillMode=process
Restart=always
RestartSec=2
[Install]
WantedBy=multi-user.target
SERVICE
#
# Configura el proxypass de nginx usando parametros posicionales.
if [[ -f /install/.nginx.lock ]]; then
    bash "/usr/local/bin/swizzin/nginx/jellyfin.sh" "${app_port_http}" "${app_port_https}"
    systemctl reload nginx
fi
#
# Configura correctamente los permisos requeridos de cualquier directorio que hayamos creado o modificado.
chown "${username}.${username}" -R "$install_dir"
chown "${username}.${username}" -R "$install_ffmpeg"
chown "${username}.${username}" -R "/home/${username}/.config"
chown "${username}.${username}" -R "/home/${username}/.ssl"
#
# Habilita y ejecuta el servicio de Jellyfin.
systemctl daemon-reload
systemctl enable --now "jellyfin.service" >> /dev/null 2>&1
#
# Fichero creado después de la instalación para prevenir la reinstalación. Deberías de desinstalar la aplicación primero que borra este fichero.
touch "/install/.jellyfin.lock"
#
# Info al terminal.
echo -e "\nLa instalación de Jellyfin se ha completado\n"
#
if [[ ! -f /install/.nginx.lock ]]; then
    echo -e "Jellyfin está disponible en: https://$(curl -s4 icanhazip.com):${app_port_https}\n"
else
    echo -e "Jellyfin está ya disponible en el panel\n"
    echo -e "Por favor, visita https://$ip_address/jellyfin\n"
fi
#
exit 
