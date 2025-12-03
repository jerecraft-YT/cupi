extends RichTextLabel

signal showMenu
var cambiarEscena = false
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if Input.is_anything_pressed() and cambiarEscena == false:
		showMenu.emit()
		cambiarEscena = true
