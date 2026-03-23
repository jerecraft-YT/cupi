extends Node2D 
class_name CupiBullet

@onready var cupi:Cupi
@onready var spawner:Node2D
@onready var cupiContainer:Node2D
@onready var controladorGeneral:Node2D = get_tree().get_first_node_in_group("controlador")
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
var cooldown:float
var deathcooldown:float
@export var update_interval: float = 0.008

var _time_accum: float = 0.0

func _ready() -> void:
	position = Vector2.ONE * 1000

func _process(delta: float) -> void:
	var currentTime = cupi.get_song_time()
	cooldown = max(0, cooldown - delta * cupi.TimeMultiplier)
	
	if isSpiral:
		if spiralStart:
			var circularAttack = get_parent()
			angle = circularAttack.anguloFinal + circularAttack.AngleFinal
			if timeLerp > 0:
				visible = true
				
			if timeLerp <= 0 and cupi.TimeMultiplier > 0:
				if cupi.cupiBot:
					controladorGeneral.rotation = deg_to_rad(angle)
				
				duracionBala = circularAttack.calc / 1000.0
				if not startDestroy:
					startDestroy = true
					cupi.BulletDestroy(self)
		else:
			# Spirales no iniciados - AÑADIR COOLDOWN
			if timeLerp <= 0 and cupi.TimeMultiplier > 0 and cooldown <= 0:
				if cupi.cupiBot:
					controladorGeneral.rotation = deg_to_rad(angle)
	
	# Movimiento de la bala
	_time_accum += delta
	
	timeLerp = min(1.0,max(0, 1.0 - inverse_lerp(baseSpawnTime, baseStrumTime, currentTime)))
	amp = distance * timeLerp * spawner.speed
	ampSpiral = distance * timeLerp
	ampSpiral += 35
	amp += 35
	position = Vector2(spawner.position.x + cos(deg_to_rad(angle)) * amp, spawner.position.y + sin(deg_to_rad(angle)) * amp)
	_time_accum = 0
		
	bulletHit(delta)
	
func bulletHit(delta):
	if timeLerp >0:
		visible = true
	
	if timeLerp <= 0 and cupi.TimeMultiplier > 0 and visible == true:
		if cupi.cupiBot:
			controladorGeneral.rotation = deg_to_rad(angle)
		
		var diferencia = abs(rad_to_deg(controladorGeneral.rotation) - fmod(angle, 360))
		var shortest_diff = min(diferencia, 360 - diferencia)
		deathcooldown += delta
		
		# Verificar si está dentro de la cobertura
		if shortest_diff <= cupi.cobertura / 2.0 and shortest_diff >= -cupi.cobertura / 2.0:
			visible = false
			# ACIERTO
			if shortest_diff <= (cupi.cobertura / 2.0) * 0.25:
				cupi.puntosNivel += 100
			elif shortest_diff <= (cupi.cobertura / 2.0) * 0.50:
				cupi.puntosNivel += 50
			elif shortest_diff <= (cupi.cobertura / 2.0) * 0.75:
				cupi.puntosNivel += 25
			else:
				cupi.puntosNivel += 10
			#cupi.BgBeat()
			#cupiContainer.cupiBeat()
			
			if isSpiral and !spiralStart:
				cupi.bulletHit()
			
			if not isSpiral:
				print("tiempo actual: " + str(cupi.get_song_time()) + "| tiempo a llegar: " + str(baseStrumTime))
				#call_deferred("queue_free")
				#queue_free()
				duracionBala = 0.1
				cupi.BulletDestroy(self)
		
		# ERROR - Solo después del deathcooldown
		if deathcooldown > 0.1 and visible == true:
			visible = false
			cupi.errores += 1
			if cupi.errores > 50:
				cupi.puntosNivel -= 300
			elif cupi.errores > 35:
				cupi.puntosNivel -= 250
			elif cupi.errores > 20:
				cupi.puntosNivel -= 200
			elif cupi.errores > 10:
				cupi.puntosNivel -= 150
			else:
				cupi.puntosNivel -= 100
			cupi.puntosNivel = max(0, cupi.puntosNivel)
			cupi.ralentizar()
			if not isSpiral:
				pass
				#call_deferred("queue_free")
				#queue_free()
