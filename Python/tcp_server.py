import socket
import json
import os
import sys

HOST = '127.0.0.1'
PORT = 8002

# Write current PID to file
with open("server.pid", "w") as f:
    f.write(str(os.getpid()))

def handle_data(data):
    try:
        parsed = json.loads(data)
        print(f"[✔] Received from Godot: {parsed}")

        # Check for shutdown command
        if parsed.get("shutdown"):
            print("[x] Shutdown signal received. Exiting...")
            if os.path.exists("server.pid"):
                os.remove("server.pid")
            sys.exit(0)

        return json.dumps({
            "ack": True,
            "received_angle": parsed.get("angle"),
            "received_power": parsed.get("power")
        })
    except json.JSONDecodeError as e:
        print(f"[!] Invalid JSON: {e}")
        return json.dumps({"ack": False, "error": "Invalid JSON"})

def start_server():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        s.bind((HOST, PORT))
        s.listen()
        print(f"[✓] Server listening on {HOST}:{PORT}")


        try:
            print("[...] Waiting for a new connection...")
            conn, addr = s.accept()
            print(f"[+] Connected by {addr}")

            with conn:
                buffer = ""
                while True:
                    chunk = conn.recv(1024)
                    if not chunk:
                        print("[-] Connection closed by client.")
                        sys.exit(0)
                        break
                    buffer += chunk.decode()

                    while "\n" in buffer:
                        msg, buffer = buffer.split("\n", 1)
                        print(f"[>] Raw message: {msg.strip()}")
                        response = handle_data(msg)
                        conn.sendall((response + "\n").encode())

        except Exception as e:
            print(f"[!] Server error: {e}")

if __name__ == "__main__":
    try:
        start_server()
    finally:
        if os.path.exists("server.pid"):
            os.remove("server.pid")
