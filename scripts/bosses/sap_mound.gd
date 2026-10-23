class_name SapMound
extends StaticBody2D
## Hardened sap left where a SapClump lands: a one-way platform (stand on it,
## jump up through it, never get stuck inside) that crumbles after LIFETIME.
## The origin is the bottom center, on the surface it landed on.

const SIZE := Vector2(40, 32)
const LIFETIME := 7.0
const WARN := 1.2
const AMBER := Color("c97a1e")
const AMBER_LIGHT := Color("ffc76a")
const AMBER_DARK := Color("7a4512")
const OUTLINE := Color("1d1a2b")

var _t := 0.0
var _grow := 0.0


func _ready() -> void:
	collision_layer = Player.LAYER_WORLD
	collision_mask = 0
	add_to_group("sap_mound")
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = SIZE
	shape.shape = rect
	shape.position = Vector2(0, -SIZE.y * 0.5)
	shape.one_way_collision = true
	add_child(shape)


func top_rect() -> Rect2:
	return Rect2(position + Vector2(-SIZE.x * 0.5, -SIZE.y), Vector2(SIZE.x, 4))


func _physics_process(delta: float) -> void:
	_t += delta
	_grow = minf(_grow + delta * 8.0, 1.0)
	if _t >= LIFETIME:
		var d := Dust.new()
		d.setup("sap")
		get_parent().add_child(d)
		d.global_position = global_position + Vector2(0, -SIZE.y * 0.5)
		Sfx.play("crumble", 0.1, -8.0)
		queue_free()
	queue_redraw()


func _draw() -> void:
	if _t > LIFETIME - WARN and int(_t * 12.0) % 2 == 0:
		return
	var h := SIZE.y * _grow
	var w := SIZE.x
	var poly := PackedVector2Array([
		Vector2(-w * 0.5, 0), Vector2(-w * 0.5 + 3, -h + 4), Vector2(-w * 0.25, -h),
		Vector2(w * 0.25, -h), Vector2(w * 0.5 - 3, -h + 4), Vector2(w * 0.5, 0),
	])
	draw_colored_polygon(poly, OUTLINE)
	var inner := PackedVector2Array()
	for v in poly:
		inner.append(v * Vector2(0.92, 0.92) + Vector2(0, -1))
	draw_colored_polygon(inner, AMBER)
	draw_rect(Rect2(-w * 0.25, -h + 1, w * 0.5, 2), AMBER_LIGHT)
	draw_rect(Rect2(-w * 0.3, -h * 0.4, 4, 4), AMBER_DARK)
	draw_rect(Rect2(w * 0.1, -h * 0.6, 3, 3), AMBER_DARK)
