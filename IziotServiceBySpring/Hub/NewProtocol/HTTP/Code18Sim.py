import network
import socket
import time
import machine
import ujson
import ubinascii
import sys
from machine import Pin, reset, UART
import gc # Import garbage collector
import _thread # Import the thread module

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
led_pin = Pin(4, Pin.OUT)  # LED flash LED pin
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

    def load_wifi_config(self):
        # Step 2: Check if WiFi credentials are saved
        try:
            with open(self.wifi_config_file, 'r') as f:
                # Read entire file content
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
            # Check token length
            if not token or len(token) < 10:
                print("Token too short")
                return False

            # Test decoding
            decoded = ubinascii.a2b_base64(token).decode('utf-8')
            json_data = ujson.loads(decoded)

            # Check for required field
            if 'url' not in json_data:
                print("Token missing required URL field")
                return False

            print("Token validation successful")
            return True

        except Exception as e:
            print("Token validation failed:", str(e))
            return False

    def save_wifi_config(self, ssid, password, token):
        # Step 4: Save WiFi credentials to memory - improved for large tokens
        try:
            print("Saving config - Token length:", len(token))

            config = {
                'ssid': ssid,
                'password': password,
                'token': token
            }

            # Convert to JSON
            json_str = ujson.dumps(config)
            print("Config JSON length:", len(json_str))

            # Save to file with improved method for large files
            try:
                # First delete old file
                import uos
                try:
                    uos.remove(self.wifi_config_file)
                except:
                    pass

                # Save in small chunks to prevent memory issues
                with open(self.wifi_config_file, 'w') as f:
                    chunk_size = 512
                    for i in range(0, len(json_str), chunk_size):
                        chunk = json_str[i:i+chunk_size]
                        f.write(chunk)
                    f.flush()  # Ensure complete writing

                print("File written successfully")

                # Verify save by reading again
                time.sleep(0.1)  # Small delay for safety
                with open(self.wifi_config_file, 'r') as f:
                    saved_content = f.read()

                print("Verification - Saved content length:", len(saved_content))

                # Verify save correctness
                try:
                    saved_config = ujson.loads(saved_content)
                    saved_token = saved_config.get('token', '')

                    if len(saved_token) == len(token) and saved_token == token:
                        print("WiFi credentials saved and verified successfully")
                        return True
                    else:
                        print("Token verification failed - lengths:", len(saved_token), "vs", len(token))
                        return False

                except Exception as e:
                    print("JSON parse error during verification:", str(e))
                    return False

            except Exception as e:
                print("File operations error:", str(e))
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
            <h3>اتصال به اینترنت</h3>
            <p>• اول تلاش برای اتصال به WiFi انجام می‌شود</p>
            <p>• در صورت عدم موفقیت، از اینترنت سیمکارت استفاده می‌شود</p>
            <p>• نیاز به ماژول سیمکارت: SIM800L یا SIM7600 روی پین‌های 16 و 17</p>
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
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)  # Allow address reuse
        s.bind(('', 80))
        s.listen(5)
        print("Web server started on port 80")

        while True:
            conn, addr = s.accept()
            print("Connection from: " + str(addr))

            try:
                # Receive request using simpler method for MicroPython
                request_data = b''
                conn.settimeout(5)

                while True:
                    try:
                        chunk = conn.recv(1024)
                        if not chunk:
                            break
                        request_data += chunk

                        # Check for end of headers
                        if b'\r\n\r\n' in request_data:
                            # Separate headers and body
                            parts = request_data.split(b'\r\n\r\n', 1)
                            headers = parts[0]

                            # If POST, we also need the body
                            if b'POST' in headers:
                                body_part = parts[1] if len(parts) > 1 else b''

                                # Check Content-Length
                                content_length = 0
                                for line in headers.split(b'\r\n'):
                                    if line.lower().startswith(b'content-length:'):
                                        content_length = int(line.split(b':')[1].strip())
                                        break

                                # Continue receiving until body is complete
                                while len(body_part) < content_length:
                                    more_data = conn.recv(min(1024, content_length - len(body_part)))
                                    if not more_data:
                                        break
                                    body_part += more_data
                                    request_data = headers + b'\r\n\r\n' + body_part
                                break
                    except:
                        break

                # Convert to string using simple method
                try:
                    request = request_data.decode('utf-8')
                except:
                    # If decode fails, remove problematic characters
                    request = ''
                    for byte in request_data:
                        try:
                            char = chr(byte)
                            if ord(char) < 128:  # Only ASCII
                                request += char
                        except:
                            pass

                if 'POST /setup' in request:
                    # Process form data - improved for large tokens
                    try:
                        body = request.split('\r\n\r\n')[1]
                    except:
                        print("Error: Could not extract request body")
                        continue

                    params = {}

                    # Process parameters with support for large tokens
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
                                # URL decode
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
                            print("Step 5: Restarting device...")
                            time.sleep(2)
                            machine.reset()
                        return

                else:
                    # Display setup form
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

    def detect_sim_module(self):
        """Detect SIM card module (SIM800L or SIM7600)"""
        try:
            print("Detecting SIM module...")

            # Initialize UART for SIM module (GPIO 16 = TX, GPIO 17 = RX)
            self.sim_uart = UART(2, baudrate=9600, tx=16, rx=17, timeout=1000)
            time.sleep(2)

            # Test AT command
            self.sim_uart.write('AT\r\n')
            time.sleep(1)
            response = self.sim_uart.read()

            if response and b'OK' in response:
                print("SIM module detected successfully")

                # Check signal strength
                self.sim_uart.write('AT+CSQ\r\n')
                time.sleep(1)
                csq_response = self.sim_uart.read()
                if csq_response:
                    print("Signal strength:", csq_response.decode('utf-8', errors='ignore'))

                return True
            else:
                print("SIM module not detected or not responding")
                return False

        except Exception as e:
            print("Error detecting SIM module:", str(e))
            return False

    def connect_sim_internet(self):
        """Connect to internet using SIM card"""
        try:
            print("Connecting to internet via SIM card...")

            if not self.sim_uart:
                print("SIM UART not initialized")
                return False

            # Check SIM card status
            self.sim_uart.write('AT+CPIN?\r\n')
            time.sleep(2)
            response = self.sim_uart.read()
            if not response or b'READY' not in response:
                print("SIM card not ready")
                return False

            # Check network registration
            self.sim_uart.write('AT+CREG?\r\n')
            time.sleep(2)
            response = self.sim_uart.read()
            print("Network registration:", response.decode('utf-8', errors='ignore') if response else "No response")

            # Set APN (replace with your carrier's APN)
            # Common APNs: "internet" for many carriers, "web.gprs.mtncl.com" for MTN, etc.
            apn_command = 'AT+CSTT="internet"\r\n'  # Change "internet" to your carrier's APN
            self.sim_uart.write(apn_command)
            time.sleep(2)
            response = self.sim_uart.read()
            print("APN set response:", response.decode('utf-8', errors='ignore') if response else "No response")

            # Bring up wireless connection
            self.sim_uart.write('AT+CIICR\r\n')
            time.sleep(10)  # This can take some time
            response = self.sim_uart.read()
            if response:
                print("Wireless connection response:", response.decode('utf-8', errors='ignore'))

            # Get IP address
            self.sim_uart.write('AT+CIFSR\r\n')
            time.sleep(2)
            response = self.sim_uart.read()
            if response:
                ip_response = response.decode('utf-8', errors='ignore')
                print("IP address response:", ip_response)

                # Check if we got a valid IP
                if '.' in ip_response and not 'ERROR' in ip_response:
                    print("SIM internet connection established successfully")
                    self.connection_type = 'sim'
                    return True

            print("Failed to establish SIM internet connection")
            return False

        except Exception as e:
            print("Error connecting SIM internet:", str(e))
            return False

    def connect_wifi(self, ssid, password):
        """Connect to WiFi network"""
        try:
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
                print("\nWiFi connected successfully! IP: " + wlan.ifconfig()[0])
                self.connection_type = 'wifi'
                return True
            else:
                print("\nFailed to connect to WiFi")
                return False
        except Exception as e:
            print("WiFi connection error:", str(e))
            return False

    def establish_internet_connection(self, ssid, password):
        """Try to establish internet connection (WiFi first, then SIM)"""
        print("=== Attempting to establish internet connection ===")

        # First try WiFi
        print("1. Trying WiFi connection...")
        if self.connect_wifi(ssid, password):
            print("✓ WiFi connection successful")
            return True

        # If WiFi fails, try SIM
        print("2. WiFi failed, trying SIM connection...")
        if self.detect_sim_module():
            if self.connect_sim_internet():
                print("✓ SIM connection successful")
                return True

        print("✗ All connection methods failed")
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
            # If decode error occurs, clear config file
            self.clear_config_and_reset()
            return None

    def extract_server_url(self, json_data):
        # Step 8: Extract server URL from url field
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

    def check_thermometer_attribute(self, json_data):
        """Check if token contains thermometer attribute"""
        try:
            attributes = json_data.get('attribute', '')
            if isinstance(attributes, list):
                # If attribute is a list, check if Thermometer is in it
                has_thermometer = 'Thermometer' in attributes
            elif isinstance(attributes, str):
                # If attribute is a string, check if it contains Thermometer
                has_thermometer = 'Thermometer' in attributes
            else:
                # If attribute is not present or not string/list
                has_thermometer = False

            print("Thermometer attribute check: " + str(has_thermometer))
            print("Attributes found: " + str(attributes))
            return has_thermometer
        except Exception as e:
            print("Error checking thermometer attribute: " + str(e))
            return False

    def init_camera(self):
        # Initialize camera module using proper method
        try:
            # Initialize camera with specific settings (based on working example)
            camera.init(0, format=camera.JPEG, fb_location=camera.PSRAM)
            camera.quality(10)  # 10-63, lower is higher quality
            camera.framesize(camera.FRAME_VGA)  # Options: FRAME_QVGA, FRAME_VGA, FRAME_SVGA

            # Set vertical flip to rotate image 180 degrees
            camera.flip(1)  # Vertical flip
            camera.mirror(1)  # Horizontal flip (combined with vertical flip = 180° rotation)

            print("Camera initialized successfully")
            return True
        except Exception as e:
            print("Camera initialization failed:", str(e))
            # Try fallback method
            try:
                camera.init(0, format=camera.JPEG)
                camera.quality(10)
                camera.framesize(camera.FRAME_VGA)

                # Set vertical flip to rotate image 180 degrees
                camera.flip(1)  # Vertical flip
                camera.mirror(1)  # Horizontal flip (combined with vertical flip = 180° rotation)

                print("Camera initialized successfully (fallback method)")
                return True
            except Exception as e2:
                print("Camera fallback initialization also failed:", str(e2))
                return False

    def capture_image(self):
        # Step 10: Capture image from camera
        try:
            # led_pin.on()  # Turn on flash LED
            # time.sleep(0.1)

            buf = camera.capture()
            # led_pin.off()  # Turn off flash LED

            if buf:
                print("Image captured - Size: " + str(len(buf)) + " bytes")
                return buf
            else:
                print("Failed to capture image")
                return None
        except Exception as e:
            print("Error capturing image: " + str(e))
            # led_pin.off()
            return None

    def get_temperature(self):
        """Get temperature reading from DS18B20 sensor"""
        try:
            # DS18B20 temperature sensor on pin 2
            import onewire
            import ds18x20
            from machine import Pin

            # Setup OneWire bus on pin 2
            ds_pin = Pin(2)
            ds_sensor = ds18x20.DS18X20(onewire.OneWire(ds_pin))

            # Scan for devices
            roms = ds_sensor.scan()
            print("Found DS18B20 devices:", len(roms))

            if len(roms) == 0:
                print("No DS18B20 sensors found")
                return 25.0  # Default temperature

            # Request temperature conversion
            ds_sensor.convert_temp()
            time.sleep_ms(750)  # Wait for conversion (750ms for 12-bit resolution)

            # Read temperatures from all sensors
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
                # Return average temperature if multiple sensors, or single temperature
                avg_temp = sum(temperatures) / len(temperatures)
                print("Average temperature: " + str(round(avg_temp, 2)) + "°C")
                return round(avg_temp, 2)
            else:
                print("No valid temperature readings")
                return 25.0  # Default temperature

        except ImportError:
            print("DS18B20 libraries not available, using random temperature")
            # Fallback to random temperature for testing
            import random
            temp = 20 + random.randint(0, 20)
            print("Random temperature: " + str(temp) + "°C")
            return temp
        except Exception as e:
            print("Error reading temperature: " + str(e))
            return 25.0  # Default temperature

    def send_http_request_sim(self, method, url, headers, data=None):
        """Send HTTP request using SIM module"""
        try:
            if not self.sim_uart:
                print("SIM UART not initialized")
                return None

            # Parse URL
            if url.startswith('https://'):
                host = url[8:].split('/')[0]
                path = '/' + '/'.join(url[8:].split('/')[1:])
                use_ssl = True
            else:
                host = url[7:].split('/')[0]
                path = '/' + '/'.join(url[7:].split('/')[1:])
                use_ssl = False

            port = 443 if use_ssl else 80

            # Start TCP connection
            connect_cmd = f'AT+CIPSTART="TCP","{host}",{port}\r\n'
            self.sim_uart.write(connect_cmd)
            time.sleep(3)
            response = self.sim_uart.read()

            if not response or b'CONNECT OK' not in response:
                print("Failed to connect to server via SIM")
                return None

            # Build HTTP request
            request_lines = [f'{method} {path} HTTP/1.1', f'Host: {host}']
            request_lines.extend(headers)
            request_lines.append('')  # Empty line before body

            if data:
                request_lines.append(data)

            http_request = '\r\n'.join(request_lines)

            # Send HTTP request
            send_cmd = f'AT+CIPSEND={len(http_request)}\r\n'
            self.sim_uart.write(send_cmd)
            time.sleep(1)

            # Wait for '>' prompt
            response = self.sim_uart.read()
            if response and b'>' in response:
                self.sim_uart.write(http_request)
                time.sleep(5)  # Wait for response

                response = self.sim_uart.read()
                if response:
                    response_str = response.decode('utf-8', errors='ignore')
                    print("SIM HTTP response:", response_str[:200] + "..." if len(response_str) > 200 else response_str)

                    # Close connection
                    self.sim_uart.write('AT+CIPCLOSE\r\n')
                    time.sleep(1)

                    return response_str

            # Close connection in case of error
            self.sim_uart.write('AT+CIPCLOSE\r\n')
            time.sleep(1)
            return None

        except Exception as e:
            print("Error sending HTTP request via SIM:", str(e))
            return None

    def _upload_temperature_thread(self, temperature, server_url, token):
            # Explicitly run garbage collection before starting memory-intensive operations
            gc.collect()
            print(f"Free memory before temp upload: {gc.mem_free()} bytes")

            try:
                if self.connection_type == 'wifi':
                    return self._upload_temperature_wifi(temperature, server_url, token)
                elif self.connection_type == 'sim':
                    return self._upload_temperature_sim(temperature, server_url, token)
                else:
                    print("No active internet connection")
                    return False
            except Exception as e:
                print("Error in temperature upload thread:", str(e))
                return False

        def _upload_temperature_wifi(self, temperature, server_url, token):
            """Upload temperature data via WiFi"""
            try:
                # Create temperature data payload
                temp_data = {
                    'temperature': temperature,
                    'timestamp': time.time(),
                    'device_id': ubinascii.hexlify(machine.unique_id()).decode()
                }

                json_data = ujson.dumps(temp_data)

                # Parse server URL
                if server_url.startswith('https://'):
                    host = server_url[8:].split('/')[0]
                    path = '/' + '/'.join(server_url[8:].split('/')[1:])
                    use_ssl = True
                    port = 443
                else:
                    host = server_url[7:].split('/')[0] if server_url.startswith('http://') else server_url
                    path = '/' + '/'.join(server_url[7:].split('/')[1:]) if server_url.startswith('http://') else '/'
                    use_ssl = False
                    port = 80

                # Create socket connection
                s = socket.socket()
                s.settimeout(10)

                if use_ssl and ussl:
                    s = ussl.wrap_socket(s, server_hostname=host)

                s.connect((host, port))

                # Build HTTP request
                request = f"POST {path} HTTP/1.1\r\n"
                request += f"Host: {host}\r\n"
                request += f"Authorization: Bearer {token}\r\n"
                request += "Content-Type: application/json\r\n"
                request += f"Content-Length: {len(json_data)}\r\n"
                request += "Connection: close\r\n\r\n"
                request += json_data

                s.write(request.encode())

                # Read response
                response = s.read(1024)
                s.close()

                if response:
                    response_str = response.decode('utf-8', errors='ignore')
                    print("Temperature upload response:", response_str[:200])

                    if "200 OK" in response_str or "201" in response_str:
                        print("Temperature uploaded successfully")
                        return True
                    else:
                        print("Temperature upload failed")
                        return False
                else:
                    print("No response from temperature upload")
                    return False

            except Exception as e:
                print("Error uploading temperature via WiFi:", str(e))
                return False

        def _upload_temperature_sim(self, temperature, server_url, token):
            """Upload temperature data via SIM"""
            try:
                # Create temperature data payload
                temp_data = {
                    'temperature': temperature,
                    'timestamp': time.time(),
                    'device_id': ubinascii.hexlify(machine.unique_id()).decode()
                }

                json_data = ujson.dumps(temp_data)

                # Prepare headers
                headers = [
                    f"Authorization: Bearer {token}",
                    "Content-Type: application/json",
                    f"Content-Length: {len(json_data)}",
                    "Connection: close"
                ]

                # Send request via SIM
                response = self.send_http_request_sim('POST', server_url, headers, json_data)

                if response and ("200 OK" in response or "201" in response):
                    print("Temperature uploaded successfully via SIM")
                    return True
                else:
                    print("Temperature upload failed via SIM")
                    return False

            except Exception as e:
                print("Error uploading temperature via SIM:", str(e))
                return False

        def upload_image(self, image_data, server_url, token):
            """Upload image to server"""
            try:
                print("Starting image upload...")
                gc.collect()  # Clean up memory before upload

                if self.connection_type == 'wifi':
                    return self._upload_image_wifi(image_data, server_url, token)
                elif self.connection_type == 'sim':
                    return self._upload_image_sim(image_data, server_url, token)
                else:
                    print("No active internet connection")
                    return False

            except Exception as e:
                print("Error in image upload:", str(e))
                return False

        def _upload_image_wifi(self, image_data, server_url, token):
            """Upload image via WiFi"""
            try:
                # Parse server URL
                if server_url.startswith('https://'):
                    host = server_url[8:].split('/')[0]
                    path = '/' + '/'.join(server_url[8:].split('/')[1:])
                    use_ssl = True
                    port = 443
                else:
                    host = server_url[7:].split('/')[0] if server_url.startswith('http://') else server_url
                    path = '/' + '/'.join(server_url[7:].split('/')[1:]) if server_url.startswith('http://') else '/'
                    use_ssl = False
                    port = 80

                # Create multipart form data
                boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"

                # Build multipart body
                body = f"--{boundary}\r\n"
                body += 'Content-Disposition: form-data; name="image"; filename="capture.jpg"\r\n'
                body += "Content-Type: image/jpeg\r\n\r\n"

                # Convert body to bytes and add image data
                body_bytes = body.encode('utf-8')
                body_bytes += image_data
                body_bytes += f"\r\n--{boundary}--\r\n".encode('utf-8')

                # Create socket connection
                s = socket.socket()
                s.settimeout(30)  # Longer timeout for image upload

                if use_ssl and ussl:
                    s = ussl.wrap_socket(s, server_hostname=host)

                s.connect((host, port))

                # Build HTTP request
                request = f"POST {path} HTTP/1.1\r\n"
                request += f"Host: {host}\r\n"
                request += f"Authorization: Bearer {token}\r\n"
                request += f"Content-Type: multipart/form-data; boundary={boundary}\r\n"
                request += f"Content-Length: {len(body_bytes)}\r\n"
                request += "Connection: close\r\n\r\n"

                # Send headers first
                s.write(request.encode())

                # Send body in chunks to avoid memory issues
                chunk_size = 1024
                for i in range(0, len(body_bytes), chunk_size):
                    chunk = body_bytes[i:i+chunk_size]
                    s.write(chunk)
                    time.sleep(0.01)  # Small delay to prevent overwhelming

                # Read response
                response = s.read(1024)
                s.close()

                if response:
                    response_str = response.decode('utf-8', errors='ignore')
                    print("Image upload response:", response_str[:200])

                    if "200 OK" in response_str or "201" in response_str:
                        print("Image uploaded successfully")
                        return True
                    else:
                        print("Image upload failed")
                        return False
                else:
                    print("No response from image upload")
                    return False

            except Exception as e:
                print("Error uploading image via WiFi:", str(e))
                return False

        def _upload_image_sim(self, image_data, server_url, token):
            """Upload image via SIM (simplified version due to SIM limitations)"""
            try:
                # For SIM upload, we might need to encode image as base64 due to binary data limitations
                import ubinascii

                # Convert image to base64
                image_b64 = ubinascii.b2a_base64(image_data).decode('utf-8')

                # Create JSON payload with base64 image
                json_data = ujson.dumps({
                    'image': image_b64,
                    'timestamp': time.time(),
                    'device_id': ubinascii.hexlify(machine.unique_id()).decode()
                })

                # Prepare headers
                headers = [
                    f"Authorization: Bearer {token}",
                    "Content-Type: application/json",
                    f"Content-Length: {len(json_data)}",
                    "Connection: close"
                ]

                # Send request via SIM
                response = self.send_http_request_sim('POST', server_url, headers, json_data)

                if response and ("200 OK" in response or "201" in response):
                    print("Image uploaded successfully via SIM")
                    return True
                else:
                    print("Image upload failed via SIM")
                    return False

            except Exception as e:
                print("Error uploading image via SIM:", str(e))
                return False

        def monitor_reset_button(self):
            """Monitor reset button for configuration reset"""
            try:
                if reset_pin.value() == 0:  # Button pressed (active low)
                    print("Reset button pressed!")
                    time.sleep(0.1)  # Debounce

                    if reset_pin.value() == 0:  # Still pressed
                        print("Clearing configuration and resetting...")
                        self.clear_config_and_reset()

            except Exception as e:
                print("Error monitoring reset button:", str(e))

        def run_main_loop(self):
            """Main operational loop"""
            try:
                print("=== Starting main operational loop ===")

                while True:
                    # Monitor reset button
                    self.monitor_reset_button()

                    # Capture and upload image
                    print("Capturing image...")
                    image_data = self.capture_image()

                    if image_data:
                        print("Uploading image...")
                        self.upload_image(image_data, self.server_url, self.token)

                    # Handle temperature if thermometer is enabled
                    if self.has_thermometer:
                        print("Reading temperature...")
                        temperature = self.get_temperature()
                        print(f"Current temperature: {temperature}°C")

                        # Upload temperature in separate thread to avoid blocking
                        try:
                            _thread.start_new_thread(self._upload_temperature_thread,
                                                   (temperature, self.server_url, self.token))
                        except Exception as e:
                            print("Error starting temperature upload thread:", str(e))

                    # Cleanup and wait
                    gc.collect()
                    print(f"Free memory: {gc.mem_free()} bytes")
                    print("Waiting 10 seconds before next cycle...")
                    time.sleep(10)

            except Exception as e:
                print("Error in main loop:", str(e))
                time.sleep(5)
                self.run_main_loop()  # Restart main loop

        def run(self):
            """Main entry point"""
            print("=== ESP32-CAM IoT System Starting ===")

            # Load saved configuration
            ssid, password, token = self.load_wifi_config()

            if ssid and password and token:
                print("Configuration found, attempting connection...")

                # Validate token before proceeding
                if not self.validate_token(token):
                    print("Invalid token found, clearing configuration...")
                    self.clear_config_and_reset()
                    return

                # Try to establish internet connection
                if self.establish_internet_connection(ssid, password):
                    print("Internet connection established!")

                    # Decode token and extract server information
                    json_data = self.decode_token(token)
                    if json_data:
                        self.server_url = self.extract_server_url(json_data)
                        self.token = token
                        self.has_thermometer = self.check_thermometer_attribute(json_data)

                        if self.server_url:
                            # Initialize camera
                            if self.init_camera():
                                print("System ready! Starting main loop...")
                                self.run_main_loop()
                            else:
                                print("Camera initialization failed!")
                        else:
                            print("Server URL not found in token")
                            self.clear_config_and_reset()
                    else:
                        print("Token decoding failed")
                        self.clear_config_and_reset()
                else:
                    print("Failed to establish internet connection")
                    print("Please check your WiFi credentials and SIM card")
                    # Don't reset immediately, give user time to see the error
                    time.sleep(10)
                    self.clear_config_and_reset()
            else:
                print("No configuration found, starting setup mode...")
                # Create hotspot and web server for configuration
                ip = self.create_hotspot()
                self.setup_web_server(ip)

    # Main execution
    if __name__ == "__main__":
        try:
            esp32_cam = ESP32_CAM_IoT()
            esp32_cam.run()
        except Exception as e:
            print("Critical error:", str(e))
            time.sleep(5)
            machine.reset()