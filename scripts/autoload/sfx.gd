extends Node
## Small pooled sound player. Sounds live in res://assets/sfx/<name>.wav.

const POOL_SIZE := 12
const SFX_DIR := "res://assets/sfx/"

var volume_db := -6.0

## Decibels a sound is played above its file (pass 270). The loudest cues, the
## cut landing and the hero's hurt, are saved a few dB under where they play so
## every file keeps headroom inside the mix check (tools/audio/levels.py,
## HEADROOM); this lifts them back, so in game they are as loud as ever.
const LIFT := {"hit": 2.2, "hurt": 3.1}

## True with no sound device (the Dummy driver: headless tests and CI). Nothing
## is started then: the dummy driver never mixes, so the audio server would keep
## every playback to the end and report them as leaks at exit.
var silent := false

## Sounds loaded from disk so far. All of them load at start (`load_all`), so
## this never grows mid-play: a first slash or phase break never waits on the disk.
var loads := 0

## The last few sounds asked for, newest last (for tests: what a moment sounds like).
var recent: Array[String] = []

## Names asked for that have no file (pass 207), each once. A sound named at
## runtime ("step_" + surface, a helper's choice) is out of reach of the
## suite's scan of the scripts, and a typo there plays silence; the test
## runner fails any test that adds to this.
var missing: Array[String] = []

var _players: Array[AudioStreamPlayer] = []
var _streams := {}
## When each voice's sound ends (ms, real time, as the mixer plays it).
var _ends: Array[int] = []
## The physics frame each sound last started on, so a burst of the same sound
## in one frame (a spray of coins) takes one voice, not the pool (pass 254).
var _started_on := {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	silent = AudioServer.get_driver_name() == "Dummy"
	Settings.ensure_buses()
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = "Sfx"
		add_child(p)
		_players.append(p)
		_ends.append(0)
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
		if not missing.has(sound):
			missing.append(sound)
		return
	var frame := Engine.get_physics_frames()
	if int(_started_on.get(sound, -1)) == frame:
		return
	_started_on[sound] = frame
	var i := _voice()
	var p := _players[i]
	p.stream = stream
	p.pitch_scale = 1.0 + randf_range(-pitch_jitter, pitch_jitter)
	p.volume_db = volume_db + volume_offset_db + float(LIFT.get(sound, 0.0))
	_ends[i] = Time.get_ticks_msec() + int(stream.get_length() / p.pitch_scale * 1000.0)
	if not silent:
		p.play()


## The voice a new sound takes (pass 254): a free one, or else the one nearest
## its end. The pool used to take turns, so in a busy fight a dozen steps and
## cuts would cut a 2.4 s victory or a phase break short in its first second.
func _voice() -> int:
	var best := 0
	for i in _players.size():
		if _ends[i] < _ends[best]:
			best = i
	return best


## What voice `i` holds now: its sound's name while it plays, else "".
func voice_sound(i: int) -> String:
	if i < 0 or i >= _players.size() or _ends[i] <= Time.get_ticks_msec() or _players[i].stream == null:
		return ""
	return String(_players[i].stream.resource_path.get_file().get_basename())


func _get_stream(sound: String) -> AudioStream:
	if _streams.has(sound):
		return _streams[sound]
	var path := SFX_DIR + sound + ".wav"
	var stream: AudioStream = load(path) if ResourceLoader.exists(path) else null
	if stream != null:
		loads += 1
	_streams[sound] = stream
	return stream
