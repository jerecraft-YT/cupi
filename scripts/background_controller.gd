extends Node2D


@export var Background1:AnimatedSprite2D
@export var Background2:AnimatedSprite2D
@export var imageShowBackground1:int = 0
@export var imageShowBackground2:int = 1
var opacidadBackground1:float = 1
var opacidadBackground2:float = 0
@export var mostrarBackground1:bool = true
var timeCambio:float
@export var changeStateEvery:float = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Background1.frame = imageShowBackground1
	Background2.frame = imageShowBackground2
	
	if mostrarBackground1:
		opacidadBackground1 = lerp(opacidadBackground1,1.0,delta)
		opacidadBackground2 = lerp(opacidadBackground2,0.0,delta)
	else:
		opacidadBackground1 = lerp(opacidadBackground1,0.0,delta)
		opacidadBackground2 = lerp(opacidadBackground2,1.0,delta)
		
	Background1.modulate = Color(1,1,1,opacidadBackground1)
	Background2.modulate = Color(1,1,1,opacidadBackground2)
	
	timeCambio += delta
	
	if timeCambio > changeStateEvery:
		timeCambio = 0
		if mostrarBackground1:
			mostrarBackground1 = false
			imageShowBackground2 += 1
			if imageShowBackground2 > 5:
				imageShowBackground2 = 0
		else:
			mostrarBackground1 = true
			imageShowBackground1 += 1
			if imageShowBackground1 > 5:
				imageShowBackground1 = 0
