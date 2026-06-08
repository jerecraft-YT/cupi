extends Node

var documentos = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
var mainConfig = FileAccess.open("user://config.cfg",FileAccess.WRITE_READ)
var time_fixed:float
var cupi:Cupi
var puntos:float
var puntosMaximos:float
var errores:int
var comboMaximo:int
var multiplicadorVelocidad:float = 1.0
var velocidadNotas:float
var regularVoz:bool
var regularCambiado:bool
var notasPerfectas:int
var notasNormales:int
var notasBuenas:int
var direccionNiveles:String = "res://Niveles/"
var musicFile:String
var resourceBackgroundLevel:String
var tipeResourceBackgroundLevel:String
var chartData
var bpm
var levelName:String = ""
var Music
var datalevel
var resourceLevel
var loadElements = false
var musicLoaded = false
var JSONLoaded = false
var resourceLoaded = false
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
	resourceBackgroundLevel = detectResourceFile()
	loadElements = true
	ResourceLoader.load_threaded_request(direccionNiveles+levelName+"/mainMusic/"+musicFile)
	ResourceLoader.load_threaded_request(direccionNiveles+levelName+"/chart.json")
	if (!resourceBackgroundLevel.is_empty()):
		ResourceLoader.load_threaded_request(direccionNiveles+levelName+"/resources/"+resourceBackgroundLevel)
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

func detectResourceFile() -> String:
	#print(ResourceLoader.list_directory(direccionNiveles+levelName+"/mainMusic"))
	
	if detectarCarpetasExternas == true:
		var archivos = DirAccess.get_files_at(direccionNiveles+levelName+"/resources")
		for archivo in archivos:
			if archivo.right(4) == ".ogv":
				return archivo
		print("no hay recursos")
	else:
		var archivos = ResourceLoader.list_directory(direccionNiveles+levelName+"/resources")
		for archivo in archivos:
			if archivo.right(4) == ".ogv":
				print("archivo de video encontrado")
				tipeResourceBackgroundLevel = "video"
				return archivo
			if archivo.right(4) == ".png" or archivo.right(4) == ".jpg":
				print("archivo de imagen encontrado")
				tipeResourceBackgroundLevel = "imagen"
				return archivo
		print("no hay recursos")
	return ""

func _process(delta: float) -> void:
	if regularVoz:
		if !regularCambiado:
			regularCambiado = true
		AudioServer.get_bus_effect(1,0).set("pitch_scale",abs(2 - multiplicadorVelocidad))
	elif !regularVoz and regularCambiado:
		regularCambiado = false
		AudioServer.get_bus_effect(1,0).set("pitch_scale",1.0)
		
	if loadElements == true:
		if musicLoaded == false:
			loadSong()
		if JSONLoaded == false:
			loadJSON()
		if resourceLoaded == false:
			loadResource()
	time_fixed = delta*60

func loadCupi() -> Cupi:
	cupi = get_tree().get_first_node_in_group("cupi")
	return cupi

func loadSong() -> void:
	if ResourceLoader.load_threaded_get_status(direccionNiveles+levelName+"/mainMusic/"+musicFile) == ResourceLoader.THREAD_LOAD_LOADED:
		Music = ResourceLoader.load_threaded_get(direccionNiveles+levelName+"/mainMusic/"+musicFile)
		if Music:
			Music.loop = false
			print("la Musica Cargo")
			musicLoaded = true

func loadResource() -> void:
	if ResourceLoader.load_threaded_get_status(direccionNiveles+levelName+"/resources/"+resourceBackgroundLevel) == ResourceLoader.THREAD_LOAD_LOADED:
		resourceLevel = ResourceLoader.load_threaded_get(direccionNiveles+levelName+"/resources/"+resourceBackgroundLevel)
		if resourceLevel:
			print("el recurso Cargo")
			resourceLoaded = true

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
