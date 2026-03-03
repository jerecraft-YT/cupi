class_name EffectNoRefresh
extends Sprite2D

var noise:NoiseTexture2D = texture
var noiseModif:FastNoiseLite = noise.noise
@export var EffectActive:bool = false:
	set(v):
		EffectActive = v
		togleEffect()
	get:
		return EffectActive

# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if EffectActive:
		noiseModif.seed = randi_range(-1024,1024)

func togleEffect():
	visible = EffectActive
	if EffectActive:
		RenderingServer.viewport_set_clear_mode(get_viewport().get_viewport_rid(),RenderingServer.VIEWPORT_CLEAR_ONLY_NEXT_FRAME)
	else:
		RenderingServer.viewport_set_clear_mode(get_viewport().get_viewport_rid(),RenderingServer.VIEWPORT_CLEAR_ALWAYS)
