extends VideoStreamPlayer

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	speed_scale = DataGame.cupi.TimeMultiplier
	
func _on_cupi_play() -> void:
	play()
