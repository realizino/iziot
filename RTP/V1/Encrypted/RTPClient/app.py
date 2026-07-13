import socket
import struct
import os


def main():
    host = 'localhost'
    port = 9085
    RTPFunction(host, port,"IMAGE","eyJpZCI6MTYsInVybCI6Imh0dHBzOi8vYXBpLmJvb21jYW0ubGl2ZSIsImF0dHJpYnV0ZSI6IlRoZXJtb21ldGVyLFJvdGF0ZSwiLCJyZXNvbHV0aW9uIjoiMTAyNCA3NjgifQ==","C:\\Users\\rezafta\\Desktop\\background - Copy.jpg")
    # RTPFunction(host, port,"TEMP","eyJpZCI6MTYsInVybCI6Imh0dHBzOi8vYXBpLmJvb21jYW0ubGl2ZSIsImF0dHJpYnV0ZSI6IlRoZXJtb21ldGVyLFJvdGF0ZSwiLCJyZXNvbHV0aW9uIjoiMTAyNCA3NjgifQ==","50")

def encrypt(data, key, encoding='utf-8'):
    if not key:
        raise ValueError("Key cannot be empty")
    
    if isinstance(key, str):
        key_bytes = key.encode(encoding)
    else:
        key_bytes = key
    
    key_length = len(key_bytes)
    return bytearray(data[i] ^ key_bytes[i % key_length] for i in range(len(data)))

def decrypt(data, key, encoding='utf-8'):
    if not key:
        raise ValueError("Key cannot be empty")
    
    if isinstance(key, str):
        key_bytes = key.encode(encoding)
    else:
        key_bytes = key
    
    key_length = len(key_bytes)
    return bytearray(data[i] ^ key_bytes[i % key_length] for i in range(len(data)))

    
def RTPFunction(host, port,datatype,token,data):
        #Get start socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    print(f"Connecting to {host}:{port}")
    sock.connect((host, port))
    print(f"Connected")

    #Get first step send client token
    token = token
    key = token[0:16]
    print(f"Sending token: {token}")
    sock.send(token.encode('utf-8'))
    
    #Get Acknowage
    acknowage_1 = sock.recv(1024).decode('utf-8')
    print(f"Acknowage from server: {acknowage_1}")
    
    #Get second step send data type    
    print(f"Sending Data type : {datatype}")
    sock.send(encrypt(datatype.encode('utf-8'),key))
    
    acknowage_2 = sock.recv(1024).decode('utf-8')
    print(f"Acknowage from server: {acknowage_2}")

    if datatype == "IMAGE" or datatype == "PICTURE":
        print("Sending Image To Server Starting")
        try:            
            filepath = data
            filename = os.path.basename(filepath)
            
            # Read file data
            with open(filepath, 'rb') as f:
                file_data = f.read()
            
            file_size = len(file_data)
            
            # Send filename length and filename
            filename_encoded = filename.encode('utf-8')
            sock.sendall(struct.pack('!I', len(filename_encoded)))
            sock.sendall(filename_encoded)
            
            # Send file size (using 8 bytes for larger files)
            sock.sendall(struct.pack('!Q', file_size))
            
            # Send file data
            sock.sendall(encrypt(file_data,key))
            # print(f"File '{filename}' ({file_size} bytes) sent successfully")
            print("Image Sended To Server")
            # return True
            
        except Exception as e:
            print(f"Error sending file: {e}")
            print("Image Can`t Sended To Server")
            # return False        

    else:
        print("Sending Data To Server Starting")
        sock.send(encrypt(data.encode('utf-8'),key))
        print("Data Sended To Server")
    
    #Get Close socket connection
    sock.close()

if __name__=="__main__":
    main()