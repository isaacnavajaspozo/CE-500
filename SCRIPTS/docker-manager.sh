#!/bin/bash

# Definir los contenedores disponibles
declare -A CONTAINERS
CONTAINERS=(
    [1]="vm1-samba"
    [2]="vm2-pentesting"
    [3]="vm3-bitwarden"
    [4]="vm4-greenbone"
    [5]="vm5-openedr"
    [6]="vm6-nginx"
    [7]="vm7-apache"
    [8]="vm8-nagios"
)

declare -A COMPOSE_FILES
COMPOSE_FILES=(
    [1]="/docker-compose/docker-compose-samba.yml"
    [2]="/docker-compose/docker-compose-pentesting.yml"
    [3]="/docker-compose/docker-compose-bitwarden.yml"
    [4]="/docker-compose/docker-compose-greenbone.yml"
    [5]="/docker-compose/docker-compose-openedr.yml"
    [6]="/docker-compose/docker-compose-nginx.yml"
    [7]="/docker-compose/docker-compose-apache.yml"
    [8]="/docker-compose/docker-compose-nagios.yml"
)

# Mostrar opciones
echo "Seleccione el contenedor a abrir:"
for i in "${!CONTAINERS[@]}"; do
    echo "$i) ${CONTAINERS[$i]}"
done

echo -n "Ingrese el número del contenedor: "
read CHOICE

# Validar la opción ingresada
if [[ -z "${CONTAINERS[$CHOICE]}" ]]; then
    echo "Opción no válida. Saliendo..."
    exit 1
fi

CONTAINER_NAME="${CONTAINERS[$CHOICE]}"
COMPOSE_FILE="${COMPOSE_FILES[$CHOICE]}"

echo -n "¿Quieres inicializar la máquina en segundo plano? (s/n): "
read BACKGROUND

if [[ "$BACKGROUND" == "s" ]]; then
    docker-compose -f "$COMPOSE_FILE" up -d
    echo "Contenedor $CONTAINER_NAME ejecutándose en segundo plano."
else
# tengo que agregar lógica para saber si esta ejecutandose en segundo plano que la pare
    echo "Saliendo..."
fi

echo -n "¿Quieres ejecutar la máquina desde bash? (s/n): "
read INTERACTIVE

# + Si está en ejecución    : se conecta al contenedor usando 'docker exec' y abre una terminal interactiva (bash).
# + Si no está en ejecución : lo inicia con 'docker start' y abre la terminal de forma interactiva.
if [[ "$INTERACTIVE" == "s" ]]; then
    if [[ "$(docker ps -q -f name=$CONTAINER_NAME)" ]]; then
        docker exec -it "$CONTAINER_NAME" bash
        exit 0
    else
        docker start -i "$CONTAINER_NAME"
    fi
fi

