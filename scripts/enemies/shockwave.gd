class_name Shockwave
extends Node2D
## The shock of an Iron Dwarf's hammer, rolling along the floor away from him.
## It hugs the ground, so a jump clears it; it breaks up at a wall or a ledge.

const SPEED := 170.0
const LIFETIME := 0.9
const DAMAGE := 12
const SIZE := Vector2(12, 12)
const CORE := Color("f0c060")
const EDGE := Color("c8784a")

var direction := 1
var room: Room
var _t := 0.0


func _ready() -> void:
	z_index = 1


func hit_rect() -> Rect2:
	return Rect2(global_position - Vector2(SIZE.x * 0.5, SIZE.y), SIZE)


func _physics_process(delta: float) -> void:
	_t += delta
	var next := global_position + Vector2(direction * SPEED * delta, 0)
	var ahead := next + Vector2(direction * SIZE.x * 0.5, -4)
	var below := next + Vector2(0, 4)
	if _t > LIFETIME or (room != null and (room.is_solid_at(ahead) or not (room.is_solid_at(below) or room.is_one_way_at(below)))):
		queue_free()
		return
	global_position = next
	var p := get_tree().get_first_node_in_group("player") as Player
	if p != null and not p.dead and hit_rect().intersects(p.body_rect()):
		p.receive_attack(DAMAGE, self, false)
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	# A low crest of rubble and dust, flickering as it travels.
	var fade := 1.0 - _t / LIFETIME
	for i in 4:
		var x := -direction * i * 3.5
		var h := (10.0 - i * 2.2) * (0.85 + 0.15 * sin(_t * 40.0 + i))
		draw_rect(Rect2(x - 1.5, -h, 3.0, h), Color(EDGE, 0.85 * fade))
		draw_rect(Rect2(x - 1.0, -h + 1.0, 2.0, h * 0.5), Color(CORE, 0.9 * fade))
