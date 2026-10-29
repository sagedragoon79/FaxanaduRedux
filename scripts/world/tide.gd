class_name Tide
extends Node2D
## The standing water of Dartmoor's drowned halls (design bible 4.4, `tide:`
## header). Until King Grieve is at rest it stands a tile deep on the floors
## and fills the pits below them: a still, dark water you wade through (your
## steps slosh), drawn translucent in front of what stands in it so the spikes
## under it still show. Once he is at rest Dartmoor drains, and all that is left
## is the tide mark where the surface stood, and silt on the floor.

const DRAIN_FLAG := "boss:king_grieve"
const WATER := Color(0.16, 0.38, 0.44, 0.55)
const DEEP := Color(0.06, 0.14, 0.2, 0.35)
const SURFACE := Color("a8e4e8")
const MARK := Color(0.3, 0.55, 0.55, 0.6)
const SILT := Color(0.32, 0.36, 0.3, 0.6)

## The water's cells (tiles) -> true.
var cells := {}
## The surface row (tiles).
var row := 0

var _t := 0.0
## Columns (tiles) the surface spans, sorted.
var _cols: Array[int] = []
## Each column's lowest water cell (tiles), where the silt settles.
var _floor := {}


func _ready() -> void:
	# The water stands in front of what wades in it; the mark it left is on the walls behind.
	z_index = -1 if drained() else 1
	for c: Vector2i in cells:
		if c.y == row:
			_cols.append(c.x)
		_floor[c.x] = maxi(int(_floor.get(c.x, c.y)), c.y)
	_cols.sort()


## True once King Grieve is at rest and the water has gone.
func drained() -> bool:
	return GameState.flag(DRAIN_FLAG)


## True if the point (room pixels) is in standing water.
func has_point(pos: Vector2) -> bool:
	return not drained() and cells.has(Vector2i(floori(pos.x / Room.TILE), floori(pos.y / Room.TILE)))


func _process(delta: float) -> void:
	if drained():
		return
	_t += delta
	queue_redraw()


func _draw() -> void:
	var y := float(row * Room.TILE)
	if drained():
		# The tide mark along the pillars and walls, and silt left on the floor.
		for x in _cols:
			draw_rect(Rect2(x * Room.TILE, y, Room.TILE, 2), MARK)
			var fy := float((int(_floor[x]) + 1) * Room.TILE)
			for k in 3:
				var sx := x * Room.TILE + ((x * 7 + k * 5) % Room.TILE)
				draw_rect(Rect2(sx, fy - 1, 2 + (x + k) % 2, 1), SILT)
		return
	for c: Vector2i in cells:
		draw_rect(Rect2(Vector2(c * Room.TILE), Vector2(Room.TILE, Room.TILE)), WATER if c.y == row else DEEP.lerp(WATER, 0.4))
	# The still surface: a pale line that breathes, with slow glints drifting on it.
	for x in _cols:
		var a := 0.55 + 0.25 * sin(_t * 1.3 + x * 0.6)
		draw_rect(Rect2(x * Room.TILE, y, Room.TILE, 1), Color(SURFACE, a))
		if (x + int(_t * 2.0)) % 5 == 0:
			draw_rect(Rect2(x * Room.TILE + 4 + int(_t * 6.0) % 8, y + 2, 3, 1), Color(SURFACE, 0.4))
