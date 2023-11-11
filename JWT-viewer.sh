#!/bin/bash

jwt="$1"

header=$(echo "$jwt" | cut -d'.' -f1 | base64 -d)
payload=$(echo "$jwt" | cut -d'.' -f2 | base64 -d)

echo "Header: $header"
echo "Payload: $payload"

echo -ne "- Nuevo header: " && read header2
echo -ne "- Nuevo payload: " && read payload2

n_header=$(echo "$header2" | base64)
n_payload=$(echo "$payload2" | base64)
n_jwt="$n_header"".""$n_payload""."
echo -ne "$n_jwt" | tr -d "="
