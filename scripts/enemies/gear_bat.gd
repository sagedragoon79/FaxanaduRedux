class_name GearBat
extends Enemy
## A Hollin Tower clockwork bat. It roosts upside down until you pass near,
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
	poison_drops = true
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
	_died_at = Time.get_ticks_msec() * 0.001
	if is_instance_valid(blade):
		blade.drop()
	blade = null
	super.die()


## Where the gear sits on the brass axle under its body in each animation (world px from
## its middle, facing right): the art draws the axle bare, the code the gear it throws.
const GEAR_AT := {"fly": Vector2(-4, 6), "windup": Vector2(-3, 5), "roost": Vector2(-2, -5)}
## The gear it carries is drawn a little smaller than the thrown one, so the bat stays the shape.
const GEAR_WORN := 0.85

var _died_at := -1.0


func _process(_delta: float) -> void:
	# The dissolve runs after death, when the body no longer redraws itself: keep
	# the collapse playing under it.
	if dead and dissolving():
		queue_redraw()


## The animation and its time for what it is doing now (docs/art/enemy-style-guide.md 4).
func anim_now() -> Array:
	if dead:
		return ["death", Time.get_ticks_msec() * 0.001 - _died_at]
	if is_staggered():
		return ["stagger", state_time]
	if _hitstun > 0.0:
		return ["hurt", 0.0]
	if state == "roost":
		return ["roost", Time.get_ticks_msec() * 0.001]
	if state == "windup":
		return ["windup", state_time]
	return ["fly" if has_gear() else "bare", Time.get_ticks_msec() * 0.001]


func _draw() -> void:
	var white := flashing() or (state == "windup" and telegraph_pulse())
	var now := anim_now()
	var anim: String = now[0]
	var jitter := Vector2(randf_range(-1, 1), 0).round() if anim == "windup" else Vector2.ZERO
	draw_sheet(SHEET, anim, now[1], white, jitter)
	# The gear rides on its axle until it is thrown; in the tell it whirs up.
	if has_gear() and GEAR_AT.has(anim):
		var at: Vector2 = (GEAR_AT[anim] + jitter) * Vector2(facing, 1)
		var spin := Time.get_ticks_msec() * 0.001 * (30.0 if anim == "windup" else 3.0)
		GearBlade.draw_gear(self, at, spin, GEAR_WORN)
		if white:
			draw_circle(at, (GearBlade.RADIUS + 0.5) * GEAR_WORN, Color(1, 1, 1, 0.85))
