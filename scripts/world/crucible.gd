class_name Crucible
extends Node2D
## The great crucible of the Smelter (room prop `crucible`), a Tower landmark:
## an iron pot as wide as a house hung on chains, tipped to pour molten ore
## in a glowing stream into a stone trough. The stream ripples, the trough
## crusts and glows, and sparks jump where the metal lands. Scenery only (the
## metal never touches the walkway), drawn at 2x density. The origin is the
## bottom center of the trough, on the floor.

const OUTLINE := Color("120f19")
const IRON := Color("4a4560")
const IRON_LIGHT := Color("7a7296")
const IRON_DARK := Color("2a2638")
const CHAIN := Color("867ba2")
const STONE := Color("5a5470")
const STONE_LIGHT := Color("8a84a0")
const CRUST := Color("6e3a1a")
const MOLTEN := Color("e8641c")
const HOT := Color("f0c02e")
const WHITE_HOT := Color("f7f1de")

## Where the pot hangs, from the origin, and how far it is tipped (radians).
const POT := Vector2(-34, -132)
const TIP := 0.38
const POT_R := Vector2(34, 26)
const TROUGH_W := 150.0

var t := 0.0
## Live sparks: [position, velocity, life].
var sparks: Array = []
var _rng := RandomNumberGenerator.new()
var _glow: Node2D


func _ready() -> void:
	z_index = -2
	_rng.seed = 11
	_glow = Node2D.new()
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_glow.material = mat
	_glow.z_index = 1
	_glow.draw.connect(_draw_glow)
	add_child(_glow)


## The point on the pot's lip the stream leaves from.
func lip() -> Vector2:
	return POT + Vector2(POT_R.x, -POT_R.y * 0.6).rotated(TIP)


func _process(delta: float) -> void:
	t += delta
	if _rng.randf() < delta * 14.0:
		var at := Vector2(lip().x + _rng.randf_range(-3, 3), -12)
		sparks.append([at, Vector2(_rng.randf_range(-70, 70), _rng.randf_range(-150, -60)), _rng.randf_range(0.3, 0.6)])
	for s: Array in sparks:
		s[1].y += 380.0 * delta
		s[0] += s[1] * delta
		s[2] -= delta
	sparks = sparks.filter(func(s: Array) -> bool: return s[2] > 0.0)
	queue_redraw()
	_glow.queue_redraw()


func _px(x: float, y: float, w: float, h: float, c: Color) -> void:
	draw_rect(Rect2(x, y, w, h), c)


func _ellipse(c: Vector2, r: Vector2, rot: float, n := 28) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		var a := float(i) / n * TAU
		pts.append(c + Vector2(cos(a) * r.x, sin(a) * r.y).rotated(rot))
	return pts


func _draw() -> void:
	# Chains from the dark above to the pot's two trunnions.
	for side: float in [-1.0, 1.0]:
		var hook := POT + Vector2(side * POT_R.x * 0.9, -POT_R.y * 0.2).rotated(TIP)
		var cy := hook.y
		while cy > -320.0:
			_px(hook.x - 1.5, cy - 4, 3, 3, OUTLINE)
			_px(hook.x - 1, cy - 3.5, 2, 2, CHAIN)
			cy -= 5.0
		draw_circle(hook, 3.0, OUTLINE)
		draw_circle(hook, 2.0, IRON_LIGHT)
	# The pot: a deep bowl of riveted iron, tipped toward the trough.
	var bowl := PackedVector2Array()
	for i in 17:
		var a := float(i) / 16.0 * PI
		bowl.append(POT + Vector2(cos(a) * POT_R.x, sin(a) * POT_R.y * 1.6).rotated(TIP))
	bowl.append(POT + Vector2(-POT_R.x, 0).rotated(TIP))
	var outline := PackedVector2Array()
	for p in bowl:
		outline.append(POT + (p - POT) * 1.06)
	draw_colored_polygon(outline, OUTLINE)
	draw_colored_polygon(bowl, IRON)
	for i in 4:
		var a := 0.5 + i * 0.7
		var p := POT + Vector2(cos(a) * POT_R.x * 0.8, sin(a) * POT_R.y * 1.3).rotated(TIP)
		draw_circle(p, 1.2, IRON_LIGHT)
	var band := PackedVector2Array()
	for i in 17:
		var a := float(i) / 16.0 * PI
		band.append(POT + Vector2(cos(a) * POT_R.x * 0.98, 6 + sin(a) * POT_R.y * 0.4).rotated(TIP))
	draw_polyline(band, IRON_DARK, 2.0)
	# Molten metal filling the mouth, its surface rolling.
	draw_colored_polygon(_ellipse(POT, Vector2(POT_R.x, POT_R.y * 0.42), TIP), OUTLINE)
	draw_colored_polygon(_ellipse(POT, Vector2(POT_R.x - 2.0, POT_R.y * 0.42 - 1.5), TIP), MOLTEN)
	for i in 5:
		var p := POT + Vector2(-22 + i * 11 + sin(t * 2.0 + i) * 3.0, sin(t * 3.0 + i * 1.7) * 2.0).rotated(TIP)
		draw_colored_polygon(_ellipse(p, Vector2(4, 1.5), TIP, 10), HOT)
	# The stream, from the lip to the trough: a wavering column of light.
	var top := lip()
	var y := top.y
	while y < -10.0:
		var k := (y - top.y) / (-10.0 - top.y)
		var wob := sin(t * 11.0 + y * 0.15) * 1.2
		var w := 6.0 - 2.0 * k
		_px(top.x + 3.0 * k * k + wob - w * 0.5, y, w, 2.0, MOLTEN)
		_px(top.x + 3.0 * k * k + wob - w * 0.25, y, w * 0.5, 2.0, HOT if int(t * 20.0 + y) % 6 else WHITE_HOT)
		y += 2.0
	# The trough: a stone channel on the floor, glowing metal crusting as it runs off.
	var x0 := -TROUGH_W * 0.5
	_px(x0 - 1, -13, TROUGH_W + 2, 13, OUTLINE)
	_px(x0, -12, TROUGH_W, 12, STONE)
	_px(x0, -12, TROUGH_W, 1.5, STONE_LIGHT)
	_px(x0 + 4, -9, TROUGH_W - 8, 4, OUTLINE)
	var bx := x0 + 5.0
	while bx < x0 + TROUGH_W - 5.0:
		var heat := clampf(1.0 - absf(bx - top.x) / (TROUGH_W * 0.6), 0.0, 1.0)
		var flick := 0.5 + 0.5 * sin(t * 4.0 + bx * 0.3)
		var c := CRUST.lerp(MOLTEN, heat).lerp(HOT, heat * heat * flick * 0.6)
		_px(bx, -8.5, 2.0, 3.0, c)
		bx += 2.0
	for i in 6:
		_px(x0 + 10 + i * 24, -12, 1, 12, OUTLINE)
	# Sparks off the landing point.
	for s: Array in sparks:
		var life: float = s[2]
		_px(s[0].x, s[0].y, 1.0, 1.0, HOT.lerp(WHITE_HOT, clampf(life * 2.0, 0.0, 1.0)))


func _draw_glow() -> void:
	var pulse := 0.5 + 0.5 * sin(t * 1.7)
	var warm := Color(MOLTEN.r, MOLTEN.g * 0.7, MOLTEN.b * 0.3, 0.014 + 0.008 * pulse)
	for i in 9:
		_glow.draw_circle(Vector2(lip().x, -14), 110.0 - i * 11.0, warm)
	for i in 5:
		_glow.draw_circle(POT, 60.0 - i * 10.0, Color(warm.r, warm.g, warm.b, 0.012))
	var top := lip()
	_glow.draw_rect(Rect2(top.x - 6, top.y, 12, -top.y - 10), Color(HOT.r, HOT.g, HOT.b, 0.08))
