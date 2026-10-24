class_name Waterfall
extends Node2D
## Time-locked water (design bible 4.5, A8; legend `f`, a rectangle of cells).
## Flowing, it beats down on anything in it: no jumping or climbing up through
## it. While the Hour Glass holds time still, the water stands frozen in the
## air, its droplets set into footholds every STEP rows up from the bottom, so a
## quick climber can go up it like a stair before time runs on.

## How hard the water bears down (px/s).
const PUSH := 260.0
## Rows between footholds.
const STEP := 3
const WATER := Color("5fb8c8")
const FOAM := Color("d8f4f0")
const DEEP := Color("2e6a7a")
const FROZEN := Color("b8e0f0")
const GLYPH := Color("f0e0a0")

## The water's cells (tiles).
var cells := Rect2i()

var _body: StaticBody2D
var _shapes: Array[CollisionShape2D] = []
var _frozen := false
var _t := 0.0


func _ready() -> void:
	z_index = 2
	_body = StaticBody2D.new()
	_body.collision_layer = Player.LAYER_WORLD
	_body.collision_mask = 0
	add_child(_body)
	for row: int in foothold_rows():
		var s := CollisionShape2D.new()
		var r := RectangleShape2D.new()
		r.size = Vector2(cells.size.x * Room.TILE, 4)
		s.shape = r
		s.one_way_collision = true
		s.position = Vector2(cells.size.x * Room.TILE * 0.5, (row - cells.position.y) * Room.TILE + 2)
		s.disabled = true
		_body.add_child(s)
		_shapes.append(s)
	position = Vector2(cells.position * Room.TILE)


## The rows (tiles) whose tops are footholds while frozen.
func foothold_rows() -> Array[int]:
	var out: Array[int] = []
	var bottom := cells.end.y - 1
	var y := bottom - STEP
	while y >= cells.position.y:
		out.append(y)
		y -= STEP
	return out


func pixel_rect() -> Rect2:
	return Rect2(Vector2(cells.position * Room.TILE), Vector2(cells.size * Room.TILE))


func frozen() -> bool:
	return _frozen


func _physics_process(delta: float) -> void:
	var stopped := TimeStop.active()
	if stopped != _frozen:
		_frozen = stopped
		for s in _shapes:
			s.set_deferred("disabled", not _frozen)
	if not _frozen:
		_t += delta
		var p := get_tree().get_first_node_in_group("player") as Player
		if p != null and not p.dead and pixel_rect().intersects(p.body_rect()):
			p.water_push = PUSH
	queue_redraw()


func _draw() -> void:
	var w := cells.size.x * Room.TILE
	var h := cells.size.y * Room.TILE
	var body := FROZEN if _frozen else WATER
	draw_rect(Rect2(0, 0, w, h), Color(DEEP, 0.55))
	# Streaks falling (or frozen where they were), in half-pixel strips.
	var strips := int(w)
	for i in strips:
		var x := i + (0.5 if i % 2 else 0.0)
		var speed := 120.0 + float((i * 37) % 50)
		var phase := fmod(_t * speed + float((i * 53) % 97), 24.0)
		var y := -24.0 + phase
		while y < h:
			var streak := 6.0 + float((i * 11) % 7)
			var top := maxf(y, 0.0)
			var bot := minf(y + streak, h)
			if bot > top:
				draw_rect(Rect2(x, top, 0.5, bot - top), Color(body, 0.55 if i % 3 else 0.8))
			y += 24.0
	# Foam where the water lands.
	for i in int(w / 2.0):
		var k := 0.6 + 0.4 * sin(_t * 9.0 + i)
		draw_rect(Rect2(i * 2.0, h - 3.0 - (i % 2), 2.0, 3.0), Color(FOAM, k if not _frozen else 0.5))
	# Clock-glyph droplets drifting down: the sign that time holds this water.
	for j in 3:
		var gy := fmod(_t * 40.0 + j * h / 3.0, h)
		var gx := w * (0.25 + 0.25 * j)
		_glyph(Vector2(gx, gy), Color(GLYPH, 0.75 if _frozen else 0.45))
	if _frozen:
		# The footholds: droplets set into pale ledges.
		for row: int in foothold_rows():
			var fy := float(row - cells.position.y) * Room.TILE
			draw_rect(Rect2(0, fy, w, 2.0), Color(FOAM, 0.9))
			draw_rect(Rect2(0, fy + 2.0, w, 1.0), Color(FROZEN, 0.6))
			for i in int(w / 4.0):
				draw_rect(Rect2(i * 4.0 + 1.0, fy + 3.0, 1.0, 1.5), Color(FOAM, 0.7))


## A tiny clock face: a ring of four dots and two hands.
func _glyph(at: Vector2, c: Color) -> void:
	for d: Vector2 in [Vector2(0, -2), Vector2(2, 0), Vector2(0, 2), Vector2(-2, 0)]:
		draw_rect(Rect2(at + d - Vector2(0.25, 0.25), Vector2(0.5, 0.5)), c)
	draw_rect(Rect2(at + Vector2(-0.25, -1.5), Vector2(0.5, 1.5)), c)
	draw_rect(Rect2(at + Vector2(0, -0.25), Vector2(1.0, 0.5)), c)
