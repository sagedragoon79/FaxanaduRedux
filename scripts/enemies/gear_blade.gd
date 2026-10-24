class_name GearBlade
extends Node2D
## The gear a Gear Bat flings. It spins out, slows to a stop and flies back to the
## bat, cutting anything in its way; a wall turns it back early. Parried, it is
## knocked home so hard that it staggers the bat that threw it.

const OUT_SPEED := 300.0
const OUT_TIME := 0.6
const RETURN_ACCEL := 700.0
const RETURN_SPEED := 240.0
const REFLECT_SPEED := 380.0
const RADIUS := 5.0
const DAMAGE := 14
const REFLECT_DAMAGE := 16
const LIFETIME := 4.0
const GOLD := Color("edce6e")
const GOLD_LIGHT := Color("f0dfa8")
const GOLD_DARK := Color("cb8d16")
const HUB := Color("8d4e16")
const OUTLINE := Color("120f19")

var owner_bat: GearBat
var room: Room
var direction := Vector2.RIGHT
var velocity := Vector2.ZERO
## "out", "back" (homing on the bat), "reflected" or "fall" (its bat is gone).
var phase := "out"
var _t := 0.0
var _spin := 0.0
var _hit := false


func _ready() -> void:
	z_index = 1
	velocity = direction * OUT_SPEED


func hit_rect() -> Rect2:
	return Rect2(global_position - Vector2(RADIUS, RADIUS), Vector2(RADIUS, RADIUS) * 2.0)


func _physics_process(delta: float) -> void:
	if TimeStop.active():
		return  # held still by the Hour Glass
	_t += delta
	_spin += delta * (30.0 if phase != "fall" else 6.0)
	var bat_ok := is_instance_valid(owner_bat) and not owner_bat.dead
	if not bat_ok and phase != "fall":
		drop()
	match phase:
		"out":
			velocity = direction * OUT_SPEED * maxf(0.0, 1.0 - _t / OUT_TIME)
			if _t >= OUT_TIME:
				phase = "back"
		"back":
			var to := owner_bat.center() - global_position
			velocity = velocity.move_toward(to.normalized() * RETURN_SPEED, RETURN_ACCEL * delta)
			if to.length() < 8.0:
				owner_bat.catch_blade()
				queue_free()
				return
		"reflected":
			var to := owner_bat.center() - global_position
			velocity = to.normalized() * REFLECT_SPEED
			if to.length() < 10.0:
				owner_bat.take_hit(REFLECT_DAMAGE, to.normalized())
				owner_bat.stagger()
				owner_bat.catch_blade()
				queue_free()
				return
		"fall":
			velocity.y += 900.0 * delta
	var next := global_position + velocity * delta
	if room != null and room.is_solid_at(next):
		if phase == "out":
			# Rings off the wall and turns for home.
			_spark()
			phase = "back"
			velocity = -velocity * 0.3
			next = global_position
		elif phase == "fall":
			_spark()
			queue_free()
			return
	global_position = next
	if phase in ["out", "back"] and not _hit:
		var p := get_tree().get_first_node_in_group("player") as Player
		if p != null and not p.dead and hit_rect().intersects(p.body_rect()):
			var res := p.receive_attack(DAMAGE, self, true)
			if res != "parried":
				_hit = true
	if _t > LIFETIME:
		if bat_ok:
			owner_bat.catch_blade()
		queue_free()
		return
	queue_redraw()


## Called by the player on a parry: the gear is knocked back at its bat.
func stagger() -> void:
	if phase == "fall":
		return
	phase = "reflected"
	_hit = true
	_spark()


## Its bat is gone: the gear drops, harmless, and breaks on the floor.
func drop() -> void:
	phase = "fall"
	_hit = true
	velocity = Vector2(velocity.x * 0.3, -60.0)


func _spark() -> void:
	var d := Dust.new()
	d.setup("guard")
	get_parent().add_child(d)
	d.global_position = global_position
	Sfx.play("guard", 0.15, -8.0)


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, _spin)
	var r := RADIUS - 0.5
	for i in 8:
		var a := i * TAU / 8.0
		var u := Vector2(cos(a), sin(a))
		var v := Vector2(-u.y, u.x)
		var tooth := PackedVector2Array([u * (r - 1.5) - v * 1.3, u * (r + 1.3) - v * 1.0, u * (r + 1.3) + v * 1.0, u * (r - 1.5) + v * 1.3])
		draw_colored_polygon(tooth, OUTLINE)
	draw_circle(Vector2.ZERO, r, OUTLINE)
	for i in 8:
		var a := i * TAU / 8.0
		var u := Vector2(cos(a), sin(a))
		var v := Vector2(-u.y, u.x)
		var tooth := PackedVector2Array([u * (r - 1.5) - v * 0.8, u * (r + 0.8) - v * 0.5, u * (r + 0.8) + v * 0.5, u * (r - 1.5) + v * 0.8])
		draw_colored_polygon(tooth, GOLD_DARK)
	draw_circle(Vector2.ZERO, r - 0.5, GOLD)
	draw_circle(Vector2(-1.2, -1.2), r - 2.5, GOLD_LIGHT)
	draw_circle(Vector2.ZERO, 1.5, HUB)
	draw_set_transform(Vector2.ZERO)
	if phase in ["out", "reflected"]:
		# A faint motion smear behind it.
		var back := -velocity.normalized() * 6.0
		draw_line(back, back * 2.0, Color(GOLD, 0.35), 3.0)
