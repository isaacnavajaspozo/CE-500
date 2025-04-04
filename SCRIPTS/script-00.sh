# Instalación de paquetes iniciales
echo "Instalando paquetes..."
apt-get update
apt-get install systemd systemctl systemd-sysv -y
apt-get install -y iputils-ping lm-sensors iproute2 sudo vim systemctl net-tools

# Configuración de sensores
echo "Configurando sensores:"
sensors-detect --auto
systemctl restart lm-sensors

# Configuro bashrc
cat <<EOF > ~/.bashrc
## alias del servidor
alias ls='ls --color=auto'
alias la='ls $LS_OPTIONS -lhai'
alias _liberarespacioram='sudo sync; echo 1 | sudo tee /proc/sys/vm/drop_caches | echo "petición realizada correctamente." && echo "" && free -h'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias grep='grep --color=auto'
alias df='df --exclude-type=tmpfs'

## Cambiar diseño del prompt
PS1='\[\e[0;90m\]r00t🐋\e[38;5;213m[\H]\e[38;5;213m\e[1;32m \w\e[0;37m $: '

## cambiar colores para ls
export LS_COLORS="di=1;32:fi=0;37:ln=1;35:so=0;38;5;208:pi=0;34:bd=0;33:cd=0;33:or=0;31:mi=0;31:ex=1;31"
EOF

## Configuración mínima de logs
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
localectl
localectl set-locale LANG=en_US.UTF-8
localectl

# Configuro vimrc
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

echo 'echo "Información del sistema::"' >> /etc/bash.bashrc
echo 'echo "CPU: $(grep -m1 "model name" /proc/cpuinfo | cut -d ":" -f2 | sed "s/^ //")"' >> /etc/bash.bashrc
echo 'echo "Memoria libre: $(free -h | awk '"'"'/^Mem:/ {print $7}'"'"')"' >> /etc/bash.bashrc
echo 'echo "Espacio en disco: $(df -h / | awk '"'"'$NF=="/"{print $4}'"'"')"' >> /etc/bash.bashrc
echo 'sensors 2>/dev/null || echo "No se detectaron sensores."' >> /etc/bash.bashrc
echo 'lsb_release -sd 2>/dev/null || echo "No LSB modules available."' >> /etc/bash.bashrc
echo 'uname -srm' >> /etc/bash.bashrc

# recargo el archivo bash.bashrc
source /etc/bash.bashrc


echo "¡Listo! Los paquetes se instalaron y la configuración está completa."
