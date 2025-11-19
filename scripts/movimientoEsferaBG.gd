extends MeshInstance3D

var amp:float
var time:float
var frequency:float
var adicionalAmp:float
@onready var cupi:Node2D = get_tree().get_first_node_in_group("cupi")

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	time += delta
	amp = (cos(time)*0.1) + adicionalAmp
	adicionalAmp = lerp(adicionalAmp,0.0,0.1*DataGame.time_fixed)
	frequency = 30+cos(time/4)*10
	mesh.material.set_shader_parameter("amplitude", amp)
	mesh.material.set_shader_parameter("frequency", frequency)
	
	rotation += Vector3(0.01,0.01,0)*DataGame.time_fixed

func beat():
	adicionalAmp = randf_range(0.1,0.4)
