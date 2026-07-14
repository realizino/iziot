import json

from werkzeug.exceptions import RequestTimeout

HOST = '127.0.0.1'
PORT = 8080
UPLOAD_DIR = "C:\\Users\\rezafta\\Desktop\\DashaxFramework\\FileTmp"
DESTINATEDURL = "localhost:8080"
DESTINATEDURLPROTOCOL = "http"

class ConfigLoader:
    def __init__(self, configFilePath):
        with open(configFilePath, 'r') as f:
            config = json.load(f)

            ConfigLoader.HOST = config['app']['HOST']
            ConfigLoader.PORT = config['app']['PORT']
            ConfigLoader.UPLOAD_DIR = config['app']['UPLOAD_DIR']
            ConfigLoader.DESTINATEDURL = config['app']['DESTINATEDURL']
            ConfigLoader.DESTINATEDURLPROTOCOL = config['app']['DESTINATEDURLPROTOCOL']


