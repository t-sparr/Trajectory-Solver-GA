extends Node

# === Config ===
const SERVER_IP := "127.0.0.1"
const SERVER_PORT := 8002
const LAUNCH_BAT := "C:\\Users\\Marco\\Documents\\Godot_Projects\\Trajectory_Solver\\Python\\launch_tcp_server.bat"

# === State ===
var client := StreamPeerTCP.new()
var connected := false
var buffer := ""

# === Signals ===
signal data_received(data)
signal server_connected

func _ready():
	_launch_python_server()
	await get_tree().create_timer(.1).timeout  # Give time for server to spin up
	await _connect_to_server(SERVER_IP, SERVER_PORT)

func _launch_python_server():
	var result := OS.create_process("cmd", ["/c", "start", "cmd", "/k", LAUNCH_BAT], false)
	print(result)

func _connect_to_server(ip: String, port: int) -> void:
	var err := client.connect_to_host(ip, port)
	if err != OK:
		print("❌ TCP: connect_to_host() failed. Code:", err)
		return

	while client.get_status() == StreamPeerTCP.STATUS_CONNECTING:
		client.poll()
		await get_tree().process_frame

	if client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		connected = true
		print("✅ TCP: Connected to %s:%d" % [ip, port])
		emit_signal("server_connected")
	else:
		print("❌ TCP: Connection failed.")

func send_json(data: Dictionary):
	if not connected:
		print("⚠️ TCP not connected. Cannot send.")
		return

	var message := JSON.stringify(data) + "\n"
	client.put_data(message.to_utf8_buffer())
	client.poll()

func _process(_delta: float) -> void:
	if connected:
		client.poll()
		if client.get_available_bytes() > 0:
			buffer += client.get_utf8_string(client.get_available_bytes())

			while buffer.find("\n") != -1:
				var newline := buffer.find("\n")
				var raw := buffer.substr(0, newline)
				buffer = buffer.substr(newline + 1)

				var parsed = JSON.parse_string(raw)
				if parsed:
					emit_signal("data_received", parsed)
