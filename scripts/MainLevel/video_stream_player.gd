extends VideoStreamPlayer

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	speed_scale = DataGame.cupi.TimeMultiplier
	
func _on_cupi_play() -> void:
	var offsetPlay = DataGame.datalevel.data.get("videoOfset", 0.0)
	
	if (offsetPlay < 0):
		#print("wait")
		await get_tree().create_timer(abs(offsetPlay)).timeout 
		#print("play")
		play()
	else:
		stream_position = offsetPlay
		play()
