extends Label

@export var velocidadNotas:Slider
@export var multiplicadorVelocidad:Slider
@export var regularVoz:CheckBox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	text = "Velocidad Notas: %s

Multiplicador velocidad:%s


Regular voz:
" % [velocidadNotas.value,multiplicadorVelocidad.value]
	DataGame.velocidadNotas = velocidadNotas.value
	DataGame.multiplicadorVelocidad = multiplicadorVelocidad.value
	DataGame.regularVoz = regularVoz.button_pressed
