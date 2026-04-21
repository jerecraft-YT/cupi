extends Node

var documentos = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
var mainConfig = FileAccess.open("user://config.cfg",FileAccess.WRITE_READ)
var time_fixed:float
var cupi:Cupi
var direccionNiveles:String = "res://Niveles/"
var musicFile:String
var chartData
var bpm
var levelName:String = ""
var Music
var datalevel
var loadElements = false
var musicLoaded = false
var JSONLoaded = false
var pcos:PackedFloat32Array = []

@export var detectarCarpetasExternas:bool = false

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(documentos+"/CUPI/Levels")
	#var levels = DirAccess.open()
	if FileAccess.file_exists("user://config.cfg"):
		print("funciono")
	else:
		print(":(")
	precalCOS()

func loadLevelElements():
	musicFile = detectMusicFile()
	loadElements = true
	ResourceLoader.load_threaded_request(direccionNiveles+levelName+"/mainMusic/"+musicFile)
	ResourceLoader.load_threaded_request(direccionNiveles+levelName+"/chart.json")
	#chartData = loadJSON()
	#bpm = datalevel.data.bpm
	#loadSong()
	
func detectMusicFile() -> String:
	#print(ResourceLoader.list_directory(direccionNiveles+levelName+"/mainMusic"))
	
	if detectarCarpetasExternas == true:
		var archivos = DirAccess.get_files_at(direccionNiveles+levelName+"/mainMusic")
		for archivo in archivos:
			if archivo.right(4) == ".ogg" or archivo.right(4) == ".mp3" or archivo.right(4) == ".wav":
				return archivo
	else:
		var archivos = ResourceLoader.list_directory(direccionNiveles+levelName+"/mainMusic")
		for archivo in archivos:
			if archivo.right(4) == ".ogg" or archivo.right(4) == ".mp3" or archivo.right(4) == ".wav":
				return archivo
	return ""

func _process(delta: float) -> void:
	if loadElements == true:
		if musicLoaded == false:
			loadSong()
		if JSONLoaded == false:
			loadJSON()
			
	time_fixed = delta*60

func loadCupi() -> Cupi:
	cupi = get_tree().get_first_node_in_group("cupi")
	return cupi

func loadSong() -> void:
	if ResourceLoader.load_threaded_get_status(direccionNiveles+levelName+"/mainMusic/"+musicFile) == ResourceLoader.THREAD_LOAD_LOADED:
		Music = ResourceLoader.load_threaded_get(direccionNiveles+levelName+"/mainMusic/"+musicFile)
		if Music:
			print("la Musica Cargo")
			musicLoaded = true

func loadJSON() -> void:
	if ResourceLoader.load_threaded_get_status(direccionNiveles+levelName+"/chart.json") == ResourceLoader.THREAD_LOAD_LOADED:
		datalevel = ResourceLoader.load_threaded_get(direccionNiveles+levelName+"/chart.json")
		if datalevel:
			print("El JSON cargo")
			JSONLoaded = true
			bpm = datalevel.data.bpm
			
var MAXANGLE = 360

func precalCOS():
	
	pcos.resize(MAXANGLE+1)
	
	for i in range(pcos.size()):
		pcos[i] = cos(deg_to_rad(i))

func getCOS(getAngle:float):
	getAngle = wrapf(getAngle , 0.0 , 360.0)
	
	var decimalPart = getAngle - int(getAngle)
	var angle = pcos[floor(getAngle)]
	
	if decimalPart == 0:
		return angle
	else:
		var topAngle = pcos[ceil(getAngle)]
		
		return lerp(angle,topAngle,decimalPart)
