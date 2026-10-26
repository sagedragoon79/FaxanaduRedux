class_name HouseFront
extends Node2D
## A house carved into the living wood (Apolune): a plank front under a bark
## arch, a door and a window. The windows are boarded until the Spring of Trunk
## is restored and the townsfolk come home, then they glow. Scenery only. The
## origin is the bottom center.

const WIDTH := 76.0
const HEIGHT := 70.0
const BARK := Color("48201e")
const BARK_LIGHT := Color("783c2b")
const PLANK := Color("aa6336")
const PLANK_DARK := Color("783c2b")
const DOOR := Color("1c0d0f")
const FRAME := Color("cd8c51")
const LIT := Color("f0c02e")
const LIT_CORE := Color("f7f1de")
const BOARD := Color("8d4e16")
const OUTLINE := Color("120f19")

## Weathered boardwalk houses for the towns of the Mist (Victim): reed-grey
## planks under a dark, damp frame. Their windows burn always: the people there
## never left.
const MIST := {"bark": Color("2e3430"), "bark_light": Color("4a5650"), "plank": Color("6e7466"), "plank_dark": Color("4a5048"), "frame": Color("9a8a5a")}
const BARK_LOOK := {"bark": BARK, "bark_light": BARK_LIGHT, "plank": PLANK, "plank_dark": PLANK_DARK, "frame": FRAME}

## The world flag that lights the windows ("" for always lit).
var lit_flag := "spring:trunk"
## "bark" (the living wood) or "mist" (weathered boardwalk planks).
var style := "bark"
var _t := 0.0


func _ready() -> void:
	z_index = -2


func lit() -> bool:
	return lit_flag == "" or GameState.flag(lit_flag)


func _process(delta: float) -> void:
	if lit():
		_t += delta
		queue_redraw()


func _draw() -> void:
	var c: Dictionary = MIST if style == "mist" else BARK_LOOK
	var w := WIDTH
	var h := HEIGHT
	# The bark arch around the front, a little wider than the planks.
	var arch_r := w * 0.5 + 6.0
	draw_circle(Vector2(0, -h + arch_r * 0.6), arch_r, OUTLINE)
	draw_circle(Vector2(0, -h + arch_r * 0.6), arch_r - 2.0, c.bark)
	draw_rect(Rect2(-arch_r, -h + arch_r * 0.6, arch_r * 2.0, h - arch_r * 0.6), c.bark)
	draw_rect(Rect2(-arch_r - 2, -h + arch_r * 0.6, 2, h - arch_r * 0.6), OUTLINE)
	draw_rect(Rect2(arch_r, -h + arch_r * 0.6, 2, h - arch_r * 0.6), OUTLINE)
	for i in 5:
		draw_rect(Rect2(-arch_r + 3 + i * 17, -h + 8 + (i % 2) * 6, 2, h - 10), c.bark_light)
	# Planks.
	var front := Rect2(-w * 0.5, -h + 14, w, h - 14)
	draw_rect(front.grow(1.0), OUTLINE)
	draw_rect(front, c.plank)
	var y := front.position.y + 6.0
	while y < 0.0:
		draw_rect(Rect2(front.position.x, y, w, 1), c.plank_dark)
		y += 7.0
	# Door, left of center, with a frame.
	var door := Rect2(-w * 0.5 + 10, -30, 18, 30)
	draw_rect(door.grow(2.0), c.frame)
	draw_rect(door, DOOR)
	draw_rect(Rect2(door.end.x - 5, -16, 2, 2), LIT if lit() else BOARD)
	# Window, right of center.
	var win := Rect2(w * 0.5 - 30, -h + 26, 18, 16)
	draw_rect(win.grow(2.0), c.frame)
	if lit():
		var flicker := 0.85 + 0.15 * sin(_t * 7.0) * sin(_t * 3.1)
		draw_rect(win, LIT * Color(1, 1, 1, flicker))
		draw_rect(win.grow(-4.0), LIT_CORE * Color(1, 1, 1, flicker))
		draw_rect(Rect2(win.position.x + 8, win.position.y, 2, win.size.y), c.frame)
		draw_rect(Rect2(win.position.x, win.position.y + 7, win.size.x, 2), c.frame)
		draw_circle(win.get_center(), 22.0, Color(LIT, 0.06 * flicker))
	else:
		draw_rect(win, DOOR)
		for i in 3:
			draw_rect(Rect2(win.position.x - 2, win.position.y + 2 + i * 5, win.size.x + 4, 3), BOARD)
	# The house sits in the floor's moss line.
	draw_rect(Rect2(-arch_r - 2, -2, arch_r * 2.0 + 4, 2), c.bark)
