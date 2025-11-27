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

func _ready() -> void:
	position = Vector2.ONE * 1000

func _process(delta: float) -> void:
	var currentTime = cupi.get_song_time()
	cooldown = max(0,cooldown-delta)
	if isSpiral:
		if spiralStart:
			var circularAttack = get_parent()
			angle = circularAttack.anguloFinal + circularAttack.AngleFinal
			if timeLerp <= 0 and cupi.TimeMultiplier > 0 :
				var diferencia = abs(rad_to_deg(controladorGeneral.rotation) - fmod(angle,360))
				var shortest_diff = min(diferencia, 360 - diferencia)
				
				if shortest_diff <= cupi.cobertura / 2.0:
					pass
				else:
					cupi.ralentizar()
				
				if cooldown <= 0:
					if shortest_diff <= cupi.cobertura / 2.0:
						if shortest_diff <= (cupi.cobertura / 2.0)*0.32:
							#print("perfecto")
							cupi.puntosNivel += 100
						elif shortest_diff <= (cupi.cobertura / 2.0)*0.60:
							#print("bien")
							cupi.puntosNivel += 50
						elif shortest_diff <= (cupi.cobertura / 2.0)*0.8:
							#print("normal")
							cupi.puntosNivel += 25
						else:
							#print("meh")
							cupi.puntosNivel += 10
						cooldown = 0.1
					else:
						#print("mal")
						cupi.errores += 1
						if cupi.errores > 50:
							cupi.puntosNivel -= 350
						elif cupi.errores > 35:
							cupi.puntosNivel -= 275
						elif cupi.errores > 20:
							cupi.puntosNivel -= 200
						elif cupi.errores > 10:
							cupi.puntosNivel -= 150
						else:
							cupi.puntosNivel -= 100
						cupi.puntosNivel = max(0,cupi.puntosNivel)
						cooldown = 0.1
				
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
	if timeLerp <= 0 and not isSpiral and cupi.TimeMultiplier > 0 :
		# Normalizar ángulos entre 0 y 360
		
		var diferencia = abs(rad_to_deg(controladorGeneral.rotation) - fmod(angle,360))
		var shortest_diff = min(diferencia, 360 - diferencia)
		
		# Verificar si está dentro de la cobertura
		if shortest_diff <= cupi.cobertura / 2.0:
			if shortest_diff <= (cupi.cobertura / 2.0)*0.25:
				#print("perfecto")
				cupi.puntosNivel += 100
			elif shortest_diff <= (cupi.cobertura / 2.0)*0.50:
				#print("bien")
				cupi.puntosNivel += 50
			elif shortest_diff <= (cupi.cobertura / 2.0)*0.75:
				#print("normal")
				cupi.puntosNivel += 25
			else:
				#print("meh")
				cupi.puntosNivel += 10
		else:
			#print("mal")
			cupi.errores += 1
			if cupi.errores > 50:
				cupi.puntosNivel -= 750
			elif cupi.errores > 35:
				cupi.puntosNivel -= 500
			elif cupi.errores > 20:
				cupi.puntosNivel -= 400
			elif cupi.errores > 10:
				cupi.puntosNivel -= 275
			else:
				cupi.puntosNivel -= 120
			cupi.puntosNivel = max(0,cupi.puntosNivel)
			cupi.ralentizar()
			
		#print(baseStrumTime)
		#elimina objeto y aplica los cambios que necesita
		cupiContainer.cupiBeat()
		#cupi.cupiMouth.frame=expresionContain
		cupi.BgBeat()
		queue_free()
		duracionBala = 0.1
		cupi.BulletDestroy(self)
