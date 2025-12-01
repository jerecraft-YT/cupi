extends Label

signal showMenu

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if Input.is_anything_pressed():
		showMenu.emit()
		set_process(false)
