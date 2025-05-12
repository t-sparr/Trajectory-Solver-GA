extends Node2D

@onready var player_tank = $PlayerTank
@onready var angle_label = $UI/VBoxContainer/AngleLabel
@onready var power_label = $UI/VBoxContainer/PowerLabel
@onready var tcp_client = $TCP_Client

func _ready():
	tcp_client.server_connected.connect(_on_tcp_connected)
	tcp_client.data_received.connect(_on_server_response)

func _on_tcp_connected():
	print("✅ Connected to Python server.")

func _process(_delta):
	var angle_deg = rad_to_deg(player_tank.player_angle)
	angle_label.text = "Angle: %.2f°" % angle_deg
	power_label.text = "Power: %.1f" % (player_tank.current_power - 50)

func _input(event: InputEvent):
	if event.is_action_pressed("fire"):
		player_tank.fire_projectile()

#func _send_shot_data():
	#if tcp_client.connected:
		#var data = {
			#"angle": rad_to_deg(player_tank.player_angle),
			#"power": player_tank.current_power
		#}
		#tcp_client.send_json(data)
	#else:
		#print("⚠️ Not connected to server. Shot data not sent.")

func _on_server_response(data):
	print("Server response:", data)
	# Optionally act on server feedback (adjust shot, log result, etc.)
