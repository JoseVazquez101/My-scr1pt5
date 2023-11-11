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

function ctrl_c() {
  echo -e "${red}\n\n[!] Saliendo...\n${normal}"
  exit 1
}
# Ctrl+c
trap ctrl_c INT

echo
echo
echo -e "${red}@@@  @@@  @@@@@@@  @@@@@@@   @@@@@@@@@@    @@@@@@   @@@@@@@${normal}" && sleep 0.2
echo -e "${red}@@@  @@@  @@@@@@@  @@@@@@@@  @@@@@@@@@@@  @@@@@@@@  @@@@@@@@${normal}" && sleep 0.2
echo -e "${red}@@!  @@@    @@!    @@!  @@@  @@! @@! @@!  @@!  @@@  @@!  @@@${normal}" && sleep 0.2
echo -e "${red}!@!  @!@    !@!    !@   @!@  !@! !@! !@!  !@!  @!@  !@!  @!@${normal}" && sleep 0.2
echo -e "${red}@!@!@!@!    @!!    @!@!@!@   @!! !!@ @!@  @!@!@!@!  @!@@!@!${normal}" && sleep 0.2
echo -e "${red}!!!@!!!!    !!!    !!!@!!!!  !@!   ! !@!  !!!@!!!!  !!@!!!${normal}" && sleep 0.2
echo -e "${red}!!:  !!!    !!:    !!:  !!!  !!:     !!:  !!:  !!!  !!:${normal}" && sleep 0.2
echo -e "${red}:!:  !:!    :!:    :!:  !:!  :!:     :!:  :!:  !:!  :!:${normal}" && sleep 0.2
echo -e "${red}::   :::     ::     :: ::::  :::     ::   ::   :::   ::${normal}" && sleep 0.2
echo -e "${red} :   : :     :     :: : ::    :      :     :   : :   :${normal}" && sleep 0.2


#Variables globales
main_url="https://htbmachines.github.io/bundle.js"

#Validador de programas necesarios
if  ! command -v js-beautify &>/dev/null; then
  echo -e "${orange}[!] Error: El binario 'js-beautify' no está instalado.${normal}"
  echo -e "${orange}[+]${normal}${gray} Para instalarlo en equipos Ubuntu desde apt, ejecute el siguiente comando"
  echo -e "${white}\tsudo apt install node-js-beautify${normal}"
  exit 1
fi
if ! command -v sponge &>/dev/null; then
  echo -e "${orange}[!] Error: El binario 'sponge' no está instalado.${normal}"
  echo -e "${orange}[+]${normal}${gray} Para instalarlo en equipos Ubuntu desde apt, ejecute el siguiente comando"
  echo -e "${white}\tsudo apt install moreutils${normal}"
fi

function helpPanel() {
  echo -e "\n${yellow}[+]${white} Uso de parametros: ${normal}"
  echo
  echo -e "${purple}\t-h${normal}${gray} Desplegar menu de ayuda ${normal}"
  echo -e "${purple}\t-u${normal}${gray} Actualizar archivos necesarios ${normal}"
  echo -e "${purple}\t-m${normal}${gray} Buscar datos por el nombre de la maquina ${normal}"
  echo -e "${purple}\t-i${normal}${gray} Filtrar las maquinas por IP ${normal}"
  echo -e "${purple}\t-d${normal}${gray} Filtrar las maquinas por dificultad [ F (Fácil) M (Media) D (Dificil) I (Insane) ]${normal}"
  echo -e "${purple}\t-s${normal}${gray} Filtrar las maquinas por Sistema Operativo [ L (Linux) W (Windows)]"
  echo -e "${purple}\t-k${normal}${gray} Filtra las maquinas por las skills empleadas ${normal}"
  echo -e "${purple}\t-y${normal}${gray} Abrir directamente el video en Youtube ${normal}"
}


function updateF() {
  echo -e "\n${yellow}[+]${normal} ${gray}Leyendo base de datos...\n${normal}"
  if [ ! -f /opt/htbmachines/bundle.js  ]; then
    echo -e "${red}[!] El archivo no existe, ¿Desea descargarlo desde $main_url? (s/n)${normal}"
    read -r op
    if [ "$op" = "s" ]; then
      echo -e "${green}\n[-]${normal}${gray} Descargando base de datos...${normal}"
      curl -s $main_url > bundle.js
      js-beautify /opt/htbmachines/bundle.js | sponge /opt/htbmachines/bundle.js
      echo -e "${green}\n[-] Base de datos descargada exitosamene!${normal}"
    fi
  else
    echo -e "${orange}[!] El archivo existe, comprobando actualizaciones${normal}\n"
    curl -s $main_url > /opt/htbmachines/bundle_temp.js
    js-beautify /opt/htbmachines/bundle_temp.js | sponge /opt/htbmachines/bundle_temp.js
    hashvalue=$(md5sum /opt/htbmachines/bundle_temp.js | awk '{print $1}')
    firsthash=$(md5sum /opt/htbmachines/bundle.js | awk '{print $1}')
    if [ "$hashvalue" == "$firsthash" ]; then
      echo -e "${green}[-]${normal}${gray} No hay actualizaciones disponibles, todo OK ;D${normal}"
      rm /opt/htbmachines/bundle_temp.js
    else
      echo -e "${orange}[!]${normal}${gray} Actualizaciones disponibles, descargando de $main_url${normal}"
      rm /opt/htbmachines/bundle.js && mv /opt/htbmachines/bundle_temp.js /opt/htbmachines/bundle.js
    fi
  fi
}

######### BUSCADOR ##########
function searchMach() {
  machName="$1"
  machInfo=$(cat /opt/htbmachines/bundle.js | awk "/name: \"$machName\"/,/youtube:/"  | tr -d '"' | tr -d ',' | sed 's/^ *//')
  if [ "$machInfo" ]; then
  echo
  echo -e "\n${green}[+]${normal} ${gray}Listando datos de la maquina${normal}${green} ${machName}${normal}"
  sleep 1
  echo
  echo -e "${orange}[-] Nombre:${normal} $(echo "$machInfo" | awk -F ':' '/name:/ {print $2}')"
  echo -e "${orange}[-] IP:${normal} $(echo "$machInfo" | awk -F ':' '/ip:/ {print $2}')"
  echo -e "${orange}[-] SO:${normal} $(echo "$machInfo" | awk -F ':' '/so:/ {print $2}')"
  echo -e "${orange}[-] Dificultad:${normal} $(echo "$machInfo" | awk -F ':' '/dificultad:/ {print $2}')"
  echo -e "${orange}[-] Skills:${normal}"
  echo "$machInfo" | awk '/skills:/ { sub("skills: ", ""); print $0 }'
  echo -n -e "${orange}[-] Like:${normal} "
  echo "$machInfo" | awk -F ':' '/like:/ { sub("like: ", ""); print $0 }'
  echo -e "${orange}[-] Video:${normal} $(echo "$machInfo" | awk -F ': ' '/youtube:/ {print substr($0, index($0,$2))}')"
  else
    echo -e "\n${red}[!]${normal} ${gray}No existe la maquina${normal}${aqua} ${machName}${normal}"
  fi
}

####### IP ######
function findIP() {
  IPaddr="$1"
  echo -e "\n${yellow}[+]${normal} ${gray}Buscando maquinas con IP ${IPaddr}...${normal}"
  IPname=$(cat /opt/htbmachines/bundle.js| grep "ip: \"$IPaddr\"" -B 3 |grep "name:"| grep -vE "id|sku:" | tr -d '"' | tr -d ',' | head -n 1 | awk '{print $2}')
  if [ "$IPname" ]; then
    sleep 1
    echo -e "\n${yellow}[-]${normal} ${gray}La maquina ${normal}${aqua}$IPname${normal} ${gray}está enlazada a ${normal}${aqua}$IPaddr${normal}"
  else
    sleep 1
    echo -e "\n${red}[!] ERROR:${normal}${gray} No existe maquina enlazada a ${normal}${aqua}$IPaddr${normal}"
  fi
}

###### Youtube ######
function YTlink() {
  linkname="$1"
  link=$(cat /opt/htbmachines/bundle.js | awk "/name: \"$linkname\"/,/resuelta:/" | grep -vE "id|sku|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')
  if [ $link ]; then
    echo -e "\n${yellow}[+]${normal} ${gray}Abrriendo${normal} ${aqua}$link${normal} ${gray}en Firefox...${normal}"
    sleep 1
    firefox "$link"
  else
    echo -e "\n${red}[!]${normal} ${gray}No existe video para la maquina${normal} ${aqua}$linkname${normal}"
  fi
}

###### Dificultad ######
function dificult() {
  Selecdif="$1"
  Result=$(cat /opt/htbmachines/bundle.js | grep "dificultad: \"$Selecdif\"" -B 5 | grep name | awk '{print $2}' | tr -d '"' | tr -d ',' | column)
  if [ "$Result" ]; then
    color=""
    case "$Selecdif" in
      "Fácil") color="${green}" ;;
      "Media") color="${yellow}" ;;
      "Difícil") color="${orange}" ;;
      "Insane") color="${red}" ;;
      *) echo -e "\n${red}[!] Error:${normal} ${gray}No existe esa dificultad${normal}"
         echo -e "${purple}\t-d${normal} ${red}F ${normal}${white}-> Fácil ${normal}"
         echo -e "${purple}\t-d${normal} ${red}M ${normal}${white}-> Media ${normal}"
         echo -e "${purple}\t-d${normal} ${red}D ${normal}${white}-> Difícil ${normal}"
         echo -e "${purple}\t-d${normal} ${red}I ${normal}${white}-> Insane ${normal}"
         return ;;
    esac
    echo -e "\n${yellow}[+]${normal} ${gray}Buscando máquinas de dificultad${normal} ${color}${Selecdif}${normal}"
    sleep 1
    echo
    cat /opt/htbmachines/bundle.js | grep "dificultad: \"$Selecdif\"" -B 5 | grep name | awk '{print $2}' | tr -d '"' | tr -d ',' | column
  else
    echo -e "\n${red}[!] Error:${normal} ${gray}No existe esa dificultad${normal}"
    echo -e "${purple}\t-d${normal} ${red}F ${normal}${white}-> Fácil ${normal}"
    echo -e "${purple}\t-d${normal} ${red}M ${normal}${white}-> Media ${normal}"
    echo -e "${purple}\t-d${normal} ${red}D ${normal}${white}-> Difícil ${normal}"
    echo -e "${purple}\t-d${normal} ${red}I ${normal}${white}-> Insane ${normal}"
  fi
}

####### OS #######
function System() {
  selectOS="$1"
  OSfind=$(cat /opt/htbmachines/bundle.js| grep "so: \"$selectOS\"" -B 5 | grep name | awk '{print $2}' | tr -d '"' | tr -d ',' | column)
  if [ "$selectOS" ]; then
    color=""
    case "$selecOS" in
      "Linux") color="${aqua}" ;;
      "Windows") color="${yellow}" ;;
      *) echo -e "\n${red}[!] Error:${normal} ${gray}No existen maquinas basadas en ese OS${normal}"
         echo -e "${purple}\t-s${normal} ${red}L ${normal}${white}-> Linux ${normal}"
         echo -e "${purple}\t-s${normal} ${red}W ${normal}${white}-> Windows ${normal}"
    return ;;
   esac
      echo -e "\n${yellow}[+]${normal} ${gray}Buscando maquinas con OS:${normal} ${color}${selectOS}${normal}"
      sleep 1
      echo
      cat /opt/htbmachines/bundle.js| grep "so: \"$selectOS\"" -B 5 | grep name | awk '{print $2}' | tr -d '"' | tr -d ',' | column
    else
    echo -e "\n${red}[!] Error:${normal} ${gray}No existen maquinas basadas en ese OS${normal}"
    echo -e "${purple}\t-s${normal} ${red}L ${normal}${white}-> Linux ${normal}"
    echo -e "${purple}\t-s${normal} ${red}W ${normal}${white}-> Windows ${normal}"
    fi
}

##### Combinacion de funciones xd #####
function OS_Dificult() {
  Selecdif="$1"
  selecOS="$2"
  if [ "$selecOS" ] && [ "$Selecdif" ]; then
    colorOS=""
    colorDif=""
    case "$selecOS" in
      "Linux") colorOS="${aqua}" ;;
      "Windows") colorOS="${yellow}" ;;
    esac

    case "$Selecdif" in
      "Fácil") colorDif="${green}" ;;
      "Media") colorDif="${yellow}" ;;
      "Difícil") colorDif="${orange}" ;;
      "Insane") colorDif="${red}" ;;
    esac
    echo
    echo -e "${yellow}[+]${normal} ${gray}Busqueda para SO${normal} ${colorOS}${selecOS}${normal} ${gray}en dificultad${normal} ${colorDif}${Selecdif}${normal}"
    echo
    sleep 1
    cat /opt/htbmachines/bundle.js| grep "so: \"$selecOS\"" -C 4 | grep "dificultad: \"$Selecdif\"" -B 5 | grep "name:" | awk '{print $2}' | tr -d '"' | tr -d ',' | column 
  else
    echo
    echo -e "${red}[!] ERROR:${normal}${white} Proporciona parametros para adecuados para ambas opciones${normal}"
  fi
}

function Skill() {
  skillName="$1"
  echo
  showSkill=$(cat bundle.js| grep "skills:" -B 6 | grep "$skillName" -i -B 6 | grep "name:" | awk '{print $2}' | tr -d '"' | tr -d ',' | column)
  if [ "$showSkill" ]; then
    echo -e "\n${yellow}[+]${normal} ${gray}Buscando maquinas con skills:${normal} ${orange}${skillName}${normal}"
    sleep 1
    echo
    cat bundle.js| grep "skills:" -B 6 | grep "$skillName" -i -B 6 | grep "name:" | awk '{print $2}' | tr -d '"' | tr -d ',' | column
  else
    echo -e "\n${red}[!] Error:${normal} ${gray}No existen maquinas con skills: ${skillName}${normal}"
  fi
}


### Parametros ###
declare -i parameterCount=0

### Parametros conjuntos ###
declare -i con_dif=0
declare -i con_so=0

while getopts "m:hi:y:d:s:k:u" arg; do
  case $arg in
    m) machName=$OPTARG; let parameterCount+=1;;
    h) ;;
    u) let parameterCount+=2;;
    i) IPaddr=$OPTARG; let parameterCount+=3;;
    y) linkname=$OPTARG; let parameterCount+=4;;
    d) case $OPTARG in
      F) Selecdif="Fácil";;
      M) Selecdif="Media";;
      D) Selecdif="Difícil";;
      I) Selecdif="Insane";;
    esac
    con_dif=1; let parameterCount+=5;;
    s) case $OPTARG in
      L) selecOS="Linux";;
      W) selecOS="Windows";;
    esac
    con_so=1; let parameterCount+=6;;
    k) skillName=$OPTARG; let parameterCount+=7 ;;
  esac
done

if [ $parameterCount -eq 1 ]; then
  searchMach $machName
elif [ $parameterCount -eq 2 ]; then
  updateF
elif [ $parameterCount -eq 3 ]; then
  findIP $IPaddr
elif [ $parameterCount -eq 4 ]; then
  YTlink $linkname
elif [ $parameterCount -eq 5 ]; then
  dificult $Selecdif
elif [ $parameterCount -eq 6 ]; then
  System $selecOS
elif [ $parameterCount -eq 7 ]; then
  Skill "$skillName"
elif [ $con_dif -eq 1 ] && [ $con_so -eq 1 ]; then
  OS_Dificult $Selecdif $selecOS
else
  helpPanel
fi
