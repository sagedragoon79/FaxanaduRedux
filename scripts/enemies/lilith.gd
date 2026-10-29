class_name Lilith
extends Enemy
## A Lilith, Pakukame's brood (design bible 8.5): a winged imp the size of a
## hand, violet with petal wings, three loosed at a time from the Bloom's
## petals as in the original. It flutters up out of the bulb, hangs above and
## to one side of you, screeches with its wings flared (telegraph), then dives
## at where you were and climbs back. It never comes back once struck down, and
## the brood dies with the Bloom. Code-drawn at 2x.

## Fluttering up out of the bulb, harmless until it is clear of the petals.
const RISE := 0.5
const HOVER_OFFSET := Vector2(56, -52)
const HOVER_TIME := 1.1
const WINDUP := 0.4
const DIVE_SPEED := 250.0
const DIVE_TIME := 0.45
const TOUCH_DAMAGE := 8

const OUTLINE := Color("1e0f1e")
const BODY := Color("6a3a8a")
const BODY_LIGHT := Color("9a62b8")
const FACE := Color("f0d8e0")
const EYE := Color("f0d040")
const WING := Color("d0508a")
const WING_LIGHT := Color("f08ab8")

## Which side of the player this one hangs on, and how far it sits from the
## others in its brood (each of the three keeps its own place).
var side := 1
var slot := 0
var _dir := Vector2.ZERO


func _init() -> void:
	max_hp = 10
	contact_damage = 0
	gold_min = 1
	gold_max = 2
	xp = 3
	body_size = Vector2(12, 10)
	body_centered = true
	uses_gravity = false
	knockback = 200.0
	state = "rise"


func _think(delta: float) -> void:
	var off := player_offset()
	contact_damage = 0 if state == "rise" else TOUCH_DAMAGE
	match state:
		"rise":
			velocity = velocity.move_toward(Vector2.ZERO, 300.0 * delta)
			if state_time >= RISE:
				set_state("hover")
		"hover":
			face_player()
			if off.x == INF:
				velocity = velocity.move_toward(Vector2.ZERO, 300.0 * delta)
				return
			var t := Time.get_ticks_msec() * 0.001 + slot * 1.7
			var target := center() + off + Vector2(side * (HOVER_OFFSET.x + slot * 14.0), HOVER_OFFSET.y - slot * 10.0)
			target += Vector2(sin(t * 2.3) * 10.0, sin(t * 4.1) * 6.0)
			velocity = ((target - global_position) * 3.0).limit_length(150.0)
			if state_time >= HOVER_TIME + slot * 0.35:
				velocity = Vector2.ZERO
				set_state("windup")
				Sfx.play("buzz", 0.15, -6.0)
		"windup":
			velocity = velocity.move_toward(Vector2.ZERO, 500.0 * delta)
			face_player()
			if state_time >= WINDUP:
				_dir = off.normalized() if off.x != INF else Vector2(facing, 0)
				set_state("dive")
				Sfx.play("whoosh", 0.15, -6.0)
		"dive":
			velocity = _dir * DIVE_SPEED
			if state_time >= DIVE_TIME or get_slide_collision_count() > 0:
				side = -side
				set_state("hover")
		_:
			set_state("hover")


func _draw() -> void:
	var white := flashing() or (state == "windup" and telegraph_pulse())
	var t := Time.get_ticks_msec() * 0.001 + slot
	var jitter := Vector2(randf_range(-1, 1), 0).round() if state == "windup" else Vector2.ZERO
	draw_set_transform(jitter, 0.0, Vector2(facing, 1))
	# Wings: flared wide and still in the screech, beating fast otherwise.
	var beat := 0.9 if state == "windup" else 0.35 + 0.45 * absf(sin(t * 18.0))
	for s in [-1, 1]:
		var root := Vector2(s * 1.5, -2)
		var tip := root + Vector2(s * 9.0, -4.0 - beat * 6.0)
		var low := root + Vector2(s * 7.0, 2.0 - beat * 2.0)
		var wing := PackedVector2Array([root, tip, low])
		draw_colored_polygon(_grow(wing, 1.0), OUTLINE)
		draw_colored_polygon(wing, WING_LIGHT if s > 0 else WING)
	# A curling tail.
	draw_line(Vector2(-2, 3), Vector2(-5, 7), OUTLINE, 2.0)
	draw_line(Vector2(-5, 7), Vector2(-3, 9), OUTLINE, 2.0)
	# Body and head.
	draw_circle(Vector2(0, 1), 4.0, OUTLINE)
	draw_circle(Vector2(0, 1), 3.0, BODY)
	draw_circle(Vector2(1, -3), 3.5, OUTLINE)
	draw_circle(Vector2(1, -3), 2.6, FACE)
	draw_circle(Vector2(-1, 0), 1.2, BODY_LIGHT)
	# Two little horns and a glinting eye; the mouth opens in the screech.
	draw_line(Vector2(0, -5), Vector2(-1, -8), OUTLINE, 1.0)
	draw_line(Vector2(2, -5), Vector2(3, -8), OUTLINE, 1.0)
	draw_rect(Rect2(2, -4, 1, 1), EYE)
	if state == "windup":
		draw_rect(Rect2(2, -2, 2, 1), OUTLINE)
	wash(white)
	draw_set_transform(Vector2.ZERO)


func _grow(poly: PackedVector2Array, by: float) -> PackedVector2Array:
	var c := Vector2.ZERO
	for v in poly:
		c += v
	c /= poly.size()
	var out := PackedVector2Array()
	for v in poly:
		out.append(v + (v - c).normalized() * by)
	return out
