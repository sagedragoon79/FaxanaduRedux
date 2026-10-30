class_name Foreman
extends Enemy
## The Foreman (design bible 7 and 8): a rock golem the dwarves of Forepaw set
## to work the tower, still wearing a foreman's lamp-helm, with the Mattock
## wedged in its back. The mini-boss of the Tower of Trunk.
##
## It plods after the player and picks one of three attacks:
## - Pound (close): fists overhead (tell), then a two-fisted slam that crushes
##   what is in front of it and sends a shockwave rolling each way.
## - Throw (middle distance): heaves a boulder overhead (tell) and lobs it.
## - Charge (far): crouches and scrapes (tell), then barrels across the hall.
##   If it meets a wall it is stunned, and the shock shakes rocks loose from the
##   ceiling (each marks its spot before it falls). Jump it or get onto a ledge.
## Its rock halves every blow except one from above or while it is stunned.
## Below half health (phase 2) its tells are shorter (never under
## Enemy.MIN_TELEGRAPH), it charges faster, and its pound also shakes rocks down.

signal defeated

const DISPLAY_NAME := "The Foreman"
const EPITHET := "Golem of Forepaw"
const SHEET := "foreman"
const MAX_HP := 220
const PHASES := [0.5]
const WALK_SPEED := 45.0
const WALK_TIME := 0.9
const POUND_RANGE := 84.0
const CHARGE_RANGE := 120.0
const POUND_TELL := 0.75
const THROW_TELL := 0.6
const CHARGE_TELL := 0.85
## Phase 2 tells are this fraction as long.
const FAST := 0.75
const CHARGE_SPEED := 250.0
const CHARGE_SPEED_P2 := 300.0
const CHARGE_MAX := 3.0
const STUN_TIME := 1.8
const RECOVER := 0.7
const POUND_DAMAGE := 22
const POUND_REACH := Vector2(56, 30)
const THROW_FLIGHT := 0.8
const INTRO_TIME := 1.4
const DYING_TIME := 1.2
const ARMOR := 0.5

## The hall's interior in pixels (walls and ceiling outside it).
var arena := Rect2(16, 64, 608, 256)
var phase := 1
var _since_charge := 0
var _last := ""
var _rng := RandomNumberGenerator.new()


func _init() -> void:
	max_hp = MAX_HP
	contact_damage = 20
	gold_min = 60
	gold_max = 80
	xp = 120
	body_size = Vector2(34, 46)
	knockback = 0.0
	state = "dormant"
	_rng.seed = 1987


func _ready() -> void:
	super._ready()
	add_to_group("boss")


## Starts the fight (called by the arena once the player is inside).
func begin() -> void:
	face_player()
	set_state("intro")
	Sfx.play("roar", 0.0, -2.0)
	Feel.add_trauma(0.35)
	GameState.banner.emit(DISPLAY_NAME, EPITHET)


func health_fraction() -> float:
	return clampf(float(hp) / max_hp, 0.0, 1.0)


func tell(base: float) -> float:
	return maxf(Enemy.MIN_TELEGRAPH, base * (FAST if phase == 2 else 1.0))


## Its opening (Enemy.punishable): stunned against a wall. Its rock never
## reels from a parry (stagger below), so that is its only window.
func punishable() -> bool:
	return stunned()


func stunned() -> bool:
	return state == "stunned"


func _modify_damage(damage: int, dir: Vector2) -> int:
	if state in ["dormant", "intro", "dying"]:
		return 0
	if stunned() or is_staggered() or dir.y > 0.0:
		return damage
	return maxi(1, roundi(damage * ARMOR))


func take_hit(damage: int, dir: Vector2) -> void:
	super.take_hit(damage, dir)
	# A boss shrugs off hitstun: blows never interrupt its attacks.
	_hitstun = 0.0
	if not dead and phase == 1 and health_fraction() <= PHASES[0]:
		phase = 2
		Sfx.play("roar", 0.0, -4.0)
		Feel.add_trauma(0.3)


func _on_blocked(_dir: Vector2) -> void:
	pass


## Rock never staggers from a parry.
func stagger() -> void:
	pass


func _think(_delta: float) -> void:
	velocity.x = 0.0
	match state:
		"dormant":
			pass
		"intro":
			if state_time >= INTRO_TIME:
				set_state("walk")
		"walk":
			face_player()
			var dx := _player_dx()
			if absf(dx) > 24.0:
				velocity.x = signf(dx) * WALK_SPEED
			if state_time >= WALK_TIME:
				_choose(absf(dx))
		"pound_tell":
			if state_time >= tell(POUND_TELL):
				_pound()
		"pound", "throw", "recover":
			if state_time >= RECOVER:
				set_state("walk")
		"throw_tell":
			if state_time >= tell(THROW_TELL):
				_throw()
		"charge_tell":
			if int(state_time * 20.0) % 3 == 0:
				_dust(Vector2(-facing * 14.0, 0), "run")
			if state_time >= tell(CHARGE_TELL):
				set_state("charge")
				Sfx.play("dash", 0.05, 2.0)
		"charge":
			velocity.x = facing * (CHARGE_SPEED_P2 if phase == 2 else CHARGE_SPEED)
			if int(state_time * 12.0) % 2 == 0:
				_dust(Vector2(-facing * 12.0, 0), "run")
			if is_on_wall() and state_time > 0.1:
				_hit_wall()
			elif state_time >= CHARGE_MAX:
				set_state("recover")
		"stunned":
			if state_time >= STUN_TIME:
				set_state("recover")
		_:
			set_state("walk")


func _choose(dist: float) -> void:
	var pick := "throw"
	if dist <= POUND_RANGE:
		pick = "pound"
	elif dist >= CHARGE_RANGE or _since_charge >= 3:
		pick = "charge"
	if pick == _last and pick != "charge":
		# Don't repeat the same close or middle attack: charge instead.
		pick = "charge"
	_last = pick
	_since_charge = 0 if pick == "charge" else _since_charge + 1
	face_player()
	set_state(pick + "_tell")
	if pick == "charge":
		Sfx.play("roar", 0.1, -10.0)


func pound_rect() -> Rect2:
	var x0 := global_position.x + (facing * 4.0 if facing > 0 else -POUND_REACH.x - 4.0)
	return Rect2(x0, global_position.y - POUND_REACH.y, POUND_REACH.x, POUND_REACH.y)


func _pound() -> void:
	set_state("pound")
	hit_player_in_rect(pound_rect(), POUND_DAMAGE, false)
	Sfx.play("break", 0.05, 0.0)
	Feel.add_trauma(0.45)
	Feel.rumble(0.7, 0.7, 0.25)
	var at := global_position + Vector2(facing * 26.0, 0)
	_dust(Vector2(facing * 26.0, 0), "debris")
	for dir in [-1, 1]:
		var w := Shockwave.new()
		w.room = get_parent() as Room
		w.direction = dir
		get_parent().add_child(w)
		w.global_position = at + Vector2(dir * 10.0, 0)
	if phase == 2:
		_rockfall(2)


func _throw() -> void:
	set_state("throw")
	var r := Rubble.new()
	r.mode = "thrown"
	r.room = get_parent() as Room
	var from := global_position + Vector2(facing * 6.0, -64.0)
	var p := player()
	var to := p.global_position + Vector2(0, -8) if p != null else from + Vector2(facing * 120.0, 60)
	r.velocity = Rubble.launch(from, to, THROW_FLIGHT)
	get_parent().add_child(r)
	r.global_position = from
	Sfx.play("heavy", 0.1, -2.0)


func _hit_wall() -> void:
	set_state("stunned")
	Sfx.play("break", 0.0, 3.0)
	Feel.hitstop(0.08)
	Feel.add_trauma(0.7)
	Feel.rumble(1.0, 1.0, 0.4)
	_dust(Vector2(facing * 18.0, -24.0), "debris")
	_rockfall(4 if phase == 2 else 3)


## Shakes `count` rocks loose from the ceiling, spread across the hall, one
## of them over the player.
func _rockfall(count: int) -> void:
	var room := get_parent() as Room
	var p := player()
	var xs: Array[float] = []
	if p != null:
		xs.append(p.global_position.x)
	while xs.size() < count:
		var x := _rng.randf_range(arena.position.x + 24.0, arena.end.x - 24.0)
		var near := false
		for o in xs:
			near = near or absf(o - x) < 40.0
		if not near:
			xs.append(x)
	for x in xs:
		var r := Rubble.new()
		r.mode = "fall"
		r.room = room
		r.floor_y = arena.end.y
		room.add_child(r)
		r.global_position = Vector2(x, arena.position.y + 4.0)


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
	Feel.boss_kill(1.0)
	Feel.add_trauma(0.8)
	Sfx.play("roar", 0.0, 2.0)


func _process(delta: float) -> void:
	if state != "dying":
		return
	state_time += delta
	if int(state_time * 10.0) % 3 == 0:
		_dust(Vector2(_rng.randf_range(-16, 16), _rng.randf_range(-44, -6)), "debris")
	if state_time >= DYING_TIME:
		state = "dead"
		defeated.emit()
		super.die()


func _draw() -> void:
	var white := flashing() or (state.ends_with("_tell") and telegraph_pulse())
	var anim := "idle"
	var t := state_time
	var jitter := Vector2.ZERO
	match state:
		"walk":
			anim = "walk" if absf(velocity.x) > 1.0 else "idle"
		"pound_tell", "charge_tell", "throw_tell", "pound", "charge", "stunned", "recover", "throw":
			anim = state
		"dying":
			anim = "stunned"
			jitter = Vector2(randf_range(-2, 2), 0).round()
			white = int(state_time * 12.0) % 2 == 0
		_:
			anim = "idle"
	if state == "charge_tell":
		jitter = Vector2(randf_range(-1, 1), 0).round()
	draw_sheet(SHEET, anim, t, white, jitter)
