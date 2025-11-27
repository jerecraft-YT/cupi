extends Line2D

var factorAmp
@export var ScaleAmplitude = 1.0
@export var ScaleFrequency = 1.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	factorAmp = 720.0/get_viewport().get_visible_rect().size.x
	material.set_shader_parameter("amplitude",0.01*factorAmp*ScaleAmplitude)
	material.set_shader_parameter("frequency",60.0 * factorAmp * ScaleFrequency)
