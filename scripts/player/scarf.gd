class_name Scarf
extends Node2D
## The red scarf: a verlet chain that trails behind real movement, so it reacts
## to dashes, wall jumps and pogo bounces without hand animation.

const SEGMENTS := 7
const SEGMENT_LENGTH := 3.0
const GRAVITY := 300.0
const DAMPING := 0.86
const COLOR := Color("c3343f")
const COLOR_TIP := Color("8e2131")
const OUTLINE := Color("1d1a2b")

var player: Player

var _points: Array[Vector2] = []
var _prev: Array[Vector2] = []


func _ready() -> void:
	top_level = true
	snap()


func anchor() -> Vector2:
	return player.visual.neck_position() + Vector2(-player.facing * 2, 1)


func snap() -> void:
	_points.clear()
	_prev.clear()
	var a := anchor()
	for i in SEGMENTS:
		var p := a + Vector2(-player.facing * SEGMENT_LENGTH * i, 0)
		_points.append(p)
		_prev.append(p)


func _physics_process(delta: float) -> void:
	if _points.is_empty():
		return
	var wind := Vector2(-player.facing * 110.0, -20.0) - player.velocity * 0.15
	for i in range(1, SEGMENTS):
		var p := _points[i]
		var v := (p - _prev[i]) * DAMPING
		_prev[i] = p
		_points[i] = p + v + (Vector2(0, GRAVITY) + wind) * delta * delta
	_points[0] = anchor()
	_prev[0] = _points[0]
	for _iter in 3:
		for i in range(1, SEGMENTS):
			var d := _points[i] - _points[i - 1]
			var len := d.length()
			if len > SEGMENT_LENGTH:
				_points[i] = _points[i - 1] + d / len * SEGMENT_LENGTH
	queue_redraw()


func _draw() -> void:
	if not player.visual.visible:
		return
	for i in SEGMENTS:
		draw_rect(Rect2(_points[i].round() - Vector2(2, 2), Vector2(4, 4)), OUTLINE)
	for i in SEGMENTS:
		var c := COLOR if i < SEGMENTS - 2 else COLOR_TIP
		draw_rect(Rect2(_points[i].round() - Vector2(1, 1), Vector2(3, 3)), c)
