extends Node2D 
class_name CupiCustomEffect

@onready var cupi:Cupi
@onready var NoRefreshEffect:EffectNoRefresh
var NoRefreshEffectState:bool

var baseStrumTime:float = 0
var baseSpawnTime:float = 0
var timeLerp:float = 1

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	var currentTime = cupi.get_song_time()
	# Movimiento de la bala
	timeLerp = max(0, 1.0 - inverse_lerp(baseSpawnTime, baseStrumTime, currentTime))
		
	if timeLerp <= 0:
		if NoRefreshEffect != null:
			NoRefreshEffect.EffectActive = NoRefreshEffectState
		queue_free()
