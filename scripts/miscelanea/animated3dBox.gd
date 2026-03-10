extends CSGBox3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	rotation += Vector3(0.01*DataGame.time_fixed,0.01*DataGame.time_fixed,0)
	pass
