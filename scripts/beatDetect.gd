extends Sprite2D

signal beatless

# Ajustables desde el editor
@export var bus_index: int = 0
@export var effect_index: int = 1
@export var buffer_size: int = 1024
@export var beat_threshold: float = 1.6   	# multiplicador sobre la energía media
@export var smoothing_factor: float = 0.92	# suavizado para la energía (valor cercano a 1 = más lento)
@export var min_energy: float = 1e-6       	# energía mínima para evitar ruido
@export var cooldown: float = 0.15	        # tiempo mínimo entre beats (segundos)
@export var bass_lowpass_alpha: float = 0.2 # IIR alpha para enfatizar bajas frecuencias (0..1)

var capture = null
var smoothed_energy: float = 0.0
var last_beat_time: float = -10.0
var lowpassed_sample: float = 0.0

func _ready() -> void:
	# Intentamos obtener el AudioEffectCapture del bus/slot configurado.
	capture = AudioServer.get_bus_effect(bus_index, effect_index)
	if not capture:
		push_warning("No se encontró AudioEffectCapture en bus %d slot %d. Añade AudioEffectCapture al bus y ajusta bus_index/effect_index." % [bus_index, effect_index])
	else:
		# (opcional) puedes comprobar la clase si quieres:
		if capture.get_class() != "AudioEffectCapture":
			push_warning("El efecto no es AudioEffectCapture")
		pass
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	_detect_beat()
	# suavizado visual de la escala hacia 1.0
	scale = scale.lerp(Vector2.ONE, 0.01)

func _detect_beat() -> void:
	if not capture:
		return
	# pedimos muestras; el capture devuelve un PackedVector2Array
	var buffer = capture.get_buffer(buffer_size)
	if buffer.size() == 0:
		return

	var energy_sq: float = 0.0
	# calculamos energía sobre una señal priorizando bajas frecuencias con un IIR simple
	for i in range(buffer.size()):
		var s = (buffer[i].x + buffer[i].y) * 0.5
		lowpassed_sample = bass_lowpass_alpha * lowpassed_sample + (1.0 - bass_lowpass_alpha) * s
		energy_sq += lowpassed_sample * lowpassed_sample

	energy_sq = energy_sq / buffer.size() # media de la energía al cuadrado (evita sqrt)
	# suavizado de la energía local (en términos de energy^2 para consistencia)
	smoothed_energy = smoothing_factor * smoothed_energy + (1.0 - smoothing_factor) * energy_sq

	# tiempo actual en segundos
	var now = Time.get_ticks_msec() / 1000.0
	# condición de beat: sobrepasa la energía media por un factor y supera mínimo absoluto, y respeta cooldown
	if energy_sq > max(min_energy, smoothed_energy * beat_threshold) and (now - last_beat_time) >= cooldown:
		#print("Beat detectado — energy_sq:", energy_sq, " smoothed:", smoothed_energy)
		_beat()
		last_beat_time = now

func _beat() -> void:
	emit_signal("beatless")
	scale = Vector2.ONE * 1.25
