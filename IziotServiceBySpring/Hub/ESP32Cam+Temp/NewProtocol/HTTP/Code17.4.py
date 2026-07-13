import network
import socket
import time
import machine
import ujson
import ubinascii
import sys
from machine import Pin, reset
import _thread

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

# ESP32-CAM pins configuration
led_pin = Pin(4, Pin.OUT)
reset_pin = Pin(0, Pin.IN, Pin.PULL_UP)

# Thread management - INCREASED for real-time performance
active_threads = 0
max_threads = 5  # Increased from 2 to 5
thread_lock = _thread.allocate_lock()

class ESP32_CAM_IoT:
    def __init__(self):
        self.wifi_config_file = 'wifi_config.json'
        self.ap_ssid = 'ESP32-CAM-Setup'
        self.ap_password = '12345678'
        self.server_url = None
        self.token = None
        self.resolution = '640x480'  # Default resolution
        self.has_thermometer = False
        self.upload_interval = 0.1  # CHANGED: Reduced from 1 to 0.1 seconds
        self.camera_initialized = False
        self.realtime_mode = True  # NEW: Enable real-time mode
        self.skip_failed_uploads = True  # NEW: Don't wait for failed uploads

    def load_wifi_config(self):
        """Load WiFi configuration from file"""
        try:
            with open(self.wifi_config_file, 'r') as f:
                content = f.read()
                if not content.strip():
                    return None, None, None

                config = ujson.loads(content)
                ssid = config.get('ssid')
                password = config.get('password')
                token = config.get('token')

                if not all([ssid, password, token]):
                    return None, None, None

                print("Config loaded - SSID: {}, Token length: {}".format(ssid, len(token)))
                return ssid, password, token

        except (OSError, ValueError) as e:
            print("Error loading config: {}".format(e))
            return None, None, None

    def validate_token(self, token):
        """Validate token format and content"""
        if not token or len(token) < 10:
            print("Token too short")
            return False

        try:
            # Test base64 decoding
            decoded = ubinascii.a2b_base64(token).decode('utf-8')
            json_data = ujson.loads(decoded)

            # Check required fields
            if 'url' not in json_data:
                print("Token missing required URL field")
                return False

            print("Token validation successful")
            return True

        except Exception as e:
            print("Token validation failed: {}".format(e))
            return False

    def save_wifi_config(self, ssid, password, token):
        """Save WiFi configuration to file with error handling"""
        try:
            # Validate inputs
            if not all([ssid, password, token]):
                print("Invalid configuration data")
                return False

            if not self.validate_token(token):
                print("Invalid token format")
                return False

            config = {
                'ssid': ssid,
                'password': password,
                'token': token
            }

            # Remove old file first
            try:
                import uos
                uos.remove(self.wifi_config_file)
            except:
                pass

            # Save configuration
            with open(self.wifi_config_file, 'w') as f:
                ujson.dump(config, f)

            # Verify save
            time.sleep(0.1)
            with open(self.wifi_config_file, 'r') as f:
                saved_config = ujson.load(f)

            if saved_config.get('token') == token:
                print("WiFi configuration saved successfully")
                return True
            else:
                print("Configuration verification failed")
                return False

        except Exception as e:
            print("Error saving config: {}".format(e))
            return False

    def clear_config_and_reset(self):
        """Clear configuration and reset device"""
        try:
            import uos
            uos.remove(self.wifi_config_file)
            print("Configuration cleared")
        except:
            pass

        print("Resetting device...")
        time.sleep(2)
        machine.reset()

    def create_hotspot(self):
        """Create WiFi hotspot for configuration"""
        try:
            ap = network.WLAN(network.AP_IF)
            ap.active(True)
            ap.config(essid=self.ap_ssid, password=self.ap_password)

            # Wait for AP to be ready
            time.sleep(2)

            ip = ap.ifconfig()[0]
            print("Hotspot created: {}".format(self.ap_ssid))
            print("IP: {}".format(ip))
            return ip

        except Exception as e:
            print("Error creating hotspot: {}".format(e))
            return None

    def setup_web_server(self, ip):
        """Setup web server for device configuration"""
        html = """<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>ESP32-CAM Setup</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 500px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h2 { text-align: center; color: #333; margin-bottom: 30px; }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; color: #555; }
        input, textarea { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 5px; box-sizing: border-box; font-size: 14px; }
        textarea { min-height: 120px; font-family: monospace; resize: vertical; }
        button { width: 100%; padding: 15px; background: #4CAF50; color: white; border: none; border-radius: 5px; font-size: 16px; cursor: pointer; }
        button:hover { background: #45a049; }
        .info { font-size: 12px; color: #666; margin-top: 5px; }
        .error { color: #d32f2f; background: #ffebee; padding: 10px; border-radius: 5px; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <h2>ESP32-CAM Configuration</h2>
        <form method="POST" action="/setup">
            <div class="form-group">
                <label for="ssid">WiFi Network Name (SSID):</label>
                <input type="text" id="ssid" name="ssid" required maxlength="32">
            </div>

            <div class="form-group">
                <label for="password">WiFi Password:</label>
                <input type="password" id="password" name="password" required maxlength="64">
            </div>

            <div class="form-group">
                <label for="token">Configuration Token:</label>
                <textarea id="token" name="token" required maxlength="4096" placeholder="Paste your base64 encoded configuration token here..."></textarea>
                <div class="info">Token must be base64 encoded and contain server URL</div>
            </div>

            <button type="submit">Save Configuration</button>
        </form>
    </div>
</body>
</html>"""

        try:
            s = socket.socket()
            s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            s.bind(('', 80))
            s.listen(1)
            print("Web server started on port 80")

            while True:
                try:
                    conn, addr = s.accept()
                    print("Connection from: {}".format(addr))
                    conn.settimeout(10)

                    # Read request
                    request = b''
                    while True:
                        try:
                            chunk = conn.recv(1024)
                            if not chunk:
                                break
                            request += chunk
                            if b'\r\n\r\n' in request:
                                break
                        except:
                            break

                    request_str = request.decode('utf-8', errors='ignore')

                    if 'POST /setup' in request_str:
                        # Parse form data
                        try:
                            body = request_str.split('\r\n\r\n', 1)[1]
                            params = self.parse_form_data(body)

                            ssid = params.get('ssid', '').strip()
                            password = params.get('password', '').strip()
                            token = params.get('token', '').strip()

                            if ssid and password and token:
                                if self.save_wifi_config(ssid, password, token):
                                    response = self.create_response(200, """
                                    <html><body style="font-family:Arial;text-align:center;padding:50px;">
                                    <h2>Configuration saved successfully!</h2>
                                    <p>Device is restarting...</p>
                                    </body></html>
                                    """)
                                    conn.send(response)
                                    conn.close()
                                    s.close()
                                    time.sleep(2)
                                    machine.reset()
                                else:
                                    response = self.create_response(400, """
                                    <html><body style="font-family:Arial;text-align:center;padding:50px;">
                                    <h2>Configuration Error</h2>
                                    <p>Invalid token format. Please check your token.</p>
                                    <p><a href="/">Try Again</a></p>
                                    </body></html>
                                    """)
                                    conn.send(response)
                            else:
                                response = self.create_response(400, "Missing required fields")
                                conn.send(response)
                        except Exception as e:
                            print("Form parsing error: {}".format(e))
                            response = self.create_response(400, "Invalid form data")
                            conn.send(response)
                    else:
                        # Serve configuration page
                        response = self.create_response(200, html)
                        conn.send(response)

                except Exception as e:
                    print("Request handling error: {}".format(e))
                finally:
                    try:
                        conn.close()
                    except:
                        pass

        except Exception as e:
            print("Web server error: {}".format(e))
        finally:
            try:
                s.close()
            except:
                pass

    def create_response(self, status_code, content):
        """Create HTTP response"""
        status_text = "OK" if status_code == 200 else "Bad Request"
        response = "HTTP/1.1 {} {}\r\n".format(status_code, status_text)
        response += "Content-Type: text/html; charset=utf-8\r\n"
        response += "Content-Length: {}\r\n".format(len(content))
        response += "Connection: close\r\n\r\n"
        response += content
        return response.encode()

    def parse_form_data(self, body):
        """Parse URL-encoded form data"""
        params = {}
        pairs = body.split('&')

        for pair in pairs:
            if '=' in pair:
                key, value = pair.split('=', 1)
                # Simple URL decoding
                value = value.replace('+', ' ')
                value = self.url_decode(value)
                params[key] = value

        return params

    def url_decode(self, s):
        """Basic URL decoding"""
        # Common URL encodings
        replacements = {
            '%20': ' ', '%21': '!', '%22': '"', '%23': '#', '%24': '$',
            '%25': '%', '%26': '&', '%27': "'", '%28': '(', '%29': ')',
            '%2B': '+', '%2C': ',', '%2F': '/', '%3A': ':', '%3B': ';',
            '%3D': '=', '%3F': '?', '%40': '@'
        }

        for encoded, decoded in replacements.items():
            s = s.replace(encoded, decoded)
        return s

    def connect_wifi(self, ssid, password):
        """Connect to WiFi network"""
        try:
            wlan = network.WLAN(network.STA_IF)
            wlan.active(True)

            if wlan.isconnected():
                wlan.disconnect()
                time.sleep(1)

            wlan.connect(ssid, password)
            print("Connecting to {}...".format(ssid))

            # Wait for connection
            timeout = 0
            while not wlan.isconnected() and timeout < 30:
                time.sleep(1)
                timeout += 1
                if timeout % 5 == 0:
                    print(".", end="")

            if wlan.isconnected():
                print("\nConnected! IP: {}".format(wlan.ifconfig()[0]))
                return True
            else:
                print("\nConnection failed")
                return False

        except Exception as e:
            print("WiFi connection error: {}".format(e))
            return False

    def decode_token(self, token):
        """Decode base64 token"""
        try:
            decoded = ubinascii.a2b_base64(token).decode('utf-8')
            json_data = ujson.loads(decoded)
            print("Token decoded: {}".format(json_data))
            return json_data
        except Exception as e:
            print("Token decode error: {}".format(e))
            return None

    def extract_server_url(self, json_data):
        """Extract server URL from token data"""
        try:
            url = json_data.get('url', '')
            if url:
                print("Server URL: {}".format(url))
                return url
            else:
                print("No URL found in token")
                return None
        except Exception as e:
            print("URL extraction error: {}".format(e))
            return None

    def extract_resolution(self, json_data):
        """Extract resolution from token data"""
        try:
            resolution = json_data.get('resolution', '640x480')
            print("Resolution: {}".format(resolution))
            return resolution
        except:
            return '640x480'

    def check_thermometer_attribute(self, json_data):
        """Check if device has thermometer capability"""
        try:
            attributes = json_data.get('attribute', [])

            if isinstance(attributes, list):
                has_thermometer = 'Thermometer' in attributes
            elif isinstance(attributes, str):
                has_thermometer = 'Thermometer' in attributes
            else:
                has_thermometer = False

            print("Thermometer capability: {}".format(has_thermometer))
            return has_thermometer

        except Exception as e:
            print("Thermometer check error: {}".format(e))
            return False

    def init_camera(self):
        """Initialize camera with error handling"""
        try:
            # Camera initialization
            camera.init(0, format=camera.JPEG, fb_location=camera.PSRAM)
            camera.quality(10)

            # Resolution mapping
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

            # Set resolution
            frame_size = resolution_map.get(self.resolution, camera.FRAME_VGA)
            camera.framesize(frame_size)

            # Set image rotation (180 degrees)
            camera.flip(1)
            camera.mirror(1)

            print("Camera initialized - Resolution: {}".format(self.resolution))
            self.camera_initialized = True
            return True

        except Exception as e:
            print("Camera initialization failed: {}".format(e))
            # Try fallback
            try:
                camera.init(0, format=camera.JPEG)
                camera.quality(10)
                camera.framesize(camera.FRAME_VGA)
                camera.flip(1)
                camera.mirror(1)
                print("Camera initialized (fallback mode)")
                self.camera_initialized = True
                return True
            except Exception as e2:
                print("Camera fallback failed: {}".format(e2))
                return False

    def capture_image(self):
        """Capture image with error handling - OPTIMIZED for speed"""
        if not self.camera_initialized:
            print("Camera not initialized")
            return None

        try:
            # REMOVED: LED flash delay for faster capture
            # led_pin.on()
            # time.sleep(0.1)

            buf = camera.capture()

            # led_pin.off()

            if buf and len(buf) > 0:
                print("Image captured: {} bytes".format(len(buf)))
                return buf
            else:
                print("Image capture failed")
                return None

        except Exception as e:
            print("Image capture error: {}".format(e))
            return None

    def get_temperature(self):
        """Get temperature from DS18B20 sensor"""
        try:
            import onewire
            import ds18x20

            # Setup sensor on pin 2
            ds_pin = Pin(2)
            ds_sensor = ds18x20.DS18X20(onewire.OneWire(ds_pin))

            # Scan for devices
            roms = ds_sensor.scan()

            if not roms:
                print("No temperature sensors found")
                return 25.0

            # Convert temperature
            ds_sensor.convert_temp()
            time.sleep_ms(750)

            # Read temperature
            temperatures = []
            for rom in roms:
                try:
                    temp = ds_sensor.read_temp(rom)
                    if temp is not None:
                        temperatures.append(round(temp, 2))
                except Exception as e:
                    print("Sensor read error: {}".format(e))

            if temperatures:
                avg_temp = sum(temperatures) / len(temperatures)
                return round(avg_temp, 2)
            else:
                return 25.0

        except ImportError:
            print("Temperature sensor libraries not available")
            # Return simulated temperature
            import random
            return round(20 + random.random() * 10, 2)
        except Exception as e:
            print("Temperature read error: {}".format(e))
            return 25.0

    def manage_threads(self):
        """Thread management helper"""
        global active_threads
        with thread_lock:
            return active_threads < max_threads

    def upload_temperature(self, temperature):
        """Upload temperature data - OPTIMIZED with shorter timeouts"""
        global active_threads

        if not self.manage_threads():
            print("Too many active threads, skipping temperature upload")
            return

        with thread_lock:
            active_threads += 1

        try:
            success = self._upload_temperature_sync(temperature)
            if not success and self.skip_failed_uploads:
                print("Temperature upload failed, continuing...")
            else:
                print("Temperature upload: {}".format('success' if success else 'failed'))
        except Exception as e:
            print("Temperature upload error: {}".format(e))
        finally:
            with thread_lock:
                active_threads -= 1

    def _upload_temperature_sync(self, temperature):
        """Synchronous temperature upload - REDUCED timeouts"""
        if not ussl:
            print("SSL not available")
            return False

        try:
            # Parse URL
            url = self.server_url
            is_https = url.startswith('https://')

            # Remove protocol
            host_path = url.replace('https://', '').replace('http://', '')

            # Split host and path
            if '/' in host_path:
                host = host_path.split('/')[0]
                path = '/' + '/'.join(host_path.split('/')[1:])
            else:
                host = host_path
                path = '/'

            # Handle port
            if ':' in host:
                host, port = host.split(':')
                port = int(port)
            else:
                port = 443 if is_https else 80

            # Create request
            endpoint = "{}/NProtocol/api/Temp".format(path.rstrip('/'))
            data = "temp={}".format(temperature)

            headers = (
                "POST {} HTTP/1.1\r\n"
                "Host: {}\r\n"
                "HubFlag: {}\r\n"
                "Content-Type: application/x-www-form-urlencoded\r\n"
                "Content-Length: {}\r\n"
                "Connection: close\r\n\r\n"
            ).format(endpoint, host, self.token, len(data))

            # Connect and send - REDUCED timeout from 15 to 5 seconds
            addr = socket.getaddrinfo(host, port)[0][-1]
            s = socket.socket()
            s.settimeout(5)  # REDUCED timeout
            s.connect(addr)

            if is_https:
                s = ussl.wrap_socket(s)

            s.write(headers.encode())
            s.write(data.encode())

            # Read response
            response = s.read(512).decode('utf-8', errors='ignore')
            s.close()

            return '200 OK' in response or '204' in response

        except Exception as e:
            print("Temperature upload error: {}".format(e))
            return False

    def upload_image(self, image_data):
        """Upload image data - OPTIMIZED with shorter timeouts"""
        global active_threads

        if not self.manage_threads():
            print("Too many active threads, skipping image upload")
            return

        with thread_lock:
            active_threads += 1

        try:
            success = self._upload_image_sync(image_data)
            if not success and self.skip_failed_uploads:
                print("Image upload failed, continuing...")
            else:
                print("Image upload: {}".format('success' if success else 'failed'))
        except Exception as e:
            print("Image upload error: {}".format(e))
        finally:
            with thread_lock:
                active_threads -= 1

    def _upload_image_sync(self, image_data):
        """Synchronous image upload - REDUCED timeouts"""
        if not ussl:
            print("SSL not available")
            return False

        try:
            # Parse URL
            url = self.server_url
            is_https = url.startswith('https://')

            # Remove protocol
            host_path = url.replace('https://', '').replace('http://', '')

            # Split host and path
            if '/' in host_path:
                host = host_path.split('/')[0]
                path = '/' + '/'.join(host_path.split('/')[1:])
            else:
                host = host_path
                path = '/'

            # Handle port
            if ':' in host:
                host, port = host.split(':')
                port = int(port)
            else:
                port = 443 if is_https else 80

            # Create multipart data
            boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
            endpoint = "{}/NProtocol/api/UploadImage".format(path.rstrip('/'))

            body_start = (
                "--{}\r\n"
                "Content-Disposition: form-data; name=\"snapshot\"; filename=\"image.jpg\"\r\n"
                "Content-Type: image/jpeg\r\n\r\n"
            ).format(boundary)

            body_end = "\r\n--{}--\r\n".format(boundary)

            content_length = len(body_start) + len(image_data) + len(body_end)

            headers = (
                "POST {} HTTP/1.1\r\n"
                "Host: {}\r\n"
                "HubFlag: {}\r\n"
                "Content-Type: multipart/form-data; boundary={}\r\n"
                "Content-Length: {}\r\n"
                "Connection: close\r\n\r\n"
            ).format(endpoint, host, self.token, boundary, content_length)

            # Connect and send - REDUCED timeout from 30 to 10 seconds
            addr = socket.getaddrinfo(host, port)[0][-1]
            s = socket.socket()
            s.settimeout(10)  # REDUCED timeout
            s.connect(addr)

            if is_https:
                s = ussl.wrap_socket(s)

            # Send headers and body
            s.write(headers.encode())
            s.write(body_start.encode())

            # Send image in chunks
            chunk_size = 1024
            for i in range(0, len(image_data), chunk_size):
                chunk = image_data[i:i + chunk_size]
                s.write(chunk)

            s.write(body_end.encode())

            # Read response
            response = s.read(512).decode('utf-8', errors='ignore')
            s.close()

            return '200 OK' in response or '204' in response

        except Exception as e:
            print("Image upload error: {}".format(e))
            return False

    def main_loop(self):
        """Main execution loop - OPTIMIZED for real-time performance"""
        print("Starting main loop in real-time mode...")

        while True:
            try:
                # REMOVED: Cycle logging for faster execution
                # print("\n--- New cycle ---")

                # Upload temperature if thermometer is available
                if self.has_thermometer:
                    try:
                        temperature = self.get_temperature()
                        print("Temp: {}°C".format(temperature))

                        # Start temperature upload thread
                        _thread.start_new_thread(self.upload_temperature, (temperature,))

                    except Exception as e:
                        print("Temperature error: {}".format(e))

                # Capture and upload image - MAIN OPTIMIZATION
                try:
                    image_data = self.capture_image()
                    if image_data:
                        # Start image upload thread immediately
                        _thread.start_new_thread(self.upload_image, (image_data,))

                        # Clear image data from memory immediately
                        del image_data

                    else:
                        print("Capture failed")

                except Exception as e:
                    print("Image error: {}".format(e))

                # OPTIMIZED: Much shorter wait time
                if self.realtime_mode:
                    time.sleep(self.upload_interval)  # 0.1 seconds
                else:
                    time.sleep(1)  # Fallback to 1 second

            except KeyboardInterrupt:
                print("Stopping...")
                break
            except Exception as e:
                print("Main loop error: {}".format(e))
                time.sleep(0.5)  # Shorter error recovery time

def main():
    """Main function"""
    iot_device = ESP32_CAM_IoT()

    try:
        # Load configuration
        ssid, password, token = iot_device.load_wifi_config()

        # Check if configuration is valid
        if not all([ssid, password, token]) or not iot_device.validate_token(token):
            print("Starting configuration mode...")
            ip = iot_device.create_hotspot()
            if ip:
                iot_device.setup_web_server(ip)
            else:
                print("Failed to create hotspot")
                return

        # Connect to WiFi
        if not iot_device.connect_wifi(ssid, password):
            print("WiFi connection failed, resetting...")
            iot_device.clear_config_and_reset()
            return

        # Decode token and extract configuration
        token_data = iot_device.decode_token(token)
        if not token_data:
            print("Token decode failed, resetting...")
            iot_device.clear_config_and_reset()
            return

        # Extract server configuration
        iot_device.server_url = iot_device.extract_server_url(token_data)
        if not iot_device.server_url:
            print("Server URL not found, resetting...")
            iot_device.clear_config_and_reset()
            return

        iot_device.token = token
        iot_device.has_thermometer = iot_device.check_thermometer_attribute(token_data)
        iot_device.resolution = iot_device.extract_resolution(token_data)

        # Initialize camera
        if not iot_device.init_camera():
            print("Camera initialization failed")
            return

        # Start main loop
        iot_device.main_loop()

    except Exception as e:
        print("Fatal error: {}".format(e))
        machine.reset()

if __name__ == '__main__':
    main()