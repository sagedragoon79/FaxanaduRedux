class_name Chest
extends Interactable
## A treasure chest. Press Up to open it; gold sprays out. Stays open for good.

const WOOD := Color("8a5a34")
const WOOD_DARK := Color("5e3b22")
const BAND := Color("c08a1e")
const GLOW := Color("ffe27a")
const OUTLINE := Color("120f19")
const WOOD_LIGHT := Color("b07a48")
const BAND_LIGHT := Color("ffd24a")
const IRON := Color("4a4560")
const IRON_LIGHT := Color("7a7296")

var pickup_id := ""
var value := 100

var _open := false


func _ready() -> void:
	super()
	prompt_height = 26.0
	z_index = -1
	if pickup_id != "" and GameState.is_collected(pickup_id):
		_open = true
		remove_from_group("interactable")


func interact(_p: Player) -> void:
	if _open:
		return
	_open = true
	remove_from_group("interactable")
	if pickup_id != "":
		GameState.collect(pickup_id)
	Coin.spray(get_parent(), global_position + Vector2(0, -12), value)
	Sfx.play("chest", 0.0)
	Feel.hitstop(0.05)
	var d := Dust.new()
	d.setup("parry")
	get_parent().add_child(d)
	d.global_position = global_position + Vector2(0, -12)


func is_open() -> bool:
	return _open


## Drawn at 2x render density: `_px` takes half-pixels.
func _draw() -> void:
	if not _open:
		draw_circle(Vector2(0, -8), 13.0 + sin(t * 3.0), Color(GLOW, 0.10))
	# The box: planks with grain, iron corners, a brass band.
	_px(-21, -25, 42, 25, OUTLINE)
	_px(-19, -23, 38, 22, WOOD)
	for i in 3:
		_px(-19, -21 + i * 7, 38, 1, WOOD_DARK)
	_px(-19, -23, 38, 1, WOOD_LIGHT)
	_px(-19, -14, 38, 4, BAND)
	_px(-19, -14, 38, 1, BAND_LIGHT)
	for x: int in [-19, 15]:
		_px(x, -23, 4, 22, IRON)
		_px(x + 1, -21, 2, 2, IRON_LIGHT)
		_px(x + 1, -6, 2, 2, IRON_LIGHT)
	if _open:
		# The lid thrown back, the inside dark with a glint of what was left.
		_px(-21, -40, 42, 11, OUTLINE)
		_px(-19, -38, 38, 8, WOOD_DARK)
		_px(-19, -38, 38, 1, WOOD)
		_px(-17, -29, 34, 4, Color("1d1410"))
		_px(-9, -28, 2, 1, BAND_LIGHT)
		_px(5, -27, 2, 1, BAND)
	else:
		# The domed lid and the lock plate, its keyhole glowing.
		_px(-21, -33, 42, 9, OUTLINE)
		_px(-19, -31, 38, 7, WOOD)
		_px(-17, -33, 34, 2, OUTLINE)
		_px(-17, -31, 34, 1, WOOD_LIGHT)
		_px(-19, -25, 38, 1, WOOD_DARK)
		for x: int in [-19, 15]:
			_px(x, -31, 4, 7, IRON)
		_px(-4, -26, 8, 9, OUTLINE)
		_px(-3, -25, 6, 7, BAND)
		_px(-3, -25, 6, 1, BAND_LIGHT)
		var k := 0.6 + 0.4 * sin(t * 4.0)
		_px(-1, -23, 2, 3, Color(GLOW, k))
	draw_prompt()


func _px(x: int, y: int, w: int, h: int, color: Color) -> void:
	draw_rect(Rect2(x * 0.5, y * 0.5, w * 0.5, h * 0.5), color)
