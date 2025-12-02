extends Control

func _ready() -> void:
	ResourceLoader.load_threaded_request("res://scenes/Pantalla_Titulo.tscn")
	
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if ResourceLoader.load_threaded_get_status("res://scenes/Pantalla_Titulo.tscn") == ResourceLoader.THREAD_LOAD_LOADED:
		var scene = ResourceLoader.load_threaded_get("res://scenes/Pantalla_Titulo.tscn")
		if scene:
			await get_tree().create_timer(0.25).timeout 
			get_tree().change_scene_to_packed(scene)
		set_process(false)
