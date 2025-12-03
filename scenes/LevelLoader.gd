extends SubViewport

var escenaActual:Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	escenaActual = get_child(0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass


func _on_start_load_load(scene:PackedScene) -> void:
	escenaActual.queue_free()
	var menu = scene.instantiate()
	add_child(menu)
	escenaActual = menu
	await get_tree().create_timer(0.1).timeout 
	escenaActual.boton.connect("load",_on_buttom_load_level)
	
func _on_buttom_load_level(scene:PackedScene) -> void:
	print("hi")
	escenaActual.queue_free()
	var menu = scene.instantiate()
	add_child(menu)
	escenaActual = menu
	#escenaActual.connect("load",_on_buttom_load_level)
