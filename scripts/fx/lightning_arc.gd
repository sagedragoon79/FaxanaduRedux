class_name LightningArc
extends Node2D
## A brief jagged arc of lightning between two points (world space), flickering
## as it fades. Used by the Thunder spell when it leaps to a conduit or a foe.

const LIFE := 0.22
const CORE := Color("f8f0b0")
const GLOW := Color("b8a8ff")

var from := Vector2.ZERO
var to := Vector2.ZERO
var _t := 0.0


static func spawn(parent: Node, a: Vector2, b: Vector2) -> LightningArc:
	var arc := LightningArc.new()
	arc.from = a
	arc.to = b
	arc.z_index = 4
	parent.add_child(arc)
	return arc


func _process(delta: float) -> void:
	_t += delta
	if _t >= LIFE:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var a := from - global_position
	var b := to - global_position
	var n := maxi(3, int(a.distance_to(b) / 10.0))
	var side := (b - a).orthogonal().normalized()
	var pts := PackedVector2Array([a])
	var flick := int(_t * 40.0)
	for i in range(1, n):
		var k := float(i) / n
		var jag := float((flick * 7 + i * 13) % 9 - 4)
		pts.append(a.lerp(b, k) + side * jag)
	pts.append(b)
	var fade := 1.0 - _t / LIFE
	draw_polyline(pts, Color(GLOW, 0.6 * fade), 3.0)
	draw_polyline(pts, Color(CORE, fade), 1.0)
