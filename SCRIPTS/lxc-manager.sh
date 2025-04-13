#!/bin/bash

# Función para mostrar el menú
mostrar_menu() {
    # Mostrar estado actual de los contenedores
    echo "Estado actual de los contenedores:"
    lxc-ls --fancy
    echo ""

    echo " ____  __..__         .__ ___.             __      "
    echo "|    |/ _||__|_______ |__|\_ |__  _____   |  | __  ____"
    echo "|      /  |  |\_  __ \|  | | __ \ \__  \  |  |/ / /  _ \ "
    echo "|    |  \ |  | |  | \/|  | | \_\ \ / __ \_|    < (  <_> )"
    echo "|____|__ \|__| |__|   |__| |___  /(____  /|__|_ \ \____/ "
    echo "        \/                     \/      \/      \/        "

    # Mostrar menú de opciones
    echo "¿Qué deseas hacer?"
    echo "1) Crear una nueva máquina"
    echo "2) Iniciar una máquina en segundo plano"
    echo "3) Acceder a una máquina"
    echo "4) Parar una máquina"
    echo "5) Eliminar una máquina"
    echo "6) Salir"
    read -p "Elige una opción [1-6]: " opcion

    case $opcion in
        1)
            # Selección del tipo de sistema operativo
            echo "¿Qué sistema operativo deseas para la máquina?"
            echo "1) Debian"
            echo "2) Ubuntu"
            echo "3) Kali"
            read -p "Elige una opción [1-3]: " so

            case $so in
                1)
                    tipo_so="debian"
                    ;;
                2)
                    tipo_so="ubuntu"
                    ;;
                3)
                    tipo_so="kali"
                    ;;
                *)
                    echo "Opción no válida. Se usará Debian por defecto."
                    tipo_so="debian"
                    ;;
            esac

            # Nombre de la nueva máquina
            read -p "Introduce el nombre de la nueva máquina: " nombre
            sudo lxc-create -n "$nombre" -t "$tipo_so"
            ;;
        2)
            read -p "Introduce el nombre de la máquina a iniciar: " nombre
            sudo lxc-start -n "$nombre" -d
            ;;
        3)
            read -p "Introduce el nombre de la máquina a la que quieres acceder: " nombre
            sudo lxc-attach -n "$nombre"
            ;;
        4)
            read -p "Introduce el nombre de la máquina que deseas parar: " nombre
            sudo lxc-stop -n "$nombre"
            ;;
        5)
            read -p "Introduce el nombre de la máquina que deseas eliminar: " nombre
            sudo lxc-destroy -n "$nombre"
            ;;
        6)
            echo "Saliendo del script..."
            exit 0
            ;;
        *)
            echo "Opción no válida."
            ;;
    esac
}

# Bucle que muestra el menú hasta que el usuario decida salir
while true; do
    mostrar_menu
done
