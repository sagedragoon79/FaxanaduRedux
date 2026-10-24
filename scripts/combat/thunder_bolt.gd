class_name ThunderBolt
extends Node2D
## The Thunder spell (design bible 4.1, A6): a fast crackling bolt. Before it
## touches anything, it leaps to any dead conduit (group "conductor") within
## ARC of it ahead or beside, and wakes it. Otherwise it strikes the first foe
## or wall it meets.

const SIZE := Vector2(12, 6)
const LIFE := 0.7
## How far the bolt leaps to a conduit.
const ARC := 72.0
const CORE := Color("f8f0b0")
const BODY := Color("b8a8ff")

var damage := 16
var velocity := Vector2.ZERO
var light_radius := 36.0

var _life := LIFE
var _clock := 0.0


func _ready() -> void:
	z_index = 3
	add_to_group("projectile")
	add_to_group("light")


func _physics_process(delta: float) -> void:
	_life -= delta
	_clock += delta
	global_position += velocity * delta
	var target := _conduit_in_reach()
	if target != null:
		LightningArc.spawn(get_parent(), global_position, target.spark_point())
		target.power()
		queue_free()
		return
	var area := Rect2(global_position - SIZE * 0.5, SIZE)
	for c: Variant in Query.rect(get_world_2d(), area, Player.LAYER_WORLD | Player.LAYER_ENEMY):
		if c.is_in_group("enemy") and c.has_method("take_hit"):
			c.take_hit(damage, Vector2(signf(velocity.x), 0))
			Feel.hitstop(0.05)
			_fizzle()
			return
		if c is TileMapLayer or c is StaticBody2D:
			_fizzle()
			return
	if _life <= 0.0:
		_fizzle()
		return
	queue_redraw()


## The nearest dead conduit within ARC, not behind the bolt.
func _conduit_in_reach() -> Conduit:
	var best: Conduit = null
	var best_d := ARC
	var dir := signf(velocity.x)
	for n in get_tree().get_nodes_in_group("conductor"):
		var c := n as Conduit
		if c.powered:
			continue
		var off := c.spark_point() - global_position
		if off.x * dir < -8.0:
			continue
		var d := off.length()
		if d <= best_d:
			best = c
			best_d = d
	return best


func _fizzle() -> void:
	var d := Dust.new()
	d.setup("parry")
	get_parent().add_child(d)
	d.global_position = global_position
	Sfx.play("zap", 0.1, -4.0)
	queue_free()


func _draw() -> void:
	var dir := signf(velocity.x)
	var pts := PackedVector2Array()
	for i in 6:
		var x := -dir * i * 4.0
		var y := (2.0 if (i + int(_clock * 40.0)) % 2 == 0 else -2.0) if i > 0 else 0.0
		pts.append(Vector2(x, y))
	draw_polyline(pts, Color(BODY, 0.7), 3.0)
	draw_polyline(pts, CORE, 1.0)
	draw_circle(Vector2.ZERO, 3.0, CORE)
