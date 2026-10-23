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

var _shown_gold := 0.0
var _font: Font


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_font = ThemeDB.fallback_font


func _process(delta: float) -> void:
	if player:
		# The counter rolls up toward the real total, like an arcade score.
		_shown_gold = move_toward(_shown_gold, player.gold, maxf(40.0, absf(player.gold - _shown_gold) * 6.0) * delta)
	queue_redraw()


func _draw() -> void:
	if player == null:
		return
	var origin := Vector2(10, 10)
	var masks := ceili(float(player.max_hp) / MASK_HP)
	for i in masks:
		var p := origin + Vector2(i * 14, 0)
		var fill := clampf(float(player.hp - i * MASK_HP) / MASK_HP, 0.0, 1.0)
		draw_rect(Rect2(p, Vector2(12, 14)), OUTLINE)
		draw_rect(Rect2(p + Vector2(1, 1), Vector2(10, 12)), MASK_EMPTY)
		if fill > 0.0:
			var h := roundf(12.0 * fill)
			draw_rect(Rect2(p + Vector2(1, 13 - h), Vector2(10, h)), MASK_FULL)
			draw_rect(Rect2(p + Vector2(2, 13 - h), Vector2(2, minf(h, 3))), MASK_SHINE)
	# Magic bar.
	var bar := Rect2(origin + Vector2(0, 18), Vector2(masks * 14 - 2, 5))
	draw_rect(bar.grow(1), OUTLINE)
	draw_rect(bar, MP_DARK)
	draw_rect(Rect2(bar.position, Vector2(roundf(bar.size.x * player.mp / player.combat.max_mp), bar.size.y)), MP)
	# Red Potion charges.
	for i in player.combat.flask_charges:
		var p := origin + Vector2(i * 9, 28)
		draw_rect(Rect2(p, Vector2(7, 9)), OUTLINE)
		draw_rect(Rect2(p + Vector2(1, 3), Vector2(5, 5)), POTION if i < player.flask_charges else POTION_EMPTY)
		draw_rect(Rect2(p + Vector2(2, 1), Vector2(3, 2)), Color("c9c4d6"))
	# Gold.
	var gp := origin + Vector2(player.combat.flask_charges * 9 + 6, 28)
	draw_rect(Rect2(gp + Vector2(0, 2), Vector2(6, 6)), OUTLINE)
	draw_rect(Rect2(gp + Vector2(1, 3), Vector2(4, 4)), GOLD)
	draw_string_outline(_font, gp + Vector2(10, 9), str(int(_shown_gold)), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, 3, OUTLINE)
	draw_string(_font, gp + Vector2(10, 9), str(int(_shown_gold)), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, GOLD)
