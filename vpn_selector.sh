#!/bin/bash

function myip() {
  variable='Direcciones:'
  greenColour="\e[0;32m\033[1m"
  endColour="\033[0m\e[0m"
  redColour="\e[0;31m\033[1m"
  grayColour="\e[0;37m\033[1m"

  echo -e "\n${greenColour}$variable${endColour}"
  echo -e "${redColour}[+] Dirección IP privada: ${endColour}" $(ip a | grep wlan0 | tail -n1 | awk '{print $2}')
  vpn_exist=$(ip a | grep tun0 | tail -n 1 | awk '{print $2}')
  if [ ! $vpn_exist ]; then
    echo -ne "${redColour}[+] Dirección IP VPN: ${endColour}" "ERROR - No existe una VPN activa.\n¿Activar VPN? (s/n):" && read opcion
    if [ "$opcion" = "s" ]; then
      echo -ne "1-THM\n2-HTB\n¿Cual VPN?: " && read VPN
      if [ "$VPN" = "1" ]; then
        sudo openvpn /path/to/your/openvpn.ovpn &>/dev/null & disown
      elif [ "$VPN" = "2" ]; then
        sudo openvpn /path/to/your/openvpn.ovpn &>/dev/null & disown
      else
        echo "Opción inválida"
      fi
    fi
  else
    echo -ne "${redColour}[+] Dirección IP VPN: ${endColour}" $(ip a | grep tun0 | tail -n 1 | awk '{print $2}')
  fi
}

myip
