class_name Settings
extends RefCounted
## Player options (design bible 14, accessibility): screen shake, screen
## flashes, rumble, music and sound volume, game speed and keyboard bindings.
## Kept apart from save slots in user://settings.cfg. The game loads and
## applies them at start; tests never do, so they run on the defaults.

const PATH := "user://settings.cfg"
const SHAKE_STEPS := [1.0, 0.5, 0.0]
const SHAKE_NAMES := ["Full", "Half", "Off"]
const FLASH_STEPS := [1.0, 0.35, 0.0]
const FLASH_NAMES := ["Full", "Reduced", "Off"]
const SPEED_STEPS := [1.0, 0.9, 0.8, 0.7]
const VOLUME_MAX := 10
## Keyboard actions the player may rebind (the pad keeps its layout).
const REBINDABLE := ["move_left", "move_right", "move_up", "move_down", "jump", "attack", "dash", "block", "spell", "heal", "map"]
const BUSES := ["Music", "Sfx"]

static var shake := 0          # index into SHAKE_STEPS
static var flashes := 0        # index into FLASH_STEPS
static var rumble := true
static var music_volume := 8
static var sound_volume := 8
static var speed := 0          # index into SPEED_STEPS
## action -> physical keycode of its first key, for rebound actions only.
static var keys := {}
## Where load() and save() go (tests point it elsewhere).
static var path := PATH


static func reset() -> void:
	shake = 0
	flashes = 0
	rumble = true
	music_volume = 8
	sound_volume = 8
	speed = 0
	keys = {}


static func load_settings() -> void:
	reset()
	var cfg := ConfigFile.new()
	if cfg.load(path) != OK:
		return
	shake = clampi(int(cfg.get_value("feel", "shake", shake)), 0, SHAKE_STEPS.size() - 1)
	flashes = clampi(int(cfg.get_value("feel", "flashes", flashes)), 0, FLASH_STEPS.size() - 1)
	rumble = bool(cfg.get_value("feel", "rumble", rumble))
	speed = clampi(int(cfg.get_value("feel", "speed", speed)), 0, SPEED_STEPS.size() - 1)
	music_volume = clampi(int(cfg.get_value("audio", "music", music_volume)), 0, VOLUME_MAX)
	sound_volume = clampi(int(cfg.get_value("audio", "sound", sound_volume)), 0, VOLUME_MAX)
	for action: String in REBINDABLE:
		if cfg.has_section_key("keys", action):
			keys[action] = int(cfg.get_value("keys", action))


static func save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("feel", "shake", shake)
	cfg.set_value("feel", "flashes", flashes)
	cfg.set_value("feel", "rumble", rumble)
	cfg.set_value("feel", "speed", speed)
	cfg.set_value("audio", "music", music_volume)
	cfg.set_value("audio", "sound", sound_volume)
	for action: String in keys:
		cfg.set_value("keys", action, keys[action])
	cfg.save(path)


## Pushes the settings into Feel, the audio buses and the input map.
static func apply() -> void:
	Feel.shake_scale = SHAKE_STEPS[shake]
	Feel.flash_scale = FLASH_STEPS[flashes]
	Feel.rumble_enabled = rumble
	Feel.set_game_speed(SPEED_STEPS[speed])
	ensure_buses()
	_set_volume("Music", music_volume)
	_set_volume("Sfx", sound_volume)
	Controls.restore_defaults()
	for action: String in keys:
		Controls.rebind(action, keys[action])


## Changes one option by `step` (wrapping lists, clamping volumes), applies and saves.
static func adjust(option: String, step: int) -> void:
	match option:
		"shake": shake = wrapi(shake + step, 0, SHAKE_STEPS.size())
		"flashes": flashes = wrapi(flashes + step, 0, FLASH_STEPS.size())
		"rumble": rumble = not rumble
		"speed": speed = wrapi(speed + step, 0, SPEED_STEPS.size())
		"music": music_volume = clampi(music_volume + step, 0, VOLUME_MAX)
		"sound": sound_volume = clampi(sound_volume + step, 0, VOLUME_MAX)
	apply()
	save()


## Binds `action` to a key (swapping with any action that had it), applies and saves.
static func bind_key(action: String, keycode: int) -> void:
	for other: String in REBINDABLE:
		if other != action and Controls.primary_key(other) == keycode:
			keys[other] = Controls.primary_key(action)
	keys[action] = keycode
	apply()
	save()


static func reset_keys() -> void:
	keys = {}
	apply()
	save()


## The Music and Sfx buses, created once under Master.
static func ensure_buses() -> void:
	for bus: String in BUSES:
		if AudioServer.get_bus_index(bus) == -1:
			AudioServer.add_bus()
			var i := AudioServer.bus_count - 1
			AudioServer.set_bus_name(i, bus)
			AudioServer.set_bus_send(i, "Master")


static func _set_volume(bus: String, level: int) -> void:
	var i := AudioServer.get_bus_index(bus)
	AudioServer.set_bus_mute(i, level <= 0)
	# A gentle curve: each step is about 3 dB, 8 of 10 is a little under full.
	AudioServer.set_bus_volume_db(i, (level - VOLUME_MAX) * 3.0)


static func value_text(option: String) -> String:
	match option:
		"shake": return SHAKE_NAMES[shake]
		"flashes": return FLASH_NAMES[flashes]
		"rumble": return "On" if rumble else "Off"
		"speed": return "%d%%" % roundi(SPEED_STEPS[speed] * 100.0)
		"music": return _bar(music_volume)
		"sound": return _bar(sound_volume)
	return ""


static func _bar(level: int) -> String:
	return "|".repeat(level) + ".".repeat(VOLUME_MAX - level)
