extends Node
## Small pooled sound player. Sounds live in res://assets/sfx/<name>.wav.

const POOL_SIZE := 12
const SFX_DIR := "res://assets/sfx/"

var volume_db := -6.0

var _players: Array[AudioStreamPlayer] = []
var _streams := {}
var _next := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Settings.ensure_buses()
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = "Sfx"
		add_child(p)
		_players.append(p)


## Plays a sound by name with a little random pitch so repeats don't sound robotic.
func play(sound: String, pitch_jitter := 0.06, volume_offset_db := 0.0) -> void:
	var stream := _get_stream(sound)
	if stream == null:
		return
	var p := _players[_next]
	_next = (_next + 1) % POOL_SIZE
	p.stream = stream
	p.pitch_scale = 1.0 + randf_range(-pitch_jitter, pitch_jitter)
	p.volume_db = volume_db + volume_offset_db
	p.play()


func _get_stream(sound: String) -> AudioStream:
	if _streams.has(sound):
		return _streams[sound]
	var path := SFX_DIR + sound + ".wav"
	var stream: AudioStream = load(path) if ResourceLoader.exists(path) else null
	_streams[sound] = stream
	return stream
