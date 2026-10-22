class_name ThornBulb
extends Area2D
## A glowing thorn pod: dangerous to touch, the main pogo target for Mattock routes.

const POD := Color("c8323a")
const GLOW := Color("ff7a6a")
const THORN := Color("3b2a2a")

var _t := randf() * TAU
var _squish := 0.0


func _ready() -> void:
	collision_layer = Player.LAYER_HAZARD
	collision_mask = 0
	monitoring = false
	add_to_group("hazard")
	add_to_group("pogo")
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 6.0
	shape.shape = circle
	add_child(shape)


func take_hit(_damage: int, _dir: Vector2) -> void:
	_squish = 1.0
	Sfx.play("thorn", 0.1)


func _physics_process(delta: float) -> void:
	_t += delta * 3.0
	_squish = maxf(_squish - delta * 6.0, 0.0)
	queue_redraw()


func _draw() -> void:
	var r := 6.0 + sin(_t) * 0.5
	var sq := Vector2(1.0 + _squish * 0.4, 1.0 - _squish * 0.35)
	draw_set_transform(Vector2.ZERO, 0.0, sq)
	for i in 6:
		var a := TAU * i / 6.0 + 0.3
		draw_line(Vector2.from_angle(a) * r, Vector2.from_angle(a) * (r + 3), THORN, 2.0)
	draw_circle(Vector2.ZERO, r, POD)
	draw_circle(Vector2(-1.5, -1.5), r * 0.45, Color(GLOW, 0.6 + 0.3 * sin(_t)))
