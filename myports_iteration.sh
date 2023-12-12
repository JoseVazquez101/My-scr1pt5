#!/bin/bash

for port in $(seq 1 65535); do
   echo '' > /dev/tcp/127.0.0.1/$port) 2>/dev/null && echo "Puerto $port abierto"
done
