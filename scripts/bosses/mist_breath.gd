class_name MistBreath
extends Node2D
## A breath of mist from one of Zorugeriru's heads: a low bank of fog that rolls
## along the ground (or the flood's surface) from where the head breathed it.
## It hurts once and can't be parried; jump it, or stand on high ground.

const WIDTH := 44.0
const HEIGHT := 40.0
const SPEED := 150.0
const LIFE := 2.4
const DAMAGE := 12
const MIST := Color("dfe8ee")
const MIST_DARK := Color("9fb2c0")

var dir := 1.0
## The ground it rolls on (world y) and the arena's sides.
var ground_y := 0.0
var left := 0.0
var right := 0.0

var _time := 0.0
var _hit := false


func _ready() -> void:
	z_index = 3


func rect() -> Rect2:
	return Rect2(global_position.x - WIDTH * 0.5, ground_y - HEIGHT, WIDTH, HEIGHT)


func _physics_process(delta: float) -> void:
	_time += delta
	global_position.x += dir * SPEED * delta
	global_position.y = ground_y
	var p := get_tree().get_first_node_in_group("player") as Player
	if not _hit and p != null and not p.dead and rect().intersects(p.body_rect()):
		_hit = true
		p.receive_attack(DAMAGE, self, false)
	if _time >= LIFE or global_position.x < left - WIDTH or global_position.x > right + WIDTH:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var a := clampf(_time / 0.15, 0.0, 1.0) * clampf((LIFE - _time) / 0.4, 0.0, 1.0)
	# Rolling puffs, densest at the front.
	for i in 7:
		var k := float(i) / 6.0
		var x := (k - 0.5) * WIDTH + sin(_time * 7.0 + i * 1.7) * 3.0
		var r := 10.0 + 6.0 * sin(k * PI) + 2.0 * sin(_time * 5.0 + i)
		var y := -r * 0.9 - 2.0
		draw_circle(Vector2(x, y), r + 1.0, Color(MIST_DARK, 0.45 * a))
		draw_circle(Vector2(x, y - 1.0), r, Color(MIST, 0.7 * a))
	draw_rect(Rect2(-WIDTH * 0.5, -6, WIDTH, 6), Color(MIST, 0.8 * a))
