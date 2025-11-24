extends Node2D

@export var cupi:Node2D
@export var cupiContainer:Node2D
@export var line:Line2D
@onready var BG = get_tree().get_first_node_in_group("BG")
var wave_amp = 0.025

var trozo:PackedScene = load("res://prefabs/trozo_shield.tscn")
var particulasBullet:PackedScene = load("res://prefabs/particulas_destruir_bullet.tscn")

#ASTRID paso por aca 22/10/2025 y eta punto del colapso mental uwu
#variable que se puede acceder desde el editor :P
@export var levelMusic:AudioStreamPlayer
@export var barBeat0Player:AudioStreamPlayer
@export var barBeat1Player:AudioStreamPlayer
@onready var slider = get_tree().get_first_node_in_group("slider")
@onready var controladorGeneral = get_tree().get_first_node_in_group("controlador")
@onready var bg3d:MeshInstance3D = get_tree().get_first_node_in_group("Bg3D")
#variables del shield
@export var amp:float = 35
var actual_angle:float
var number_points:int = 16
var cobertura:float = 60

#variables para el beat
var time:float
var TimeScene:float
var timeBPM:float
var convertedBPM:float
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
				levelMusic.stream = normalMusic
			else:
				levelMusic.stream = reverseMusic

			levelMusic.play()
			levelMusic.seek((levelMusic.stream.get_length() - previewPlayBackPos))
	get:
		return TimeMultiplier

##beat values
var chartData:JSON = loadJSON()

var beat:int = 0
var beatStartTime:float = 0

##gameplay values
var velShield:float = 10
var musicNormalOrInverted:bool = true
var musicChangeApply=true
var previewPlayBackPos:float
var normalMusic:AudioStream
var reverseMusic:AudioStream
var bpm:float = chartData.data.bpm
var rng = RandomNumberGenerator.new()
@onready var lineScale:float

func _ready() -> void:
	DataGame.loadCupi()
	
	loadSong()

	#generar circulo al inicio de la escena
	createcircle()
	
	# Reproducir música a la vez que el beat
	levelMusic.play()
	beatStartTime = TimeScene # Tiempo de marca actual
	
func loadSong():
	normalMusic = load("res://music/StandartMusic/daidaidaikirai.ogg")
	reverseMusic = load("res://music/ReverseMusic/daidaidaikiraiReverse.ogg")
	
func get_song_time() -> float:
	return TimeScene - beatStartTime

func loadJSON():
	var data = load("res://charts/daidaidaikirai.json")
	return(data)

func _process(delta: float) -> void:
	line.scale = Vector2.ONE*cupiContainer.lineScale
	if controladorGeneral != null:
		line.rotation = controladorGeneral.rotation
	convertedBPM = bpm*TimeMultiplier

	timeBPM += delta*abs(TimeMultiplier)

	if timeBPM >= abs(60 / convertedBPM):
		timeBPM -= abs(60 / convertedBPM)
		if beat % 4 == 0:
			# beat 0 significa el inicio de una marca, las marcas duran 4 beats
			# (en time signature 4/4)
			barBeat0Player.play()
			#BgBeat()
			WAVEBEAT()
			#cupiBeat(time)
		else:
			# beat 1 al 3, fin de marca
			barBeat1Player.play()
			#BgBeat()
			WAVEBEAT()
			#cupiBeat(time)
		beat += 1
		
		# Sincronizarrrrrr
		var song_time = get_song_time()
		#print(song_time)
		if song_time > 0 and abs(song_time - (levelMusic.get_playback_position() + AudioServer.get_time_since_last_mix())) >= 1.0/120.0 and musicNormalOrInverted:
			# Sincronizar si está atrasado por 8 milisegundos
			levelMusic.seek(song_time / 1000.0) # este espera tiempo en decimal, no enteros
			pass
	
	TimeScene += (delta * TimeMultiplier) * 1000.0
	TimeScene = max(0,TimeScene)
	levelMusic.pitch_scale = max(0.001,abs(TimeMultiplier))
	
	
func WAVEBEAT():
	wave_amp = 0.05
	
func BulletDestroy(bullet):
		var particles:GPUParticles2D = particulasBullet.instantiate()
		add_child(particles)
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
		particles.rotation = bullet.angle

func BgBeat():
	pass
	#bg3d.beat()

func createcircle():
	#limpiar puntos de shield
	line.clear_points()
	
	for i in range(number_points):
		
		#crear puntos en orden en forma de circulo
		actual_angle = (float(i)*(cobertura/number_points))-(cobertura/2.0)
		line.add_point(Vector2(cos(deg_to_rad( actual_angle))*amp,sin(deg_to_rad(actual_angle))*amp),i)
