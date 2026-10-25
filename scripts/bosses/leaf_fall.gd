class_name LeafFall
extends Node2D
## The crown-leaf falling through the sky (design bible 8.5, Pakukame's third
## phase): once the Bloom tears its root out, the leaf is cut loose. Wind rushes
## up past it, torn leaves and petals ride the wind up, and while it falls the
## player in the arena weighs a little less (WEIGHT), so jumps hang longer: room
## to clear a lunging bloom. `settle()` when the Bloom dies: the wind dies away.

## How much of their weight the player keeps while the leaf falls.
const WEIGHT := 0.85
const WIND := Color("f4fbff")
## A darker edge so the streaks read against a pale sky.
const WIND_EDGE := Color("4a86b8")
const LEAF := Color("7cbf52")
const PETAL := Color("f08ab8")
## Seconds the wind takes to die away after settle().
const SETTLE_TIME := 1.5

## The arena (world pixels).
var area := Rect2(16, 64, 928, 256)
var falling := true
var _t := 0.0
var _fade := 1.0


func _ready() -> void:
	z_index = 2


func settle() -> void:
	falling = false


func _physics_process(delta: float) -> void:
	_t += delta
	if not falling:
		_fade -= delta / SETTLE_TIME
		if _fade <= 0.0:
			queue_free()
			return
	else:
		var p := get_tree().get_first_node_in_group("player") as Player
		if p != null and not p.dead and area.has_point(p.body_rect().get_center()):
			p.gravity_scale = minf(p.gravity_scale, WEIGHT)
	queue_redraw()


func _draw() -> void:
	var a := _fade
	# Streaks of wind racing up the whole sky.
	for i in 28:
		var x := area.position.x + fmod(i * 131.0, area.size.x)
		var y := area.end.y - fmod(_t * (380.0 + (i % 5) * 40.0) + i * 53.0, area.size.y)
		var h := 18.0 + (i % 3) * 8.0
		draw_rect(Rect2(x + 1, y, 1, h), Color(WIND_EDGE, 0.3 * a))
		draw_rect(Rect2(x, y, 1, h), Color(WIND, 0.6 * a))
	# Torn leaf and petals riding the wind up, tumbling.
	for i in 10:
		var x := area.position.x + fmod(i * 97.0 + sin(_t * 1.5 + i) * 30.0, area.size.x)
		var y := area.end.y + 20.0 - fmod(_t * 160.0 + i * 61.0, area.size.y + 40.0)
		var col := PETAL if i % 3 == 0 else LEAF
		var spin := _t * 6.0 + i
		var d := Vector2(cos(spin), sin(spin)) * 4.0
		draw_line(Vector2(x, y) - d, Vector2(x, y) + d, Color(col.darkened(0.5), 0.9 * a), 4.0)
		draw_line(Vector2(x, y) - d, Vector2(x, y) + d, Color(col, 0.9 * a), 2.0)
