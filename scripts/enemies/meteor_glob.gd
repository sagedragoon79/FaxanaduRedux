class_name MeteorGlob
extends Node2D
## A gobbet of molten meteor-rock lobbed by a Meteor Slug. It flies in an arc,
## burns the player on contact (unparryable), and where it lands on a floor it
## leaves a patch of embers for a moment. The Hour Glass holds it in the air.

const GRAVITY := 700.0
const RADIUS := 4.5
const DAMAGE := 12
const LIFETIME := 3.0
const HOT := Color("ff7a2a")
const CORE := Color("ffe08a")
const CRUST := Color("4a2a3a")
const OUTLINE := Color("120f19")

var velocity := Vector2.ZERO
var room: Room
var _t := 0.0


## The launch velocity that carries a glob from `from` to `to` in `flight` seconds.
static func launch(from: Vector2, to: Vector2, flight: float) -> Vector2:
	var d := to - from
	return Vector2(d.x / flight, d.y / flight - 0.5 * GRAVITY * flight)


func _ready() -> void:
	z_index = 2
	add_to_group("enemy_projectile")


func _physics_process(delta: float) -> void:
	if TimeStop.active():
		return  # held still by the Hour Glass
	_t += delta
	velocity.y += GRAVITY * delta
	var next := global_position + velocity * delta
	var p := get_tree().get_first_node_in_group("player") as Player
	if p != null and not p.dead and Rect2(next - Vector2(RADIUS, RADIUS), Vector2(RADIUS, RADIUS) * 2.0).intersects(p.body_rect()):
		p.receive_attack(DAMAGE, self, false)
		_burst(next, false)
		return
	if room != null and room.is_solid_at(next):
		_burst(next, velocity.y > 0.0)
		return
	global_position = next
	if _t > LIFETIME:
		queue_free()
	queue_redraw()


## Bursts in sparks; landing on a floor it leaves embers on the tile above.
func _burst(at: Vector2, on_floor: bool) -> void:
	if on_floor and room != null:
		var cell := room.cell_at(at)
		var e := MeteorEmbers.new()
		get_parent().add_child(e)
		e.global_position = Vector2(at.x, cell.y * Room.TILE)
	var d := Dust.new()
	d.setup("hit")
	get_parent().add_child(d)
	d.global_position = at
	Sfx.play("fire_burst", 0.15, -10.0)
	queue_free()


func _draw() -> void:
	var stretch := clampf(velocity.length() / 400.0, 0.0, 0.4) if not TimeStop.active() else 0.0
	draw_set_transform(Vector2.ZERO, velocity.angle(), Vector2(1.0 + stretch, 1.0 - stretch * 0.5))
	draw_circle(Vector2.ZERO, RADIUS + 1.0, OUTLINE)
	draw_circle(Vector2.ZERO, RADIUS, CRUST)
	draw_circle(Vector2(0.5, 0.5), RADIUS - 1.5, HOT)
	draw_circle(Vector2(1.0, 0.0), 1.5, CORE)
	draw_set_transform(Vector2.ZERO)
