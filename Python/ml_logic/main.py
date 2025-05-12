from tcp_server import start_server, send_to_client
import json
import time
from evolve import *

def received_data(data):
    fitness = data.get("fitness", 0.0)
    return json.dumps(fitness)

if __name__ == "__main__":
    start_server(received_data)

    print("[*] Server running. Press Ctrl+C to stop.")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n[x] Interrupted by user.")
