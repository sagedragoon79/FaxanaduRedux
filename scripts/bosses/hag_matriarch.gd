class_name HagMatriarch
extends Enemy
## The Marsh Hag Matriarch (design bible 7 and 8): the oldest of the Mist's
## hags, mother of all of them, grown huge and bent in her mire east of Mascon.
## The mini-boss of the Mist (room header `boss: hag_matriarch`).
##
## She fights as her daughters do, from a distance and through the fog, with a
## great marsh-wisp in her staff to show where she is:
## - Hex (her staple): she raises the staff and marks the floor under you and to
##   either side with rings of bog light (three marks; five below half), the
##   telegraph. Then mud hands burst out of every mark (`MireGrasp`, 16,
##   unparryable): step between them. Strike her mid-hex and the whole spell
##   breaks: every mark fizzles and she gropes for her staff, open.
## - Sink: crowd her and she sinks into the bog (bubbles at her feet, the tell),
##   gone and untouchable, and rises again at the far side of the mire.
## - Call (below half, every third move): she calls a daughter, a Marsh Hag,
##   up out of the bog on the far side; never more than one at a time.
## Her reed shawl halves every blow except while she gropes for her staff or
## reels from a parry. Below half her tells are shorter (never under
## Enemy.MIN_TELEGRAPH).

signal defeated

const DISPLAY_NAME := "The Marsh Hag Matriarch"
const EPITHET := "Mother of the Mire"
const MAX_HP := 230
const PHASES := [0.5]
const WALK_SPEED := 26.0
## Crowd her nearer than this (px) for SHY_TIME and she sinks away.
const SHY := 80.0
const SHY_TIME := 0.5
const HEX_TELL := 0.8
const SINK_TELL := 0.5
const CALL_TELL := 0.7
## Phase 2 tells are this fraction as long.
const FAST := 0.8
## Marks in a hex, and the gap between them (px).
const MARKS := 3
const MARKS_PHASE2 := 5
const MARK_GAP := 40.0
## Groping for her staff after a broken hex: her opening.
const FUMBLE := 1.4
const SUNK := 0.6
const RISE := 0.4
const CAST := 0.35
const GUARD := 0.5
const INTRO_TIME := 1.4
const DYING_TIME := 1.4
const SCALE := 3.0

const OUTLINE := Color("141a12")
const REED := Color("8a8a4a")
const REED_DARK := Color("5a5a2e")
const MOSS := Color("4a7a3a")
const MOSS_LIGHT := Color("7aaa52")
const SKIN := Color("9aa88a")
const STAFF := Color("5a4028")
const WISP := Color("6fd08a")
const WISP_LIGHT := Color("c8ffd0")
const EYE := Color("e8ff9a")

## The mire's interior in pixels (walls and ceiling outside it).
var arena := Rect2(16, 64, 608, 208)
var phase := 1
var light_radius := 72.0
var _marks: Array[MireGrasp] = []
var _daughter: MarshHag
var _moves := 0
var _crowded := 0.0
var _rng := RandomNumberGenerator.new()


func _init() -> void:
	max_hp = MAX_HP
	contact_damage = 10
	gold_min = 60
	gold_max = 80
	xp = 120
	body_size = Vector2(26, 44)
	knockback = 0.0
	launchable = false
	state = "dormant"
	_rng.seed = 1989


func _ready() -> void:
	super._ready()
	add_to_group("boss")
	add_to_group("light")


## Starts the fight (called by the arena once the player is inside).
func begin() -> void:
	face_player()
	set_state("intro")
	Sfx.play("matriarch_cackle", 0.0, 3.0)
	Feel.add_trauma(0.25)
	GameState.banner.emit(DISPLAY_NAME, EPITHET)


func health_fraction() -> float:
	return clampf(float(hp) / max_hp, 0.0, 1.0)


func tell(base: float) -> float:
	return maxf(Enemy.MIN_TELEGRAPH, base * (FAST if phase == 2 else 1.0))


func is_hexing() -> bool:
	return state == "hex_tell"


func is_sunk() -> bool:
	return state == "sunk"


## The marks of the hex now being cast.
func marks() -> Array[MireGrasp]:
	return _marks.filter(func(m: MireGrasp) -> bool: return is_instance_valid(m))


## Her daughter, while one walks.
func daughter() -> MarshHag:
	return _daughter if _daughter != null and is_instance_valid(_daughter) and not _daughter.dead else null


## Her opening (Enemy.punishable): groping for her staff, or reeling from a parry.
func punishable() -> bool:
	return is_staggered() or state == "fumble"


func stagger() -> void:
	if state in ["dormant", "intro", "dying", "sunk"]:
		return
	_fizzle()
	super.stagger()
	_stagger = 1.2
	velocity = Vector2.ZERO
	Sfx.play("hag_fumble", 0.1, -4.0)


func _modify_damage(damage: int, _dir: Vector2) -> int:
	if state in ["dormant", "intro", "dying", "sunk"]:
		return 0
	# A thrown dagger stings her but takes a blow to break the spell (pass 188).
	if is_hexing() and not thrown:
		_break_hex()
		return damage
	if punishable():
		return damage
	return ceili(damage * GUARD)


func take_hit(damage: int, dir: Vector2) -> void:
	super.take_hit(damage, dir)
	# A boss shrugs off hitstun: blows never interrupt its attacks.
	_hitstun = 0.0
	if not dead and phase == 1 and health_fraction() <= PHASES[0]:
		phase = 2
		Sfx.play("matriarch_cackle", 0.0, 5.0)
		Feel.add_trauma(0.3)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_clamp_to_arena()


func _think(delta: float) -> void:
	if is_staggered():
		velocity.x = 0.0
		return
	var dx := _player_dx()
	match state:
		"dormant":
			velocity.x = 0.0
		"intro":
			velocity.x = 0.0
			if state_time >= INTRO_TIME:
				set_state("walk")
		"walk":
			face_player()
			# She keeps her distance, drifting off to arm's length and a bit.
			var want := 0.0
			if absf(dx) < SHY * 1.6:
				want = -facing * WALK_SPEED
			elif absf(dx) > SHY * 3.0:
				want = facing * WALK_SPEED
			velocity.x = want
			_crowded = _crowded + delta if absf(dx) < SHY else 0.0
			if _crowded >= SHY_TIME:
				_crowded = 0.0
				set_state("sink_tell")
				Sfx.play("bog_sink", 0.05, 0.0)
			elif state_time >= 0.9 and is_on_floor():
				_choose()
		"hex_tell":
			velocity.x = 0.0
			if state_time >= tell(HEX_TELL):
				for m in marks():
					m.erupt()
				_marks.clear()
				set_state("cast")
				Sfx.play("mire_grasp", 0.06, 2.0)
		"cast":
			velocity.x = 0.0
			if state_time >= CAST:
				set_state("walk")
		"fumble":
			velocity.x = 0.0
			if state_time >= FUMBLE:
				set_state("walk")
		"sink_tell":
			velocity.x = 0.0
			if state_time >= tell(SINK_TELL):
				_sink()
		"sunk":
			velocity.x = 0.0
			if state_time >= SUNK:
				_rise()
		"rise":
			velocity.x = 0.0
			if state_time >= RISE:
				set_state("walk")
		"call_tell":
			velocity.x = 0.0
			if state_time >= tell(CALL_TELL):
				_call_daughter()
				set_state("cast")
				Sfx.play("bog_rise", 0.06, 0.0)
		_:
			set_state("walk")


func _choose() -> void:
	face_player()
	_moves += 1
	if phase == 2 and _moves % 3 == 0 and daughter() == null:
		set_state("call_tell")
		Sfx.play("matriarch_cackle", 0.06, 0.0)
	elif not _begin_hex():
		set_state("walk")


## Marks the floor under you and to either side and raises the staff. False when
## there is no floor under you to mark.
func _begin_hex() -> bool:
	var p := player()
	var room := get_parent() as Room
	if p == null or room == null:
		return false
	var count := MARKS if phase == 1 else MARKS_PHASE2
	var made := 0
	for i in count:
		var off := (i - (count - 1) * 0.5) * MARK_GAP
		var x := clampf(p.global_position.x + off, arena.position.x + 8.0, arena.end.x - 8.0)
		var foot := MireGrasp.floor_below(room, Vector2(x, p.global_position.y))
		if foot == Vector2.INF:
			continue
		var m := MireGrasp.new()
		m.hag = self
		room.add_child(m)
		m.global_position = foot
		_marks.append(m)
		made += 1
	if made == 0:
		return false
	set_state("hex_tell")
	Sfx.play("hag_hex", 0.04, 3.0)
	return true


## Struck mid-hex: every mark fizzles and she gropes for her staff.
func _break_hex() -> void:
	_fizzle()
	set_state("fumble")
	Sfx.play("hag_fumble", 0.06, -3.0)
	_dust(Vector2(facing * 14.0, -6.0), "splash")


func _fizzle() -> void:
	for m in marks():
		m.fizzle()
	_marks.clear()


func _sink() -> void:
	set_state("sunk")
	collision_layer = 0
	visible = false
	_dust(Vector2.ZERO, "splash")


## Rises at the far end of the mire from you.
func _rise() -> void:
	var p := player()
	var mid := arena.get_center().x
	var px := p.global_position.x if p != null else mid
	global_position.x = arena.position.x + 48.0 if px > mid else arena.end.x - 48.0
	collision_layer = Player.LAYER_ENEMY
	visible = true
	face_player()
	set_state("rise")
	Sfx.play("bog_rise", 0.05, 0.0)
	_dust(Vector2.ZERO, "splash")


## A daughter climbs out of the bog at the far side, facing you.
func _call_daughter() -> void:
	var room := get_parent() as Room
	if room == null:
		return
	var p := player()
	var mid := arena.get_center().x
	var px := p.global_position.x if p != null else mid
	var h := MarshHag.new()
	h.position = Vector2(arena.position.x + 40.0 if px > mid else arena.end.x - 40.0, arena.end.y)
	h.respawn_time = 0.0
	room.add_child(h)
	_daughter = h
	_dust(h.position - global_position, "splash")


func _clamp_to_arena() -> void:
	var half := body_size.x * 0.5
	global_position.x = clampf(global_position.x, arena.position.x + half, arena.end.x - half)


func _player_dx() -> float:
	var p := player()
	return p.global_position.x - global_position.x if p != null else 0.0


func _dust(offset: Vector2, kind: String) -> void:
	var d := Dust.new()
	d.setup(kind)
	get_parent().add_child(d)
	d.global_position = global_position + offset


func die() -> void:
	if state == "dying":
		return
	_fizzle()
	if daughter() != null:
		_daughter.take_hit(_daughter.hp, Vector2.RIGHT)
	visible = true
	set_state("dying")
	dead = true
	collision_layer = 0
	velocity = Vector2.ZERO
	Feel.boss_kill(1.0)
	Feel.add_trauma(0.6)
	Sfx.play("bog_sink", 0.0, 4.0)


func _process(delta: float) -> void:
	light_radius = 0.0 if not visible else (110.0 if state in ["hex_tell", "call_tell"] else 72.0)
	if state != "dying":
		return
	state_time += delta
	if int(state_time * 10.0) % 3 == 0:
		_dust(Vector2(_rng.randf_range(-14, 14), _rng.randf_range(-40, -4)), "splash")
	if state_time >= DYING_TIME:
		state = "dead"
		defeated.emit()
		super.die()


func _draw() -> void:
	if not visible:
		return
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1))
	var hot := state.ends_with("_tell") and telegraph_pulse()
	var sink := 0
	match state:
		"sink_tell":
			sink = int(state_time / SINK_TELL * 8.0)
		"rise":
			sink = 8 - int(state_time / RISE * 8.0)
		"dying":
			sink = int(state_time / DYING_TIME * 14.0)
	var raise := 3 if state in ["hex_tell", "call_tell", "cast"] else 0
	var by := -15 + sink
	# The shawl of reeds: a wide bell of dry stalks over the bog.
	_px(-9, by - 4, 18, 19 - sink, OUTLINE)
	_px(-8, by - 3, 16, 17 - sink, REED)
	for k in 5:
		_px(-7 + k * 3, by, 1, 13 - sink, REED_DARK)
	# Her face, hunched under a heap of moss.
	_px(-1, by - 9, 8, 7, OUTLINE)
	_px(0, by - 8, 6, 5, SKIN)
	_px(3, by - 7, 2, 1, EYE if not hot else Color.WHITE)
	_px(-3, by - 12, 11, 4, MOSS)
	_px(-2, by - 13, 6, 2, MOSS_LIGHT)
	_px(-5, by - 9, 3, 9, MOSS)
	# The staff: a crooked willow with the great wisp in its crook.
	var sx := 9
	_px(sx, by - 14 - raise, 2, 29 - sink + raise, STAFF)
	_px(sx - 1, by - 16 - raise, 4, 2, STAFF)
	var glow := WISP_LIGHT if hot else WISP
	draw_circle(Vector2((sx + 1) * SCALE * 0.5, (by - 19 - raise) * SCALE * 0.5), 5.0 + (2.0 if hot else 0.0), Color(glow, 0.35))
	_px(sx - 1, by - 21 - raise, 4, 4, glow)
	if state == "fumble":
		# The staff lies in the mud; she gropes for it.
		_px(4, -2, 14, 2, STAFF)
	wash(flashing())
	draw_set_transform(Vector2.ZERO)


## Draws a rect of the design (laid out in units of 1/SCALE half-pixels),
## snapped to the half-pixel grid so neighbouring rects still tile.
func _px(x: int, y: int, w: int, h: int, color: Color) -> void:
	var x0 := floorf(x * SCALE)
	var y0 := floorf(y * SCALE)
	var x1 := maxf(floorf((x + w) * SCALE), x0 + 1.0)
	var y1 := maxf(floorf((y + h) * SCALE), y0 + 1.0)
	draw_rect(Rect2(x0 * 0.5, y0 * 0.5, (x1 - x0) * 0.5, (y1 - y0) * 0.5), color)
