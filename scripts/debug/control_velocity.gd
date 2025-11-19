extends HSlider

@onready var cupi:Node2D = get_tree().get_first_node_in_group("cupi")

@warning_ignore("unused_parameter")
func _input(event: InputEvent) -> void:
		cupi.TimeMultiplier=value
