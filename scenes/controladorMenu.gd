extends Node2D

var showMenu:bool = false
var progressAnim:float
func _on_comenzar_show_menu() -> void:
	showMenu = true

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if showMenu == true:
		progressAnim = min(1,progressAnim + DataGame.time_fixed*0.05)
		var animprogress = DataGame.easeInOutBack(progressAnim)
		position = Vector2(animprogress*-220,0)
		scale = Vector2((animprogress*0.5)+2,(animprogress*0.5)+2)
