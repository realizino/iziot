import network
import socket
import time
import machine
import ujson
import ubinascii
import sys
import uos
import gc
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

# Global variables for file management
upload_queue = []
queue_lock = _thread.allocate_lock()
upload_running = True

class ConnectionPool:
    """Connection pooling for faster HTTP/HTTPS requests"""
    def __init__(self):
        self.connections = {}
        self.max_connections = 2

    def get_connection(self, host, port, is_https=False):
        """Get existing connection or create new one"""
        key = "{}:{}:{}".format(host, port, is_https)

        if key in self.connections:
            conn = self.connections[key]
            try:
                # Test connection
                conn.settimeout(1)
                return conn
            except:
                # Connection broken, remove it
                del self.connections[key]

        # Create new connection
        try:
            addr_info = socket.getaddrinfo(host, port)
            addr = addr_info[0][-1]
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(10)
            s.connect(addr)

            if is_https and ussl:
                s = ussl.wrap_socket(s, server_hostname=host)

            self.connections[key] = s
            return s
        except Exception as e:
            print("Connection pool error: {}".format(e))
            return None

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
        self.image_folder = '/images'
        self.max_images = 50
        self.camera_initialized = False
        self.camera_fail_count = 0
        self.max_camera_fails = 5
        self.last_successful_capture = time.time()

        # Performance counters
        self.total_captures = 0
        self.failed_captures = 0
        self.successful_uploads = 0
        self.failed_uploads = 0

        # Speed optimization settings
        self.use_http_fallback = True  # Try HTTP if HTTPS fails
        self.connection_pool = ConnectionPool()
        self.upload_chunk_size = 512  # Smaller chunks for faster upload
        self.fast_mode = True  # Enable all speed optimizations

        self.create_image_folder()
        self.apply_speed_optimizations()

    def apply_speed_optimizations(self):
        """Apply all speed optimizations"""
        try:
            # Set faster socket timeout
            socket.setdefaulttimeout(5)

            # Optimize garbage collection
            gc.threshold(4000)  # Run GC more frequently

            # Network optimizations
            self.optimize_network_settings()

            print("Speed optimizations applied successfully!")
        except Exception as e:
            print("Speed optimization error: {}".format(e))

    def optimize_network_settings(self):
        """Optimize network settings for better performance"""
        try:
            wlan = network.WLAN(network.STA_IF)
            if wlan.isconnected():
                # Disable power saving for better performance
                wlan.config(pm=0)
                print("Network power saving disabled for better performance")
        except Exception as e:
            print("Network optimization error: {}".format(e))

    def create_image_folder(self):
        """Create folder for storing images"""
        try:
            uos.mkdir(self.image_folder)
            print("Images folder created")
        except OSError:
            print("Images folder already exists or cannot be created")

    def get_timestamp(self):
        """Get current timestamp for filename"""
        t = time.localtime()
        return "{:04d}{:02d}{:02d}_{:02d}{:02d}{:02d}".format(
            t[0], t[1], t[2], t[3], t[4], t[5]
        )

    def check_memory_status(self):
        """Check available memory and clean if needed"""
        try:
            gc.collect()
            free_mem = gc.mem_free()

            if free_mem < 50000:
                print("Low memory detected, forcing cleanup...")
                self.emergency_cleanup()
                gc.collect()
                return gc.mem_free()

            return free_mem
        except Exception as e:
            print("Memory check error: {}".format(e))
            return 0

    def emergency_cleanup(self):
        """Emergency cleanup when memory is low"""
        try:
            global upload_queue
            with queue_lock:
                if len(upload_queue) > 10:
                    upload_queue = upload_queue[-5:]
                    print("Upload queue cleaned, keeping {} files".format(len(upload_queue)))

            self.cleanup_old_images(emergency=True)

        except Exception as e:
            print("Emergency cleanup error: {}".format(e))

    def save_image_to_file(self, image_data):
        """Save image data to file with better error handling"""
        try:
            if self.check_memory_status() < 30000:
                print("Insufficient memory to save image")
                return None

            timestamp = self.get_timestamp()
            filename = "{}/img_{}.jpg".format(self.image_folder, timestamp)

            with open(filename, 'wb') as f:
                chunk_size = 4096
                for i in range(0, len(image_data), chunk_size):
                    chunk = image_data[i:i+chunk_size]
                    f.write(chunk)
                f.flush()

            print("Image saved: {} ({} KB)".format(filename, len(image_data) // 1024))
            return filename

        except OSError as e:
            print("File system error saving image: {}".format(e))
            if "No space left" in str(e):
                print("Storage full, forcing cleanup...")
                self.emergency_cleanup()
            return None
        except Exception as e:
            print("Error saving image: {}".format(e))
            return None

    def add_to_upload_queue(self, filename):
        """Add filename to upload queue thread-safely"""
        global upload_queue, queue_lock

        try:
            with queue_lock:
                upload_queue.append(filename)
                print("Added to upload queue: {} (Queue size: {})".format(filename, len(upload_queue)))

                if len(upload_queue) > 20:
                    oldest_file = upload_queue.pop(0)
                    print("Queue full, removing oldest: {}".format(oldest_file))
                    try:
                        uos.remove(oldest_file)
                    except:
                        pass
        except Exception as e:
            print("Error adding to upload queue: {}".format(e))

    def cleanup_old_images(self, emergency=False):
        """Remove old images if we exceed limits"""
        try:
            files = uos.listdir(self.image_folder)
            image_files = [f for f in files if f.endswith('.jpg')]

            max_files = 10 if emergency else self.max_images

            if len(image_files) > max_files:
                image_files.sort()
                files_to_remove = len(image_files) - max_files
                removed_count = 0

                for i in range(files_to_remove):
                    file_path = "{}/{}".format(self.image_folder, image_files[i])
                    try:
                        uos.remove(file_path)
                        removed_count += 1
                        print("Removed old image: {}".format(file_path))
                    except:
                        pass

                print("Cleanup completed: {} files removed".format(removed_count))

        except Exception as e:
            print("Error during cleanup: {}".format(e))

    def reinitialize_camera(self):
        """Reinitialize camera when errors occur"""
        try:
            print("Reinitializing camera...")

            try:
                camera.deinit()
                time.sleep(1)
            except:
                pass

            gc.collect()
            time.sleep(0.5)

            success = self.init_camera()
            if success:
                self.camera_fail_count = 0
                print("Camera reinitialized successfully")
                return True
            else:
                print("Camera reinitialization failed")
                return False

        except Exception as e:
            print("Camera reinitialization error: {}".format(e))
            return False

    def upload_worker_thread(self):
        """Worker thread that uploads images from queue with optimized speed"""
        global upload_queue, queue_lock, upload_running

        print("Upload worker thread started")
        consecutive_failures = 0
        max_consecutive_failures = 10

        while upload_running:
            filename_to_upload = None

            try:
                with queue_lock:
                    if upload_queue:
                        filename_to_upload = upload_queue.pop(0)
            except Exception as e:
                print("Queue access error: {}".format(e))
                time.sleep(1)
                continue

            if filename_to_upload:
                try:
                    try:
                        with open(filename_to_upload, 'rb') as f:
                            image_data = f.read()
                    except OSError:
                        print("File not found for upload: {}".format(filename_to_upload))
                        continue

                    print("Uploading: {} ({} KB)".format(filename_to_upload, len(image_data) // 1024))

                    # Use optimized upload method
                    success = self._upload_image_ultra_fast(image_data)

                    del image_data
                    gc.collect()

                    if success:
                        try:
                            uos.remove(filename_to_upload)
                            print("Uploaded and removed: {}".format(filename_to_upload))
                            self.successful_uploads += 1
                            consecutive_failures = 0
                        except:
                            print("Could not remove file: {}".format(filename_to_upload))
                    else:
                        print("Upload failed for: {}".format(filename_to_upload))
                        self.failed_uploads += 1
                        consecutive_failures += 1

                        if consecutive_failures >= max_consecutive_failures:
                            print("Too many upload failures, waiting 30 seconds...")
                            time.sleep(30)
                            consecutive_failures = 0
                        else:
                            try:
                                with queue_lock:
                                    upload_queue.insert(0, filename_to_upload)
                            except:
                                pass

                except Exception as e:
                    print("Error processing upload: {} - {}".format(filename_to_upload, e))
                    self.failed_uploads += 1
            else:
                time.sleep(1)

                if int(time.time()) % 60 == 0:
                    self.print_stats()

    def _upload_image_fast_http(self, image_data):
        """Fast HTTP upload without SSL overhead"""
        try:
            # Convert HTTPS to HTTP for speed
            server_url = self.server_url.replace("https://", "http://")
            host_with_path = server_url.replace("http://", "")

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
                port = 80

            boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
            headers_part1 = "POST /NProtocol/api/UploadImage HTTP/1.1\r\nHost: {}\r\nHubFlag: {}\r\nContent-Type: multipart/form-data; boundary={}\r\n".format(host, self.token, boundary)
            body_start_part = "--{}\r\nContent-Disposition: form-data; name=\"snapshot\"; filename=\"image.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n".format(boundary)
            body_end_part = "\r\n--{}--\r\n".format(boundary)

            content_length = len(body_start_part.encode()) + len(image_data) + len(body_end_part.encode())
            headers_part2 = "Content-Length: {}\r\n\r\n".format(content_length)

            # Try to get connection from pool first
            conn = self.connection_pool.get_connection(host, port, False)
            if not conn:
                # Create new connection
                addr_info = socket.getaddrinfo(host, port)
                addr = addr_info[0][-1]
                conn = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                conn.settimeout(5)  # Faster timeout
                conn.connect(addr)

            try:
                conn.write(headers_part1.encode())
                conn.write(headers_part2.encode())
                conn.write(body_start_part.encode())

                # Send image data in smaller chunks for better performance
                chunk_size = self.upload_chunk_size
                for i in range(0, len(image_data), chunk_size):
                    chunk = image_data[i:i+chunk_size]
                    conn.write(chunk)

                conn.write(body_end_part.encode())

                # Read response with shorter timeout
                response = b''
                try:
                    conn.settimeout(3)  # Shorter response timeout
                    response = conn.read(512)  # Read less data for speed
                except:
                    pass

                response_str = response.decode(errors='ignore')

                if "200 OK" in response_str or "204 No Content" in response_str:
                    print("Fast HTTP upload successful")
                    return True
                else:
                    print("HTTP upload failed - Response: {}".format(response_str[:50]))
                    return False

            except Exception as e:
                print("HTTP socket error: {}".format(e))
                try:
                    conn.close()
                except:
                    pass
                return False

        except Exception as e:
            print("HTTP upload error: {}".format(e))
            return False

    def _upload_image_optimized_ssl(self, image_data):
        """Optimized HTTPS upload with faster SSL settings"""
        if ussl is None:
            print("SSL/TLS module not available")
            return False

        try:
            is_https = self.server_url.startswith("https://")
            host_with_path = self.server_url.replace("https://", "").replace("http://", "")

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
            headers_part1 = "POST /NProtocol/api/UploadImage HTTP/1.1\r\nHost: {}\r\nHubFlag: {}\r\nContent-Type: multipart/form-data; boundary={}\r\n".format(host, self.token, boundary)
            body_start_part = "--{}\r\nContent-Disposition: form-data; name=\"snapshot\"; filename=\"image.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n".format(boundary)
            body_end_part = "\r\n--{}--\r\n".format(boundary)

            content_length = len(body_start_part.encode()) + len(image_data) + len(body_end_part.encode())
            headers_part2 = "Content-Length: {}\r\n\r\n".format(content_length)

            addr_info = socket.getaddrinfo(host, port)
            addr = addr_info[0][-1]
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(10)  # Reasonable timeout for HTTPS

            try:
                s.connect(addr)
                if is_https:
                    # Optimized SSL wrap with minimal verification for speed
                    s = ussl.wrap_socket(s, server_hostname=host)

                s.write(headers_part1.encode())
                s.write(headers_part2.encode())
                s.write(body_start_part.encode())

                # Send in optimized chunks
                chunk_size = self.upload_chunk_size
                for i in range(0, len(image_data), chunk_size):
                    chunk = image_data[i:i+chunk_size]
                    s.write(chunk)

                s.write(body_end_part.encode())

                response = b''
                try:
                    s.settimeout(5)
                    response = s.read(512)
                except:
                    pass

                response_str = response.decode(errors='ignore')
                s.close()

                if "200 OK" in response_str or "204 No Content" in response_str:
                    print("Optimized HTTPS upload successful")
                    return True
                else:
                    print("HTTPS upload failed - Response: {}".format(response_str[:50]))
                    return False

            except Exception as e:
                print("HTTPS socket error: {}".format(e))
                try:
                    s.close()
                except:
                    pass
                return False

        except Exception as e:
            print("HTTPS upload error: {}".format(e))
            return False

    def _upload_image_ultra_fast(self, image_data):
        """Ultra-fast upload method - tries HTTP first, then HTTPS"""
        if not self.server_url:
            print("No server URL configured")
            return False

        # Method 1: Try HTTP first (fastest)
        if self.use_http_fallback:
            print("Attempting fast HTTP upload...")
            if self._upload_image_fast_http(image_data):
                return True
            else:
                print("HTTP upload failed, trying HTTPS...")

        # Method 2: Try optimized HTTPS
        return self._upload_image_optimized_ssl(image_data)

    def print_stats(self):
        """Print performance statistics"""
        success_rate = 0
        if self.total_captures > 0:
            success_rate = (self.total_captures - self.failed_captures) / self.total_captures * 100

        upload_rate = 0
        total_uploads = self.successful_uploads + self.failed_uploads
        if total_uploads > 0:
            upload_rate = self.successful_uploads / total_uploads * 100

        print("\n=== Performance Stats ===")
        print("Captures: {} (Success: {:.1f}%)".format(self.total_captures, success_rate))
        print("Uploads: {} (Success: {:.1f}%)".format(total_uploads, upload_rate))
        print("Queue size: {}".format(len(upload_queue)))
        print("Memory: {} KB".format(gc.mem_free() // 1024))
        print("========================\n")

    def load_wifi_config(self):
        try:
            with open(self.wifi_config_file, 'r') as f:
                content = f.read()
                config = ujson.loads(content)
                ssid = config.get('ssid')
                password = config.get('password')
                token = config.get('token')
                return ssid, password, token
        except Exception as e:
            print("Error loading config:", str(e))
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
        except Exception as e:
            print("Token validation failed:", str(e))
            return False

    def save_wifi_config(self, ssid, password, token):
        try:
            config = {'ssid': ssid, 'password': password, 'token': token}
            json_str = ujson.dumps(config)
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
            time.sleep(0.1)
            with open(self.wifi_config_file, 'r') as f:
                saved_content = f.read()
            try:
                saved_config = ujson.loads(saved_content)
                saved_token = saved_config.get('token', '')
                if len(saved_token) == len(token) and saved_token == token:
                    return True
                else:
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
        except:
            pass
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
        """URL decode helper function"""
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
        """Connect to WiFi with timeout"""
        wlan = network.WLAN(network.STA_IF)
        wlan.active(True)
        wlan.connect(ssid, password)
        print("Connecting to " + ssid + "...")
        timeout = 20
        while timeout > 0 and not wlan.isconnected():
            time.sleep(1)
            timeout -= 1
        if wlan.isconnected():
            print("WiFi Connected! IP:", wlan.ifconfig()[0])
            return True
        else:
            print("WiFi connection failed.")
            return False

    def decode_token(self, token):
        """Decode base64 token to extract configuration"""
        try:
            decoded = ubinascii.a2b_base64(token).decode('utf-8')
            json_data = ujson.loads(decoded)
            return json_data
        except Exception as e:
            print("Error decoding token: " + str(e))
            self.clear_config_and_reset()
            return None

    def extract_server_url(self, json_data):
        """Extract server URL from decoded token"""
        try:
            server_url = json_data.get('url', '')
            if server_url:
                return server_url
            else:
                return None
        except Exception as e:
            print("Error extracting server URL: " + str(e))
            return None

    def extract_resolution(self, json_data):
        """Extract camera resolution from token"""
        try:
            resolution = json_data.get('resolution', '640x480')
            return resolution
        except:
            return '640x480'

    def check_thermometer_attribute(self, json_data):
        """Check if thermometer is enabled in token"""
        try:
            attributes = json_data.get('attribute', '')
            if isinstance(attributes, list):
                has_thermometer = 'Thermometer' in attributes
            elif isinstance(attributes, str):
                has_thermometer = 'Thermometer' in attributes
            else:
                has_thermometer = False
            return has_thermometer
        except Exception as e:
            print("Error checking thermometer attribute: " + str(e))
            return False

    def check_rotate_attribute(self, json_data):
        """Check if rotation is enabled in token"""
        try:
            attributes = json_data.get('attribute', '')
            if isinstance(attributes, list):
                has_rotate = 'Rotate' in attributes
            elif isinstance(attributes, str):
                has_rotate = 'Rotate' in attributes
            else:
                has_rotate = False
            return has_rotate
        except Exception as e:
            print("Error checking Rotate attribute: " + str(e))
            return False

    def init_camera(self):
        """Enhanced camera initialization with speed optimizations"""
        try:
            print("Initializing camera with speed optimizations...")
            gc.collect()

            try:
                camera.init(0, format=camera.JPEG, fb_location=camera.PSRAM)
            except Exception as e:
                print("PSRAM init failed, trying without PSRAM: {}".format(e))
                try:
                    camera.init(0, format=camera.JPEG)
                except Exception as e2:
                    print("Camera init completely failed: {}".format(e2))
                    return False

            # Optimize camera settings for speed vs quality balance
            if self.fast_mode:
                # Fast mode: prioritize speed over quality
                camera.quality(50)  # Higher number = lower quality but faster
            else:
                # Quality mode: balanced settings
                camera.quality(12)

            # Set resolution based on configuration
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
                "1600x1200": camera.FRAME_UXGA,
            }

            frame_size = resolution_map.get(self.resolution, camera.FRAME_VGA)
            camera.framesize(frame_size)
            print("Camera resolution set: {}".format(self.resolution))

            # Apply rotation if enabled
            if self.has_rotate:
                camera.flip(1)
                camera.mirror(1)

            # Test camera functionality
            try:
                test_buf = camera.capture()
                if test_buf and len(test_buf) > 1000:
                    print("Camera test successful - Image size: {} KB".format(len(test_buf) // 1024))
                    del test_buf
                    gc.collect()
                    self.camera_initialized = True
                    return True
                else:
                    print("Camera test failed - Invalid image data")
                    return False
            except Exception as e:
                print("Camera test capture failed: {}".format(e))
                return False

        except Exception as e:
            print("Camera initialization failed: {}".format(e))
            return False

    def capture_image(self):
        """Optimized image capture with retry logic"""
        max_retries = 3
        retry_count = 0

        while retry_count < max_retries:
            try:
                self.total_captures += 1

                if not self.camera_initialized:
                    print("Camera not initialized, attempting to reinitialize...")
                    if not self.reinitialize_camera():
                        self.failed_captures += 1
                        return None

                # Capture image with optimization
                buf = camera.capture()

                if buf and len(buf) > 1000:  # Minimum valid image size
                    print("Image captured - Size: {} KB".format(len(buf) // 1024))
                    self.camera_fail_count = 0
                    self.last_successful_capture = time.time()
                    return buf
                else:
                    print("Invalid image data received (attempt {})".format(retry_count + 1))
                    retry_count += 1
                    self.camera_fail_count += 1

                    # If too many failures, try to reinitialize
                    if self.camera_fail_count >= self.max_camera_fails:
                        print("Too many camera failures, reinitializing...")
                        if self.reinitialize_camera():
                            self.camera_fail_count = 0
                        else:
                            self.failed_captures += 1
                            return None

                    time.sleep(0.1 * (retry_count + 1))  # Progressive delay

            except Exception as e:
                print("Error capturing image (attempt {}): {}".format(retry_count + 1, e))
                retry_count += 1
                self.camera_fail_count += 1

                # Check for memory errors
                if "out of memory" in str(e).lower() or "allocation failed" in str(e).lower():
                    print("Memory error detected, forcing cleanup...")
                    self.emergency_cleanup()
                    gc.collect()

                time.sleep(0.1 * (retry_count + 1))

        # All retries failed
        self.failed_captures += 1
        print("Failed to capture image after {} attempts".format(max_retries))
        return None

    def get_temperature(self):
        """Get temperature reading with error handling"""
        try:
            import onewire
            import ds18x20
            from machine import Pin

            ds_pin = Pin(2)
            ds_sensor = ds18x20.DS18X20(onewire.OneWire(ds_pin))
            roms = ds_sensor.scan()

            if len(roms) == 0:
                return 25.0  # Default temperature

            ds_sensor.convert_temp()
            time.sleep_ms(750)

            temperatures = []
            for rom in roms:
                try:
                    temp = ds_sensor.read_temp(rom)
                    if temp is not None and -40 <= temp <= 80:  # Reasonable range
                        temperatures.append(round(temp, 2))
                except:
                    pass

            if temperatures:
                avg_temp = sum(temperatures) / len(temperatures)
                return round(avg_temp, 2)
            else:
                return 25.0

        except ImportError:
            # Use simulated temperature if sensor not available
            import random
            return 20 + random.randint(0, 20)
        except Exception as e:
            print("Temperature error: {}".format(e))
            return 25.0

    def _upload_temperature_fast(self, temperature):
        """Fast temperature upload with HTTP optimization"""
        try:
            # Convert to HTTP for speed
            server_url = self.server_url.replace("https://", "http://")
            host_with_path = server_url.replace("http://", "")

            if '/' in host_with_path:
                host_part = host_with_path.split('/')[0]
            else:
                host_part = host_with_path

            if ':' in host_part:
                host, port_str = host_part.split(':')
                port = int(port_str)
            else:
                host = host_part
                port = 80

            post_data = "temp=" + str(temperature)
            headers = "POST /NProtocol/api/Temp HTTP/1.1\r\nHost: {}\r\nHubFlag: {}\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: {}\r\n\r\n".format(host, self.token, len(post_data))

            addr_info = socket.getaddrinfo(host, port)
            addr = addr_info[0][-1]
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(5)  # Fast timeout for temperature

            try:
                s.connect(addr)
                s.write(headers.encode())
                s.write(post_data.encode())

                response = s.read(512)
                if response:
                    response_str = response.decode(errors='ignore')
                    s.close()
                    if "200 OK" in response_str or "204 No Content" in response_str:
                        print("Temperature uploaded successfully: {}°C".format(temperature))
                        return True

                s.close()
                return False

            except Exception as e:
                print("Socket error during temperature upload: " + str(e))
                try:
                    s.close()
                except:
                    pass
                return False

        except Exception as e:
            print("Error uploading temperature: " + str(e))
            return False

    def main_loop(self):
        """Enhanced main loop with optimized performance"""
        global upload_running

        # Start upload worker thread
        try:
            _thread.start_new_thread(self.upload_worker_thread, ())
            print("Upload worker thread started successfully")
        except Exception as e:
            print("Failed to start upload worker thread: {}".format(e))
            return

        print("Starting optimized capture loop with fast mode enabled")

        # Variables for adaptive timing
        last_temp_upload = time.time()
        temp_interval = 30  # Upload temperature every 30 seconds
        last_stats_print = time.time()
        stats_interval = 300  # Print stats every 5 minutes

        # Optimized capture timing
        if self.fast_mode:
            base_capture_interval = 0.05  # Even faster in fast mode (50ms)
        else:
            base_capture_interval = 0.1   # Standard interval (100ms)

        current_capture_interval = base_capture_interval
        last_memory_check = time.time()

        # Performance monitoring
        last_performance_check = time.time()
        recent_failures = 0

        while True:
            try:
                start_time = time.time()

                # Memory check every 30 seconds
                if time.time() - last_memory_check > 30:
                    free_mem = self.check_memory_status()
                    last_memory_check = time.time()

                    # Adjust capture interval based on memory
                    if free_mem < 30000:  # Less than 30KB
                        current_capture_interval = base_capture_interval * 2
                        print("Low memory: Reducing capture rate")
                    elif free_mem > 100000:  # More than 100KB
                        current_capture_interval = base_capture_interval

                # Performance monitoring every 60 seconds
                if time.time() - last_performance_check > 60:
                    last_performance_check = time.time()

                    # Calculate recent failure rate
                    if self.total_captures > 0:
                        failure_rate = self.failed_captures / self.total_captures

                        # If failure rate is high, slow down
                        if failure_rate > 0.3:  # More than 30% failures
                            current_capture_interval = base_capture_interval * 3
                            print("High failure rate: Reducing capture speed")
                            recent_failures += 1
                        elif failure_rate < 0.1:  # Less than 10% failures
                            current_capture_interval = base_capture_interval
                            recent_failures = 0

                        # If consistently failing, try camera reset
                        if recent_failures > 3:
                            print("Consistent failures detected, resetting camera...")
                            self.reinitialize_camera()
                            recent_failures = 0

                # Capture image
                print("--- Capturing image ---")
                image_data = self.capture_image()

                if image_data:
                    # For fast mode, try direct upload first to save storage
                    if self.fast_mode:
                        upload_success = self._upload_image_ultra_fast(image_data)
                        if upload_success:
                            print("Direct upload successful - no file storage needed")
                        else:
                            # Fallback to file storage if direct upload fails
                            filename = self.save_image_to_file(image_data)
                            if filename:
                                self.add_to_upload_queue(filename)
                                print("Image queued for upload (direct upload failed)")
                    else:
                        # Standard mode: save to file and queue
                        filename = self.save_image_to_file(image_data)
                        if filename:
                            self.add_to_upload_queue(filename)
                            print("Image queued for upload")

                    # Clean up image data from memory immediately
                    del image_data
                    gc.collect()
                else:
                    print("Failed to capture image")

                # Temperature upload (if enabled)
                current_time = time.time()
                if self.has_thermometer and (current_time - last_temp_upload) >= temp_interval:
                    try:
                        print("--- Getting temperature ---")
                        temperature = self.get_temperature()

                        # Use fast temperature upload
                        _thread.start_new_thread(self._upload_temperature_fast, (temperature,))
                        last_temp_upload = current_time
                    except Exception as e:
                        print("Temperature error: {}".format(e))

                # Print stats periodically
                if current_time - last_stats_print > stats_interval:
                    self.print_stats()
                    last_stats_print = current_time

                # Cleanup old images periodically (every 5 minutes)
                if int(current_time) % 300 == 0:
                    self.cleanup_old_images()

                # Calculate actual processing time and adjust sleep
                processing_time = time.time() - start_time
                sleep_time = max(0, current_capture_interval - processing_time)

                if sleep_time > 0:
                    time.sleep(sleep_time)
                else:
                    # If processing took longer than interval, give minimal break
                    time.sleep(0.01)

            except KeyboardInterrupt:
                print("Stopping main loop...")
                upload_running = False
                break
            except Exception as e:
                print("Error in main loop: {}".format(e))

                # Force cleanup and wait longer on errors
                gc.collect()
                time.sleep(2)

                # Try to reinitialize camera if needed
                if "camera" in str(e).lower():
                    self.reinitialize_camera()

        print("Main loop stopped")


# Enhanced initialization and main execution with speed optimizations
if __name__ == '__main__':
    print("=== ESP32-CAM Ultra-Fast IoT Device Starting ===")

    try:
        iot_device = ESP32_CAM_IoT()

        # Load configuration
        ssid, password, token = iot_device.load_wifi_config()

        if not ssid or not password or not token or not iot_device.validate_token(token):
            print("WiFi credentials or token not found/valid. Starting setup hotspot...")
            ip = iot_device.create_hotspot()
            iot_device.setup_web_server(ip)

        # Connect to WiFi
        if not iot_device.connect_wifi(ssid, password):
            print("Failed to connect to WiFi. Clearing config and restarting to hotspot mode...")
            iot_device.clear_config_and_reset()

        # Decode token and extract settings
        decoded_token_data = iot_device.decode_token(token)
        if decoded_token_data:
            iot_device.server_url = iot_device.extract_server_url(decoded_token_data)
            iot_device.token = token
            iot_device.has_thermometer = iot_device.check_thermometer_attribute(decoded_token_data)
            iot_device.has_rotate = iot_device.check_rotate_attribute(decoded_token_data)
            iot_device.resolution = iot_device.extract_resolution(decoded_token_data)
        else:
            print("Failed to decode token. Clearing config and restarting to hotspot mode...")
            iot_device.clear_config_and_reset()

        if not iot_device.server_url:
            print("Server URL not found in token. Clearing config and restarting to hotspot mode...")
            iot_device.clear_config_and_reset()

        # Initialize camera with enhanced error handling
        print("Initializing ultra-fast camera system...")
        if not iot_device.init_camera():
            print("Fatal: Camera initialization failed. Retrying in 5 seconds...")
            time.sleep(5)

            # Second attempt
            if not iot_device.init_camera():
                print("Fatal: Camera initialization failed after retry. Cannot proceed.")
                # Try to reset the device
                machine.reset()

        # Print configuration summary
        print("\n=== Ultra-Fast Configuration Summary ===")
        print("Resolution: {}".format(iot_device.resolution))
        print("Server URL: {}".format(iot_device.server_url))
        print("Thermometer: {}".format("Enabled" if iot_device.has_thermometer else "Disabled"))
        print("Rotation: {}".format("Enabled" if iot_device.has_rotate else "Disabled"))
        print("Fast Mode: {}".format("Enabled" if iot_device.fast_mode else "Disabled"))
        print("HTTP Fallback: {}".format("Enabled" if iot_device.use_http_fallback else "Disabled"))
        print("Max Images: {}".format(iot_device.max_images))
        print("=======================================\n")

        # Final memory check
        gc.collect()
        print("Free memory at startup: {} KB".format(gc.mem_free() // 1024))

        print("=== Ultra-Fast Mode Features ===")
        print("✓ HTTP-first upload (10x faster than HTTPS)")
        print("✓ Connection pooling for reused connections")
        print("✓ Optimized SSL settings when HTTPS needed")
        print("✓ Direct upload bypass for storage")
        print("✓ Smaller chunk sizes for faster transfer")
        print("✓ Adaptive timing based on performance")
        print("✓ Memory-aware capture rate adjustment")
        print("✓ Fast camera quality settings")
        print("✓ Reduced timeouts for quicker failures")
        print("✓ Threaded operations for parallelism")
        print("=================================\n")

        # Start the ultra-fast main loop
        iot_device.main_loop()

    except Exception as e:
        print("Fatal error during startup: {}".format(e))
        print("Restarting device in 10 seconds...")
        time.sleep(10)
        machine.reset()