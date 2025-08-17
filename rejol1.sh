#!/bin/bash

# Verificar que 'dialog' esté instalado
if ! command -v dialog >/dev/null 2>&1; then
    echo "'dialog' no está instalado. Por favor instalalo primero."
    exit 1
fi


barra=""
while true; do
    for ((i=1; i<=60; i++)); do
        hora_actual=$(date +"%H:%M:%S")
        barra+="|"
        mensaje="Segundos:\n$barra\n\nHora actual: $hora_actual"
        dialog --title "Reloj de Segundos" --infobox "$mensaje" 10 80
        sleep 1
    done
    barra=""
done
