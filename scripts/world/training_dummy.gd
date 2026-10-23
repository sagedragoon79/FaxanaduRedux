class_name TrainingDummy
extends Area2D
## A straw dummy for testing hits and pogo. Flashes, wobbles, breaks and returns.

const HP := 40
const RESPAWN_TIME := 1.5
const STRAW := Color("d9b45a")
const STRAW_DARK := Color("a8843a")
const POST := Color("6b4a2b")
const OUTLINE := Color("1d1a2b")

var hp := HP
var hits_taken := 0

var _flash := 0.0
var _wobble := 0.0
var _dead_timer := 0.0


func _ready() -> void:
	collision_layer = Player.LAYER_ENEMY
	collision_mask = 0
	monitoring = false
	add_to_group("pogo")
	add_to_group("enemy")
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(18, 34)
	shape.shape = rect
	shape.position = Vector2(0, -17)
	add_child(shape)


func take_hit(damage: int, dir: Vector2) -> void:
	if _dead_timer > 0.0:
		return
	hp -= damage
	hits_taken += 1
	_flash = 0.07
	_wobble = signf(dir.x) if dir.x != 0.0 else 0.5
	var d := Dust.new()
	d.setup("hit")
	get_parent().add_child(d)
	d.global_position = global_position + Vector2(0, -20)
	if hp <= 0:
		_dead_timer = RESPAWN_TIME
		collision_layer = 0
		var debris := Dust.new()
		debris.setup("debris")
		get_parent().add_child(debris)
		debris.global_position = global_position + Vector2(0, -16)
		Feel.hitstop(0.09)
		Feel.add_trauma(0.25)


func _physics_process(delta: float) -> void:
	_flash -= delta
	_wobble = move_toward(_wobble, 0.0, delta * 4.0)
	if _dead_timer > 0.0:
		_dead_timer -= delta
		if _dead_timer <= 0.0:
			hp = HP
			collision_layer = Player.LAYER_ENEMY
	queue_redraw()


func _draw() -> void:
	if _dead_timer > 0.0:
		draw_rect(Rect2(-2, -8, 4, 8), POST)
		return
	var white := _flash > 0.0
	draw_set_transform(Vector2.ZERO, _wobble * 0.25 * sin(Time.get_ticks_msec() * 0.03), Vector2.ONE)
	draw_rect(Rect2(-2, -12, 4, 12), Color.WHITE if white else POST)
	draw_rect(Rect2(-8, -31, 16, 20), OUTLINE)
	draw_rect(Rect2(-7, -30, 14, 18), Color.WHITE if white else STRAW)
	draw_rect(Rect2(-7, -22, 14, 2), Color.WHITE if white else STRAW_DARK)
	draw_rect(Rect2(-5, -39, 10, 9), OUTLINE)
	draw_rect(Rect2(-4, -38, 8, 7), Color.WHITE if white else STRAW)
	draw_rect(Rect2(-12, -28, 24, 3), Color.WHITE if white else STRAW_DARK)
