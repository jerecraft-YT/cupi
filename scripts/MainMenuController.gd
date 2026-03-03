extends Node2D
class_name MainMenu

var niveles:Array
var pickRandomMusic = true
var MusicSelected:int
var musicaPick:String
var prevMusic:int
var mainScreenActive:bool = true

@export var ampMusicItem:float = 1350
@export var animatedItems:bool = false
@export var objectiveAmpMusic:float = 550
@export var YCOS = 0.5
@export var XCOS:float = 1
@export var MusicItem:PackedScene
@onready var MusicasContainer = $Musicas
@export var audio:AudioStreamPlayer
@export var rotacion:float = 0
@export var fixedRotacion:float
var separacionAngleMusicItem = 1
var numberMusicItem = 16
var angulosMusic:float = 60
var midleAngulos:float = angulosMusic/2
var vueltas:float
var offsetMusic
var musicLoaded = false
var pasoMusic = angulosMusic/numberMusicItem
var detectarOffset:bool = false
var offsetMouse:float
var lastMousePos: Vector2
var sensitivity: float = 0.1
var aceleracion:float
var prevAngle:float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	niveles = getLevels()
	prevMusic = randi_range(0,niveles.size()-1)
	if pickRandomMusic == true:
		randomMusic()

func randomMusic():
	musicLoaded = false
	while true:
		MusicSelected = randi_range(0,niveles.size()-1)
		if MusicSelected != prevMusic:
			break
	prevMusic = MusicSelected
	#vueltas = MusicSelected
	loadMusic()

func changeMusic(mus):
	musicLoaded = false
	MusicSelected = mus
	prevMusic = MusicSelected
	loadMusic()
	

func SpawnLevels():
	for child in MusicasContainer.get_child_count():
		MusicasContainer.get_child(child).queue_free()
	vueltas = -MusicSelected
	for i in range(numberMusicItem):
		var itemLevel:ItemMusic = MusicItem.instantiate()
		MusicasContainer.add_child(itemLevel)
		itemLevel.ID_Item = i
		#print(i)
		itemLevel.name = "musicItem|"+str(i)
		itemLevel.PantallaTitulo = self
		itemLevel.position.x = 1000
		@warning_ignore("integer_division")
		itemLevel.ID_ItemView = i- int(numberMusicItem / 2)
		itemLevel.UpdateData()
	DataGame.levelName = str(niveles[MusicSelected]).left(-1)
	animatedItems = true
	
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
			#print("Loading Music resource")
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
			#print("Loading Music resource")
		else:
			randomMusic()
			
@warning_ignore("unused_parameter")
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		randomMusic()

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	#RenderingServer.viewport_set_clear_mode(get_viewport().get_viewport_rid(),RenderingServer.VIEWPORT_CLEAR_NEVER)
	offsetMusic = (rotacion+(pasoMusic/2))/pasoMusic
	#print(fmod(rotacion/pasoMusic,1))
	
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if animatedItems == true :
		ampMusicItem = lerp(ampMusicItem,objectiveAmpMusic,0.1*DataGame.time_fixed)
	else:
		ampMusicItem = lerp(ampMusicItem,1350.0,0.1*DataGame.time_fixed)
	
	if mainScreenActive:
		moveLevels()
		
	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		rotacion += aceleracion*DataGame.time_fixed
		aceleracion = lerp(aceleracion,0.0,0.1*DataGame.time_fixed)
		#print(aceleracion)
		# Detener detección
		detectarOffset = false
		#print(ceil(rotacion / pasoMusic))
		if aceleracion < 0.1 and aceleracion > -0.1:
			aceleracion = 0
			if rotacion > pasoMusic/2:
				rotacion = lerp(rotacion,pasoMusic,0.1*DataGame.time_fixed)
			elif rotacion < -pasoMusic/2:
				rotacion = lerp(rotacion,-pasoMusic,0.1*DataGame.time_fixed)
			else:
				rotacion = lerp(rotacion,0.0,0.1*DataGame.time_fixed)
	
	if rotacion >= pasoMusic-0.1:
		vueltas += 1
		rotacion -= pasoMusic
	elif rotacion <= -pasoMusic+0.1:
		vueltas -= 1
		rotacion += pasoMusic
		
	fixedRotacion = rotacion	
	if musicLoaded == false:
		GetMusic()
		
	
func moveLevels():
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
func GetMusic():
	if ResourceLoader.load_threaded_get_status(DataGame.direccionNiveles+niveles[MusicSelected]+"/mainMusic/"+musicaPick) == ResourceLoader.THREAD_LOAD_LOADED:
		var musica = ResourceLoader.load_threaded_get(DataGame.direccionNiveles+niveles[MusicSelected]+"/mainMusic/"+musicaPick)
		#print("getting Music resource")
		if musica:
			musica.loop = true
			audio.stream = musica
			audio.play()
			musicLoaded = true

func _on_audio_stream_player_finished() -> void:
	if pickRandomMusic == true:
		randomMusic()

func _on_comenzar_show_menu() -> void:
	call_deferred("SpawnLevels")
	#SpawnLevels()
