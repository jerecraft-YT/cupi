extends RichTextLabel

signal showMenu
var cambiarEscena = false
@export var boton1:Button
@export var boton2:Button
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if Input.is_anything_pressed() and cambiarEscena == false:
		showMenu.emit()
		cambiarEscena = true
		await get_tree().create_timer(0.25).timeout 
		boton1.disabled = false
		boton2.disabled = false
		
