extends Button

var cargar = false
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if cargar == true:
		if ResourceLoader.load_threaded_get_status("res://scenes/Level.tscn") == ResourceLoader.THREAD_LOAD_LOADED:
			var scene = ResourceLoader.load_threaded_get("res://scenes/Level.tscn")
			if scene:
				get_tree().change_scene_to_packed(scene)
			set_process(false)

func _on_pressed() -> void:
	ResourceLoader.load_threaded_request("res://scenes/Level.tscn")
	cargar = true
