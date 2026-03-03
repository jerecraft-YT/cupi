extends Node2D

var actualTime:float = -1.5
var letraMusica:JSON = load("res://scripts/animatedDebug/letraMusica.json")
var itemLeter:int = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	actualTime += delta * DataGame.cupi.TimeMultiplier
	for i in range(32):
		itemLeter = min(max(0,itemLeter),letraMusica.data.size()-1)
		if itemLeter == letraMusica.data.size()-1:
			break
		if DataGame.cupi.TimeMultiplier < 0:
			if letraMusica.data[itemLeter]["time"] >= actualTime:
				if get_child_count() != 0:
					for o in range(get_child_count()):
						if get_child(o) != null:
							get_child(o).queue_free()
				var textoScene:textDraw = textDraw.new()
				add_child(textoScene)
				textoScene.position = Vector2(0,-120)
				textoScene.BaseColor = Color(1.0, 1.0, 1.0, 1.0)
				textoScene.textToDraw = letraMusica.data[itemLeter]["word"]
				#textoScene.RGBActive = true
				textoScene.TornadoActive = true
				itemLeter -= 1
		if DataGame.cupi.TimeMultiplier > 0:
			if letraMusica.data[itemLeter]["time"] <= actualTime:
				if get_child_count() != 0:
					if get_child(0) != null:
						#print("hi")
						get_child(0).queue_free()
				var textoScene:textDraw = textDraw.new()
				add_child(textoScene)
				textoScene.position = Vector2(0,-120)
				textoScene.BaseColor = Color(1.0, 1.0, 1.0, 1.0)
				textoScene.textToDraw = letraMusica.data[itemLeter]["word"]
				textoScene.shadowActive = true
				#textoScene.RGBActive = true
				textoScene.TornadoActive = true
				itemLeter += 1
