class_name SeedShot
extends Node2D
## A seed Pakukame spits: a hard green pip that arcs through the air and
## stings whoever it hits. It can be parried, and bursts on the leaf.

const GRAVITY := 600.0
const DAMAGE := 12
const LIFE := 3.0
const SIZE := 6.0

var velocity := Vector2.ZERO
var _t := 0.0


func _physics_process(delta: float) -> void:
	_t += delta
	velocity.y += GRAVITY * delta
	global_position += velocity * delta
	var p := get_tree().get_first_node_in_group("player") as Player
	if p != null and not p.dead and Rect2(global_position - Vector2(SIZE, SIZE) * 0.5, Vector2(SIZE, SIZE)).intersects(p.body_rect()):
		p.receive_attack(DAMAGE, self, true)
		_burst()
		return
	var room := get_parent() as Room
	if _t >= LIFE or (room != null and room.is_solid_at(global_position)):
		_burst()
		return
	queue_redraw()


func _burst() -> void:
	var d := Dust.new()
	d.setup("hit")
	get_parent().add_child(d)
	d.global_position = global_position
	queue_free()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 3.5, Color("13200f"))
	draw_circle(Vector2.ZERO, 2.5, Color("8cc35a"))
	draw_circle(Vector2(-0.8, -0.8), 1.0, Color("e8f0c0"))
