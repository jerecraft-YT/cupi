extends Button

var cargar = false
var sceneLoaded = false
var scene = null
@export var boton2:Button
signal load(scenaLoad)
@export var pantallaTitulo:MainMenu
@export var externalLoad = false

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if cargar == true:
		loadLevel()
	if DataGame.musicLoaded == true and DataGame.JSONLoaded == true and sceneLoaded == true:
		pantallaTitulo.animatedItems = false
		await get_tree().create_timer(1.0).timeout
		print(DataGame.levelName)
		if externalLoad == false:
			if scene != null:
				get_tree().change_scene_to_packed(scene)
		else:
			load.emit(scene)
		
func loadLevel():
	if ResourceLoader.load_threaded_get_status("res://scenes/Level.tscn") == ResourceLoader.THREAD_LOAD_LOADED:
		scene = ResourceLoader.load_threaded_get("res://scenes/Level.tscn")
		print("getting level resource")
		if scene:
			sceneLoaded = true
			cargar = false

func _on_pressed() -> void:
	ResourceLoader.load_threaded_request("res://scenes/Level.tscn")
	print("Loading Level resource")
	DataGame.loadLevelElements()
	cargar = true
	disabled = true
	boton2.disabled = true


func _on_button_2_pressed() -> void:
	ResourceLoader.load_threaded_request("res://scenes/Level.tscn")
	print("Loading Level resource")
	DataGame.loadLevelElements()
	cargar = true
	disabled = true
	boton2.disabled = true
