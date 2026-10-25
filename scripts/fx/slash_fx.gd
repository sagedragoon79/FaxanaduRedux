class_name SlashFx
extends Node2D
## The smear arc for a sword swing or Mattock down-strike. Follows the player.

const LIFE := 0.12
const COLOR := Color("f6eed2")
const EDGE := Color("ffffff")
const HEAVY := Color("ffe9a8")

var _kind := "side"
var _facing := 1
var _combo := 1
var _heavy := false
var _life := LIFE
## Scales the smear for a bigger blade (the Giant Blade's arc).
var _size := 1.0


func setup(kind: String, facing: int, combo := 1, heavy := false, size := 1.0) -> void:
	_size = size
	_kind = kind
	_facing = facing
	_combo = combo
	_heavy = heavy
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
	# The second combo hit sweeps the other way, so a chain reads as back-and-forth cuts.
	if _combo == 2:
		var t := from
		from = to
		to = t
	var radius := (26.0 if _heavy else 20.0) * _size
	var width := (9.0 if _heavy else 6.0) * _size
	var sweep := lerpf(0.35, 1.0, 1.0 - k)
	var end := lerpf(from, to, sweep)
	draw_arc(center, radius, from, end, 12, Color(HEAVY if _heavy else COLOR, k), width)
	draw_arc(center, radius + 3.0, from, end, 12, Color(EDGE, k), 2.0)
