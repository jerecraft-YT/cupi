extends Node

var direccionNiveles = "res://Niveles/"
var niveles:Array
var pickRandomLevel = true
var levelSelected:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	niveles = loadLevels()
	print(DirAccess.get_directories_at(direccionNiveles).size())
	print()
	if pickRandomLevel == true:
		levelSelected = randi_range(0,niveles.size()-1)

func loadLevels():
	return DirAccess.get_directories_at(direccionNiveles)
