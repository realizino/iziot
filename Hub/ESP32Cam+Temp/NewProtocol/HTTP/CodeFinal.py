import network
import socket
import time
import machine
import ujson
import ubinascii
import sys
import gc
from machine import Pin
import _thread

# Check camera module availability
try:
    import camera
except ImportError:
    print("Camera module not found. Please use a MicroPython firmware with camera support.")
    sys.exit(1)

# SSL/TLS support
try:
    import ussl
except ImportError:
    print("ussl module not found. HTTPS will not be available.")
    ussl = None

# ESP32-CAM pins
led_pin = Pin(4, Pin.OUT)
reset_pin = Pin(0, Pin.IN, Pin.PULL_UP)

# Delay between frames per resolution (seconds)
FRAME_DELAY = {
    "96 96": 0.1,
    "160 120": 0.1,
    "176 144": 0.1,
    "240 176": 0.2,
    "320 240": 0.3,
    "400 296": 0.4,
    "640 480": 0.5,
    "800 600": 1,
    "1024 768": 1,
    "1280 1024": 2,
    "1600 1200": 3,
}

# Resolution -> camera frame size name
FRAME_SIZE = {
    "96 96": "FRAME_96X96",
    "160 120": "FRAME_QQVGA",
    "176 144": "FRAME_QCIF",
    "240 176": "FRAME_HQVGA",
    "320 240": "FRAME_QVGA",
    "400 296": "FRAME_CIF",
    "640 480": "FRAME_VGA",
    "800 600": "FRAME_SVGA",
    "1024 768": "FRAME_XGA",
    "1280 1024": "FRAME_SXGA",
    "1600 1200": "FRAME_UXGA",
}

SETUP_HTML = """<!DOCTYPE html>
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
        <h2>BoomCam Settings</h2>
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


class ESP32_CAM_IoT:
    def __init__(self):
        self.wifi_config_file = 'wifi_config.json'
        self.ap_ssid = 'BoomCamHub'
        self.ap_password = '12345678'
        self.resolution = '640 480'
        self.server_url = None
        self.token = None
        self.has_thermometer = False
        self.has_rotate = False
        self.wlan = None
        self.camera_initialized = False
        self.ssid = None
        self.password = None
        # Only one upload (temperature + image) at a time
        self.upload_lock = _thread.allocate_lock()

    # ------------------------------------------------------------------
    # Config
    # ------------------------------------------------------------------
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
            json_str = ujson.dumps({'ssid': ssid, 'password': password, 'token': token})
            print("Config JSON length:", len(json_str))

            import uos
            try:
                uos.remove(self.wifi_config_file)
            except:
                pass

            with open(self.wifi_config_file, 'w') as f:
                chunk_size = 512
                for i in range(0, len(json_str), chunk_size):
                    f.write(json_str[i:i + chunk_size])
                f.flush()
            print("File written successfully")

            time.sleep(0.1)
            with open(self.wifi_config_file, 'r') as f:
                saved_content = f.read()

            saved_config = ujson.loads(saved_content)
            if saved_config.get('token', '') == token:
                print("WiFi credentials saved and verified successfully")
                return True
            print("Token verification failed")
            return False
        except Exception as e:
            print("Error saving config:", str(e))
            return False

    def clear_config_and_reset(self):
        try:
            import uos
            uos.remove(self.wifi_config_file)
            print("Config file cleared")
        except:
            print("Config file not found or already cleared")
        print("Resetting to hotspot mode...")
        time.sleep(2)
        machine.reset()

    # ------------------------------------------------------------------
    # Setup hotspot + web server
    # ------------------------------------------------------------------
    def create_hotspot(self):
        ap = network.WLAN(network.AP_IF)
        ap.active(True)
        ap.config(essid=self.ap_ssid, password=self.ap_password)
        print("Hotspot created: " + self.ap_ssid)
        print("IP: " + ap.ifconfig()[0])
        return ap.ifconfig()[0]

    def url_decode(self, s):
        """Full URL decoding (handles '+' and any %XX, including UTF-8)"""
        s = s.replace('+', ' ')
        parts = s.split('%')
        out = bytearray(parts[0].encode())
        for p in parts[1:]:
            try:
                out.append(int(p[:2], 16))
                out.extend(p[2:].encode())
            except:
                out.extend(b'%')
                out.extend(p.encode())
        try:
            return out.decode('utf-8')
        except:
            return out.decode('latin-1')

    def parse_form(self, body):
        params = {}
        for pair in body.split('&'):
            if '=' in pair:
                k, v = pair.split('=', 1)
                params[k] = self.url_decode(v).strip()
        return params

    def setup_web_server(self, ip):
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
                    request = request_data.decode('latin-1')

                if 'POST /setup' in request:
                    try:
                        body = request.split('\r\n\r\n', 1)[1]
                    except:
                        print("Error: Could not extract request body")
                        continue

                    params = self.parse_form(body)
                    ssid = params.get('ssid', '')
                    password = params.get('password', '')
                    token = params.get('token', '')

                    print("Received - SSID:", ssid)
                    print("Received - Password length:", len(password))
                    print("Received - Token length:", len(token))

                    saved = False
                    if ssid and password and token and self.validate_token(token):
                        saved = self.save_wifi_config(ssid, password, token)

                    if saved:
                        response = ("HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\n\r\n"
                                    "<html><body style=\"font-family:Arial;text-align:center;padding:50px;\">"
                                    "<h2>Settings saved successfully!</h2><p>Device is restarting...</p>"
                                    "</body></html>")
                    else:
                        response = ("HTTP/1.1 400 Bad Request\r\nContent-Type: text/html; charset=utf-8\r\n\r\n"
                                    "<html><body style=\"font-family:Arial;text-align:center;padding:50px;\">"
                                    "<h2>Error: Invalid token!</h2><p><a href=\"/\">Try Again</a></p>"
                                    "</body></html>")

                    conn.send(response.encode())
                    conn.close()

                    if saved:
                        s.close()
                        print("Restarting device...")
                        time.sleep(2)
                        machine.reset()
                        return
                else:
                    response = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\n\r\n" + SETUP_HTML
                    conn.send(response.encode())

            except Exception as e:
                print("Error handling request:", str(e))
            finally:
                try:
                    conn.close()
                except:
                    pass

    # ------------------------------------------------------------------
    # WiFi + token
    # ------------------------------------------------------------------
    def connect_wifi(self, ssid, password):
        self.ssid = ssid
        self.password = password
        self.wlan = network.WLAN(network.STA_IF)
        self.wlan.active(True)
        self.wlan.connect(ssid, password)

        print("Connecting to " + ssid + "...")
        timeout = 0
        while not self.wlan.isconnected() and timeout < 30:
            print(".", end="")
            time.sleep(1)
            timeout += 1

        if self.wlan.isconnected():
            print("\nConnected successfully! IP: " + self.wlan.ifconfig()[0])
            return True
        print("\nFailed to connect to WiFi")
        return False

    def ensure_wifi(self):
        """Reconnect if the connection dropped. Returns True if connected."""
        try:
            if self.wlan and self.wlan.isconnected():
                return True
            print("WiFi lost, reconnecting...")
            self.wlan.disconnect()
            self.wlan.connect(self.ssid, self.password)
            for _ in range(20):
                if self.wlan.isconnected():
                    print("WiFi reconnected")
                    return True
                time.sleep(1)
        except Exception as e:
            print("Reconnect error:", e)
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
        server_url = json_data.get('url', '')
        if server_url:
            print("Server URL extracted: " + server_url)
            return server_url
        print("URL field not found in token")
        return None

    def extract_resolution(self, json_data):
        resolution = json_data.get('resolution', '640 480')
        print("Resolution: {}".format(resolution))
        return resolution

    def has_attribute(self, json_data, name):
        try:
            attributes = json_data.get('attribute', '')
            result = name in attributes if isinstance(attributes, (list, str)) else False
            print("{} attribute check: {} (attributes: {})".format(name, result, attributes))
            return result
        except Exception as e:
            print("Error checking {} attribute: {}".format(name, e))
            return False

    # ------------------------------------------------------------------
    # Camera
    # ------------------------------------------------------------------
    def init_camera(self):
        try:
            camera.init(0, format=camera.JPEG, fb_location=camera.PSRAM)
            camera.quality(10)

            size_name = FRAME_SIZE.get(self.resolution, "FRAME_VGA")
            camera.framesize(getattr(camera, size_name))
            print("init camera resolution : camera." + size_name)

            if self.has_rotate:
                camera.flip(1)
                camera.mirror(1)

            print("Camera initialized - Resolution: {}".format(self.resolution))
            self.camera_initialized = True
            return True

        except Exception as e:
            print("Camera initialization failed: {}".format(e))
            try:
                camera.init(0, format=camera.JPEG)
                camera.quality(10)
                camera.framesize(camera.FRAME_VGA)
                if self.has_rotate:
                    camera.flip(1)
                    camera.mirror(1)
                print("Camera initialized (fallback mode)")
                self.camera_initialized = True
                return True
            except Exception as e2:
                print("Camera fallback failed: {}".format(e2))
                return False

    def capture_image(self):
        try:
            buf = camera.capture()
            if buf:
                print("Image captured - Size: " + str(len(buf)) + " bytes")
                return buf
            print("Failed to capture image")
            return None
        except Exception as e:
            print("Error capturing image: " + str(e))
            return None

    # ------------------------------------------------------------------
    # Temperature
    # ------------------------------------------------------------------
    def get_temperature(self):
        """Read DS18B20 on pin 2"""
        try:
            import onewire
            import ds18x20

            ds_sensor = ds18x20.DS18X20(onewire.OneWire(Pin(2)))
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
                        print("Sensor " + str(i) + " temperature: " + str(temp) + "C")
                except Exception as e:
                    print("Error reading sensor " + str(i) + ": " + str(e))

            if temperatures:
                return round(sum(temperatures) / len(temperatures), 2)
            print("No valid temperature readings")
            return 25.0

        except ImportError:
            print("DS18B20 libraries not available, using random temperature")
            import random
            return 20 + random.randint(0, 20)
        except Exception as e:
            print("Error reading temperature: " + str(e))
            return 25.0

    # ------------------------------------------------------------------
    # HTTP upload (generic, always closes the socket)
    # ------------------------------------------------------------------
    def _parse_url(self, server_url):
        is_https = server_url.startswith("https://")
        host_part = server_url.replace("https://", "").replace("http://", "").split('/')[0]
        if ':' in host_part:
            host, port_str = host_part.split(':')
            port = int(port_str)
        else:
            host = host_part
            port = 443 if is_https else 80
        return host, port, is_https

    def _post(self, path, content_type, parts, timeout=10):
        """POST the given list of bytes parts. Returns True on 200/204."""
        if self.server_url.startswith("https://") and ussl is None:
            print("ussl not available, cannot upload over HTTPS")
            return False

        s = None
        try:
            host, port, is_https = self._parse_url(self.server_url)
            total = 0
            for p in parts:
                total += len(p)

            header = ("POST {} HTTP/1.1\r\n"
                      "Host: {}\r\n"
                      "HubFlag: {}\r\n"
                      "Connection: close\r\n"
                      "Content-Type: {}\r\n"
                      "Content-Length: {}\r\n\r\n").format(path, host, self.token, content_type, total).encode()

            print("POST -> {}://{}:{}{}".format("https" if is_https else "http", host, port, path))

            addr = socket.getaddrinfo(host, port)[0][-1]
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(timeout)
            s.connect(addr)
            if is_https:
                s = ussl.wrap_socket(s)

            s.write(header)
            for p in parts:
                mv = memoryview(p)
                for i in range(0, len(mv), 1024):
                    s.write(mv[i:i + 1024])

            # Only the status line is needed, don't wait for the server to close
            resp = s.read(64)
            ok = bool(resp) and (b" 200" in resp[:16] or b" 204" in resp[:16])
            if ok:
                print("Upload OK")
            else:
                print("Upload failed, response:", resp[:40] if resp else None)
            return ok

        except Exception as e:
            print("Upload error:", e)
            return False
        finally:
            if s:
                try:
                    s.close()
                except:
                    pass
            gc.collect()

    def upload_temperature(self, temperature):
        body = ("temp=" + str(temperature)).encode()
        return self._post("/NProtocol/api/Temp", "application/x-www-form-urlencoded", [body], 10)

    def upload_image(self, image_data):
        boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
        body_start = ("--{}\r\nContent-Disposition: form-data; name=\"snapshot\"; "
                      "filename=\"image.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n").format(boundary).encode()
        body_end = "\r\n--{}--\r\n".format(boundary).encode()
        return self._post("/NProtocol/api/UploadImage",
                          "multipart/form-data; boundary=" + boundary,
                          [body_start, image_data, body_end], 15)

    def _upload_worker(self, image_data, temperature):
        """Runs in a thread. Releases the lock when done, no matter what."""
        try:
            if temperature is not None:
                self.upload_temperature(temperature)
            if image_data:
                self.upload_image(image_data)
        except Exception as e:
            print("Worker error:", e)
        finally:
            self.upload_lock.release()

    # ------------------------------------------------------------------
    # Main loop
    # ------------------------------------------------------------------
    def main_loop(self):
        delay = FRAME_DELAY.get(self.resolution, 3)

        while True:
            try:
                # Skip this cycle if the previous upload is still running
                if not self.upload_lock.acquire(False):
                    print("Previous upload still running, skipping frame")
                    time.sleep(0.2)
                    continue

                started = False
                try:
                    if not self.ensure_wifi():
                        print("No WiFi, skipping cycle")
                        time.sleep(2)
                        continue

                    print("\n--- Starting new cycle ---")

                    temperature = None
                    if self.has_thermometer:
                        try:
                            temperature = self.get_temperature()
                        except Exception as e:
                            print("temp error:", e)

                    image_data = self.capture_image()

                    if image_data or temperature is not None:
                        _thread.start_new_thread(self._upload_worker, (image_data, temperature))
                        started = True
                        print("Upload thread started.")
                    del image_data

                except Exception as e:
                    print("Cycle error:", e)
                finally:
                    # If no thread took ownership of the lock, release it here
                    if not started:
                        self.upload_lock.release()

                time.sleep(delay)

            except Exception as e:
                print("Error in main loop: " + str(e))
                time.sleep(5)
                gc.collect()


# ----------------------------------------------------------------------
# Main execution
# ----------------------------------------------------------------------
if __name__ == '__main__':
    iot_device = ESP32_CAM_IoT()

    ssid, password, token = iot_device.load_wifi_config()

    if not ssid or not password or not token or not iot_device.validate_token(token):
        print("WiFi credentials or token not found/valid. Starting setup hotspot...")
        ip = iot_device.create_hotspot()
        iot_device.setup_web_server(ip)  # blocks until setup is done, then resets

    if not iot_device.connect_wifi(ssid, password):
        print("Failed to connect to WiFi. Clearing config and restarting to hotspot mode...")
        iot_device.clear_config_and_reset()

    decoded_token_data = iot_device.decode_token(token)
    if decoded_token_data:
        iot_device.server_url = iot_device.extract_server_url(decoded_token_data)
        iot_device.token = token  # original token is sent as HubFlag
        iot_device.has_thermometer = iot_device.has_attribute(decoded_token_data, 'Thermometer')
        iot_device.has_rotate = iot_device.has_attribute(decoded_token_data, 'Rotate')
        iot_device.resolution = iot_device.extract_resolution(decoded_token_data)
    else:
        print("Failed to decode token. Clearing config and restarting to hotspot mode...")
        iot_device.clear_config_and_reset()

    if not iot_device.server_url:
        print("Server URL not found in token. Clearing config and restarting to hotspot mode...")
        iot_device.clear_config_and_reset()

    if not iot_device.init_camera():
        print("Fatal: Camera initialization failed. Cannot proceed.")
        sys.exit(1)

    gc.collect()
    print("Free memory before main loop:", gc.mem_free())

    iot_device.main_loop()