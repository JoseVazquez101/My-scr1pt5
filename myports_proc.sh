#!/bin/bash

function myports() {
echo
cat /proc/net/tcp | uniq -u | awk 'NR > 1 {print $2}' | awk -F ":" '{print $2}' | while read line; do
    if [[ $line != "0" ]]; then
        echo -e "[+] Puerto $((16#$line)) abierto"
    fi
done
}

myports
