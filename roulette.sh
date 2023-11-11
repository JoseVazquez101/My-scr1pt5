#!/bin/bash

red='\033[1;31m'
orange='\033[1;38;5;208m'
green='\033[1;32m'
yellow='\033[1;33m'
blue='\033[1;34m'
purple='\033[1;35m'
aqua='\033[1;36m'
white='\033[1;37m'
gray='\033[1;30m'
normal='\033[0m'

declare -i count=0
declare -i count_bad=0
bad_plays="[ "

function ctrl_c() {
  echo
  echo -e "${yellow}[+]${normal} ${gray}Jugadas:${normal}" ${green}${count}${normal}
  echo -e "${yellow}[+]${normal} ${gray}Dinero generado:${normal} ${green}$actual_money${normal}"
  echo -e "${red}\n\n[!] Saliendo...${normal}"
  exit 1
}
trap ctrl_c INT

function helpPanel() {
  echo -e "\n${yellow}[+]${white} Uso de parametros para '${0}': ${normal}" | tr -d '.sh' | tr -d './'
  echo
  echo -e "${purple}\t-h${normal}${gray} Desplegar menu de ayuda ${normal}"
  echo -e "${purple}\t-m${normal}${gray} Ingresar cantidad de dinero inicial ${normal}"
  echo -e "${purple}\t-t${normal}${gray} Seleccionar la tecnica [ M (Martingala) L (Labouchere) ]${normal}"
}

function Martingala() {
  startMoney=$1
  flag=false
  echo
  echo -e "${yellow}[+]${normal} ${gray}Tecnica:${normal} ${orange}Martingala${normal}"
  echo -e "${yellow}[+]${normal} ${gray}Dinero:${normal} ${green}${startMoney}$ ${normal}"
  echo -ne "${yellow}[-]${normal} ${gray}Cantidad de apuesta: ${normal}" && read apuesta1
  while [ $startMoney -lt $apuesta1 ]; do
    echo -e "${red}[!] ERROR: No apuestes lo que no tienes xd${normal}"
    echo -ne "${yellow}[-]${normal} ${gray}Cantidad de apuesta: ${normal}" && read apuesta1
  done
  while [ "$flag" == false ]; do
    echo -ne "${yellow}[-]${normal} ${gray}Tipo de apuesta [ (par)/(impar) ]:${normal} " && read opt
    if [ "$opt" == "par" ] || [ "$opt" == "impar" ]; then
      flag=true
    else
      echo -e "${red}[!] ERROR: Opción inexistente (par/impar)${normal}"
    fi
  done
  echo
  echo -e "${green}[+]${normal} ${gray}Apostando${normal} ${green}${apuesta1}$ ${normal}a jugada ${green}$opt${normal}"
  echo

  actual_money=$startMoney
  apuesta_original=$apuesta1
  while true; do
    echo -e "${green}[+]${normal} ${gray}Dinero actual:${normal} ${green}${actual_money}${normal}"
    echo -e "${green}[+]${normal} ${gray}Apostando:${normal} ${green}${apuesta1}${normal}"
    ran=$(($RANDOM % 37))
    echo -e "${yellow}[+]${normal} ${gray}Casilla en${normal} ${green}$ran${normal}"

    if [ ! "$actual_money" -le 0  ]; then
      if [ "$opt" == "par" ]; then
        if [ "$(($ran % 2))" -eq 0 ]; then
          if [ "$ran" -eq 0 ]; then
            echo -e "\t${yellow}--${normal}${red} Fuera de la apuesta, ¡Perdiste! -> ${apuesta1}${normal}\n"
            actual_money=$(($actual_money-$apuesta1))
            apuesta1=$(($apuesta1*2))
            count_bad+=1
            bad_plays+=" $ran ,"
          else
            reward=$(($apuesta1*2))
            actual_money=$(($actual_money-$apuesta1))
            echo -e "\t${yellow}--${normal}${green} Par, ¡Ganas! -> ${reward}${normal}\n"
            actual_money=$(($actual_money+$reward))
            apuesta1=$apuesta_original
            count_bad=0
            bad_plays=""
          fi
        else
            echo -e "\t${yellow}--${normal}${red} Impar, ¡Perdiste! -> ${apuesta1}${normal}\n"
            actual_money=$(($actual_money-$apuesta1))
            apuesta1=$(($apuesta1*2))
            count_bad+=1
            bad_plays+=" $ran, "
        fi
      else
        if [ "$(($ran % 2))" -eq 1 ]; then
          if [ "$ran" -eq 0 ]; then
            echo -e "\t${yellow}--${normal}${red} Fuera de la apuesta, ¡Perdiste! -> ${apuesta1}${normal}"
            actual_money=$(($actual_money-$apuesta1))
            apuesta1=$(($apuesta1*2))
            count_bad+=1
            bad_plays+=" $ran ,"
          else
            reward=$(($apuesta1*2))
            actual_money=$(($actual_money-$apuesta1))
            echo -e "\t${yellow}--${normal}${green} Par, ¡Ganas! -> ${reward}${normal}\n"
            actual_money=$(($actual_money+$reward))
            apuesta1=$apuesta_original
            count_bad=0
            bad_plays=""
          fi
        else
            echo -e "\t${yellow}--${normal}${red} Par, ¡Perdiste! -> ${apuesta1}${normal}\n"
            actual_money=$(($actual_money-$apuesta1))
            apuesta1=$(($apuesta1*2))
            count_bad+=1
            bad_plays+=" $ran, "
        fi
      fi
      count+=1
      sleep 0
    else
      echo -e "\n${red}[!] Te has quedado sin pasta bastardo xd\n${normal}"
      echo -e "${yellow}[+]${normal} ${gray}Jugadas:${normal}" ${green}${count}${normal}
      echo -e "${yellow}[+]${normal} ${gray}Jugadas malas consecutivas:${normal}" ${red}${count_bad}${normal}
      echo -e "${yellow}[+]${normal} ${gray}Adeudo:${normal} ${green}$actual_money${normal}"
      echo -e "${yellow}[+]${normal} ${gray}Casillas malas consecutivas:${normal}${red} ${bad_plays}${normal}"
      echo -e "${red}\n[!] Saliendo...${normal}"
      exit 0
    fi
  done
}

###############################################################################################################################
###############################################################################################################################
########################################################################################################################################################################################################################################################################

function Labouchere() {
  startMoney=$1
  flag=false
  flag1=false
  echo
  echo -e "${yellow}[+]${normal} ${gray}Técnica:${normal} ${orange}Labouchere${normal}"
  echo -e "${yellow}[+]${normal} ${gray}Dinero:${normal} ${green}${startMoney}$ ${normal}"
  echo -ne "${yellow}[-]${normal} ${gray}Rango seguro de reinicio:${normal} " && read rango

  while [ "$flag1" == false ]; do
    echo -ne "${yellow}[-]${normal} ${gray}Activar apuesta segura (s/n):${normal} " && read secure
    if [ "$secure" == "s" ] || [ "$secure" == "n" ]; then
      flag1=true
    else
      echo -e "${red}[!] ERROR: Opción inexistente (s/n)${normal}"
    fi
  done

  while [ "$flag" == false ]; do
    echo -ne "${yellow}[-]${normal} ${gray}Tipo de apuesta [ (par)/(impar) ]:${normal} " && read opt
    if [ "$opt" == "par" ] || [ "$opt" == "impar" ]; then
      flag=true
    else
      echo -e "${red}[!] ERROR: Opción inexistente (par/impar)${normal}"
    fi
  done

  echo
  declare -a sequence=(1 2 3 4)
  declare -i apuesta1=$((sequence[0]+sequence[-1]))
  declare -i renew_ap=$(($startMoney+$rango)) #Indicador para renovar secuencia a 1234
  declare -i count_restart=0
  declare -i rest_ap=$(($rango*2))
  echo -e "${green}[+]${normal} ${gray}Secuencia:${normal} ${green}[${sequence[@]}] ${normal}"
  echo -e "${green}[+]${normal} ${gray}Apostando${normal} ${green}${apuesta1}$ ${normal}a jugada ${green}${opt}${normal}"
  echo

  actual_money=$startMoney
  apuesta_original=$apuesta1
  count=0
  count_bad=0
  bad_plays=""
  reset_plays=""

  while true; do
    if [ ${#sequence[@]} -le 1 ]; then
      if [ ${#sequence[@]} -eq 0 ]; then
        sequence=(1 2 3 4)
        apuesta1=$((sequence[0]+sequence[-1]))
        echo -e "\t${orange}--${normal}${red} Reestableciendo secuencia a -> ${sequence[@]}${normal}\n"
      else
        apuesta1=${sequence[0]}
      fi
    else
      apuesta1=$((sequence[0]+sequence[-1]))
    fi
    echo -e "${green}[+]${normal} ${gray}Dinero actual:${normal} ${green}${actual_money}${normal}"
    echo -e "${green}[+]${normal} ${gray}Apostando:${normal} ${green}${apuesta1}${normal}"
    echo -e "${green}[+]${normal} ${gray}Tope para renovar en:${normal} ${green}${renew_ap}${normal}"
    ran=$((RANDOM % 37))
    echo -e "${yellow}[+]${normal} ${gray}Casilla en${normal} ${green}${ran}${normal}"

    if [ ! "$actual_money" -le 0 ]; then
      if [ "$opt" == "par" ]; then
        if [ $(($ran % 2)) -eq 0 ] && [ $ran -ne 0 ]; then
          reward=$(($apuesta1*2))
          actual_money=$(($actual_money-$apuesta1))
          actual_money=$(($actual_money+$reward))
          sequence+=($apuesta1)
          echo -e "\t${yellow}--${normal}${green} Par, ¡Ganas! -> ${reward}${normal}"
          echo -e "\t${yellow}--${normal}${gray} Nueva secuencia -> [${sequence[@]}]${normal}\n"
          count_bad=0
          bad_plays=""
        else
          actual_money=$(($actual_money-$apuesta1))
          unset 'sequence[0]'
          unset 'sequence[-1]' 2>/dev/null
          sequence=("${sequence[@]}")
          echo -e "\t${yellow}--${normal}${red} Impar, ¡Perdiste! -> ${apuesta1}${normal}"
          echo -e "\t${yellow}--${normal}${gray} Nueva secuencia -> [${sequence[@]}]${normal}\n"
          count_bad+=1
          bad_plays+=" $ran,"
        fi
      else
        if [ $(($ran % 2)) -eq 1 ]; then
          reward=$(($apuesta1*2))
          actual_money=$(($actual_money-$apuesta1))
          actual_money=$(($actual_money+$reward))
          sequence+=($apuesta1)
          echo -e "\t${yellow}--${normal}${green} Impar, ¡Ganas! -> ${reward}${normal}"
          echo -e "\t${yellow}--${normal}${gray} Nueva secuencia -> [${sequence[@]}]${normal}\n"
          count_bad=0
          bad_plays=""
        else
          actual_money=$(($actual_money-$apuesta1))
          unset 'sequence[0]'
          unset 'sequence[-1]' 2>/dev/null
          sequence=("${sequence[@]}")
          echo -e "\t${yellow}--${normal}${red} Par, ¡Perdiste! -> ${apuesta1}${normal}"
          echo -e "\t${yellow}--${normal}${gray} Nueva secuencia -> [${sequence[@]}]${normal}\n"
          count_bad+=1
          bad_plays+=" $ran,"
        fi
      fi
      count+=1
      sleep 0
    else
      echo -e "\n${red}[!] Te has quedado sin pasta bastardo xd\n${normal}"
      echo -e "${yellow}[+]${normal} ${gray}Jugadas:${normal}" ${green}${count}${normal}
      echo -e "${yellow}[+]${normal} ${gray}Adeudo:${normal} ${green}$actual_money${normal}"
      echo -e "${yellow}[+]${normal} ${gray}Reinicios:${normal}" ${orange}${count_restart}${normal}
      echo -e "${yellow}[+]${normal} ${gray}Jugadas de reinicio:${normal}${orange} ${reset_plays}${normal}"
      echo -e "${yellow}[+]${normal} ${gray}Jugadas malas consecutivas:${normal}" ${red}${count_bad}${normal}
      echo -e "${yellow}[+]${normal} ${gray}Casillas malas consecutivas:${normal}${red} ${bad_plays}${normal}"
      echo -e "${red}\n[!] Saliendo...${normal}"
      exit 0
    fi
    if [ $actual_money -gt $renew_ap ]; then
      reset_plays+=" $count,"
      count_restart+=1
      renew_ap+=$rango
      sequence=(1 2 3 4)
      apuesta1=$((sequence[0]+sequence[-1]))
      echo -e "\t${orange}-- RANGO SEGURO ALCANZADO: ${normal}${red} Reestableciendo secuencia a -> ${sequence[@]}${normal}\n"
    else
      if [ "$secure" == "s" ] && [ $actual_money -lt $(($renew_ap-$rest_ap)) ]; then
        renew_ap=$(($renew_ap-$rest_ap))
        apuesta1=$((sequence[0]+sequence[-1]))
        echo -e "\t${orange}-- DISMINUCIÓN CRITICA: ${normal}${red} Reajustando reinicio a -> ${renew_ap}${normal}\n"
      fi
    fi
  done
}


while getopts "m:t:h" arg; do
  case $arg in
    h) ;;
    m) startMoney=$OPTARG;;
    t) case $OPTARG in
        M) selecTec="Martingala";;
        L) selecTec="Labouchere";;
      esac;;
  esac
done

if [ $startMoney ] && [ "$selecTec" ]; then
  if [ "$selecTec" == "Martingala"  ]; then
    Martingala $startMoney
  elif [ "$selecTec" == "Labouchere" ]; then
    Labouchere $startMoney
  else
    echo
    echo -e "${red}[!] ERROR: La tecnica no existe${normal}"
    helpPanel
  fi
else
  helpPanel
fi
