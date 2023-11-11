#!/bin/bash

########## Colores ##########
dark_yellow=$(tput setaf 3)
red=$(tput setaf 1)
orange=$(tput setaf 9)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
purple=$(tput setaf 5)
aqua=$(tput setaf 6)
white=$(tput setaf 7)
gray=$(tput setaf 8)
normal=$(tput sgr0)
##############################

echo -ne "\n"
echo -ne "████████╗██╗░░██╗██████╗░  ██╗░░██╗░█████╗░██████╗░██╗░░░██╗███████╗░██████╗████████╗██████╗░██████╗░\n" ;sleep 0.3
echo -ne "╚══██╔══╝██║░░██║╚════██╗  ██║░░██║██╔══██╗██╔══██╗██║░░░██║██╔════╝██╔════╝╚══██╔══╝╚════██╗██╔══██╗\n" ;sleep 0.3
echo -ne "░░░██║░░░███████║░█████╔╝  ███████║███████║██████╔╝╚██╗░██╔╝█████╗░░╚█████╗░░░░██║░░░░█████╔╝██████╔╝\n" ;sleep 0.3
echo -ne "░░░██║░░░██╔══██║░╚═══██╗  ██╔══██║██╔══██║██╔══██╗░╚████╔╝░██╔══╝░░░╚═══██╗░░░██║░░░░╚═══██╗██╔══██╗\n" ;sleep 0.3
echo -ne "░░░██║░░░██║░░██║██████╔╝  ██║░░██║██║░░██║██║░░██║░░╚██╔╝░░███████╗██████╔╝░░░██║░░░██████╔╝██║░░██║\n" ;sleep 0.3
echo -ne "\n\n"

uid=$(id | grep -o -P '\([^)]+\)' | tr -d '()' | head -n 1)
gid=$(id | grep -o -P '\([^)]+\)' | tr -d '()' | sed -n '2p')

echo -ne "Sudo password for $uid: "
read -s password_sudo
echo

if [[ -z "$password_sudo" ]]; then
  echo "[!] No se proporcionó contraseña."
else
  echo "[-] Contraseña proporcionada."
fi

#######################################################################################

function search_groups() {
  echo -ne "[+] Buscando grupos vulnerables...\n"
  grps=$(groups | tr ' ' '\n')
  sleep 1
  while read -r grp; do
    if [[ "$grps" == *"$grp"* ]]; then
      echo -ne "[-] El grup ${red}$grp${normal} parece ser vulnerable"
      echo -ne "\t--> Consulte https://gtfobins.github.io/gtfobins/${red}$grp${normal}/\n"
    fi
  done < "list.txt"
}

function search_SUID() {
  echo -ne "[+] Escaneando permisos SUID...\n"
  SUID=$(find / -perm -4000 2>/dev/null)

  while read -r command; do
    if [[ "$SUID" == *"$command"* ]]; then
      echo -ne "[-] El binario ${red}$command${normal} parece ser vulnerable"
      echo -ne "\t--> Consulte https://gtfobins.github.io/gtfobins/${red}$command${normal}/\n"
    fi
  done < "list.txt"
}


function search_GUID() {
  echo -ne "\n[+] Escaneando permisos GUID...\n"
  GUID=$(find / -perm -2000 2>/dev/null)

  while read -r command; do
    if [[ "$GUID" == *"$command"* ]]; then
      echo -ne "[-] El binario ${red}$command${normal} parece ser vulnerable"
      echo -ne "\t--> Consulte https://gtfobins.github.io/gtfobins/${red}$command${normal}/\n"
    fi
  done < "list.txt"
}

function seach_sudoers() {
  echo -ne "\n[+] Analizando sudoers"
  if [ $password_sudo ]; then
    echo -ne "\n[-] Utilizando contraseña ...\n"
    echo $password_sudo | sudo -S -l
  else
    echo -ne "\n[-] Ejecutando sin contraseña...\n"
    sudo -l
  fi
}

function port_listening() {
  echo -ne "\n[+] Analizando puertos en escucha..."
  netstat -nat
}

function search_world_writable() {
    echo -ne "\n[+] Buscando archivos y directorios world-writable...\n"
    find / -type f -writable -o -type d -writable 2>/dev/null
}

function services_as_root() {
    echo -ne "\n[+] Buscando servicios que corren como root...\n"
    ps aux | grep root
}

function search_cron_jobs() {
    echo -ne "\n[+] Buscando cron jobs...\n"
    for user in $(cat /etc/passwd | cut -f1 -d:); do
        crontab -l -u $user 2>/dev/null
    done
}

function check_path() {
    echo -ne "\n[+] Comprobando configuraciones de PATH...\n"
    echo $PATH | tr ':' '\n'
}

function search_setcap() {
    echo -ne "\n[+] Buscando binarios con permisos setcap...\n"
    getcap -r / 2>/dev/null
}

function search_w_r() {
  echo -ne "\n[-] Buscando ejecutables para el uid $uid\n"
  e_u=$(find / -user $uid -perm -u=x -type f 2>/dev/null | while read -r file; do ls -la "$file"; done |sed 's/root/'$red'&'$normal'/g')
  echo -ne "$e_u"
  echo -ne "\n[-] Buscando ejecutables para el gid $gid\n"
  e_g=$(find / -group $gid -perm -g=x -type f 2>/dev/null| while read -r file; do ls -la "$file"; done | sed 's/root/'$red'&'$normal'/g')
  echo -ne "$e_g"
  echo -ne "\n[-] Buscando escribibles para el uid $uid\n"
  es_u=$(find / -user $uid -perm -u=w -type f 2>/dev/null | while read -r file; do ls -la "$file"; done | sed 's/root/'$red'&'$normal'/g')
  echo -ne "$es_u"
  echo -ne "\n[-] Buscando escribibles para el gid $gid\n"
  es_g=$(find / -group $gid -perm -g=w -type f 2>/dev/null | while read -r file; do ls -la "$file"; done | sed 's/root/'$red'&'$normal'/g')
  echo -ne "$es_g"
  echo -ne "\n[-] Buscando escribibles para otros usuarios y ejecutables para root\n"
  r0t=$(find / -type f -perm -o=w -a -perm -u=x 2>/dev/null | while read -r file; do ls -la "$file"; done | sed 's/root/'$red'&'$normal'/g')
  echo -ne "r0t"
}

function possible_scalation() {
  echo -ne "\n[-] Posibles usuarios para escalar\n"
  possible_shells=("zsh" "bash" "sh")
  regex=$(IFS="|"; echo "${possible_shells[*]}")
  cat /etc/passwd | grep -E "\\b($regex)\\b" | cut -f1 -d:
}

function kernel_scan() {
  kern_v=$(uname -a | awk '{printf $3}')
  echo -ne "\n[-] Versión de Kernel: $kern_v\n"
}

function search_ssh_key() {
  echo -ne "\n[-] Buscando claves ssh...\n"
  find ~/.ssh/ -type f -name "*.pub" 2>/dev/null
  find / -type f -name id_rsa* 2>/dev/null
}

function search_pgp_key() {
  echo -ne "\n[-] Comprobando claves pgp registradas...\n"
  echo -ne "\t- Claves secretas ->";gpg --list-secret-keys
  echo -ne "\t- Claves genericas ->";gpg --list-keys
}

function port_sniffer() {
echo -ne "\n[-] Escaneando puertos internos...\n"
cat /proc/net/tcp | uniq -u | awk 'NR > 1 {print $2}' | awk -F ":" '{print $2}' | while read line; do
    if [[ $line != "0" ]]; then
        echo -ne "\t- Puerto $((16#$line)) abierto"
    fi
done
}

function online_users() {
  echo -ne "\n[-] Usuarios en linea\n"
  who
}

function private_ssh_key() {
  echo -ne "\n[-] Buscando claves ssh...\n"
  find ~/ -type f -name "id_rsa" -o -name "id_dsa" -o -name "id_ecdsa" -o -name "id_ed25519" -exec ls -l {} \; 2>/dev/null
}

function search_weird_archives() {
  echo -ne "\n[-] Buscando archivos sospechosos...\n"
  cred=$(find / -type f -name credential* 2>/dev/null | while read -r file; do ls -la "$file"; done | sed 's/credential/'$red'&'$normal'/g')
  echo -ne "$cred"
  passw=$(find / -type f -name passw* 2>/dev/null | while read -r file; do ls -la "$file"; done | sed 's/passw/'$red'&'$normal'/g')
  echo -ne "$passw"
  back=$(find / -type f -name backup* 2>/dev/null | while read -r file; do ls -la "$file"; done | sed 's/backup/'$red'&'$normal'/g')
  echo -ne "$back"
  dbse=$(find / -type f -name *.db 2>/dev/null | while read -r file; do ls -la "$file"; done | sed 's/db/'$red'&'$normal'/g')
  echo -ne "$dbse"
  sqlit=$(find / -type f -name *.sqlite 2>/dev/null | while read -r file; do ls -la "$file"; done | sed 's/sqlite/'$red'&'$normal'/g')
  echo -ne "$sqlit"
}

function dnsiffer() {
  echo -ne "\n[-] Configuración DNS en la maquina:\n";cat /etc/hosts
}

possible_scalation
echo
kernel_scan
echo
sud=$(sudo --version | head -n 1)
echo "[+] $sud"
echo
dnsiffer
echo
search_groups
echo
seach_sudoers
echo
search_SUID
echo
search_GUID
echo
port_listening
echo
#search_world_writable
echo
services_as_root
echo
search_cron_jobs
echo
check_path
echo
search_setcap
echo
#search_w_r
echo
search_ssh_key
echo
search_pgp_key
echo
port_sniffer
echo
online_users
echo
private_ssh_key
echo
search_weird_archives
