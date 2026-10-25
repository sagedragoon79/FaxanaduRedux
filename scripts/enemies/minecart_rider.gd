class_name MinecartRider
extends Enemy
## A Forepaw dwarf hunched in an ore cart (design bible 7, Tower of Trunk).
## Trundles along the floor; with you level with him and in front, he hauls
## the brake and the wheels shriek (the telegraph), then lets go and charges
## the length of the floor. Jump him. The cart stops dead at a wall or the end
## of the floor and tips forward, and the dazed rider is open to every blow.
## Otherwise the iron tub turns most hits, except blows from above.

const ROLL_SPEED := 30.0
const CHARGE_SPEED := 230.0
const CHARGE_ACCEL := 900.0
const SIGHT := Vector2(170, 30)
const REV := 0.6
## A charge that finds no wall still ends after this long.
const CHARGE_MAX := 2.2
const CRASH := 1.1
const RECOVER := 0.35
const ROLL_CONTACT := 10
const CHARGE_CONTACT := 22
## How much of a blow the tub lets through, outside the crash.
const ARMOR := 0.4
const SHEET := "minecart_rider"
## His cart is heard within this distance of the player.
const HEAR := 300.0

## Counts down to the next rail clack (roll), brake shriek (rev) or wheel spark (charge).
var _rev_sfx := 0.0


func _init() -> void:
	max_hp = 56
	gold_min = 8
	gold_max = 14
	poison_drops = true
	xp = 20
	contact_damage = ROLL_CONTACT
	body_size = Vector2(30, 22)
	knockback = 10.0


## True while the cart is tipped and the rider dazed: blows land in full.
func exposed() -> bool:
	return state == "crash" or is_staggered()


func _modify_damage(damage: int, dir: Vector2) -> int:
	if exposed() or dir.y > 0.0:
		return damage
	return maxi(1, roundi(damage * ARMOR))


func _think(delta: float) -> void:
	var off := player_offset()
	var seen := off.x != INF and absf(off.x) < SIGHT.x and absf(off.y) < SIGHT.y
	contact_damage = CHARGE_CONTACT if state == "charge" else ROLL_CONTACT
	match state:
		"idle", "roll":
			if state == "idle":
				set_state("roll")
			if seen and is_on_floor():
				face_player()
				velocity.x = 0.0
				set_state("rev")
				_sound("brake", -6.0)
				_rev_sfx = 0.2
				return
			if is_on_floor() and (_wall_ahead() or not _floor_ahead()):
				facing = -facing
			velocity.x = facing * ROLL_SPEED
			_rev_sfx -= delta
			if _rev_sfx <= 0.0:
				_rev_sfx = 0.5
				_sound("cart", -12.0)
		"rev":
			velocity.x = 0.0
			_rev_sfx -= delta
			if _rev_sfx <= 0.0:
				_rev_sfx = 0.2
				_sound("brake", -6.0)
			if state_time >= REV:
				Sfx.play("dash", 0.05, -2.0)
				_rev_sfx = 0.0
				set_state("charge")
		"charge":
			velocity.x = move_toward(velocity.x, facing * CHARGE_SPEED, CHARGE_ACCEL * delta)
			_rev_sfx -= delta
			if absf(velocity.x) > 60.0 and _rev_sfx <= 0.0:
				_rev_sfx = 0.12
				_spark()
				_sound("cart", -4.0)
			if is_on_floor() and (_wall_ahead() or not _floor_ahead()):
				velocity.x = 0.0
				_crash()
			elif state_time >= CHARGE_MAX:
				velocity.x = 0.0
				set_state("recover")
		"crash":
			velocity.x = 0.0
			if state_time >= CRASH:
				set_state("recover")
		"recover":
			velocity.x = move_toward(velocity.x, 0.0, 600.0 * delta)
			if state_time >= RECOVER:
				facing = -facing
				set_state("roll")
		_:
			set_state("roll")


## Plays `sound` if the player is near, quieter with distance.
func _sound(sound: String, volume_db: float) -> void:
	var p := player()
	if p == null:
		return
	var d := p.global_position.distance_to(global_position)
	if d < HEAR:
		Sfx.play(sound, 0.08, volume_db - 14.0 * d / HEAR)


func _crash() -> void:
	set_state("crash")
	Feel.add_trauma(0.25)
	Sfx.play("heavy", 0.05, 2.0)
	var d := Dust.new()
	d.setup("land")
	get_parent().add_child(d)
	d.global_position = global_position + Vector2(facing * body_size.x * 0.5, 0)


func _spark() -> void:
	var d := Dust.new()
	d.setup("hit")
	get_parent().add_child(d)
	d.global_position = global_position + Vector2(-facing * body_size.x * 0.4, -2)


func _wall_ahead() -> bool:
	return test_move(global_transform, Vector2(facing * 4, 0))


func _floor_ahead() -> bool:
	var t := global_transform.translated(Vector2(facing * (body_size.x * 0.5 + 2), 0))
	return test_move(t, Vector2(0, 6))


func _draw() -> void:
	var white := flashing() or (state == "rev" and telegraph_pulse())
	var anim := "roll"
	var t := state_time
	if is_staggered():
		anim = "stagger"
	elif state in ["rev", "charge", "crash"]:
		anim = state
	elif absf(velocity.x) < 1.0:
		t = 0.0
	draw_sheet(SHEET, anim, t, white)
