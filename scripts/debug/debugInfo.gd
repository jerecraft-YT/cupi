extends RichTextLabel

@onready var cupi:Node2D = get_tree().get_first_node_in_group("cupi")

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
		text = str("Pos Music: ",cupi.levelMusic.get_playback_position(),"\nMultiplicador Velocidad: ",cupi.TimeMultiplier,"\nBPM: ",abs(cupi.chartData.data.bpm*cupi.TimeMultiplier),"\nFPS: ",Engine.get_frames_per_second())
