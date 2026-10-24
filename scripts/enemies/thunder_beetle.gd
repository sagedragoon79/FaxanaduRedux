class_name ThunderBeetle
extends Enemy
## A Thunder Beetle of Daybreak (design bible 7): a beetle as big as a dog,
## its storm-violet shell striped with gold, that trundles the shrine stones
## soaking up the storm. The shell turns blows from the side, but not from
## above: pogo it. Linger near it and its wing cases lift and crackle (the
## telegraph), then it discharges a ring of lightning around itself that
## can't be parried, above it as much as beside it. Spent, its wing cases hang
## open and every blow lands in full. Legend `t`.

## How near you must come (px, centre to centre) before it charges.
const TRIGGER := 64.0
const WALK_SPEED := 28.0
const CHARGE := 0.6
const DISCHARGE := 0.3
const SPENT := 1.1
## After a discharge it walks a while before it can charge again.
const COOLDOWN := 1.4
## The lightning's reach from the centre of the shell.
const RADIUS := 46.0
const DISCHARGE_DAMAGE := 14
const TOUCH_DAMAGE := 12
## Share of a side blow that gets through the shell.
const SHELL := 0.3
## Design units per half-pixel (2.0: one unit is one world pixel).
const SCALE := 2.0

const OUTLINE := Color("13101f")
const SHELL_DARK := Color("2e2350")
const SHELL_MID := Color("4a3a7a")
const SHELL_LIGHT := Color("7c68b8")
const STRIPE := Color("e8c04a")
const LEG := Color("221a38")
const HORN := Color("c88a3a")
const SPARK := Color("f8f0b0")
const ARC := Color("b8a8ff")

var _cool := 0.0
var _struck := false


func _init() -> void:
	max_hp = 44
	gold_min = 6
	gold_max = 12
	xp = 14
	body_size = Vector2(30, 18)
	knockback = 40.0
	contact_damage = TOUCH_DAMAGE
	state = "walk"


func _think(delta: float) -> void:
	_cool -= delta
	var off := player_offset()
	var near := off.x != INF and off.length() < TRIGGER
	match state:
		"walk":
			if _edge_ahead():
				facing = -facing
			velocity.x = facing * WALK_SPEED
			if near and _cool <= 0.0:
				velocity.x = 0.0
				set_state("charge")
				Sfx.play("static", 0.05, -3.0)
		"charge":
			velocity.x = 0.0
			if state_time >= CHARGE:
				_struck = false
				set_state("discharge")
				Sfx.play("zap", 0.05)
				Feel.add_trauma(0.2)
		"discharge":
			velocity.x = 0.0
			if not _struck and _player_in_ring():
				_struck = true
				var p := player()
				p.receive_attack(DISCHARGE_DAMAGE, self, false)
			if state_time >= DISCHARGE:
				set_state("spent")
		"spent":
			velocity.x = 0.0
			if state_time >= SPENT:
				_cool = COOLDOWN
				set_state("walk")
		_:
			set_state("walk")


## Is any part of the player's body within the lightning's reach?
func _player_in_ring() -> bool:
	var p := player()
	if p == null or p.dead:
		return false
	var r := p.body_rect()
	var c := center()
	var nearest := Vector2(clampf(c.x, r.position.x, r.end.x), clampf(c.y, r.position.y, r.end.y))
	return nearest.distance_to(c) <= RADIUS


## Shell open or not, a blow from above lands in full.
func exposed() -> bool:
	return state == "spent"


func _modify_damage(damage: int, dir: Vector2) -> int:
	if exposed() or dir.y > 0.0:
		return damage
	return maxi(1, roundi(damage * SHELL))


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
	var lift := 0
	match state:
		"charge":
			lift = mini(int(state_time / CHARGE * 4.0), 3)
		"discharge":
			lift = 3
		"spent":
			lift = 5
	var step := roundi(sin(t * 10.0)) if state == "walk" else 0
	# Six legs, three a side, stepping in turn.
	for i in 3:
		var lx := -8 + i * 7
		var up := step if i % 2 == 0 else -step
		_px(lx - 1, -5 + up, 3, 5 - up, OUTLINE)
		_px(lx, -4 + up, 1, 4 - up, LEG)
		_px(lx - 2, -1, 3, 1, LEG)
	# The body under the shell, glimpsed when the cases lift.
	_px(-10, -10, 20, 5, OUTLINE)
	_px(-9, -9, 18, 3, SHELL_DARK)
	# Head and horns at the front: a pair of copper prongs.
	_px(8, -9, 6, 5, OUTLINE)
	_px(9, -8, 4, 3, SHELL_DARK)
	_px(12, -12, 2, 4, OUTLINE)
	_px(13, -14, 3, 3, OUTLINE)
	_px(12, -11, 1, 3, HORN)
	_px(13, -13, 2, 1, HORN)
	_px(11, -7, 1, 1, STRIPE)
	# The wing cases: a dome split down the middle, the back case lifting
	# as it charges. Each row of the dome is a little narrower than the one below.
	for half in 2:
		var dy := 0 if half == 0 else -lift
		for r in 12:
			var k := float(r) / 12.0
			var w := roundi(13.0 * sqrt(maxf(0.0, 1.0 - k * k)))
			var y := -8 - r + dy
			var x0 := 0 if half == 0 else -w
			_px(x0 - (1 if half == 1 else 0), y - 1, w + 1, 3, OUTLINE)
		for r in 12:
			var k := float(r) / 12.0
			var w := roundi(13.0 * sqrt(maxf(0.0, 1.0 - k * k))) - 1
			var y := -8 - r + dy
			var x0 := 0 if half == 0 else -w
			var col := SHELL_DARK if r < 3 else (SHELL_LIGHT if r > 8 else SHELL_MID)
			if r == 6 and w > 3:
				_px(x0 + (1 if half == 1 else 0), y, w - 2, 1, STRIPE)
				continue
			_px(x0, y, w, 1, col)
		# A glint on the crown of each case.
		_px(3 if half == 0 else -6, -17 + dy, 3, 1, Color(1, 1, 1, 0.5))
	# Static: sparks jumping between the lifted cases.
	if state == "charge" or state == "discharge":
		var bright := telegraph_pulse() or state == "discharge"
		for k in 3:
			var sx := -10 + int(fposmod(t * 37.0 + k * 7.3, 20.0))
			var sy := -20 - int(fposmod(t * 23.0 + k * 3.1, 4.0)) - lift
			_px(sx, sy, 1, 2, SPARK if bright else ARC)
	if flashing() or (state == "charge" and telegraph_pulse()):
		_px(-13, -19 - lift, 29, 19 + lift, Color(1, 1, 1), 0.55)
	draw_set_transform(Vector2.ZERO)
	if state == "discharge":
		_draw_ring(t)


## The discharge: a jagged ring of lightning around the shell.
func _draw_ring(t: float) -> void:
	var c := center() - global_position
	var k := clampf(state_time / DISCHARGE, 0.0, 1.0)
	var pts := PackedVector2Array()
	var n := 18
	for i in n + 1:
		var a := TAU * i / n
		var jag := 1.0 + (0.12 if (i + int(t * 30.0)) % 2 == 0 else -0.08)
		pts.append(c + Vector2(cos(a), sin(a)) * RADIUS * jag)
	var col := Color(SPARK, 1.0 - k * 0.6)
	draw_polyline(pts, Color(ARC, 0.5 * (1.0 - k)), 3.0)
	draw_polyline(pts, col, 1.0)
	draw_circle(c, RADIUS * 0.9, Color(ARC, 0.12 * (1.0 - k)))


## Draws a rect of the design (in units of 1/SCALE half-pixels), snapped to
## the half-pixel grid so neighbouring rects still tile.
func _px(x: int, y: int, w: int, h: int, color: Color, alpha := 1.0) -> void:
	var x0 := floorf(x * SCALE)
	var y0 := floorf(y * SCALE)
	var x1 := maxf(floorf((x + w) * SCALE), x0 + 1.0)
	var y1 := maxf(floorf((y + h) * SCALE), y0 + 1.0)
	draw_rect(Rect2(x0 * 0.5, y0 * 0.5, (x1 - x0) * 0.5, (y1 - y0) * 0.5), Color(color, color.a * alpha))
