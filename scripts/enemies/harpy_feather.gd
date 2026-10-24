class_name HarpyFeather
extends Node2D
## A feather a Storm Harpy flings: a steel-hard quill that flies straight and
## stings whoever it hits. It can be parried, and a parried feather flies back
## at the harpy that threw it, striking the first foe in its way.

const DAMAGE := 8
const REFLECT_DAMAGE := 12
const REFLECT_SPEED := 300.0
const LIFE := 2.2
const SIZE := 6.0
const QUILL := Color("d8d0f0")
const VANE := Color("6a5a9a")
const OUTLINE := Color("13101f")
const GOLD := Color("e8c04a")

var velocity := Vector2.ZERO
var thrower: Enemy
var reflected := false
var _t := 0.0


func _ready() -> void:
	z_index = 3
	add_to_group("enemy_projectile")


func _physics_process(delta: float) -> void:
	_t += delta
	if reflected and thrower != null and is_instance_valid(thrower) and not thrower.dead:
		# It homes on the harpy that threw it.
		velocity = (thrower.center() - global_position).normalized() * REFLECT_SPEED
	global_position += velocity * delta
	var box := Rect2(global_position - Vector2(SIZE, SIZE) * 0.5, Vector2(SIZE, SIZE))
	if reflected:
		for c: Variant in Query.rect(get_world_2d(), box, Player.LAYER_ENEMY):
			if c.is_in_group("enemy") and c.has_method("take_hit") and not c.dead:
				c.take_hit(REFLECT_DAMAGE, velocity.normalized())
				_burst()
				return
	else:
		var p := get_tree().get_first_node_in_group("player") as Player
		if p != null and not p.dead and box.intersects(p.body_rect()):
			if p.receive_attack(DAMAGE, self, true) != "parried":
				_burst()
				return
	var room := get_parent() as Room
	if _t >= LIFE or (room != null and room.is_solid_at(global_position)):
		_burst()
		return
	queue_redraw()


## Parried: the feather turns and flies back at its harpy (or straight back).
func stagger() -> void:
	if reflected:
		return
	reflected = true
	_t = 0.0
	var back := -velocity.normalized()
	if thrower != null and is_instance_valid(thrower) and not thrower.dead:
		back = (thrower.center() - global_position).normalized()
	velocity = back * REFLECT_SPEED


func _burst() -> void:
	var d := Dust.new()
	d.setup("feathers")
	get_parent().add_child(d)
	d.global_position = global_position
	queue_free()


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, velocity.angle())
	# A quill pointing along its flight: a gold tip, a violet vane, a pale shaft.
	draw_rect(Rect2(-6, -1.5, 11, 3), OUTLINE)
	draw_rect(Rect2(-5, -1, 7, 2), VANE)
	draw_rect(Rect2(-5, -0.5, 9, 1), QUILL)
	draw_rect(Rect2(3, -1, 2, 2), GOLD if not reflected else Color("fff4c0"))
	draw_set_transform(Vector2.ZERO)
