extends Sprite2D

@warning_ignore("unused_parameter") 
func _process(delta: float) -> void:
	rotation += 0.02*DataGame.time_fixed
