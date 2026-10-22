class_name SlashFx
extends Node2D
## The smear arc for a sword swing or Mattock down-strike. Follows the player.

const LIFE := 0.12
const COLOR := Color("f6eed2")
const EDGE := Color("ffffff")

var _kind := "side"
var _facing := 1
var _life := LIFE


func setup(kind: String, facing: int) -> void:
	_kind = kind
	_facing = facing
	z_index = 3


func _physics_process(delta: float) -> void:
	_life -= delta
	if _life <= 0.0:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var k := clampf(_life / LIFE, 0.0, 1.0)
	var center: Vector2
	var from: float
	var to: float
	match _kind:
		"up":
			center = Vector2(0, -38)
			from = deg_to_rad(-170)
			to = deg_to_rad(-10)
		"down":
			center = Vector2(0, -6)
			from = deg_to_rad(20)
			to = deg_to_rad(160)
		_:
			center = Vector2(_facing * 6, -22)
			from = deg_to_rad(-70) if _facing > 0 else deg_to_rad(250)
			to = deg_to_rad(70) if _facing > 0 else deg_to_rad(110)
	var sweep := lerpf(0.35, 1.0, 1.0 - k)
	var end := lerpf(from, to, sweep)
	draw_arc(center, 20.0, from, end, 10, Color(COLOR, k), 6.0)
	draw_arc(center, 23.0, from, end, 10, Color(EDGE, k), 2.0)
