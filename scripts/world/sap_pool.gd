class_name SapPool
extends Node2D
## Amber sap pools (Trunk Hollows). Drawn over the player's feet so they read
## as sinking in. The slow-down itself is applied by the World.

const SAP := Color(0.85, 0.55, 0.12, 0.78)
const SAP_DEEP := Color(0.62, 0.34, 0.08, 0.85)
const SURFACE := Color("ffc76a")

## Tile -> true.
var cells := {}

var _t := 0.0


func _ready() -> void:
	z_index = 2


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var tile := float(Room.TILE)
	for c: Vector2i in cells:
		var r := Rect2(Vector2(c) * tile, Vector2(tile, tile))
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
