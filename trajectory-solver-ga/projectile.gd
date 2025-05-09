extends Area2D

var velocity := Vector2.ZERO
var my_gravity := 600
var max_distance = 800
@export var deathParticle : PackedScene
@onready var target = get_tree().get_root().get_node("Game/Target")
@onready var tcp_client = get_node("/root/Game/TCP_Client")

var shot_data: Dictionary



func _physics_process(delta):
	velocity.y += my_gravity * delta
	
	position += velocity * delta
	rotation = velocity.angle()
	if position.y > 1000:
		delete_projectile()


func _on_body_entered(body: Node2D) -> void:
	if body.name in ["Tilemap1", "Tilemap2", "Target","Far_Ground"]:
		var particle = deathParticle.instantiate()
		particle.position = global_position
		particle.rotation = global_rotation
		get_tree().current_scene.add_child(particle)
		delete_projectile()
		
		
	

func delete_projectile():
	var distance = target.global_position.distance_to(global_position)
	var normalized_distance = distance / max_distance
	var fitness = 1 - normalized_distance
	var message = {
		"angle": shot_data.angle,
		"power": shot_data.power,
		"fitness": fitness
	}
	print("Fitness:", fitness)
	tcp_client.send_json(message)
	queue_free()
