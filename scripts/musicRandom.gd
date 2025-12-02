extends Node2D


var niveles:Array
var pickRandomMusic = true
var MusicSelected:int
var musicaPick:String
var prevMusic:int
@export var audio:AudioStreamPlayer
var musicLoaded = false
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
func _process(delta: float) -> void:
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
