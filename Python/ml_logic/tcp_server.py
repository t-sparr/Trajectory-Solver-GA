import socket
import json
import os
import sys
import ctypes
import time

class TCPServer:
    def __init__(self, host='127.0.0.1', port=8002):
        self.host = host
        self.port = port
        self.client_conn = None
        self.buffer = ""
        self.running = False
        self.handler = None

    def start(self, handler):
        self.handler = handler
        self.running = True
        self._run_server()

    def move_window(self, x=100, y=100, width=1000, height=600):
        time.sleep(0.3)  # Wait a bit for the terminal to fully initialize
        hwnd = ctypes.windll.kernel32.GetConsoleWindow()
        if hwnd:
            ctypes.windll.user32.MoveWindow(hwnd, x, y, width, height, True)


    def _run_server(self):
        self.move_window(-1920, 0, 1000, 1000)
        with open("server.pid", "w") as f:
            f.write(str(os.getpid()))

        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            s.bind((self.host, self.port))
            s.listen()
            print(f"[✓] Server listening on {self.host}:{self.port}")

            try:
                print("[...] Waiting for a connection...")
                self.client_conn, addr = s.accept()
                print(f"[+] Connected by {addr}")

                with self.client_conn:
                    while self.running:
                        chunk = self.client_conn.recv(1024)
                        if not chunk:
                            print("[-] Client disconnected.")
                            self.cleanup()
                            sys.exit(0)

                        self.buffer += chunk.decode()

                        while "\n" in self.buffer:
                            msg, self.buffer = self.buffer.split("\n", 1)
                            self._handle_message(msg)

            except Exception as e:
                print(f"[!] Server error: {e}")
            finally:
                self.cleanup()

    def _handle_message(self, raw_msg):
        try:
            data = json.loads(raw_msg)
            print(f"[-] From Godot: {data}")
        except json.JSONDecodeError as e:
            print(f"[!] JSON error: {e}")
            self.send_to_client(json.dumps({"ack": False, "error": "Invalid JSON"}))
            return

        if data.get("shutdown") is True:
            print("[x] Shutdown signal received.")
            self.send_to_client(json.dumps({"ack": True, "status": "shutting down"}))
            self.cleanup()
            sys.exit(0)

        if self.handler:
            response = self.handler(data)
            if response:
                self.send_to_client(response)
                
    def send_to_client(self, message):
        if self.client_conn:
            try:
                self.client_conn.sendall((message + "\n").encode())
            except Exception as e:
                print(f"[!] Send error: {e}")

    def cleanup(self):
        self.running = False
        if os.path.exists("server.pid"):
            os.remove("server.pid")
        print("[x] Server stopped.")

# Singleton
_server = TCPServer()

def start_server(handler):
    _server.start(handler)

def send_to_client(data):
    _server.send_to_client(data)
