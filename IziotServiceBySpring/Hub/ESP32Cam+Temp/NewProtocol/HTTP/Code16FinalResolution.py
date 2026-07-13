import network
import socket
import time
import machine
import ujson
import ubinascii
import sys
from machine import Pin, reset
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
led_pin = Pin(4, Pin.OUT)  # LED flash pin
reset_pin = Pin(0, Pin.IN, Pin.PULL_UP)  # Reset button pin

class ESP32_CAM_IoT:
    def __init__(self):
        self.wifi_config_file = 'wifi_config.json'
        self.ap_ssid = 'ESP32-CAM-Setup'
        self.ap_password = '12345678'
        self.server_url = None
        self.token = None
        self.has_thermometer = False  # New attribute to track thermometer capability
        self.camera_resolution = camera.FRAME_VGA # Default camera resolution

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
    </style>
</head>
<body>
    <div class="container">
        <h2>Smart Camera Settings</h2>
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

            # Extract resolution if present
            resolution_str = json_data.get('resolution')
            if resolution_str:
                # Map string resolution to camera.framesize constant
                # Ensure these constants exist in your camera module
                resolution_map = {
                    "240 240": camera.FRAME_240X240,
                    "320 240": camera.FRAME_QVGA,
                    "400 296": camera.FRAME_CIF,
                    "640 480": camera.FRAME_VGA,
                    "800 600": camera.FRAME_SVGA,
                    "1024 768": camera.FRAME_XGA,
                    "1280 1024": camera.FRAME_SXGA,
                    "1600 1200": camera.FRAME_UXGA,
                    "1920 1080": camera.FRAME_HD,
                    "2048 1536": camera.FRAME_QXGA,
                    # "2560 1440": camera.FRAME_QSXGA, # This might not exist on all firmwares
                    # "2560 1920": camera.FRAME_UXGA2 # This caused the error
                }
                try:
                    self.camera_resolution = resolution_map.get(resolution_str, camera.FRAME_VGA)
                    # Removed the problematic hasattr check for integer values.
                    # The camera.init() itself will fail if the resolution is truly unsupported.
                except AttributeError:
                    print(f"Warning: Could not resolve resolution {resolution_str} from map. Falling back to VGA.")
                    self.camera_resolution = camera.FRAME_VGA


                print(f"Camera resolution set to: {resolution_str} (internal: {self.camera_resolution})")
            else:
                print("No resolution found in token, using default (VGA).")

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
        print("--- Attempting camera initialization ---")
        try:
            print("  Attempt 1: camera.init(0, format=camera.JPEG, fb_location=camera.PSRAM)")
            camera.init(0, format=camera.JPEG, fb_location=camera.PSRAM)
            camera.quality(10)  # 10-63, lower is higher quality
            camera.framesize(self.camera_resolution) # Use resolution from token

            # Set vertical flip to rotate image 180 degrees
            camera.flip(1)  # Vertical flip
            camera.mirror(1)  # Horizontal flip (combined with vertical flip = 180° rotation)

            print(f"  Camera initialized successfully with resolution {self.camera_resolution}. Returning True from first attempt.")
            return True
        except Exception as e:
            print(f"  Camera initialization failed (first attempt): {type(e).__name__}: {str(e)}. Trying fallback method.")
            # Try fallback method
            try:
                print("  Attempt 2: camera.init(0, format=camera.JPEG) (fallback)")
                camera.init(0, format=camera.JPEG)
                camera.quality(10)
                camera.framesize(self.camera_resolution) # Use resolution from token

                # Set vertical flip to rotate image 180 degrees
                camera.flip(1)  # Vertical flip
                camera.mirror(1)  # Horizontal flip (combined with vertical flip = 180° rotation)

                print(f"  Camera initialized successfully (fallback method) with resolution {self.camera_resolution}. Returning True from fallback.")
                return True
            except Exception as e2:
                print(f"  Camera fallback initialization also failed: {type(e2).__name__}: {str(e2)}. Returning False.")
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
        # Default temperature if sensor is not found or fails
        default_temp = 25.0
        try:
            import onewire
            import ds18x20
            from machine import Pin

            # Setup OneWire bus on the chosen pin.
            # IMPORTANT: You must physically connect your DS18B20 data line to this pin.
            # GPIO2 is often used by the camera. GPIO12/13/14/15 are better candidates.
            # (Note: This function is only called if 'Thermometer' is in the token attributes)
            ds_pin = Pin(13) # Using GPIO13 based on previous attempt.

            ds_sensor = ds18x20.DS18X20(onewire.OneWire(ds_pin))

            # Scan for devices
            roms = ds_sensor.scan()
            print("Found DS18B20 devices:", len(roms))

            if len(roms) == 0:
                print("No DS18B20 sensors found on the specified pin. Returning default temperature.")
                return default_temp

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
                        print("Sensor " + str(i) + " returned None.")
                except Exception as e:
                    print("Error reading sensor " + str(i) + ": " + str(e))

            if temperatures:
                # Return average temperature if multiple sensors, or single temperature
                avg_temp = sum(temperatures) / len(temperatures)
                print("Average temperature: " + str(round(avg_temp, 2)) + "°C")
                return round(avg_temp, 2)
            else:
                print("No valid temperature readings from any DS18B20 sensors. Returning default temperature.")
                return default_temp

        except ImportError:
            print("DS18B20 libraries (onewire, ds18x20) not available. Returning default temperature.")
            # Fallback to random temperature for testing if libraries are not present
            import random
            temp = 20 + random.randint(0, 20)
            print("Random temperature used:", temp)
            return temp
        except Exception as e:
            # Catch any other exception during temperature reading (e.g., GPIO conflict, sensor failure)
            print(f"Error initializing or reading DS18B20 sensor: {e}. Returning default temperature.")
            return default_temp


    def _upload_temperature_thread(self, temperature, server_url, token):
        if ussl is None:
            print("SSL/TLS module (ussl) not available. Cannot upload securely.")
            return False

        # Explicitly run garbage collection before starting memory-intensive operations
        gc.collect()
        print(f"Free memory before temp upload: {gc.mem_free()} bytes")

        try:
            # Parse server URL and determine if it's HTTPS
            is_https = server_url.startswith("https://")
            host_with_path = server_url.replace("https://", "").replace("http://", "")

            # Split host and path
            if '/' in host_with_path:
                host_part = host_with_path.split('/')[0]
                path = '/' + '/'.join(host_with_path.split('/')[1:])
            else:
                host_part = host_with_path
                path = "/"

            # Determine port from host_part if exists, otherwise use default
            if ':' in host_part:
                host, port_str = host_part.split(':')
                port = int(port_str)
            else:
                host = host_part
                port = 443 if is_https else 80

            print(f"Uploading temperature to: {'https' if is_https else 'http'}://{host}:{port}/NProtocol/api/Temp") # Fixed path here

            # Create POST data
            post_data = "temp=" + str(temperature)

            # Build HTTP headers (use f-strings for efficiency, or pre-calculate lengths)
            headers = f"POST /NProtocol/api/Temp HTTP/1.1\r\nHost: {host}\r\nHubFlag: {token}\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: {len(post_data)}\r\n\r\n"

            # Connect to server
            addr_info = socket.getaddrinfo(host, port)
            addr = addr_info[0][-1]
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM) # Specify AF_INET, SOCK_STREAM explicitly
            s.settimeout(10)

            try:
                s.connect(addr)
                if is_https:
                    print("Wrapping socket with SSL...")
                    # Removed server_hostname for compatibility with older ussl builds
                    s = ussl.wrap_socket(s)
                    print("SSL handshake complete.")

                # Send headers and data using .write()
                s.write(headers.encode())
                s.write(post_data.encode())

                # Read response using .read()
                response = s.read(1024) # Read as bytes first
                if response:
                    response_str = response.decode(errors='ignore') # Decode, ignoring errors
                    print("Temperature upload response: ", response_str)
                    s.close()
                    # Check response
                    if "200 OK" in response_str or "204 No Content" in response_str: # Also check for 204 No Content
                        print("Temperature uploaded successfully")
                        return True
                    else:
                        print("Temperature upload failed - Response: " + response_str[:100])
                        return False
                else:
                    print("No response from temperature upload server.")
                    s.close()
                    return False

            except Exception as e:
                print("Socket error during temperature upload: " + str(e))
                s.close()
                return False

        except Exception as e:
            print("Error uploading temperature: " + str(e))
            return False
        finally:
            # Always run garbage collection after a significant operation
            gc.collect()
            print(f"Free memory after temp upload: {gc.mem_free()} bytes")


    def _upload_image_thread(self, image_data, server_url, token):
        if ussl is None:
            print("SSL/TLS module (ussl) not available. Cannot upload securely.")
            return False

        # Explicitly run garbage collection before starting memory-intensive operations
        gc.collect()
        print(f"Free memory before image upload: {gc.mem_free()} bytes")

        try:
            # Parse server URL and determine if it's HTTPS
            is_https = server_url.startswith("https://")
            host_with_path = server_url.replace("https://", "").replace("http://", "")

            # Split host and path
            if '/' in host_with_path:
                host_part = host_with_path.split('/')[0]
                path = '/' + '/'.join(host_with_path.split('/')[1:])
            else:
                host_part = host_with_path
                path = "/"

            # Determine port from host_part if exists, otherwise use default
            if ':' in host_part:
                host, port_str = host_part.split(':')
                port = int(port_str)
            else:
                host = host_part
                port = 443 if is_https else 80

            print(f"Uploading image to: {'https' if is_https else 'http'}://{host}:{port}/NProtocol/api/UploadImage") # Fixed path here

            # Create HTTP POST request
            boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"

            # Build HTTP headers (use f-strings for efficiency, or pre-calculate lengths)
            headers_part1 = f"POST /NProtocol/api/UploadImage HTTP/1.1\r\nHost: {host}\r\nHubFlag: {token}\r\nContent-Type: multipart/form-data; boundary={boundary}\r\n"

            body_start_part = f"--{boundary}\r\nContent-Disposition: form-data; name=\"snapshot\"; filename=\"image.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n"

            body_end_part = f"\r\n--{boundary}--\r\n"

            # Calculate content length
            content_length = len(body_start_part.encode()) + len(image_data) + len(body_end_part.encode())
            headers_part2 = f"Content-Length: {content_length}\r\n\r\n"

            # Connect to server
            addr_info = socket.getaddrinfo(host, port)
            addr = addr_info[0][-1]
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM) # Specify AF_INET, SOCK_STREAM explicitly
            s.settimeout(30) # Increased timeout for image upload

            try:
                s.connect(addr)
                if is_https:
                    print("Wrapping socket with SSL...")
                    # Removed server_hostname for compatibility with older ussl builds
                    s = ussl.wrap_socket(s)
                    print("SSL handshake complete.")

                # Send headers and body in parts to manage memory
                s.write(headers_part1.encode())
                s.write(headers_part2.encode())
                s.write(body_start_part.encode())

                # Send image data in chunks using .write()
                chunk_size = 1024 # Keep chunk size reasonable
                for i in range(0, len(image_data), chunk_size):
                    chunk = image_data[i:i+chunk_size]
                    s.write(chunk) # Use write for SSL sockets

                # Send body end using .write()
                s.write(body_end_part.encode())

                # Read response using .read()
                response = b''
                while True:
                    data = s.read(1024) # Changed .recv() to .read()
                    if data:
                        response += data
                    else:
                        break

                response_str = response.decode(errors='ignore') # Decode, ignoring errors
                print("Image upload response: ", response_str)
                s.close()

                # Check response
                if "200 OK" in response_str or "204 No Content" in response_str: # Also check for 204 No Content
                    print("Image uploaded successfully")
                    return True
                else:
                    print("Upload failed - Response: " + response_str[:100])
                    return False

            except Exception as e:
                print("Socket error during image upload: " + str(e))
                s.close()
                return False

        except Exception as e:
            print("Error uploading image: " + str(e))
            return False
        finally:
            # Always run garbage collection after a significant operation
            gc.collect()
            print(f"Free memory after image upload: {gc.mem_free()} bytes")

    def main_loop(self):
        # Step 9: Infinite loop for capturing and uploading images
        while True:
            try:
                print("\n--- Starting new cycle ---")

                # Perform explicit garbage collection at the start of each cycle
                gc.collect()
                print(f"Free memory at start of cycle: {gc.mem_free()} bytes")

                # Check if device has thermometer capability and upload temperature
                if self.has_thermometer:
                    try:
                        print("--- Thermometer detected - Getting temperature ---")
                        temperature = self.get_temperature()
                        # Start temperature upload in a new thread
                        try:
                            # Pass arguments as a tuple (even if single arg, it needs to be a tuple)
                            _thread.start_new_thread(self._upload_temperature_thread, (temperature, self.server_url, self.token))
                            print("Temperature upload thread started.")
                        except Exception as e:
                            print("Failed to start temperature upload thread:", str(e))
                    except Exception as e:
                        print("Error getting temperature or starting its upload:", str(e))
                        # DO NOT clear config and reset here. Just log and continue.
                else:
                    print("Thermometer not specified in token or not found. Skipping temperature reading.")


                # Capture and upload image
                image_data = self.capture_image()
                if image_data:
                    # Start image upload in a new thread
                    try:
                        # Pass arguments as a tuple
                        _thread.start_new_thread(self._upload_image_thread, (image_data, self.server_url, self.token))
                        print("Image upload thread started.")
                    except Exception as e:
                        print("Failed to start image upload thread:", str(e))
                else:
                    print("Skipping image upload due to capture failure.")

                # No sleep here for continuous operation as requested.
                # The _thread.start_new_thread will run uploads concurrently (or yield in MicroPython's cooperative multitasking).
                # The speed of the loop will now be determined by the capture speed and how quickly threads can be managed.

            except Exception as e:
                print("Error in main loop:", str(e))
                # Consider adding a small delay here if continuous errors occurs,
                # to prevent rapid, successive failures that could lock up the device.
                time.sleep(1) # Small delay to prevent busy-looping on errors

# Main execution
if __name__ == '__main__':
    esp32_cam = ESP32_CAM_IoT()

    # Configure reset button for clearing Wi-Fi config
    # reset_pin.irq(trigger=Pin.IRQ_FALLING, handler=lambda p: esp32_cam.clear_config_and_reset())

    # Load WiFi config
    ssid, password, token = esp32_cam.load_wifi_config()

    if ssid and password and token and esp32_cam.validate_token(token):
        # Configuration found and valid, connect to WiFi
        esp32_cam.token = token # Store token
        decoded_token_data = esp32_cam.decode_token(token)
        if decoded_token_data:
            esp32_cam.server_url = esp32_cam.extract_server_url(decoded_token_data)
            esp32_cam.has_thermometer = esp32_cam.check_thermometer_attribute(decoded_token_data)
            if esp32_cam.server_url and esp32_cam.connect_wifi(ssid, password):
                # Init camera after WiFi is connected and token parsed for resolution
                print("\n--- Main script calling init_camera() ---")
                camera_init_status = esp32_cam.init_camera() # Capture the explicit return value
                print(f"--- init_camera() call result: {camera_init_status} ---") # Print the result explicitly
                if camera_init_status:
                    esp32_cam.main_loop()
                else:
                    print("Final decision: Camera initialization failed. Restarting to setup mode.")
                    esp32_cam.clear_config_and_reset() # Go back to setup if camera fails
            else:
                print("Failed to connect to WiFi or extract server URL. Restarting to hotspot mode.")
                esp32_cam.clear_config_and_reset() # Go back to setup if WiFi fails
        else:
            print("Failed to decode token. Restarting to hotspot mode.")
            esp32_cam.clear_config_and_reset()
    else:
        # No valid config found, create hotspot for setup
        print("No valid WiFi configuration found. Creating hotspot...")
        ap_ip = esp32_cam.create_hotspot()
        esp32_cam.setup_web_server(ap_ip)