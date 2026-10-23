class_name GoldPurse
extends Node2D
## The gold you drop on death. Touch it to get it back; die again first and it's gone.

const GLOW := Color("ffe27a")
const BAG := Color("8a5a34")
const BAG_DARK := Color("5e3b22")
const TIE := Color("ffd24a")
const OUTLINE := Color("120f19")

var value := 0

var _t := 0.0


func _ready() -> void:
	z_index = 1
	add_to_group("purse")


func _physics_process(delta: float) -> void:
	_t += delta
	var p := get_tree().get_first_node_in_group("player") as Player
	if p != null and not p.dead and not p.frozen and p.body_rect().grow(4.0).has_point(global_position + Vector2(0, -6)):
		p.add_gold(value)
		Sfx.play("coin", 0.0, 2.0)
		var d := Dust.new()
		d.setup("parry")
		get_parent().add_child(d)
		d.global_position = global_position + Vector2(0, -6)
		if p.purse == self:
			p.purse = null
		GameState.data.purse = {}
		queue_free()
		return
	queue_redraw()


## Drawn at 2x render density: `_px` takes half-pixels.
func _draw() -> void:
	var bob := roundf(sin(_t * 3.0) * 4.0)
	draw_circle(Vector2(0, -6 + bob * 0.5), 10.0 + sin(_t * 4.0), Color(GLOW, 0.18))
	# A leather pouch bulging with coin, tied off with gold cord.
	_px(-11, -18 + bob, 22, 17, OUTLINE)
	_px(-13, -13 + bob, 26, 11, OUTLINE)
	_px(-9, -17 + bob, 18, 15, BAG)
	_px(-11, -12 + bob, 22, 9, BAG)
	_px(-9, -4 + bob, 18, 2, BAG_DARK)
	_px(7, -12 + bob, 4, 8, BAG_DARK)
	_px(-8, -14 + bob, 3, 5, BAG.lightened(0.25))
	_px(-6, -24 + bob, 12, 7, OUTLINE)
	_px(-4, -23 + bob, 8, 5, BAG)
	_px(-6, -19 + bob, 12, 3, TIE)
	_px(-6, -19 + bob, 12, 1, Color("fff4c0"))
	_px(1, -16 + bob, 2, 4, TIE)
	_px(-2, -9 + bob, 4, 4, TIE)
	_px(-1, -8 + bob, 2, 2, BAG_DARK)


func _px(x: float, y: float, w: float, h: float, color: Color) -> void:
	draw_rect(Rect2(x * 0.5, y * 0.5, w * 0.5, h * 0.5), color)
