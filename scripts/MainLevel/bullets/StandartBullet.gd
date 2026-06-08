extends Node2D 
class_name CupiBullet

@onready var cupi:Cupi
@export var nota:Sprite2D
@onready var spawner:BulletSpawner
@onready var cupiContainer:CupiContainer
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
var circularAttack:CupiSpiral
var notifyBot:bool = false
var usableParaBot:bool = false
var trail_positions:Array[Vector2] = []
const TRAIL_LENGTH = 14
var trail_timer = 0.0
var trail_maxTime = 0.15


func _ready() -> void:
	position = Vector2.ONE * 1000

func _draw() -> void:


	if nota == null or nota.texture == null:
		return

	draw_set_transform(Vector2.ZERO - (nota.texture.get_size() / 2.0 * 0.14), 0.0, Vector2.ONE * 0.14)

	for i in range(trail_positions.size()):

		var t := float(i) / float(TRAIL_LENGTH)

		# Desaparece rápidamente
		var alpha := pow(1.0 - t, 2.0) * 0.5

		var local_pos := to_local(trail_positions[i])

		draw_texture(
			nota.texture,
			local_pos - Vector2.ONE * 2.0,
			Color(1.0, 1.0, 1.0, alpha)
		)

	# Bala principal
	draw_texture(
		nota.texture,
		Vector2.ONE * -2.0,
		Color.WHITE
	)
	
func _process(delta: float) -> void:
	trail_maxTime = DataGame.velocidadNotas /3.0 * DataGame.multiplicadorVelocidad / 2.0
	
	rotation = deg_to_rad(cupiContainer.faceAngle * 3)
	
	var currentTime = cupi.get_song_time()
	cooldown = max(0, cooldown - delta * cupi.TimeMultiplier)
	if isSpiral and spiralStart:
		usableParaBot = true
		angle = circularAttack.anguloFinal + circularAttack.AngleFinal
	if !isSpiral:
		usableParaBot = true
	timeLerp = min(1.0,max(0, 1.0 - inverse_lerp(baseSpawnTime, baseStrumTime, currentTime)))
	if timeLerp > 0.9 and cupi.TimeMultiplier < 0:
		notifyBot = false
		
	if timeLerp < 0.9 and !notifyBot and usableParaBot:
		if isSpiral:
			cupi.notifyBot(circularAttack.AngleStart,baseStrumTime)
		else:
			cupi.notifyBot(angle,baseStrumTime)
		notifyBot = true
		
	amp = distance * timeLerp * spawner.speed
	ampSpiral = distance * timeLerp
	ampSpiral += 35
	amp += 35
	position = Vector2(spawner.position.x + cos(deg_to_rad(angle)) * amp, spawner.position.y + sin(deg_to_rad(angle)) * amp)
	
	trail_timer += delta
	
	if trail_timer > trail_maxTime:
		trail_timer = 0.0
		trail_positions.push_front(global_position)

		if trail_positions.size() > TRAIL_LENGTH:
			trail_positions.pop_back()
	queue_redraw()
	
	bulletHit(delta)
	
func bulletHit(delta):
	if timeLerp > 0:
		visible = true
		if isSpiral and spiralStart:
			startDestroy = false
	if timeLerp <= 0 and cupi.TimeMultiplier > 0 and isSpiral and spiralStart and circularAttack.bulletFinal.visible == true:
		if cupi.cupiBot:
			controladorGeneral.rotation = deg_to_rad(angle)
	
	if timeLerp <= 0 and cupi.TimeMultiplier > 0 and visible == true:
		
		if isSpiral and spiralStart and !startDestroy:
				duracionBala = circularAttack.calc / 1000.0
				startDestroy = true
				var trail := BulletTrail.new()
				
				trail.global_position = position
				trail.positions = trail_positions.duplicate()
				trail.texture = nota.texture
				trail.life = 0.5

				get_parent().get_parent().add_child(trail)
				
				cupi.BulletDestroy(self)
		
		if cupi.cupiBot and !isSpiral:
			controladorGeneral.rotation = deg_to_rad(angle)
		
		var diferencia = abs(rad_to_deg(controladorGeneral.rotation) - fmod(angle, 360))
		var shortest_diff = min(diferencia, 360 - diferencia)
		deathcooldown += delta
		
		# Verificar si está dentro de la cobertura
		if shortest_diff <= cupi.cobertura / 2.0 and shortest_diff >= -cupi.cobertura / 2.0:
			visible = false
			# ACIERTO
			spawner.addToCombo()
			cupiContainer.niceHit()
			if shortest_diff <= (cupi.cobertura / 2.0) * 0.35:
				cupi.puntosNivel += 100
				DataGame.notasPerfectas += 1
			elif shortest_diff <= (cupi.cobertura / 2.0) * 0.65:
				cupi.puntosNivel += 50
				DataGame.notasBuenas += 1
			else:
				cupi.puntosNivel += 25
				DataGame.notasNormales += 1
			#cupi.BgBeat()
			#cupiContainer.cupiBeat()
			
			if isSpiral and !spiralStart:
				var trail := BulletTrail.new()
				
				trail.global_position = position
				trail.positions = trail_positions.duplicate()
				trail.texture = nota.texture
				trail.life = 0.5

				get_parent().get_parent().add_child(trail)
				
				cupi.bulletHit()
			
			if not isSpiral:
				#print("tiempo actual: " + str(cupi.get_song_time()) + "| tiempo a llegar: " + str(baseStrumTime))
				duracionBala = 0.1
				var trail := BulletTrail.new()
				
				trail.global_position = position
				trail.positions = trail_positions.duplicate()
				trail.texture = nota.texture
				trail.life = 0.5

				get_parent().get_parent().add_child(trail)
				cupi.BulletDestroy(self)
		
		# ERROR - Solo después del deathcooldown
		if deathcooldown > 0.1 and visible == true:
			spawner.restartCombo()
			cupiContainer.error()
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
			var trail := BulletTrail.new()
			
			trail.global_position = position
			trail.positions = trail_positions.duplicate()
			trail.texture = nota.texture
			trail.life = 0.5

			get_parent().get_parent().add_child(trail)
			cupi.ralentizar()
