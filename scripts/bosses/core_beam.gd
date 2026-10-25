class_name CoreBeam
extends Node2D
## A beam the meteor's core fires down the Veins at you (the Evil One, phase 2,
## design bible 8.9). A thin flickering line marks where it will strike for
## `tell` seconds (never under Enemy.MIN_TELEGRAPH), then a lance of light burns
## along it for FIRE seconds. Unparryable: get out of the line. The Hour Glass
## holds it, line and all. The origin is where it is fired from.

const FIRE := 0.35
const LENGTH := 1400.0
const WIDTH := 12.0
const DAMAGE := 16
const LIGHT := Color("e8fffc")
const CYAN := Color("4ae0d8")
const RED := Color("ff4060")

## Unit direction it fires along.
var direction := Vector2.DOWN
var tell := 0.6
var _t := 0.0
var _hit := false


func _ready() -> void:
	z_index = 3
	add_to_group("enemy_projectile")


func firing() -> bool:
	return _t >= tell and _t < tell + FIRE


## How far the point `p` is from the beam's line (only ahead of the origin).
func distance_to(p: Vector2) -> float:
	var along := clampf((p - global_position).dot(direction), 0.0, LENGTH)
	return (global_position + direction * along).distance_to(p)


func _physics_process(delta: float) -> void:
	if TimeStop.active():
		return
	_t += delta
	if _t >= tell + FIRE:
		queue_free()
		return
	if firing() and not _hit:
		var pl := get_tree().get_first_node_in_group("player") as Player
		if pl != null and not pl.dead and distance_to(pl.body_rect().get_center()) <= WIDTH * 0.5 + 6.0:
			_hit = pl.receive_attack(DAMAGE, self, false) != ""
	queue_redraw()


func _draw() -> void:
	var end := direction * LENGTH
	if _t < tell:
		var on := int(_t * (10.0 + 20.0 * _t / tell)) % 2 == 0
		draw_line(Vector2.ZERO, end, Color(RED if on else CYAN, 0.35 + 0.4 * _t / tell), 1.0)
		return
	var k := 1.0 - (_t - tell) / FIRE
	draw_line(Vector2.ZERO, end, Color(CYAN, 0.6 * k), WIDTH + 6.0)
	draw_line(Vector2.ZERO, end, Color(LIGHT, k), WIDTH * 0.5)
