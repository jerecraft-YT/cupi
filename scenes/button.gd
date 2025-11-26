extends Button

var cargar = false
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if cargar == true:
		if ResourceLoader.load_threaded_get_status("res://scenes/test_zone.tscn") == ResourceLoader.THREAD_LOAD_LOADED:
			var scene = ResourceLoader.load_threaded_get("res://scenes/test_zone.tscn")
			if scene:
				get_tree().change_scene_to_packed(scene)
			set_process(false)

func _on_pressed() -> void:
	cargar = true
	ResourceLoader.load_threaded_request("res://scenes/test_zone.tscn")
