from Config.ConfigLoader import ConfigLoader
from RTP.RTPServer import RTPServer

def main():

    # Store the ConfigLoader instance
    config_loader = ConfigLoader('config.json')

    # Use instance attributes
    RTPServer(config_loader.PORT, config_loader.HOST)

if __name__ == '__main__':
    main()