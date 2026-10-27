class_name LeafMantis
extends Enemy
## A Leaf Mantis of the Branches (design bible 7): a mantis the green of the
## World Tree's leaves, folded up on a bough so it looks like one more leaf
## cluster. It does not hurt to touch while it hides. Come near and it rears up
## and spreads its scythe arms (the telegraph), then lunges along the bough and
## slashes. A lunge that misses leaves it overreached, arms low: strike it then
## for half again the damage. Its slash can be parried. Legend `m`.

## How near you must come (px, centre to centre) before it unfolds.
const SIGHT_X := 110.0
const SIGHT_Y := 48.0
const UNFOLD := 0.5
const LUNGE_SPEED := 260.0
const LUNGE_TIME := 0.25
const RECOVER := 0.8
const STALK_SPEED := 40.0
## Out of sight this long while stalking, it folds back into a leaf.
const LOSE_TIME := 2.0
const SLASH_DAMAGE := 16
const TOUCH_DAMAGE := 10
## Overreached, it takes this much more damage.
const SOFT := 1.5
## The scythes' reach in front of the body while lunging.
const SLASH_REACH := 24.0
## The drawing is laid out small and drawn this much larger.
const SCALE := 1.6

const OUTLINE := Color("1d2a16")
const LEAF := Color("5d9a3c")
const LEAF_LIGHT := Color("8cc35a")
const LEAF_DARK := Color("3b6a2a")
const VEIN := Color("2e5220")
const BLADE := Color("d8e8b0")
const EYE := Color("f0d040")

var _struck := false
var _lost := 0.0


func _init() -> void:
	max_hp = 30
	gold_min = 4
	gold_max = 8
	xp = 9
	body_size = Vector2(22, 32)
	knockback = 60.0
	contact_damage = 0
	state = "hide"


func _think(delta: float) -> void:
	var off := player_offset()
	var seen := off.x != INF and absf(off.x) < SIGHT_X and absf(off.y) < SIGHT_Y
	contact_damage = 0 if state == "hide" else TOUCH_DAMAGE
	match state:
		"hide":
			velocity.x = 0.0
			if seen:
				_unfold()
		"unfold":
			velocity.x = 0.0
			face_player()
			if state_time >= UNFOLD:
				_struck = false
				set_state("lunge")
				Sfx.play("scythe", 0.1, -3.0)
		"lunge":
			if _edge_ahead():
				velocity.x = 0.0
			else:
				velocity.x = facing * LUNGE_SPEED
			if not _struck:
				var res := hit_player_in_rect(slash_rect(), SLASH_DAMAGE)
				if res != "":
					_struck = true
			if state_time >= LUNGE_TIME and state == "lunge":
				velocity.x = 0.0
				set_state("recover")
		"recover":
			velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
			if state_time >= RECOVER:
				_lost = 0.0
				set_state("stalk")
		"stalk":
			if seen:
				_lost = 0.0
				face_player()
				velocity.x = 0.0 if _edge_ahead() else facing * STALK_SPEED
				if state_time >= 0.4:
					_unfold()
			else:
				velocity.x = 0.0
				_lost += delta
				if _lost >= LOSE_TIME:
					set_state("hide")
		_:
			set_state("stalk")


func _unfold() -> void:
	velocity.x = 0.0
	face_player()
	set_state("unfold")
	Sfx.play("mantis_unfold", 0.1, -4.0)


## Where its scythes cut during a lunge.
func slash_rect() -> Rect2:
	var c := center()
	var x := c.x if facing > 0 else c.x - SLASH_REACH - body_size.x * 0.5
	return Rect2(x, c.y - 16.0, SLASH_REACH + body_size.x * 0.5, 30.0)


func _modify_damage(damage: int, _dir: Vector2) -> int:
	if state == "hide":
		# Struck while folded: it springs open, and the next swing is yours.
		_unfold()
	return roundi(damage * SOFT) if state == "recover" else damage


func _edge_ahead() -> bool:
	if not is_on_floor():
		return false
	if test_move(global_transform, Vector2(facing * 4, 0)):
		return true
	var t := global_transform.translated(Vector2(facing * (body_size.x * 0.5 + 2), 0))
	return not test_move(t, Vector2(0, 6))


func _draw() -> void:
	var t := Time.get_ticks_msec() * 0.001
	var white := flashing() or (state == "unfold" and telegraph_pulse())
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1))
	if state == "hide":
		_draw_folded(t)
	else:
		_draw_open(t)
	wash(white)
	draw_set_transform(Vector2.ZERO)


## Folded: three overlapping leaves, swaying a little like the rest of the bough.
func _draw_folded(t: float) -> void:
	var sway := roundi(sin(t * 1.3 + home.x * 0.05) * 1.5)
	_leaf(-10 + sway, -22, 16, 22, LEAF_DARK)
	_leaf(-2 + sway, -26, 16, 26, LEAF)
	_leaf(-14 + sway, -16, 14, 16, LEAF_LIGHT)
	# A hint of the eye, for the sharp-sighted.
	_px(6 + sway, -18, 2, 2, EYE, 0.6)


## Open: abdomen, thorax, head and scythes, posed for the state.
func _draw_open(t: float) -> void:
	var rear := 0
	var arm := 0  # 0 = folded at the chest, 1 = raised and spread, 2 = thrust forward, 3 = slack
	var lean := 0
	match state:
		"unfold":
			rear = mini(int(state_time / UNFOLD * 8.0), 6)
			arm = 1
		"lunge":
			arm = 2
			lean = 6
		"recover":
			arm = 3
			lean = 4
			rear = -4
		"stagger":
			arm = 3
			rear = -2
	var bob := roundi(sin(t * 6.0) * 1.0) if state == "stalk" else 0
	# Legs: three thin pairs down to the bough.
	for i in 3:
		var lx := -12 + i * 8 + (lean if i == 2 else 0)
		_px(lx - 1, -10, 4, 10, OUTLINE, 1.0)
		_px(lx, -9, 2, 9, LEAF_DARK, 1.0)
	# The abdomen: a long leaf shape trailing behind.
	_leaf(-22, -22 + bob, 22, 14, LEAF)
	# The thorax: a stalk leaning forward from the abdomen, a step at a time.
	var tx := -2 + lean
	var ty := -30 - rear + bob
	for i in 6:
		var sx := tx + i / 2
		var sy := ty + i * 3
		_px(sx - 1, sy - 1, 8, 5, OUTLINE, 1.0)
	for i in 6:
		var sx := tx + i / 2
		var sy := ty + i * 3
		_px(sx, sy, 6, 3, LEAF_LIGHT, 1.0)
		_px(sx + 4, sy, 2, 3, LEAF_DARK, 1.0)
	# The head: a wedge pointing forward, a big compound eye at the front.
	var hx := tx + 2
	var hy := ty - 9
	_px(hx - 1, hy - 1, 14, 10, OUTLINE, 1.0)
	_px(hx, hy, 12, 8, LEAF, 1.0)
	_px(hx, hy, 12, 2, LEAF_LIGHT, 1.0)
	_px(hx + 8, hy + 6, 6, 3, OUTLINE, 1.0)
	_px(hx + 8, hy + 6, 4, 2, LEAF_DARK, 1.0)
	_px(hx + 7, hy + 1, 4, 4, OUTLINE, 1.0)
	_px(hx + 7, hy + 1, 3, 3, EYE, 1.0)
	# Antennae, swept back.
	_px(hx + 1, hy - 5, 1, 5, OUTLINE, 1.0)
	_px(hx - 2, hy - 8, 3, 1, OUTLINE, 1.0)
	_px(hx + 4, hy - 4, 1, 4, OUTLINE, 1.0)
	# Scythes, from the front of the thorax.
	var ax := tx + 6
	var ay := ty + 4
	match arm:
		1:
			# Reared and spread: both blades up and out ahead of the head.
			_scythe(ax, ay, 8, -16)
			_scythe(ax - 2, ay + 3, 14, -8)
		2:
			_scythe(ax, ay, 22, 2)
			_scythe(ax - 2, ay + 4, 18, 6)
		3:
			_scythe(ax, ay + 4, 8, 10)
		_:
			_scythe(ax, ay, 4, 8)


## A scythe arm from (x, y) along (dx, dy), with a pale hooked blade at the end.
func _scythe(x: int, y: int, dx: int, dy: int) -> void:
	var steps := maxi(absi(dx), absi(dy))
	for i in steps + 1:
		var px := x + roundi(dx * float(i) / steps)
		var py := y + roundi(dy * float(i) / steps)
		_px(px - 1, py - 1, 4, 4, OUTLINE, 1.0)
	for i in steps + 1:
		var px := x + roundi(dx * float(i) / steps)
		var py := y + roundi(dy * float(i) / steps)
		_px(px, py, 2, 2, LEAF_DARK if i < steps / 2 else BLADE, 1.0)
	# The hook.
	_px(x + dx - 1, y + dy + 1, 4, 2, OUTLINE, 1.0)
	_px(x + dx, y + dy + 2, 2, 3, BLADE, 1.0)


## A leaf: an outlined lens shape with a midrib along its length.
func _leaf(x: int, y: int, w: int, h: int, color: Color) -> void:
	for r in h:
		var k := absf(float(r) - h * 0.5) / (h * 0.5)
		var half := roundi(w * 0.5 * sqrt(maxf(0.0, 1.0 - k * k)))
		var cx := x + w / 2
		_px(cx - half - 1, y + r, half * 2 + 2, 1, OUTLINE, 1.0)
		if half > 0:
			_px(cx - half, y + r, half * 2, 1, color, 1.0)
	if w > h:
		_px(x + 2, y + h / 2, w - 4, 1, VEIN, 1.0)
	else:
		_px(x + w / 2, y + 2, 1, h - 4, VEIN, 1.0)


## Draws a rect of the design (laid out in units of 1/SCALE half-pixels),
## snapped to the half-pixel grid so neighbouring rects still tile.
func _px(x: int, y: int, w: int, h: int, color: Color, alpha: float) -> void:
	var x0 := floorf(x * SCALE)
	var y0 := floorf(y * SCALE)
	var x1 := maxf(floorf((x + w) * SCALE), x0 + 1.0)
	var y1 := maxf(floorf((y + h) * SCALE), y0 + 1.0)
	draw_rect(Rect2(x0 * 0.5, y0 * 0.5, (x1 - x0) * 0.5, (y1 - y0) * 0.5), Color(color, color.a * alpha))
