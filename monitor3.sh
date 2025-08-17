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

# Verificar si dialog
if ! command -v dialog >/dev/null 2>&1; then
    echo "'dialog' no está instalado."
    if [ "$OS" = "Ubuntu" ]; then
        echo "sudo apt update && sudo apt install dialog"
    elif [ "$OS" = "FreeBSD" ]; then
        echo "pkg install dialog4ports"
    fi
    exit 1
fi

# Función para obtener datos en Ubuntu
get_stats_ubuntu() {
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
    MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
    MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
    MEM_FREE=$(free -m | awk '/Mem:/ {print $4}')
}

# Función para obtener datos en FreeBSD
get_stats_freebsd() {
    CPU_IDLE=$(top -d1 -n1 | grep "CPU" | awk -F'idle' '{print $1}' | awk '{print $NF}')
    CPU_USAGE=$(echo "scale=2; 100 - $CPU_IDLE" | bc)
    
    MEM_TOTAL=$(sysctl -n hw.physmem | awk '{print int($1 / 1048576)}') # Bytes a MB
    MEM_FREE=$(vmstat | awk 'NR==3 {print int($5 / 1024)}') # en KB, convertir a MB
    MEM_USED=$((MEM_TOTAL - MEM_FREE))
}

# Mostrar dialogo continuamente
while true; do
    if [ "$OS" = "Ubuntu" ]; then
        get_stats_ubuntu
    else
        get_stats_freebsd
    fi

    dialog --title "Uso del Sistema" --clear --msgbox \
"USO DE RECURSOS DEL SISTEMA

CPU en uso:      ${CPU_USAGE}% 

Memoria Total:   ${MEM_TOTAL} MB
Memoria Usada:   ${MEM_USED} MB
Memoria Libre:   ${MEM_FREE} MB" \
    15 50

    sleep 3
done
