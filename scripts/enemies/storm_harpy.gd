class_name StormHarpy
extends Enemy
## A Storm Harpy of Carillon (design bible 7): a winged hunter of the Spires,
## storm-grey and violet with gold talons. She keeps above you and to one side,
## out of reach of a plain slash. Her tell: she rears back and spreads her
## wings wide with a screech, then flings a fan of three feathers at you. A
## parried feather flies back at her. After a volley she sags lower for a
## moment, winded, in reach of a jump. Legend `y`.

## How far she spots you from (px).
const SIGHT := 260.0
## Where she likes to hang: this far beside you and above you.
const PERCH := Vector2(72, -84)
const FLY_SPEED := 110.0
const WINDUP := 0.55
const THROW := 0.2
const RECOVER := 0.8
const COOLDOWN := 1.4
const FEATHER_SPEED := 200.0
## Spread of the fan, either side of the aim (radians).
const FAN := 0.26
## How far she sags while winded.
const SAG := 34.0
const TOUCH_DAMAGE := 12

var _cool := 0.6
var _side := 1


func _init() -> void:
	max_hp = 30
	gold_min = 6
	gold_max = 12
	xp = 16
	body_size = Vector2(18, 20)
	body_centered = true
	uses_gravity = false
	knockback = 120.0
	contact_damage = TOUCH_DAMAGE
	state = "hover"


func _think(delta: float) -> void:
	_cool -= delta
	var off := player_offset()
	var sees := off.x != INF and off.length() < SIGHT
	match state:
		"hover":
			face_player()
			var goal := home
			if sees:
				# Keep her own side of you, unless you have passed under her.
				if absf(off.x) > 24.0:
					_side = -int(signf(off.x))
				goal = center() + off + Vector2(PERCH.x * _side, PERCH.y)
			var t := Time.get_ticks_msec() * 0.001
			goal += Vector2(0, sin(t * 3.0) * 4.0)
			velocity = ((goal - center()) * 2.5).limit_length(FLY_SPEED)
			if sees and _cool <= 0.0:
				velocity = Vector2.ZERO
				set_state("windup")
				Sfx.play("screech", 0.08, -4.0)
		"windup":
			velocity = Vector2.ZERO
			face_player()
			if state_time >= WINDUP:
				_volley()
				set_state("throw")
		"throw":
			velocity = Vector2.ZERO
			if state_time >= THROW:
				set_state("recover")
		"recover":
			# Winded: she sags lower, in reach.
			velocity = Vector2(0, SAG / RECOVER * 1.6 if state_time < RECOVER * 0.6 else 0.0)
			if state_time >= RECOVER:
				_cool = COOLDOWN
				set_state("hover")
		_:
			set_state("hover")


## Three feathers in a fan at where you are now.
func _volley() -> void:
	var off := player_offset()
	var aim := off.normalized() if off.x != INF else Vector2(facing, 0.5).normalized()
	for k in [-1, 0, 1]:
		var f := HarpyFeather.new()
		f.thrower = self
		f.velocity = aim.rotated(k * FAN) * FEATHER_SPEED
		get_parent().add_child(f)
		f.global_position = center() + aim * 10.0
	Sfx.play("feather", 0.08)


## The sheet's animation for each state (docs/art/enemy-style-guide.md 4).
const ANIMS := {"hover": "hover", "windup": "windup", "throw": "throw", "recover": "recover"}

var _died_at := -1.0


func die() -> void:
	_died_at = Time.get_ticks_msec() * 0.001
	super.die()


func _process(_delta: float) -> void:
	# The dissolve runs after death, when the body no longer redraws itself: keep
	# the collapse playing under it.
	if dead and dissolving():
		queue_redraw()


## The animation and its time for what she is doing now.
func anim_now() -> Array:
	if dead:
		return ["death", Time.get_ticks_msec() * 0.001 - _died_at]
	if _hitstun > 0.0:
		return ["hurt", HITSTUN - _hitstun]
	if is_staggered():
		return ["recover", state_time]
	var a: String = ANIMS.get(state, "hover")
	return [a, state_time if a != "hover" else Time.get_ticks_msec() * 0.001]


func _draw() -> void:
	var now := anim_now()
	draw_sheet("storm_harpy", now[0], now[1], flashing() or (state == "windup" and telegraph_pulse()))
