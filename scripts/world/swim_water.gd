class_name SwimWater
extends Node2D
## Deep water (the Sunken Spring, design bible 6.8 and 8.10; legend `a`). Every
## `a` cell in a room belongs to one SwimWater. While the centre of the player's
## body is in a water cell the player swims (Player.in_water): they float up to
## the surface, sink while holding Down, and a jump press is a stroke up; with
## the head above the surface it is a full jump out. Enemies are not slowed.
## Drawn in front of the bodies in it, a translucent green-blue with a moving
## surface line, drifting caustic light and bubbles.

const WATER := Color("1f6a78")
const DEEP := Color("123e52")
const SURFACE := Color("8ae8e0")
const BUBBLE := Color("c8fff6")
## Speed (px/s) a body must hit the surface at to throw spray.
const SPLASH_SPEED := 140.0

## The water's cells (tiles) -> true.
var cells := {}
## Cells with rock right above them: no waterline is drawn there.
var roofed := {}

var _t := 0.0
var _runs: Array[Rect2] = []
var _surface: Array[Rect2] = []
var _was_in := false
var _splashes: Array[Vector3] = []   # x, y, age


func _ready() -> void:
	z_index = 1
	_build_runs()


## Horizontal runs of water cells per row, and the cells at the surface (open above).
func _build_runs() -> void:
	_runs.clear()
	_surface.clear()
	var rows := {}
	for c: Vector2i in cells:
		if not rows.has(c.y):
			rows[c.y] = []
		rows[c.y].append(c.x)
		if not cells.has(c + Vector2i.UP) and not roofed.has(c):
			_surface.append(Rect2(Vector2(c * Room.TILE), Vector2(Room.TILE, Room.TILE)))
	for y: int in rows:
		var xs: Array = rows[y]
		xs.sort()
		var start: int = xs[0]
		var prev: int = xs[0]
		for i in range(1, xs.size() + 1):
			var x: int = xs[i] if i < xs.size() else -999
			if x != prev + 1:
				_runs.append(Rect2(start * Room.TILE, y * Room.TILE, (prev - start + 1) * Room.TILE, Room.TILE))
				start = x
			prev = x


## True if the point (room pixels) is in the water.
func has_point(pos: Vector2) -> bool:
	return cells.has(Vector2i(floori(pos.x / Room.TILE), floori(pos.y / Room.TILE)))


## The y (pixels) of the water's surface above the point.
func surface_above(pos: Vector2) -> float:
	var c := Vector2i(floori(pos.x / Room.TILE), floori(pos.y / Room.TILE))
	while cells.has(c + Vector2i.UP):
		c += Vector2i.UP
	return float(c.y * Room.TILE)


func _physics_process(delta: float) -> void:
	_t += delta
	var p := get_tree().get_first_node_in_group("player") as Player
	var now := false
	if p != null and not p.dead:
		var mid := p.body_rect().get_center() - global_position
		if has_point(mid):
			now = true
			p.in_water = true
			p.water_surface = surface_above(mid) + global_position.y
		if now != _was_in and absf(p.velocity.y) > SPLASH_SPEED:
			var x := mid.x
			var y := surface_above(mid if now else mid + Vector2(0, Room.TILE * 1.5))
			_splashes.append(Vector3(x, y, 0.0))
			Sfx.play("dive", 0.1, -4.0 if now else -8.0)
	_was_in = now
	for i in range(_splashes.size() - 1, -1, -1):
		_splashes[i].z += delta
		if _splashes[i].z > 0.6:
			_splashes.remove_at(i)
	queue_redraw()


func _draw() -> void:
	for r in _runs:
		draw_rect(r, Color(WATER, 0.42))
		# Darker towards the bottom of each row band: cheap depth.
		draw_rect(Rect2(r.position + Vector2(0, Room.TILE * 0.5), Vector2(r.size.x, Room.TILE * 0.5)), Color(DEEP, 0.08))
		# Caustic light drifting across the run.
		var n := int(r.size.x / 40.0) + 1
		for i in n:
			var x := fmod(_t * 12.0 + i * 41.0 + r.position.y * 0.7, r.size.x)
			var w := 6.0 + 4.0 * sin(_t * 1.3 + i)
			draw_rect(Rect2(r.position.x + x, r.position.y + fmod(i * 7.0, 12.0), minf(w, r.size.x - x), 1.0), Color(SURFACE, 0.12))
	for s in _surface:
		# A bright rippling waterline along the top of every open cell.
		for k in 4:
			var x := s.position.x + k * 4.0
			var lift := roundf(sin(_t * 3.0 + x * 0.15) * 1.0)
			draw_rect(Rect2(x, s.position.y + lift, 4.0, 2.0), Color(SURFACE, 0.75))
		draw_rect(Rect2(s.position + Vector2(0, 3), Vector2(s.size.x, 2.0)), Color(SURFACE, 0.18))
	# Bubbles rising from fixed spots in the deep water.
	var count := mini(cells.size() / 12, 40)
	var keys := cells.keys()
	for i in count:
		var c: Vector2i = keys[(i * 97) % keys.size()]
		if cells.has(c + Vector2i.UP + Vector2i.UP):
			var x := c.x * Room.TILE + 8.0 + sin(_t * 2.0 + i) * 2.0
			var y := c.y * Room.TILE + 16.0 - fmod(_t * 18.0 + i * 13.0, 32.0)
			draw_rect(Rect2(x, y, 2.0, 2.0), Color(BUBBLE, 0.5))
	for sp in _splashes:
		var k := sp.z / 0.6
		for side in [-1.0, 1.0]:
			for j in 3:
				var dx: float = side * (4.0 + j * 5.0) * (0.3 + k)
				var dy := -(14.0 - j * 3.0) * sin(k * PI)
				draw_rect(Rect2(sp.x + dx, sp.y + dy, 2.0, 2.0), Color(BUBBLE, 1.0 - k))
