extends GPUParticles2D

var tiempoVida:float
var time:float
var bulletStart
var Dinamic:bool
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	speed_scale = DataGame.cupi.TimeMultiplier
	time += delta * DataGame.cupi.TimeMultiplier
	if is_instance_valid(bulletStart):
		if Dinamic:
			position = bulletStart.position
			rotation = deg_to_rad(bulletStart.angle)

	if time >= tiempoVida:
		emitting = false
	if emitting == false and time >= tiempoVida+lifetime:
		queue_free()
	if time <= 0:
		queue_free()
