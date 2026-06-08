extends Node2D
class_name CupiContainer

@onready var ojosCupi:AnimatedSprite2D = $Face/eyes
@onready var BocaCupi:AnimatedSprite2D = $Face/mouth
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
var tiempoRestablecer:float
@export var spawner:BulletSpawner
@export var zoomInBeat:bool = true
@export var zoomBeatCupi:float = 1.2
@export var rotateInBeat:bool = true
var happy:bool = true
var easterEgg:int
var accion = ["quieto","sosteniendoNota"]

var voiceData:Array = []
var voiceIndex:int = 0

var voiceActive:bool = false
var voiceEndTime:float = 0

var voiceMouth:int = 0
var voiceFace:int = 0

func error():
	BocaCupi.frame = 8
	ojosCupi.frame = 8
	tiempoRestablecer = 1
	happy = false
	easterEgg = randi_range(0,128)
	scalecupi = 1.2

func niceHit():
	tiempoRestablecer = 0

func cupiBeat():
	#verificar si el zoom en beat esta activo
	if zoomInBeat == true:
		scalecupi = zoomBeatCupi
	#cambiar direccion de rotacion para beat
	if rotateInBeat == true:
		direction_beat = 1 ^ direction_beat
		faceAngle = ((direction_beat*2.0)-1.0)*beatAngleForce

func shieldBeat():
	lineScale = 0.9
	
func searchVoice():
	if DataGame.datalevel.data.has("voz"):
		voiceData = DataGame.datalevel.data["voz"]

func updateVoice():

	if voiceData.is_empty() or spawner == null:
		return

	
	var songTime:float = spawner.cupi.get_song_time()

	voiceActive = false

	while voiceIndex < voiceData.size():

		var voice = voiceData[voiceIndex]

		if songTime > voice["time"] + voice["duracion"]:
			voiceIndex += 1
			continue

		if songTime >= voice["time"]:

			voiceMouth = voice["expresionBoca"]
			voiceFace = voice["expresionCara"]

			voiceActive = true

		break
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	
	tiempoRestablecer -= delta
	
	if (tiempoRestablecer < 0 and spawner != null):
		if (happy):

			if voiceActive:

				ojosCupi.frame = voiceFace
				BocaCupi.frame = voiceMouth

			else:

				if (easterEgg > 90):
					ojosCupi.frame = 6
					BocaCupi.frame = 7
				else:
					ojosCupi.frame = 0
					BocaCupi.frame = 0
		else:
			if spawner.comboActual < 5:
				ojosCupi.frame = 5
				BocaCupi.frame = 19
			elif spawner.comboActual < 10:
				ojosCupi.frame = 0
				BocaCupi.frame = 15
			elif spawner.comboActual < 20:
				ojosCupi.frame = 0
				BocaCupi.frame = 20
			else:
				happy = true
	
	
	
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
