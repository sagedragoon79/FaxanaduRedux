class_name Fireball
extends Node2D
## The Fire spell (design bible 4.1, a supporting spell): a ball of flame thrown in an arc. It bursts
## on whatever it meets, a wall, a floor or a foe, scorching every foe in the
## burst and setting anything in the "fire_target" group alight (bramble walls).
## A foe in living bark (Bark Knight, Bark Knight Captain) loses all its bark to it.
## It lights the fog as it flies (group "light").

const SIZE := Vector2(8, 8)
const GRAVITY := 520.0
const LIFE := 1.6
## Reach of the burst from where the ball lands.
const BURST := 20.0
const CORE := Color("fff0b0")
const BODY := Color("f08a2a")
const DARK := Color("b8401a")

var damage := 18
var velocity := Vector2.ZERO
var light_radius := 40.0

var _life := LIFE
var _trail: Array[Vector2] = []
var _clock := 0.0


func _ready() -> void:
	z_index = 3
	add_to_group("projectile")
	add_to_group("light")


func _physics_process(delta: float) -> void:
	_life -= delta
	_clock += delta
	_trail.push_front(global_position)
	if _trail.size() > 6:
		_trail.pop_back()
	velocity.y += GRAVITY * delta
	global_position += velocity * delta
	var area := Rect2(global_position - SIZE * 0.5, SIZE)
	for c: Variant in Query.rect(get_world_2d(), area, Player.LAYER_WORLD | Player.LAYER_ENEMY):
		if c.is_in_group("fire_target") or (c.is_in_group("enemy") and c.has_method("take_hit")) \
				or c is TileMapLayer or c is StaticBody2D:
			burst()
			return
	if _life <= 0.0:
		burst()
		return
	queue_redraw()


## Bursts where it is: every foe in reach is scorched once, every fire target lit.
func burst() -> void:
	var area := Rect2(global_position - Vector2(BURST, BURST), Vector2(BURST, BURST) * 2.0)
	var struck := {}
	for c: Variant in Query.rect(get_world_2d(), area, Player.LAYER_WORLD | Player.LAYER_ENEMY):
		if struck.has(c.get_instance_id()):
			continue
		struck[c.get_instance_id()] = true
		if c.is_in_group("fire_target") and c.has_method("burn"):
			c.burn()
		elif c.is_in_group("enemy") and c.has_method("take_hit"):
			if c.has_method("burn_bark"):
				# Living bark catches (pass 177): the whole coat burns off, and
				# the flame lands on bare heartwood.
				c.burn_bark()
			var dir := Vector2(signf((c as Node2D).global_position.x - global_position.x), 0)
			if dir.x == 0.0:
				dir.x = signf(velocity.x)
			c.take_hit(damage, dir)
	Feel.hitstop(0.03)
	var d := Dust.new()
	d.setup("embers")
	get_parent().add_child(d)
	d.global_position = global_position
	Sfx.play("fire_burst", 0.1)
	queue_free()


func _draw() -> void:
	for i in _trail.size():
		var p := to_local(_trail[i])
		var s := 5.0 - i * 0.7
		draw_rect(Rect2(p - Vector2(s, s) * 0.5, Vector2(s, s)), Color(BODY if i < 3 else DARK, 0.7 - i * 0.1))
	var flick := 0.5 if fmod(_clock * 20.0, 2.0) < 1.0 else 0.0
	draw_circle(Vector2.ZERO, 4.5, DARK)
	draw_circle(Vector2.ZERO, 3.5 + flick, BODY)
	draw_rect(Rect2(-1.5, -2.0, 2.5, 2.5), CORE)
