extends Node2D

@export var projectile_scene: PackedScene
@export var power_multiplier := 5.0
var player_angle := 0.0
var current_power := 0.0
var barrel

func _ready() -> void:
	barrel = $TanksTurret1

func _process(delta):
	
	var mouse_pos = get_global_mouse_position()
	var barrel_global_pos = barrel.get_global_position()
	
	var direction = mouse_pos - barrel_global_pos
	player_angle = direction.angle()
	
	
	var min_angle = deg_to_rad(-90)
	var max_angle = deg_to_rad(0)
	player_angle = clamp(player_angle, min_angle, max_angle)
	
	var player_pos = global_position
	var distance = player_pos.distance_to(mouse_pos)/6
	current_power = clamp(distance, 0, 100) + 50
	
	
	barrel.rotation = player_angle
	
	
func fire_projectile():
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		
		var power = current_power * power_multiplier
		var spawn_pos = barrel.get_global_position() + Vector2.RIGHT.rotated(barrel.rotation) * 10
		
		projectile.global_position = spawn_pos
		projectile.velocity = Vector2.RIGHT.rotated(player_angle) * power
		projectile.shot_data = {
			"angle": rad_to_deg(player_angle),
			"power": current_power
		}
		get_tree().current_scene.add_child(projectile)
