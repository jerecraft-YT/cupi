extends Button

var cargar = false
var sceneLoaded = false
var scene = null
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if cargar == true:
		loadLevel()
	if DataGame.musicLoaded == true and DataGame.JSONLoaded == true and sceneLoaded == true:
		await get_tree().create_timer(1.0).timeout 
		get_tree().change_scene_to_packed(scene)
		
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
