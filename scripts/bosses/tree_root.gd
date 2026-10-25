class_name TreeRoot
extends Node2D
## A root of the World Tree lashing up through the floor of the meteor's heart
## to bind the core (the Evil One, phase 3, design bible 8.9). The Tree fights
## alongside you on a rhythm: the floor under the core cracks and glows green
## for TELL seconds, then the root whips up, wraps the core and drags it down to
## the floor, where the Dragon Slayer can reach it. It holds it for `hold`
## seconds and sinks back. It never hurts the player. The Hour Glass holds it.
## The origin is on the floor where it breaks through.

signal struck

const TELL := 0.8
const LASH := 0.2
const SINK := 0.5
const BARK := Color("5a3a24")
const BARK_LIGHT := Color("8a6038")
const SAP := Color("9af06a")
const OUTLINE := Color("13101f")

## What it binds (the core). It reaches for wherever it is.
var target: Node2D
var hold := 2.4
var _t := 0.0
var _struck := false


func _ready() -> void:
	# Under the core it grips (EvilHeart draws a layer up), so it seems to hold it from below.
	z_index = 0


## 0..1: how far up the root has reached toward its target.
func reach() -> float:
	if _t < TELL:
		return 0.0
	if _t < TELL + LASH:
		return (_t - TELL) / LASH
	if _t < TELL + LASH + hold:
		return 1.0
	return clampf(1.0 - (_t - TELL - LASH - hold) / SINK, 0.0, 1.0)


func telling() -> bool:
	return _t < TELL


func _tip() -> Vector2:
	if target == null or not is_instance_valid(target):
		return Vector2(0, -40)
	return target.global_position - global_position


func _physics_process(delta: float) -> void:
	if TimeStop.active():
		queue_redraw()
		return
	_t += delta
	if not _struck and _t >= TELL + LASH:
		_struck = true
		struck.emit()
		Sfx.play("crumble", 0.1)
		Feel.add_trauma(0.35)
	if _t >= TELL + LASH + hold + SINK:
		queue_free()
		return
	# The root's base follows the core across the floor while it is held.
	if _struck and target != null and is_instance_valid(target):
		global_position.x = move_toward(global_position.x, target.global_position.x, 200.0 * delta)
	queue_redraw()


func _draw() -> void:
	if telling():
		# The floor cracks and the Tree's light wells up through it.
		var k := _t / TELL
		var on := int(_t * (8.0 + 14.0 * k)) % 2 == 0
		draw_rect(Rect2(-14.0, -3.0, 28.0, 3.0), Color(SAP, 0.3 + 0.5 * k if on else 0.2))
		for i in 3:
			var x := -10.0 + i * 10.0
			draw_line(Vector2(x, 0), Vector2(x + 3.0, -4.0 - 10.0 * k), Color(SAP, 0.5 * k), 1.0)
		return
	var r := reach()
	var tip := _tip() * r
	# A thick curve of bark, bending as it climbs, coiled about the core at the top.
	var bend := Vector2(-tip.y * 0.18, 0)
	var steps := 10
	var prev := Vector2.ZERO
	for i in range(1, steps + 1):
		var s := float(i) / steps
		var pt := tip * s + bend * sin(s * PI)
		var w := lerpf(14.0, 6.0, s)
		draw_line(prev, pt, OUTLINE, w + 2.0)
		draw_line(prev, pt, BARK, w)
		draw_line(prev + Vector2(-w * 0.2, 0), pt + Vector2(-w * 0.2, 0), BARK_LIGHT, 2.0)
		prev = pt
	# The Tree's light running up its veins.
	var pulse := fmod(_t * 1.5, 1.0)
	draw_circle(tip * pulse + bend * sin(pulse * PI), 3.0, Color(SAP, 0.9))
	if r >= 1.0:
		# Tendrils of it curled up around the core's sides.
		for side in [-1.0, 1.0]:
			draw_arc(tip, 30.0, PI * 0.5 - side * 1.6, PI * 0.5, 10, OUTLINE, 7.0)
			draw_arc(tip, 30.0, PI * 0.5 - side * 1.6, PI * 0.5, 10, BARK, 5.0)
