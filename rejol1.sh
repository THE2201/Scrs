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

# Verificar dialog
if ! command -v dialog >/dev/null 2>&1; then
    echo "'dialog' no está instalado. Por favor instálalo primero:"
    if [ "$OS" = "Ubuntu" ]; then
        echo "sudo apt update && sudo apt install dialog"
    elif [ "$OS" = "FreeBSD" ]; then
        echo "pkg install dialog4ports"
    fi
    exit 1
fi

# Función para mostrar el reloj visual
mostrar_reloj() {
    while true; do
        hora=$(date +%H)
        minuto=$(date +%M)
        segundo=$(date +%S)

        hora=$((10#$hora))
        minuto=$((10#$minuto))
        segundo=$((10#$segundo))

        # Calcular porcentaje de segundos
        porcentaje_segundo=$((segundo * 100 / 59))

        #dialogo de hora
        dialog --title "Reloj Barra" \
               --gauge "Hora actual: $(printf "%02d" $hora):$(printf "%02d" $minuto):$(printf "%02d" $segundo)" \
               10 60 "$porcentaje_segundo"

        sleep 1
    done
}

mostrar_reloj
