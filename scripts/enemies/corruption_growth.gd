class_name CorruptionGrowth
extends Node2D
## The stillglass grown through a corrupted foe of the Evercrown (design bible 8.9),
## drawn over whatever the foe draws: shards jutting from its back, glowing
## veins and a cyan eye that opens on its flank. It follows the foe's facing and
## pulses with the Everbloom's heartbeat. A child of the Enemy.

const SHARD := Color("4ae0d8")
const SHARD_LIGHT := Color("b8fff4")
const SHARD_DARK := Color("1a6a78")
const VEIN := Color("d03050")
const OUTLINE := Color("13101f")
## The stillglass's heartbeat (beats per second), shared with the Evercrown theme's tempo.
const BEAT := 1.25
## Each shard casts the stillglass's own light onto the foe's body around its base,
## so the glass lifts off the silhouette instead of reading as a flat decal stamped
## over the foe (pass 494). GLOW_MARGIN is how far past the shard's own width that
## light reaches, in pixels; GLOW_ALPHA its strength. Both must stay above zero or
## the shards flatten back into the body.
const GLOW_MARGIN := 5.0
const GLOW_ALPHA := 0.17
## A dark socket where each shard breaks the skin, so it reads as growing out of the
## flesh rather than sitting on top of it.
const SOCKET_ALPHA := 0.55

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


## Each back-shard's geometry for a foe of `size`, facing `f` (-1/1), with its body
## centre at `c` relative to this node. Returns, per shard: `base` (on the skin),
## `tip`, `half_width`, and the cast-light `glow_center` / `glow_radius` that reach
## GLOW_MARGIN past the shard so a reader can tell glass from foe. `_draw` and the
## readability test share this, so the separation is the same on screen as under test.
func shards(size: Vector2, f: float, c: Vector2) -> Array:
	var out: Array = []
	var top := c.y - size.y * 0.5
	var base_y := top + size.y * 0.15
	var heights := [0.55, 0.85, 0.45]
	for i in 3:
		var x := c.x - f * size.x * (0.05 + 0.18 * i)
		var h := maxf(6.0, size.y * float(heights[i]))
		var w := clampf(size.x * 0.12, 3.0, 6.0)
		var tip := Vector2(x - f * h * 0.25, base_y - h)
		out.append({
			"base": Vector2(x, base_y),
			"tip": tip,
			"half_width": w,
			"glow_center": Vector2(x + (tip.x - x) * 0.5, base_y - h * 0.5),
			"glow_radius": w + GLOW_MARGIN,
		})
	return out


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
	for s in shards(size, f, c):
		var base: Vector2 = s["base"]
		var tip: Vector2 = s["tip"]
		var w: float = s["half_width"]
		# The stillglass's light cast on the body, falling off outward, so the shard
		# reads against any foe silhouette and glows a touch brighter on the beat.
		for g in 3:
			var rr: float = s["glow_radius"] * (1.0 - g * 0.26)
			draw_circle(s["glow_center"], rr, Color(SHARD, GLOW_ALPHA * 0.6 + 0.06 * p))
		# A dark socket where it breaks the skin: the shard grows out, not onto, the foe.
		draw_circle(base, w * 0.9, Color(OUTLINE, SOCKET_ALPHA))
		draw_colored_polygon(PackedVector2Array([base + Vector2(-w - 1.0, 0), tip + Vector2(0, -1.5), base + Vector2(w + 1.0, 0)]), OUTLINE)
		draw_colored_polygon(PackedVector2Array([base + Vector2(-w, 0), tip, base + Vector2(w, 0)]), SHARD)
		# The base third sinks back toward the socket, so the lit tip stands clear of it.
		var mid := base.lerp(tip, 0.34)
		draw_colored_polygon(PackedVector2Array([base + Vector2(-w, 0), Vector2(base.x - w * 0.4, mid.y), Vector2(base.x + w * 0.4, mid.y), base + Vector2(w, 0)]), Color(SHARD_DARK, 0.6))
		draw_colored_polygon(PackedVector2Array([base + Vector2(-w * 0.2, 0), tip, base + Vector2(w * 0.6, 0)]), SHARD_LIGHT.lerp(SHARD, 0.5 - 0.5 * p))
		draw_line(base + Vector2(-w, 0), base + Vector2(w, 0), SHARD_DARK, 1.0)
	# Red veins spread from the shards down the body, brighter on the beat.
	for i in 2:
		var vx := c.x - f * size.x * (0.1 + 0.2 * i)
		draw_line(Vector2(vx, top + size.y * 0.15), Vector2(vx + f * 3.0, top + size.y * 0.6), Color(VEIN, 0.45 + 0.5 * p), 1.0)
	# The eye on its flank, toward the way it faces, with its own faint cast light.
	var eye := Vector2(c.x + f * size.x * 0.12, c.y + size.y * 0.05)
	draw_circle(eye, 4.5, Color(SHARD, GLOW_ALPHA * 0.7 + 0.08 * p))
	draw_rect(Rect2(eye - Vector2(2.5, 2.0), Vector2(5, 4)), OUTLINE)
	draw_rect(Rect2(eye - Vector2(1.5, 1.0), Vector2(3, 2)), SHARD_LIGHT if p > 0.3 else SHARD)
	draw_rect(Rect2(eye - Vector2(0.5, 1.0), Vector2(1, 2)), OUTLINE)
