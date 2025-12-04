extends Node2D
class_name MainMenu

var niveles:Array
var pickRandomMusic = true
var MusicSelected:int
var musicaPick:String
var prevMusic:int

var ampMusicItem = 550
var separacionAngleMusicItem = 1
@export var YCOS = 0.5
@export var XCOS:float = 1
var numberMusicItem = 32
@export var MusicItem:PackedScene
@onready var boton = $Button
@onready var MusicasContainer = $Musicas
@export var audio:AudioStreamPlayer
@export var rotacion:float = 0
@export var fixedRotacion:float
var vueltas:float
var offsetMusic
var musicLoaded = false
var pasoMusic = 360.0/numberMusicItem
var detectarOffset:bool = false
var offsetMouse:float
var lastMousePos: Vector2
var sensitivity: float = 0.1
var aceleracion:float
var prevAngle:float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Pantalla Titulo")
	niveles = getLevels()
	prevMusic = randi_range(0,niveles.size()-1)
	if pickRandomMusic == true:
		pass
		randomMusic()

func randomMusic():
	musicLoaded = false
	while true:
		MusicSelected = randi_range(0,niveles.size()-1)
		if MusicSelected != prevMusic:
			break
	prevMusic = MusicSelected
	loadMusic()

func SpawnLevels():
	for child in MusicasContainer.get_child_count():
		MusicasContainer.get_child(child).queue_free()
	for i in range(numberMusicItem):
		var itemLevel:ItemMusic = MusicItem.instantiate()
		MusicasContainer.add_child(itemLevel)
		itemLevel.ID_Item = i
		#print(i)
		itemLevel.name = "musicItem|"+str(i)
		itemLevel.PantallaTitulo = self

func getLevels():
	if DataGame.detectarCarpetasExternas == true:
		return DirAccess.get_directories_at(DataGame.direccionNiveles)
	else:
		return ResourceLoader.list_directory(DataGame.direccionNiveles)

func loadMusic():
	if DataGame.detectarCarpetasExternas == true:
		var archivos = DirAccess.get_files_at(DataGame.direccionNiveles+niveles[MusicSelected]+"/mainMusic")
		var found = false
		for archivo in archivos:
			if archivo.right(4) == ".ogg" or archivo.right(4) == ".mp3" or archivo.right(4) == ".wav":
				musicaPick = archivo
				found = true
				break
		if found == true:
			ResourceLoader.load_threaded_request(DataGame.direccionNiveles+niveles[MusicSelected]+"/mainMusic/"+musicaPick)
			print("Loading Music resource")
		else:
			randomMusic()
	else:
		var archivos = ResourceLoader.list_directory(DataGame.direccionNiveles+niveles[MusicSelected]+"/mainMusic")
		var found = false
		for archivo in archivos:
			if archivo.right(4) == ".ogg" or archivo.right(4) == ".mp3" or archivo.right(4) == ".wav":
				musicaPick = archivo
				found = true
				break
		if found == true:
			ResourceLoader.load_threaded_request(DataGame.direccionNiveles+niveles[MusicSelected]+"/mainMusic/"+musicaPick)
			print("Loading Music resource")
		else:
			randomMusic()
			
@warning_ignore("unused_parameter")
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		randomMusic()

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	offsetMusic = (rotacion+(pasoMusic/2))/pasoMusic
	#print(fmod(rotacion/pasoMusic,1))
	
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	var anguloCercano = fmod(rotacion/pasoMusic,1)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and detectarOffset == false:
		# Iniciar detección
		detectarOffset = true
		lastMousePos = get_viewport().get_mouse_position()
		offsetMouse = lastMousePos.y
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and detectarOffset:
		var currentMousePos = get_viewport().get_mouse_position()
		
		# Calcular diferencia desde la última posición
		var deltaY:float = currentMousePos.y - lastMousePos.y
		
		# Aplicar rotación con sensibilidad
		rotacion += deltaY * sensitivity
		if prevAngle == rotacion:
			aceleracion = 0
			
		if prevAngle != rotacion:
			aceleracion = rotacion - prevAngle
			prevAngle = rotacion

		#print(aceleracion)
		# Guardar posición actual para el siguiente frame
		lastMousePos = currentMousePos
	
	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		rotacion += aceleracion
		aceleracion = lerp(aceleracion,0.0,0.1*DataGame.time_fixed)
		#print(aceleracion)
		# Detener detección
		detectarOffset = false
		#print(ceil(rotacion / pasoMusic))
		if aceleracion < 0.1 and aceleracion > -0.1:
			aceleracion = 0
			if anguloCercano > 0.5:
				rotacion = lerp(rotacion,ceil(rotacion / pasoMusic)*pasoMusic,0.1)
			elif anguloCercano < -0.5:
				rotacion = lerp(rotacion,floor(rotacion / pasoMusic)*pasoMusic,0.1)
			else:
				rotacion = lerp(rotacion,floor(rotacion / pasoMusic)*pasoMusic,0.1)
	fixedRotacion = fmod(rotacion,pasoMusic)
	if rotacion > 0:
		vueltas = floor(rotacion / pasoMusic)
	else:
		vueltas = ceil(rotacion / pasoMusic)
		
		#rotacion = lerp(rotacion,vueltas*pasoMusic,0.1)
	#print(get_child_count(true))
	if musicLoaded == false:
		pass
		GetMusic()

func GetMusic():
	if ResourceLoader.load_threaded_get_status(DataGame.direccionNiveles+niveles[MusicSelected]+"/mainMusic/"+musicaPick) == ResourceLoader.THREAD_LOAD_LOADED:
		var musica = ResourceLoader.load_threaded_get(DataGame.direccionNiveles+niveles[MusicSelected]+"/mainMusic/"+musicaPick)
		print("getting Music resource")
		if musica:
			audio.stream = musica
			audio.play()
			musicLoaded = true

func _on_audio_stream_player_finished() -> void:
	randomMusic()


func _on_comenzar_show_menu() -> void:
	SpawnLevels()
