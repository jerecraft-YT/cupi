extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	position = get_global_mouse_position()
