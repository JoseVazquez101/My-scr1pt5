#!/bin/bash

function ctrl_c(){
  echo -e "\n\n[!] Saliendo..."
  exit 1
}

trap ctrl_c INT

process=$(ps -eo user,command)

while true; do
  current_pr=$(ps -eo user,command)
  diff <(echo "$process") <(echo "$current_pr") | grep "[\>\<]" | grep -vE "command|kworker|procron"
  process=$current_pr
done
