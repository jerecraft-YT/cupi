extends Node2D

var showMenu:bool = false
var progressAnim:float
@export var titulo:Node2D
@export var comenzar:Node2D
@export var valoresCustom:Control
func _on_comenzar_show_menu() -> void:
	showMenu = true

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if showMenu == true:
		progressAnim = min(1,progressAnim + DataGame.time_fixed*0.05)
		var animprogress = MathFunctions.easeInOutBack(progressAnim)
		position = Vector2(animprogress*-220,0)
		scale = Vector2.ONE * ((animprogress*0.5)+1.5)
		titulo.position = Vector2(titulo.position.x,(animprogress*-230)-180)
		comenzar.position = Vector2(comenzar.position.x,(animprogress*250)+250)
		valoresCustom.position = Vector2((animprogress*300)-300,valoresCustom.position.y)
