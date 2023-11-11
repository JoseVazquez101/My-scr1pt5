#!/bin/bash

# Función para manejar la interrupción de Ctrl+C
red=""
hilos=10

function ctrl_c() {
  echo
  echo -e "${hilos}\n\n[!] Saliendo...${normal}"
  exit 1
}

trap ctrl_c INT

# Definir las funciones de escaneo
function scaner_basic() {
  red=$1
  for host in $(seq 1 254); do
    timeout 0.5 bash -c "ping -c 1 $red.$host >/dev/null" && echo "[+] Host ${red}.${host} activo" &
  done
  wait
}

function scaner() {
  local red=$1
  declare -i contador=0

  for host1 in $(seq 1 254); do
    for host2 in $(seq 1 254); do
      timeout 0.5 bash -c "ping -c 1 $red.$host1.$host2 >/dev/null" && echo "[+] Host ${red}.${host1}.${host2} activo" &

      contador+=1

      if [ $contador -eq $hilos ]; then
        wait
        contador=0
      fi
    done
  done
}

# Procesar los argumentos de línea de comandos
function help() {
  echo "Uso: ./nombre_del_script.sh -h <red> -t <hilos>"
  echo " -h <red>: Especifica la red a escanear (Ejemplo: -h 192.168.1)"
  echo " -t <hilos>: Especifica el número de hilos para el escaneo (Valor predeterminado: 10)"
  exit 1
}

if [ $# -eq 0 ]; then
  help
fi

if [ $# -ne 4 ]; then
  help
fi

if [ "$1" != "-h" ] || [ "$3" != "-t" ]; then
  help
fi

while getopts "h:t:" arg; do
  case $arg in
    h) red=$OPTARG ;;
    t) hilos=$OPTARG ;;
  esac
done

ip_identify=$(echo "$red" | awk -F. '{print NF-1}')

if [ $ip_identify -eq 1 ]; then
  scaner $red
elif [ $ip_identify -eq 2 ]; then
  scaner_basic $red
else
  echo -e "[!] ERROR: No se especificó la red"
  exit 1
fi

