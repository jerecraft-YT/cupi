extends Node2D

@export var videoPlayer:VideoStreamPlayer
@export var texture:TextureRect
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if DataGame.tipeResourceBackgroundLevel == "video":
		videoPlayer.stream = DataGame.resourceLevel
		pass
	if DataGame.tipeResourceBackgroundLevel == "imagen":
		texture.texture = DataGame.resourceLevel
	pass
