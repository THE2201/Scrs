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

# Verificar si dialog y dd estan instalados
if ! command -v dialog >/dev/null 2>&1; then
    echo "'dialog' no está instalado."
    if [ "$OS" = "Ubuntu" ]; then
        echo "sudo apt update && sudo apt install dialog"
    elif [ "$OS" = "FreeBSD" ]; then
        echo "pkg install dialog4ports"
    fi
    exit 1
fi

if ! command -v dd >/dev/null 2>&1; then
    echo "'dd' no está instalado."
    exit 1
fi

TESTFILE="/tmp/testfile_benchmark"
BS=1M
COUNT=512  # ~512 MB
TOTAL_MB=$((COUNT))

# Mostrar barra de progreso simulacion
mostrar_progreso() {
    for i in $(seq 1 100); do
        echo $i
        echo "$i%"
        sleep 0.02
    done
}

# Medir escritura
medir_escritura() {
    START=$(date +%s.%N)
    dd if=/dev/zero of="$TESTFILE" bs=$BS count=$COUNT conv=fsync status=none
    END=$(date +%s.%N)

    TIME=$(echo "$END - $START" | bc)
    WRITE_SPEED=$(echo "scale=2; $TOTAL_MB / $TIME" | bc)
}

# Medir lectura
medir_lectura() {
    START=$(date +%s.%N)
    dd if="$TESTFILE" of=/dev/null bs=$BS count=$COUNT status=none
    END=$(date +%s.%N)

    TIME=$(echo "$END - $START" | bc)
    READ_SPEED=$(echo "scale=2; $TOTAL_MB / $TIME" | bc)
}

# Comenzar prueba de escritura
(
    echo "XXX"
    echo "0"
    echo "Iniciando prueba de escritura..."
    echo "XXX"
    mostrar_progreso
) | dialog --title "Escribiendo archivo de prueba..." --gauge "Procesando..." 10 60 0

medir_escritura

# Comenzar prueba de lectura
(
    echo "XXX"
    echo "0"
    echo "Iniciando prueba de lectura..."
    echo "XXX"
    mostrar_progreso
) | dialog --title "Leyendo archivo de prueba..." --gauge "Procesando..." 10 60 0

medir_lectura

# Eliminar archivo temporal
rm -f "$TESTFILE"

# Mostrar resultados
dialog --title "Resultados de info de Disco" --msgbox \
"RESULTADOS

Velocidad de escritura: ${WRITE_SPEED} MB/s
Velocidad de le
