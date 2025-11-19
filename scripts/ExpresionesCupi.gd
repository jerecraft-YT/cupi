extends Node2D

@onready var ojosCupi = $Face/eyes
@onready var BocaCupi = $Face/mouth
@onready var CaraCupi = $Face

var elevacion:float
var maxElevacion:float = 10
var duracionElevacion:float
var posX:float
var posY:float
var time:float
var beatAngleForce:float = 10
var scalecupi:float = 1
var direction_beat:int
var lineScale:float = 1
var faceAngle:float

@export var zoomInBeat:bool = true
@export var zoomBeatCupi:float = 1.2
@export var rotateInBeat:bool = true
var accion = ["quieto","sosteniendoNota"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func cupiBeat():
	#verificar si el zoom en beat esta activo
	if zoomInBeat == true:
		scalecupi = zoomBeatCupi
	
	lineScale = 0.9
	#cambiar direccion de rotacion para beat
	if rotateInBeat == true:
		direction_beat = 1 ^ direction_beat
		faceAngle = ((direction_beat*2.0)-1.0)*beatAngleForce
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	#hacer que la cara del personaje oscile periodicamente
	time += DataGame.time_fixed
	posY = (sin(deg_to_rad(time)))*1
	position.y = posY
	
		#rotar cara de cupi
	faceAngle = lerp(faceAngle,0.0, 0.1 * DataGame.time_fixed)
	CaraCupi.rotation = deg_to_rad(faceAngle)
	
	#escalar cara de cupi
	scalecupi = lerp(scalecupi,1.0, 0.1 * DataGame.time_fixed)
	CaraCupi.scale = Vector2(scalecupi,scalecupi)
	
	lineScale = lerp(lineScale,1.0,0.1 * DataGame.time_fixed)
