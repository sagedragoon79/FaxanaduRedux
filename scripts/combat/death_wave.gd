class_name DeathWave
extends Node2D
## The Death spell (design bible 4.1, pass 132), the original's darkest magic:
## a ring of black light rolls out from the caster through walls and all, and
## every foe it passes takes one blow. Bosses take half. It costs most of a
## full flask of MP, so it is a last resort, not a weapon to lead with.

## Seconds the ring takes to roll out to RADIUS.
const DURATION := 0.45
## How far it reaches: about half the screen's width each way.
const RADIUS := 300.0
const CORE := Color("120814")
const RIM := Color("b070ff")

var damage := 36
var boss_damage := 18
## The foes struck so far (each is struck once).
var struck: Array[Node2D] = []

var _t := 0.0


func _ready() -> void:
	z_index = 3
	add_to_group("projectile")
	Feel.add_trauma(0.25)
	Sfx.play("death_wave", 0.03)


## How far out the ring is now.
func radius() -> float:
	return RADIUS * ease(minf(_t / DURATION, 1.0), 0.6)


func _physics_process(delta: float) -> void:
	_t += delta
	var r := radius()
	for n in get_tree().get_nodes_in_group("enemy"):
		var e := n as Node2D
		if e == null or e in struck or e.get("dead") == true or not e.has_method("take_hit"):
			continue
		var mid: Vector2 = e.call("center") if e.has_method("center") else e.global_position
		if mid.distance_to(global_position) > r:
			continue
		struck.append(e)
		# It falls on them from everywhere at once: no shield faces it.
		e.take_hit(boss_damage if e.is_in_group("boss") else damage, Vector2.DOWN)
	if _t >= DURATION + 0.2:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var r := radius()
	var k := clampf(_t / DURATION, 0.0, 1.0)
	var fade := 1.0 - clampf((_t - DURATION) / 0.2, 0.0, 1.0)
	# A dark hush inside the ring, thinning as it spreads.
	draw_circle(Vector2.ZERO, r, Color(CORE, 0.35 * (1.0 - k) * fade))
	# The ring: a black band with a violet rim, and a fainter echo behind it.
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 96, Color(CORE, 0.8 * fade), 6.0)
	draw_arc(Vector2.ZERO, r + 3.0, 0.0, TAU, 96, Color(RIM, 0.9 * fade), 2.0)
	draw_arc(Vector2.ZERO, r * 0.8, 0.0, TAU, 96, Color(RIM, 0.3 * fade), 1.0)
