extends Node2D
class_name VoiceAnalyzer

enum MusicGenre {
	POP,
	ROCK,
	ELECTRONIC,
	ACOUSTIC,
	KARAOKE
}

@export var bus_name := "Music"
@export var genre : MusicGenre = MusicGenre.POP

# Resultados públicos
var singing := false
var sing_power := 0.0
var voice_intensity := 0.0
var voice_probability := 0.0
var voice_pitch := 0.5

var spectrum : AudioEffectSpectrumAnalyzerInstance

var weak_threshold := 1.2
var strong_threshold := 1.8

var timer := 0.0

func _ready():

	_setup_genre()

	var bus_idx := AudioServer.get_bus_index(bus_name)

	if bus_idx == -1:
		push_error("Bus '%s' no encontrado" % bus_name)
		return

	spectrum = AudioServer.get_bus_effect_instance(bus_idx, 0)

	if spectrum == null:
		push_error("No se encontró Spectrum Analyzer")
		return

	print("VoiceAnalyzer listo")

func _setup_genre():

	match genre:

		MusicGenre.POP:
			weak_threshold = 1.2
			strong_threshold = 1.8

		MusicGenre.ROCK:
			weak_threshold = 1.5
			strong_threshold = 2.2

		MusicGenre.ELECTRONIC:
			weak_threshold = 1.8
			strong_threshold = 2.8

		MusicGenre.ACOUSTIC:
			weak_threshold = 1.0
			strong_threshold = 1.5

		MusicGenre.KARAOKE:
			weak_threshold = 0.8
			strong_threshold = 1.2

func _process(delta):

	if spectrum == null:
		return

	timer += delta

	if timer < 0.05:
		return

	timer = 0.0

	_analyze()

func _analyze():

	var bass = _band(80, 250)

	var low_mid = _band(250, 700)
	var vocal_mid = _band(700, 2000)
	var high_mid = _band(2000, 3500)

	var highs = _band(3500, 8000)

	# Energía vocal
	var vocal_energy =(low_mid * 0.6) +(vocal_mid * 1.0) +(high_mid * 0.8)

	# Energía instrumental
	var instrumental_energy =(bass * 0.8) +(highs * 0.8)

	var target_probability =vocal_energy /max(instrumental_energy, 0.0001)

	voice_probability = lerp(voice_probability,target_probability,
		0.15
	)

	voice_intensity = lerp(
		voice_intensity,
		clamp(vocal_energy * 0.08, 0.0, 1.0),
		0.2
	)

	var total_mid =low_mid +vocal_mid +high_mid

	if total_mid > 0.0001:

		var target_pitch =(low_mid * 0.0 +vocal_mid * 0.5 +high_mid * 1.0) / total_mid

		voice_pitch = lerp(
			voice_pitch,
			target_pitch,
			0.15
		)

	singing = voice_probability > weak_threshold

	sing_power = clamp(
		(voice_probability - weak_threshold) /
		(strong_threshold - weak_threshold),
		0.0,
		1.0
	)

func _band(min_freq: float, max_freq: float) -> float:

	var mag = spectrum.get_magnitude_for_frequency_range(
		min_freq,
		max_freq
	)

	return mag.length()
