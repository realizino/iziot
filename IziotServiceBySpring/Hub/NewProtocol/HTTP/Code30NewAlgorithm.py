import network
import socket
import time
import machine
import ujson
import ubinascii
import sys
import uos # Import uos for file operations
from machine import Pin, reset
# gc is intentionally not imported as per user request to avoid explicit calls

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

# ESP32-CAM pins configuration (Standard AI-Thinker board)
led_pin = Pin(4, Pin.OUT)  # LED flash pin
reset_pin = Pin(0, Pin.IN, Pin.PULL_UP)  # Reset button pin

# --- Global Queue for Photos to Upload ---
photo_upload_queue = []
PHOTO_DIR = "captured_photos" # Directory to save photos on the device

# Ensure the photo directory exists on the filesystem
try:
    uos.mkdir(PHOTO_DIR)
    print(f"Created directory: {PHOTO_DIR}")
except OSError as e:
    if e.args[0] == 17: # EEXIST error means directory already exists
        print(f"Directory {PHOTO_DIR} already exists.")
    else:
        print(f"Error creating directory {PHOTO_DIR}: {e}")

# --- Threading Lock for Queue Access ---
# Use a lock if _thread module is available, otherwise operate without it.
queue_lock = None
try:
    import _thread
    queue_lock = _thread.allocate_lock()
    print("_thread module loaded, queue lock enabled.")
except ImportError:
    print("Warning: _thread module not found. Cannot use locks for queue management (might be okay if not truly multithreaded).")


class ESP32_CAM_IoT:
    def __init__(self):
        self.wifi_config_file = 'wifi_config.json'
        self.ap_ssid = 'iziotHub'
        self.ap_password = '12345678'
        self.resolution = '640x480'  # Default resolution (can be overridden by token)
        self.server_url = None
        self.token = None
        self.has_thermometer = False  # Flag to enable/disable thermometer readings
        self.has_rotate = False       # Flag to enable/disable image rotation
        self.camera_initialized = False # Tracks camera initialization state

        # List of all standard ESP32-CAM resolutions to cycle through
        self.all_resolutions = [
            "96x96", "160x120", "176x144", "240x176", "320x240", "400x296",
            "640x480", "800x600", "1024x768", "1280x1024", "1600x1200"
        ]

    def load_wifi_config(self):
        """Loads WiFi SSID, password, and server token from a configuration file."""
        try:
            with open(self.wifi_config_file, 'r') as f:
                content = f.read()
                print("Raw config file content length:", len(content))
                config = ujson.loads(content)
                ssid = config.get('ssid')
                password = config.get('password')
                token = config.get('token')
                print("Token found, length:", len(token) if token else 0)
                return ssid, password, token
        except Exception as e:
            print(f"Error loading config file: {e}")
            return None, None, None

    def validate_token(self, token):
        """Validates the structure and content of the base64-encoded server token."""
        try:
            if not token or len(token) < 10:
                print("Token too short or empty.")
                return False
            decoded = ubinascii.a2b_base64(token).decode('utf-8')
            json_data = ujson.loads(decoded)
            if 'url' not in json_data:
                print("Token missing required 'url' field.")
                return False
            print("Token validation successful.")
            return True
        except Exception as e:
            print(f"Token validation failed: {e}")
            return False

    def save_wifi_config(self, ssid, password, token):
        """Saves WiFi credentials and token to a configuration file."""
        try:
            print(f"Saving config - Token length: {len(token)}")
            config = {'ssid': ssid, 'password': password, 'token': token}
            json_str = ujson.dumps(config)
            print(f"Config JSON length: {len(json_str)}")
            try:
                uos.remove(self.wifi_config_file) # Remove old file first
            except OSError:
                pass # File might not exist yet

            # Write in chunks to prevent memory issues with very large tokens
            with open(self.wifi_config_file, 'w') as f:
                chunk_size = 512
                for i in range(0, len(json_str), chunk_size):
                    chunk = json_str[i:i+chunk_size]
                    f.write(chunk)
                f.flush() # Ensure all data is written to disk

            print("Config file written successfully.")
            time.sleep(0.1) # Small delay for file system
            # Verify save by reading back
            with open(self.wifi_config_file, 'r') as f:
                saved_content = f.read()
            print(f"Verification - Saved content length: {len(saved_content)}")
            try:
                saved_config = ujson.loads(saved_content)
                saved_token = saved_config.get('token', '')
                if len(saved_token) == len(token) and saved_token == token:
                    print("WiFi credentials saved and verified successfully.")
                    return True
                else:
                    print(f"Token verification failed - lengths: {len(saved_token)} vs {len(token)}")
                    return False
            except Exception as e:
                print(f"JSON parse error during verification: {e}")
                return False
        except Exception as e:
            print(f"Error saving config: {e}")
            return False

    def clear_config_and_reset(self):
        """Clears the configuration file and resets the device to hotspot mode."""
        try:
            uos.remove(self.wifi_config_file)
            print("Config file cleared.")
        except OSError:
            print("Config file not found or already cleared.")
        print("Resetting to hotspot mode...")
        time.sleep(2)
        machine.reset()

    def create_hotspot(self):
        """Creates a WiFi access point (hotspot) for initial device configuration."""
        ap = network.WLAN(network.AP_IF)
        ap.active(True)
        ap.config(essid=self.ap_ssid, password=self.ap_password)
        print(f"Hotspot created: {self.ap_ssid}")
        print(f"Hotspot IP: {ap.ifconfig()[0]}")
        return ap.ifconfig()[0]

    def setup_web_server(self, ip):
        """Sets up a basic web server to allow users to configure WiFi and server token."""
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
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1) # Allow address reuse
        s.bind(('', 80))
        s.listen(5)
        print("Web server started on port 80.")

        while True:
            conn, addr = s.accept()
            print(f"Connection from: {addr}")

            try:
                request_data = b''
                conn.settimeout(5) # Set a timeout for receiving data

                while True:
                    try:
                        chunk = conn.recv(1024)
                        if not chunk:
                            break
                        request_data += chunk
                        if b'\r\n\r\n' in request_data: # End of headers
                            parts = request_data.split(b'\r\n\r\n', 1)
                            headers = parts[0]
                            if b'POST' in headers:
                                body_part = parts[1] if len(parts) > 1 else b''
                                content_length = 0
                                for line in headers.split(b'\r\n'):
                                    if line.lower().startswith(b'content-length:'):
                                        content_length = int(line.split(b':')[1].strip())
                                        break
                                # Read remaining body data if content_length is known
                                while len(body_part) < content_length:
                                    more_data = conn.recv(min(1024, content_length - len(body_part)))
                                    if not more_data:
                                        break
                                    body_part += more_data
                                request_data = headers + b'\r\n\r\n' + body_part # Reconstruct full request
                                break # Body is complete
                            else: # For GET requests, headers are enough
                                break
                    except Exception as recv_e:
                        print(f"Error during socket recv: {recv_e}")
                        break

                try:
                    request = request_data.decode('utf-8')
                except UnicodeError:
                    # Fallback for non-UTF-8 characters in request
                    request = ''.join(chr(byte) for byte in request_data if byte < 128)

                if 'POST /setup' in request:
                    try:
                        body = request.split('\r\n\r\n')[1]
                    except IndexError:
                        print("Error: Could not extract request body for POST.")
                        continue

                    params = {}
                    # Manual parsing of URL-encoded form data (robust for large tokens)
                    pairs = body.split('&')
                    for pair in pairs:
                        if '=' in pair:
                            key, value = pair.split('=', 1)
                            params[self.url_decode(key)] = self.url_decode(value)

                    ssid = params.get('ssid', '').strip()
                    password = params.get('password', '').strip()
                    token = params.get('token', '').strip()

                    print(f"Received - SSID: {ssid}")
                    print(f"Received - Password length: {len(password)}")
                    print(f"Received - Token length: {len(token)}")

                    if ssid and password and token:
                        if self.save_wifi_config(ssid, password, token):
                            response = """HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\n\r\n
<html><body style="font-family:Arial;text-align:center;padding:50px;">
<h2>Settings saved successfully!</h2>
<p>Device is restarting...</p>
</body></html>"""
                            conn.send(response.encode())
                            conn.close()
                            s.close() # Close server socket before reset
                            print("Restarting device to apply settings...")
                            time.sleep(2)
                            machine.reset() # Reset the device
                        else:
                            response = """HTTP/1.1 400 Bad Request\r\nContent-Type: text/html; charset=utf-8\r\n\r\n
<html><body style="font-family:Arial;text-align:center;padding:50px;">
<h2>Error: Invalid token or failed to save!</h2>
<p><a href="/">Try Again</a></p>
</body></html>"""
                            conn.send(response.encode())
                    else:
                        response = """HTTP/1.1 400 Bad Request\r\nContent-Type: text/html; charset=utf-8\r\n\r\n
<html><body style="font-family:Arial;text-align:center;padding:50px;">
<h2>Error: Missing SSID, Password, or Token!</h2>
<p><a href="/">Try Again</a></p>
</body></html>"""
                        conn.send(response.encode())

                else: # Handle GET requests to display the setup form
                    response = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\n\r\n" + html
                    conn.send(response.encode())

            except Exception as e:
                print(f"Error handling HTTP request: {e}")
            finally:
                conn.close() # Always close the client connection

    def url_decode(self, s):
        """Simple URL decoding for basic characters used in form data."""
        s = s.replace('+', ' ')
        parts = s.split('%')
        decoded_s = parts[0]
        for part in parts[1:]:
            if len(part) >= 2:
                try:
                    hex_val = int(part[0:2], 16)
                    decoded_s += chr(hex_val) + part[2:]
                except ValueError:
                    decoded_s += '%' + part # Keep if not a valid hex escape
            else:
                decoded_s += '%' + part
        return decoded_s

    def connect_wifi(self, ssid, password):
        """Connects the ESP32 to the specified WiFi network."""
        wlan = network.WLAN(network.STA_IF)
        wlan.active(True)
        wlan.connect(ssid, password)

        print(f"Connecting to {ssid}...")
        timeout = 0
        while not wlan.isconnected() and timeout < 30: # 30-second timeout
            print(".", end="")
            time.sleep(1)
            timeout += 1

        if wlan.isconnected():
            print(f"\nConnected successfully! IP: {wlan.ifconfig()[0]}")
            return True
        else:
            print("\nFailed to connect to WiFi.")
            return False

    def decode_token(self, token):
        """Decodes the base64 token and parses it as JSON."""
        try:
            decoded = ubinascii.a2b_base64(token).decode('utf-8')
            json_data = ujson.loads(decoded)
            print(f"Token decoded successfully: {json_data}")
            return json_data
        except Exception as e:
            print(f"Error decoding token: {e}")
            self.clear_config_and_reset() # Reset if token is invalid
            return None

    def extract_server_url(self, json_data):
        """Extracts the server URL from the decoded token data."""
        try:
            server_url = json_data.get('url', '')
            if server_url:
                print(f"Server URL extracted: {server_url}")
                return server_url
            else:
                print("URL field not found in token.")
                return None
        except Exception as e:
            print(f"Error extracting server URL: {e}")
            return None

    def extract_resolution(self, json_data):
        """Extracts the default camera resolution from the token data."""
        try:
            resolution = json_data.get('resolution', '640x480')
            print(f"Default resolution from token: {resolution}")
            return resolution
        except:
            return '640x480' # Default fallback if token doesn't specify

    def check_thermometer_attribute(self, json_data):
        """Checks if the 'Thermometer' attribute is present in the token."""
        try:
            attributes = json_data.get('attribute', '')
            has_thermometer = False
            if isinstance(attributes, list):
                has_thermometer = 'Thermometer' in attributes
            elif isinstance(attributes, str):
                has_thermometer = 'Thermometer' in attributes

            print(f"Thermometer attribute check: {has_thermometer}")
            return has_thermometer
        except Exception as e:
            print(f"Error checking thermometer attribute: {e}")
            return False

    def check_rotate_attribute(self, json_data):
        """Checks if the 'Rotate' attribute is present in the token."""
        try:
            attributes = json_data.get('attribute', '')
            has_rotate = False
            if isinstance(attributes, list):
                has_rotate = 'Rotate' in attributes
            elif isinstance(attributes, str):
                has_rotate = 'Rotate' in attributes

            print(f"Rotate attribute check: {has_rotate}")
            return has_rotate
        except Exception as e:
            print(f"Error checking Rotate attribute: {e}")
            return False

    def init_camera(self, resolution=None):
        """
        Initializes or re-initializes the camera with a specified resolution.
        Attempts to use PSRAM for frame buffer.
        """
        try:
            if self.camera_initialized:
                camera.deinit() # Deinitialize if already active to change settings
                self.camera_initialized = False

            # Initialize camera with PSRAM for higher resolutions
            camera.init(0, format=camera.JPEG, fb_location=camera.PSRAM)
            camera.quality(10) # Good balance between quality and file size

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

            current_resolution = resolution if resolution else self.resolution
            frame_size = resolution_map.get(current_resolution, camera.FRAME_VGA)
            camera.framesize(frame_size)

            if self.has_rotate:
                camera.flip(1) # Flip vertically
                camera.mirror(1) # Mirror horizontally

            print(f"Camera initialized - Resolution: {current_resolution}")
            self.camera_initialized = True
            return True

        except Exception as e:
            print(f"Camera initialization failed for {current_resolution}: {e}")
            # Fallback attempt without PSRAM (might work for lower resolutions or boards without PSRAM)
            try:
                if self.camera_initialized:
                    camera.deinit()
                    self.camera_initialized = False
                camera.init(0, format=camera.JPEG) # Try without fb_location=camera.PSRAM
                camera.quality(10)
                camera.framesize(camera.FRAME_VGA) # Default to VGA for fallback
                if self.has_rotate:
                    camera.flip(1)
                    camera.mirror(1)
                print("Camera initialized (fallback to VGA without PSRAM)!")
                self.camera_initialized = True
                return True
            except Exception as e2:
                print(f"Camera fallback also failed: {e2}")
                self.camera_initialized = False
                return False

    def capture_image(self, filename_prefix="image"):
        """
        Captures an image and saves it to a file.
        Returns the filename on success, None on failure.
        The large image buffer is explicitly dereferenced after saving.
        """
        buf = None # Initialize buffer to None
        try:
            led_pin.on()  # Turn on flash LED
            time.sleep(0.1) # Short delay for flash to activate (as requested)
            buf = camera.capture() # Capture image data
            led_pin.off()  # Turn off flash LED

            if buf:
                # Create a unique filename using timestamp and resolution
                timestamp = int(time.time())
                # Replace 'x' in resolution (e.g., "640x480" -> "640480") for cleaner filename
                filename = f"{PHOTO_DIR}/{filename_prefix}_{timestamp}_{self.resolution.replace('x', '')}.jpg"

                with open(filename, 'wb') as f:
                    f.write(buf)
                print(f"Image captured and saved: {filename} - Size: {len(buf)} bytes")
                return filename
            else:
                print("Failed to capture image: Buffer is empty.")
                return None
        except Exception as e:
            print(f"Error capturing or saving image: {e}")
            led_pin.off() # Ensure LED is off even on error
            return None
        finally:
            # Explicitly clear the reference to the large buffer.
            # This makes the memory eligible for automatic garbage collection.
            buf = None

    def get_temperature(self):
        """Reads temperature from a DS18B20 sensor connected to Pin 2."""
        try:
            import onewire
            import ds18x20
            ds_pin = Pin(2)
            ds_sensor = ds18x20.DS18X20(onewire.OneWire(ds_pin))

            roms = ds_sensor.scan()
            print(f"Found DS18B20 devices: {len(roms)}")

            if len(roms) == 0:
                print("No DS18B20 sensors found.")
                return 25.0 # Default temperature if no sensor

            ds_sensor.convert_temp() # Start temperature conversion
            time.sleep_ms(750) # Wait for conversion to complete (750ms for 12-bit)

            temperatures = []
            for i, rom in enumerate(roms):
                try:
                    temp = ds_sensor.read_temp(rom)
                    if temp is not None:
                        temperatures.append(round(temp, 2))
                        print(f"Sensor {i} temperature: {temp}°C")
                    else:
                        print(f"Sensor {i} returned None.")
                except Exception as e:
                    print(f"Error reading sensor {i}: {e}")

            if temperatures:
                avg_temp = sum(temperatures) / len(temperatures)
                print(f"Average temperature: {round(avg_temp, 2)}°C")
                return round(avg_temp, 2)
            else:
                print("No valid temperature readings from sensors.")
                return 25.0 # Default if no valid readings

        except ImportError:
            print("DS18B20 libraries (onewire, ds18x20) not available. Using random temperature.")
            import random
            return round(20 + (random.random() * 20), 2) # Random temp for testing
        except Exception as e:
            print(f"Error getting temperature: {e}")
            return 25.0

    def _upload_temperature_data(self, temperature, server_url, token):
        """Uploads temperature data to the server via HTTP POST."""
        if ussl is None:
            print("SSL/TLS module (ussl) not available. Cannot upload securely.")
            return False

        try:
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

            endpoint = "/NProtocol/api/Temp" # Specific API endpoint for temperature
            print(f"Uploading temperature to: {'https' if is_https else 'http'}://{host}:{port}{endpoint}")

            post_data = f"temp={temperature}"
            headers = (
                f"POST {endpoint} HTTP/1.1\r\n"
                f"Host: {host}\r\n"
                f"HubFlag: {token}\r\n" # Your custom token header
                f"Content-Type: application/x-www-form-urlencoded\r\n"
                f"Content-Length: {len(post_data)}\r\n\r\n"
            )

            addr_info = socket.getaddrinfo(host, port)
            addr = addr_info[0][-1]
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(10) # 10 second timeout for connection and send/recv

            try:
                s.connect(addr)
                if is_https:
                    print("Wrapping socket with SSL...")
                    s = ussl.wrap_socket(s) # No server_hostname for broader compatibility
                    print("SSL handshake complete.")

                s.write(headers.encode())
                s.write(post_data.encode())

                response_bytes = b''
                while True:
                    data = s.read(1024) # Read response in chunks
                    if data:
                        response_bytes += data
                    else:
                        break # No more data

                response_str = response_bytes.decode(errors='ignore') # Decode, ignoring errors
                print("Temperature upload response: ", response_str)
                s.close() # Close socket

                if "200 OK" in response_str or "204 No Content" in response_str:
                    print("Temperature uploaded successfully.")
                    return True
                else:
                    print(f"Temperature upload failed - Response status not OK/No Content: {response_str[:100]}")
                    return False

            except Exception as e:
                print(f"Socket error during temperature upload: {e}")
                s.close() # Ensure socket is closed on error
                return False

        except Exception as e:
            print(f"Error preparing temperature upload: {e}")
            return False

    def _upload_image_data(self, image_filepath, server_url, token):
        """
        Uploads an image from a given file path to the server via HTTP POST (multipart/form-data).
        Returns True on success, False on failure.
        """
        if ussl is None:
            print("SSL/TLS module (ussl) not available. Cannot upload securely.")
            return False

        image_data = None # Initialize to None for explicit dereferencing
        try:
            # Read image data from file just before uploading
            try:
                with open(image_filepath, 'rb') as f:
                    image_data = f.read()
                print(f"Read image from {image_filepath}, size: {len(image_data)} bytes.")
            except Exception as e:
                print(f"Error reading image file {image_filepath}: {e}")
                return False

            is_https = server_url.startswith("https://")
            host_with_path = server_url.replace("https://", "").replace("http://", "")

            # Split host and path
            if '/' in host_with_path:
                host_part = host_with_path.split('/')[0]
                path = '/' + '/'.join(host_with_path.split('/')[1:])
            else:
                host_part = host_with_path
                path = "/"

            # Determine port
            if ':' in host_part:
                host, port_str = host_part.split(':')
                port = int(port_str)
            else:
                host = host_part
                port = 443 if is_https else 80

            endpoint = "/NProtocol/api/UploadImage" # Specific API endpoint for image upload
            print(f"Uploading image to: {'https' if is_https else 'http'}://{host}:{port}{endpoint}")

            boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW" # Standard multipart boundary

            # Construct multipart body parts
            body_start_part = (
                f"--{boundary}\r\n"
                f"Content-Disposition: form-data; name=\"snapshot\"; filename=\"{uos.path.basename(image_filepath)}\"\r\n"
                f"Content-Type: image/jpeg\r\n\r\n"
            )
            body_end_part = f"\r\n--{boundary}--\r\n"

            # Calculate total content length for the HTTP header
            content_length = len(body_start_part.encode()) + len(image_data) + len(body_end_part.encode())

            headers = (
                f"POST {endpoint} HTTP/1.1\r\n"
                f"Host: {host}\r\n"
                f"HubFlag: {token}\r\n" # Your custom token header
                f"Content-Type: multipart/form-data; boundary={boundary}\r\n"
                f"Content-Length: {content_length}\r\n\r\n"
            )

            addr_info = socket.getaddrinfo(host, port)
            addr = addr_info[0][-1]
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(30) # Increased timeout for image upload

            try:
                s.connect(addr)
                if is_https:
                    print("Wrapping socket with SSL...")
                    s = ussl.wrap_socket(s)
                    print("SSL handshake complete.")

                # Send headers and body in parts
                s.write(headers.encode())
                s.write(body_start_part.encode())

                # Send image data in chunks to avoid large single allocations
                chunk_size = 1024
                for i in range(0, len(image_data), chunk_size):
                    chunk = image_data[i:i+chunk_size]
                    s.write(chunk)

                s.write(body_end_part.encode())

                response_bytes = b''
                while True:
                    data = s.read(1024) # Read response in chunks
                    if data:
                        response_bytes += data
                    else:
                        break

                response_str = response_bytes.decode(errors='ignore')
                print("Image upload response: ", response_str)
                s.close()

                if "200 OK" in response_str or "204 No Content" in response_str:
                    print(f"Image from {image_filepath} uploaded successfully.")
                    return True
                else:
                    print(f"Image upload failed for {image_filepath} - Response status not OK/No Content: {response_str[:100]}")
                    return False

            except Exception as e:
                print(f"Socket error during image upload from {image_filepath}: {e}")
                s.close()
                return False

        except Exception as e:
            print(f"Error preparing image upload from {image_filepath}: {e}")
            return False
        finally:
            # Explicitly clear the reference to the large image data buffer.
            image_data = None

    def delete_photo_file(self, filepath):
        """Deletes a photo file from the device's storage."""
        try:
            uos.remove(filepath)
            print(f"Deleted photo file: {filepath}")
        except OSError as e:
            print(f"Error deleting file {filepath}: {e}")

    def main_loop(self):
        """
        Main operational loop for capturing, saving, queuing, and uploading photos and temperature.
        """
        # Initial camera setup using the resolution from the token or default
        if not self.init_camera():
            print("Critical: Camera could not be initialized at all. Cannot proceed with photo capture.")
            # Consider a longer sleep or reset if camera fails critically
            time.sleep(10)
            machine.reset()
            return

        last_capture_cycle_time = time.time()
        last_temp_upload_time = time.time()
        temperature_upload_interval = 600 # 10 minutes (adjust as needed)

        while True:
            current_time = time.time()

            # --- Capture and Save Photos at all resolutions ---
            # Trigger a new full photo capture cycle every 0.1 seconds
            if current_time - last_capture_cycle_time >= 0.1:
                print("\n--- Starting a new photo capture cycle ---")
                for res in self.all_resolutions:
                    print(f"Attempting to capture at resolution: {res}")
                    # Re-initialize camera for each resolution
                    if self.init_camera(resolution=res):
                        self.resolution = res # Update current resolution for filename
                        filename = self.capture_image()
                        if filename:
                            # Add the filename to the upload queue
                            if queue_lock:
                                with queue_lock:
                                    photo_upload_queue.append(filename)
                            else: # No lock, just append
                                photo_upload_queue.append(filename)
                            print(f"Added {filename} to upload queue. Current queue size: {len(photo_upload_queue)}")
                        else:
                            print(f"Failed to capture image at {res}.")

                        # As requested, sleep for 0.1 seconds after each capture, regardless of resolution
                        # This applies to the time between captures at different resolutions.
                        time.sleep(0.1)
                    else:
                        print(f"Skipping capture for {res} due to camera initialization failure.")
                last_capture_cycle_time = current_time # Update time after one full resolution cycle

            # --- Process and Upload Photos from Queue ---
            # This runs in the main loop, processing one image at a time from the queue.
            file_to_upload = None
            if queue_lock:
                with queue_lock:
                    if photo_upload_queue:
                        file_to_upload = photo_upload_queue[0] # Get the first item
            else: # No lock available
                if photo_upload_queue:
                    file_to_upload = photo_upload_queue[0]

            if file_to_upload:
                print(f"Processing upload for: {file_to_upload}")
                if self._upload_image_data(file_to_upload, self.server_url, self.token):
                    # Remove from queue and delete file only on successful upload
                    if queue_lock:
                        with queue_lock:
                            photo_upload_queue.pop(0)
                    else:
                        photo_upload_queue.pop(0)
                    self.delete_photo_file(file_to_upload)
                else:
                    print(f"Failed to upload {file_to_upload}. Will retry later.")
                    # For simplicity, if upload fails, it remains at the front of the queue
                    # and will be retried on the next loop iteration.
            else:
                pass # The 'pass' should be correctly indented within the 'else' block if it exists.


            # --- Upload Temperature (if enabled by token) ---
            if self.has_thermometer and (current_time - last_temp_upload_time >= temperature_upload_interval):
                print("\nAttempting to upload temperature...")
                temperature = self.get_temperature()
                if temperature is not None:
                    if self._upload_temperature_data(temperature, self.server_url, self.token):
                        last_temp_upload_time = current_time # Update only on success
                    else:
                        print("Temperature upload failed.")
                else:
                    print("Could not get a valid temperature reading.")

            # General short delay to prevent the loop from consuming all CPU unnecessarily
            # This also allows MicroPython's automatic garbage collection to run periodically.
            time.sleep(1)

# Main execution logic
if __name__ == '__main__':
    iot_device = ESP32_CAM_IoT()

    ssid, password, token = iot_device.load_wifi_config()

    if ssid and password and token and iot_device.validate_token(token):
        iot_device.token = token
        decoded_token_data = iot_device.decode_token(token)
        if decoded_token_data:
            iot_device.server_url = iot_device.extract_server_url(decoded_token_data)
            # The resolution from token will be used as the initial default,
            # but the loop will cycle through all resolutions.
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