extends Node2D

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			look_at(get_global_mouse_position())
			rotation = deg_to_rad(fmod(rad_to_deg(rotation),360))
