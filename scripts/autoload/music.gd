extends Node
## Music and ambience. Tracks live in res://assets/music/<name>.(ogg|mp3|wav);
## a file Sean supplies replaces the generated placeholder of the same name
## (tools/audio/musicgen.py). Changing track crossfades; ambience is a separate
## looping bed under the music.
##
## What plays where: the zone's track (`zone` header) unless a room sets
## `music:`, the boss theme during a boss fight, and the title theme on the
## title screen. Ambience is "amb_<zone>" if it exists.

const DIR := "res://assets/music/"
const EXTENSIONS := ["ogg", "mp3", "wav"]
const FADE := 1.2
const MUSIC_DB := -10.0
const AMBIENCE_DB := -18.0
const SILENT_DB := -60.0

var track := ""
var ambience_track := ""

var _players: Array[AudioStreamPlayer] = []
var _active := 0
var _amb: AudioStreamPlayer
var _streams := {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Settings.ensure_buses()
	for i in 2:
		var p := AudioStreamPlayer.new()
		p.bus = "Music"
		p.volume_db = SILENT_DB
		add_child(p)
		_players.append(p)
	_amb = AudioStreamPlayer.new()
	_amb.bus = "Music"
	_amb.volume_db = SILENT_DB
	add_child(_amb)


## Crossfades to `name` ("" fades to silence). Asking for the playing track does nothing.
func play(name: String, fade := FADE) -> void:
	if name == track:
		return
	track = name
	var old := _players[_active]
	_active = 1 - _active
	var next := _players[_active]
	_fade(old, SILENT_DB, fade, true)
	var stream := stream_for(name)
	if stream == null:
		return
	next.stream = stream
	next.volume_db = SILENT_DB
	next.play()
	_fade(next, MUSIC_DB, fade, false)


func ambience(name: String, fade := FADE) -> void:
	if name == ambience_track:
		return
	ambience_track = name
	var stream := stream_for(name)
	if stream == null:
		_fade(_amb, SILENT_DB, fade, true)
		return
	_amb.stream = stream
	_amb.volume_db = SILENT_DB
	_amb.play()
	_fade(_amb, AMBIENCE_DB, fade, false)


## Picks the music and ambience for a room.
func for_room(room: Room) -> void:
	if room == null:
		return
	var zone_track: String = room.header.get("music", room.zone)
	if room.zone == "gym" or room.zone == "test" or room.zone == "":
		zone_track = ""
	play(zone_track)
	ambience("amb_" + room.zone)


## The loaded, looping stream for a track name, or null if there is no file.
func stream_for(name: String) -> AudioStream:
	if name == "":
		return null
	if _streams.has(name):
		return _streams[name]
	var stream: AudioStream = null
	for ext: String in EXTENSIONS:
		var path := DIR + name + "." + ext
		if ResourceLoader.exists(path):
			stream = load(path)
			break
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	elif stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	elif stream is AudioStreamWAV:
		var wav := stream as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_end = int(wav.get_length() * wav.mix_rate)
	_streams[name] = stream
	return stream


func _fade(p: AudioStreamPlayer, to_db: float, time: float, stop_after: bool) -> void:
	var tw := create_tween()
	tw.tween_property(p, "volume_db", to_db, maxf(time, 0.01))
	if stop_after:
		tw.tween_callback(p.stop)
