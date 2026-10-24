class_name OnyxSheen
extends Node2D
## What the Black Onyx shows (design bible A7, 4.5): a thin violet seam that
## shimmers around every illusory wall (fake wall, legend `%`) in the room, and
## the hidden planks (legend `i`) drawn faintly. Without the Onyx it draws
## nothing and the planks stay invisible, though they still hold you up.

const SEAM := Color("c8b0ff")
## How faintly the hidden planks show through the Onyx.
const PHANTOM_ALPHA := 0.38
const FADE := 2.5

var room: Room
## The room's fake-wall cells (cell -> true).
var cells := {}
## 0 without the Onyx, easing to 1 once the player carries it.
var strength := 0.0

var _t := 0.0
## Seam segments [from, to] in world pixels, built once.
var _edges: Array = []


func _ready() -> void:
	z_index = 4
	for cell: Vector2i in cells:
		for side: Array in [[Vector2i.UP, Vector2(0, 0), Vector2(1, 0)], [Vector2i.DOWN, Vector2(0, 1), Vector2(1, 1)],
				[Vector2i.LEFT, Vector2(0, 0), Vector2(0, 1)], [Vector2i.RIGHT, Vector2(1, 0), Vector2(1, 1)]]:
			if not cells.has(cell + side[0]):
				var o := Vector2(cell) * Room.TILE
				_edges.append([o + side[1] * Room.TILE, o + side[2] * Room.TILE])


static func sees(p: Player) -> bool:
	return p != null and p.abilities.get("onyx", false)


func _physics_process(delta: float) -> void:
	_t += delta
	var p := get_tree().get_first_node_in_group("player") as Player
	strength = move_toward(strength, 1.0 if OnyxSheen.sees(p) else 0.0, delta * FADE)
	if room.phantoms != null:
		room.phantoms.modulate.a = strength * (PHANTOM_ALPHA + 0.08 * sin(_t * 3.0))
	if not _edges.is_empty():
		queue_redraw()


## A seam of half-pixel dashes; a brighter pulse sweeps along it so the eye
## catches it, and the whole seam breathes.
func _draw() -> void:
	if strength <= 0.0:
		return
	var breathe := 0.55 + 0.2 * sin(_t * 2.2)
	for e: Array in _edges:
		var a: Vector2 = e[0]
		var b: Vector2 = e[1]
		var step := (b - a) / 8.0
		for i in 8:
			var at := a + step * (i + 0.5)
			var wave := 0.5 + 0.5 * sin(_t * 4.0 - (at.x + at.y) * 0.09)
			var k := strength * (breathe * 0.6 + wave * wave * 0.5)
			if (i + int(_t * 6.0)) % 4 == 0:
				k *= 0.4
			var r := Rect2(at - Vector2(0.25, 0.25) - (step.abs() * 0.5), step.abs() + Vector2(0.5, 0.5))
			draw_rect(r, Color(SEAM, minf(k, 1.0)))
