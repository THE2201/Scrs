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

# Verificar si 'dialog' esta instalado
if ! command -v dialog >/dev/null 2>&1; then
    echo "'dialog' no esta instalado. Por favor instalalo primero:"
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

        # Calculo porcentaje para barras
        porcentaje_hora=$((hora * 100 / 23))
        porcentaje_minuto=$((minuto * 100 / 59))
        porcentaje_segundo=$((segundo * 100 / 59))

        # Mostrar ventana con tres barras de progreso y hora digital
        {
            echo "XXX"
            echo "$porcentaje_hora"
            echo "Horas: $hora / 23"
            echo "XXX"
            echo "$porcentaje_minuto"
            echo "Minutos: $minuto / 59"
            echo "XXX"
            echo "$porcentaje_segundo"
            echo "Segundos: $segundo / 59"
            echo "XXX"
        } | dialog --title "Reloj Visual" --gauge "Hora actual: $hora:$minuto:$segundo" 15 60 0

        sleep 1
    done
}

mostrar_reloj
