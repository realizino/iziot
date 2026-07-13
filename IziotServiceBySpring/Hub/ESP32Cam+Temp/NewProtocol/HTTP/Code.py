import network
import socket
import time
import machine
import ujson
import ubinascii
from machine import Pin, reset
import camera
import gc

# ESP32-CAM pins configuration
led_pin = Pin(4, Pin.OUT)  # LED flash pin
reset_pin = Pin(0, Pin.IN, Pin.PULL_UP)  # Reset button pin

class ESP32_CAM_IoT:
    def __init__(self):
        self.wifi_config_file = 'wifi_config.json'
        self.ap_ssid = 'ESP32-CAM-Setup'
        self.ap_password = '12345678'
        self.server_url = None
        self.token = None

    def load_wifi_config(self):
        # Step 2: Check if WiFi credentials are saved
        try:
            with open(self.wifi_config_file, 'r') as f:
                config = ujson.loads(f.read())
                return config.get('ssid'), config.get('password'), config.get('token')
        except:
            return None, None, None

    def save_wifi_config(self, ssid, password, token):
        # Step 4: Save WiFi credentials to memory
        config = {
            'ssid': ssid,
            'password': password,
            'token': token
        }
        with open(self.wifi_config_file, 'w') as f:
            f.write(ujson.dumps(config))
        print("WiFi credentials saved successfully")

    def create_hotspot(self):
        # Step 2: Create WiFi hotspot for initial setup
        ap = network.WLAN(network.AP_IF)
        ap.active(True)
        ap.config(essid=self.ap_ssid, password=self.ap_password)
        print("Hotspot created: " + self.ap_ssid)
        print("IP: " + ap.ifconfig()[0])
        return ap.ifconfig()[0]

    def setup_web_server(self, ip):
        # Step 3: Web server to receive WiFi credentials and token
        html = """<!DOCTYPE html>
<html dir="rtl">
<head>
    <meta charset="utf-8">
    <title>ESP32-CAM Settings</title>
    <style>
        body { font-family: Arial; padding: 20px; background: #f0f0f0; }
        .container { max-width: 400px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; }
        input { width: 100%; padding: 10px; margin: 10px 0; border: 1px solid #ddd; border-radius: 5px; }
        button { width: 100%; padding: 15px; background: #4CAF50; color: white; border: none; border-radius: 5px; cursor: pointer; }
        button:hover { background: #45a049; }
        h2 { text-align: center; color: #333; }
    </style>
</head>
<body>
    <div class="container">
        <h2>Smart Camera Settings</h2>
        <form method="POST" action="/setup">
            <input type="text" name="ssid" placeholder="WiFi Network Name" required>
            <input type="password" name="password" placeholder="WiFi Password" required>
            <input type="text" name="token" placeholder="Server Token" required>
            <button type="submit">Save and Setup</button>
        </form>
    </div>
</body>
</html>"""

        s = socket.socket()
        s.bind(('', 80))
        s.listen(5)
        print("Web server started on port 80")

        while True:
            conn, addr = s.accept()
            print("Connection from: " + str(addr))
            request = conn.recv(1024).decode()

            if 'POST /setup' in request:
                # Process form data
                body = request.split('\r\n\r\n')[1]
                params = {}
                for param in body.split('&'):
                    if '=' in param:
                        key, value = param.split('=', 1)
                        params[key] = value.replace('+', ' ').replace('%40', '@')

                ssid = params.get('ssid', '')
                password = params.get('password', '')
                token = params.get('token', '')

                if ssid and password and token:
                    self.save_wifi_config(ssid, password, token)

                    response = """HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\n\r\n
<html><body style="font-family:Arial;text-align:center;padding:50px;">
<h2>Settings saved successfully!</h2>
<p>Device is restarting...</p>
</body></html>"""

                    conn.send(response.encode())
                    conn.close()
                    s.close()

                    print("Step 5: Restarting device...")
                    time.sleep(2)
                    machine.reset()

            else:
                # Display setup form
                response = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\n\r\n" + html
                conn.send(response.encode())

            conn.close()

    def connect_wifi(self, ssid, password):
        # Step 6: Connect to WiFi network
        wlan = network.WLAN(network.STA_IF)
        wlan.active(True)
        wlan.connect(ssid, password)

        print("Connecting to " + ssid + "...")
        timeout = 0
        while not wlan.isconnected() and timeout < 30:
            print(".", end="")
            time.sleep(1)
            timeout += 1

        if wlan.isconnected():
            print("\nConnected successfully! IP: " + wlan.ifconfig()[0])
            return True
        else:
            print("\nFailed to connect to WiFi")
            return False

    def decode_token(self, token):
        # Step 7: Decode base64 token and convert to JSON
        try:
            # Decode base64
            decoded = ubinascii.a2b_base64(token).decode('utf-8')
            # Convert to JSON
            json_data = ujson.loads(decoded)
            print("Token decoded successfully: " + str(json_data))
            return json_data
        except Exception as e:
            print("Error decoding token: " + str(e))
            return None

    def extract_server_url(self, json_data):
        # Step 8: Extract server URL from iot_model field
        try:
            iot_model = json_data.get('iot_model', '')
            parts = iot_model.split('-')
            if len(parts) >= 2:
                server_url = parts[1]
                print("Server URL extracted: " + server_url)
                return server_url
            else:
                print("Invalid iot_model format")
                return None
        except Exception as e:
            print("Error extracting server URL: " + str(e))
            return None

    def init_camera(self):
        # Initialize camera module
        try:
            camera.init(0, format=camera.JPEG, framesize=camera.FRAME_SVGA,
                       quality=10, fb_count=1)
            print("Camera initialized successfully")
            return True
        except Exception as e:
            print("Error initializing camera: " + str(e))
            return False

    def capture_image(self):
        # Step 10: Capture image from camera
        try:
            led_pin.on()  # Turn on flash LED
            time.sleep(0.1)

            buf = camera.capture()
            led_pin.off()  # Turn off flash LED

            if buf:
                print("Image captured - Size: " + str(len(buf)) + " bytes")
                return buf
            else:
                print("Failed to capture image")
                return None
        except Exception as e:
            print("Error capturing image: " + str(e))
            led_pin.off()
            return None

    def upload_image(self, image_data, server_url, token):
        # Step 11 & 12: Upload image to server with token in header
        try:
            # Parse server URL and port
            if ':' in server_url:
                host, port = server_url.split(':')
                port = int(port)
            else:
                host = server_url
                port = 80

            print("Uploading to: " + host + ":" + str(port))

            # Create HTTP POST request
            boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"

            # Build HTTP headers
            headers = "POST /upload HTTP/1.1\r\n"
            headers += "Host: " + host + "\r\n"
            headers += "Authorization: Bearer " + token + "\r\n"
            headers += "Content-Type: multipart/form-data; boundary=" + boundary + "\r\n"

            # Build multipart body
            body = "--" + boundary + "\r\n"
            body += "Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n"
            body += "Content-Type: image/jpeg\r\n\r\n"

            body_end = "\r\n--" + boundary + "--\r\n"

            # Calculate content length
            content_length = len(body.encode()) + len(image_data) + len(body_end.encode())
            headers += "Content-Length: " + str(content_length) + "\r\n\r\n"

            # Connect to server
            s = socket.socket()
            try:
                s.settimeout(30)
                s.connect((host, port))

                # Send headers
                s.send(headers.encode())

                # Send body start
                s.send(body.encode())

                # Send image data in chunks
                chunk_size = 1024
                for i in range(0, len(image_data), chunk_size):
                    chunk = image_data[i:i+chunk_size]
                    s.send(chunk)

                # Send body end
                s.send(body_end.encode())

                # Read response
                response = s.recv(1024).decode()
                s.close()

                # Check response
                if "200 OK" in response:
                    print("Image uploaded successfully")
                    return True
                else:
                    print("Upload failed - Response: " + response[:100])
                    return False

            except Exception as e:
                print("Socket error: " + str(e))
                s.close()
                return False

        except Exception as e:
            print("Error uploading image: " + str(e))
            return False

    def main_loop(self):
        # Step 9: Infinite loop for capturing and uploading images
        while True:
            try:
                print("\n--- Capturing new image ---")

                # Capture image
                image_data = self.capture_image()
                if image_data:
                    # Upload image
                    success = self.upload_image(image_data, self.server_url, self.token)
                    if success:
                        print("Image sent successfully")
                    else:
                        print("Failed to send image")

                # Free up memory
                gc.collect()

                # Wait before next capture (30 seconds)
                print("Waiting 30 seconds for next capture...")
                time.sleep(30)

            except Exception as e:
                print("Error in main loop: " + str(e))
                time.sleep(10)

    def run(self):
        # Main execution function
        print("=== ESP32-CAM Smart IoT Camera ===")
        print("Step 1: Device startup")

        # Check for saved WiFi credentials
        ssid, password, token = self.load_wifi_config()

        if not ssid or not password or not token:
            print("Step 2: No WiFi credentials found - Creating hotspot")
            ip = self.create_hotspot()
            print("Connect to hotspot and go to http://" + ip + " for setup")
            self.setup_web_server(ip)
        else:
            print("WiFi credentials found")

            # Connect to WiFi
            if self.connect_wifi(ssid, password):
                # Decode token
                json_data = self.decode_token(token)
                if json_data:
                    # Extract server URL
                    server_url = self.extract_server_url(json_data)
                    if server_url:
                        self.server_url = server_url
                        self.token = token

                        # Initialize camera
                        if self.init_camera():
                            print("Starting main loop...")
                            self.main_loop()
                        else:
                            print("Failed to initialize camera")
                    else:
                        print("Failed to extract server URL")
                else:
                    print("Failed to decode token")
            else:
                print("WiFi connection failed - Clearing saved settings")
                try:
                    import uos
                    uos.remove(self.wifi_config_file)
                except:
                    pass
                machine.reset()

# Run the program
if __name__ == "__main__":
    camera_system = ESP32_CAM_IoT()
    camera_system.run()