extends Node2D

var spectrum:AudioEffectSpectrumAnalyzerInstance
@export var defaultScale:Vector2 = Vector2(0.55,0.55)
var time:float
@export var spectro:SpectroAnalizer
@export var metaball:Node2D
var patronUsar:int = 6
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spectrum = AudioServer.get_bus_effect_instance(0, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(metaball)
	time += delta
	if time >= 0.12:
		#var escalaObjeto:Vector2 = spectrum.get_magnitude_for_frequency_range(spectrum.MagnitudeMode.MAGNITUDE_AVERAGE,8361) 
		metaball.scale = defaultScale+(Vector2(spectro.max_values[patronUsar],spectro.max_values[patronUsar])*0.001)*0.3
		time = 0
	metaball.scale = lerp(metaball.scale,defaultScale,0.2*DataGame.time_fixed)
	#print(spectro.max_values[patronUsar])
