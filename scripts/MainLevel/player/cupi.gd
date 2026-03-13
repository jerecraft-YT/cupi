class_name Cupi extends Node2D

#signal waveBeat
signal play
signal beat
#ASTRID paso por aca 22/10/2025 y eta punto del colapso mental uwu

@export var cupi:Cupi
@export var cupiContainer:CupiContainer
@export var line:Line2D
@export var levelMusic:AudioStreamPlayer
@export var InverseLevelMusic:ReversableAudioStreamPlayer
@export var barBeat0Player:AudioStreamPlayer
@export var barBeat1Player:AudioStreamPlayer
@export var bulletHitAudio:AudioStreamPlayer
@export var cupiBot:bool
@export var levelName:String
@export var amp:float = 35
@export var timeMultiplierObjective:float = 1.0
@export var TimeMultiplier:float=1.0 :
	set(v):
		TimeMultiplier = v
		# Se llama cada vez que cambia
		##revertir musica
		if TimeMultiplier > 0 and not musicNormalOrInverted:
			musicChangeApply = false
			musicNormalOrInverted = true
		elif TimeMultiplier <= 0 and musicNormalOrInverted:
			musicChangeApply = false
			musicNormalOrInverted = false
		
		if not musicChangeApply:
			musicChangeApply = true
			previewPlayBackPos = levelMusic.get_playback_position()

			if musicNormalOrInverted:
				levelMusic.volume_db = 0
				InverseLevelMusic.volume_db = -80
			else:
				levelMusic.volume_db = -80
				InverseLevelMusic.volume_db = 0

			levelMusic.seek((levelMusic.stream.get_length() - previewPlayBackPos))
			InverseLevelMusic.seek((levelMusic.stream.get_length() - previewPlayBackPos))
	get:
		return TimeMultiplier

@onready var lineScale:float
@onready var controladorGeneral:Node2D = get_tree().get_first_node_in_group("controlador")
@export var cobertura:float = 75:
	set(v):
		cobertura = v
		createcircle()
	get:
		return cobertura

var particulasBullet:PackedScene = load("res://prefabs/particulas_destruir_bullet.tscn")
var actual_angle:float
var puntosNivel:float
var time:float
var TimeScene:float
var timeBPM:float
var convertedBPM:float
var previewPlayBackPos:float
var bpm:float
var wah:float
var beatStartTime:float = 0
var errores:int
var number_points:int = 8
var beatNumber:int = 0
var musicNormalOrInverted:bool = true
var musicChangeApply:bool=true
var normalMusic:AudioStream
var chartData:JSON
var prestartLevel:float
var firstLoad = false

func _ready() -> void:
	DataGame.loadCupi()
	#generar circulo al inicio de la escena
	createcircle()
	# Reproducir música a la vez que el beat
	beatStartTime = TimeScene # Tiempo de marca actual
	
	chartData = DataGame.datalevel
	bpm = chartData.data.bpm
	InverseLevelMusic.bstream = DataGame.Music
	levelMusic.stream = DataGame.Music
	
func get_song_time() -> float:
	return TimeScene - beatStartTime
	
func ralentizar():
	TimeMultiplier = 0.5+(wah*0.15)

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if cupiBot:
		controladorGeneral.rotation += deg_to_rad(2)
	wah = cos(TimeScene*0.025)
	
func _process(delta: float) -> void:
	TimeMultiplier = lerp(TimeMultiplier,timeMultiplierObjective,0.2*DataGame.time_fixed)
	line.scale = Vector2.ONE*cupiContainer.lineScale
	if controladorGeneral != null:
		line.rotation = controladorGeneral.rotation
	convertedBPM = bpm*TimeMultiplier
	
	if firstLoad:
		timeBPM += delta*abs(TimeMultiplier)

	if timeBPM >= abs(60 / convertedBPM):
		timeBPM -= abs(60 / convertedBPM)
		if beatNumber % 4 == 0:
			# beat 0 significa el inicio de una marca, las marcas duran 4 beats
			# (en time signature 4/4)
			barBeat0Player.play()
			beat.emit()
			#BgBeat()
			#waveBeat.emit()
			cupiContainer.cupiBeat()
		else:
			# beat 1 al 3, fin de marca
			barBeat1Player.play()
			#BgBeat()
			#waveBeat.emit()
			cupiContainer.cupiBeat()
			beat.emit()
			
		beatNumber += 1
		#cupiContainer.cupiBeat()
		# Sincronizarrrrrr
		var song_time = get_song_time()
		if song_time > 0 and abs(song_time - (levelMusic.get_playback_position() + AudioServer.get_time_since_last_mix())) >= 1.0/120.0 and musicNormalOrInverted:
			# Sincronizar si está atrasado por 8 milisegundos
			levelMusic.seek(song_time / 1000.0) # este espera tiempo en decimal, no enteros
			#print("sinc")
			pass
			
	prestartLevel += (delta * TimeMultiplier) * 1000.0
	if prestartLevel >= 1500:
		if firstLoad == false:
			play.emit()
			InverseLevelMusic.play()
			levelMusic.play()
			firstLoad = true
		TimeScene += (delta * TimeMultiplier) * 1000.0
	#TimeScene += (delta * TimeMultiplier) * 1000.0
	TimeScene = max(0,TimeScene)
	levelMusic.pitch_scale = max(0.001,abs(TimeMultiplier))
	InverseLevelMusic.playback_rate = TimeMultiplier

func bulletHit():
	bulletHitAudio.play()
	
func BulletDestroy(bullet):
		bulletHit()
		var particles:GPUParticles2D = particulasBullet.instantiate()
		add_child(particles)
		particles.rotation = deg_to_rad(bullet.angle)
		particles.tiempoVida = bullet.duracionBala
		if !bullet.isSpiral:
			particles.one_shot = true
		else:
			particles.bulletStart = bullet
			particles.Dinamic = true
		particles.emitting = true
		var materialparticulas:ParticleProcessMaterial = particles.process_material
		materialparticulas.scale_min = scale.x*1.5
		particles.position = bullet.position

func BgBeat():
	pass
	#bg3d.beat()

func createcircle():
	#limpiar puntos de shield
	line.clear_points()
	
	for i in range(number_points+1):
		
		#crear puntos en orden en forma de circulo
		actual_angle = (float(i)*(cobertura/number_points))-(cobertura/2.0)
		line.add_point(Vector2(cos(deg_to_rad( actual_angle))*amp,sin(deg_to_rad(actual_angle))*amp),i)
