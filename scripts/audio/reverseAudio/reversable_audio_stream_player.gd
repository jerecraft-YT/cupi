@tool extends AudioStreamPlayer
class_name ReversableAudioStreamPlayer

var playback_direction := 1

@export var bstream:AudioStream : 
	set(v):
		bstream = v
		if v != null:
			_render_audio()
		else:
			reversed.clear()
			reversed_size = 0
	get:
		return bstream

@export_range(-4.0, 4.0, 0.001) var playback_rate = 1.0 :
	set(v):
		playback_rate = v
		var dir := -1 if v < 0 else 1
		
		# Actualizar dirección de reproducción
		if dir != playback_direction:
			playback_direction = dir
		
		# Manejar el pitch_scale de forma segura
		var target_pitch = abs(v)
		
		# Evitar valores problemáticos
		if target_pitch <= 0.0:
			stream_paused = true
			pitch_scale = 0.001  # Valor mínimo seguro
		else:
			stream_paused = false
			pitch_scale = target_pitch
	get:
		return playback_rate

var generator := AudioStreamGenerator.new()

# Playback data
var reversed:PackedVector2Array
var reversed_size:int

var offset:float = 0
@export var playback_position:float :
	set(v):
		offset = v * generator.mix_rate
	get:
		return offset / generator.mix_rate

func _init() -> void:
	stream = AudioStreamGenerator.new()
	stream.mix_rate_mode = AudioStreamGenerator.MIX_RATE_OUTPUT
	stream.buffer_length = 0.1

@warning_ignore("unused_parameter")
func _set(property: StringName, value: Variant) -> bool:
	if property == "stream" or property == "pitch_scale":
		return true
	return false
	
func _render_audio() -> void:
	offset = 0
	var rev_playback = bstream.instantiate_playback()
	rev_playback.start()
	reversed = rev_playback.mix_audio(1, round(bstream.get_length() * generator.mix_rate))
	reversed_size = reversed.size()
	
func mix_audio():
	var playback := get_stream_playback()
	if not playback: 
		return
	
	var frames_available = playback.get_frames_available()
	if frames_available <= 0:
		return
	
	for i in range(frames_available):
		if reversed.size() > 0:
			var idx = roundi(offset)
			# Asegurar que el índice esté dentro de límites
			idx = clampi(idx, 0, reversed_size - 1)
			playback.push_frame(reversed[idx])
			offset += 1 * playback_direction
			
			# Detener si se sale de los límites
			if offset < 0 or offset >= reversed_size - 1:
				stop()
				offset = 0
				break

# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if not playing: 
		return
	mix_audio()
