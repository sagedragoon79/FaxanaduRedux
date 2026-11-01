extends Node
## Game-feel services: hit-stop, screen shake (trauma model) and rumble.
## Times here use real (unscaled) time so hit-stop can freeze the game clock.

const MAX_SHAKE_OFFSET := Vector2(10.0, 7.0)
const TRAUMA_DECAY := 1.5
## A boss kill (design bible 6.7): the game freezes this long, then runs in
## slow motion that ramps back up to full speed.
const BOSS_KILL_HITSTOP := 0.35
const BOSS_KILL_SLOWMO := 0.3
## The white flash every guardian's kill throws over the screen (design bible
## 8, pass 356), scaled by the flashes option like every flash.
const BOSS_KILL_FLASH := 1.0

## Settings (the options menu sets these through Settings).
var hitstop_enabled := true
var shake_scale := 1.0
var rumble_enabled := true
## Scales full-screen flashes (boss kills, the Elixir): 1 full, 0 off.
var flash_scale := 1.0
## Game speed (accessibility, 70% to 100%): the time scale the game runs at.
var game_speed := 1.0

var trauma := 0.0
var shake_offset := Vector2.ZERO
## The last rumble asked for (weak, strong, seconds), even with rumble off (tests).
var last_rumble := Vector3.ZERO
## The last hit-stop asked for, in seconds, even with hit-stop off (tests).
var last_hitstop := 0.0

var _hitstop_until_usec := 0
## Slow motion (boss kills): the time scale hit-stop returns to, and until when.
var _base_scale := 1.0
var _slowmo_until_usec := 0
## A ramping slow motion (boss kills) eases from _slowmo_scale back to full
## speed between these times; 0 when the slow motion holds steady.
var _ramp_from_usec := 0
var _slowmo_scale := 1.0
var _noise := FastNoiseLite.new()
var _noise_t := 0.0
var _last_usec := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_noise.seed = 1987
	_noise.frequency = 0.9
	_last_usec = Time.get_ticks_usec()


## Freezes game time for `seconds`. Overlapping calls keep the longest end time.
func hitstop(seconds: float) -> void:
	last_hitstop = seconds
	if not hitstop_enabled or seconds <= 0.0:
		return
	var until := Time.get_ticks_usec() + int(seconds * 1_000_000.0)
	_hitstop_until_usec = maxi(_hitstop_until_usec, until)
	Engine.time_scale = 0.0


## Slows the game to `scale` for `seconds` of real time (cinematic kills).
func slowmo(scale: float, seconds: float) -> void:
	_ramp_from_usec = 0
	scale *= game_speed
	_base_scale = scale
	_slowmo_until_usec = Time.get_ticks_usec() + int(seconds * 1_000_000.0)
	if Engine.time_scale > 0.0:
		Engine.time_scale = scale


## A boss's death blow: the 350 ms freeze, then slow motion easing back up to
## full speed over `seconds` of real time.
func boss_kill(seconds: float) -> void:
	GameState.flash.emit(BOSS_KILL_FLASH)
	hitstop(BOSS_KILL_HITSTOP)
	slowmo(BOSS_KILL_SLOWMO, BOSS_KILL_HITSTOP + seconds)
	_slowmo_scale = _base_scale
	_ramp_from_usec = Time.get_ticks_usec() + int(BOSS_KILL_HITSTOP * 1_000_000.0)


## The time scale a ramping slow motion has reached at `now` (in usec).
func _ramped_scale(now: int) -> float:
	var t := clampf(float(now - _ramp_from_usec) / float(_slowmo_until_usec - _ramp_from_usec), 0.0, 1.0)
	return lerpf(_slowmo_scale, game_speed, t * t)


## Ends any hitstop or slow motion at once (tests, room resets).
func reset() -> void:
	_hitstop_until_usec = 0
	_slowmo_until_usec = 0
	_ramp_from_usec = 0
	_base_scale = game_speed
	Engine.time_scale = game_speed


func set_game_speed(speed: float) -> void:
	game_speed = speed
	if _slowmo_until_usec == 0:
		_base_scale = speed
		if Engine.time_scale > 0.0:
			Engine.time_scale = speed


func is_frozen() -> bool:
	return Engine.time_scale == 0.0


func add_trauma(amount: float) -> void:
	trauma = clampf(trauma + amount * shake_scale, 0.0, 1.0)


func rumble(weak: float, strong: float, seconds: float) -> void:
	last_rumble = Vector3(weak, strong, seconds)
	if not rumble_enabled:
		return
	for pad in Input.get_connected_joypads():
		Input.start_joy_vibration(pad, weak, strong, seconds)


func _process(_delta: float) -> void:
	var now := Time.get_ticks_usec()
	var real_delta := float(now - _last_usec) / 1_000_000.0
	_last_usec = now
	# With --fixed-fps (tests, captures) real time is meaningless; fall back to a frame step.
	if real_delta <= 0.0 or real_delta > 0.25:
		real_delta = 1.0 / 60.0

	if _slowmo_until_usec > 0 and now >= _slowmo_until_usec:
		_slowmo_until_usec = 0
		_ramp_from_usec = 0
		_base_scale = game_speed
		if Engine.time_scale > 0.0:
			Engine.time_scale = game_speed
	elif _ramp_from_usec > 0 and now > _ramp_from_usec:
		_base_scale = _ramped_scale(now)
		if Engine.time_scale > 0.0:
			Engine.time_scale = _base_scale
	if _hitstop_until_usec > 0 and now >= _hitstop_until_usec:
		_hitstop_until_usec = 0
		Engine.time_scale = _base_scale

	trauma = maxf(trauma - TRAUMA_DECAY * real_delta, 0.0)
	_noise_t += real_delta * 60.0
	var shake := trauma * trauma
	shake_offset = Vector2(
		MAX_SHAKE_OFFSET.x * shake * _noise.get_noise_2d(_noise_t, 0.0),
		MAX_SHAKE_OFFSET.y * shake * _noise.get_noise_2d(0.0, _noise_t)
	).round()
