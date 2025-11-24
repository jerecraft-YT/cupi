extends ColorRect

var wave_amp:float

func _ready() -> void:
	pass

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	material.set_shader_parameter("wave_amp", wave_amp)
	wave_amp = lerp(wave_amp,0.025,0.1*DataGame.time_fixed)
	
