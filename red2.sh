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

# Verificar si dialog está instalado
if ! command -v dialog >/dev/null 2>&1; then
    echo "'dialog' no está instalado."
    if [ "$OS" = "Ubuntu" ]; then
        echo "sudo apt update && sudo apt install dialog"
    elif [ "$OS" = "FreeBSD" ]; then
        echo "pkg install dialog4ports"
    fi
    exit 1
fi

# Pedir interfaz de red al usuario
echo "Introduce el nombre de la interfaz de red (ej. eth0, enp0s3, em0):"
read INTERFAZ

# Verificar que la interfaz exista
if [ "$OS" = "Ubuntu" ]; then
    if ! grep -q "$INTERFAZ" /proc/net/dev; then
        echo "Interfaz no encontrada en /proc/net/dev"
        exit 1
    fi
elif [ "$OS" = "FreeBSD" ]; then
    if ! ifconfig "$INTERFAZ" >/dev/null 2>&1; then
        echo "Interfaz no encontrada"
        exit 1
    fi
fi

# Obtener tráfico de red (bytes) y calcular velocidad
obtener_bytes_linux() {
    awk -v iface="$INTERFAZ" '$0 ~ iface {gsub(":", "", $1); print $2, $10}' /proc/net/dev
}

obtener_bytes_freebsd() {
    netstat -I "$INTERFAZ" -n -b | awk 'NR==2 {print $7, $10}'
}

mostrar_trafico() {
    while true; do
        if [ "$OS" = "Ubuntu" ]; then
            read rx1 tx1 <<EOF
$(obtener_bytes_linux)
EOF
        else
            read rx1 tx1 <<EOF
$(obtener_bytes_freebsd)
EOF
        fi

        sleep 1

        if [ "$OS" = "Ubuntu" ]; then
            read rx2 tx2 <<EOF
$(obtener_bytes_linux)
EOF
        else
            read rx2 tx2 <<EOF
$(obtener_bytes_freebsd)
EOF
        fi

        rx_diff=$((rx2 - rx1))
        tx_diff=$((tx2 - tx1))

        # Convertir a Kbps (aproximado)
        rx_kbps=$((rx_diff * 8 / 1024))
        tx_kbps=$((tx_diff * 8 / 1024))

        # Limitar barra a 100 Mbps = 100000 Kbps
        rx_pct=$((rx_kbps * 100 / 100000))
        tx_pct=$((tx_kbps * 100 / 100000))

        [ "$rx_pct" -gt 100 ] && rx_pct=100
        [ "$tx_pct" -gt 100 ] && tx_pct=100

        (
            echo "XXX"
            echo "$rx_pct"
            echo "Velocidad de descarga (RX): ${rx_kbps} Kbps"
            echo "XXX"
            echo "$tx_pct"
            echo "Velocidad de subida (TX): ${tx_kbps} Kbps"
            echo "XXX"
        ) | dialog --title "Monitor de Tráfico de Red - $INTERFAZ" \
            --gauge "Midiendo tráfico..." 15 60 0

    done
}
mostrar_trafico
