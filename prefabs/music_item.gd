extends Node2D
class_name ItemMusic

var ID_Item:int
var PantallaTitulo:MainMenu
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	position = Vector2(cos(deg_to_rad(ID_Item*(360.0/PantallaTitulo.numberMusicItem)))*PantallaTitulo.ampMusicItem-220,sin(deg_to_rad(ID_Item*(360.0/PantallaTitulo.numberMusicItem)))*PantallaTitulo.ampMusicItem*PantallaTitulo.YCOS)
	rotation = deg_to_rad(ID_Item*(360.0/PantallaTitulo.numberMusicItem))
