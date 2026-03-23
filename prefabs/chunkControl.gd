class_name chunkController
extends Node2D

var timeCleanFinal:float
var timeCleanStart:float
var cupi:Cupi
var actualTime:float

# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	actualTime = cupi.get_song_time()
	
	if actualTime > timeCleanFinal:
		for child in get_children():
			child.queue_free()
		set_process(false)
	if actualTime < timeCleanStart:
		for child in get_children():
			child.queue_free()
		set_process(false)
