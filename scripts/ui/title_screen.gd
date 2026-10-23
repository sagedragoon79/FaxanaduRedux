class_name TitleScreen
extends Control
## The title backdrop: Eolis's distant houses and the Trunk's hanging roots
## drifting by, falling spores, and the logo. The menu itself is the shared
## ListMenu, drawn on top.

const FAR := "res://assets/bg/eolis_far.png"
const MID := "res://assets/bg/trunk_mid.png"
const GOLD := Color("f0c02e")
const GOLD_LIGHT := Color("f7f1de")
const OUTLINE := Color("120f19")
const SUB := Color("cec5d3")
const SPORES := 40

var _far: Texture2D
var _mid: Texture2D
var _font: Font
var _t := 0.0
var _spores: Array = []
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	process_mode = Node.PROCESS_MODE_ALWAYS
	_font = ThemeDB.fallback_font
	_far = load(FAR) if ResourceLoader.exists(FAR) else null
	_mid = load(MID) if ResourceLoader.exists(MID) else null
	_rng.seed = 7
	for i in SPORES:
		_spores.append([Vector2(_rng.randf() * 640.0, _rng.randf() * 360.0), _rng.randf_range(4.0, 14.0), _rng.randf() * TAU])


func _process(delta: float) -> void:
	if not visible:
		return
	_t += delta
	for s: Array in _spores:
		s[0].y += s[1] * delta
		s[0].x += sin(_t * 0.8 + s[2]) * 6.0 * delta
		if s[0].y > 362.0:
			s[0] = Vector2(_rng.randf() * 640.0, -2.0)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), OUTLINE)
	_layer(_far, 4.0, 0.0)
	_layer(_mid, 11.0, -30.0)
	# Darken the lower half so the menu reads.
	for i in 12:
		draw_rect(Rect2(0, 180 + i * 15, 640, 15), Color(OUTLINE, 0.06 * i))
	for s: Array in _spores:
		var a := 0.4 + 0.4 * sin(_t * 2.0 + s[2])
		draw_rect(Rect2((s[0] as Vector2).round(), Vector2(1, 1)), Color(0.71, 0.89, 0.88, a))
	_logo(Vector2(320, 78))


func _layer(tex: Texture2D, speed: float, y: float) -> void:
	if tex == null:
		return
	var w := tex.get_width()
	var x := -fmod(_t * speed, w)
	while x < 640:
		draw_texture(tex, Vector2(roundf(x), y))
		x += w


func _logo(center: Vector2) -> void:
	var title := "FAXANADU"
	var size := 44
	var w := _font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var pos := Vector2(roundf(center.x - w * 0.5), center.y)
	# A drop shadow, then the letters; they brighten and dim slowly.
	draw_string(_font, pos + Vector2(0, 3), title, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color("542512"))
	draw_string(_font, pos, title, HORIZONTAL_ALIGNMENT_LEFT, -1, size, GOLD.lerp(GOLD_LIGHT, 0.12 + 0.12 * sin(_t * 1.3)))
	var sub := "R  E  D  U  X"
	var sw := _font.get_string_size(sub, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
	var sp := Vector2(roundf(center.x - sw * 0.5), center.y + 24)
	draw_string_outline(_font, sp, sub, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, 4, OUTLINE)
	draw_string(_font, sp, sub, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, SUB)
	draw_rect(Rect2(center.x - 90, center.y + 32, 180, 1), Color(GOLD, 0.6))
