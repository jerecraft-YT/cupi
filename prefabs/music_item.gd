extends Node2D
class_name ItemMusic

var ID_Item:int
var PantallaTitulo:MainMenu
@onready var Autor:Label = $Panel/Autor
@onready var Name:Label = $Panel/Name
@onready var panel:Panel = $Panel
var newID:int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	#var total_items = PantallaTitulo.numberMusicItem
	#var MedioItems:int = total_items / 2

	#var relative_position = wrapi(newID, -MedioItems, MedioItems)
	
	newID = ID_Item + PantallaTitulo.offsetMusic
		
	
	Name.text = str(PantallaTitulo.niveles[fmod(ID_Item-PantallaTitulo.vueltas,PantallaTitulo.niveles.size())]).left(-1)
	position = Vector2(cos(deg_to_rad((ID_Item*(360.0/PantallaTitulo.numberMusicItem))+PantallaTitulo.fixedRotacion+180))*PantallaTitulo.ampMusicItem-220*PantallaTitulo.XCOS,sin(deg_to_rad((ID_Item*(360.0/PantallaTitulo.numberMusicItem))+PantallaTitulo.fixedRotacion+180))*PantallaTitulo.ampMusicItem*PantallaTitulo.YCOS)
	rotation = deg_to_rad((ID_Item*(360.0/PantallaTitulo.numberMusicItem))+PantallaTitulo.fixedRotacion+180)
	
	var progresoScale = 1-min(abs(rotation_degrees-360),PantallaTitulo.pasoMusic*5)/(PantallaTitulo.pasoMusic*5)
	Autor.text = str(progresoScale)
	scale = Vector2(max(progresoScale,0.75),max(progresoScale,0.75))
	if progresoScale >0.85:
		z_index = 1
	else:
		z_index = 0
