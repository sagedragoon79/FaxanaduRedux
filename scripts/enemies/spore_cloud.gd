class_name SporeCloud
extends Node2D
## The cloud a Bog Myconid bursts into: it billows out to RADIUS, drifts up and
## thins away. Anyone inside is stung for DAMAGE at once and again every TICK.
## Spores can't be parried. Drawn at 2x: puffs land on half-pixels.

const RADIUS := 40.0
const GROW := 0.3
const LIFETIME := 2.4
const RISE := 10.0
const DAMAGE := 8
const TICK := 0.7
const PUFFS := 9
const SPORE := Color("b6c98a")
const SPORE_LIGHT := Color("e6efb8")
const SPORE_DARK := Color("6f8a5a")

var _t := 0.0
var _tick := 0.0
var _seeds: Array[Vector3] = []


func _ready() -> void:
	z_index = 2
	add_to_group("spore_cloud")
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(global_position)
	for i in PUFFS:
		var a := TAU * i / PUFFS + rng.randf_range(-0.3, 0.3)
		_seeds.append(Vector3(cos(a) * rng.randf_range(0.2, 0.7), sin(a) * rng.randf_range(0.15, 0.5), rng.randf_range(0.35, 0.55)))


## The cloud's reach now (px).
func radius() -> float:
	return RADIUS * clampf(_t / GROW, 0.15, 1.0)


## True while it can still sting.
func stinging() -> bool:
	return _t < LIFETIME * 0.85


func _physics_process(delta: float) -> void:
	_t += delta
	_tick -= delta
	global_position.y -= RISE * delta
	if _t >= LIFETIME:
		queue_free()
		return
	var p := get_tree().get_first_node_in_group("player") as Player
	if p != null and not p.dead and stinging() and _tick <= 0.0:
		var r := p.body_rect()
		var nearest := Vector2(clampf(global_position.x, r.position.x, r.end.x), clampf(global_position.y, r.position.y, r.end.y))
		if nearest.distance_to(global_position) < radius() * 0.8:
			p.receive_attack(DAMAGE, self, false)
			_tick = TICK
	queue_redraw()


func _draw() -> void:
	var fade := 1.0 - clampf((_t - LIFETIME * 0.55) / (LIFETIME * 0.45), 0.0, 1.0)
	var r := radius()
	for s in _seeds:
		var c := Vector2(s.x, s.y) * r
		c.y += sin(_t * 2.0 + s.x * 9.0) * 1.5
		var pr := maxf(2.0, r * s.z)
		_puff(c, pr + 0.5, Color(SPORE_DARK, 0.45 * fade))
		_puff(c + Vector2(-0.5, -0.5), pr, Color(SPORE, 0.5 * fade))
		_puff(c + Vector2(-pr * 0.3, -pr * 0.35), pr * 0.4, Color(SPORE_LIGHT, 0.45 * fade))
	# Motes of spore glinting in the cloud.
	for i in 6:
		var a := i * 1.7 + _t * 0.8
		var m := Vector2(cos(a), sin(a * 1.3)) * r * 0.6
		draw_rect(Rect2(roundf(m.x * 2.0) * 0.5, roundf(m.y * 2.0) * 0.5, 1.0, 1.0), Color(SPORE_LIGHT, 0.9 * fade))


## A round puff snapped to the 2x grid.
func _puff(c: Vector2, r: float, color: Color) -> void:
	draw_circle(Vector2(roundf(c.x * 2.0) * 0.5, roundf(c.y * 2.0) * 0.5), roundf(r * 2.0) * 0.5, color)
