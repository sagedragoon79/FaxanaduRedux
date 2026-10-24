class_name CrystalSpike
extends Node2D
## One spike of a Crystal Dwarf's eruption: the floor glows where it will burst
## for WARN seconds, then a shard of meteor crystal stabs up for UP seconds and
## sinks again. It hurts anything standing over it while it is up, so a jump
## clears it. Unparryable. The origin is on the floor.

const WARN := 0.18
const UP := 0.45
const HEIGHT := 26.0
const WIDTH := 12.0
const DAMAGE := 12
const LIGHT := Color("f0a0f0")
const MID := Color("c050c8")
const DARK := Color("6a2a78")
const OUTLINE := Color("13101f")

var delay := 0.0
var _t := 0.0
var _hit := false


func _ready() -> void:
	z_index = 1


## How far up the spike stands now (0..1).
func rise() -> float:
	var t := _t - delay - WARN
	if t < 0.0:
		return 0.0
	if t < 0.06:
		return t / 0.06
	if t > UP - 0.12:
		return clampf((UP - t) / 0.12, 0.0, 1.0)
	return 1.0


func hit_rect() -> Rect2:
	var h := HEIGHT * rise()
	return Rect2(global_position - Vector2(WIDTH * 0.5, h), Vector2(WIDTH, h))


func _physics_process(delta: float) -> void:
	if TimeStop.active():
		return  # held still by the Hour Glass
	_t += delta
	if _t >= delay + WARN + UP:
		queue_free()
		return
	if not _hit and rise() > 0.5:
		var p := get_tree().get_first_node_in_group("player") as Player
		if p != null and not p.dead and hit_rect().intersects(p.body_rect()):
			_hit = p.receive_attack(DAMAGE, self, false) != ""
	queue_redraw()


func _draw() -> void:
	if _t < delay:
		return
	if _t < delay + WARN:
		# The warning: the floor glows and cracks where it will burst.
		var k := (_t - delay) / WARN
		draw_rect(Rect2(-WIDTH * 0.5, -1.5, WIDTH, 1.5), Color(LIGHT, 0.4 + 0.5 * k))
		draw_rect(Rect2(-1.0, -3.0, 2.0, 3.0), Color(LIGHT, k))
		return
	var h := HEIGHT * rise()
	if h <= 0.5:
		return
	var w := WIDTH * 0.5
	draw_circle(Vector2(0, -h * 0.4), w + 4.0, Color(LIGHT, 0.18))
	draw_colored_polygon(PackedVector2Array([Vector2(-w - 1, 0), Vector2(0, -h - 1), Vector2(w + 1, 0)]), OUTLINE)
	draw_colored_polygon(PackedVector2Array([Vector2(-w, 0), Vector2(0, -h), Vector2(w, 0)]), MID)
	draw_colored_polygon(PackedVector2Array([Vector2(-w * 0.2, 0), Vector2(0, -h), Vector2(w, 0)]), DARK)
	draw_line(Vector2(-w * 0.5, -1), Vector2(-0.5, -h + 2), LIGHT, 1.0)
