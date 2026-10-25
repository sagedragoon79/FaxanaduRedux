class_name TilteOrb
extends Node2D
## The Tilte spell (design bible 4.1, a supporting spell): a homing spirit orb.
## It leaves the hand drifting up and forward and hangs for WAKE seconds,
## pulsing (the tell that it is choosing), then locks on the nearest foe within
## SEEK and flies at it, turning at most TURN radians a second, so a quick foe
## can slip it. Walls stop it. With no foe in reach it sails straight on.
## It lights the fog as it flies (group "light").

const SIZE := Vector2(8, 8)
const WAKE := 0.15
const SPEED := 230.0
const DRIFT := 70.0
const TURN := 6.0
const SEEK := 240.0
const LIFE := 2.2
const CORE := Color("ffffff")
const BODY := Color("9cf0d8")
const HALO := Color("4ac8b0")

var damage := 14
var velocity := Vector2.ZERO
## The direction it sets off in (from the caster's facing, fanned for a swarm).
var heading := Vector2.RIGHT
var light_radius := 36.0
## The foe it has locked on to, if any.
var target: Node2D

var _life := LIFE
var _clock := 0.0
var _trail: Array[Vector2] = []


func _ready() -> void:
	z_index = 3
	add_to_group("projectile")
	add_to_group("light")
	velocity = heading.normalized() * DRIFT


func _physics_process(delta: float) -> void:
	_life -= delta
	_clock += delta
	_trail.push_front(global_position)
	if _trail.size() > 7:
		_trail.pop_back()
	if _clock < WAKE:
		velocity = velocity.move_toward(Vector2.ZERO, DRIFT * 2.0 * delta)
	else:
		if target == null or not is_instance_valid(target) or target.get("dead") == true:
			target = nearest_foe(global_position, heading.x)
		var want := heading if target == null else (target.global_position + Vector2(0, -10) - global_position)
		var dir := velocity.normalized() if velocity.length() > 1.0 else heading.normalized()
		var turn := clampf(dir.angle_to(want), -TURN * delta, TURN * delta)
		velocity = dir.rotated(turn) * SPEED
	global_position += velocity * delta
	var area := Rect2(global_position - SIZE * 0.5, SIZE)
	for c: Variant in Query.rect(get_world_2d(), area, Player.LAYER_WORLD | Player.LAYER_ENEMY):
		if c.is_in_group("enemy") and c.has_method("take_hit"):
			if c.get("dead") == true:
				continue
			c.take_hit(damage, Vector2(signf(velocity.x) if velocity.x != 0.0 else heading.x, 0))
			_pop()
			return
		if c is TileMapLayer or c is StaticBody2D:
			_pop()
			return
	if _life <= 0.0:
		_pop()
		return
	queue_redraw()


## The nearest live foe within SEEK, preferring those on the `side` it set off
## toward (a foe behind counts as twice as far).
func nearest_foe(from: Vector2, side: float) -> Node2D:
	var best: Node2D = null
	var best_d := INF
	for e in get_tree().get_nodes_in_group("enemy"):
		var n := e as Node2D
		if n == null or n.get("dead") == true or not n.has_method("take_hit"):
			continue
		var d := n.global_position.distance_to(from)
		if d > SEEK:
			continue
		if signf(n.global_position.x - from.x) != signf(side):
			d *= 2.0
		if d < best_d:
			best_d = d
			best = n
	return best


func _pop() -> void:
	var d := Dust.new()
	d.setup("parry")
	get_parent().add_child(d)
	d.global_position = global_position
	Sfx.play("tilte_hit", 0.1)
	queue_free()


func _draw() -> void:
	for i in _trail.size():
		var p := to_local(_trail[i])
		var s := 6.0 - i * 0.7
		draw_rect(Rect2(p - Vector2(s, s) * 0.5, Vector2(s, s)), Color(HALO, 0.6 - i * 0.08))
	# While it wakes the halo swells and pulses: the tell that it is choosing.
	var waking := _clock < WAKE
	var pulse := 1.0 + (0.6 * sin(_clock * 60.0) if waking else 0.25 * sin(_clock * 18.0))
	draw_circle(Vector2.ZERO, 9.0 * pulse, Color(HALO, 0.3))
	draw_circle(Vector2.ZERO, 5.5, BODY)
	draw_rect(Rect2(-2, -2, 4, 4), CORE)
