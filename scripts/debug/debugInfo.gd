extends RichTextLabel

@onready var cupi:Cupi = get_tree().get_first_node_in_group("cupi")

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass
	text = str("FPS: ",Engine.get_frames_per_second(),"\nPuntos: ",cupi.puntosNivel,"\nErrores: ", cupi.errores)
