class_name StormHarpy
extends Enemy
## A Storm Harpy of Daybreak (design bible 7): a winged hunter of the Spires,
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
## Design units per half-pixel (2.0: one unit is one world pixel).
const SCALE := 2.0

const OUTLINE := Color("13101f")
const WING_DARK := Color("2e2a4a")
const WING := Color("4e4a78")
const WING_LIGHT := Color("8a84b8")
const SKIN := Color("d9c2b0")
const HAIR := Color("c8c4dc")
const TALON := Color("e8c04a")
const EYE := Color("ffe070")

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


func _draw() -> void:
	var t := Time.get_ticks_msec() * 0.001
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1))
	var flap := 0.0
	match state:
		"windup":
			flap = -0.55
		"throw":
			flap = 0.6
		"recover":
			flap = 0.35 + sin(t * 18.0) * 0.15
		_:
			flap = sin(t * 9.0) * 0.45
	# The far wing, behind her.
	_wing(-1, flap - 0.15, WING_DARK)
	# Legs and talons.
	_px(-3, 6, 3, 6, OUTLINE)
	_px(2, 6, 3, 6, OUTLINE)
	_px(-2, 7, 1, 4, WING_DARK)
	_px(3, 7, 1, 4, WING_DARK)
	_px(-4, 11, 4, 2, TALON)
	_px(2, 11, 4, 2, TALON)
	# A feathered body.
	_px(-6, -6, 12, 14, OUTLINE)
	_px(-5, -5, 10, 12, WING)
	_px(-4, -4, 4, 9, WING_LIGHT)
	_px(-5, 5, 10, 2, WING_DARK)
	# Head: pale face, wild storm-white hair streaming back, gold eyes.
	_px(-1, -15, 9, 10, OUTLINE)
	_px(0, -14, 7, 8, SKIN)
	_px(-5, -16, 9, 5, OUTLINE)
	_px(-4, -15, 7, 3, HAIR)
	_px(-7, -13, 5, 6, HAIR)
	_px(-8, -10, 3, 3, HAIR)
	_px(4, -12, 2, 1, EYE if state != "recover" else OUTLINE)
	_px(6, -9, 1, 1, OUTLINE)
	# The near wing, in front.
	_wing(1, flap, WING)
	if flashing() or (state == "windup" and telegraph_pulse()):
		_px(-16, -22, 32, 36, Color(1, 1, 1), 0.55)
	draw_set_transform(Vector2.ZERO)


## The scalloped outline of a wing, from the shoulder (0, 0), swept up and back.
const WING_SHAPE := [Vector2(0, 0), Vector2(-4, -10), Vector2(-12, -19), Vector2(-21, -22), Vector2(-27, -18),
	Vector2(-23, -15), Vector2(-28, -10), Vector2(-23, -8), Vector2(-27, -3), Vector2(-20, -2), Vector2(-22, 3),
	Vector2(-12, 2), Vector2(-6, 4)]


## A wing from the shoulder, turned by `angle` (negative raises it). `layer` -1
## is the far wing, drawn behind and darker.
func _wing(layer: int, angle: float, col: Color) -> void:
	var shoulder := Vector2(-2, -4) if layer > 0 else Vector2(1, -6)
	var fill := PackedVector2Array()
	var edge := PackedVector2Array()
	for v: Vector2 in WING_SHAPE:
		fill.append(shoulder + v.rotated(angle))
		edge.append(shoulder + (v * 1.12 + Vector2(1, 0)).rotated(angle))
	draw_colored_polygon(edge, OUTLINE)
	draw_colored_polygon(fill, col)
	# The leading edge catches the light; the flight feathers darken.
	var lead := PackedVector2Array()
	for k in 5:
		lead.append(shoulder + WING_SHAPE[k].rotated(angle))
	draw_polyline(lead, WING_LIGHT if layer > 0 else col.lightened(0.15), 1.0)
	for k in [6, 8, 10]:
		var a: Vector2 = shoulder + (WING_SHAPE[k] * 0.55).rotated(angle)
		var b: Vector2 = shoulder + WING_SHAPE[k].rotated(angle)
		draw_line(a, b, col.darkened(0.3), 1.0)


## Draws a rect of the design (in units of 1/SCALE half-pixels), snapped to
## the half-pixel grid so neighbouring rects still tile.
func _px(x: int, y: int, w: int, h: int, color: Color, alpha := 1.0) -> void:
	var x0 := floorf(x * SCALE)
	var y0 := floorf(y * SCALE)
	var x1 := maxf(floorf((x + w) * SCALE), x0 + 1.0)
	var y1 := maxf(floorf((y + h) * SCALE), y0 + 1.0)
	draw_rect(Rect2(x0 * 0.5, y0 * 0.5, (x1 - x0) * 0.5, (y1 - y0) * 0.5), Color(color, color.a * alpha))
