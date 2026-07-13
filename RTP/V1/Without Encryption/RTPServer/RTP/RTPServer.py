import socket

from RTP.RTPHandler import RTPHandler
import threading

class RTPServer:

    HOST = '0.0.0.0'
    PORT = 8000

    def __init__(self, port, host):
        self.HOST = host
        self.PORT = port

        print("Get Staring RTP Server...")
        self.RTPServerHandle()

    def RTPServerHandle(self):

        #Get Socket
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        sock.bind((self.HOST, self.PORT))
        sock.listen(4096)

        print("RTP Server Ready on Port : ",self.PORT)

        while True:
            conn, addr = sock.accept()
            print("RTP Server Connected : ", addr)

            #Get start handling
            RTPHandler().Handle(conn)