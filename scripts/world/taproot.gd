class_name Taproot
extends Node2D
## The World Tree's taproot (Taproot Vault, a Trunk Hollows landmark): a vast
## root running from the ceiling into the floor, gnawed half through by
## Rokusutahn, oozing sap from the bites. Once the Spring of Trunk is restored
## the sap in it runs again: amber veins pulse up the root and the bites close
## over with fresh wood. Scenery only. The origin is the bottom center.

const HEIGHT := 336.0
const HALF_WIDTH := 52.0
const BARK := Color("48201e")
const BARK_LIGHT := Color("783c2b")
const BARK_DARK := Color("2c1418")
const HEART := Color("cd8c51")
const HEART_DARK := Color("aa6336")
const SAP := Color("e0902a")
const LIT := Color("f0c02e")
const OUTLINE := Color("120f19")
## Bites on the root: (height above the floor, side, radius).
const BITES := [[210.0, 1, 26.0], [128.0, -1, 20.0], [70.0, 1, 16.0]]

var healed_flag := "spring:trunk"
var _t := 0.0


func _ready() -> void:
	z_index = -2


func healed() -> bool:
	return GameState.flag(healed_flag)


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


## The root's edges at height `h` above the floor: [left, right] in pixels.
func edges(h: float) -> Vector2:
	# Wider where it meets the floor, with a slow organic wobble.
	var flare := maxf(0.0, 40.0 - h) * 0.9
	var w := HALF_WIDTH + flare + sin(h * 0.031) * 4.0
	var shift := sin(h * 0.012 + 1.0) * 6.0
	var l := -w + shift
	var r := w + shift
	if not healed():
		for b: Array in BITES:
			var dy := h - float(b[0])
			var rad: float = b[2]
			if absf(dy) < rad:
				var depth := sqrt(rad * rad - dy * dy)
				if int(b[1]) > 0:
					r -= depth
				else:
					l += depth
	return Vector2(roundf(l), roundf(r))


func _draw() -> void:
	var y := 0.0
	while y < HEIGHT:
		var e := edges(y)
		var row := -y - 2.0
		draw_rect(Rect2(e.x - 1, row, e.y - e.x + 2, 2), OUTLINE)
		draw_rect(Rect2(e.x, row, e.y - e.x, 2), BARK)
		draw_rect(Rect2(e.x, row, 3, 2), BARK_LIGHT)
		draw_rect(Rect2(e.y - 4, row, 3, 2), BARK_DARK)
		# Grooves running down the bark.
		for g in 5:
			var gx := lerpf(e.x + 8, e.y - 8, (g + 0.5) / 5.0) + sin(y * 0.05 + g * 1.7) * 3.0
			draw_rect(Rect2(roundf(gx), row, 2, 2), BARK_DARK)
		y += 2.0
	if healed():
		_draw_veins()
	else:
		_draw_bites()


## The bitten faces show pale heartwood, with sap seeping and dripping.
func _draw_bites() -> void:
	for b: Array in BITES:
		var h: float = b[0]
		var side: int = b[1]
		var rad: float = b[2]
		var y := -rad
		while y <= rad:
			var hy := h + y
			var e := edges(hy)
			var x := e.y if side > 0 else e.x
			var w := 5.0
			draw_rect(Rect2(x - w if side > 0 else x, -hy - 2, w, 2), HEART)
			draw_rect(Rect2(x - 2 if side > 0 else x, -hy - 2, 2, 2), HEART_DARK)
			y += 2.0
		# Tooth marks.
		for i in 3:
			var ty := h - rad * 0.5 + i * rad * 0.5
			var e := edges(ty)
			var tx := e.y - 7 if side > 0 else e.x + 5
			draw_rect(Rect2(tx, -ty - 1, 2, 3), HEART_DARK)
		# A drip of sap gathering and falling from the bottom of the bite.
		var phase := fmod(_t * 0.5 + h * 0.01, 1.0)
		var e0 := edges(h - rad + 2.0)
		var dx := (e0.y - 3.0) if side > 0 else (e0.x + 1.0)
		var drop_y := -(h - rad) + phase * phase * 60.0
		draw_rect(Rect2(dx, -(h - rad) - 2, 3, 4), SAP)
		draw_rect(Rect2(dx, drop_y, 2, 3), Color(SAP, 1.0 - phase))


## After the spring: amber light climbing the grooves.
func _draw_veins() -> void:
	for g in 5:
		var y := 0.0
		while y < HEIGHT:
			var e := edges(y)
			var gx := lerpf(e.x + 8, e.y - 8, (g + 0.5) / 5.0) + sin(y * 0.05 + g * 1.7) * 3.0
			var pulse := 0.5 + 0.5 * sin(y * 0.04 - _t * 3.0 + g)
			draw_rect(Rect2(roundf(gx), -y - 2, 2, 2), Color(LIT, 0.25 + 0.6 * pulse * pulse))
			y += 2.0
