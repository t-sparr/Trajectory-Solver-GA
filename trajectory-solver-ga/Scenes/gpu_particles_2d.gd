extends GPUParticles2D

var timeCreated
func _ready() -> void:
	timeCreated = Time.get_ticks_msec()
	emitting = true
	z_index = 1
	


func _process(_delta):
	if Time.get_ticks_msec() - timeCreated > 10000:
		queue_free()
