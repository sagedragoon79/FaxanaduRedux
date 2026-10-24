class_name ClockworkHound
extends Enemy
## A Clockwork Hound of Dartmoor (design bible 7): one of King Grieve's brass
## hunting dogs, still running on the spring the king last wound. It trots after
## you. Near enough, it crouches and its key spins up, ratcheting, its eyes
## blazing (the telegraph), then it pounces in a long low arc and bites.
## Parry the bite and it tumbles onto its back, belly plates open, every blow
## landing. Otherwise its brass plating turns half of every blow. It is a thing
## of clockwork, so the Hour Glass stops it dead where it stands, mid-leap or
## not. Legend `j`.

const TROT := 62.0
const SIGHT := Vector2(170, 56)
## It pounces when you are this near (px, centre to centre).
const REACH := 120.0
const WIND := 0.45
## Its leap: the rise, and the most it covers across (px/s); it aims to land on you.
const POUNCE := Vector2(320, -230)
const BITE_DAMAGE := 14
const SKID := 0.5
const COOLDOWN := 1.1
## A parried bite throws it on its back this long.
const FLIPPED := 1.3
## The share of a blow its plating lets through, except on its back.
const PLATING := 0.5
## The drawing is laid out small and drawn this much larger.
const SCALE := 2.0

const OUTLINE := Color("1a120c")
const BRASS := Color("c8913a")
const BRASS_LIGHT := Color("f0c870")
const BRASS_DARK := Color("7a5222")
const STEEL := Color("8a96a0")
const BELLY := Color("5a4a3a")
const GEAR := Color("e0b050")
const EYE := Color("ff5a3a")
const EYE_HOT := Color("ffe0a0")

var _cool := 0.0
var _bitten := false
## The key's turn, for drawing.
var _key := 0.0


func _init() -> void:
	max_hp = 44
	gold_min = 8
	gold_max = 14
	xp = 22
	contact_damage = 10
	body_size = Vector2(24, 16)
	knockback = 60.0
	launchable = false


## On its back after a parry, plating up and belly bare.
func flipped() -> bool:
	return is_staggered()


func stagger() -> void:
	super.stagger()
	_stagger = FLIPPED
	velocity = Vector2(-facing * 60.0, -140.0)
	Sfx.play("guard", 0.1, -4.0)


func _modify_damage(damage: int, _dir: Vector2) -> int:
	if flipped():
		return damage
	return maxi(1, roundi(damage * PLATING))


func _physics_process(delta: float) -> void:
	# Clockwork: stopped time stops it dead, in the air or not.
	if TimeStop.active() and not dead:
		_flash -= delta
		queue_redraw()
		return
	super._physics_process(delta)


func _think(delta: float) -> void:
	_cool -= delta
	var off := player_offset()
	var seen := off.x != INF and absf(off.x) < SIGHT.x and absf(off.y) < SIGHT.y
	_key += delta * (14.0 if state == "wind" else 3.0)
	match state:
		"idle", "trot":
			if state == "idle":
				set_state("trot")
			if seen:
				face_player()
				if absf(off.x) < REACH and _cool <= 0.0 and is_on_floor():
					velocity.x = 0.0
					set_state("wind")
					Sfx.play("ratchet", 0.1, -4.0)
					return
			if _edge_ahead():
				facing = -facing
			velocity.x = facing * (TROT if seen else TROT * 0.5)
		"wind":
			velocity.x = 0.0
			if state_time >= WIND:
				_bitten = false
				var air := 2.0 * -POUNCE.y / GRAVITY
				var off_now := player_offset()
				var across := POUNCE.x if off_now.x == INF else clampf(absf(off_now.x) / air, 100.0, POUNCE.x)
				velocity = Vector2(facing * across, POUNCE.y)
				set_state("pounce")
				Sfx.play("slash", 0.15, -4.0)
		"pounce":
			if not _bitten:
				var res := hit_player_in_rect(bite_rect(), BITE_DAMAGE)
				if res != "":
					_bitten = true
			if state == "pounce" and state_time > 0.1 and is_on_floor():
				set_state("skid")
		"skid":
			velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
			if state_time >= SKID:
				_cool = COOLDOWN
				set_state("trot")
		_:
			set_state("trot")


## Where its jaws close: ahead of the body, at head height.
func bite_rect() -> Rect2:
	var c := center()
	return Rect2(c.x - 6.0 + facing * 10.0, c.y - 10.0, 12.0 + 6.0, 16.0)


func _edge_ahead() -> bool:
	if not is_on_floor():
		return false
	if test_move(global_transform, Vector2(facing * 4, 0)):
		return true
	var t := global_transform.translated(Vector2(facing * (body_size.x * 0.5 + 2), 0))
	return not test_move(t, Vector2(0, 6))


func _draw() -> void:
	var t := Time.get_ticks_msec() * 0.001
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1))
	var stopped := TimeStop.active()
	if flipped():
		_draw_flipped()
	else:
		var crouch := 0
		var stride := 0
		var stretch := 0
		match state:
			"wind":
				crouch = mini(int(state_time / WIND * 3.0) + 1, 3)
			"pounce":
				stretch = 3
			"trot":
				if not stopped:
					stride = roundi(sin(t * 14.0) * 2.0)
		var by := -13 + crouch
		# Legs: four brass struts, scissoring as it trots, flung back as it leaps.
		for leg: Array in [[-8, stride], [-5, -stride], [5, -stride], [8, stride]]:
			var lx: int = leg[0] + (leg[1] if stretch == 0 else (-3 if leg[0] < 0 else 3))
			_px(lx - 1, by + 6, 3, 8 - crouch, OUTLINE, 1.0)
			_px(lx, by + 6, 1, 7 - crouch, STEEL, 1.0)
		# Body: a barrel of riveted brass.
		_px(-11 - stretch, by - 1, 23 + stretch * 2, 10, OUTLINE, 1.0)
		_px(-10 - stretch, by, 21 + stretch * 2, 8, BRASS, 1.0)
		_px(-10 - stretch, by, 21 + stretch * 2, 2, BRASS_LIGHT, 1.0)
		_px(-10 - stretch, by + 6, 21 + stretch * 2, 2, BRASS_DARK, 1.0)
		for rx in [-7, -2, 3, 8]:
			_px(rx, by + 3, 1, 1, BRASS_DARK, 1.0)
		# Tail: a stiff steel spring.
		_px(-14 - stretch, by - 3, 4, 2, OUTLINE, 1.0)
		_px(-13 - stretch, by - 2, 3, 1, STEEL, 1.0)
		# Head: a long brass muzzle with a hinged jaw, ears like cog teeth.
		var hx := 9 + stretch
		var hy := by - 5 + (1 if crouch > 0 else 0)
		var gape := 2 if state == "pounce" else 0
		_px(hx - 1, hy - 1, 12, 8, OUTLINE, 1.0)
		_px(hx, hy, 10, 4, BRASS, 1.0)
		_px(hx, hy, 10, 1, BRASS_LIGHT, 1.0)
		_px(hx + 3, hy + 4 + gape, 7, 2, BRASS_DARK, 1.0)
		if gape > 0:
			for k in 3:
				_px(hx + 4 + k * 2, hy + 4, 1, 1, STEEL, 1.0)
		_px(hx + 1, hy - 3, 2, 3, OUTLINE, 1.0)
		_px(hx + 4, hy - 3, 2, 3, OUTLINE, 1.0)
		var hot := state == "wind" and telegraph_pulse()
		_px(hx + 6, hy + 1, 2, 2, EYE_HOT if hot else EYE, 1.0)
		if state == "wind":
			var k := 0.5 + 0.5 * absf(sin(state_time * 18.0))
			_px(hx + 5, hy, 4, 4, Color(EYE, 0.35 * k), 1.0)
		# The winding key on its back, turning; it spins up before a pounce.
		_draw_key(-3, by - 5)
	if stopped:
		# Stopped: a ring of clock-glyph ticks around it.
		for i in 4:
			var a := TAU * i / 4.0 + 0.4
			_px(roundi(cos(a) * 15.0), -9 + roundi(sin(a) * 9.0), 1, 1, Color(EYE_HOT, 0.8), 1.0)
	if flashing():
		_px(-14, -18, 30, 18, Color(1, 1, 1), 0.55)
	draw_set_transform(Vector2.ZERO)


func _draw_key(x: int, y: int) -> void:
	var turn := int(_key) % 4
	_px(x, y + 1, 2, 3, OUTLINE, 1.0)
	_px(x, y + 2, 1, 2, STEEL, 1.0)
	# The bow of the key, seen turning: wide, narrow, wide, narrow.
	var w := 7 if turn % 2 == 0 else 3
	_px(x + 1 - w / 2 - 1, y - 2, w + 2, 4, OUTLINE, 1.0)
	_px(x + 1 - w / 2, y - 1, w, 2, GEAR, 1.0)


func _draw_flipped() -> void:
	# On its back: belly plates and gear-work bare, legs kicking.
	var t := Time.get_ticks_msec() * 0.001
	var kick := roundi(sin(t * 20.0) * 2.0)
	for lx in [-8, -5, 5, 8]:
		_px(lx - 1, -18 + (kick if lx < 0 else -kick), 3, 7, OUTLINE, 1.0)
		_px(lx, -17 + (kick if lx < 0 else -kick), 1, 6, STEEL, 1.0)
	_px(-11, -11, 23, 10, OUTLINE, 1.0)
	_px(-10, -10, 21, 8, BRASS_DARK, 1.0)
	_px(-8, -11, 17, 3, BELLY, 1.0)
	for gx in [-6, 0, 6]:
		_px(gx - 1, -10, 3, 3, GEAR, 1.0)
		_px(gx, -9, 1, 1, OUTLINE, 1.0)
	_px(9, -8, 10, 5, OUTLINE, 1.0)
	_px(10, -7, 8, 3, BRASS, 1.0)


## Draws a rect of the design (laid out in units of 1/SCALE half-pixels),
## snapped to the half-pixel grid so neighbouring rects still tile.
func _px(x: int, y: int, w: int, h: int, color: Color, alpha: float) -> void:
	var x0 := floorf(x * SCALE)
	var y0 := floorf(y * SCALE)
	var x1 := maxf(floorf((x + w) * SCALE), x0 + 1.0)
	var y1 := maxf(floorf((y + h) * SCALE), y0 + 1.0)
	draw_rect(Rect2(x0 * 0.5, y0 * 0.5, (x1 - x0) * 0.5, (y1 - y0) * 0.5), Color(color, color.a * alpha))
