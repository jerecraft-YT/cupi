extends Sprite2D
 	
var time:float
var gradientSx
var gradientSy 
func _process(delta: float) -> void:
	time += delta*2.0
	gradientSx=(cos(time)+1.0)/4.0
	gradientSy=(sin(time)+1.0)/4.0
	texture.fill_from=Vector2(gradientSx,gradientSy)
	texture.fill_to=Vector2(1,1)
