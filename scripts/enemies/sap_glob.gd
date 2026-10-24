class_name SapGlob
extends Node2D
## A glob of sap lobbed by a Sap Spitter. It flies in an arc, hurts the player
## on contact, and splashes on whatever it hits, leaving a puddle on a floor.

const GRAVITY := 700.0
const RADIUS := 5.0
const DAMAGE := 12
const PUDDLE_TIME := 4.0
const LIFETIME := 3.0
const SAP := Color("e0902a")
const SAP_LIGHT := Color("ffc76a")
const OUTLINE := Color("120f19")

var velocity := Vector2.ZERO
var room: Room
var _t := 0.0


## The launch velocity that carries a glob from `from` to `to` in `flight` seconds.
static func launch(from: Vector2, to: Vector2, flight: float) -> Vector2:
	var d := to - from
	return Vector2(d.x / flight, d.y / flight - 0.5 * GRAVITY * flight)


func _ready() -> void:
	z_index = 1


func _physics_process(delta: float) -> void:
	if TimeStop.active():
		return  # held still by the Hour Glass
	_t += delta
	velocity.y += GRAVITY * delta
	var next := global_position + velocity * delta
	var p := get_tree().get_first_node_in_group("player") as Player
	if p != null and not p.dead and Rect2(next - Vector2(RADIUS, RADIUS), Vector2(RADIUS, RADIUS) * 2.0).intersects(p.body_rect()):
		p.receive_attack(DAMAGE, self, false)
		_splash(next)
		return
	if room != null and room.is_solid_at(next):
		_splash(next)
		return
	global_position = next
	if _t > LIFETIME:
		queue_free()
	queue_redraw()


## Bursts; on a floor (falling onto it) it leaves a puddle in the tile above.
func _splash(at: Vector2) -> void:
	if room != null and velocity.y > 0.0:
		var cell := room.cell_at(at)
		room.splash_sap(Vector2(cell.x * Room.TILE + 8, (cell.y - 1) * Room.TILE + 8), PUDDLE_TIME)
	var d := Dust.new()
	d.setup("land")
	get_parent().add_child(d)
	d.global_position = at
	Sfx.play("splat", 0.1, -6.0)
	queue_free()


func _draw() -> void:
	var stretch := clampf(velocity.length() / 400.0, 0.0, 0.5)
	draw_set_transform(Vector2.ZERO, velocity.angle(), Vector2(1.0 + stretch, 1.0 - stretch * 0.5))
	draw_circle(Vector2.ZERO, RADIUS + 1.0, OUTLINE)
	draw_circle(Vector2.ZERO, RADIUS, SAP)
	draw_circle(Vector2(-1.5, -1.5), 1.6, SAP_LIGHT)
	draw_set_transform(Vector2.ZERO)
