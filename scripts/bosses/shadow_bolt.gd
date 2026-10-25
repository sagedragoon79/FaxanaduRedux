class_name ShadowBolt
extends Node2D
## A bolt of shadow Shadow Eura casts once it fights on its own with your
## Arcana (design bible 8.8). It flies straight along the hall. Parry it and it
## turns back on the shadow that cast it. The Hour Glass holds it still. The
## origin is the bolt's centre.

const SPEED := 200.0
const DAMAGE := 12
## What a bolt parried back does to the shadow.
const REFLECT_DAMAGE := 12
const SIZE := Vector2(14, 8)
const LIFE := 4.0
const CORE := Color("ffb8f0")
const BODY := Color("9a5ae0")
const DARK := Color("120a1c")

var boss: ShadowEura
var direction := 1
## Turned back by a parry: it hurts the shadow now, not you.
var reflected := false
var bounds := Rect2(16, 64, 928, 256)
var _t := 0.0


func _ready() -> void:
	z_index = 2
	add_to_group("enemy_projectile")


func hit_rect() -> Rect2:
	return Rect2(global_position - SIZE * 0.5, SIZE)


func _physics_process(delta: float) -> void:
	if TimeStop.active():
		return
	_t += delta
	global_position.x += direction * SPEED * delta
	if _t >= LIFE or not bounds.grow(8.0).has_point(global_position):
		_burst()
		return
	if reflected:
		if is_instance_valid(boss) and not boss.dead and hit_rect().intersects(Rect2(boss.center() - boss.body_size * 0.5, boss.body_size)):
			boss.take_hit(REFLECT_DAMAGE, Vector2(direction, 0))
			_burst()
		return
	var p := get_tree().get_first_node_in_group("player") as Player
	if p != null and not p.dead and hit_rect().intersects(p.body_rect()):
		var res := p.receive_attack(DAMAGE, self, true)
		if res == "parried":
			reflected = true
			direction = -direction
			_t = 0.0
		elif res != "ignored":
			_burst()
	queue_redraw()


## A parry turns it (the player calls stagger() on what it parries).
func stagger() -> void:
	pass


func _burst() -> void:
	var d := Dust.new()
	d.setup("hit")
	get_parent().add_child(d)
	d.global_position = global_position
	queue_free()


func _draw() -> void:
	var k := 0.6 + 0.4 * absf(sin(_t * 20.0))
	var hx := SIZE.x * 0.5
	var hy := SIZE.y * 0.5
	# A comet of shadow: a dark head with a violet rim and a pale core, a tail behind.
	for i in 3:
		draw_rect(Rect2(-direction * (hx + 3.0 + i * 4.0) - 2.0, -1.0, 4.0, 2.0), Color(BODY, 0.5 - i * 0.15))
	draw_rect(Rect2(-hx - 1.0, -hy - 1.0, SIZE.x + 2.0, SIZE.y + 2.0), Color(BODY, 0.8))
	draw_rect(Rect2(-hx, -hy, SIZE.x, SIZE.y), DARK)
	draw_rect(Rect2(-2.0, -2.0, 4.0, 4.0), Color(CORE if not reflected else Color.WHITE, k))
