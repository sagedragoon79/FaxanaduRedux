class_name GravityDrift
extends Node2D
## A pocket where the meteor's pull is wrong (Zenis, design bible 8.9; legend
## `v`, a rectangle of cells). Inside it the player weighs a fraction of what
## they should: they fall slowly, and a jump carries them about two and a half
## times as high, up ledges no jump could reach. Leave the pocket mid-flight
## and the true pull takes hold again. Drawn as a faint column of light with
## motes drifting up through it.

## How much of their weight the player keeps inside (gravity and top fall speed).
const PULL := 0.4
const WASH := Color("7a4ac8")
const MOTE := Color("8af0e8")
const EDGE := Color("4ae0d8")
## Rising speed of the motes (px/s).
const RISE := 26.0

## The pocket's cells (tiles).
var cells := Rect2i()

var _t := 0.0


func _ready() -> void:
	z_index = -1
	position = Vector2(cells.position * Room.TILE)


func pixel_rect() -> Rect2:
	return Rect2(Vector2(cells.position * Room.TILE), Vector2(cells.size * Room.TILE))


func _physics_process(delta: float) -> void:
	_t += delta
	var p := get_tree().get_first_node_in_group("player") as Player
	# The body's centre decides: half in, half out still floats.
	if p != null and not p.dead and pixel_rect().has_point(p.body_rect().get_center()):
		p.gravity_scale = PULL
	queue_redraw()


func _draw() -> void:
	var w := float(cells.size.x * Room.TILE)
	var h := float(cells.size.y * Room.TILE)
	draw_rect(Rect2(0, 0, w, h), Color(WASH, 0.22))
	# Bands of light climbing the column.
	for i in 3:
		var y := h - fmod(_t * RISE * 0.6 + i * h / 3.0, h)
		draw_rect(Rect2(0, y, w, 10.0), Color(EDGE, 0.08))
	# Shimmering edges at the sides.
	var a := 0.45 + 0.2 * sin(_t * 3.0)
	draw_rect(Rect2(0, 0, 1, h), Color(EDGE, a))
	draw_rect(Rect2(w - 1.0, 0, 1, h), Color(EDGE, a))
	# Motes drifting up, each on its own column and pace, swaying a little.
	var count := int(w * h / 380.0) + 4
	for i in count:
		var speed := RISE * (0.6 + float((i * 37) % 10) / 10.0)
		var y := h - fmod(_t * speed + float((i * 131) % 977), h)
		var x := fmod(float(i * 53 % 997), w) + sin(_t * 1.7 + i) * 2.0
		var k := clampf(minf(y, h - y) / 24.0, 0.0, 1.0)
		var sz := 1.0 + float(i % 2)
		# A short streak below each mote: they are rising, not falling.
		draw_rect(Rect2(x, y + sz, sz * 0.5 + 0.5, 4.0), Color(MOTE, 0.25 * k))
		draw_rect(Rect2(x, y, sz, sz), Color(MOTE, 0.9 * k))
