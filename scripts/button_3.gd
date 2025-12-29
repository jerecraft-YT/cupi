extends Button
@export var audioDebug:Control
@export var titulo:MainMenu
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_pressed() -> void:
	if audioDebug != null:
		audioDebug.visible = true
		titulo.mainScreenActive = false
	pass # Replace with function body.
