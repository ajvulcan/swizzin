![swizzin](https://github.com/ajvulcan/swizzin/raw/master/logo.png)

Servidor HD es una solución seedbox modular para Ubuntu 16.04 / 18.04 con posibilidad de instalar multitud de aplicaciones todo en uno.

### Inicio rápido:

wget
```
bash <(wget -O- -q  https://raw.githubusercontent.com/ajvulcan/swizzin/master/setup.sh)
```

curl
```
bash <(curl -s  https://raw.githubusercontent.com/ajvulcan/swizzin/master/setup.sh)
```

Si quieres hacer el setup a través del sudo en ubuntu:

```
sudo -H su -c 'bash <(wget -O- -q https://raw.githubusercontent.com/ajvulcan/swizzin/master/setup.sh)'
```

#### Soporte

Solo para versiones LTS:
* Ubuntu 16.04/18.04/20.04
* Debian 9/10 (No testeado)

### Es una versión propia de quickbox/swizzin con las siguientes funciones

Box:

* box - abre una interfaz gráfica de consola.
  * uso: 'box'
* list - muestra una lista de todos los paquetes disponibles.
  * Uso: `box list`
* install - installa un paquete o varios.
  * Uso: `box install sickrage couchpotato plex`
* remove - borra un paquete o varios.
  * Uso: `box remove sonarr radarr`
* adduser - añade un usuario nuevo.
  * Uso: `box adduser pepito`
* deluser - borra un usuario específico.
  * Uso: `box deluser pepito`
* chpasswd - cambia la contraseña de un usuario.
  * Uso: `box chpasswd pepito`
* update - actualiza servidor HD a los últimos cambios.
  * Uso: `box update`
* upgrade - actualiza una aplicación instalada desde un paquete.
  * Uso: `box upgrade nginx`
* panel - cambia la inspección de disco entre el directorio raiz `fix-disk root` o el uso del directorio home `fix-disk home`.
  * Uso: `box panel fix-disk home`
* rmgrsec - elimina los kernels grsec instalados por ovh y lo sustituye por uno estándar.
  * Uso: `box rmgrsec`
* rtx - configura los plugins de rutorrent.
  * Uso: `box rtx` or `rtx`

### Otros comandos:

* reload - Reinicia php y nginx entre otros.
* setdisk - establece cuotas en disco.
* showspace - muestra el uso de disco por parte de cada usuario, incluye versión plus con otras consideraciones.
* menu - muestra todos los scripts disponibles
* disco_analizador - Ejecución del programa NCDU para analisis del espacio en disco.
* disco_rendimiento - Ejecuta una prueba a traves de HDparm para comprobar la velocidad de disco.
* monitor - Set de herramientas de monitorización del sistema (FTP, htop, hd smart, interfaces, cpu, ...).
* speedtest-cli - Script de speedtest para pruebas de velocidad.
