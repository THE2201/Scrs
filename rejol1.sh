#!/bin/sh

# Detectar sistema operativo
if [ -f /etc/lsb-release ] || [ -f /etc/debian_version ]; then
    OS="Ubuntu"
elif [ "$(uname)" = "FreeBSD" ]; then
    OS="FreeBSD"
else
    echo "Sistema operativo no compatible."
    exit 1
fi

# Verificar si 'dialog' está instalado
if ! command -v dialog >/dev/null 2>&1; then
    echo "'dialog' no está instalado."
    if [ "$OS" = "Ubuntu" ]; then
        echo "Puedes instalarlo con:"
        echo "sudo apt update && sudo apt install dialog"
    elif [ "$OS" = "FreeBSD" ]; then
        echo "Puedes instalarlo con:"
        echo "sudo pkg install dialog"
    fi
    exit 1
fi

# Bucle infinito: cada minuto, la barra se reinicia
barra=""
while true; do
    for i in $(seq 1 60); do
        hora_actual=$(date +"%H:%M:%S")
        barra="${barra}|"
        mensaje="Segundos:\n$barra\n\nHora actual: $hora_actual"
        dialog --title "Reloj de Segundos" --infobox "$mensaje" 10 80
        sleep 1
    done
    barra=""
done
