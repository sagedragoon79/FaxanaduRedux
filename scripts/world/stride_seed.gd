class_name StrideSeed
extends Node2D
## A stride seed (design bible 6.4: the dash-reset orb): a glowing elf-seed that
## floats in open air. Touch it in the air while a double jump or a dash is
## spent and it bursts, giving back both, then grows again after REGROW
## seconds. Touched with nothing spent, or from the ground, it stays whole, so
## it is never wasted. Legend `r`, floating at the center of its cell. Seeds
## only ever help: none is needed to reach anything.

## How close (px) the middle of the player's body must come.
const REACH := 14.0
const REGROW := 2.5
const CORE := Color("fff6c8")
const BODY := Color("9be86a")
const GLOW := Color("5cc85a")
const OUTLINE := Color("1c2a18")

## Seconds until it has grown back (0 = whole).
var regrow := 0.0
var _t := 0.0


func _ready() -> void:
	add_to_group("stride_seed")
	_t = fmod(global_position.x * 0.013, TAU)


func is_whole() -> bool:
	return regrow <= 0.0


func _physics_process(delta: float) -> void:
	_t += delta
	if regrow > 0.0:
		regrow = maxf(0.0, regrow - delta)
	elif _try_burst():
		pass
	queue_redraw()


func _try_burst() -> bool:
	var p := get_tree().get_first_node_in_group("player") as Player
	if p == null or p.dead or p.is_on_floor():
		return false
	if p.body_rect().get_center().distance_to(global_position) > REACH + 6.0:
		return false
	if not p.needs_air_refresh():
		return false
	p.refresh_air_moves()
	regrow = REGROW
	var d := Dust.new()
	d.setup("feathers")
	get_parent().add_child(d)
	d.global_position = global_position
	Sfx.play("seed", 0.05)
	Feel.rumble(0.25, 0.0, 0.06)
	return true


func _draw() -> void:
	if regrow > 0.0:
		# A faint husk while it grows back, filling in over the last half second.
		var k := clampf(1.0 - regrow / 0.5, 0.0, 1.0)
		draw_arc(Vector2.ZERO, 5.0, 0.0, TAU, 12, Color(GLOW, 0.35), 1.0)
		if k > 0.0:
			draw_circle(Vector2.ZERO, 4.0 * k, Color(BODY, 0.6 * k))
		return
	var bob := Vector2(0, sin(_t * 2.4) * 1.5)
	draw_circle(bob, 9.0 + sin(_t * 4.0), Color(GLOW, 0.22))
	# A seed shape: a fat teardrop pointing up, outlined, lit on one side.
	draw_circle(bob + Vector2(0, 1), 5.0, OUTLINE)
	draw_colored_polygon(PackedVector2Array([bob + Vector2(-4.5, 0), bob + Vector2(0, -8), bob + Vector2(4.5, 0)]), OUTLINE)
	draw_circle(bob + Vector2(0, 1), 4.0, BODY)
	draw_colored_polygon(PackedVector2Array([bob + Vector2(-3.5, 0), bob + Vector2(0, -6.5), bob + Vector2(3.5, 0)]), BODY)
	draw_rect(Rect2(bob + Vector2(-2, -2), Vector2(2, 3)), CORE)
