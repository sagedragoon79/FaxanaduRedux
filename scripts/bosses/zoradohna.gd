class_name Zoradohna
extends Enemy
## Zoradohna, the Hammer of Forepaw (design bible 8.2): a dwarf champion fused
## with a walking siege drill. The boss of the Tower of Trunk.
##
## The iron hull shrugs off sword blows from the side (a quarter gets through).
## Its exhaust stacks and cockpit are on top: strike down onto it, bouncing off
## the vents with the Mattock, to deal full damage. Driving the drill into a
## wall or the floor leaves it stuck and open to any blow.
##
## Phase 1: drill charges (spins up, then rams across the shaft) and stomps
##   (rears up, then slams a shockwave out each way).
## Phase 2 (below 65%): the lift starts rising. Debris rains from the shaft,
##   and the drill climbs the wall, marks a spot on the floor and dives at it.
## Phase 3 (below 30%): the cockpit bursts open on the crystal harness that
##   binds the dwarf. Only blows from above land now, but they land hard.
## Every tell is at least Enemy.MIN_TELEGRAPH.

signal defeated

const DISPLAY_NAME := "Zoradohna"
const EPITHET := "Hammer of Forepaw"
const SHEET := "zoradohna"
const MAX_HP := 260
const PHASES := [0.65, 0.3]
const WALK_SPEED := 55.0
const WALK_TIME := 0.8
const DRILL_TELL := 0.8
const SLAM_TELL := 0.7
const DIVE_TELL := 0.7
const DRILL_SPEED := 270.0
const DRILL_MAX := 3.0
const DRILL_DAMAGE := 24
const SLAM_DAMAGE := 22
const SLAM_RANGE := 90.0
const STUCK_TIME := 1.5
const DIVE_STUCK := 1.1
const RECOVER := 0.6
const CLIMB_SPEED := 160.0
const DIVE_SPEED := 380.0
const SIDE_ARMOR := 0.25
## Damage multiplier on the exposed harness (phase 3, from above).
const HARNESS := 1.5
const DEBRIS_EVERY := 2.4
const OPEN_TIME := 1.3
const INTRO_TIME := 1.6
const DYING_TIME := 1.8
## Phase 2 and 3 tells are this fraction as long.
const FAST := 0.8

## The shaft's interior in pixels (walls and ceiling outside it).
var arena := Rect2(16, 64, 608, 256)
var phase := 1
## True while the lift is rising (phase 2 on). The arena's LiftShaft reads it.
var rising := false
## Where a dive will land (shown while it is telegraphed).
var dive_target := Vector2.ZERO
var _since_climb := 0
var _last := ""
var _debris_timer := 0.0
var _stuck_for := STUCK_TIME
var _rng := RandomNumberGenerator.new()


func _init() -> void:
	max_hp = MAX_HP
	contact_damage = 20
	gold_min = 120
	gold_max = 160
	xp = 300
	body_size = Vector2(50, 46)
	knockback = 0.0
	state = "dormant"
	_rng.seed = 1990


func _ready() -> void:
	super._ready()
	add_to_group("boss")


## Starts the fight (called by the arena once the player is inside).
func begin() -> void:
	face_player()
	set_state("intro")
	Sfx.play("whir", 0.0, 4.0)
	Sfx.play("roar", 0.0, -4.0)
	Feel.add_trauma(0.4)
	GameState.banner.emit(DISPLAY_NAME, EPITHET)


func health_fraction() -> float:
	return clampf(float(hp) / max_hp, 0.0, 1.0)


## Jumps to health fraction `f` and the phase it belongs to (screenshots, tests).
func set_health_fraction(f: float) -> void:
	hp = maxi(1, roundi(MAX_HP * f))
	phase = 3 if f <= PHASES[1] else (2 if f <= PHASES[0] else 1)
	rising = phase >= 2


func tell(base: float) -> float:
	return maxf(Enemy.MIN_TELEGRAPH, base * (FAST if phase >= 2 else 1.0))


## Its opening (Enemy.punishable): rammed into a wall or the floor, the drill is stuck.
func punishable() -> bool:
	return stuck()


func stuck() -> bool:
	return state == "stuck"


func cockpit_open() -> bool:
	return phase >= 3 and state != "opening"


func _modify_damage(damage: int, dir: Vector2) -> int:
	if state in ["dormant", "intro", "opening", "dying"]:
		return 0
	var from_above := dir.y > 0.0
	if cockpit_open():
		return roundi(damage * HARNESS) if from_above else 0
	if from_above or stuck():
		return damage
	return maxi(1, roundi(damage * SIDE_ARMOR))


func take_hit(damage: int, dir: Vector2) -> void:
	super.take_hit(damage, dir)
	# A boss shrugs off hitstun: blows never interrupt its attacks.
	_hitstun = 0.0
	if dead:
		return
	if phase == 1 and health_fraction() <= PHASES[0]:
		phase = 2
		rising = true
		_debris_timer = 1.0
		Sfx.play("rumble", 0.0, 4.0)
		Feel.add_trauma(0.5)
		GameState.toast.emit("The lift lurches upward!")
	elif phase == 2 and health_fraction() <= PHASES[1]:
		phase = 3
		uses_gravity = true
		set_state("opening")
		Sfx.play("break", 0.0, 4.0)
		Feel.add_trauma(0.6)
		GameState.toast.emit("The cockpit bursts open. Free him: strike the crystal from above!")


func _on_blocked(_dir: Vector2) -> void:
	Sfx.play("guard", 0.1, -4.0)


## Iron never staggers from a parry.
func stagger() -> void:
	pass


func _think(delta: float) -> void:
	if not state in ["climb", "dive_tell", "dive"]:
		velocity.x = 0.0
	if rising and state != "dormant":
		_debris_timer -= delta
		if _debris_timer <= 0.0:
			_debris_timer = DEBRIS_EVERY
			_debris()
	match state:
		"dormant":
			pass
		"intro":
			if state_time >= INTRO_TIME:
				set_state("walk")
		"opening":
			if state_time >= OPEN_TIME:
				set_state("walk")
		"walk":
			face_player()
			var dx := _player_dx()
			if absf(dx) > 30.0:
				velocity.x = signf(dx) * WALK_SPEED
			if state_time >= WALK_TIME:
				_choose(absf(dx))
		"drill_tell":
			if int(state_time * 20.0) % 3 == 0:
				_dust(Vector2(-facing * 18.0, 0), "run")
			if state_time >= tell(DRILL_TELL):
				set_state("drill")
				Sfx.play("whir", 0.0, 2.0)
		"drill":
			velocity.x = facing * DRILL_SPEED
			hit_player_in_rect(drill_rect(), DRILL_DAMAGE, false)
			if int(state_time * 12.0) % 2 == 0:
				_dust(Vector2(-facing * 16.0, 0), "run")
			if is_on_wall() and state_time > 0.1:
				_bury(STUCK_TIME)
			elif state_time >= DRILL_MAX:
				set_state("recover")
		"slam_tell":
			if state_time >= tell(SLAM_TELL):
				_slam()
		"slam", "recover":
			if state_time >= RECOVER:
				set_state("walk")
		"stuck":
			if state_time >= _stuck_for:
				set_state("recover")
		"climb":
			# Run at the nearer wall, then crawl up it on the drill's grip.
			velocity.x = 0.0
			var wall_x := arena.position.x + 30.0 if facing < 0 else arena.end.x - 30.0
			# (A sealed doorway is a wall too: climb wherever the hull meets one.)
			if absf(global_position.x - wall_x) > 4.0 and is_on_floor() and not (is_on_wall() and state_time > 0.1) and state_time < 2.0:
				velocity.x = signf(wall_x - global_position.x) * DRILL_SPEED * 0.8
			else:
				uses_gravity = false
				velocity = Vector2(0, -CLIMB_SPEED)
				if global_position.y <= arena.position.y + 70.0 or state_time > 3.0:
					velocity = Vector2.ZERO
					var p := player()
					dive_target = Vector2(p.global_position.x if p != null else arena.get_center().x, arena.end.y)
					dive_target.x = clampf(dive_target.x, arena.position.x + 40.0, arena.end.x - 40.0)
					facing = int(signf(dive_target.x - global_position.x)) if absf(dive_target.x - global_position.x) > 2.0 else facing
					set_state("dive_tell")
					Sfx.play("tell_heavy", 0.05, -2.0)
		"dive_tell":
			velocity = Vector2.ZERO
			if state_time >= tell(DIVE_TELL):
				set_state("dive")
				Sfx.play("whir", 0.0, 4.0)
		"dive":
			velocity = (dive_target - global_position).normalized() * DIVE_SPEED
			hit_player_in_rect(drill_rect(), DRILL_DAMAGE, false)
			if is_on_floor() or global_position.y >= dive_target.y - 1.0 or state_time > 1.5:
				uses_gravity = true
				velocity = Vector2.ZERO
				_shockwaves(global_position)
				_bury(DIVE_STUCK)
		_:
			set_state("walk")



func _choose(dist: float) -> void:
	var pick := "drill"
	if dist <= SLAM_RANGE:
		pick = "slam"
	if phase == 2 and _since_climb >= 2:
		pick = "climb"
	if pick == _last and pick == "slam":
		pick = "drill"
	_last = pick
	_since_climb = 0 if pick == "climb" else _since_climb + 1
	face_player()
	if pick == "climb":
		# Head for the wall behind it, away from the player.
		facing = -facing
		set_state("climb")
		Sfx.play("whir", 0.1, -2.0)
		return
	set_state(pick + "_tell")
	# Heard as it starts (bible 13.3): the drill spinning up, the hull heaving to slam.
	Sfx.play("tell_charge" if pick == "drill" else "tell_heavy", 0.05, -2.0)


## The drill's reach in front of the hull.
func drill_rect() -> Rect2:
	if state == "dive":
		return Rect2(global_position + Vector2(-20, -10), Vector2(40, 22))
	var x0 := global_position.x + (facing * 20.0 if facing > 0 else -50.0)
	return Rect2(x0, global_position.y - 46.0, 30.0, 26.0)


func slam_rect() -> Rect2:
	return Rect2(global_position.x - 44.0, global_position.y - 20.0, 88.0, 20.0)


func _slam() -> void:
	set_state("slam")
	hit_player_in_rect(slam_rect(), SLAM_DAMAGE, false)
	_shockwaves(global_position)


func _shockwaves(at: Vector2) -> void:
	Sfx.play("break", 0.05, 2.0)
	Feel.add_trauma(0.5)
	Feel.rumble(0.8, 0.8, 0.25)
	_dust(Vector2(0, 0), "debris")
	for dir in [-1, 1]:
		var w := Shockwave.new()
		w.room = get_parent() as Room
		w.direction = dir
		get_parent().add_child(w)
		w.global_position = Vector2(at.x + dir * 30.0, arena.end.y)


## Drives the drill in: stuck for `time`, open to any blow.
func _bury(time: float) -> void:
	_stuck_for = time
	set_state("stuck")
	Sfx.play("break", 0.0, 3.0)
	Feel.hitstop(0.08)
	Feel.add_trauma(0.6)
	_dust(Vector2(facing * 34.0, -30.0), "debris")


## The rising lift scrapes debris loose: one rock over the player, one elsewhere.
func _debris() -> void:
	var room := get_parent() as Room
	var p := player()
	var xs: Array[float] = []
	if p != null:
		xs.append(p.global_position.x)
	var x := _rng.randf_range(arena.position.x + 24.0, arena.end.x - 24.0)
	if xs.is_empty() or absf(xs[0] - x) > 48.0:
		xs.append(x)
	for rx in xs:
		var r := Rubble.new()
		r.mode = "fall"
		r.room = room
		r.floor_y = arena.end.y
		room.add_child(r)
		r.global_position = Vector2(rx, arena.position.y + 4.0)


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
	rising = false
	uses_gravity = true
	collision_layer = 0
	velocity = Vector2.ZERO
	Feel.boss_kill(1.0)
	Feel.add_trauma(0.8)
	Sfx.play("break", 0.0, 4.0)


func _process(delta: float) -> void:
	if state != "dying":
		return
	state_time += delta
	if int(state_time * 10.0) % 3 == 0 and state_time < DYING_TIME * 0.7:
		_dust(Vector2(_rng.randf_range(-24, 24), _rng.randf_range(-50, -6)), "debris")
	if state_time >= DYING_TIME:
		state = "dead"
		GameState.toast.emit("The harness shatters. The dwarf of Forepaw is free.")
		defeated.emit()
		super.die()


func _draw() -> void:
	var white := flashing() or (state.ends_with("_tell") and telegraph_pulse())
	var anim := "idle"
	var jitter := Vector2.ZERO
	var aim := Vector2.ZERO  # world direction the drill points, when turned
	match state:
		"walk":
			anim = "walk" if absf(velocity.x) > 1.0 else "idle"
		"drill_tell", "drill", "slam_tell", "slam", "stuck":
			anim = state
		"climb":
			anim = "drill" if not uses_gravity else "walk"
			if not uses_gravity:
				aim = Vector2.UP
		"dive_tell":
			anim = "drill_tell"
			aim = dive_target - global_position
		"dive":
			anim = "drill"
			aim = dive_target - global_position
		"opening":
			anim = "stuck"
			jitter = Vector2(randf_range(-2, 2), 0).round()
			white = int(state_time * 14.0) % 2 == 0
		"dying":
			anim = "freed"
			jitter = Vector2(randf_range(-2, 2), 0).round() if state_time < DYING_TIME * 0.6 else Vector2.ZERO
			white = state_time < DYING_TIME * 0.6 and int(state_time * 12.0) % 2 == 0
		_:
			anim = "idle"
	if phase >= 3 and anim != "freed":
		anim = "open_" + anim
	if state == "drill_tell":
		jitter = Vector2(randf_range(-1, 1), 0).round()
	if state == "dive_tell":
		_draw_target()
	if aim != Vector2.ZERO:
		# Climbing and diving: turn the whole machine about its middle so the
		# drill points along `aim`.
		var mid := Vector2(0, -24)
		var angle := aim.angle() - (0.0 if facing > 0 else PI)
		var xf := Transform2D(0.0, mid + jitter) * Transform2D(angle, Vector2.ZERO) \
			* Transform2D(0.0, Vector2(facing, 1), 0.0, Vector2.ZERO) * Transform2D(0.0, -mid)
		draw_set_transform_matrix(xf)
		var f := Sheet.frame_at(SHEET, anim, state_time)
		Sheet.draw(self, SHEET, anim, f)
		if white:
			Sheet.draw(self, SHEET, anim, f, Color(1, 1, 1, 0.85), true)
		draw_set_transform_matrix(Transform2D.IDENTITY)
		return
	draw_sheet(SHEET, anim, state_time, white, jitter)


## A pulsing ring on the floor where the dive will land.
func _draw_target() -> void:
	var at := dive_target - global_position
	var k := 0.5 + 0.5 * sin(state_time * 30.0)
	var c := Color(1.0, 0.35, 0.2, 0.5 + 0.4 * k)
	draw_arc(at + Vector2(0, -2), 18.0 - 4.0 * k, 0.0, TAU, 24, c, 2.0)
	draw_line(at + Vector2(-24, -1), at + Vector2(24, -1), c, 1.0)
