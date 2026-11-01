class_name ShadeKnight
extends Enemy
## A Shade Knight of Dartmoor (design bible 7): the drowned ghost of one of King
## Grieve's household guard, still in his armour, a tower shield on his left arm.
## A parry fight. His shield turns every blow from the front. He advances behind
## it, then draws his blade back (it glows: the telegraph) and thrusts, then
## cuts again. Parry either and he reels, shield wide, open to every blow.
## Let the pair finish and he stands winded a moment, shield low. Batter his
## shield instead and he answers with a quick riposte. Strike from behind or
## from above and his shield doesn't help him. Legend `e`.

const WALK_SPEED := 26.0
const SIGHT := Vector2(160, 56)
## He opens his combo when you are this near (px, centre to centre).
const REACH := 64.0
const THRUST_TELL := 0.55
const THRUST_TIME := 0.18
const THRUST_SPEED := 170.0
const CUT_TELL := 0.38
const CUT_TIME := 0.14
const RIPOSTE_TELL := 0.36
const WINDED := 0.7
const COOLDOWN := 0.6
const THRUST_DAMAGE := 18
const CUT_DAMAGE := 14
## Blows on his shield before he ripostes.
const RIPOSTE_AFTER := 2
## His blade's reach in front of the body.
const BLADE_REACH := 30.0
## The drawing is laid out small and drawn this much larger.
const SCALE := 1.7

const OUTLINE := Color("0c1418")
const ARMOR := Color("4f7f88")
const ARMOR_LIGHT := Color("8fc8c8")
const ARMOR_DARK := Color("2c4a54")
const SHIELD := Color("3a5f66")
const SHIELD_RIM := Color("a8b8a0")
const GLOW := Color("7ff0e0")
const BLADE := Color("d8f8f0")
const EYES := Color("b8fff0")

var _struck := false
var _cool := 0.0
var _battered := 0
## Which cut comes after the tell: "thrust" or "cut".
var _next := "thrust"


func _init() -> void:
	max_hp = 56
	gold_min = 10
	gold_max = 16
	xp = 28
	contact_damage = 12
	body_size = Vector2(20, 30)
	knockback = 40.0
	launchable = false


## True while his shield is up and facing you.
func guarding() -> bool:
	return state in ["idle", "walk", "thrust_tell", "cut_tell", "riposte_tell"] and not is_staggered()


func _modify_damage(damage: int, dir: Vector2) -> int:
	# The tower shield turns anything from the front unless he is reeling or winded.
	if dir.y > 0.0 or not guarding():
		return damage
	if dir.x != 0.0 and signf(dir.x) == facing:
		return damage  # from behind
	if dir.x == 0.0:
		return damage
	_battered += 1
	if _battered >= RIPOSTE_AFTER and state in ["idle", "walk"]:
		_battered = 0
		_open("riposte_tell", "cut")
	return 0


func _think(delta: float) -> void:
	_cool -= delta
	var off := player_offset()
	var seen := off.x != INF and absf(off.x) < SIGHT.x and absf(off.y) < SIGHT.y
	match state:
		"idle", "walk":
			if state == "idle":
				set_state("walk")
			if seen:
				face_player()
				if absf(off.x) < REACH and _cool <= 0.0 and is_on_floor():
					_open("thrust_tell", "thrust")
					return
				velocity.x = 0.0 if _edge_ahead() or absf(off.x) < REACH * 0.6 else facing * WALK_SPEED
			else:
				velocity.x = 0.0
		"thrust_tell", "cut_tell", "riposte_tell":
			velocity.x = 0.0
			var tell: float = {"thrust_tell": THRUST_TELL, "cut_tell": CUT_TELL, "riposte_tell": RIPOSTE_TELL}[state]
			if state_time >= tell:
				_struck = false
				set_state(_next)
				Sfx.play("slash", 0.1, -2.0)
		"thrust":
			velocity.x = 0.0 if _edge_ahead() else facing * THRUST_SPEED
			_strike(THRUST_DAMAGE)
			if state == "thrust" and state_time >= THRUST_TIME:
				velocity.x = 0.0
				face_player()
				_open("cut_tell", "cut")
		"cut":
			velocity.x = 0.0
			_strike(CUT_DAMAGE)
			if state == "cut" and state_time >= CUT_TIME:
				set_state("winded")
		"winded":
			velocity.x = 0.0
			if state_time >= WINDED:
				_cool = COOLDOWN
				_battered = 0
				set_state("walk")
		_:
			set_state("walk")


func _open(tell: String, next: String) -> void:
	velocity.x = 0.0
	face_player()
	_next = next
	set_state(tell)
	Sfx.play("swell", 0.15, -8.0)


func _strike(damage: int) -> void:
	if _struck:
		return
	var res := hit_player_in_rect(blade_rect(), damage)
	if res != "":
		_struck = true


## Where his blade cuts.
func blade_rect() -> Rect2:
	var c := center()
	var w := BLADE_REACH + body_size.x * 0.5
	return Rect2(c.x if facing > 0 else c.x - w, c.y - 14.0, w, 24.0)


func _edge_ahead() -> bool:
	if not is_on_floor():
		return false
	if test_move(global_transform, Vector2(facing * 4, 0)):
		return true
	var t := global_transform.translated(Vector2(facing * (body_size.x * 0.5 + 2), 0))
	return not test_move(t, Vector2(0, 6))


func _draw() -> void:
	var t := Time.get_ticks_msec() * 0.001
	var telling := state.ends_with("_tell")
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1))
	# A shade: he wavers a little, and his edges fray into mist below the knees.
	var a := 0.82 + 0.08 * sin(t * 3.0)
	var bob := roundi(sin(t * 2.0) * 1.0)
	var lean := 0
	var shield_x := 6
	var shield_low := 0
	match state:
		"thrust":
			lean = 4
		"cut":
			lean = 2
		"winded":
			shield_low = 8
			shield_x = 3
		"stagger":
			shield_low = 4
			shield_x = -10
			lean = -3
	# Mist trailing at his feet.
	for i in 4:
		var mx := -10 + i * 6 + roundi(sin(t * 2.5 + i) * 2.0)
		_px(mx, -4, 6, 4, Color(GLOW, 0.25), a)
	# Legs: greaves fading into the mist.
	_px(-7, -12, 6, 10, OUTLINE, a)
	_px(1, -12, 6, 10, OUTLINE, a)
	_px(-6, -11, 4, 8, ARMOR_DARK, a * 0.8)
	_px(2, -11, 4, 8, ARMOR_DARK, a * 0.8)
	# Body: a squat breastplate.
	var bx := -9 + lean
	var by := -28 + bob
	_px(bx - 1, by - 1, 20, 18, OUTLINE, a)
	_px(bx, by, 18, 16, ARMOR, a)
	_px(bx, by, 18, 3, ARMOR_LIGHT, a)
	_px(bx + 2, by + 6, 14, 2, ARMOR_DARK, a)
	_px(bx + 8, by + 3, 2, 12, ARMOR_DARK, a)
	# Helm: a dwarf's great helm with a slit; the eyes glow inside.
	var hx := -7 + lean
	var hy := by - 12
	_px(hx - 1, hy - 1, 16, 14, OUTLINE, a)
	_px(hx, hy, 14, 12, ARMOR, a)
	_px(hx, hy, 14, 3, ARMOR_LIGHT, a)
	_px(hx + 4, hy + 5, 10, 2, OUTLINE, a)
	_px(hx + 7, hy + 5, 2, 2, EYES, 1.0)
	_px(hx + 11, hy + 5, 2, 2, EYES, 1.0)
	_px(hx + 2, hy - 3, 10, 2, ARMOR_DARK, a)
	# The blade, by state: held low, drawn back glowing, thrust, or swept down.
	var sx := bx + 14
	var sy := by + 8
	var glow := telling and telegraph_pulse()
	var blade := BLADE if not glow else Color(1, 1, 1)
	var tip := Vector2i.ZERO
	match state:
		"thrust_tell", "riposte_tell":
			tip = _blade(sx - 16, sy - 2, 18, 0, blade, a)
		"cut_tell":
			tip = _blade(sx - 2, sy - 6, 6, -20, blade, a)
		"thrust":
			tip = _blade(sx, sy, 30, 0, blade, a)
		"cut":
			tip = _blade(sx, sy - 6, 24, 18, blade, a)
		"winded", "stagger":
			tip = _blade(sx, sy + 4, 12, 10, blade, a)
		_:
			tip = _blade(sx, sy + 2, 14, 6, blade, a)
	if telling:
		# The drawn blade gathers a cold light at its point: the tell.
		var k := 0.5 + 0.5 * absf(sin(state_time * 14.0))
		_px(tip.x - 4, tip.y - 4, 10, 10, Color(GLOW, 0.25 * k), 1.0)
		_px(tip.x - 1, tip.y - 6, 4, 14, Color(GLOW, 0.8 * k), 1.0)
		_px(tip.x - 6, tip.y - 1, 14, 4, Color(GLOW, 0.8 * k), 1.0)
	# The tower shield in front: tall, iron-rimmed, a drowned crown on it.
	var shx := shield_x + lean
	var shy := by - 6 + shield_low
	_px(shx - 1, shy - 1, 9, 30, OUTLINE, a)
	_px(shx, shy, 7, 28, SHIELD, a)
	_px(shx, shy, 7, 2, SHIELD_RIM, a)
	_px(shx, shy + 26, 7, 2, SHIELD_RIM, a)
	_px(shx + 5, shy, 2, 28, SHIELD_RIM, a)
	_px(shx + 2, shy + 10, 3, 4, GLOW, a * 0.7)
	_px(shx + 1, shy + 9, 1, 2, GLOW, a * 0.7)
	_px(shx + 5, shy + 9, 1, 2, GLOW, a * 0.7)
	wash(flashing() or (telling and telegraph_pulse()))
	draw_set_transform(Vector2.ZERO)


## A blade from (x, y) along (dx, dy), outlined, with a bright edge.
func _blade(x: int, y: int, dx: int, dy: int, color: Color, a: float) -> Vector2i:
	var steps := maxi(absi(dx), absi(dy))
	for i in steps + 1:
		_px(x + roundi(dx * float(i) / steps) - 1, y + roundi(dy * float(i) / steps) - 1, 4, 4, OUTLINE, a)
	for i in steps + 1:
		_px(x + roundi(dx * float(i) / steps), y + roundi(dy * float(i) / steps), 2, 2, color, a)
	# The hilt.
	_px(x - 2, y - 2, 3, 6, ARMOR_DARK, a)
	return Vector2i(x + dx, y + dy)


## Draws a rect of the design (laid out in units of 1/SCALE half-pixels),
## snapped to the half-pixel grid so neighbouring rects still tile.
func _px(x: int, y: int, w: int, h: int, color: Color, alpha: float) -> void:
	var x0 := floorf(x * SCALE)
	var y0 := floorf(y * SCALE)
	var x1 := maxf(floorf((x + w) * SCALE), x0 + 1.0)
	var y1 := maxf(floorf((y + h) * SCALE), y0 + 1.0)
	draw_rect(Rect2(x0 * 0.5, y0 * 0.5, (x1 - x0) * 0.5, (y1 - y0) * 0.5), Color(color, color.a * alpha))
