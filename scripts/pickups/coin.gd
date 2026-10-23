class_name Coin
extends CharacterBody2D
## A gold coin that pops out of a defeated enemy, bounces, then flies to the player.

const GRAVITY := 700.0
const MAGNET_DELAY := 0.4
const MAGNET_RANGE := 100.0
const MAGNET_SPEED := 320.0
const COLLECT_RANGE := 12.0
const LIFETIME := 12.0
const GOLD := Color("ffd24a")
const GOLD_DARK := Color("c08a1e")
const SHINE := Color("fff6c4")

var value := 1

var _age := 0.0
var _magnet := false


func _ready() -> void:
	collision_layer = 0
	collision_mask = Player.LAYER_WORLD
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(4, 4)
	shape.shape = rect
	shape.position = Vector2(0, -2)
	add_child(shape)
	z_index = 2
	if velocity == Vector2.ZERO:
		velocity = Vector2(randf_range(-80, 80), randf_range(-260, -160))


func _physics_process(delta: float) -> void:
	_age += delta
	var p := get_tree().get_first_node_in_group("player") as Player
	if p != null and not p.dead:
		var target := p.global_position + Vector2(0, -20)
		var d := target - global_position
		if _age > MAGNET_DELAY and d.length() < MAGNET_RANGE * p.magnet_mult:
			_magnet = true
		if _magnet:
			global_position += d.normalized() * minf(MAGNET_SPEED * delta, d.length())
			if global_position.distance_to(target) < COLLECT_RANGE:
				_collect(p)
				return
			queue_redraw()
			return
	velocity.y += GRAVITY * delta
	var was_falling := velocity.y > 60.0
	move_and_slide()
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0.0, 300.0 * delta)
		if was_falling and _age < 0.8:
			velocity.y = -90.0  # one small bounce
	if _age > LIFETIME:
		queue_free()
	queue_redraw()


func _collect(p: Player) -> void:
	p.add_gold(value, true)
	var d := Dust.new()
	d.setup("coin")
	get_parent().add_child(d)
	d.global_position = global_position
	Sfx.play("coin", 0.15, -4.0)
	queue_free()


func _draw() -> void:
	if _age > LIFETIME - 2.0 and int(_age * 10.0) % 2 == 0:
		return
	var spin := absf(sin(_age * 8.0))
	var w := maxf(1.0, round(4.0 * spin))
	draw_rect(Rect2(-w * 0.5 - 0.5, -5, w + 1, 5), GOLD_DARK)
	draw_rect(Rect2(-w * 0.5, -5, w, 4), GOLD)
	if w > 2:
		draw_rect(Rect2(-w * 0.5, -5, 1, 1), SHINE)


## Spawns `total` gold as a spray of coins (5-gold coins first, then singles).
static func spray(parent: Node, at: Vector2, total: int) -> void:
	var remaining := total
	while remaining > 0:
		var c := Coin.new()
		c.value = 5 if remaining >= 10 else 1
		remaining -= c.value
		parent.add_child(c)
		c.global_position = at
