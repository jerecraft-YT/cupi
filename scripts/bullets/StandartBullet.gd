extends Node2D 
class_name CupiBullet

@onready var cupi:Node2D
@onready var spawner:Node2D
@onready var cupiContainer:Node2D
var distance:float=0
var angle:float=0
var baseStrumTime:float = 0
var baseSpawnTime:float = 0
var expresionContain:int = 0
var isSpiral:bool
var amp:float
var spiralStart:bool
var timeLerp:float = 1
var ampSpiral:float
var startDestroy = false
var duracionBala:float

func _ready() -> void:
	position = Vector2.ONE * 1000

@warning_ignore("unused_parameter") # Ignorar esta advertencia xd UWU
func _process(delta: float) -> void:
	var currentTime = cupi.get_song_time()
	
	if isSpiral:
		if spiralStart:
			var circularAttack = get_parent()
			angle = circularAttack.anguloFinal + circularAttack.AngleFinal
			if timeLerp <= 0:
				duracionBala = circularAttack.calc/1000.0
				if startDestroy == false:
					startDestroy = true
					cupi.BulletDestroy(self)
	
	timeLerp = max(0,1.0-inverse_lerp(baseSpawnTime, baseStrumTime, currentTime))
	amp = distance * timeLerp * spawner.speed
	ampSpiral = distance * timeLerp
	ampSpiral += 35
	amp += 35
	position = Vector2(spawner.position.x + cos(deg_to_rad(angle))*amp,spawner.position.y + sin(deg_to_rad(angle))*amp)
	# De momento, eliminar la bala si se pasa de rango
	if timeLerp <= 0 and not isSpiral:
		print(baseStrumTime)
		#elimina objeto y aplica los cambios que necesita
		cupiContainer.cupiBeat()
		#cupi.cupiMouth.frame=expresionContain
		cupi.BgBeat()
		queue_free()
		duracionBala = 0.1
		cupi.BulletDestroy(self)
