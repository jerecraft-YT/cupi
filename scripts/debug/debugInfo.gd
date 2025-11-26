extends RichTextLabel

@onready var cupi:Node2D = get_tree().get_first_node_in_group("cupi")

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
		text = str("FPS: ",Engine.get_frames_per_second())
