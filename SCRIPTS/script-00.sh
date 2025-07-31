# Instalación de paquetes iniciales
echo "Instalando paquetes..."
apt-get update && apt-get upgrade -y

## Paquetes de ciberseguridad:
# Preguntar al usuario si quiere instalar paquetes de ciberseguridad
# -------------------------------------------------------------------
read -p "¿Deseas instalar paquetes de ciberseguridad como sqlmap john hydra...? (s/n): " respuestaCyber

if [[ "$respuestaCyber" == "s" || "$respuestaCyber" == "S" ]]; then
    apt install -y nmap john hydra sqlmap whatweb tshark exiftool
    echo "Paquetes de ciberseguridad instalados:"
    echo "nmap, john, hydra, sqlmap, whatweb, tshark, exiftool."
else
    echo "Continuando con la instalación sin paquetes de instalación."
fi
# ------------------------------------------------------------------- 

# instalaciones general 
apt-get install -y \
    nmap \
    iputils-ping lm-sensors iproute2 sudo vim net-tools curl btop iftop \
    lsb-release arping wget sysstat ntpdate snmp snmpd tcpdump \
    ngrep iptraf-ng mlocate tar gzip tree ca-certificates \
    screen man-db mailutils dnsutils telnet rsyslog  

# Configuración de sensores
echo "Configurando sensores:"
sensors-detect --auto
systemctl restart lm-sensors

## modificar hostname:
# Preguntar al usuario si desea cambiar el hostname
# -------------------------------------------------------------------
read -p "¿Deseas agregar un nuevo hostname? (s/n): " respuestaHost

if [[ "$respuestaHost" == "s" || "$respuestaHost" == "S" ]]; then
    read -p "Introduce el nuevo hostname (isaac.laboratory-00): " new_hostname

    sudo hostname "$new_hostname"

    sudo mv /etc/hostname /etc/hostname.old
    echo "$new_hostname" | sudo tee /etc/hostname > /dev/null
    echo "El hostname se ha cambiado a: $new_hostname"

    sudo mv /etc/hosts /etc/hosts.old

    sudo tee /etc/hosts > /dev/null <<EOF
127.0.0.1   localhost
127.0.1.1   $new_hostname

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

else
    echo "Continuando con la instalación sin cambiar el hostname."
fi
# -------------------------------------------------------------------

# Configuro bashrc
cat <<EOF > ~/.bashrc
## alias del servidor
alias ls='ls -ha --color=auto --group-directories-first'
alias la='ls $LS_OPTION -lhai --group-directories-first'
alias _liberarespacioram='sudo sync; echo 1 | sudo tee /proc/sys/vm/drop_caches | echo "petición realizada correctamente." && echo "" && free -h'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias grep='grep --color=auto'
alias df='df --exclude-type=tmpfs'

## Cambiar diseño del prompt (estilo cyberpunk)
# **************************************
# color 1
PS1='\[\e[0;90m\]r00t箱\e[38;5;196m[\H]\e[38;5;196m\e[1;32m \w\e[0;37m $: '
# color 2
# PS1='\[\e[1;31m\]r00t箱[\H] \w $: \[\e[0m\]'

## cambiar colores para ls (estilo cyberpunk)
# **************************************
export LS_COLORS="di=1;32:fi=0;37:ln=1;35:so=0;38;5;208:pi=0;34:bd=0;33:cd=0;33:or=0;31:mi=0;31:ex=1;31"
EOF

# agrego mis propios comandos:
# comando : scanvuln
# escanea rapidamente las vulnerabilidades de la IP asignada
# -------------------------------------------------------------------
cat <<EOF > /usr/bin/scanvuln
#!/bin/bash
if ! command -v nmap &>/dev/null; then
  read -rp "[!] Nmap no esta instalado. ¿Quieres instalarlo? (s/n): " respuesta
  if [[ "$respuesta" =~ ^[Ss]$ ]]; then
    echo "[*] Instalando nmap..."
    sudo apt-get update && sudo apt-get install -y nmap
    if [[ $? -ne 0 ]]; then
      echo "[!] Error al instalar nmap."
      exit 1
    fi
  else
    echo "[!] Nmap es necesario para realizar el escaneo."
    exit 1
  fi
fi

echo "[*] Este comando realiza un escaneo de vulnerabilidades sobre la IP específica."
read -rp "Introduce la IP a escanear: " ip

if [[ -z "$ip" ]]; then
  echo "[!] No se ha introducido una IP valida."
  exit 1
fi

echo "[*] Escaneando con Nmap + scripts de vulnerabilidades..."
sudo nmap -sV --script vuln "$ip"
EOF

chmod 777 /usr/bin/scanvuln

# comando : pingtime
# hace un ping registrando la fecha y tiempo exacto y de manera opcional guarda cada peticion en la ruta /var/log/ping/
# -------------------------------------------------------------------
cat <<EOF > /usr/bin/pingtime
#!/bin/bash
if [[ -z "$1" ]]; then
  echo "Uso: pingtime <IP|host>"
  exit 1
fi

host="$1"
read -rp "¿Quieres guardar el registro? (s/n): " respuesta

timestamp=$(date +"%Y%m%d_%H%M%S")
log_dir="/var/log/ping"
log_file="$log_dir/ping_${host}_$timestamp.log"

if [[ "$respuesta" =~ ^[Ss]$ ]]; then
  mkdir -p "$log_dir"

  # Información inicial del host
  {
    echo -e "================================================================================\n"
    echo "Información inicial para $host"
    echo "Fecha: $(date)"
    ip neigh show "$host"
    nslookup "$host"
    echo -e "================================================================================\n"
  } >> "$log_file"

  read -rp "¿Registrar todos los logs (a) o solo cambios de estado (c)? [a/c]: " modo

  last_state=""
  ping "$host" | while IFS= read -r line; do
    date_str="[$(date '+%Y-%m-%d %H:%M:%S')]"

    if [[ "$modo" =~ ^[Aa]$ ]]; then
      echo "$date_str $line" | tee -a "$log_file"
    else
      if echo "$line" | grep -q "bytes from"; then
        current_state="up"
      else
        current_state="down"
      fi

      if [[ "$current_state" != "$last_state" ]]; then
        echo "$date_str $line" | tee -a "$log_file"
        last_state="$current_state"
      fi
    fi
  done

  echo "Registro guardado en $log_file"

else
  ping "$host" | while IFS= read -r line; do
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $line"
  done
fi
EOF

chmod 777 /usr/bin/pingtime

## Configuración mínima de logs
# **************************************
# Logrotate estandar para cualquier servidor (configuracion minima):
# Configura la rotación mensual, mantiene 12 meses rotados, agrega fechas a los nombres, comprime los logs antiguos, elimina archivos de dos años y permite configuraciones adicionales desde /etc/logrotate.d.
cat  <<EOF > /etc/logrotate.conf
# logrotate.conf - Elliot 2025
weekly
rotate 52          # 52 semanas = 1 año
dateext
compress
notifempty
maxage 730         # elimina logs > 730 días (2 años)
create 640 root adm
include /etc/logrotate.d
EOF
systemctl enable rsyslog
systemctl restart rsyslog

# Idioma
# **************************************
#localectl
localectl set-locale LANG=en_US.UTF-8
localectl

# Configuro vimrc (estilo cyberpunk)
# **************************************
cat <<EOF > ~/.vimrc
" Configuración del archivo .vimrc
set number                                              " Muestra los números de línea en el margen izquierdo.
set cursorline                                          " Resalta la línea donde se encuentra el cursor.
set scrolloff=8                                         " Mantiene 8 líneas visibles por encima y por debajo del cursor al desplazarse.
set incsearch                                           " Realiza la búsqueda de manera incremental, mostrando resultados a medida que se escribe.
set hlsearch                                            " Resalta todas las coincidencias de la búsqueda.
set ignorecase                                          " Ignora mayúsculas y minúsculas en las búsquedas.
set smartcase                                           " Si se usa una mayúscula en la búsqueda, se activa la distinción entre mayúsculas y minúsculas.
set expandtab                                           " Convierte las tabulaciones en espacios.
set tabstop=4                                           " Establece el ancho de una tabulación a 4 espacios.
set shiftwidth=4                                        " Establece el ancho de sangría a 4 espacios.
set wildmenu                                            " Mejora la interfaz de autocompletado en la línea de comandos.
set foldmethod=indent                                   " Usa la indentación para determinar los pliegues de código.
set foldlevel=99                                        " Establece el nivel de pliegue inicial a 99, mostrando todo el código.
syntax on                                               " Activa el resaltado de sintaxis.
set background=dark                                     " Establece el fondo oscuro para el resaltado de sintaxis.
colorscheme industry                                    " Aplica el esquema de colores 'industry'.
highlight Comment ctermfg=Green guifg=#00FF00           " Resalta los comentarios en verde.
highlight LineNr ctermfg=Magenta                        " Resalta los números de línea en magenta.
highlight CursorLineNr ctermfg=DarkMagenta              " Resalta el número de línea del cursor en magenta oscuro.
highlight Normal ctermfg=White ctermbg=DarkGray         " Establece el color normal del texto a blanco sobre fondo gris oscuro.
highlight Keyword ctermfg=LightGray                     " Resalta las palabras clave en gris claro.
highlight Function ctermfg=Yellow                       " Resalta las funciones en amarillo.
highlight Type ctermfg=Magenta                          " Resalta los tipos de datos en magenta.
highlight Constant ctermfg=Magenta                      " Resalta las constantes en magenta.
highlight Identifier ctermfg=White                      " Resalta los identificadores en blanco.
highlight Statement ctermfg=Yellow                      " Resalta las declaraciones en amarillo.
highlight Error ctermfg=White ctermbg=Red               " Resalta los errores en blanco sobre fondo rojo.
highlight Search ctermfg=Black ctermbg=Yellow           " Resalta la búsqueda en negro sobre fondo amarillo.
highlight Visual ctermbg=Grey                           " Resalta la selección visual en gris.
highlight StatusLine ctermfg=Blue ctermbg=White         " Establece el color de la línea de estado en azul sobre fondo blanco.
highlight StatusLineNC ctermfg=Blue ctermbg=DarkGray    " Establece el color de la línea de estado no activa en azul sobre fondo gris oscuro.
highlight Special ctermfg=Blue                          " Resalta los elementos especiales en azul.
highlight PreProc ctermfg=Grey                          " Resalta las preprocesadores en gris.
highlight Todo ctermfg=Black ctermbg=Yellow             " Resalta las tareas pendientes en negro sobre fondo amarillo.
highlight Underlined ctermfg=White                      " Resalta el texto subrayado en blanco.
highlight Pmenu ctermbg=DarkGray                        " Establece el fondo del menú de completado en gris oscuro.
highlight PmenuSel ctermbg=Blue ctermfg=White           " Establece el fondo del menú de selección en azul y el texto en blanco.
highlight DiffAdd ctermbg=Green                         " Resalta las adiciones en el diff en verde.
highlight DiffChange ctermbg=Yellow                     " Resalta los cambios en el diff en amarillo.
highlight DiffDelete ctermbg=Red                        " Resalta las eliminaciones en el diff en rojo.
highlight Folded ctermfg=White ctermbg=DarkBlue         " Resalta los pliegues en blanco sobre fondo azul oscuro.
set laststatus=2                                        " Siempre muestra la línea de estado.
set noerrorbells                                        " Desactiva los sonidos de error.
set history=1000                                        " Establece el tamaño del historial de comandos a 1000 entradas.
set clipboard=unnamedplus                               " Usa el portapapeles del sistema para copiar y pegar.
EOF

# Información en inicio de sesión
echo '# información inicio de sesión' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMMMWWXKOkxddooooooddxkO0KNWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMWX0kolc::;;;::;;;;;;;;::cloxOKNWMMMMMMMMMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMWN0dl:;:;;:;;;;;;;;;;;;;;;;;;;;:clxOXWWMMMMMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMWXko::;;;;;;;;;;;;;;;;;;;;;;;;;;;;:;;:cdOXWMMMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMWNOl:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:;;::;;;:lkKWMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMWKd:;:;;;;;::;:;;;;;;;;;;;;;;;;;;;;;;;::;;;:;:lkXWMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMW0o:;;;;;;;;:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:;;;:lONMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMWKo:;;;::;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;cxXWMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMXd:;:;;::;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:dXWMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMWOc::;:;;;;;;;;;;;;:;;;:;;;;;;;;;;;;;;;;;;;;:;;:;;;;;;:xNMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMNd:;;;;;;;;;;;;;;;::;;;;;:;;:;;;::;;;;;;;;;;;;;;;;;;:;:l0WMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMWKo;;;;;;;;;:;::;;;:;::;;;::cllllc::;;;;;;;;;;;;;;;;;;;:cdKNMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMWKo;;;;;;;;;;;:cc:;;;;;;:looollccc::;;;;;;;;;;;;;;;;;:;:::cxXMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMXo:;:;;;;;;;;::ll:;;;;cdxl::;:lol:;::;;;;;;;;;;;;;;;:cdkoccxNMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMNx:;;;;::;;;::;col::;:xkl::lokXNKd::;;;;;;;;;;;;;;;;:xXXxc:oKMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMW0l:;;;;;;;;;:;:loc:cxKx:;cOXWMMWOc;:;;;;;;;;;;;;;;;l0WNx::oKWMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMNkc;;::;;;;;;;::oxk0K0o:;oXWWMMNx:;;;;;;;;;;;;:;;;;l0WXd::dXMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMNkc;;::;;;:;;:;:clllol;:dXWMMW0l:;:;;;;;;;;;::::;;cONKo;:kNMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMNkc:::;;;;;:::;;;;:c:;:oKWWMNx::;;;;;;;;;;::;:;::ckN0l;cOWMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMW0dc::::;;cl:;;:::::;:l0WWMXd;;;;;;;;;;;;;:;;;::ckN0l;l0WMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMN0o:;;;;col:::;::::;lKWWMXo;;;;;;;;;;;;:cl::;:cON0l;l0WMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMWNOoc:;:lxo:;;:c:;;oKWWWKo:;:;;:;;;;;:lOkc:;;lONOc;lKWMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMWN0occ:dOxl:ll:::xNWWWOl:;;;;:;;;:::dXKo:;;:dOdc:dXMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMNkodlcxXX00d:;:kNWWWOl:;;:;;:;;::dKWNkc;::ccccdKWMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMWNOoc:oXWWNk:;:oOKK0xl:::::;;;::dKNXN0l;cxkxx0NWMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMMNkc:xNMMWKd::::ccccoxO0Oxl::;:xKOkKOl:lKWWMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMMNx:l0WMMMWN0xddddk0NWMWNxlc::::cc:cl::lKMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMW0lcONMMMMMMMWWWWWMMMMMWKo:;:c:;:::;cl:oKMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMWOcl0WMMMMMMMMMMMMMMMMMWkc;;coc;:ll:odoONMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMWKocxXWMMMMMMMMMMMMMMMMW0dlokdc:oxod0XNWMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMWKdlok0KNWWMMMMMMMMMMMMWNXNWX0KNNNWWMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMWKOdollokKKO0KXWWWWNX0dkXWMMMMMMMMMMMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNKOdlll::cdxdkOdodloKWMMMMMMMMMMMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWKxc:::cc:clccdkKWMMMMMMMMMMMMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNkc;;;;;:::dKWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN0dooodoldKWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWWWWNXWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc

echo 'echo "Información del sistema:"' >> /etc/bash.bashrc
echo 'echo "CPU: $(grep -m1 '\''model name'\'' /proc/cpuinfo | cut -d ":" -f2 | sed '\''s/^ //'\'' )"' >> /etc/bash.bashrc
echo 'echo "Memoria libre: $(free -h | awk '\''/^Mem:/ {print $7}'\'')"' >> /etc/bash.bashrc
echo 'echo "Espacio en disco: $(df -h / | awk '\''$NF=="/"{print $4}'\'')"' >> /etc/bash.bashrc
echo 'echo "Memoria escrita: $(awk '\''{sum += $10} END {print sum * 512 / (1024*1024*1024*1024)}'\'' /proc/diskstats) TB"' >> /etc/bash.bashrc
echo 'echo "Encendido permanente: $(awk '\''{ print int($1/86400) " days, " int(($1%86400)/3600) " hours, " int(($1%3600)/60) " minutes" }'\'' /proc/uptime)"' >> /etc/bash.bashrc
echo 'sensors 2>/dev/null || echo "No se detectaron sensores."' >> /etc/bash.bashrc
echo 'lsb_release -sd 2>/dev/null || echo "No LSB modules available."' >> /etc/bash.bashrc
echo 'uname -srm' >> /etc/bash.bashrc

# recargo el archivo bash.bashrc
source /etc/bash.bashrc

# servidor de SNMP
# **************************************
mv /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.ori
touch /etc/snmp/snmpd.conf
cat <<EOF > /etc/snmp/snmpd.conf
#
# SNMPD Configuration
# Isaac (v2) - 2025
#
agentAddress udp:161

# =====[DEFINO-RED-SNMP]============================================================================================
rocommunity MaltLiquor_25 localhost
rocommunity MaltLiquor_25 39.1.0.0/16
rocommunity MaltLiquor_25 192.168.1.0/24

# =====[ESCRITURA-VALORES]==========================================================================================
# sobreescribo o fuerzo valores
syslocation "🤖 CPD"
syscontact "🤖 Informatica <informatica@aptelliot.es>"

# =====[HABILITO-OIDS]==============================================================================================
# OIDs importantes:
# sysObjectID: .1.3.6.1.2.1.1.2  # Identificador único del objeto del sistema (por ejemplo, el tipo de dispositivo)
# sysDescr: .1.3.6.1.2.1.1.1     # Descripción del sistema (por ejemplo, el modelo y la versión del firmware)
# sysUpTime: .1.3.6.1.2.1.1.3    # Tiempo que el sistema ha estado funcionando desde el último reinicio
# sysContact: .1.3.6.1.2.1.1.4   # Información de contacto del administrador del sistema
# sysName: .1.3.6.1.2.1.1.5      # Nombre del sistema
# sysLocation: .1.3.6.1.2.1.1.6  # Ubicación física del sistema
# sysServices: .1.3.6.1.2.1.1.7  # Servicios disponibles en el sistema (por ejemplo, SNMP, HTTP, FTP)

# =====[PERSONALIZACIÓN-RAMAS]======================================================================================
# Ramas personalizadas
#extend test1 /bin/echo "Hello world"
#exec 1.3.6.1.4.1.2021.8 /bin/echo "Hello world"

# =====[ACCESOS-RESTRICTIVOS]=======================================================================================
# Solo exponer arbol de OID seguro
view systemonly included .1.3.6.1.2.1.1.1
view systemonly included .1.3.6.1.2.1.1.2
view systemonly included .1.3.6.1.2.1.1.6

# =====[PERMISOS-VISTAS]============================================================================================
# Permitir acceso de lectura para la vista definida
access readonly "" any noauth exact systemonly none none

# Permitir acceso de lectura y escritura para la vista definida
#access rwcommunity "" any noauth exact systemonly none none

# Permitir acceso de lectura y escritura con autenticación y cifrado para la vista definida
#access rwcommunity "" any authPriv exact all none none
EOF

systemctl start snmpd
systemctl enable snmpd

# Hora
# **************************************
timedatectl
ntpdate hora.roa.es
timedatectl set-timezone Europe/Madrid
# sincroniza la hora del servidor con el servidor horario oficial de España
echo -e "## actualizacion de hora \n00 6 * * * /usr/sbin/ntpdate -s hora.roa.es" >> /var/spool/cron/crontabs/root

# SAR Habilitamos monitorizacion
# **************************************
sed -i 's/ENABLED="false"/ENABLED="true"/g' /etc/default/sysstat
systemctl enable sysstat
systemctl start sysstat

# Cambiar nombre tarjeta de red
# **************************************
# Comprobamos que tarjeta de red vamos a renombrar
# dmesg | grep -i eth

# Deshabilitamos el renombrado de interfaces en /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/g' /etc/default/grub

# Regeneramos el archivo de grub
grub-mkconfig -o /boot/grub/grub.cfg

# Modificamos el archivo /etc/network/interfaces reemplazando ens33 por eth0
# auto eth0
mv /etc/network/interfaces /etc/network/_interfaces.ori
touch /etc/network/interfaces
cat <<EOF > /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth0
iface eth0  inet dhcp
EOF

# editor de texto por defecto
# **************************************
# modifico el editor por defecto del sistema para muchas aplicaciones (como crontab)
# Para el usuario actual
echo "export VISUAL=vim" >> ~/.bashrc
echo "export EDITOR=vim" >> ~/.bashrc
# Para root (si usas sudo crontab -e)
sudo bash -c 'echo "export VISUAL=vim" >> /root/.bashrc'
sudo bash -c 'echo "export EDITOR=vim" >> /root/.bashrc'
. "$HOME/.cargo/env"

# Deshabilitar IPv6
# **************************************
echo -e "# Deshabilitamos IPv6\nnet.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
sysctl -p

echo -e "\e[31m⚠️ ¡Listo! Los paquetes se instalaron y la configuración esta completa.\e[0m"
echo -e "\e[31m⚠️ Abre una nueva sesión para trabajar sobre los cambios.\e[0m"
