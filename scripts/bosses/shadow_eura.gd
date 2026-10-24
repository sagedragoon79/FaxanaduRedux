class_name ShadowEura
extends Enemy
## Shadow Eura, the Mirror (design bible 8.8): a shadow copy of the player,
## made from every fight the meteor has watched. It waits before the gate of
## Zenis as your reflection: the hall is mirrored down its middle, and the
## shadow stands where you would stand on the far side of the glass.
##
## Phase 1, the mirror: it does what you did DELAY seconds ago, mirrored. Walk
## left and it walks right; jump and it jumps. Swing and it swings back at
## you DELAY later, its blade glinting for SWING_TELL first, so a blow you land
## on it comes back at you: step away or parry the echo, and a parried echo
## leaves it reeling. Only where you meet at the mirror line are you in reach
## of each other. Hold still too long and it steps through the glass to cut
## at you from behind, rising out of the floor beside you with its blade
## raised (the tell) before it strikes.
##
## Phases 2 and 3 (acting on its own, then splitting in two) come later; for
## now the mirror is the whole fight.

signal defeated

const DISPLAY_NAME := "Shadow Eura"
const EPITHET := "the Mirror"
const MAX_HP := 150
## Health fractions where later phases begin (none yet: the mirror is the
## whole fight until phases 2 and 3 are built).
const PHASES := []
## How far behind you the reflection runs (s).
const DELAY := 0.6
## How long its blade glints before an echoed swing lands (within DELAY).
const SWING_TELL := 0.4
const SWING_DAMAGE := 14
const SWING_TIME := 0.15
## Hold still this long and it comes through the mirror after you.
const STILL_TIME := 2.2
const STILL_SPEED := 20.0
## Sinking into the floor's reflection, untouchable.
const SINK_TIME := 0.5
## Risen beside you, blade raised: the tell before the cut.
const RISE_TELL := 0.45
## Where it rises, behind you.
const BEHIND := 30.0
const RECOVER := 0.6
const BLINK_TIME := 0.35
const STAGGER := 1.2
const INTRO_TIME := 1.2
const DYING_TIME := 1.6

const SHADOW := Color("120a1c")
const SHADOW_LIGHT := Color("2e1f44")
const RIM := Color("9a5ae0")
const CRYSTAL := Color("e05ad0")
const CRYSTAL_LIGHT := Color("ffb8f0")
const EYE := Color("ffe0f8")

## The hall's interior in pixels; the mirror runs down its middle.
var arena := Rect2(16, 64, 928, 256)
## What the player did, oldest first: {t, pos, facing, anim, frame}.
var _history: Array[Dictionary] = []
## Echoes of the player's swings still to come: {at, kind}.
var _echoes: Array[Dictionary] = []
var _clock := 0.0
var _swings := -1
var _still := 0.0
var _anim := "idle"
var _frame := 0
## The echo being struck now ("" when none) and whether it has landed.
var _cut := ""
var _cut_time := 0.0
var _struck := false


func _init() -> void:
	max_hp = MAX_HP
	contact_damage = 10
	gold_min = 140
	gold_max = 180
	xp = 450
	body_size = Player.BODY_SIZE
	knockback = 0.0
	launchable = false
	uses_gravity = false
	state = "dormant"


func _ready() -> void:
	super._ready()
	collision_mask = 0
	add_to_group("boss")
	z_index = 1


## Starts the fight (called by the arena once the player is inside).
func begin() -> void:
	_record()
	_follow(true)
	set_state("intro")
	Sfx.play("wail", 0.0, -4.0)
	Feel.add_trauma(0.25)
	GameState.banner.emit(DISPLAY_NAME, EPITHET)


func health_fraction() -> float:
	return clampf(float(hp) / max_hp, 0.0, 1.0)


## The x of the mirror line down the middle of the hall.
func axis() -> float:
	return arena.get_center().x


## Where `pos` falls on the other side of the mirror.
func mirrored(pos: Vector2) -> Vector2:
	return Vector2(2.0 * axis() - pos.x, pos.y)


## True while it is copying you (not reeling, not out of the glass).
func mirroring() -> bool:
	return state in ["mirror", "echo"]


## Seconds until the next echoed swing lands, or INF.
func next_echo_in() -> float:
	return _echoes[0].at - _clock if not _echoes.is_empty() else INF


## True while its blade glints before a blow.
func telling() -> bool:
	return state == "rise" or (mirroring() and next_echo_in() <= SWING_TELL)


func _modify_damage(damage: int, _dir: Vector2) -> int:
	if state in ["dormant", "intro", "dying", "sink", "blink"]:
		return 0
	return damage


func take_hit(damage: int, dir: Vector2) -> void:
	super.take_hit(damage, dir)
	_hitstun = 0.0


## A parried echo leaves it reeling: it stops copying you and stands open.
func stagger() -> void:
	if dead or state in ["dormant", "intro", "dying", "sink", "blink"]:
		return
	super.stagger()
	_stagger = STAGGER
	velocity.x = -facing * 60.0
	_echoes.clear()
	_cut = ""


func _think(delta: float) -> void:
	_clock += delta
	_record()
	match state:
		"dormant":
			pass
		"intro":
			_follow(false)
			if state_time >= INTRO_TIME:
				_echoes.clear()
				set_state("mirror")
		"idle":
			# Out of a stagger: back behind the glass.
			_blink_out()
		"mirror", "echo":
			velocity = Vector2.ZERO
			_follow(false)
			_strike_echoes(delta)
			if _still >= STILL_TIME and _cut == "":
				_still = 0.0
				_echoes.clear()
				set_state("sink")
				Sfx.play("wail", 0.1, -6.0)
		"sink":
			if state_time >= SINK_TIME:
				_rise_behind()
		"rise":
			face_player()
			if state_time >= RISE_TELL:
				_cut = "side"
				_cut_time = 0.0
				_struck = false
				Sfx.play("slash", 0.05, -2.0)
				set_state("cut")
		"cut":
			_strike(delta)
			if state_time >= SWING_TIME:
				_cut = ""
				set_state("recover")
		"recover":
			if state_time >= RECOVER:
				_blink_out()
		"blink":
			if state_time >= BLINK_TIME:
				_follow(true)
				_echoes.clear()
				_still = 0.0
				set_state("mirror")
		_:
			set_state("mirror")


## Notes what the player is doing this frame, and any new swing to echo.
func _record() -> void:
	var p := player()
	if p == null:
		return
	var vis := p.visual
	_history.append({"t": _clock, "pos": p.global_position, "facing": p.facing,
		"anim": vis.anim if vis != null else "idle", "frame": vis.frame if vis != null else 0})
	while _history.size() > 2 and _history[1].t <= _clock - DELAY:
		_history.pop_front()
	if _swings >= 0 and p.swing_count != _swings and state in ["intro", "mirror", "echo"]:
		_echoes.append({"at": _clock + DELAY, "kind": p.attack_kind})
	_swings = p.swing_count
	if mirroring() and p.velocity.length() < STILL_SPEED and not p.is_attacking:
		_still += get_physics_process_delta_time()
	else:
		_still = 0.0


## Takes up the place, facing and pose the player had DELAY ago, mirrored.
## Before DELAY has passed (or when `now`), it mirrors the present instead.
func _follow(now: bool) -> void:
	if _history.is_empty():
		return
	var h: Dictionary = _history[_history.size() - 1] if now else _history[0]
	global_position = mirrored(h.pos)
	facing = -int(h.facing)
	if _cut == "":
		_anim = h.anim
		_frame = h.frame


## Strikes back each swing the player made DELAY ago, from the mirrored spot.
func _strike_echoes(delta: float) -> void:
	if _cut != "":
		_strike(delta)
		if _cut_time >= SWING_TIME:
			_cut = ""
			set_state("mirror")
		return
	if not _echoes.is_empty() and _clock >= _echoes[0].at:
		var e: Dictionary = _echoes.pop_front()
		_cut = e.kind
		_cut_time = 0.0
		_struck = false
		set_state("echo")
		Sfx.play("slash", 0.1, -3.0)


func _strike(delta: float) -> void:
	_cut_time += delta
	if not _struck:
		_struck = hit_player_in_rect(blade_rect(), SWING_DAMAGE) != ""


## Where its blade bites: the player's own swing, mirrored.
func blade_rect() -> Rect2:
	var center: Vector2
	var size: Vector2
	match _cut:
		"down":
			size = Player.DOWN_STRIKE_SIZE
			center = Vector2(0, 8)
		"up":
			size = Player.UP_SLASH_SIZE
			center = Vector2(0, -body_size.y - 14)
		_:
			size = Player.SLASH_SIZE
			center = Vector2(facing * (body_size.x * 0.5 + 16), -body_size.y * 0.55)
	return Rect2(global_position + center - size * 0.5, size)


## Up out of the floor just behind the player, blade raised.
func _rise_behind() -> void:
	var p := player()
	var x := global_position.x
	var y := global_position.y
	if p != null:
		x = clampf(p.global_position.x - p.facing * BEHIND, arena.position.x + 12.0, arena.end.x - 12.0)
		y = p.global_position.y
	global_position = Vector2(x, y)
	face_player()
	_anim = "slash1"
	_frame = 0
	set_state("rise")
	Sfx.play("swell", 0.1, -4.0)


## Sinks away and comes back up in the mirror.
func _blink_out() -> void:
	_cut = ""
	velocity = Vector2.ZERO
	set_state("blink")


func die() -> void:
	if state == "dying":
		return
	set_state("dying")
	dead = true
	collision_layer = 0
	velocity = Vector2.ZERO
	_echoes.clear()
	_cut = ""
	Feel.hitstop(0.12)
	Feel.slowmo(0.3, 1.0)
	Feel.add_trauma(0.7)
	Sfx.play("wail", 0.0, 0.0)


func _process(delta: float) -> void:
	if state != "dying":
		return
	state_time += delta
	if int(state_time * 10.0) % 3 == 0:
		var d := Dust.new()
		d.setup("debris")
		get_parent().add_child(d)
		d.global_position = global_position + Vector2(randf_range(-8, 8), randf_range(-36, -4))
	if state_time >= DYING_TIME:
		state = "dead"
		defeated.emit()
		super.die()


## How solid it is drawn: it fades into the floor and back.
func presence() -> float:
	match state:
		"intro":
			return clampf(state_time / INTRO_TIME, 0.0, 1.0)
		"sink":
			return 1.0 - clampf(state_time / SINK_TIME, 0.0, 1.0)
		"rise":
			return clampf(state_time / 0.2, 0.0, 1.0)
		"blink":
			return absf(1.0 - 2.0 * clampf(state_time / BLINK_TIME, 0.0, 1.0))
		"dying":
			return 1.0 - clampf(state_time / DYING_TIME, 0.0, 1.0)
	return 1.0


func _draw() -> void:
	var t := Time.get_ticks_msec() * 0.001
	# The mirror line: a faint seam of light down the middle of the hall.
	if state != "dormant" and not dead or state == "dying":
		var ax := axis() - global_position.x
		var top := arena.position.y - global_position.y
		var k := 0.5 + 0.5 * sin(t * 1.5)
		draw_rect(Rect2(ax - 0.5, top, 1.0, arena.size.y), Color(RIM, 0.10 + 0.06 * k))
		for i in 6:
			var sy := fmod(t * 24.0 + i * arena.size.y / 6.0, arena.size.y)
			draw_rect(Rect2(ax - 0.5, top + sy, 1.0, 6.0), Color(CRYSTAL_LIGHT, 0.18))
	var a := presence()
	if a <= 0.01:
		return
	var anim := _anim
	var frame := _frame
	if state == "rise" or state == "cut":
		anim = "slash1"
		frame = 0 if state == "rise" else 2
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1))
	# A violet rim around a body of shadow: you, cut out of the dark.
	for o: Vector2 in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]:
		draw_set_transform(o, 0.0, Vector2(facing, 1))
		PlayerVisual.draw_frame(self, anim, frame, Color(RIM, 0.55 * a), true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1))
	PlayerVisual.draw_frame(self, anim, frame, Color(SHADOW, 0.95 * a), true)
	var info := Sheet.info(PlayerVisual.SHEET_NAME, anim, frame)
	# Eyes where yours would be, lit pale.
	var neck: Array = info.get("neck", [0, -32])
	var eye := Vector2(neck[0] + 2.0, neck[1] - 6.0)
	draw_rect(Rect2(eye, Vector2(2, 1)), Color(EYE, a))
	draw_rect(Rect2(eye + Vector2(-3, 0), Vector2(1, 1)), Color(EYE, 0.6 * a))
	# Its blade, a shard of the meteor, glinting before each blow.
	if info.has("blade"):
		var hand := Vector2(info.hand[0], info.hand[1])
		var dir := Vector2.from_angle(deg_to_rad(float(info.blade)))
		var base := hand + dir * 2.0
		var tip := base + dir * PlayerVisual.BLADE_LENGTH
		draw_line(base, tip + dir, Color(SHADOW, a), 4.0)
		draw_line(base, tip, Color(CRYSTAL, a), 2.0)
	if telling():
		var k := 0.5 + 0.5 * absf(sin(t * 18.0))
		var hand := Vector2(info.hand[0], info.hand[1]) if info.has("hand") else Vector2(6, -22)
		draw_rect(Rect2(hand + Vector2(-1, -7), Vector2(3, 14)), Color(CRYSTAL_LIGHT, 0.9 * k * a))
		draw_rect(Rect2(hand + Vector2(-6, -1), Vector2(13, 3)), Color(CRYSTAL_LIGHT, 0.9 * k * a))
		PlayerVisual.draw_frame(self, anim, frame, Color(CRYSTAL, 0.35 * k * a), true)
	if flashing() or (state == "dying" and int(state_time * 12.0) % 2 == 0):
		PlayerVisual.draw_frame(self, anim, frame, Color(1, 1, 1, 0.8 * a), true)
	draw_set_transform(Vector2.ZERO)
