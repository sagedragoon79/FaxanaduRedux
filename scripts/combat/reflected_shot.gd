class_name ReflectedShot
extends Node2D
## A small projectile turned by the Magic Shield (design bible 5.2 and the
## Daybreak armory): parried, the seed, glob or pip the shield caught flies back
## as a mote of the shield's light, straight at the nearest foe in front of you
## (or straight ahead if none is near), and strikes the first foe it meets for
## DAMAGE. Walls stop it. The Hour Glass holds it still.

const SPEED := 340.0
const DAMAGE := 16
const SIZE := 8.0
const LIFE := 1.4
## How far ahead it looks for a foe to fly at (px).
const SEEK := 260.0
const LIGHT := Color("fff4c8")
const GOLD := Color("e8c04a")

var velocity := Vector2.ZERO
## The colour of what was caught, glowing at its core.
var tint := GOLD
var _t := 0.0
var _hit := {}


## Turns `source` back from the player: spawns the shot where it was caught.
static func spawn(p: Player, source: Node2D, tint_color := GOLD) -> ReflectedShot:
	var s := ReflectedShot.new()
	s.tint = tint_color
	var from := source.global_position
	var aim := Vector2(p.facing, 0)
	var target := nearest_foe(p, from)
	if target != null:
		aim = (target.center() - from).normalized()
	s.velocity = aim * SPEED
	source.get_parent().add_child(s)
	s.global_position = from
	return s


## The nearest living foe within SEEK px on the side the player faces.
static func nearest_foe(p: Player, from: Vector2) -> Enemy:
	var best: Enemy = null
	var best_d := SEEK
	for n in p.get_tree().get_nodes_in_group("enemy"):
		var e := n as Enemy
		if e == null or e.dead:
			continue
		var off := e.center() - from
		if signf(off.x) != float(p.facing) and absf(off.x) > 4.0:
			continue
		if off.length() < best_d:
			best_d = off.length()
			best = e
	return best


func _ready() -> void:
	z_index = 3


func hit_rect() -> Rect2:
	return Rect2(global_position - Vector2(SIZE, SIZE) * 0.5, Vector2(SIZE, SIZE))


func _physics_process(delta: float) -> void:
	if TimeStop.active():
		return
	_t += delta
	global_position += velocity * delta
	for c: Variant in Query.rect(get_world_2d(), hit_rect(), Player.LAYER_ENEMY):
		if c.has_method("take_hit") and not bool(c.get("dead")) and not _hit.has(c.get_instance_id()):
			_hit[c.get_instance_id()] = true
			c.take_hit(DAMAGE, velocity.normalized())
			Sfx.play("hit", 0.1, 2.0)
			_burst()
			return
	var room := get_parent() as Room
	if _t >= LIFE or (room != null and room.is_solid_at(global_position)):
		_burst()
		return
	queue_redraw()


func _burst() -> void:
	var d := Dust.new()
	d.setup("parry")
	get_parent().add_child(d)
	d.global_position = global_position
	queue_free()


func _draw() -> void:
	var k := 0.7 + 0.3 * absf(sin(_t * 24.0))
	var back := -velocity.normalized()
	# A short comet of shield light with the caught shot glowing at its heart.
	for i in 5:
		draw_circle(back * (5.0 + i * 5.0), 4.0 - i * 0.7, Color(GOLD, 0.6 - i * 0.1))
	draw_circle(Vector2.ZERO, 7.0 * k, Color(LIGHT, 0.5))
	draw_arc(Vector2.ZERO, 7.0 * k, 0.0, TAU, 16, Color(GOLD, 0.9), 1.0)
	draw_circle(Vector2.ZERO, 4.0, tint)
	draw_circle(Vector2(-1, -1), 1.5, LIGHT)
