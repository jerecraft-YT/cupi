class_name ControlGame
extends Node2D

@onready var cupi:Cupi = get_tree().get_first_node_in_group("cupi")
var angleToGet:float
var angulosMeta:Array
var tiempoProgreso:float
var intialTime:float
var firstTime:bool = true
func _ready() -> void:
	cupi.beat.connect(beat)

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
		if cupi != null:
			if !cupi.cupiBot:
				if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
					look_at(get_global_mouse_position())
					rotation = deg_to_rad(fmod(rad_to_deg(rotation),360))
			else:
				if !angulosMeta.is_empty() and cupi.TimeMultiplier > 0:
					tiempoProgreso = inverse_lerp(intialTime,angulosMeta[0]["StrumTime"],cupi.TimeScene)
					rotation = lerp_angle(rotation,deg_to_rad(angulosMeta[0]["Angle"]),tiempoProgreso)
					if cupi.TimeScene > angulosMeta[0]["StrumTime"]:
						intialTime = angulosMeta[0]["StrumTime"]
						angulosMeta.remove_at(0)
						
						
func MoveToAngle(Angle:float,StrumTime:float):
	if firstTime:
		intialTime = cupi.TimeScene
		firstTime = false
	angulosMeta.append({"Angle":Angle,"StrumTime":StrumTime})
	angleToGet = Angle
	angulosMeta.sort_custom(sortByTime)
	
func beat():
	pass
		
func sortByTime(A,B):
	if A["StrumTime"] < B["StrumTime"]:
		return true
	return false
