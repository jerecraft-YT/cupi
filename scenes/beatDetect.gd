extends Sprite2D

signal beatless

var capture: AudioEffectCapture = AudioServer.get_bus_effect(0, 1)
var beat_threshold: float = 0.4  # Umbral para detectar beats (ajusta según necesites)
var last_energy: float = 0.0
var smoothing_factor: float = 0.75  # Suavizado para la energía
var smoothed_energy: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	detect_beat()
	scale = lerp(scale, Vector2(1, 1), 0.1)
	
	if Input.is_action_just_pressed("ui_accept"):
		print("beat manual!")
		beat()

func detect_beat():
	var buffer = capture.get_buffer(512)  # Obtener más muestras para mejor detección
	
	if buffer.size() > 0:
		# Calcular la energía RMS del buffer (convertir Vector2 a mono)
		var energy: float = 0.0
		for i in range(buffer.size()):
			# Convertir estéreo a mono y calcular energía
			var sample_mono = (buffer[i].x + buffer[i].y) / 2.0
			energy += sample_mono * sample_mono
		energy = sqrt(energy / buffer.size())
		
		# Aplicar suavizado
		smoothed_energy = smoothing_factor * smoothed_energy + (1.0 - smoothing_factor) * energy
		
		# Detectar beat si la energía actual es significativamente mayor que la suavizada
		if energy > smoothed_energy * (1.0 + beat_threshold) and energy > 0.01:
			print("Beat detectado! Energía: ", energy)
			beat()
			last_energy = energy

func beat():
	beatless.emit()
	scale = Vector2.ONE * 1.2
