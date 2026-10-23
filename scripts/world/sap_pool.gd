class_name SapPool
extends Node2D
## Amber sap pools (Trunk Hollows). Drawn over the player's feet so they read
## as sinking in. The slow-down itself is applied by the World. Sap with open
## air beside it and more sap below is a falls: drawn as a pouring stream that
## splashes into the pool it lands in.

const SAP := Color(0.85, 0.55, 0.12, 0.78)
const SAP_DEEP := Color(0.62, 0.34, 0.08, 0.85)
const SURFACE := Color("ffc76a")
const STREAM := Color(0.93, 0.66, 0.2, 0.82)
const STREAK := Color("ffd98f")

## Tile -> true.
var falls := {}

## Tile -> true.
var cells := {}

var _t := 0.0


func _ready() -> void:
	z_index = 2


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


## The falls among `cells`: sap with sap below whose row run of sap ends in
## open air (not sap and not `solid(cell)`) on at least one side. Pools are
## walled in on both sides, so only streams qualify.
static func find_falls(sap: Dictionary, solid: Callable) -> Dictionary:
	var out := {}
	for c: Vector2i in sap:
		if not sap.has(c + Vector2i.DOWN):
			continue
		var l := c
		while sap.has(l + Vector2i.LEFT):
			l += Vector2i.LEFT
		var r := c
		while sap.has(r + Vector2i.RIGHT):
			r += Vector2i.RIGHT
		var open_l: bool = not solid.call(l + Vector2i.LEFT)
		var open_r: bool = not solid.call(r + Vector2i.RIGHT)
		if open_l or open_r:
			out[c] = true
	return out


func _draw() -> void:
	var tile := float(Room.TILE)
	for c: Vector2i in cells:
		var r := Rect2(Vector2(c) * tile, Vector2(tile, tile))
		if falls.has(c):
			_draw_stream(c, r)
			continue
		var top := not cells.has(c + Vector2i(0, -1))
		draw_rect(r, SAP if top else SAP_DEEP)
		if top:
			for x in 16:
				var wave := sin(_t * 2.0 + (c.x * 16 + x) * 0.35)
				var y := 1.0 + roundf(wave)
				draw_rect(Rect2(r.position + Vector2(x, y), Vector2(1, 1)), SURFACE)
			# Slow bubbles.
			var phase := fmod(_t * 0.6 + c.x * 0.37, 1.0)
			if (c.x * 7) % 3 == 0:
				draw_rect(Rect2(r.position + Vector2(5 + (c.x % 5), 12 - phase * 10), Vector2(2, 2)), SURFACE)


func _draw_stream(c: Vector2i, r: Rect2) -> void:
	draw_rect(r, STREAM)
	var left := not cells.has(c + Vector2i.LEFT)
	var right := not cells.has(c + Vector2i.RIGHT)
	if left:
		draw_rect(Rect2(r.position, Vector2(1, 16)), SAP_DEEP)
	if right:
		draw_rect(Rect2(r.position + Vector2(15, 0), Vector2(1, 16)), SAP_DEEP)
	# Streaks pouring down, each lane at its own pace.
	for lane in 4:
		var x := 2 + lane * 4 + (c.x * 3 + lane) % 2
		var speed := 70.0 + float((c.x * 5 + lane * 11) % 4) * 12.0
		var y := fmod(_t * speed + float(lane * 7 + c.x * 13) + c.y * 16.0, 16.0)
		draw_rect(Rect2(r.position + Vector2(x, y), Vector2(1, minf(5.0, 16.0 - y))), STREAK)
	# Where the stream meets the pool below, it splashes.
	var below := c + Vector2i.DOWN
	if cells.has(below) and not falls.has(below):
		for i in 3:
			var phase := fmod(_t * 1.7 + i * 0.33 + c.x * 0.21, 1.0)
			var px := r.position.x + 3.0 + i * 5.0 + sin(phase * 6.0) * 2.0
			var py := r.end.y - phase * 6.0
			draw_rect(Rect2(px, py, 2, 2), Color(SURFACE, 1.0 - phase))
