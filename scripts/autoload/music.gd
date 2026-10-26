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
const MUSIC_DB := -8.3
const AMBIENCE_DB := -18.0
const SILENT_DB := -60.0
## Each boss phase raises the music a semitone (and its tempo with it), the
## old "key change" lift (design bible 13.3, Audio).
const PHASE_STEP := 1.0594631
const PHASE_SHIFT_TIME := 0.8

var track := ""
## How many phase lifts the playing track has taken (0 = as written).
var intensity := 0
var ambience_track := ""

## True with no sound device (the Dummy driver: headless tests and CI). Nothing
## is started then: the dummy driver never mixes, so the audio server would keep
## every playback to the end and report them as leaks at exit.
var silent := false

var _players: Array[AudioStreamPlayer] = []
var _active := 0
var _amb: AudioStreamPlayer
var _streams := {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	silent = AudioServer.get_driver_name() == "Dummy"
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
	intensity = 0
	var old := _players[_active]
	_active = 1 - _active
	var next := _players[_active]
	next.pitch_scale = 1.0
	_fade(old, SILENT_DB, fade, true)
	var stream := stream_for(name)
	if stream == null:
		return
	next.stream = stream
	next.volume_db = SILENT_DB
	if not silent:
		next.play()
	_fade(next, MUSIC_DB, fade, false)


## Dips the music for `time` seconds so a fanfare can be heard, then brings it back.
func duck(time: float, depth_db := 14.0) -> void:
	var p := _players[_active]
	if not p.playing:
		return
	var tw := create_tween()
	tw.tween_property(p, "volume_db", MUSIC_DB - depth_db, 0.15)
	tw.tween_interval(maxf(time - 0.8, 0.0))
	tw.tween_property(p, "volume_db", MUSIC_DB, 0.65)


## Lifts the playing track to `level` phase steps (a semitone each) over
## PHASE_SHIFT_TIME. A new track starts back at 0.
func intensify(level: int) -> void:
	if level == intensity:
		return
	intensity = level
	var tw := create_tween()
	tw.tween_property(_players[_active], "pitch_scale", pitch_for(level), PHASE_SHIFT_TIME)


## The pitch (and tempo) scale for a number of phase steps.
static func pitch_for(level: int) -> float:
	return pow(PHASE_STEP, level)


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
	if not silent:
		_amb.play()
	_fade(_amb, AMBIENCE_DB, fade, false)


## Tracks that change once the game is cleared: track -> its post-game self.
const AFTER_THE_END := {"eolis": "eolis_bloom", "zenis": "zenis_still", "amb_zenis": "amb_zenis_still"}


## Picks the music and ambience for a room. A spring restored in the room calls
## it again with a slow fade, so the zone's music turns as the water comes back.
func for_room(room: Room, fade := FADE) -> void:
	if room == null:
		return
	var zone_track: String = room.header.get("music", room.zone)
	if room.zone == "gym" or room.zone == "test" or room.zone == "":
		zone_track = ""
	play(after_the_end(restored(zone_track)), fade)
	# A room can name its own bed (`ambience: heights` plays amb_heights).
	ambience(after_the_end(restored("amb_" + room.header.get("ambience", room.zone))), fade)


## The track a room's music or bed becomes once the Evil One is dead and the
## Tree blooms (`cleared`, design bible 4.4): Eolis plays its festival, and the
## dead meteor goes still, with no heartbeat (pass 143).
static func after_the_end(track: String) -> String:
	if GameState.flag("cleared"):
		return String(AFTER_THE_END.get(track, track))
	return track


## Tracks that change once their zone's spring flows again (design bible 13.3,
## pass 150): track -> [the spring's flag, the restored track].
const RESTORED := {
	"trunk": ["spring:trunk", "trunk_restored"],
	"mist": ["spring:mist", "mist_restored"],
	"daybreak": ["spring:sky", "daybreak_restored"],
	"amb_daybreak": ["spring:sky", "amb_daybreak_restored"],
}


## The track a zone's music or bed becomes once its spring is restored: the
## Trunk opens up over the amber, the Mist is heard through half the fog, and
## the storm over Daybreak breaks.
static func restored(track: String) -> String:
	if RESTORED.has(track) and GameState.flag(String(RESTORED[track][0])):
		return String(RESTORED[track][1])
	return track


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
