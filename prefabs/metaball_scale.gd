extends Node
@export var defaultScale:Vector2 = Vector2(1,1)
@export var spectro:Node2D
var time
@export var metaballPivot:Node2D
@export var magnitudExtra:float = 1
var patronUsar:int = 6
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(metaball)
	time += delta
	if time >= 0.12:
		#var escalaObjeto:Vector2 = spectrum.get_magnitude_for_frequency_range(spectrum.MagnitudeMode.MAGNITUDE_AVERAGE,8361) 
		metaballPivot.scale = defaultScale+(Vector2(spectro.max_values[patronUsar],spectro.max_values[patronUsar])*0.001)*magnitudExtra
		time = 0
	metaballPivot.scale = lerp(metaballPivot.scale,defaultScale,0.2*DataGame.time_fixed)
	#print(spectro.max_values[patronUsar])
