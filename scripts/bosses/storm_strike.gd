class_name StormStrike
extends Node2D
## One bolt of Borabohra's phase-2 storm (design bible 8.6). It marks its spot
## for TELL seconds (a flickering thread of light from the sky and a glow where it
## will land), then strikes the column for DAMAGE, unparryable. A dead conduit
## under the bolt wakes, so the storm can do some of your work for you.
## Placed with its origin where the bolt lands; `top` is the sky above it.

const TELL := 0.6
const DAMAGE := 18
const HALF_WIDTH := 14.0
const LINGER := 0.25
const CORE := Color("f8f0b0")
const GLOW := Color("b8a8ff")

var boss: Enemy
var top := 0.0
var _t := 0.0
var _struck := false


func _ready() -> void:
	z_index = 3


## The column the bolt fills, in world space.
func strike_rect() -> Rect2:
	var y0 := minf(top, global_position.y)
	return Rect2(global_position.x - HALF_WIDTH, y0, HALF_WIDTH * 2.0, global_position.y - y0 + 6.0)


func _physics_process(delta: float) -> void:
	if TimeStop.active():
		return  # held still by the Hour Glass
	_t += delta
	if not _struck and _t >= TELL:
		_strike()
	if _t >= TELL + LINGER:
		queue_free()
	queue_redraw()


func _strike() -> void:
	_struck = true
	var r := strike_rect()
	if is_instance_valid(boss) and not boss.dead:
		boss.hit_player_in_rect(r, DAMAGE, false)
	for c in get_tree().get_nodes_in_group("conductor"):
		var cd := c as Conduit
		if not cd.powered and r.grow(8.0).has_point(cd.spark_point()):
			cd.power()
	LightningArc.spawn(get_parent(), Vector2(global_position.x, top), global_position)
	Sfx.play("zap", 0.08, 2.0)
	Feel.add_trauma(0.3)
	GameState.flash.emit(0.25)


func _draw() -> void:
	var h := global_position.y - top
	if not _struck:
		# The tell: a thin thread from the sky and a pulsing glow at the landing.
		var on := int(_t * 18.0) % 2 == 0
		var k := clampf(_t / TELL, 0.0, 1.0)
		draw_line(Vector2(0, -h), Vector2(0, 0), GLOW * Color(1, 1, 1, 0.2 + 0.25 * k), 6.0 + 6.0 * k)
		draw_line(Vector2(0, -h), Vector2(0, 0), CORE * Color(1, 1, 1, 0.5 + 0.4 * k), 1.0 if on else 2.0)
		draw_circle(Vector2(0, -2), 4.0 + 6.0 * k, GLOW * Color(1, 1, 1, 0.35))
		draw_circle(Vector2(0, -2), 2.0 + 2.0 * k, CORE * Color(1, 1, 1, 0.6 if on else 0.3))
	else:
		var fade := 1.0 - clampf((_t - TELL) / LINGER, 0.0, 1.0)
		draw_rect(Rect2(-HALF_WIDTH, -h, HALF_WIDTH * 2.0, h), GLOW * Color(1, 1, 1, 0.25 * fade))
		draw_circle(Vector2(0, -2), 10.0 * fade + 2.0, CORE * Color(1, 1, 1, fade))
