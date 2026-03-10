extends Panel
class_name ItemMusic

var ID_Item:int
var ID_ItemView:int
var PantallaTitulo:MainMenu
@onready var Autor:Label = $Autor
@onready var Name:Label = $Name
@onready var panel:Panel = self
var prevVueltas:float = -1
var newID:int
var progresoScale:float = 1

func UpdateData():
	Name.text = str(PantallaTitulo.niveles[fmod(ID_ItemView-PantallaTitulo.vueltas,PantallaTitulo.niveles.size())]).left(-1)
	Autor.text = str("Autor")
	prevVueltas = PantallaTitulo.vueltas

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if prevVueltas != PantallaTitulo.vueltas:
		UpdateData()
	newID = ID_Item + PantallaTitulo.offsetMusic
	position = Vector2(	cos(
							deg_to_rad	(
								(ID_Item*(PantallaTitulo.angulosMusic/PantallaTitulo.numberMusicItem))
								+PantallaTitulo.fixedRotacion-PantallaTitulo.midleAngulos
										)
							)
							*PantallaTitulo.ampMusicItem-220*PantallaTitulo.XCOS,
						sin(
							deg_to_rad	(
								(ID_Item*(PantallaTitulo.angulosMusic/PantallaTitulo.numberMusicItem))
								+PantallaTitulo.fixedRotacion-PantallaTitulo.midleAngulos
										)
							)
							*PantallaTitulo.ampMusicItem*PantallaTitulo.YCOS
						)
						
	rotation = deg_to_rad((ID_Item*(PantallaTitulo.angulosMusic/PantallaTitulo.numberMusicItem))+PantallaTitulo.fixedRotacion-PantallaTitulo.midleAngulos)
	
	progresoScale = 1-min(abs(rotation_degrees),PantallaTitulo.pasoMusic*5)/(PantallaTitulo.pasoMusic*5)
	scale = Vector2(max(progresoScale,0.65),max(progresoScale,0.65))
	modulate = Color(progresoScale,progresoScale,progresoScale)
	if progresoScale >0.85:
		z_index = 2
	elif progresoScale >0.15:
		z_index = 1
	else:
		z_index = 0
	if progresoScale > 0.95:
		if PantallaTitulo.niveles[fmod(ID_ItemView-PantallaTitulo.vueltas,PantallaTitulo.niveles.size())] != PantallaTitulo.niveles[PantallaTitulo.MusicSelected]:
			PantallaTitulo.changeMusic(fmod(ID_ItemView-PantallaTitulo.vueltas,PantallaTitulo.niveles.size()))
			DataGame.levelName = str(PantallaTitulo.niveles[fmod(ID_ItemView-PantallaTitulo.vueltas,PantallaTitulo.niveles.size())]).left(-1)
