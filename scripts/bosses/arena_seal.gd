class_name ArenaSeal
extends StaticBody2D
## A wall of thick roots that grows across a doorway while a boss is alive and
## pulls back when it falls; in the Tower of Trunk, an iron portcullis that
## drops and winches back up. Its origin is the top-left of the blocked area.

const ROOT := Color("5e3b22")
const ROOT_LIGHT := Color("8a5a34")
const OUTLINE := Color("1d1a2b")
const GROW_TIME := 0.35
const IRON := Color("645e82")
const IRON_LIGHT := Color("aca1ba")
const RIVET := Color("cb8d16")

var size := Vector2(16, 48)
## "roots" or "iron".
var style := "roots"

var _grow := 0.0
var _opening := false


func _ready() -> void:
	collision_layer = Player.LAYER_WORLD
	collision_mask = 0
	add_to_group("arena_seal")
	z_index = 1
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	shape.position = size * 0.5
	add_child(shape)
	Sfx.play("heavy" if style == "iron" else "crumble", 0.1, -6.0)


func open() -> void:
	_opening = true
	collision_layer = 0
	Sfx.play("crumble", 0.1, -4.0)


func _process(delta: float) -> void:
	_grow = move_toward(_grow, 0.0 if _opening else 1.0, delta / GROW_TIME)
	if _opening and _grow <= 0.0:
		queue_free()
	queue_redraw()


func _draw() -> void:
	if style == "iron":
		_draw_portcullis()
		return
	var h := size.y * _grow
	# A dark mass of root fills the opening (hiding whatever is beyond it)...
	draw_rect(Rect2(0, 0, size.x, h), OUTLINE)
	draw_rect(Rect2(1, 0, size.x - 2, h), Color("2e1d12"))
	# ...with three twisted strands growing down from the lintel.
	for i in 3:
		var x := 2.0 + i * (size.x - 4.0) / 2.0
		var pts := PackedVector2Array()
		var steps := 8
		for k in steps + 1:
			var y := h * k / steps
			pts.append(Vector2(x + sin(y * 0.25 + i * 2.0) * 3.0, y))
		draw_polyline(pts, OUTLINE, 7.0)
		draw_polyline(pts, ROOT, 5.0)
		draw_polyline(pts, ROOT_LIGHT, 1.0)


## An iron portcullis: bars hanging from the lintel, two cross straps with rivets,
## and spiked tips, sliding down as it closes.
func _draw_portcullis() -> void:
	var h := size.y * _grow
	if h <= 0.0:
		return
	var top := h - size.y
	draw_rect(Rect2(0, 0, size.x, h), Color(OUTLINE, 0.55))
	var bars := maxi(3, int(size.x / 6.0))
	for i in bars:
		var x := 2.0 + i * (size.x - 4.0) / (bars - 1)
		draw_rect(Rect2(x - 2.0, 0, 4.0, h), OUTLINE)
		draw_rect(Rect2(x - 1.0, 0, 2.0, h - 2.0), IRON)
		draw_rect(Rect2(x - 1.0, 0, 1.0, h - 2.0), IRON_LIGHT)
		draw_colored_polygon(PackedVector2Array([Vector2(x - 2.0, h - 2.0), Vector2(x + 2.0, h - 2.0), Vector2(x, h + 2.0)]), OUTLINE)
	for k: float in [0.25, 0.7]:
		var y := top + size.y * k
		if y < 0.0:
			continue
		draw_rect(Rect2(0, y - 2.0, size.x, 5.0), OUTLINE)
		draw_rect(Rect2(0, y - 1.0, size.x, 3.0), IRON)
		draw_rect(Rect2(0, y - 1.0, size.x, 1.0), IRON_LIGHT)
		for i in bars:
			var x := 2.0 + i * (size.x - 4.0) / (bars - 1)
			draw_rect(Rect2(x - 1.0, y, 2.0, 1.0), RIVET)
