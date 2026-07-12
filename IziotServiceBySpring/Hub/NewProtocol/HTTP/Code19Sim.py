import network
import socket
import time
import machine
import ujson
import ubinascii
import sys
from machine import Pin, reset, UART
import gc  # Import garbage collector
import _thread  # Import the thread module

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
    ussl = None  # Set to None if not available

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
        self.has_thermometer = False
        self.sim_uart = None
        self.connection_type = None  # 'wifi' or 'sim'
        self.log_file = 'system.log'
        self.max_log_size = 10240  # 10KB max log size
        self.connection_attempts = 0
        self.max_connection_attempts = 3

    def log_message(self, message):
        """Append message to log file with timestamp"""
        try:
            import uos
            timestamp = time.time()
            log_entry = f"[{timestamp}] {message}\n"

            # Check log file size
            try:
                stat = uos.stat(self.log_file)
                if stat[6] > self.max_log_size:
                    uos.remove(self.log_file)
            except:
                pass

            with open(self.log_file, 'a') as f:
                f.write(log_entry)
        except Exception as e:
            print(f"Error writing to log: {str(e)}")

    def load_wifi_config(self):
        """Load WiFi credentials and token from file"""
        try:
            with open(self.wifi_config_file, 'r') as f:
                content = f.read()
                self.log_message(f"Raw file content length: {len(content)}")
                config = ujson.loads(content)
                ssid = config.get('ssid')
                password = config.get('password')
                token = config.get('token')
                self.log_message(f"Token found, length: {len(token) if token else 0}")
                return ssid, password, token
        except Exception as e:
            self.log_message(f"Error loading config: {str(e)}")
            return None, None, None

    def validate_token(self, token):
        """Validate token before use"""
        try:
            if not token or len(token) < 10:
                self.log_message("Token too short")
                return False

            decoded = ubinascii.a2b_base64(token).decode('utf-8')
            json_data = ujson.loads(decoded)

            if 'url' not in json_data:
                self.log_message("Token missing required URL field")
                return False

            self.log_message("Token validation successful")
            return True
        except Exception as e:
            self.log_message(f"Token validation failed: {str(e)}")
            return False

    def save_wifi_config(self, ssid, password, token):
        """Save WiFi credentials and token to file"""
        try:
            self.log_message(f"Saving config - Token length: {len(token)}")
            config = {
                'ssid': ssid,
                'password': password,
                'token': token
            }
            json_str = ujson.dumps(config)
            self.log_message(f"Config JSON length: {len(json_str)}")

            import uos
            try:
                uos.remove(self.wifi_config_file)
            except:
                pass

            with open(self.wifi_config_file, 'w') as f:
                chunk_size = 512
                for i in range(0, len(json_str), chunk_size):
                    chunk = json_str[i:i+chunk_size]
                    f.write(chunk)
                f.flush()

            self.log_message("File written successfully")
            time.sleep(0.1)
            with open(self.wifi_config_file, 'r') as f:
                saved_content = f.read()

            self.log_message(f"Verification - Saved content length: {len(saved_content)}")
            saved_config = ujson.loads(saved_content)
            saved_token = saved_config.get('token', '')

            if len(saved_token) == len(token) and saved_token == token:
                self.log_message("WiFi credentials saved and verified successfully")
                return True
            else:
                self.log_message(f"Token verification failed - lengths: {len(saved_token)} vs {len(token)}")
                return False
        except Exception as e:
            self.log_message(f"Error saving config: {str(e)}")
            return False

    def clear_config_and_reset(self):
        """Clear config file and reset to hotspot mode"""
        try:
            import uos
            uos.remove(self.wifi_config_file)
            self.log_message("Config file cleared")
        except:
            self.log_message("Config file not found or already cleared")

        self.log_message("Resetting to hotspot mode...")
        time.sleep(2)
        machine.reset()

    def create_hotspot(self):
        """Create WiFi hotspot for initial setup"""
        ap = network.WLAN(network.AP_IF)
        ap.active(True)
        ap.config(essid=self.ap_ssid, password=self.ap_password)
        ip = ap.ifconfig()[0]
        self.log_message(f"Hotspot created: {self.ap_ssid}, IP: {ip}")
        return ip

    def setup_web_server(self, ip):
        html = """<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>ESP32-CAM Settings</title>
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
        .connection-info { background: #e8f4f8; padding: 15px; border-radius: 5px; margin: 15px 0; }
        .connection-info h3 { margin: 0 0 10px 0; color: #2c5aa0; }
        .connection-info p { margin: 5px 0; font-size: 14px; color: #555; }
    </style>
</head>
<body>
    <div class="container">
        <h2>Smart Camera Settings</h2>

        <div class="connection-info">
            <h3>Internet Connection</h3>
            <p>• First attempts to connect via WiFi</p>
            <p>• If WiFi fails, uses SIM card internet</p>
            <p>• Required SIM module: SIM800L or SIM7600 on pins 16 and 17</p>
        </div>

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
        self.log_message("Web server started on port 80")

        while True:
            conn, addr = s.accept()
            self.log_message(f"Connection from: {str(addr)}")

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
                        self.log_message("Error: Could not extract request body")
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

                    self.log_message(f"Received - SSID: {ssid}, Password length: {len(password)}, Token length: {len(token)}")

                    if ssid and password and token:
                        if self.save_wifi_config(ssid, password, token):
                            response = """HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\n\r\n
<html><body style="font-family:Arial;text-align:center;padding:50px;">
<h2>Settings saved successfully!</h2>
<p>Device is restarting...</p>
<p>Connection priority: WiFi → SIM Card</p>
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
                            self.log_message("Restarting device...")
                            time.sleep(2)
                            machine.reset()
                        return
                else:
                    response = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\n\r\n" + html
                    conn.send(response.encode())

            except Exception as e:
                self.log_message(f"Error handling request: {str(e)}")
            finally:
                conn.close()

    def url_decode(self, s):
        """URL decode special characters"""
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

    def detect_sim_module(self):
        """Detect SIM card module (SIM800L or SIM7600)"""
        try:
            self.log_message("Detecting SIM module...")
            self.sim_uart = UART(2, baudrate=9600, tx=16, rx=17, timeout=1000)
            time.sleep(2)
            self.sim_uart.write('AT\r\n')
            time.sleep(1)
            response = self.sim_uart.read()

            if response and b'OK' in response:
                self.log_message("SIM module detected successfully")
                self.sim_uart.write('AT+CSQ\r\n')
                time.sleep(1)
                csq_response = self.sim_uart.read()
                if csq_response:
                    self.log_message(f"Signal strength: {csq_response.decode('utf-8', errors='ignore')}")
                return True
            else:
                self.log_message("SIM module not detected or not responding")
                return False
        except Exception as e:
            self.log_message(f"Error detecting SIM module: {str(e)}")
            return False

    def check_sim_signal(self):
        """Check SIM signal quality"""
        try:
            if not self.sim_uart:
                self.log_message("SIM UART not initialized for signal check")
                return False
            self.sim_uart.write('AT+CSQ\r\n')
            time.sleep(1)
            response = self.sim_uart.read()
            if response and b'+CSQ' in response:
                signal = response.decode('utf-8', errors='ignore')
                self.log_message(f"SIM signal quality: {signal}")
                # Extract signal strength (simplified)
                if ',99' not in signal:  # 99 indicates no signal
                    return True
                return False
            return False
        except Exception as e:
            self.log_message(f"Error checking SIM signal: {str(e)}")
            return False

    def connect_sim_internet(self):
        """Connect to internet using SIM card"""
        try:
            self.log_message("Connecting to internet via SIM card...")
            if not self.sim_uart:
                self.log_message("SIM UART not initialized")
                return False

            self.sim_uart.write('AT+CPIN?\r\n')
            time.sleep(2)
            response = self.sim_uart.read()
            if not response or b'READY' not in response:
                self.log_message("SIM card not ready")
                return False

            self.sim_uart.write('AT+CREG?\r\n')
            time.sleep(2)
            response = self.sim_uart.read()
            self.log_message(f"Network registration: {response.decode('utf-8', errors='ignore') if response else 'No response'}")

            apn_command = 'AT+CSTT="internet"\r\n'  # Replace with your carrier's APN
            self.sim_uart.write(apn_command)
            time.sleep(2)
            response = self.sim_uart.read()
            self.log_message(f"APN set response: {response.decode('utf-8', errors='ignore') if response else 'No response'}")

            self.sim_uart.write('AT+CIICR\r\n')
            time.sleep(10)
            response = self.sim_uart.read()
            if response:
                self.log_message(f"Wireless connection response: {response.decode('utf-8', errors='ignore')}")

            self.sim_uart.write('AT+CIFSR\r\n')
            time.sleep(2)
            response = self.sim_uart.read()
            if response:
                ip_response = response.decode('utf-8', errors='ignore')
                self.log_message(f"IP address response: {ip_response}")
                if '.' in ip_response and 'ERROR' not in ip_response:
                    self.log_message("SIM internet connection established successfully")
                    self.connection_type = 'sim'
                    return True

            self.log_message("Failed to establish SIM internet connection")
            return False
        except Exception as e:
            self.log_message(f"Error connecting SIM internet: {str(e)}")
            return False

    def connect_wifi(self, ssid, password):
        """Connect to WiFi network"""
        try:
            wlan = network.WLAN(network.STA_IF)
            wlan.active(True)
            wlan.connect(ssid, password)
            self.log_message(f"Connecting to {ssid}...")
            timeout = 0
            while not wlan.isconnected() and timeout < 30:
                print(".", end="")
                time.sleep(1)
                timeout += 1

            if wlan.isconnected():
                self.log_message(f"WiFi connected successfully! IP: {wlan.ifconfig()[0]}")
                self.connection_type = 'wifi'
                return True
            else:
                self.log_message("Failed to connect to WiFi")
                return False
        except Exception as e:
            self.log_message(f"WiFi connection error: {str(e)}")
            return False

    def check_wifi_status(self):
        """Check if WiFi is still connected"""
        try:
            wlan = network.WLAN(network.STA_IF)
            if wlan.isconnected():
                self.log_message("WiFi connection is active")
                return True
            self.log_message("WiFi connection lost")
            return False
        except Exception as e:
0            self.log_message(f"Error checking WiFi status: {str(e)}")
            return False

    def establish_internet_connection(self, ssid, password):
        """Try to establish internet connection (WiFi first, then SIM)"""
        self.log_message("Attempting to establish internet connection")
        self.connection_attempts += 1

        if self.connection_attempts > self.max_connection_attempts:
            self.log_message("Max connection attempts reached, reverting to hotspot mode")
            self.clear_config_and_reset()
            return False

        print("1. Trying WiFi connection...")
        if self.connect_wifi(ssid, password):
            self.connection_attempts = 0
            self.log_message("WiFi connection successful")
            return True

        print("2. WiFi failed, trying SIM connection...")
        if self.detect_sim_module() and self.check_sim_signal():
            if self.connect_sim_internet():
                self.connection_attempts = 0
                self.log_message("SIM connection successful")
                return True

        self.log_message("All connection methods failed")
        return False

    def decode_token(self, token):
        """Decode base64 token and convert to JSON"""
        try:
            decoded = ubinascii.a2b_base64(token).decode('utf-8')
            json_data = ujson.loads(decoded)
            self.log_message(f"Token decoded successfully: {str(json_data)}")
            return json_data
        except Exception as e:
            self.log_message(f"Error decoding token: {str(e)}")
            self.clear_config_and_reset()
            return None

    def extract_server_url(self, json_data):
        """Extract server URL from token"""
        try:
            server_url = json_data.get('url', '')
            if server_url:
                self.log_message(f"Server URL extracted: {server_url}")
                return server_url
            else:
                self.log_message("URL field not found in token")
                return None
        except Exception as e:
            self.log_message(f"Error extracting server URL: {str(e)}")
            return None

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
            self.log_message(f"Thermometer attribute check: {has_thermometer}, Attributes: {attributes}")
            return has_thermometer
        except Exception as e:
            self.log_message(f"Error checking thermometer attribute: {str(e)}")
            return False

    def init_camera(self):
        """Initialize camera module"""
        try:
            camera.init(0, format=camera.JPEG, fb_location=camera.PSRAM)
            camera.quality(10)
            camera.framesize(camera.FRAME_VGA)
            camera.flip(1)
            camera.mirror(1)
            self.log_message("Camera initialized successfully")
            return True
        except Exception as e:
            self.log_message(f"Camera initialization failed: {str(e)}")
            try:
                camera.init(0, format=camera.JPEG)
                camera.quality(10)
                camera.framesize(camera.FRAME_VGA)
                camera.flip(1)
                camera.mirror(1)
                self.log_message("Camera initialized successfully (fallback)")
                return True
            except Exception as e2:
                self.log_message(f"Camera fallback initialization failed: {str(e2)}")
                return False

    def capture_image(self):
        """Capture image from camera"""
        try:
            # led_pin.on()
            # time.sleep(0.1)
            buf = camera.capture()
            # led_pin.off()
            if buf:
                self.log_message(f"Image captured - Size: {len(buf)} bytes")
                return buf
            else:
                self.log_message("Failed to capture image")
                return None
        except Exception as e:
            self.log_message(f"Error capturing image: {str(e)}")
            # led_pin.off()
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
            self.log_message(f"Found DS18B20 devices: {len(roms)}")

            if len(roms) == 0:
                self.log_message("No DS18B20 sensors found")
                return 25.0

            ds_sensor.convert_temp()
            time.sleep_ms(750)
            temperatures = []
            for i, rom in enumerate(roms):
                try:
                    temp = ds_sensor.read_temp(rom)
                    if temp is not None:
                        temperatures.append(round(temp, 2))
                        self.log_message(f"Sensor {i} temperature: {temp}°C")
                    else:
                        self.log_message(f"Sensor {i} returned None")
                except Exception as e:
                    self.log_message(f"Error reading sensor {i}: {str(e)}")

            if temperatures:
                avg_temp = sum(temperatures) / len(temperatures)
                self.log_message(f"Average temperature: {round(avg_temp, 2)}°C")
                return round(avg_temp, 2)
            else:
                self.log_message("No valid temperature readings")
                return 25.0
        except ImportError:
            self.log_message("DS18B20 libraries not available, using random temperature")
            import random
            temp = 20 + random.randint(0, 20)
            self.log_message(f"Random temperature: {temp}°C")
            return temp
        except Exception as e:
            self.log_message(f"Error reading temperature: {str(e)}")
            return 25.0

    def send_http_request_sim(self, method, url, headers, data=None, retries=2):
        """Send HTTP request using SIM module with retries"""
        attempt = 0
        while attempt <= retries:
            try:
                if not self.sim_uart:
                    self.log_message("SIM UART not initialized")
                    return None

                if url.startswith('https://'):
                    host = url[8:].split('/')[0]
                    path = '/' + '/'.join(url[8:].split('/')[1:])
                    use_ssl = True
                else:
                    host = url[7:].split('/')[0]
                    path = '/' + '/'.join(url[7:].split('/')[1:])
                    use_ssl = False

                port = 443 if use_ssl else 80
                connect_cmd = f'AT+CIPSTART="TCP","{host}",{port}\r\n'
                self.sim_uart.write(connect_cmd)
                time.sleep(3)
                response = self.sim_uart.read()

                if not response or b'CONNECT OK' not in response:
                    self.log_message(f"Failed to connect to server via SIM (attempt {attempt + 1})")
                    attempt += 1
                    time.sleep(2)
                    continue

                request_lines = [f'{method} {path} HTTP/1.1', f'Host: {host}']
                request_lines.extend(headers)
                request_lines.append('')
                if data:
                    request_lines.append(data)
                http_request = '\r\n'.join(request_lines)

                send_cmd = f'AT+CIPSEND={len(http_request)}\r\n'
                self.sim_uart.write(send_cmd)
                time.sleep(1)
                response = self.sim_uart.read()
                if response and b'>' in response:
                    self.sim_uart.write(http_request)
                    time.sleep(5)
                    response = self.sim_uart.read()
                    if response:
                        response_str = response.decode('utf-8', errors='ignore')
                        self.log_message(f"SIM HTTP response: {response_str[:200] + '...' if len(response_str) > 200 else response_str}")
                        self.sim_uart.write('AT+CIPCLOSE\r\n')
                        time.sleep(1)
                        return response_str
                self.sim_uart.write('AT+CIPCLOSE\r\n')
                time.sleep(1)
                attempt += 1
            except Exception as e:
                self.log_message(f"Error sending HTTP request via SIM (attempt {attempt + 1}): {str(e)}")
                attempt += 1
                time.sleep(2)
        self.log_message("All SIM HTTP request attempts failed")
        return None

    def _upload_temperature_thread(self, temperature, server_url, token):
        """Upload temperature in a separate thread"""
        gc.collect()
        self.log_message(f"Free memory before temp upload: {gc.mem_free()} bytes")
        try:
            if self.connection_type == 'wifi':
                return self._upload_temperature_wifi(temperature, server_url, token)
            elif self.connection_type == 'sim':
                return self._upload_temperature_sim(temperature, server_url, token)
            else:
                self.log_message("No active internet connection")
                return False
        except Exception as e:
            self.log_message(f"Error in temperature upload thread: {str(e)}")
            return False

    def _upload_temperature_wifi(self, temperature, server_url, token, retries=2):
        """Upload temperature data via WiFi with retries"""
        attempt = 0
        while attempt <= retries:
            try:
                temp_data = {
                    'temperature': temperature,
                    'timestamp': time.time(),
                    'device_id': ubinascii.hexlify(machine.unique_id()).decode()
                }
                json_data = ujson.dumps(temp_data)

                if server_url.startswith('https://'):
                    host = server_url[8:].split('/')[0]
                    path = '/' + '/'.join(server_url[8:].split('/')[1:]) or '/NProtocol/api/Temp'
                    use_ssl = True
                    port = 443
                else:
                    host = server_url[7:].split('/')[0] if server_url.startswith('http://') else server_url
                    path = '/' + '/'.join(server_url[7:].split('/')[1:]) or '/NProtocol/api/Temp'
                    use_ssl = False
                    port = 80

                s = socket.socket()
                s.settimeout(10)
                if use_ssl and ussl:
                    s = ussl.wrap_socket(s, server_hostname=host)
                s.connect((host, port))

                request = f"POST {path} HTTP/1.1\r\n"
                request += f"Host: {host}\r\n"
                request += f"Authorization: Bearer {token}\r\n"
                request += "Content-Type: application/json\r\n"
                request += f"Content-Length: {len(json_data)}\r\n"
                request += "Connection: close\r\n\r\n"
                request += json_data

                s.write(request.encode())
                response = s.read(1024)
                s.close()

                if response:
                    response_str = response.decode('utf-8', errors='ignore')
                    self.log_message(f"Temperature upload response: {response_str[:200]}")
                    if "200 OK" in response_str or "201" in response_str:
                        self.log_message("Temperature uploaded successfully")
                        return True
                    else:
                        self.log_message(f"Temperature upload failed (attempt {attempt + 1})")
                        attempt += 1
                        time.sleep(2)
                        continue
                else:
                    self.log_message(f"No response from temperature upload (attempt {attempt + 1})")
                    attempt += 1
                    time.sleep(2)
            except Exception as e:
                self.log_message(f"Error uploading temperature via WiFi (attempt {attempt + 1}): {str(e)}")
                attempt += 1
                time.sleep(2)
        self.log_message("All WiFi temperature upload attempts failed")
        return False

    def _upload_temperature_sim(self, temperature, server_url, token):
        """Upload temperature data via SIM"""
        try:
            temp_data = {
                'temperature': temperature,
                'timestamp': time.time(),
                'device_id': ubinascii.hexlify(machine.unique_id()).decode()
            }
            json_data = ujson.dumps(temp_data)
            headers = [
                f"Authorization: Bearer {token}",
                "Content-Type: application/json",
                f"Content-Length: {len(json_data)}",
                "Connection: close"
            ]
            response = self.send_http_request_sim('POST', server_url + '/NProtocol/api/Temp', headers, json_data)
            if response and ("200 OK" in response or "201" in response):
                self.log_message("Temperature uploaded successfully via SIM")
                return True
            else:
                self.log_message("Temperature upload failed via SIM")
                return False
        except Exception as e:
            self.log_message(f"Error uploading temperature via SIM: {str(e)}")
            return False

    def upload_image(self, image_data, server_url, token):
        """Upload image to server"""
        gc.collect()
        self.log_message(f"Free memory before image upload: {gc.mem_free()} bytes")
        try:
            if self.connection_type == 'wifi':
                return self._upload_image_wifi(image_data, server_url, token)
            elif self.connection_type == 'sim':
                return self._upload_image_sim(image_data, server_url, token)
            else:
                self.log_message("No active internet connection")
                return False
        except Exception as e:
            self.log_message(f"Error in image upload: {str(e)}")
            return False

    def _upload_image_wifi(self, image_data, server_url, token, retries=2):
        """Upload image via WiFi with retries"""
        attempt = 0
        while attempt <= retries:
            try:
                if server_url.startswith('https://'):
                    host = server_url[8:].split('/')[0]
                    path = '/' + '/'.join(server_url[8:].split('/')[1:]) or '/NProtocol/api/UploadImage'
                    use_ssl = True
                    port = 443
                else:
                    host = server_url[7:].split('/')[0] if server_url.startswith('http://') else server_url
                    path = '/' + '/'.join(server_url[7:].split('/')[1:]) or '/NProtocol/api/UploadImage'
                    use_ssl = False
                    port = 80

                boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
                body = f"--{boundary}\r\n"
                body += 'Content-Disposition: form-data; name="image"; filename="capture.jpg"\r\n'
                body += "Content-Type: image/jpeg\r\n\r\n"
                body_bytes = body.encode('utf-8') + image_data + f"\r\n--{boundary}--\r\n".encode('utf-8')

                s = socket.socket()
                s.settimeout(30)
                if use_ssl and ussl:
                    s = ussl.wrap_socket(s, server_hostname=host)
                s.connect((host, port))

                request = f"POST {path} HTTP/1.1\r\n"
                request += f"Host: {host}\r\n"
                request += f"Authorization: Bearer {token}\r\n"
                request += f"Content-Type: multipart/form-data; boundary={boundary}\r\n"
                request += f"Content-Length: {len(body_bytes)}\r\n"
                request += "Connection: close\r\n\r\n"

                s.write(request.encode())
                chunk_size = 1024
                for i in range(0, len(body_bytes), chunk_size):
                    chunk = body_bytes[i:i+chunk_size]
                    s.write(chunk)
                    time.sleep(0.01)

                response = s.read(1024)
                s.close()

                if response:
                    response_str = response.decode('utf-8', errors='ignore')
                    self.log_message(f"Image upload response: {response_str[:200]}")
                    if "200 OK" in response_str or "201" in response_str:
                        self.log_message("Image uploaded successfully")
                        return True
                    else:
                        self.log_message(f"Image upload failed (attempt {attempt + 1})")
                        attempt += 1
                        time.sleep(2)
                        continue
                else:
                    self.log_message(f"No response from image upload (attempt {attempt + 1})")
                    attempt += 1
                    time.sleep(2)
            except Exception as e:
                self.log_message(f"Error uploading image via WiFi (attempt {attempt + 1}): {str(e)}")
                attempt += 1
                time.sleep(2)
        self.log_message("All WiFi image upload attempts failed")
        return False

    def _upload_image_sim(self, image_data, server_url, token):
        """Upload image via SIM with base64 encoding"""
        try:
            import ubinascii
            image_b64 = ubinascii.b2a_base64(image_data).decode('utf-8')
            json_data = ujson.dumps({
                'image': image_b64,
                'timestamp': time.time(),
                'device_id': ubinascii.hexlify(machine.unique_id()).decode()
            })
            headers = [
                f"Authorization: Bearer {token}",
                "Content-Type: application/json",
                f"Content-Length: {len(json_data)}",
                "Connection: close"
            ]
            response = self.send_http_request_sim('POST', server_url + '/NProtocol/api/UploadImage', headers, json_data)
            if response and ("200 OK" in response or "201" in response):
                self.log_message("Image uploaded successfully via SIM")
                return True
            else:
                self.log_message("Image upload failed via SIM")
                return False
        except Exception as e:
            self.log_message(f"Error uploading image via SIM: {str(e)}")
            return False

    def monitor_reset_button(self):
        """Monitor reset button with long-press detection"""
        try:
            if reset_pin.value() == 0:
                start_time = time.time()
                time.sleep(0.1)
                if reset_pin.value() == 0:
                    while reset_pin.value() == 0 and (time.time() - start_time) < 3:
                        time.sleep(0.1)
                    if reset_pin.value() == 0:
                        self.log_message("Long-press detected, clearing configuration and resetting...")
                        self.clear_config_and_reset()
        except Exception as e:
            self.log_message(f"Error monitoring reset button: {str(e)}")

    def run_main_loop(self):
        """Main operational loop with connection monitoring"""
        try:
            self.log_message("Starting main operational loop")
            last_connection_check = time.time()
            connection_check_interval = 300  # Check every 5 minutes

            while True:
                self.monitor_reset_button()
                gc.collect()

                # Periodic connection check
                if time.time() - last_connection_check > connection_check_interval:
                    if self.connection_type == 'wifi' and not self.check_wifi_status():
                        self.log_message("WiFi connection lost, attempting reconnection...")
                        ssid, password, _ = self.load_wifi_config()
                        if not self.establish_internet_connection(ssid, password):
                            self.log_message("Failed to reconnect, continuing loop")
                    elif self.connection_type == 'sim' and not self.check_sim_signal():
                        self.log_message("SIM signal lost, attempting reconnection...")
                        ssid, password, _ = self.load_wifi_config()
                        if not self.establish_internet_connection(ssid, password):
                            self.log_message("Failed to reconnect, continuing loop")
                    last_connection_check = time.time()

                self.log_message("Capturing image...")
                image_data = self.capture_image()
                if image_data:
                    self.log_message("Uploading image...")
                    self.upload_image(image_data, self.server_url, self.token)
                    del image_data
                    gc.collect()

                if self.has_thermometer:
                    self.log_message("Reading temperature...")
                    temperature = self.get_temperature()
                    self.log_message(f"Current temperature: {temperature}°C")
                    try:
                        _thread.start_new_thread(self._upload_temperature_thread, (temperature, self.server_url, self.token))
                    except Exception as e:
                        self.log_message(f"Error starting temperature upload thread: {str(e)}")

                self.log_message(f"Free memory: {gc.mem_free()} bytes")
                self.log_message("Waiting 10 seconds before next cycle...")
                time.sleep(10)
        except Exception as e:
            self.log_message(f"Error in main loop: {str(e)}")
            time.sleep(5)
            self.run_main_loop()

    def run(self):
        """Main entry point"""
        self.log_message("ESP32-CAM IoT System Starting")
        ssid, password, token = self.load_wifi_config()

        if ssid and password and token:
            self.log_message("Configuration found, attempting connection...")
            if not self.validate_token(token):
                self.log_message("Invalid token found, clearing configuration...")
                self.clear_config_and_reset()
                return

            if self.establish_internet_connection(ssid, password):
                self.log_message("Internet connection established!")
                json_data = self.decode_token(token)
                if json_data:
                    self.server_url = self.extract_server_url(json_data)
                    self.token = token
                    self.has_thermometer = self.check_thermometer_attribute(json_data)
                    if self.server_url:
                        if self.init_camera():
                            self.log_message("System ready! Starting main loop...")
                            self.run_main_loop()
                        else:
                            self.log_message("Camera initialization failed!")
                    else:
                        self.log_message("Server URL not found in token")
                        self.clear_config_and_reset()
                else:
                    self.log_message("Token decoding failed")
                    self.clear_config_and_reset()
            else:
                self.log_message("Failed to establish internet connection")
                self.log_message("Please check your WiFi credentials and SIM card")
                time.sleep(10)
                self.clear_config_and_reset()
        else:
            self.log_message("No configuration found, starting setup mode...")
            ip = self.create_hotspot()
            self.setup_web_server(ip)

if __name__ == "__main__":
    try:
        esp32_cam = ESP32_CAM_IoT()
        esp32_cam.run()
    except Exception as e:
        print(f"Critical error: {str(e)}")
        time.sleep(5)
        machine.reset()