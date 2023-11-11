#!/bin/bash

echo "Rango inicial: "
read r1

echo "Rango final: "
read r2

for id in $(seq $r1 $r2); do
  response=$(curl -s -X GET "http://localhost/users.php?id=$id" -I | grep 200)
  if [ "$response" ]; then
    echo -e "\n\n[+] RUTA -> http://localhost/users.php?id=$id - OK"
  fi
done
