#!/usr/bin/python3
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad
import hashlib
import math

#Interceptado //Hardcoded:
A = "0x5cda3a2dc931af7e"
p = "0xde26ab651b92a129"
g = 2
B = "0x2e9ebd2b01b84a78"
#Enteros
p_i=int(p, 16)
A_i=int(A, 16)
B_i=int(B, 16)

print("[-] Calculando raiz de p...") #traza
root_p=int(math.ceil(math.sqrt(p_i-1))) #Calculamos la raiz de p-1 y la redondeamos al entero cercano mas grande
print("[+] Raiz de p encontrada: ", root_p) #traza

#Baby-step
baby_steps = {}
value = 1
print("\n[+] Calculando baby-steps...")
for x in range(root_p): #itero sobre la raiz
	baby_steps[value] = x #añado x al diccionario
	value = (value * g) % p_i #actualizo value (que es la clave) a un nuevo valor, aquí tengo dudas si también puede funcionar (g ** x) % p_i pero creo que es mas ineficiente
	#Se hace lo mismo, pero ahora se multiplica de nuevo el valor de value, que es lo mismo que el comentario de arriba

#Gigant-step
gigant_steps = pow(pow(g, root_p, p_i), -1, p_i) #Base = ((2**root_p)%p_i), exp = -1 (Porque es num inverso), primo = p_i
value = A_i #Valor actualizado al numero de Alice
print("[+] Calculando Gigant-steps...") #traza
for y in range(root_p):
	if value in baby_steps: #El numero de Alice debe estar en el diccionario
		secret = baby_steps[value] + y * root_p #Se concreta la llave secreta con y * root_p, tal que g^x+y*root_p mod p = A | y+root_p es el numero de Gigant-steps que se han dado
		print("[+] Clave conjunta encontrada con y = ", y)
		print(secret)
		break
	else:
		print("[!] Clave conjunta no encontrada")

shared_secret=pow(A_i, secret, p_i) #Se calcula la clave de Alice, puesto que ella envió el vector y la flag
print("\n[+] Secreto compartid: ", shared_secret)

#Vector de inicialización y Flag
iv = "4fac8b8f45f81839d6a723673559c300"
encrypted_flag = "543ed676c30f03dcfa24b394ca4e1a4ad7bb5e7f24b3864426480689b6497d4e"

# Derive AES key from shared secret
sha1 = hashlib.sha1()
sha1.update(str(secret).encode('ascii'))
key = sha1.digest()[:16]
# Encrypt flag
cipher_hex = bytes.fromhex(encrypted_flag)
iv = bytes.fromhex(iv)
cipher = AES.new(key, AES.MODE_CBC, iv)
# Prepare data to send
flag = cipher.decrypt(cipher_hex)
print("\n\nFlag: ", flag)
