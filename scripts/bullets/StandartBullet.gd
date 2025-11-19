extends Node2D

@onready var bullet=$"."
@onready var cupi = get_tree().get_first_node_in_group("cupi")
@onready var spawner = get_tree().get_first_node_in_group("bulletSpawner")
@onready var cupiContainer = get_tree().get_first_node_in_group("CupiContainer")

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
var startDestroy = true
var duracionBala:float
@warning_ignore("unused_parameter") # Ignorar esta advertencia xd UWU
func _process(delta: float) -> void:
	var currentTime = cupi.get_song_time()
	timeLerp = max(0,1.0-inverse_lerp(baseSpawnTime, baseStrumTime, currentTime))
	amp = distance * timeLerp * spawner.speed
	ampSpiral = distance * timeLerp
	ampSpiral +=35
	amp += 35
	bullet.position = Vector2(spawner.position.x + cos(deg_to_rad(angle))*amp,spawner.position.y + sin(deg_to_rad(angle))*amp)
	# De momento, eliminar la bala si se pasa de rango
	if timeLerp <= 0 and not isSpiral:
		#elimina objeto y aplica los cambios que necesita
		cupiContainer.cupiBeat()
		#cupi.cupiMouth.frame=expresionContain
		cupi.BgBeat()
		bullet.queue_free()
		duracionBala = 0.1
		cupi.BulletDestroy(bullet)
	if isSpiral:
		if spiralStart:
			var circularAttack = get_parent()
			if timeLerp <= 0:
				duracionBala = circularAttack.calc/1000.0
				if startDestroy == true:
					startDestroy = false
					cupi.BulletDestroy(bullet)

			angle = circularAttack.anguloFinal + circularAttack.AngleFinal

		
