class_name Winch
extends Node2D
## The great winch of Winch Hall (room prop `winch`), a Tower landmark: a
## toothed iron wheel and a rope drum in an A-frame, its rope running up out of
## sight toward Forepaw. It has stood still since the dwarves went quiet; once
## Zoradohna falls and the dwarves are free, it turns again, slowly, and the
## rope crawls. Scenery only, drawn at 2x density. The origin is the bottom
## center (it stands on the floor or a ledge).

const OUTLINE := Color("120f19")
const IRON := Color("4a4560")
const IRON_LIGHT := Color("7a7296")
const IRON_DARK := Color("2a2638")
const BRASS := Color("cb8d16")
const BRASS_LIGHT := Color("f0c02e")
const WOOD := Color("6e3a1a")
const WOOD_DARK := Color("48201e")
const ROPE := Color("aa6336")
const ROPE_DARK := Color("783c2b")

const WHEEL_R := 44.0
const DRUM_R := 16.0
const AXLE := Vector2(0, -58)
## Turns per second once it runs.
const SPEED := 0.06
const FLAG := "boss:zoradohna"

var angle := 0.0


func _ready() -> void:
	z_index = -2


func running() -> bool:
	return GameState.flag(FLAG)


func _process(delta: float) -> void:
	if running():
		angle = fposmod(angle + SPEED * delta, 1.0)
		queue_redraw()


func _px(x: float, y: float, w: float, h: float, c: Color) -> void:
	draw_rect(Rect2(x, y, w, h), c)


func _draw() -> void:
	var a := angle * TAU
	# The rope climbs out of sight from the drum's top; its marks crawl upward as it winds.
	var rx := DRUM_R - 1.0
	_px(rx - 1.5, -300, 4, 300 + AXLE.y, OUTLINE)
	_px(rx - 1, -300, 3, 300 + AXLE.y, ROPE)
	var mark := fposmod(-angle * TAU * DRUM_R, 6.0)
	var y := AXLE.y - mark
	while y > -300.0:
		_px(rx - 1, y, 3, 1, ROPE_DARK)
		y -= 6.0
	# The A-frame: two timber legs each side, braced, on stone feet.
	for s: float in [-1.0, 1.0]:
		var foot := Vector2(s * 50, 0)
		var top := AXLE + Vector2(s * 4, -4)
		draw_line(foot, top, OUTLINE, 7.0)
		draw_line(foot, top, WOOD, 5.0)
		draw_line(foot + Vector2(-s * 1.5, 0), top + Vector2(-s * 1.5, 0), WOOD_DARK, 1.5)
		_px(foot.x - 7, -5, 14, 5, OUTLINE)
		_px(foot.x - 6, -4, 12, 4, IRON)
		_px(foot.x - 6, -4, 12, 1, IRON_LIGHT)
	draw_line(Vector2(-34, -18), Vector2(34, -18), OUTLINE, 5.0)
	draw_line(Vector2(-34, -18), Vector2(34, -18), WOOD, 3.0)
	# The toothed wheel: a rim of iron teeth, six spokes, a brass hub.
	var teeth := 24
	for i in teeth:
		var t := a + float(i) / teeth * TAU
		var d := Vector2(cos(t), sin(t))
		draw_line(AXLE + d * (WHEEL_R - 2.0), AXLE + d * (WHEEL_R + 3.5), OUTLINE, 5.0)
		draw_line(AXLE + d * (WHEEL_R - 1.0), AXLE + d * (WHEEL_R + 2.5), IRON, 3.0)
	draw_arc(AXLE, WHEEL_R - 2.5, 0.0, TAU, 72, OUTLINE, 7.0)
	draw_arc(AXLE, WHEEL_R - 2.5, 0.0, TAU, 72, IRON, 5.0)
	draw_arc(AXLE, WHEEL_R - 1.0, 0.0, TAU, 72, IRON_LIGHT, 1.0)
	draw_arc(AXLE, WHEEL_R - 4.5, 0.0, TAU, 72, IRON_DARK, 1.0)
	for i in 6:
		var t := a + i * TAU / 6.0
		var d := Vector2(cos(t), sin(t))
		draw_line(AXLE + d * 8.0, AXLE + d * (WHEEL_R - 5.0), OUTLINE, 4.5)
		draw_line(AXLE + d * 8.0, AXLE + d * (WHEEL_R - 5.0), IRON, 2.5)
		draw_circle(AXLE + d * (WHEEL_R - 3.0), 1.0, BRASS)
	# The rope drum in front, wound with rope.
	draw_circle(AXLE, DRUM_R + 1.0, OUTLINE)
	draw_circle(AXLE, DRUM_R, ROPE)
	for i in 5:
		var off := -DRUM_R + 3.0 + i * 5.5
		var h := sqrt(maxf(0.0, DRUM_R * DRUM_R - off * off))
		draw_line(AXLE + Vector2(-h, off), AXLE + Vector2(h, off), ROPE_DARK, 1.0)
	draw_circle(AXLE, 6.0, OUTLINE)
	draw_circle(AXLE, 5.0, BRASS)
	draw_circle(AXLE + Vector2(-1.2, -1.2), 2.0, BRASS_LIGHT)
	# The crank: an iron arm and a worn wooden handle, turning with the wheel.
	var c := AXLE + Vector2(cos(-a * 2.0), sin(-a * 2.0)) * 24.0
	draw_line(AXLE, c, OUTLINE, 4.0)
	draw_line(AXLE, c, IRON_LIGHT, 2.0)
	draw_line(c, c + Vector2(0, 7), OUTLINE, 4.0)
	draw_line(c, c + Vector2(0, 7), WOOD, 2.5)
	# A pawl that clicks on the teeth, and its spring.
	var pawl := AXLE + Vector2(-WHEEL_R - 6, -6)
	draw_line(pawl, pawl + Vector2(6, 6), OUTLINE, 3.5)
	draw_line(pawl, pawl + Vector2(6, 6), BRASS, 1.5)
	draw_circle(pawl, 2.0, IRON_LIGHT)
