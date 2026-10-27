class_name SpringEel
extends Enemy
## A Spring Eel of the Sunken Spring (design bible 7): a long pale eel gone
## blind in the dark water, with a lamp of the spring's light grown on its
## brow. It never leaves the water. It weaves back and forth near where it
## lives; come within about seven tiles and it draws back into an S, its lamp
## blazing, for 0.5 s (the telegraph), then darts straight at where you were
## and bites for 14. The dart stops dead at the water's edge, so the bank is
## safe. Spent, it hangs slack for 0.8 s and takes every blow at half again.
## Legend `l` (a cell of water with the eel in it).

const SWIM := 46.0
const WANDER := 80.0
const SIGHT := 112.0
const COIL := 0.5
const DART := 300.0
const DART_TIME := 0.45
const SLACK := 0.8
const COOLDOWN := 1.0
const BITE := 14
## The drawing is laid out small and drawn this much larger.
const SCALE := 2.0

const OUTLINE := Color("0c1a22")
const SKIN := Color("9ab8b0")
const SKIN_LIGHT := Color("d0e8e0")
const SKIN_DARK := Color("4e6e70")
const FIN := Color("6a9a98")
const LAMP := Color("8af0e8")
const LAMP_CORE := Color("f0fff8")

var water: SwimWater
var _cool := 0.6
var _dir := Vector2.ZERO
var _bit := false


func _init() -> void:
	max_hp = 30
	gold_min = 6
	gold_max = 10
	xp = 16
	contact_damage = 8
	body_size = Vector2(26, 10)
	body_centered = true
	uses_gravity = false
	knockback = 120.0
	state = "swim"


func _modify_damage(damage: int, _dir_in: Vector2) -> int:
	return ceili(damage * 1.5) if state == "slack" else damage


## The room's water, found once it exists (the room adds it after the grid).
func _water() -> SwimWater:
	if water == null or not is_instance_valid(water):
		for c in get_parent().get_children():
			if c is SwimWater:
				water = c
	return water


func _in_water(pos: Vector2) -> bool:
	var w := _water()
	return w == null or w.has_point(pos - w.global_position)


## Moves at `v` this frame unless that would carry its head out of the water.
func _steer(v: Vector2, delta: float) -> bool:
	var ahead := global_position + v * delta + v.normalized() * body_size.x * 0.5
	if v != Vector2.ZERO and not _in_water(ahead):
		velocity = Vector2.ZERO
		return false
	velocity = v
	return true


func _think(delta: float) -> void:
	_cool -= delta
	var off := player_offset()
	var near := off.x != INF and off.length() < SIGHT
	match state:
		"swim", "idle":
			if state == "idle":
				set_state("swim")
			var drift := Vector2(facing * SWIM, sin(state_time * 2.4) * 14.0)
			if absf(global_position.x - home.x) > WANDER and signf(global_position.x - home.x) == facing:
				facing = -facing
			if not _steer(drift, delta):
				facing = -facing
			if near and _cool <= 0.0:
				face_player()
				_dir = off.normalized()
				velocity = Vector2.ZERO
				set_state("coil")
				Sfx.play("eel_lunge", 0.1, -10.0)
		"coil":
			# Draws back away from you, lamp blazing.
			_steer(-_dir * 20.0, delta)
			if off.x != INF:
				_dir = _dir.lerp(off.normalized(), minf(1.0, 4.0 * delta)).normalized()
			if state_time >= COIL:
				_bit = false
				set_state("dart")
				Sfx.play("eel_lunge", 0.05)
		"dart":
			if absf(_dir.x) > 0.1:
				facing = int(signf(_dir.x))
			var moving := _steer(_dir * DART, delta)
			if not _bit and hit_player_in_rect(Rect2(center() + _dir * 10.0 - Vector2(10, 8), Vector2(20, 16)), BITE) != "":
				_bit = true
			if state_time >= DART_TIME or not moving:
				set_state("slack")
		"slack":
			velocity = velocity.move_toward(Vector2.ZERO, 300.0 * delta)
			if state_time >= SLACK:
				_cool = COOLDOWN
				set_state("swim")


func _draw() -> void:
	var t := Time.get_ticks_msec() * 0.001
	var ang := 0.0
	if state in ["coil", "dart"] and _dir != Vector2.ZERO:
		ang = atan2(_dir.y, absf(_dir.x))
	draw_set_transform(Vector2.ZERO, ang * facing, Vector2(facing, 1))
	# The body is a chain of segments along a wave; coiling bunches it into an S.
	var segs := 9
	var amp := 2.5
	var speed := 6.0
	var length := 15.0
	match state:
		"coil":
			amp = 5.0 + 3.0 * minf(1.0, state_time / COIL)
			length = 11.0
			speed = 14.0
		"dart":
			amp = 0.8
			length = 17.0
		"slack":
			amp = 1.2
			speed = 1.5
	var pts: Array[Vector2] = []
	for i in segs:
		var k := float(i) / (segs - 1)
		var x := length * 0.5 - k * length
		var y := sin(t * speed - k * 5.0) * amp * k
		pts.append(Vector2(x, y))
	for pass_i in 2:
		for i in segs:
			var k := float(i) / (segs - 1)
			var r := lerpf(3.4, 1.2, k)
			if pass_i == 0:
				_dot(pts[i], r + 0.6, OUTLINE)
			else:
				_dot(pts[i], r, SKIN)
				_dot(pts[i] + Vector2(0, -r * 0.4), r * 0.45, SKIN_LIGHT)
				_dot(pts[i] + Vector2(0, r * 0.45), r * 0.35, SKIN_DARK)
	# A ribbon of fin along the back and a tail fluke.
	for i in range(2, segs):
		var r := lerpf(3.4, 1.2, float(i) / (segs - 1))
		_dot(pts[i] + Vector2(0, -r - 0.6), 0.6, FIN)
	_dot(pts[segs - 1] + Vector2(-1.2, 0), 1.3, FIN)
	# The head: a blunt snout with a jaw that gapes while it darts.
	var head := pts[0]
	var gape := 1.6 if state == "dart" else (0.8 if state == "coil" else 0.2)
	_dot(head + Vector2(2.6, -0.6), 2.0, OUTLINE)
	_dot(head + Vector2(2.4, -0.6), 1.5, SKIN)
	_dot(head + Vector2(3.2, 1.0 + gape), 1.4, OUTLINE)
	_dot(head + Vector2(3.0, 0.9 + gape), 1.0, SKIN_DARK)
	# The lamp on its brow: a dim glow while it weaves, blazing as it coils.
	var lamp := 0.45 + 0.15 * sin(t * 3.0)
	if state == "coil":
		lamp = 0.6 + 0.4 * absf(sin(state_time * 18.0))
	elif state == "dart":
		lamp = 1.0
	elif state == "slack":
		lamp = 0.2
	var lp := head + Vector2(1.0, -3.6)
	draw_circle(lp * SCALE, (2.4 + 2.0 * lamp) * SCALE, Color(LAMP, 0.16 * lamp))
	_dot(head + Vector2(0.2, -2.6), 0.5, OUTLINE)
	_dot(lp, 1.2, Color(LAMP, lamp))
	_dot(lp, 0.55, Color(LAMP_CORE, lamp))
	wash(flashing())
	draw_set_transform(Vector2.ZERO)


func _dot(p: Vector2, r: float, c: Color) -> void:
	draw_circle((p * SCALE).round(), maxf(1.0, r * SCALE), c)
