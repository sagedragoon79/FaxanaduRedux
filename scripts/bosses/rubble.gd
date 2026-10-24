class_name Rubble
extends Node2D
## A rock in the Foreman's fight. "thrown": a boulder he lobs in an arc.
## "fall": shaken loose from the ceiling. A falling rock first marks its spot
## with trickling dust and a shadow on the floor (TELL seconds), then drops.
## Either breaks on whatever it hits.

const GRAVITY := 700.0
const FALL_SPEED := 420.0
const TELL := 0.7
const RADIUS := 7.0
const DAMAGE := 16
const LIFETIME := 4.0
const ROCK := Color("aa6336")
const ROCK_LIGHT := Color("cd8c51")
const ROCK_DARK := Color("783c2b")
const OUTLINE := Color("120f19")

var mode := "thrown"
var velocity := Vector2.ZERO
var room: Room
## For a falling rock: the floor height its shadow is drawn on.
var floor_y := 0.0
var _t := 0.0
var _spin := 0.0


## The launch velocity that carries a boulder from `from` to `to` in `flight` seconds.
static func launch(from: Vector2, to: Vector2, flight: float) -> Vector2:
	var d := to - from
	return Vector2(d.x / flight, d.y / flight - 0.5 * GRAVITY * flight)


func _ready() -> void:
	z_index = 1


func falling() -> bool:
	return mode == "fall" and _t >= TELL


func hit_rect() -> Rect2:
	return Rect2(global_position - Vector2(RADIUS, RADIUS), Vector2(RADIUS, RADIUS) * 2.0)


func _physics_process(delta: float) -> void:
	if TimeStop.active():
		return  # held still by the Hour Glass
	_t += delta
	_spin += delta * 6.0
	if mode == "fall":
		if _t < TELL:
			queue_redraw()
			return
		velocity = Vector2(0, FALL_SPEED)
	else:
		velocity.y += GRAVITY * delta
	var next := global_position + velocity * delta
	var p := get_tree().get_first_node_in_group("player") as Player
	if p != null and not p.dead and Rect2(next - Vector2(RADIUS, RADIUS), Vector2(RADIUS, RADIUS) * 2.0).intersects(p.body_rect()):
		p.receive_attack(DAMAGE, self, false)
		_break(next)
		return
	# Falling rocks start inside the ceiling, so only the floor stops them.
	var blocked := room != null and room.is_solid_at(next)
	if mode == "fall":
		blocked = blocked and next.y >= floor_y - 4.0
	if blocked or _t > LIFETIME:
		_break(next)
		return
	global_position = next
	queue_redraw()


func _break(at: Vector2) -> void:
	var d := Dust.new()
	d.setup("debris")
	get_parent().add_child(d)
	d.global_position = at
	Sfx.play("crumble", 0.15, -6.0)
	queue_free()


func _draw() -> void:
	if mode == "fall" and _t < TELL:
		# The tell: a shadow growing on the floor below, and grit trickling down.
		var k := _t / TELL
		var shadow := Vector2(0, floor_y - global_position.y)
		draw_set_transform(shadow, 0.0, Vector2(1.0, 0.3))
		draw_circle(Vector2.ZERO, RADIUS * (0.6 + 0.8 * k), Color(0, 0, 0, 0.25 + 0.3 * k))
		draw_set_transform(Vector2.ZERO)
		for i in 3:
			var y := fmod(_t * 160.0 + i * 37.0, maxf(shadow.y, 1.0))
			draw_rect(Rect2(Vector2(-3 + i * 3, y), Vector2(1, 2)), Color(ROCK_LIGHT, 0.8))
		return
	draw_set_transform(Vector2.ZERO, _spin)
	var pts := PackedVector2Array()
	for i in 7:
		var a := i * TAU / 7.0
		pts.append(Vector2(cos(a), sin(a)) * (RADIUS + 1.0) * (0.85 + 0.15 * sin(i * 2.3)))
	draw_colored_polygon(pts, OUTLINE)
	var inner := PackedVector2Array()
	for v in pts:
		inner.append(v * 0.82)
	draw_colored_polygon(inner, ROCK)
	draw_circle(Vector2(-2, -2), RADIUS * 0.35, ROCK_LIGHT)
	draw_circle(Vector2(2, 2.5), RADIUS * 0.3, ROCK_DARK)
	draw_set_transform(Vector2.ZERO)
