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
		if pitch_scale == 0 or v == 0:
			stream_paused = true
			pitch_scale = 0.001  # Valor muy pequeño pero positivo
		else:
			stream_paused = false
			pitch_scale = abs(v)
			
		playback_rate = v
		var dir := -1 if v < 0 else 1
		if dir != playback_direction:
			playback_direction = dir
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
	if not playback: return
	for i in range(playback.get_frames_available()):
		if reversed.size() > 0:
			playback.push_frame(reversed[roundi(offset)])
			offset += 1 * playback_direction
			offset = clamp(offset, 0, reversed_size - 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if not playing: 
		offset = 0
		return
	mix_audio()
	
