class_name Fountain
extends Node2D
## The Fountain of Hearthroot: its water level shows how many of the three springs
## are restored (design bible 4.4). The origin is the bottom center.
## Drawn from Sean's PixelLab sheet (one state per spring, packed by
## tools/art/pixellab_objects.py); the code drawing below is the fallback.

const SPRINGS := ["heartwood", "haar", "sky"]
const WIDTH := 140.0
const STONE := Color("8d84a3")
const STONE_DARK := Color("4a4458")
const STONE_LIGHT := Color("c9c4d6")
const WATER := Color(0.49, 0.77, 0.94, 0.85)
const WATER_LIGHT := Color("d8f1ff")
const DRY := Color("5a4a3a")
## The sheet's animation for each fountain level.
const STATES := ["dry", "third", "two_thirds", "full"]
const SHEET := "fountain"

var _t := 0.0


func _ready() -> void:
	z_index = -1


static func level() -> int:
	var n := 0
	for s: String in SPRINGS:
		if GameState.flag("spring:" + s):
			n += 1
	return n


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


## The sheet animation for the current level.
static func state() -> String:
	return STATES[level()]


func _draw() -> void:
	if Sheet.exists(SHEET):
		Sheet.draw(self, SHEET, state(), Sheet.frame_at(SHEET, state(), _t))
		return
	var w := WIDTH
	var fill := level() / 3.0
	# Basin wall and bed.
	draw_rect(Rect2(-w * 0.5, -22, w, 22), STONE_DARK)
	draw_rect(Rect2(-w * 0.5 + 4, -18, w - 8, 16), DRY)
	if fill > 0.0:
		var h := 14.0 * fill
		draw_rect(Rect2(-w * 0.5 + 4, -2 - h, w - 8, h), WATER)
		draw_rect(Rect2(-w * 0.5 + 4, -2 - h, w - 8, 1), WATER_LIGHT)
	draw_rect(Rect2(-w * 0.5 - 2, -24, w + 4, 4), STONE)
	draw_rect(Rect2(-w * 0.5 - 2, -24, w + 4, 1), STONE_LIGHT)
	# Central column and bowl.
	draw_rect(Rect2(-6, -64, 12, 42), STONE)
	draw_rect(Rect2(-6, -64, 3, 42), STONE_LIGHT)
	draw_rect(Rect2(-26, -70, 52, 6), STONE)
	draw_rect(Rect2(-26, -70, 52, 1), STONE_LIGHT)
	if fill > 0.0:
		# Streams falling from the bowl, stronger with each spring.
		for side: int in [-1, 1]:
			for i in level():
				var x := side * (20.0 - i * 5.0)
				var wob := sin(_t * 10.0 + i) * 0.6
				draw_rect(Rect2(x - 1 + wob, -64, 2, 44 - 14.0 * fill), WATER)
		var k := fmod(_t, 1.0)
		draw_arc(Vector2(0, -2 - 14.0 * fill), 10.0 + k * 40.0, PI, TAU, 16, Color(WATER_LIGHT, 0.5 * (1.0 - k)), 1.0)
