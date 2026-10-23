class_name GearBat
extends Enemy
## A Tower of Trunk clockwork bat. It roosts upside down until you pass near,
## then hangs off to one side of you, winds the gear on its back up to a whir
## (telegraph) and flings it. The gear flies out, slows, and comes back to the
## bat; parry it and it flies home hard enough to stagger its owner.

const SHEET := "gear_bat"
const WAKE_RANGE := Vector2(120, 170)
const WAKE := 0.4
const HOVER_OFFSET := Vector2(72, -36)
const HOVER_SPEED := 4.0
const LEASH := 200.0
const HOVER_TIME := 0.9
const WINDUP := 0.5
const COOLDOWN := 1.1

var blade: GearBlade
var _cooldown := 0.0
var _side := 1


func _init() -> void:
	max_hp = 22
	contact_damage = 12
	gold_min = 4
	gold_max = 7
	xp = 9
	body_size = Vector2(18, 12)
	body_centered = true
	uses_gravity = false
	knockback = 160.0
	state = "roost"


func has_gear() -> bool:
	return blade == null


func _think(delta: float) -> void:
	_cooldown -= delta
	var off := player_offset()
	match state:
		"roost":
			velocity = Vector2.ZERO
			if (absf(off.x) < WAKE_RANGE.x and absf(off.y) < WAKE_RANGE.y) or hits_taken > 0:
				face_player()
				set_state("wake")
				Sfx.play("whir", 0.05, -12.0)
		"wake":
			# Drops off the roost with a flap.
			velocity = Vector2(0, 60.0 * (1.0 - state_time / WAKE))
			if state_time >= WAKE:
				set_state("hover")
		"hover", "bare":
			_hover(off, delta)
			if state == "hover" and has_gear() and _cooldown <= 0.0 and state_time >= HOVER_TIME and off.x != INF:
				velocity = Vector2.ZERO
				set_state("windup")
				Sfx.play("whir", 0.05, -4.0)
			elif state == "bare" and has_gear():
				_cooldown = COOLDOWN
				set_state("hover")
		"windup":
			velocity = velocity.move_toward(Vector2.ZERO, 400.0 * delta)
			face_player()
			if state_time >= WINDUP:
				_throw()
		_:
			set_state("hover" if has_gear() else "bare")


## Holds station beside and above the player, on whichever side it is already on,
## without straying far from its roost.
func _hover(off: Vector2, _delta: float) -> void:
	face_player()
	if off.x == INF:
		velocity = (home - global_position) * 2.0
		return
	if absf(off.x) > 20.0:
		_side = -int(signf(off.x))
	var target := center() + off + Vector2(_side * HOVER_OFFSET.x, HOVER_OFFSET.y)
	target += Vector2(0, sin(Time.get_ticks_msec() * 0.006) * 5.0)
	var to_home := target - home
	if to_home.length() > LEASH:
		target = home + to_home.normalized() * LEASH
	velocity = (target - global_position) * HOVER_SPEED
	velocity = velocity.limit_length(140.0 if state == "hover" else 90.0)


func _throw() -> void:
	blade = GearBlade.new()
	blade.owner_bat = self
	var off := player_offset()
	blade.direction = off.normalized() if off.x != INF else Vector2(facing, 0)
	blade.room = get_parent() as Room
	get_parent().add_child(blade)
	blade.global_position = center() + Vector2(-facing * 2.0, -7.0)
	Sfx.play("slash", 0.1, -2.0)
	set_state("bare")


## The gear is back on its axle.
func catch_blade() -> void:
	blade = null


func die() -> void:
	if is_instance_valid(blade):
		blade.drop()
	blade = null
	super.die()


func _draw() -> void:
	var white := flashing() or (state == "windup" and telegraph_pulse())
	var t := Time.get_ticks_msec() * 0.001
	var anim := "fly"
	var jitter := Vector2.ZERO
	if is_staggered():
		anim = "stagger"
	elif state == "roost":
		anim = "roost"
	elif state == "windup":
		anim = "windup"
		t = state_time
		jitter = Vector2(randf_range(-1, 1), 0).round()
	elif not has_gear():
		anim = "bare"
	draw_sheet(SHEET, anim, t, white, jitter)
