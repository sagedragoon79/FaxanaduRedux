class_name ClockworkAlpha
extends Enemy
## The Clockwork Alpha (design bible 7 and 8): the first of King Grieve's brass
## hounds, as big as a pony, wound by the king's own hand with a key the size of
## a shield. The mini-boss of Dartmoor, in its den under the King's Kennels
## (legend: room header `boss: clockwork_alpha`).
##
## It trots after the player and picks one of two attacks:
## - Pounce (near): it crouches and its key spins up, eyes blazing (tell), then
##   leaps in a long low arc to land on you and bite. Parry the bite and it is
##   thrown on its back, belly gears bare.
## - Charge (far): it plants its feet and its key screams (tell), then it runs
##   the length of the den. If it meets a wall its spring jams: it stands
##   stunned, gears spilling, until it shakes itself free.
## Below half health (phase 2) its tells are shorter (never under
## Enemy.MIN_TELEGRAPH) and it can howl (tell): its key winds two brass pups
## out of the kennel grates, never more than two at once.
## Its plating turns half of every blow except while it is on its back, jammed,
## or stopped: it is clockwork, so the Hour Glass stops it dead where it stands,
## and a stopped Alpha takes every blow in full.

signal defeated

const DISPLAY_NAME := "The Clockwork Alpha"
const EPITHET := "First Hound of King Grieve"
const MAX_HP := 260
const PHASES := [0.5]
const TROT := 70.0
const TROT_TIME := 0.8
## It pounces when you are nearer than this (px, centre to centre); farther, it charges.
const POUNCE_RANGE := 150.0
const POUNCE_TELL := 0.6
const CHARGE_TELL := 0.7
const HOWL_TELL := 0.8
## Phase 2 tells are this fraction as long.
const FAST := 0.75
## Its leap: the rise, and the most it covers across (px/s); it aims to land on you.
const POUNCE := Vector2(360, -260)
const BITE_DAMAGE := 18
const CHARGE_SPEED := 300.0
const CHARGE_SPEED_P2 := 340.0
const CHARGE_DAMAGE := 20
const CHARGE_MAX := 2.6
const SKID := 0.55
const RECOVER := 0.5
## A wall jams its spring this long; a parry throws it on its back this long.
const JAMMED := 1.6
const FLIPPED := 1.5
## The share of a blow its plating lets through, outside its openings.
const PLATING := 0.5
const MAX_PUPS := 2
const INTRO_TIME := 1.4
const DYING_TIME := 1.4
## The drawing is laid out small and drawn this much larger.
const SCALE := 3.0

const OUTLINE := Color("1a120c")
const BRASS := Color("c8913a")
const BRASS_LIGHT := Color("f0c870")
const BRASS_DARK := Color("7a5222")
const STEEL := Color("8a96a0")
const BELLY := Color("5a4a3a")
const GEAR := Color("e0b050")
const CROWN := Color("ffd24a")
const EYE := Color("ff5a3a")
const EYE_HOT := Color("ffe0a0")

## The den's interior in pixels (walls and ceiling outside it).
var arena := Rect2(16, 64, 608, 256)
var phase := 1
var pups: Array[ClockworkHound] = []
var _bitten := false
var _rammed := false
var _howls := 0
var _key := 0.0
var _rng := RandomNumberGenerator.new()


func _init() -> void:
	max_hp = MAX_HP
	contact_damage = 12
	gold_min = 70
	gold_max = 90
	xp = 140
	body_size = Vector2(44, 30)
	knockback = 0.0
	launchable = false
	state = "dormant"
	_rng.seed = 1987


func _ready() -> void:
	super._ready()
	add_to_group("boss")


## Starts the fight (called by the arena once the player is inside).
func begin() -> void:
	face_player()
	set_state("intro")
	Sfx.play("ratchet", 0.0, 2.0)
	Feel.add_trauma(0.3)
	GameState.banner.emit(DISPLAY_NAME, EPITHET)


func health_fraction() -> float:
	return clampf(float(hp) / max_hp, 0.0, 1.0)


func tell(base: float) -> float:
	return maxf(Enemy.MIN_TELEGRAPH, base * (FAST if phase == 2 else 1.0))


## On its back after a parry, belly gears bare.
func flipped() -> bool:
	return is_staggered()


func jammed() -> bool:
	return state == "jammed"


## Held by the Hour Glass: clockwork stops dead.
func stopped() -> bool:
	return TimeStop.active() and not dead and state != "dormant"


## Its opening (Enemy.punishable): on its back, jammed against a wall, or stopped.
func punishable() -> bool:
	return flipped() or jammed() or stopped()


func stagger() -> void:
	if state in ["dormant", "intro", "dying"]:
		return
	super.stagger()
	_stagger = FLIPPED
	set_state("skid")
	velocity = Vector2(-facing * 80.0, -160.0)
	Sfx.play("guard", 0.1, -2.0)


func _modify_damage(damage: int, _dir: Vector2) -> int:
	if state in ["dormant", "intro", "dying"]:
		return 0
	if punishable():
		return damage
	return maxi(1, roundi(damage * PLATING))


func take_hit(damage: int, dir: Vector2) -> void:
	super.take_hit(damage, dir)
	# A boss shrugs off hitstun: blows never interrupt its attacks.
	_hitstun = 0.0
	if not dead and phase == 1 and health_fraction() <= PHASES[0]:
		phase = 2
		Sfx.play("ratchet", 0.0, 4.0)
		Feel.add_trauma(0.3)


func _physics_process(delta: float) -> void:
	# Clockwork: stopped time stops it dead, in the air or not.
	if stopped():
		_flash -= delta
		queue_redraw()
		return
	super._physics_process(delta)
	_clamp_to_arena()


func _think(delta: float) -> void:
	pups = pups.filter(func(h: ClockworkHound) -> bool: return is_instance_valid(h) and not h.dead)
	_key += delta * (16.0 if state.ends_with("_tell") else 3.0)
	if flipped():
		velocity.x = move_toward(velocity.x, 0.0, 300.0 * delta)
		return
	match state:
		"dormant":
			velocity.x = 0.0
		"intro":
			velocity.x = 0.0
			if state_time >= INTRO_TIME:
				set_state("trot")
		"trot":
			face_player()
			var dx := _player_dx()
			velocity.x = signf(dx) * TROT if absf(dx) > 30.0 else 0.0
			if state_time >= TROT_TIME and is_on_floor():
				_choose(absf(dx))
		"pounce_tell":
			velocity.x = 0.0
			if state_time >= tell(POUNCE_TELL):
				_pounce()
		"pounce":
			if not _bitten and hit_player_in_rect(bite_rect(), BITE_DAMAGE) != "":
				_bitten = true
			if state == "pounce" and state_time > 0.1 and is_on_floor():
				set_state("skid")
		"skid":
			velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
			if state_time >= SKID:
				set_state("trot")
		"charge_tell":
			velocity.x = 0.0
			if state_time >= tell(CHARGE_TELL):
				_rammed = false
				set_state("charge")
				Sfx.play("dash", 0.05, 2.0)
		"charge":
			velocity.x = facing * (CHARGE_SPEED_P2 if phase == 2 else CHARGE_SPEED)
			if not _rammed and hit_player_in_rect(body_rect().grow(2.0), CHARGE_DAMAGE, false) != "":
				_rammed = true
			if is_on_wall() and state_time > 0.1:
				_jam()
			elif state_time >= CHARGE_MAX:
				set_state("recover")
		"jammed":
			velocity.x = 0.0
			if state_time >= JAMMED:
				set_state("recover")
		"howl_tell":
			velocity.x = 0.0
			if state_time >= tell(HOWL_TELL):
				_howl()
		"howl", "recover":
			velocity.x = 0.0
			if state_time >= RECOVER:
				set_state("trot")
		_:
			set_state("trot")


func _choose(dist: float) -> void:
	face_player()
	if phase == 2 and pups.size() < MAX_PUPS and _howls < 3 and _rng.randf() < 0.4:
		set_state("howl_tell")
		Sfx.play("ratchet", 0.1, 0.0)
	elif dist < POUNCE_RANGE:
		set_state("pounce_tell")
		Sfx.play("ratchet", 0.1, -2.0)
	else:
		set_state("charge_tell")
		Sfx.play("tell_charge", 0.05, 0.0)


func _pounce() -> void:
	_bitten = false
	var air := 2.0 * -POUNCE.y / GRAVITY
	var dx := _player_dx()
	var across := clampf(absf(dx) / air, 120.0, POUNCE.x)
	velocity = Vector2(facing * across, POUNCE.y)
	set_state("pounce")
	Sfx.play("slash", 0.15, -2.0)


func _jam() -> void:
	set_state("jammed")
	Sfx.play("break", 0.0, 2.0)
	Feel.hitstop(0.06)
	Feel.add_trauma(0.5)
	_dust(Vector2(facing * 22.0, -18.0), "debris")


## Winds a brass pup out of the grate at each end of the den, up to MAX_PUPS.
func _howl() -> void:
	set_state("howl")
	_howls += 1
	Sfx.play("roar", 0.1, -6.0)
	var room := get_parent() as Room
	for side in [-1, 1]:
		if pups.size() >= MAX_PUPS:
			break
		var h := ClockworkHound.new()
		h.position = Vector2(arena.position.x + 40.0 if side < 0 else arena.end.x - 40.0, arena.end.y)
		h.home = h.position
		room.add_child(h)
		pups.append(h)
		_dust(h.position - global_position + Vector2(0, -8), "debris")


## Where its jaws close: ahead of the body, at head height.
func bite_rect() -> Rect2:
	var c := center()
	return Rect2(c.x - 8.0 + facing * 18.0, c.y - 14.0, 24.0, 22.0)


func body_rect() -> Rect2:
	return Rect2(global_position - Vector2(body_size.x * 0.5, body_size.y), body_size)


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
	set_state("dying")
	dead = true
	collision_layer = 0
	velocity = Vector2.ZERO
	for h in pups:
		if is_instance_valid(h) and not h.dead:
			h.die()
	Feel.boss_kill(1.0)
	Feel.add_trauma(0.7)
	Sfx.play("break", 0.0, 4.0)


func _process(delta: float) -> void:
	if state != "dying":
		return
	state_time += delta
	if int(state_time * 10.0) % 3 == 0:
		_dust(Vector2(_rng.randf_range(-20, 20), _rng.randf_range(-30, -4)), "debris")
	if state_time >= DYING_TIME:
		state = "dead"
		defeated.emit()
		super.die()


func _draw() -> void:
	var t := Time.get_ticks_msec() * 0.001
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1))
	var still := stopped()
	if flipped():
		_draw_flipped(t)
	else:
		var crouch := 0
		var stride := 0
		var stretch := 0
		var shake := 0
		match state:
			"pounce_tell", "charge_tell", "howl_tell":
				crouch = mini(int(state_time / maxf(tell(POUNCE_TELL), 0.01) * 3.0) + 1, 3)
				if state == "howl_tell":
					crouch = 0
			"pounce", "charge":
				stretch = 3
			"trot":
				if not still:
					stride = roundi(sin(t * 12.0) * 2.0)
			"jammed", "dying":
				shake = roundi(sin(t * 50.0))
		var by := -11 + crouch
		# Legs: four thick brass struts.
		for leg: Array in [[-10, stride], [-6, -stride], [6, -stride], [10, stride]]:
			var lx: int = leg[0] + (leg[1] if stretch == 0 else (-3 if leg[0] < 0 else 3))
			_px(lx - 1 + shake, by + 6, 4, 6 - crouch, OUTLINE)
			_px(lx + shake, by + 6, 2, 5 - crouch, STEEL)
		# Body: a long riveted barrel.
		_px(-14 - stretch + shake, by - 2, 29 + stretch * 2, 10, OUTLINE)
		_px(-13 - stretch + shake, by - 1, 27 + stretch * 2, 8, BRASS)
		_px(-13 - stretch + shake, by - 1, 27 + stretch * 2, 2, BRASS_LIGHT)
		_px(-13 - stretch + shake, by + 5, 27 + stretch * 2, 2, BRASS_DARK)
		for rx in [-10, -5, 0, 5, 10]:
			_px(rx + shake, by + 2, 1, 1, BRASS_DARK)
		# Tail: a coiled steel spring.
		_px(-17 - stretch, by - 4, 4, 3, OUTLINE)
		_px(-16 - stretch, by - 3, 3, 1, STEEL)
		# Head and the king's collar: a ring of gold points behind the jaw.
		var hx := 12 + stretch + shake
		var hy := by - 6 + (1 if crouch > 0 else 0)
		var gape := 2 if state in ["pounce", "howl", "howl_tell"] else 0
		_px(hx - 2, hy - 1, 3, 9, OUTLINE)
		for k in 3:
			_px(hx - 2, hy + k * 3, 2, 2, CROWN)
		_px(hx - 1, hy - 1, 13, 9, OUTLINE)
		_px(hx, hy, 11, 5, BRASS)
		_px(hx, hy, 11, 1, BRASS_LIGHT)
		_px(hx + 3, hy + 5 + gape, 8, 2, BRASS_DARK)
		if gape > 0:
			for k in 4:
				_px(hx + 4 + k * 2, hy + 5, 1, 1, STEEL)
		_px(hx + 1, hy - 4, 2, 4, OUTLINE)
		_px(hx + 5, hy - 4, 2, 4, OUTLINE)
		var hot := state.ends_with("_tell") and telegraph_pulse()
		_px(hx + 7, hy + 1, 2, 2, EYE_HOT if hot else EYE)
		if state.ends_with("_tell"):
			var k := 0.5 + 0.5 * absf(sin(state_time * 18.0))
			_px(hx + 6, hy, 4, 4, Color(EYE, 0.35 * k))
		if jammed():
			# Gears spilling from the seams.
			for i in 3:
				var gy := by - 4 - int(fmod(state_time * 20.0 + i * 5.0, 10.0))
				_px(-6 + i * 6, gy, 2, 2, GEAR)
		_draw_key(-4, by - 6)
	if still:
		for i in 6:
			var a := TAU * i / 6.0 + 0.4
			_px(roundi(cos(a) * 20.0), -8 + roundi(sin(a) * 12.0), 1, 1, Color(EYE_HOT, 0.8))
	wash(flashing())
	draw_set_transform(Vector2.ZERO)


## The king's winding key, as tall as the hound's back; it spins up before every attack.
func _draw_key(x: int, y: int) -> void:
	var turn := int(_key) % 4
	_px(x, y + 1, 2, 4, OUTLINE)
	_px(x, y + 2, 1, 3, STEEL)
	var w := 10 if turn % 2 == 0 else 4
	_px(x + 1 - w / 2 - 1, y - 3, w + 2, 5, OUTLINE)
	_px(x + 1 - w / 2, y - 2, w, 3, GEAR)


func _draw_flipped(t: float) -> void:
	var kick := roundi(sin(t * 20.0) * 2.0)
	for lx in [-10, -6, 6, 10]:
		_px(lx - 1, -18 + (kick if lx < 0 else -kick), 4, 7, OUTLINE)
		_px(lx, -17 + (kick if lx < 0 else -kick), 2, 6, STEEL)
	_px(-14, -11, 29, 10, OUTLINE)
	_px(-13, -10, 27, 8, BRASS_DARK)
	_px(-11, -11, 23, 3, BELLY)
	for gx in [-8, -2, 4, 10]:
		_px(gx - 1, -10, 3, 3, GEAR)
		_px(gx, -9, 1, 1, OUTLINE)
	_px(12, -8, 11, 6, OUTLINE)
	_px(13, -7, 9, 4, BRASS)


## Draws a rect of the design (laid out in units of 1/SCALE half-pixels),
## snapped to the half-pixel grid so neighbouring rects still tile.
func _px(x: int, y: int, w: int, h: int, color: Color) -> void:
	var x0 := floorf(x * SCALE)
	var y0 := floorf(y * SCALE)
	var x1 := maxf(floorf((x + w) * SCALE), x0 + 1.0)
	var y1 := maxf(floorf((y + h) * SCALE), y0 + 1.0)
	draw_rect(Rect2(x0 * 0.5, y0 * 0.5, (x1 - x0) * 0.5, (y1 - y0) * 0.5), color)
