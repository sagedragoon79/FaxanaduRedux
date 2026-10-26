class_name Ladders
extends Node2D
## The room's ladders (legend `"`, design bible 6.11): two wooden rails with a
## rung every 8 px, drawn behind the tiles so the top cell's plank sits over
## the rails' ends. Climbing is the player's (`Player.on_ladder`); this only
## draws them.

const RAIL := Color("5e3b22")
const RAIL_LIGHT := Color("8a5a34")
const RUNG := Color("a8784a")
const RUNG_SHADE := Color("5e3b22")

var cells := {}


func _ready() -> void:
	z_index = -1


func _draw() -> void:
	var t := Room.TILE
	for c: Vector2i in cells:
		var o := Vector2(c * t)
		# Rails: 2 px wide, 10 px apart, with a lit left edge.
		for x: int in [2, 12]:
			draw_rect(Rect2(o + Vector2(x, 0), Vector2(2, t)), RAIL)
			draw_rect(Rect2(o + Vector2(x, 0), Vector2(1, t)), RAIL_LIGHT)
		for y: int in [3, 11]:
			draw_rect(Rect2(o + Vector2(4, y), Vector2(8, 2)), RUNG)
			draw_rect(Rect2(o + Vector2(4, y + 1), Vector2(8, 1)), RUNG_SHADE)
