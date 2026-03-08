extends Node2D
class_name SpectroAnalizer

@export var VU_COUNT = 9
@export_range(1, 60) var UPDATE_RATE = 30  # Limitar updates por segundo
@export var WIDTH = 800
@export var HEIGHT = 250
@export var HEIGHT_SCALE = 3.0
@export var test:Node2D

const FREQ_MAX = 15050.0
const MIN_DB = 60
const ANIMATION_SPEED = 0.2

var spectrum
var min_values = []
var max_values = []
var data = []  # Reutilizar array
var time_since_last_update = 0.0
var numberEffects:int

func _ready():
	print(test)
	numberEffects = AudioServer.get_bus_effect_count(0)
	setAudioInstance()
	min_values.resize(VU_COUNT)
	max_values.resize(VU_COUNT)
	data.resize(VU_COUNT)
	min_values.fill(0.0)
	max_values.fill(0.0)
	data.fill(0.0)

func setAudioInstance():
	spectrum = AudioServer.get_bus_effect_instance(0, 0)
	numberEffects = AudioServer.get_bus_effect_count(0)
	print("update spectrum")
	
func _process(delta):
	#centerMetaball.rotation += deg_to_rad(10)*delta
	if numberEffects != AudioServer.get_bus_effect_count(0):
		setAudioInstance()
	
	time_since_last_update += delta
	
	# Limitar frecuencia de actualización
	if time_since_last_update < (1.0 / UPDATE_RATE):
		return
	
	time_since_last_update = 0.0
	
	calculate_spectrum_data()
	update_visuals()

func calculate_spectrum_data():
	var prev_hz = 0.0
	
	for i in range(VU_COUNT):
		var hz = (i + 1) * FREQ_MAX / VU_COUNT
		var magnitude = spectrum.get_magnitude_for_frequency_range(prev_hz, hz)
		var energy = clampf((MIN_DB + linear_to_db(magnitude.length())) / MIN_DB, 0.0, 1.0)
		data[i] = energy * HEIGHT * HEIGHT_SCALE
		prev_hz = hz

func update_visuals():
	for i in range(VU_COUNT):
		# Optimizar: evitar operaciones innecesarias
		var current_data = data[i]
		
		if current_data > max_values[i]:
			max_values[i] = current_data
		else:
			# Usar lerp solo si es necesario
			max_values[i] = lerpf(max_values[i], current_data, ANIMATION_SPEED)
		
		# Optimizar esta condición
		if current_data <= 0.0:
			min_values[i] = lerpf(min_values[i], 0.0, ANIMATION_SPEED)
	
	#queue_redraw()  # Solo redibujar cuando sea necesario

# También considera usar _physics_process para updates más estables
