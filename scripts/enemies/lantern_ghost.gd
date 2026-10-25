class_name LanternGhost
extends Enemy
## A Lantern Ghost of the Mist (design bible 7): the soul of a drowned dwarf,
## a hooded wisp that drifts through wood and stone. Out in the fog it is all but
## invisible; it shows only near light (Fog.clear_at): your own pocket of sight,
## a lantern, a shrine. It drifts toward you, and once close its eyes flare (a
## wind-up that always shows, even in the murk), then it lunges and fades back.
## Legend `A`.

const SIGHT := 170.0
const DRIFT_SPEED := 38.0
const REACH := 64.0
const WINDUP := 0.55
const LUNGE_SPEED := 230.0
const LUNGE_TIME := 0.42
const FADE_TIME := 0.9
const COOLDOWN := 0.6
## Faintest it gets in full fog, and how bright its wind-up always is.
const MIN_ALPHA := 0.07
const WINDUP_ALPHA := 0.75
const LUNGE_DAMAGE := 18
const TOUCH_DAMAGE := 10

const OUTLINE := Color("2c3a36")
const BODY := Color("b9cbbd")
const BODY_LIGHT := Color("e2ecdc")
const BODY_DARK := Color("7d958a")
const FACE := Color("17201e")
const EYE := Color("f4e48c")

var _dir := Vector2.ZERO
var _cooldown := 0.0
## How visible it is now, 0..1.
var seen := 1.0


func _init() -> void:
	max_hp = 18
	gold_min = 3
	gold_max = 6
	xp = 7
	body_size = Vector2(14, 18)
	body_centered = true
	uses_gravity = false
	knockback = 120.0
	contact_damage = TOUCH_DAMAGE


func _ready() -> void:
	super()
	# A ghost: it drifts through the Tree's wood.
	collision_mask = 0


func _think(delta: float) -> void:
	_cooldown -= delta
	var off := player_offset()
	var close := off.x != INF and off.length() < SIGHT
	contact_damage = LUNGE_DAMAGE if state == "lunge" else TOUCH_DAMAGE
	match state:
		"idle":
			var t := Time.get_ticks_msec() * 0.001
			var bob := home + Vector2(sin(t * 0.7) * 14.0, sin(t * 1.4) * 5.0)
			velocity = (bob - global_position) * 2.0
			if close:
				set_state("drift")
		"drift":
			if not close:
				set_state("return")
			else:
				face_player()
				velocity = velocity.move_toward(off.normalized() * DRIFT_SPEED, 120.0 * delta)
				if _cooldown <= 0.0 and off.length() < REACH:
					velocity = Vector2.ZERO
					set_state("windup")
					Sfx.play("wail", 0.08, -4.0)
		"windup":
			velocity = Vector2.ZERO
			face_player()
			if state_time >= WINDUP:
				_dir = off.normalized() if off.x != INF else Vector2(facing, 0)
				set_state("lunge")
				Sfx.play("whoosh", 0.08, -4.0)
		"lunge":
			velocity = _dir * LUNGE_SPEED
			if state_time >= LUNGE_TIME:
				set_state("fade")
		"fade":
			velocity = velocity.move_toward(-_dir * 30.0, 300.0 * delta)
			if state_time >= FADE_TIME:
				_cooldown = COOLDOWN
				set_state("drift" if close else "return")
		"return":
			var d := home - global_position
			velocity = d.normalized() * DRIFT_SPEED * 1.5
			if d.length() < 6.0 or state_time > 4.0:
				set_state("idle")
			elif close:
				set_state("drift")
		_:
			set_state("drift")


func _process(_delta: float) -> void:
	var fog := Fog.current(get_tree())
	var clear := fog.clear_at(center()) if fog != null else 1.0
	seen = lerpf(MIN_ALPHA, 1.0, clear)
	if state == "windup":
		seen = maxf(seen, WINDUP_ALPHA)
	elif state == "fade":
		seen *= 1.0 - 0.6 * clampf(state_time / FADE_TIME, 0.0, 1.0)


func _draw() -> void:
	var t := Time.get_ticks_msec() * 0.001
	var white := flashing() or (state == "windup" and telegraph_pulse())
	var a := seen
	var lean := -4 if state == "lunge" else 0
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1))
	# The tattered tail, streaming back and down, waving.
	for i in 6:
		var k := i / 5.0
		var x := roundi(-2 - k * 14.0 + sin(t * 4.0 + i) * 2.0)
		var y := roundi(8 + k * 16.0)
		var w := roundi(lerpf(14.0, 3.0, k))
		_px(x - w / 2 - 1, y - 1, w + 2, 6, OUTLINE, a * (1.0 - k * 0.5))
		_px(x - w / 2, y, w, 4, BODY_DARK if i % 2 else BODY, a * (1.0 - k * 0.6))
	# The shroud, row by row: a peaked hood that falls into a wide, ragged hem.
	for y in range(-21, 10):
		var half := _half_width(y)
		var x0 := -half + lean
		var hem := y >= 6 and (posmod(y * 3 + int(t * 6.0) + roundi(float(x0)), 4) == 0)
		_px(x0 - 1, y, half * 2 + 2, 1, OUTLINE, a)
		if not hem:
			_px(x0, y, half * 2, 1, BODY, a)
			_px(x0, y, 2, 1, BODY_LIGHT, a)
			_px(x0 + half * 2 - 2, y, 2, 1, BODY_DARK, a)
	# Hem tatters: three ragged points below the shroud.
	for k in 3:
		var hx := -9 + k * 8 + lean + roundi(sin(t * 3.0 + k) * 1.5)
		_px(hx - 1, 10, 4, 3, OUTLINE, a)
		_px(hx, 10, 2, 2, BODY_DARK, a)
	# The dark face inside the hood.
	for y in range(-14, -3):
		var fw := 5 if y < -12 or y > -6 else 6
		_px(-fw + 1 + lean, y, fw * 2 - 1, 1, FACE, a)
	# Eyes, which flare in the wind-up.
	var eye := EYE if state != "windup" else Color(1, 1, 0.85)
	var big := 3 if state == "windup" else 2
	_px(-4 + lean, -9, big, big, eye, maxf(a, 0.35 if state == "windup" else 0.0))
	_px(2 + lean, -9, big, big, eye, maxf(a, 0.35 if state == "windup" else 0.0))
	# Wisps of arms reaching forward.
	var reach := 6 if state == "lunge" else (2 if state == "windup" else 0)
	_px(8 + lean, -2, 6 + reach, 3, OUTLINE, a)
	_px(9 + lean, -1, 4 + reach, 1, BODY_LIGHT, a)
	if white:
		for y in range(-21, 10):
			_px(-_half_width(y) + lean, y, _half_width(y) * 2, 1, Color(1, 1, 1), 0.6 * maxf(a, 0.5))
	draw_set_transform(Vector2.ZERO)


## Half the shroud's width on row `y` (half-pixels): a peaked hood, shoulders,
## then a hem that flares out.
static func _half_width(y: int) -> int:
	if y < -15:
		return [2, 4, 6, 7, 8, 9][y + 21]
	if y < 0:
		return 10
	return 10 + (y + 2) / 3


func _px(x: int, y: int, w: int, h: int, color: Color, alpha: float) -> void:
	draw_rect(Rect2(x * 0.5, y * 0.5, w * 0.5, h * 0.5), Color(color, color.a * alpha))
