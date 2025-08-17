#!/bin/sh

# Detectar el sistema operativo
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
    echo "'dialog' no está instalado. Por favor instálalo primero:"
    if [ "$OS" = "Ubuntu" ]; then
        echo "sudo apt update && sudo apt install dialog"
    elif [ "$OS" = "FreeBSD" ]; then
        echo "pkg install dialog4ports"
    fi
    exit 1
fi

# Funcion para dibujar el reloj visual
mostrar_reloj() {
    while true; do
        hora=$(date +%H)
        minuto=$(date +%M)
        segundo=$(date +%S)

        # Crear contenido de la caja con 3 barras
        (
            echo "XXX"
            echo "$((hora * 100 / 23))"
            echo "Hora actual: $hora"
            echo "XXX"
            echo "$((minuto * 100 / 59))"
            echo "Minutos: $minuto"
            echo "XXX"
            echo "$((segundo * 100 / 59))"
            echo "Segundos: $segundo"
            echo "XXX"
        ) | dialog --title "Reloj Visual" --gauge "Simulando reloj..." 15 60 0

        sleep 1
    done
}

mostrar_reloj
