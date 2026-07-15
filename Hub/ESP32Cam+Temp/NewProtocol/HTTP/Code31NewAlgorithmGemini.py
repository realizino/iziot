import network
import socket
import time
import machine
import ujson
import ubinascii
import sys
import uos
from machine import Pin, reset
import _thread
import gc

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
# A red LED is typically on Pin 4.
led_pin = Pin(4, Pin.OUT)
# A flash LED is typically on Pin 4.
# The reset button is on Pin 0.
reset_pin = Pin(0, Pin.IN, Pin.PULL_UP)

# Global variables for multi-threading
# A list to act as a queue for image file paths to be uploaded
upload_queue = []
# A lock to prevent simultaneous access to the queue from different threads
queue_lock = _thread.allocate_lock()
# A flag to control the uploader thread's main loop
should_upload_thread_run = True

class ESP32_CAM_IoT:
    def __init__(self):
        self.wifi_config_file = 'wifi_config.json'
        self.ap_ssid = 'iziotHub'
        self.ap_password = '12345678'
        self.resolution = '1600x1200'
        self.server_url = None
        self.token = None
        self.has_thermometer = False
        self.has_rotate = False
        self.camera_initialized = False

    def load_wifi_config(self):
        try:
            with open(self.wifi_config_file, 'r') as f:
                content = f.read()
                config = ujson.loads(content)
                ssid = config.get('ssid')
                password = config.get('password')
                token = config.get('token')
                return ssid, password, token
        except Exception:
            return None, None, None

    def validate_token(self, token):
        try:
            if not token or len(token) < 10:
                return False
            decoded = ubinascii.a2b_base64(token).decode('utf-8')
            json_data = ujson.loads(decoded)
            if 'url' not in json_data:
                return False
            return True
        except Exception:
            return False

    def save_wifi_config(self, ssid, password, token):
        try:
            config = {
                'ssid': ssid,
                'password': password,
                'token': token
            }
            json_str = ujson.dumps(config)
            with open(self.wifi_config_file, 'w') as f:
                f.write(json_str)
            with open(self.wifi_config_file, 'r') as f:
                saved_content = f.read()
            saved_config = ujson.loads(saved_content)
            saved_token = saved_config.get('token', '')
            if len(saved_token) == len(token) and saved_token == token:
                return True
            else:
                return False
        except Exception as e:
            return False

    def clear_config_and_reset(self):
        try:
            uos.remove(self.wifi_config_file)
        except:
            pass
        time.sleep(2)
        machine.reset()

    def create_hotspot(self):
        ap = network.WLAN(network.AP_IF)
        ap.active(True)
        ap.config(essid=self.ap_ssid, password=self.ap_password)
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
        while True:
            conn, addr = s.accept()
            try:
                request_data = b''
                conn.settimeout(5)
                while True:
                    try:
                        chunk = conn.recv(1024)
                        if not chunk: break
                        request_data += chunk
                        if b'\r\n\r\n' in request_data:
                            if b'POST' in request_data:
                                content_length = 0
                                for line in request_data.split(b'\r\n'):
                                    if line.lower().startswith(b'content-length:'):
                                        content_length = int(line.split(b':')[1].strip())
                                        break
                                while len(request_data.split(b'\r\n\r\n', 1)[1]) < content_length:
                                    more_data = conn.recv(min(1024, content_length - len(request_data.split(b'\r\n\r\n', 1)[1])))
                                    if not more_data: break
                                    request_data += more_data
                            break
                    except: break

                try:
                    request = request_data.decode('utf-8')
                except:
                    request = ''

                if 'POST /setup' in request:
                    try:
                        body = request.split('\r\n\r\n')[1]
                    except: continue
                    params = {}
                    parts = body.split('&')
                    for part in parts:
                        key_val = part.split('=', 1)
                        if len(key_val) == 2:
                            params[key_val[0]] = self.url_decode(key_val[1])

                    ssid = params.get('ssid', '').strip()
                    password = params.get('password', '').strip()
                    token = params.get('token', '').strip()

                    if ssid and password and token and self.save_wifi_config(ssid, password, token):
                        response = """HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\n\r\n<html><body style="font-family:Arial;text-align:center;padding:50px;"><h2>Settings saved successfully!</h2><p>Device is restarting...</p></body></html>"""
                        conn.send(response.encode())
                        conn.close()
                        s.close()
                        time.sleep(2)
                        machine.reset()
                        return
                    else:
                        response = """HTTP/1.1 400 Bad Request\r\nContent-Type: text/html; charset=utf-8\r\n\r\n<html><body style="font-family:Arial;text-align:center;padding:50px;"><h2>Error: Invalid token!</h2><p><a href="/">Try Again</a></p></body></html>"""
                        conn.send(response.encode())
                else:
                    response = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\n\r\n" + html
                    conn.send(response.encode())
            except Exception:
                pass
            finally:
                conn.close()

    def url_decode(self, s):
        replacements = {'%20': ' ', '%21': '!', '%22': '"', '%23': '#', '%24': '$', '%25': '%', '%26': '&', '%27': "'", '%28': '(', '%29': ')', '%2A': '*', '%2B': '+', '%2C': ',', '%2D': '-', '%2E': '.', '%2F': '/', '%3A': ':', '%3B': ';', '%3C': '<', '%3D': '=', '%3E': '>', '%3F': '?', '%40': '@', '%5B': '[', '%5C': '\\', '%5D': ']', '%5E': '^', '%5F': '_', '%60': '`', '%7B': '{', '%7C': '|', '%7D': '}', '%7E': '~'}
        for encoded, decoded in replacements.items():
            s = s.replace(encoded, decoded)
        return s

    def connect_wifi(self, ssid, password):
        wlan = network.WLAN(network.STA_IF)
        wlan.active(True)
        wlan.connect(ssid, password)
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
            return json_data
        except Exception:
            self.clear_config_and_reset()
            return None

    def extract_server_url(self, json_data):
        try:
            server_url = json_data.get('url', '')
            return server_url if server_url else None
        except Exception:
            return None

    def extract_resolution(self, json_data):
        try:
            return json_data.get('resolution', '640x480')
        except:
            return '640x480'

    def check_thermometer_attribute(self, json_data):
        try:
            attributes = json_data.get('attribute', '')
            if isinstance(attributes, list):
                return 'Thermometer' in attributes
            elif isinstance(attributes, str):
                return 'Thermometer' in attributes
            else:
                return False
        except Exception:
            return False

    def check_rotate_attribute(self, json_data):
        try:
            attributes = json_data.get('attribute', '')
            if isinstance(attributes, list):
                return 'Rotate' in attributes
            elif isinstance(attributes, str):
                return 'Rotate' in attributes
            else:
                return False
        except Exception:
            return False

    def init_camera(self):
        try:
            camera.init(0, format=camera.JPEG, fb_location=camera.PSRAM)
            camera.quality(10)

            res_map = {
                "96x96": camera.FRAME_96X96, "160x120": camera.FRAME_QQVGA, "176x144": camera.FRAME_QCIF,
                "240x176": camera.FRAME_HQVGA, "320x240": camera.FRAME_QVGA, "400x296": camera.FRAME_CIF,
                "640x480": camera.FRAME_VGA, "800x600": camera.FRAME_SVGA, "1024x768": camera.FRAME_XGA,
                "1280x1024": camera.FRAME_SXGA, "1600x1200": camera.FRAME_UXGA
            }
            frame_size = res_map.get(self.resolution, camera.FRAME_VGA)
            camera.framesize(frame_size)
            print(f"Camera initialized - Resolution: {self.resolution}")

            if self.has_rotate:
              camera.flip(1)
              camera.mirror(1)

            self.camera_initialized = True
            return True
        except Exception as e:
            print(f"Camera initialization failed: {e}")
            self.camera_initialized = False
            return False

    def capture_and_save_image(self, file_path, retries=3):
        if not self.camera_initialized: return False

        fallback_resolutions = [
            camera.FRAME_UXGA, camera.FRAME_SXGA, camera.FRAME_XGA,
            camera.FRAME_SVGA, camera.FRAME_VGA
        ]

        current_res_index = -1
        try: current_res_index = fallback_resolutions.index(camera.framesize())
        except ValueError: current_res_index = 0

        attempt = 0
        while attempt < retries:
            try:
                gc.collect()
                buf = camera.capture()
                if buf:
                    with open(file_path, 'wb') as f:
                        f.write(buf)
                    print(f"Image captured and saved to {file_path} - Size: {len(buf)} bytes")
                    del buf
                    gc.collect()
                    return True
                else:
                    print(f"Attempt {attempt + 1}: Failed to capture image. Retrying...")
                    attempt += 1
                    time.sleep(1)
            except MemoryError:
                print(f"Attempt {attempt + 1}: MemoryError. Lowering resolution...")
                current_res_index += 1
                if current_res_index < len(fallback_resolutions):
                    try:
                        camera.framesize(fallback_resolutions[current_res_index])
                    except:
                        return False
                else:
                    return False
                attempt += 1
                time.sleep(1)
            except Exception as e:
                print(f"Attempt {attempt + 1}: Error capturing image: {str(e)}. Retrying...")
                attempt += 1
                time.sleep(1)
        print("Failed to capture image after all retries.")
        return False

    def upload_image_and_delete(self, file_path, server_url, token):
        try:
            with open(file_path, 'rb') as f:
                image_data = f.read()

            if self._upload_image_thread_raw(image_data, server_url, token):
                print(f"Image {file_path} uploaded successfully. Deleting file...")
                uos.remove(file_path)
                return True
            else:
                return False
        except Exception as e:
            return False

    def _upload_image_thread_raw(self, image_data, server_url, token):
        if ussl is None: return False
        gc.collect()
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

            boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
            headers_part1 = f"POST /NProtocol/api/UploadImage HTTP/1.1\r\nHost: {host}\r\nHubFlag: {token}\r\nContent-Type: multipart/form-data; boundary={boundary}\r\n"
            body_start_part = f"--{boundary}\r\nContent-Disposition: form-data; name=\"snapshot\"; filename=\"image.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n"
            body_end_part = f"\r\n--{boundary}--\r\n"
            content_length = len(body_start_part) + len(image_data) + len(body_end_part)
            headers_part2 = f"Content-Length: {content_length}\r\n\r\n"

            addr_info = socket.getaddrinfo(host, port)
            addr = addr_info[0][-1]
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(20)

            try:
                s.connect(addr)
                if is_https: s = ussl.wrap_socket(s)
                s.write(headers_part1.encode())
                s.write(headers_part2.encode())
                s.write(body_start_part.encode())
                s.write(image_data)
                s.write(body_end_part.encode())

                response = s.read(1024)
                if response:
                    response_str = response.decode(errors='ignore')
                    s.close()
                    return "200 OK" in response_str or "204 No Content" in response_str
                else:
                    s.close()
                    return False
            except Exception:
                s.close()
                return False
        except Exception:
            return False
        finally:
            gc.collect()

    def get_temperature(self):
        try:
            import onewire, ds18x20
            from machine import Pin
            ds_pin = Pin(2)
            ds_sensor = ds18x20.DS18X20(onewire.OneWire(ds_pin))
            roms = ds_sensor.scan()
            if len(roms) == 0: return 25.0
            ds_sensor.convert_temp()
            time.sleep_ms(750)
            temperatures = [ds_sensor.read_temp(rom) for rom in roms]
            valid_temps = [t for t in temperatures if t is not None]
            return round(sum(valid_temps) / len(valid_temps), 2) if valid_temps else 25.0
        except:
            return 25.0

    def _upload_temperature_thread(self, temperature, server_url, token):
        if ussl is None: return False
        gc.collect()
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

            post_data = "temp=" + str(temperature)
            headers = f"POST /NProtocol/api/Temp HTTP/1.1\r\nHost: {host}\r\nHubFlag: {token}\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: {len(post_data)}\r\n\r\n"
            addr_info = socket.getaddrinfo(host, port)
            addr = addr_info[0][-1]
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(10)

            try:
                s.connect(addr)
                if is_https: s = ussl.wrap_socket(s)
                s.write(headers.encode())
                s.write(post_data.encode())
                response = s.read(1024)
                if response:
                    response_str = response.decode(errors='ignore')
                    s.close()
                    return "200 OK" in response_str or "204 No Content" in response_str
                else:
                    s.close()
                    return False
            except Exception:
                s.close()
                return False
        except Exception:
            return False
        finally:
            gc.collect()

def uploader_thread(app_instance, server_url, token):
    print("Uploader thread started.")
    while should_upload_thread_run:
        try:
            queue_lock.acquire()
            if upload_queue:
                file_path = upload_queue.pop(0)
                queue_lock.release()
                print(f"Uploader thread: Found {file_path} in queue. Starting upload.")

                if not app_instance.upload_image_and_delete(file_path, server_url, token):
                    queue_lock.acquire()
                    upload_queue.append(file_path)
                    queue_lock.release()
                    print(f"Upload failed for {file_path}. Added back to queue.")
            else:
                queue_lock.release()
                time.sleep(1)
        except Exception:
            queue_lock.release()
            time.sleep(5)

    print("Uploader thread stopped.")

if __name__ == "__main__":
    app = ESP32_CAM_IoT()

    if reset_pin.value() == 0:
        app.clear_config_and_reset()

    ssid, password, token = app.load_wifi_config()

    if not ssid or not password or not token:
        ip = app.create_hotspot()
        app.setup_web_server(ip)
    else:
        if not app.connect_wifi(ssid, password):
            time.sleep(5)
            machine.reset()

        token_data = app.decode_token(token)
        if not token_data: sys.exit(1)

        app.server_url = app.extract_server_url(token_data)
        if not app.server_url: sys.exit(1)

        app.resolution = app.extract_resolution(token_data)
        app.has_thermometer = app.check_thermometer_attribute(token_data)
        app.has_rotate = app.check_rotate_attribute(token_data)

        if not app.init_camera():
            sys.exit(1)

        try:
            _thread.start_new_thread(uploader_thread, (app, app.server_url, token,))
        except Exception as e:
            print("Failed to start uploader thread:", e)

        image_counter = 0
        capture_interval = 0.1

        while True:
            try:
                gc.collect()
                filename = f"image_{image_counter:04d}.jpg"
                file_path = f"/flash/{filename}"

                if app.capture_and_save_image(file_path):
                    queue_lock.acquire()
                    upload_queue.append(file_path)
                    queue_lock.release()
                    image_counter += 1

                if app.has_thermometer:
                    temperature = app.get_temperature()
                    if temperature != "-":
                        _thread.start_new_thread(app._upload_temperature_thread, (temperature, app.server_url, token,))

                time.sleep(capture_interval)

            except Exception as e:
                print("Main loop error: " + str(e))
                time.sleep(5)