import network
import socket
import time
import machine
import ujson
import ubinascii
import sys
import struct
import gc
from machine import Pin, reset

# Check camera module availability
try:
    import camera
except ImportError:
    print("Camera module not found. Please use a MicroPython firmware with camera support.")
    sys.exit(1)

# Import ussl for SSL/TLS support
try:
    import ussl
except ImportError:
    print("ussl module not found. SSL/TLS will not be available.")
    ussl = None

# Global Pin Definitions
LED_PIN = 4
RESET_PIN = 0

class ESP32_CAM_IoT:
    def __init__(self):
        self.wifi_config_file = 'wifi_config.json'
        self.ap_ssid = 'iziot'
        self.ap_password = '12345678'
        self.resolution = '800x600'
        self.server_url = None
        self.token = None
        self.has_thermometer = False
        self.has_rotate = False
        self.camera_initialized = False
        self.led_pin = None
        self.reset_pin = None

    def load_wifi_config(self):
        try:
            with open(self.wifi_config_file, 'r') as f:
                content = f.read()
                print("Raw file content length:", len(content))
                config = ujson.loads(content)
                ssid = config.get('ssid')
                password = config.get('password')
                token = config.get('token')
                print("Token found, length:", len(token) if token else 0)
                return ssid, password, token
        except Exception as e:
            print("Error loading config:", str(e))
            return None, None, None

    def validate_token(self, token):
        """Validate token before use"""
        try:
            if not token or len(token) < 10:
                print("Token too short")
                return False

            decoded = ubinascii.a2b_base64(token).decode('utf-8')
            json_data = ujson.loads(decoded)

            if 'url' not in json_data:
                print("Token missing required URL field")
                return False

            print("Token validation successful")
            return True

        except Exception as e:
            print("Token validation failed:", str(e))
            return False

    def save_wifi_config(self, ssid, password, token):
        try:
            print("Saving config - Token length:", len(token))

            config = {
                'ssid': ssid,
                'password': password,
                'token': token
            }

            json_str = ujson.dumps(config)
            print("Config JSON length:", len(json_str))

            try:
                import uos
                try:
                    uos.remove(self.wifi_config_file)
                except:
                    pass

                with open(self.wifi_config_file, 'w') as f:
                    chunk_size = 512
                    for i in range(0, len(json_str), chunk_size):
                        chunk = json_str[i:i + chunk_size]
                        f.write(chunk)
                    f.flush()

                print("File written successfully")

                time.sleep(0.1)
                with open(self.wifi_config_file, 'r') as f:
                    saved_content = f.read()

                saved_config = ujson.loads(saved_content)
                saved_token = saved_config.get('token', '')

                if len(saved_token) == len(token) and saved_token == token:
                    print("WiFi credentials saved and verified successfully")
                    return True
                else:
                    print("Token verification failed - lengths:", len(saved_token), "vs", len(token))
                    return False

            except Exception as e:
                print("File operations error during save/verify:", str(e))
                return False

        except Exception as e:
            print("Error saving config:", str(e))
            return False

    def clear_config_and_reset(self):
        """Clear config file and reset to hotspot mode"""
        try:
            import uos
            uos.remove(self.wifi_config_file)
            print("Config file cleared")
        except:
            print("Config file not found or already cleared")

        print("Resetting to hotspot mode...")
        time.sleep(2)
        machine.reset()

    def create_hotspot(self):
        ap = network.WLAN(network.AP_IF)
        ap.active(True)
        ap.config(essid=self.ap_ssid, password=self.ap_password)
        print("Hotspot created: " + self.ap_ssid)
        print("IP: " + ap.ifconfig()[0])
        return ap.ifconfig()[0]

    def setup_web_server(self, ip):
        html = """<!DOCTYPE html>
<html dir="ltr">
<head>
    <meta charset="utf-8">
    <title>ESP32-CAM Settings</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0">
    <style>
        body { font-family: Arial; padding: 20px; background: #f0f0f0; }
        .container { max-width: 500px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; }
        input { width: 100%; padding: 10px; margin: 10px 0; border: 1px solid #ddd; border-radius: 5px; box-sizing: border-box; }
        textarea { width: 100%; padding: 10px; margin: 10px 0; border: 1px solid #ddd; border-radius: 5px; min-height: 200px; resize: vertical; box-sizing: border-box; font-family: monospace; font-size: 12px; }
        button { width: 100%; padding: 15px; background: #4CAF50; color: white; border: none; border-radius: 5px; cursor: pointer; font-size: 16px; }
        button:hover { background: #45a049; }
        h2 { text-align: center; color: #333; }
        .token-info { font-size: 12px; color: #666; margin: 5px 0; }
        .form-group { margin: 15px 0; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h2>iziot Settings</h2>
        <form method="POST" action="/setup" enctype="application/x-www-form-urlencoded">
            <div class="form-group">
                <label for="ssid">WiFi Network Name:</label>
                <input type="text" id="ssid" name="ssid" placeholder="Enter WiFi name" required>
            </div>

            <div class="form-group">
                <label for="password">WiFi Password:</label>
                <input type="password" id="password" name="password" placeholder="Enter WiFi password" required>
            </div>

            <div class="form-group">
                <label for="token">Server Token:</label>
                <div class="token-info">Paste your complete token here (up to 8KB supported)</div>
                <textarea id="token" name="token" placeholder="Paste your complete server token here..." required maxlength="8192"></textarea>
                <div class="token-info" id="token-length">Token length: 0 characters</div>
            </div>

            <button type="submit">Save and Setup</button>
        </form>
    </div>

    <script>
        document.getElementById('token').addEventListener('input', function() {
            document.getElementById('token-length').innerText = 'Token length: ' + this.value.length + ' characters';
        });
    </script>
</body>
</html>"""

        s = socket.socket()
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        s.bind(('', 80))
        s.listen(5)
        print("Web server started on port 80")

        while True:
            conn, addr = s.accept()
            print("Connection from: " + str(addr))

            try:
                request_data = b''
                conn.settimeout(5)

                while True:
                    try:
                        chunk = conn.recv(1024)
                        if not chunk:
                            break
                        request_data += chunk

                        if b'\r\n\r\n' in request_data:
                            parts = request_data.split(b'\r\n\r\n', 1)
                            headers = parts[0]

                            if b'POST' in headers:
                                body_part = parts[1] if len(parts) > 1 else b''
                                content_length = 0
                                for line in headers.split(b'\r\n'):
                                    if line.lower().startswith(b'content-length:'):
                                        content_length = int(line.split(b':')[1].strip())
                                        break

                                while len(body_part) < content_length:
                                    more_data = conn.recv(min(1024, content_length - len(body_part)))
                                    if not more_data:
                                        break
                                    body_part += more_data
                                    request_data = headers + b'\r\n\r\n' + body_part
                                break
                    except:
                        break

                try:
                    request = request_data.decode('utf-8')
                except:
                    request = ''
                    for byte in request_data:
                        try:
                            char = chr(byte)
                            if ord(char) < 128:
                                request += char
                        except:
                            pass

                if 'POST /setup' in request:
                    try:
                        body = request.split('\r\n\r\n')[1]
                    except:
                        print("Error: Could not extract request body")
                        continue

                    params = {}
                    current_param = ""
                    current_value = ""
                    reading_value = False

                    i = 0
                    while i < len(body):
                        char = body[i]

                        if char == '=' and not reading_value:
                            current_param = current_value
                            current_value = ""
                            reading_value = True
                        elif char == '&' or i == len(body) - 1:
                            if i == len(body) - 1 and char != '&':
                                current_value += char
                            if current_param:
                                decoded_value = self.url_decode(current_value)
                                params[current_param] = decoded_value.strip()
                            current_param = ""
                            current_value = ""
                            reading_value = False
                        else:
                            current_value += char

                        i += 1

                    ssid = params.get('ssid', '').strip()
                    password = params.get('password', '').strip()
                    token = params.get('token', '').strip()

                    print("Received - SSID:", ssid)
                    print("Received - Password length:", len(password))
                    print("Received - Token length:", len(token))

                    if ssid and password and token:
                        if self.save_wifi_config(ssid, password, token):
                            response = """HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\n\r\n
<html><body style="font-family:Arial;text-align:center;padding:50px;">
<h2>Settings saved successfully!</h2>
<p>Device is restarting...</p>
</body></html>"""
                        else:
                            response = """HTTP/1.1 400 Bad Request\r\nContent-Type: text/html; charset=utf-8\r\n\r\n
<html><body style="font-family:Arial;text-align:center;padding:50px;">
<h2>Error: Invalid token!</h2>
<p><a href="/">Try Again</a></p>
</body></html>"""

                        conn.send(response.encode())
                        conn.close()
                        s.close()

                        if self.save_wifi_config(ssid, password, token):
                            print("Step 5: Restarting device...")
                            time.sleep(2)
                            machine.reset()
                        return

                else:
                    response = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\n\r\n" + html
                    conn.send(response.encode())

            except Exception as e:
                print("Error handling request:", str(e))

            finally:
                conn.close()

    def url_decode(self, s):
        """URL decoding for special characters"""
        replacements = {
            '%20': ' ', '%21': '!', '%22': '"', '%23': '#', '%24': '$',
            '%25': '%', '%26': '&', '%27': "'", '%28': '(', '%29': ')',
            '%2A': '*', '%2B': '+', '%2C': ',', '%2D': '-', '%2E': '.',
            '%2F': '/', '%3A': ':', '%3B': ';', '%3C': '<', '%3D': '=',
            '%3E': '>', '%3F': '?', '%40': '@', '%5B': '[', '%5C': '\\',
            '%5D': ']', '%5E': '^', '%5F': '_', '%60': '`', '%7B': '{',
            '%7C': '|', '%7D': '}', '%7E': '~'
        }

        for encoded, decoded in replacements.items():
            s = s.replace(encoded, decoded)
        return s

    def connect_wifi(self, ssid, password):
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
        try:
            decoded = ubinascii.a2b_base64(token).decode('utf-8')
            json_data = ujson.loads(decoded)
            print("Token decoded successfully: " + str(json_data))
            return json_data
        except Exception as e:
            print("Error decoding token: " + str(e))
            self.clear_config_and_reset()
            return None

    def extract_server_url(self, json_data):
        try:
            server_url = json_data.get('url', '')
            if server_url:
                print("Server URL extracted: " + server_url)
                return server_url
            else:
                print("URL field not found in token")
                return None
        except Exception as e:
            print("Error extracting server URL: " + str(e))
            return None

    def extract_resolution(self, json_data):
        """Extract resolution from token data, defaulting to 800x600 for stability"""
        try:
            resolution = json_data.get('resolution', '800x600')
            if resolution in ["1600x1200", "1280x1024"]:
                print(f"Warning: High resolution {resolution} might fail. Forcing 1024x768 max.")
                resolution = '1024x768'

            if 'x' in resolution:
                resolution = resolution.replace('x', ' ')

            print("Resolution: {}".format(resolution))
            return resolution
        except:
            return '800 600'

    def check_thermometer_attribute(self, json_data):
        """Check if token contains thermometer attribute"""
        try:
            attributes = json_data.get('attribute', '')
            if isinstance(attributes, list):
                has_thermometer = 'Thermometer' in attributes
            elif isinstance(attributes, str):
                has_thermometer = 'Thermometer' in attributes
            else:
                has_thermometer = False

            print("Thermometer attribute check: " + str(has_thermometer))
            print("Attributes found: " + str(attributes))
            return has_thermometer
        except Exception as e:
            print("Error checking thermometer attribute: " + str(e))
            return False

    def check_rotate_attribute(self, json_data):
        """Check if token contains Rotate attribute"""
        try:
            attributes = json_data.get('attribute', '')
            if isinstance(attributes, list):
                has_rotate = 'Rotate' in attributes
            elif isinstance(attributes, str):
                has_rotate = 'Rotate' in attributes
            else:
                has_rotate = False

            print("Rotate attribute check: " + str(has_rotate))
            print("Attributes found: " + str(attributes))
            return has_rotate
        except Exception as e:
            print("Error checking Rotate attribute: " + str(e))
            return False

    def init_camera(self):
        try:
            camera.deinit()
            time.sleep(0.1)
            gc.collect()

            camera.init(0, format=camera.JPEG, fb_location=camera.PSRAM)
            camera.quality(10)

            resolution_map = {
                "96 96": camera.FRAME_96X96,
                "160 120": camera.FRAME_QQVGA,
                "176 144": camera.FRAME_QCIF,
                "240 176": camera.FRAME_HQVGA,
                "320 240": camera.FRAME_QVGA,
                "400 296": camera.FRAME_CIF,
                "640 480": camera.FRAME_VGA,
                "800 600": camera.FRAME_SVGA,
                "1024 768": camera.FRAME_XGA,
                "1280 1024": camera.FRAME_SXGA,
                "1600 1200": camera.FRAME_UXGA
            }

            frame_size = resolution_map.get(self.resolution, camera.FRAME_VGA)
            camera.framesize(frame_size)
            print("init camera resolution : {}".format(frame_size))

            if self.has_rotate:
                camera.flip(1)
                camera.mirror(1)

            print("Camera initialized - Resolution: {}".format(self.resolution))
            self.camera_initialized = True
            return True

        except Exception as e:
            print("Camera initialization failed: {}".format(e))
            self.camera_initialized = False
            try:
                camera.deinit()
                time.sleep(0.1)
                gc.collect()
                camera.init(0, format=camera.JPEG)
                camera.quality(10)
                camera.framesize(camera.FRAME_VGA)
                print("Camera initialized (fallback mode - VGA)")
                self.camera_initialized = True
                return True
            except Exception as e2:
                print("Camera fallback failed: {}".format(e2))
                return False

    def capture_image(self):
        try:
            buf = camera.capture()

            sleep_time_map = {
                "96 96": 0.3, "160 120": 0.4, "176 144": 0.5, "240 176": 1,
                "320 240": 2, "400 296": 3, "640 480": 4, "800 600": 5,
                "1024 768": 10, "1280 1024": 20, "1600 1200": 30
            }
            sleep_time = sleep_time_map.get(self.resolution, 5)

            if buf:
                print("Image captured - Size: " + str(len(buf)) + " bytes")
                print("Waiting {} seconds for next cycle...".format(sleep_time))
                time.sleep(sleep_time)
                return buf
            else:
                print("Failed to capture image")
                print("Waiting 5 seconds before retrying...")
                time.sleep(5)
                return None
        except Exception as e:
            print("Error capturing image: " + str(e))
            if self.led_pin:
                self.led_pin.off()
            return None

    def get_temperature(self):
        """Get temperature reading from DS18B20 sensor"""
        try:
            import onewire
            import ds18x20
            from machine import Pin

            ds_pin = Pin(2)
            ds_sensor = ds18x20.DS18X20(onewire.OneWire(ds_pin))

            roms = ds_sensor.scan()
            print("Found DS18B20 devices:", len(roms))

            if len(roms) == 0:
                print("No DS18B20 sensors found")
                return "-"

            ds_sensor.convert_temp()
            time.sleep_ms(750)

            temperatures = []
            for i, rom in enumerate(roms):
                try:
                    temp = ds_sensor.read_temp(rom)
                    if temp is not None:
                        temperatures.append(round(temp, 2))
                        print("Sensor " + str(i) + " temperature: " + str(temp) + "°C")
                    else:
                        print("Sensor " + str(i) + " returned None")
                except Exception as e:
                    print("Error reading sensor " + str(i) + ": " + str(e))

            if temperatures:
                avg_temp = sum(temperatures) / len(temperatures)
                print("Average temperature: " + str(round(avg_temp, 2)) + "°C")
                return round(avg_temp, 2)
            else:
                print("No valid temperature readings")
                return 25.0

        except ImportError:
            print("DS18B20 libraries not available, using random temperature")
            import random
            temp = 20 + random.randint(0, 20)
            print("Random temperature: " + str(temp) + "°C")
            return temp
        except Exception as e:
            print("Error reading temperature: " + str(e))
            return 25.0

    def encrypt(self, data, key, encoding='utf-8'):
        """Encrypt data using XOR with key"""
        if not key:
            raise ValueError("Key cannot be empty")

        if isinstance(key, str):
            key_bytes = key.encode(encoding)
        else:
            key_bytes = key

        key_length = len(key_bytes)
        return bytearray(data[i] ^ key_bytes[i % key_length] for i in range(len(data)))

    def decrypt(self, data, key, encoding='utf-8'):
        """Decrypt data using XOR with key"""
        if not key:
            raise ValueError("Key cannot be empty")

        if isinstance(key, str):
            key_bytes = key.encode(encoding)
        else:
            key_bytes = key

        key_length = len(key_bytes)
        return bytearray(data[i] ^ key_bytes[i % key_length] for i in range(len(data)))

    def RTPFunction(self, datatype, token, data):
        """Send data to server via RTP protocol"""
        host = self.server_url.split(':')[0]
        port = 9085

        print("--------------------------")
        print("Host:", host)
        print("Port:", port)
        print("--------------------------")

        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(10)  # 10 second timeout

        try:
            print("Connecting to {}:{}".format(host, port))
            sock.connect((host, port))
            print("Connected successfully!")

            # Send token
            key = token[0:16]
            print("Sending token (length: {})".format(len(token)))
            sock.sendall(token.encode('utf-8'))

            # Get acknowledgment
            acknowage_1 = sock.recv(1024).decode('utf-8')
            print("Acknowledgment 1 from server: {}".format(acknowage_1))

            # Send data type
            print("Sending Data type: {}".format(datatype))
            sock.sendall(self.encrypt(datatype.encode('utf-8'), key))

            acknowage_2 = sock.recv(1024).decode('utf-8')
            print("Acknowledgment 2 from server: {}".format(acknowage_2))

            if datatype == "IMAGE" or datatype == "PICTURE":
                print("Sending Image To Server Starting")
                try:
                    if isinstance(data, (bytes, bytearray)):
                        file_data = bytes(data)
                        filename = "capture.jpg"
                    else:
                        filename = data.split('/')[-1]
                        with open(data, 'rb') as f:
                            file_data = f.read()

                    file_size = len(file_data)

                    # Send filename length and filename
                    filename_encoded = filename.encode('utf-8')
                    sock.sendall(struct.pack('!I', len(filename_encoded)))
                    sock.sendall(filename_encoded)

                    # Send file size
                    sock.sendall(struct.pack('!Q', file_size))

                    # Send encrypted file data
                    sock.sendall(self.encrypt(file_data, key))
                    print("Image sent to server ({} bytes)".format(file_size))

                except Exception as e:
                    print("Error sending image: {}".format(e))

            else:
                print("Sending Data To Server Starting")
                sock.sendall(self.encrypt(data.encode('utf-8'), key))
                print("Data Sent To Server")

        except OSError as e:
            print("RTPFunction OSError: {} (Error code: {})".format(e, e.args[0] if e.args else 'N/A'))
            if e.args[0] == 113:  # ECONNABORTED
                print("Connection refused. Is the server running at {}:{}?".format(host, port))
            elif e.args[0] == 110:  # ETIMEDOUT
                print("Connection timeout. Check network connectivity.")
            elif e.args[0] == 111:  # ECONNREFUSED
                print("Connection refused. Server is not accepting connections.")
        except Exception as e:
            print("RTPFunction error: {}".format(e))
        finally:
            sock.close()

    def main_loop(self, token):
        """Infinite loop for capturing and uploading images"""
        while True:
            try:
                print("\n--- Starting new cycle ---")

                # Check if device has thermometer capability and upload temperature
                if self.has_thermometer:
                    print("--- Thermometer detected - Getting temperature ---")
                    temperature = self.get_temperature()
                    temp_str = str(temperature)
                    print(temp_str)
                    self.RTPFunction("TEMP", token, temp_str)

                # Capture and upload image
                print("--- Capturing new image ---")
                image_buffer = self.capture_image()
                gc.collect()

                if image_buffer:
                    self.RTPFunction("IMAGE", token, image_buffer)
                else:
                    print("Capture failed. Retrying in next cycle.")

            except Exception as e:
                print("Main loop error: {}".format(e))
                time.sleep(5)

    def run_setup_mode(self):
        """Initializes pins and runs setup logic."""
        try:
            self.led_pin = Pin(LED_PIN, Pin.OUT)
            self.reset_pin = Pin(RESET_PIN, Pin.IN, Pin.PULL_UP)
        except Exception as e:
            print(f"Pin initialization error: {e}")

        # Check for saved config
        ssid, password, token = self.load_wifi_config()

        if ssid and password and token and self.validate_token(token):
            if self.connect_wifi(ssid, password):
                json_data = self.decode_token(token)
                if json_data:
                    self.server_url = self.extract_server_url(json_data)
                    self.resolution = self.extract_resolution(json_data)
                    self.has_thermometer = self.check_thermometer_attribute(json_data)
                    self.has_rotate = self.check_rotate_attribute(json_data)

                    if self.init_camera():
                        self.main_loop(token)
                    else:
                        print("Critical: Camera failed to initialize. Reverting to Hotspot mode.")
                        self.clear_config_and_reset()
                else:
                    print("Invalid token data. Reverting to Hotspot mode.")
                    self.clear_config_and_reset()
            else:
                print("WiFi connection failed. Reverting to Hotspot mode.")
                self.clear_config_and_reset()
        else:
            print("No valid WiFi config found. Starting Hotspot setup.")
            ip = self.create_hotspot()
            self.setup_web_server(ip)

# Main entry point
if __name__ == '__main__':
    gc.collect()
    app = ESP32_CAM_IoT()
    app.run_setup_mode()