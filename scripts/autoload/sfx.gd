extends Node
## Small pooled sound player. Sounds live in res://assets/sfx/<name>.wav.

const POOL_SIZE := 12
const SFX_DIR := "res://assets/sfx/"

var volume_db := -6.0

## True with no sound device (the Dummy driver: headless tests and CI). Nothing
## is started then: the dummy driver never mixes, so the audio server would keep
## every playback to the end and report them as leaks at exit.
var silent := false

## Sounds loaded from disk so far. All of them load at start (`load_all`), so
## this never grows mid-play: a first slash or phase break never waits on the disk.
var loads := 0

## The last few sounds asked for, newest last (for tests: what a moment sounds like).
var recent: Array[String] = []

var _players: Array[AudioStreamPlayer] = []
var _streams := {}
var _next := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	silent = AudioServer.get_driver_name() == "Dummy"
	Settings.ensure_buses()
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = "Sfx"
		add_child(p)
		_players.append(p)
	load_all()


## Loads every sound in SFX_DIR (about 80 small files, some 20 ms once at start).
func load_all() -> void:
	for f in DirAccess.get_files_at(SFX_DIR):
		# Exported games list "name.wav.import" (or ".remap") in place of the file.
		var file := f.trim_suffix(".remap").trim_suffix(".import")
		if file.ends_with(".wav"):
			_get_stream(file.get_basename())


## Plays a sound by name with a little random pitch so repeats don't sound robotic.
func play(sound: String, pitch_jitter := 0.06, volume_offset_db := 0.0) -> void:
	recent.append(sound)
	if recent.size() > 32:
		recent.remove_at(0)
	var stream := _get_stream(sound)
	if stream == null:
		return
	var p := _players[_next]
	_next = (_next + 1) % POOL_SIZE
	p.stream = stream
	p.pitch_scale = 1.0 + randf_range(-pitch_jitter, pitch_jitter)
	p.volume_db = volume_db + volume_offset_db
	if not silent:
		p.play()


func _get_stream(sound: String) -> AudioStream:
	if _streams.has(sound):
		return _streams[sound]
	var path := SFX_DIR + sound + ".wav"
	var stream: AudioStream = load(path) if ResourceLoader.exists(path) else null
	if stream != null:
		loads += 1
	_streams[sound] = stream
	return stream
