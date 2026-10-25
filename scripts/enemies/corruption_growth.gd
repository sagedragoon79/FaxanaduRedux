class_name CorruptionGrowth
extends Node2D
## The meteor crystal grown through a corrupted foe of Zenis (design bible 8.9),
## drawn over whatever the foe draws: shards jutting from its back, glowing
## veins and a cyan eye that opens on its flank. It follows the foe's facing and
## pulses with the meteor's heartbeat. A child of the Enemy.

const SHARD := Color("4ae0d8")
const SHARD_LIGHT := Color("b8fff4")
const SHARD_DARK := Color("1a6a78")
const VEIN := Color("d03050")
const OUTLINE := Color("13101f")
## The meteor's heartbeat (beats per second), shared with the Zenis theme's tempo.
const BEAT := 1.25

var _t := 0.0


func _ready() -> void:
	z_index = 1


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


## 0..1: a sharp beat that fades.
func pulse() -> float:
	var ph := fmod(_t * BEAT, 1.0)
	return maxf(0.0, 1.0 - ph * 4.0)


func _draw() -> void:
	var e := get_parent() as Enemy
	if e == null:
		return
	var size := e.body_size
	var c := e.center() - e.global_position
	var f := float(e.facing)
	var top := c.y - size.y * 0.5
	var p := pulse()
	# Shards up through the back (the side away from where it faces), tallest in the middle.
	var heights := [0.55, 0.85, 0.45]
	for i in 3:
		var x := c.x - f * size.x * (0.05 + 0.18 * i)
		var h := maxf(6.0, size.y * float(heights[i]))
		var w := clampf(size.x * 0.12, 3.0, 6.0)
		var lean := -f * h * 0.25
		var base_y := top + size.y * 0.15
		var tip := Vector2(x + lean, base_y - h)
		draw_colored_polygon(PackedVector2Array([Vector2(x - w - 1.0, base_y), tip + Vector2(0, -1.5), Vector2(x + w + 1.0, base_y)]), OUTLINE)
		draw_colored_polygon(PackedVector2Array([Vector2(x - w, base_y), tip, Vector2(x + w, base_y)]), SHARD)
		draw_colored_polygon(PackedVector2Array([Vector2(x - w * 0.2, base_y), tip, Vector2(x + w * 0.6, base_y)]), SHARD_LIGHT.lerp(SHARD, 0.5 - 0.5 * p))
		draw_line(Vector2(x - w, base_y), Vector2(x + w, base_y), SHARD_DARK, 1.0)
	# Red veins spread from the shards down the body, brighter on the beat.
	for i in 2:
		var vx := c.x - f * size.x * (0.1 + 0.2 * i)
		draw_line(Vector2(vx, top + size.y * 0.15), Vector2(vx + f * 3.0, top + size.y * 0.6), Color(VEIN, 0.45 + 0.5 * p), 1.0)
	# The eye on its flank, toward the way it faces.
	var eye := Vector2(c.x + f * size.x * 0.12, c.y + size.y * 0.05)
	draw_rect(Rect2(eye - Vector2(2.5, 2.0), Vector2(5, 4)), OUTLINE)
	draw_rect(Rect2(eye - Vector2(1.5, 1.0), Vector2(3, 2)), SHARD_LIGHT if p > 0.3 else SHARD)
	draw_rect(Rect2(eye - Vector2(0.5, 1.0), Vector2(1, 2)), OUTLINE)
