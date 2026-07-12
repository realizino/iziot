import network
import socket
import time
import machine
import ujson
import ubinascii
import sys
import uos # Import uos for file operations
from machine import Pin, reset
import gc # Import garbage collector
import _thread # Import the thread module (use with caution for complex tasks)

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

# --- Global Queue for Photos to Upload ---
# We'll use a simple list as a queue. For true concurrent access
# with multiple threads, you'd need a more complex synchronization mechanism
# but for a single uploader thread, a list is sufficient if managed carefully.
photo_upload_queue = []
PHOTO_DIR = "captured_photos" # Directory to save photos

# Ensure the photo directory exists
try:
    uos.mkdir(PHOTO_DIR)
    print(f"Created directory: {PHOTO_DIR}")
except OSError as e:
    if e.args[0] == 17: # EEXIST
        print(f"Directory {PHOTO_DIR} already exists.")
    else:
        print(f"Error creating directory {PHOTO_DIR}: {e}")

# --- Threading Lock for Queue Access (if using separate uploader thread) ---
# A lock is crucial if multiple threads will access photo_upload_queue
queue_lock = _thread.allocate_lock()


class ESP32_CAM_IoT:
    def __init__(self):
        self.wifi_config_file = 'wifi_config.json'
        self.ap_ssid = 'iziotHub'
        self.ap_password = '12345678'
        self.resolution = '640x480'  # Default resolution
        self.server_url = None
        self.token = None
        self.has_thermometer = False
        self.has_rotate = False
        self.camera_initialized = False

        # All available resolutions
        self.all_resolutions = [
            "96x96", "160x120", "176x144", "240x176", "320x240", "400x296",
            "640x480", "800x600", "1024x768", "1280x1024", "1600x1200"
        ]

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
            config = {'ssid': ssid, 'password': password, 'token': token}
            json_str = ujson.dumps(config)
            print("Config JSON length:", len(json_str))
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
            print("File written successfully")
            time.sleep(0.1)
            with open(self.wifi_config_file, 'r') as f:
                saved_content = f.read()
            print("Verification - Saved content length:", len(saved_content))
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
            print("Error saving config:", str(e))
            return False

    def clear_config_and_reset(self):
        try:
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
        try:
            resolution = json_data.get('resolution', '640x480')
            print("Resolution: {}".format(resolution))
            return resolution
        except:
            return '640x440'

    def check_thermometer_attribute(self, json_data):
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

    def init_camera(self, resolution=None):
        """Initializes or re-initializes the camera with a specified resolution."""
        try:
            if self.camera_initialized:
                # Deinit camera if already initialized to change settings
                camera.deinit()
                self.camera_initialized = False # Reset flag

            # Camera initialization
            camera.init(0, format=camera.JPEG, fb_location=camera.PSRAM)
            camera.quality(10)

            resolution_map = {
                "96x96": camera.FRAME_96X96,
                "160x120": camera.FRAME_QQVGA,
                "176x144": camera.FRAME_QCIF,
                "240x176": camera.FRAME_HQVGA,
                "320x240": camera.FRAME_QVGA,
                "400x296": camera.FRAME_CIF,
                "640x480": camera.FRAME_VGA,
                "800x600": camera.FRAME_SVGA,
                "1024x768": camera.FRAME_XGA,
                "1280x1024": camera.FRAME_SXGA,
                "1600x1200": camera.FRAME_UXGA
            }

            if resolution is None:
                current_resolution = self.resolution # Use stored resolution if not specified
            else:
                current_resolution = resolution # Use provided resolution

            frame_size = resolution_map.get(current_resolution, camera.FRAME_VGA)
            camera.framesize(frame_size)

            if self.has_rotate:
              camera.flip(1)
              camera.mirror(1)

            print(f"Camera initialized - Resolution: {current_resolution}")
            self.camera_initialized = True
            return True

        except Exception as e:
            print(f"Camera initialization failed for {resolution if resolution else self.resolution}: {e}")
            # Try fallback to VGA if specific resolution fails
            try:
                if self.camera_initialized:
                    camera.deinit()
                    self.camera_initialized = False
                camera.init(0, format=camera.JPEG)
                camera.quality(10)
                camera.framesize(camera.FRAME_VGA)
                if self.has_rotate:
                    camera.flip(1)
                    camera.mirror(1)
                print("Camera initialized (fallback to VGA)")
                self.camera_initialized = True
                return True
            except Exception as e2:
                print(f"Camera fallback failed: {e2}")
                return False

    def capture_image(self, filename_prefix="image"):
        """Captures an image and saves it to a file. Returns filename on success."""
        try:
            led_pin.on()  # Turn on flash LED
            time.sleep(0.1) # Sleep before capture
            buf = camera.capture()
            led_pin.off()  # Turn off flash LED

            if buf:
                timestamp = int(time.time()) # Use timestamp for unique filename
                filename = f"{PHOTO_DIR}/{filename_prefix}_{timestamp}_{self.resolution}.jpg"
                with open(filename, 'wb') as f:
                    f.write(buf)
                print(f"Image captured and saved: {filename} - Size: {len(buf)} bytes")
                gc.collect() # Aggressive garbage collection after saving a large buffer
                return filename
            else:
                print("Failed to capture image")
                return None
        except Exception as e:
            print("Error capturing or saving image: " + str(e))
            led_pin.off()
            return None

    def get_temperature(self):
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
                return 25.0
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

    def _upload_temperature_thread(self, temperature, server_url, token):
        if ussl is None:
            print("SSL/TLS module (ussl) not available. Cannot upload securely.")
            return False
        try:
            is_https = server_url.startswith("https://")
            host_with_path = server_url.replace("https://", "").replace("http://", "")
            if '/' in host_with_path:
                host_part = host_with_path.split('/')[0]
                path = '/' + '/'.join(host_with_path.split('/')[1:])
            else:
                host_part = host_with_path
                path = "/"
            if ':' in host_part:
                host, port_str = host_part.split(':')
                port = int(port_str)
            else:
                host = host_part
                port = 443 if is_https else 80

            print(f"Uploading temperature to: {'https' if is_https else 'http'}://{host}:{port}/NProtocol/api/Temp")
            post_data = "temp=" + str(temperature)
            headers = f"POST /NProtocol/api/Temp HTTP/1.1\r\nHost: {host}\r\nHubFlag: {token}\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: {len(post_data)}\r\n\r\n"
            addr_info = socket.getaddrinfo(host, port)
            addr = addr_info[0][-1]
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(10)
            try:
                s.connect(addr)
                if is_https:
                    print("Wrapping socket with SSL...")
                    s = ussl.wrap_socket(s)
                    print("SSL handshake complete.")
                s.write(headers.encode())
                s.write(post_data.encode())
                response = s.read(1024)
                if response:
                    response_str = response.decode(errors='ignore')
                    print("Temperature upload response: ", response_str)
                    s.close()
                    if "200 OK" in response_str or "204 No Content" in response_str:
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

    def _upload_image_thread(self, image_filepath, server_url, token):
        """
        Uploads an image from a given file path.
        Returns True on success, False on failure.
        """
        if ussl is None:
            print("SSL/TLS module (ussl) not available. Cannot upload securely.")
            return False

        try:
            # Read image data from file
            try:
                with open(image_filepath, 'rb') as f:
                    image_data = f.read()
                print(f"Read image from {image_filepath}, size: {len(image_data)} bytes")
            except Exception as e:
                print(f"Error reading image file {image_filepath}: {e}")
                return False

            is_https = server_url.startswith("https://")
            host_with_path = server_url.replace("https://", "").replace("http://", "")

            if '/' in host_with_path:
                host_part = host_with_path.split('/')[0]
                path = '/' + '/'.join(host_with_path.split('/')[1:])
            else:
                host_part = host_with_path
                path = "/"

            if ':' in host_part:
                host, port_str = host_part.split(':')
                port = int(port_str)
            else:
                host = host_part
                port = 443 if is_https else 80

            print(f"Uploading image to: {'https' if is_https else 'http'}://{host}:{port}/NProtocol/api/UploadImage")

            boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
            headers_part1 = f"POST /NProtocol/api/UploadImage HTTP/1.1\r\nHost: {host}\r\nHubFlag: {token}\r\nContent-Type: multipart/form-data; boundary={boundary}\r\n"
            body_start_part = f"--{boundary}\r\nContent-Disposition: form-data; name=\"snapshot\"; filename=\"{uos.path.basename(image_filepath)}\"\r\nContent-Type: image/jpeg\r\n\r\n"
            body_end_part = f"\r\n--{boundary}--\r\n"

            content_length = len(body_start_part.encode()) + len(image_data) + len(body_end_part.encode())
            headers_part2 = f"Content-Length: {content_length}\r\n\r\n"

            addr_info = socket.getaddrinfo(host, port)
            addr = addr_info[0][-1]
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(30)

            try:
                s.connect(addr)
                if is_https:
                    print("Wrapping socket with SSL...")
                    s = ussl.wrap_socket(s)
                    print("SSL handshake complete.")

                s.write(headers_part1.encode())
                s.write(headers_part2.encode())
                s.write(body_start_part.encode())

                chunk_size = 1024
                for i in range(0, len(image_data), chunk_size):
                    chunk = image_data[i:i+chunk_size]
                    s.write(chunk)

                s.write(body_end_part.encode())

                response = b''
                while True:
                    data = s.read(1024)
                    if data:
                        response += data
                    else:
                        break

                response_str = response.decode(errors='ignore')
                print("Image upload response: ", response_str)
                s.close()
                gc.collect() # Aggressive garbage collection after upload

                if "200 OK" in response_str or "204 No Content" in response_str:
                    print(f"Image from {image_filepath} uploaded successfully")
                    return True
                else:
                    print(f"Image upload failed for {image_filepath} - Response: {response_str[:100]}")
                    return False

            except Exception as e:
                print(f"Socket error during image upload from {image_filepath}: {e}")
                s.close()
                return False

        except Exception as e:
            print(f"Error preparing image upload from {image_filepath}: {e}")
            return False

    def delete_photo_file(self, filepath):
        """Deletes a photo file from the device."""
        try:
            uos.remove(filepath)
            print(f"Deleted photo file: {filepath}")
        except OSError as e:
            print(f"Error deleting file {filepath}: {e}")

    def main_loop(self):
        # Initial camera setup with default/token resolution
        if not self.init_camera():
            print("Critical: Camera could not be initialized. Exiting main loop.")
            return

        # Start the photo uploader thread
        # This thread will continuously check the queue and upload images
        # _thread.start_new_thread(self.photo_uploader_thread, ()) # Removed for simpler sequential processing

        last_capture_time = time.time()
        last_temp_upload_time = time.time()
        temperature_upload_interval = 600 # 10 minutes (adjust as needed)

        while True:
            # --- Capture and Save Photos (all resolutions) ---
            current_time = time.time()
            if current_time - last_capture_time >= 0.1: # Capture every 0.1 seconds
                # Iterate through all resolutions
                for res in self.all_resolutions:
                    print(f"\nAttempting to capture at resolution: {res}")
                    # Re-initialize camera for each resolution
                    if self.init_camera(resolution=res):
                        self.resolution = res # Update current resolution for filename
                        filename = self.capture_image()
                        if filename:
                            # Add the filename to the upload queue
                            with queue_lock: # Acquire lock before modifying queue
                                photo_upload_queue.append(filename)
                            print(f"Added {filename} to upload queue. Queue size: {len(photo_upload_queue)}")
                        time.sleep(0.1) # Sleep between captures at different resolutions

                    gc.collect() # Aggressive garbage collection after each capture attempt
                    print(f"Free memory after {res} capture: {gc.mem_free()} bytes")

                last_capture_time = current_time # Update last capture time after one full cycle

            # --- Upload Photos from Queue ---
            # Process one image from the queue in the main loop to avoid complex threading issues
            with queue_lock: # Acquire lock before accessing queue
                if photo_upload_queue:
                    file_to_upload = photo_upload_queue[0] # Get the first item
                    print(f"Attempting to upload: {file_to_upload}")
                else:
                    file_to_upload = None

            if file_to_upload:
                if self._upload_image_thread(file_to_upload, self.server_url, self.token):
                    with queue_lock: # Acquire lock before modifying queue
                        photo_upload_queue.pop(0) # Remove from queue only on successful upload
                    self.delete_photo_file(file_to_upload) # Delete file after successful upload
                else:
                    print(f"Failed to upload {file_to_upload}. Keeping in queue for retry.")
                    # Optionally, implement a retry mechanism or move to end of queue
                    # For simplicity, it stays at the front and will be retried on next loop.

            # --- Upload Temperature (if enabled) ---
            if self.has_thermometer and (current_time - last_temp_upload_time >= temperature_upload_interval):
                print("\nAttempting to upload temperature...")
                temperature = self.get_temperature()
                if temperature is not None:
                    if self._upload_temperature_thread(temperature, self.server_url, self.token):
                        last_temp_upload_time = current_time
                    else:
                        print("Temperature upload failed.")
                else:
                    print("Could not get temperature reading.")
                gc.collect()
                print(f"Free memory after temperature upload: {gc.mem_free()} bytes")

            # Small delay to prevent busy-waiting if nothing to do
            # This delay should be adjusted based on desired capture/upload frequency
            time.sleep(1) # Reduced general sleep time as captures are time-based

# Main execution logic
if __name__ == '__main__':
    iot_device = ESP32_CAM_IoT()

    ssid, password, token = iot_device.load_wifi_config()

    if ssid and password and token and iot_device.validate_token(token):
        iot_device.token = token
        decoded_token_data = iot_device.decode_token(token)
        if decoded_token_data:
            iot_device.server_url = iot_device.extract_server_url(decoded_token_data)
            iot_device.resolution = iot_device.extract_resolution(decoded_token_data)
            iot_device.has_thermometer = iot_device.check_thermometer_attribute(decoded_token_data)
            iot_device.has_rotate = iot_device.check_rotate_attribute(decoded_token_data)

            if iot_device.server_url:
                if iot_device.connect_wifi(ssid, password):
                    print("Entering main loop...")
                    iot_device.main_loop()
                else:
                    print("Failed to connect to WiFi, reverting to hotspot setup.")
                    iot_device.clear_config_and_reset()
            else:
                print("Server URL not found in token, reverting to hotspot setup.")
                iot_device.clear_config_and_reset()
        else:
            print("Failed to decode token, reverting to hotspot setup.")
            iot_device.clear_config_and_reset()
    else:
        print("WiFi credentials or valid token not found. Starting hotspot setup.")
        ip_address = iot_device.create_hotspot()
        iot_device.setup_web_server(ip_address)