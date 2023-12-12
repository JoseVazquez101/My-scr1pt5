#!/bin/bash

red=""
hilos=10

function ctrl_c() {
  echo
  echo -e "${hilos}\n\n[!] Saliendo...${normal}"
  exit 1
}

trap ctrl_c INT

function scaner_basic() {
  red=$1
    for host in $(seq 1 254); do
      timeout 0.5 bash -c "ping -c 1 $red.$host >/dev/null" && echo "[+] Host ${red}.${host} activo" &
    done; wait
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
