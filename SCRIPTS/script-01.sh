## versión de script-00.sh : versión 2
# Instalación de paquetes iniciales
echo "Instalando paquetes..."
apt-get update && apt-get upgrade -y

## Paquetes de ciberseguridad:
# Preguntar al usuario si quiere instalar paquetes de ciberseguridad
# -------------------------------------------------------------------
read -p "¿Deseas instalar paquetes de ciberseguridad como nmap john hydra...? (s/n): " respuestaCyber

if [[ "$respuestaCyber" == "s" || "$respuestaCyber" == "S" ]]; then
    apt install -y nmap john hydra sqlmap whatweb tshark exiftool
    echo "Paquetes de ciberseguridad instalados:"
    echo "nmap, john, hydra, sqlmap, whatweb, tshark y exiftool."
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
    # Solicitar el nuevo hostname
    read -p "Introduce el nuevo hostname (isaac.laboratory-00): " new_hostname

    # Modificar hostname
    sudo hostname "$new_hostname"

    # Hacer una copia de seguridad del archivo /etc/hostname
    sudo mv /etc/hostname /etc/hostname.old
    touch /etc/hostname

    # Escribir el nuevo hostname en /etc/hostname
    echo "$new_hostname" | sudo tee /etc/hostname > /dev/null
    echo "El hostname se ha cambiado a: $new_hostname"
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
PS1='\[\e[0;90m\]r00t箱\e[38;5;213m[\H]\e[38;5;213m\e[1;32m \w\e[0;37m $: '

## cambiar colores para ls (estilo cyberpunk)
# **************************************
export LS_COLORS="di=1;32:fi=0;37:ln=1;35:so=0;38;5;208:pi=0;34:bd=0;33:cd=0;33:or=0;31:mi=0;31:ex=1;31"

## función para escanear vulnerabilidades
# **************************************
_vuln_scan() {
  echo "[*] Esta función realiza un escaneo de vulnerabilidades sobre la IP especificada."
  read -p "Introduce la IP a escanear: " ip
  if [[ -z "$ip" ]]; then
    echo "[!] No se ha introducido una IP válida."
    return 1
  fi

  echo "[*] Escaneando $ip con Nmap + scripts de vulnerabilidades..."
  sudo nmap -sV --script vuln "$ip"
}
EOF

## Configuración mínima de logs
# **************************************
# Logrotate estandar para cualquier servidor (configuracion minima):
# Configura la rotación semanal, mantiene 54 semanas rotadas, agrega fechas a los nombres, comprime los logs antiguos y permite configuraciones adicionales desde /etc/logrotate.d.
cat  <<EOF > /etc/logrotate.conf
# logrotate.conf
weekly
rotate 54
dateext
compress
include /etc/logrotate.d
EOF
systemctl enable rsyslog
systemctl restart rsyslog

# Idioma
# **************************************
#localectl
#localectl set-locale LANG=en_US.UTF-8
#localectl

# Configuro vimrc (estilo cyberpunk)
# **************************************
cat <<EOF > ~/.vimrc
" configuración archivo .vimrc
set number
set cursorline
set scrolloff=8
set incsearch
set hlsearch
set ignorecase
set smartcase
set expandtab
set tabstop=4
set shiftwidth=4
set wildmenu
set foldmethod=indent
set foldlevel=99
syntax on
set background=dark
colorscheme industry
highlight Comment ctermfg=Green guifg=#00FF00
highlight LineNr ctermfg=Magenta
highlight CursorLineNr ctermfg=DarkMagenta
highlight Normal ctermfg=White ctermbg=DarkGray
highlight Keyword ctermfg=LightGray
highlight Function ctermfg=Yellow
highlight Type ctermfg=Magenta
highlight Constant ctermfg=Magenta
highlight Identifier ctermfg=White
highlight Statement ctermfg=Yellow
highlight Error ctermfg=White ctermbg=Red
highlight Search ctermfg=Black ctermbg=Yellow
highlight Visual ctermbg=Grey
highlight StatusLine ctermfg=Blue ctermbg=White
highlight StatusLineNC ctermfg=Blue ctermbg=DarkGray
highlight Special ctermfg=Blue
highlight PreProc ctermfg=Grey
highlight Todo ctermfg=Black ctermbg=Yellow
highlight Underlined ctermfg=White
highlight Pmenu ctermbg=DarkGray
highlight PmenuSel ctermbg=Blue ctermfg=White
highlight DiffAdd ctermbg=Green
highlight DiffChange ctermbg=Yellow
highlight DiffDelete ctermbg=Red
highlight Folded ctermfg=White ctermbg=DarkBlue
set laststatus=2
set noerrorbells
set history=1000
set clipboard=unnamedplus
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
syslocation "CPD"
syscontact "IT <informatica@isaacnavajas.es>"

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
# Solo exponer árbol de OID seguro
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

# HORA
# **************************************
timedatectl
ntpdate hora.roa.es
timedatectl set-timezone Europe/Madrid
echo -e "## Actualizacion de hora: \n00 6 * * * /usr/sbin/ntpdate -s hora.roa.es" >> /var/spool/cron/crontabs/root

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

# Deshabilitar IPv6
# **************************************
echo -e "# Deshabilitamos IPv6\nnet.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
sysctl -p

echo -e "\e[31m⚠️ Recuerda cambiar el host en /etc/hosts por el mismo que acabas de agregar en /etc/hostname\e[0m"
echo "¡Listo! Los paquetes se instalaron y la configuración está completa."
