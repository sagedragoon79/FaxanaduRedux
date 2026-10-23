class_name GameHud
extends Control
## In-game HUD drawn in code at the 640x360 base resolution: health masks,
## magic bar, Red Potion charges and gold. Rendered at native resolution
## (outside the pixel-art viewport) so it stays sharp.

const MASK_HP := 20
const OUTLINE := Color("1d1a2b")
const MASK_FULL := Color("f1ead2")
const MASK_EMPTY := Color("3a344c")
const MASK_SHINE := Color("ffffff")
const MP := Color("4aa3df")
const MP_DARK := Color("23385e")
const POTION := Color("e0404a")
const POTION_EMPTY := Color("4a2a34")
const GOLD := Color("ffd24a")

var player: Player

const BANNER_TIME := 3.2
const TOAST_TIME := 2.2

var _shown_gold := 0.0
var _font: Font
var _banner_title := ""
var _banner_sub := ""
var _banner_t := 0.0
var _toast := ""
var _toast_t := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_font = ThemeDB.fallback_font
	GameState.banner.connect(show_banner)
	GameState.toast.connect(show_toast)


func show_banner(title: String, subtitle: String) -> void:
	_banner_title = title
	_banner_sub = subtitle
	_banner_t = BANNER_TIME


func show_toast(text: String) -> void:
	_toast = text
	_toast_t = TOAST_TIME


func _process(delta: float) -> void:
	_banner_t = maxf(_banner_t - delta, 0.0)
	_toast_t = maxf(_toast_t - delta, 0.0)
	if player:
		# The counter rolls up toward the real total, like an arcade score.
		_shown_gold = move_toward(_shown_gold, player.gold, maxf(40.0, absf(player.gold - _shown_gold) * 6.0) * delta)
	queue_redraw()


func _draw() -> void:
	if player == null:
		return
	var origin := Vector2(10, 10)
	var masks := ceili(float(player.max_hp) / MASK_HP)
	var mask_x := 0.0
	for i in masks:
		# The last container is narrower when a Life Fruit has added half a mask.
		var cap := clampf(float(player.max_hp - i * MASK_HP) / MASK_HP, 0.0, 1.0)
		var w := 12.0 if cap >= 1.0 else 7.0
		var p := origin + Vector2(mask_x, 0)
		mask_x += w + 2.0
		var fill := clampf(float(player.hp - i * MASK_HP) / (MASK_HP * cap), 0.0, 1.0)
		draw_rect(Rect2(p, Vector2(w, 14)), OUTLINE)
		draw_rect(Rect2(p + Vector2(1, 1), Vector2(w - 2, 12)), MASK_EMPTY)
		if fill > 0.0:
			var h := roundf(12.0 * fill)
			draw_rect(Rect2(p + Vector2(1, 13 - h), Vector2(w - 2, h)), MASK_FULL)
			draw_rect(Rect2(p + Vector2(2, 13 - h), Vector2(2, minf(h, 3))), MASK_SHINE)
	# Magic bar.
	var bar := Rect2(origin + Vector2(0, 18), Vector2(maxf(mask_x - 2.0, player.max_mp), 5))
	draw_rect(bar.grow(1), OUTLINE)
	draw_rect(bar, MP_DARK)
	draw_rect(Rect2(bar.position, Vector2(roundf(bar.size.x * player.mp / player.max_mp), bar.size.y)), MP)
	# Red Potion charges.
	for i in player.flask_max:
		var p := origin + Vector2(i * 9, 28)
		draw_rect(Rect2(p, Vector2(7, 9)), OUTLINE)
		draw_rect(Rect2(p + Vector2(1, 3), Vector2(5, 5)), POTION if i < player.flask_charges else POTION_EMPTY)
		draw_rect(Rect2(p + Vector2(2, 1), Vector2(3, 2)), Color("c9c4d6"))
	# Gold.
	var gp := origin + Vector2(player.flask_max * 9 + 6, 28)
	draw_rect(Rect2(gp + Vector2(0, 2), Vector2(6, 6)), OUTLINE)
	draw_rect(Rect2(gp + Vector2(1, 3), Vector2(4, 4)), GOLD)
	draw_string_outline(_font, gp + Vector2(10, 9), str(int(_shown_gold)), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, 3, OUTLINE)
	draw_string(_font, gp + Vector2(10, 9), str(int(_shown_gold)), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, GOLD)
	_draw_messages()


## Fades in fast, holds, fades out over the last half second.
static func _envelope(t_left: float, total: float) -> float:
	return clampf(minf((total - t_left) / 0.2, t_left / 0.5), 0.0, 1.0)


func _draw_messages() -> void:
	var w := get_viewport_rect().size.x
	if _banner_t > 0.0:
		var a := _envelope(_banner_t, BANNER_TIME)
		var band := Rect2(0, 96, w, 50 if _banner_sub != "" else 34)
		draw_rect(band, Color(0.07, 0.06, 0.11, 0.75 * a))
		draw_rect(Rect2(band.position, Vector2(w, 1)), Color(GOLD, 0.6 * a))
		draw_rect(Rect2(band.position + Vector2(0, band.size.y - 1), Vector2(w, 1)), Color(GOLD, 0.6 * a))
		_centered(_banner_title, 124, 18, Color(MASK_FULL, a))
		if _banner_sub != "":
			_centered(_banner_sub, 140, 10, Color(Color("c9b98f"), a))
	if _toast_t > 0.0:
		var a := _envelope(_toast_t, TOAST_TIME)
		_centered(_toast, 330, 10, Color(MASK_FULL, a))


func _centered(text: String, y: float, size: int, color: Color) -> void:
	var w := get_viewport_rect().size.x
	var tw := _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var pos := Vector2(roundf((w - tw) * 0.5), y)
	draw_string_outline(_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 3, Color(OUTLINE, color.a))
	draw_string(_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
