class_name SetPiece
extends Node2D
## A still building or monument from Sean's PixelLab objects (design bible 13.6),
## drawn from its Sheet (packed by tools/art/pixellab_objects.py) behind the
## people in front of it. The origin is the bottom center, on the floor.
##
## The building itself never moves: PixelLab redraws a whole object for each
## frame, so its animations shift the walls (Sean, 2026-11-03). A sheet may still
## animate when Sean hand-edits the frames so only the living parts move (the
## smithy's smoke, forge and lantern, 2026-11-04). Light (a forge's glow, a
## lantern's) is drawn here, over the sprite, at points in world pixels from the origin.

## Room prop names that are set pieces; each is a sheet in assets/sprites/.
const NAMES := ["shop_arms", "shop_sundries", "shop_dyeworks", "shop_cartographer"]
## Living parts per set piece: "fire" (a flickering glow with rising embers),
## "smoke" (puffs that rise, swell and fade), "lamp" (a soft, slow flicker) and
## "light" (only a fire's glow, for a fire the sheet already animates).
const EFFECTS := {
	"shop_arms": [
		{"kind": "light", "at": Vector2(18.5, -27.5)},
		{"kind": "lamp", "at": Vector2(-7.0, -39.5)},
	],
	"shop_sundries": [{"kind": "lamp", "at": Vector2(38.5, -56.5)}],
}
const FIRE := Color(1.0, 0.55, 0.2)
const LAMP := Color(1.0, 0.75, 0.4)
const SMOKE := Color(0.62, 0.6, 0.68)
const EMBER := Color(1.0, 0.7, 0.3)

var sheet := ""
var _t := 0.0
var _glow: Node2D


func _ready() -> void:
	z_index = -2
	if not effects().is_empty():
		_glow = Node2D.new()
		_glow.name = "Glow"
		var mat := CanvasItemMaterial.new()
		mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		_glow.material = mat
		_glow.draw.connect(_draw_glow)
		add_child(_glow)


func effects() -> Array:
	return EFFECTS.get(sheet, [])


func _process(delta: float) -> void:
	if Sheet.get_sheet(sheet).animations.idle.seq.size() > 1 or _glow != null:
		_t += delta
		queue_redraw()
		if _glow != null:
			_glow.queue_redraw()


## How bright a fire or lamp is at time `t`: layered sines, never quite steady.
static func flicker(t: float, seed_value: float) -> float:
	return 0.75 + 0.15 * sin(t * 9.0 + seed_value) + 0.1 * sin(t * 23.0 + seed_value * 2.0)


func _draw() -> void:
	Sheet.draw(self, sheet, "idle", Sheet.frame_at(sheet, "idle", _t))
	for e: Dictionary in effects():
		var at: Vector2 = e.at
		match String(e.kind):
			"smoke":
				for i in 4:
					var k := fmod(_t * 0.35 + i * 0.25, 1.0)
					var p := at + Vector2(sin(k * 5.0 + i) * 2.0 + k * 6.0, -k * 26.0)
					draw_circle(p.round(), 1.5 + k * 3.5, Color(SMOKE, 0.55 * (1.0 - k)))
			"fire":
				for i in 3:
					var k := fmod(_t * 0.8 + i * 0.37, 1.0)
					var p := at + Vector2(sin(k * 7.0 + i * 2.0) * 2.5, -3.0 - k * 9.0)
					draw_rect(Rect2(p.round(), Vector2.ONE), Color(EMBER, 1.0 - k))


func _draw_glow() -> void:
	for e: Dictionary in effects():
		var at: Vector2 = e.at
		match String(e.kind):
			"fire", "light":
				var f := flicker(_t, at.x)
				_glow.draw_circle(at + Vector2(0, -3), 9.0 * f, Color(FIRE, 0.18 * f))
				_glow.draw_circle(at + Vector2(0, -2), 4.5 * f, Color(FIRE, 0.3 * f))
			"lamp":
				var f := flicker(_t * 0.5, at.y)
				_glow.draw_circle(at, 6.0, Color(LAMP, 0.16 * f))
