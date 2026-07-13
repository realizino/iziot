from http.server import BaseHTTPRequestHandler
import socketserver
import socket
import threading
import os
import struct
import urllib.request
import urllib.parse
import json
from datetime import datetime

import Config.ConfigLoader
from Encryption import Encryption


class RTPHandler:

    #Get handling
    def Handle(self,conn):
        threading.Thread(target=self.GetHandling,args=(conn,)).start()


    #Get start RTP Protocol
    def GetHandling(self,conn):
        try:

            # Get first step get client token
            Token = conn.recv(1024).decode('utf-8')
            Key = Token[0: 16]
            print("Token is : ", Token)

            #Send Acknowage
            conn.send(("OK").encode('utf-8'))

            #Get second step get data type
            DataType = Encryption.decrypt(conn.recv(20),Key).decode('utf-8')
            print("Data Type is : ", DataType)

            # Send Acknowage
            conn.send(("READY").encode('utf-8'))


            if DataType == "IMAGE" or DataType == "PICTURE":
                print("Get Image From Client Starting")
                try:
                    # First receive filename length and filename
                    filename_size = struct.unpack('!I', conn.recv(4))[0]
                    filename = conn.recv(filename_size).decode('utf-8')

                    # Then receive file size
                    file_size = struct.unpack('!Q', conn.recv(8))[0]  # Using 8 bytes for larger files

                    # Receive file data
                    received_data = b''
                    bytes_received = 0

                    while bytes_received < file_size:
                        chunk = Encryption.decrypt(conn.recv(4096),Key)
                        if not chunk:
                            break
                        received_data += chunk
                        bytes_received += len(chunk)

                    # Save the file
                    saved_path = self.GetFileDataHandling(Token,received_data, filename)
                    print(f"File '{filename}' ({file_size} bytes) received and saved as: {saved_path}")
                    print(f"Image Received From ${Token}")

                except Exception as e:
                    print(f"Error receiving file: {e}")
                finally:
                    conn.close()

            else:
                print("Get Text From Client Starting")
                Data = Encryption.decrypt(conn.recv(1024),Key).decode('utf-8')
                print("Data is : ", Data)
                self.GetDataHandling(token=Token, data=Data,datatype=DataType)

            conn.close()
        except Exception as e:
            print("Error RTP : ",e)
            conn.close()


    def GetDataHandling(self, token, data, datatype):
        base_url = f"{Config.ConfigLoader.DESTINATEDURLPROTOCOL}://{Config.ConfigLoader.DESTINATEDURL}"

        if datatype == "TEMP":
            endpoint = "/NProtocol/api/Temp"
            params = {"temp": data}
        elif datatype == "AIRQ":
            endpoint = "/NProtocol/api/AirQ"
            params = {"airQ": data}
        elif datatype == "LOC":
            endpoint = "/NProtocol/api/Loc"
            params = {"loc": data}
        else:
            print(f"Unknown datatype: {datatype}")
            return

        full_url = base_url + endpoint
        
        # تبدیل دیکشنری به فرمت استاندارد x-www-form-urlencoded برای قرارگیری در Body
        data_bytes = urllib.parse.urlencode(params).encode('utf-8')

        headers = {
            "Accept": "*/*",
            "User-Agent": "LocalClient/1.0",
            "HubFlag": token,
            "Content-Type": "application/x-www-form-urlencoded",
            "Content-Length": str(len(data_bytes))
        }

        try:
            print(f"Forwarding to: {full_url}")
            print(f"Payload: {params}")
            
            request = urllib.request.Request(
                full_url, 
                data=data_bytes,  # ارسال داده در Body (نه در URL)
                headers=headers, 
                method="POST"
            )

            with urllib.request.urlopen(request) as response:
                print(f"Success! Status: {response.status}")
                print(f"Response: {response.read().decode()}")

        except urllib.error.HTTPError as e:
            print(f"HTTP Error: {e.code} - {e.read().decode()}")
        except urllib.error.URLError as e:
            print(f"URL Error (Check if destination server is running): {e.reason}")
        except Exception as e:
            print(f"Other error: {e}")


    def GetFileDataHandling(self,token,data, filename):

        if not os.path.exists("Repositories/"+token):
            os.makedirs("Repositories/"+token)

        now = datetime.now()
        timestamp = now.timestamp()
        print(timestamp)

        filepath = os.path.join("Repositories/"+token, str(timestamp)+os.path.splitext(filename)[1])
        with open(filepath, 'wb') as f:
            f.write(data)


        #Upload image
        base_url = Config.ConfigLoader.DESTINATEDURLPROTOCOL + "://" + Config.ConfigLoader.DESTINATEDURL+"/NProtocol/api/UploadImage"
        params = {}
        url_with_params = f"{base_url}?{urllib.parse.urlencode(params)}"

        with open(filepath, 'rb') as f:
            image_data = f.read()

        boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW'

        body = []
        body.append(f'--{boundary}')
        body.append('Content-Disposition: form-data; name="snapshot"; filename="image.jpg"')
        body.append('Content-Type: image/jpeg')
        body.append('')
        body.append(image_data)
        body.append(f'--{boundary}--')
        body.append('')

        body_bytes = b'\r\n'.join([
            part.encode('utf-8') if isinstance(part, str) else part
            for part in body
        ])

        headers = {
            "Accept": "*/*",
            "User-Agent": "LocalClient/1.0",
            "HubFlag": token,
            "Content-Type": f"multipart/form-data; boundary={boundary}",
        }

        try:
            request = urllib.request.Request(
                url_with_params,
                data=body_bytes,
                headers=headers,
                method="POST"
            )

            print(f"Uploading image to: {url_with_params}")

            with urllib.request.urlopen(request) as response:
                print(f"Status: {response.status}")
                print(f"Response: {response.read().decode()}")

        except urllib.error.URLError as e:
            print(f"Error: {e}")

        os.remove(filepath)
