class_name Chest
extends Interactable
## A treasure chest. Press Up to open it; gold sprays out. Stays open for good.

const WOOD := Color("8a5a34")
const WOOD_DARK := Color("5e3b22")
const BAND := Color("c08a1e")
const GLOW := Color("ffe27a")

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


func _draw() -> void:
	if not _open:
		draw_circle(Vector2(0, -8), 13.0 + sin(t * 3.0), Color(GLOW, 0.10))
	draw_rect(Rect2(-10, -12, 20, 12), WOOD_DARK)
	draw_rect(Rect2(-9, -11, 18, 10), WOOD)
	draw_rect(Rect2(-9, -7, 18, 2), BAND)
	if _open:
		draw_rect(Rect2(-10, -20, 20, 5), WOOD_DARK)
		draw_rect(Rect2(-9, -19, 18, 3), WOOD.darkened(0.2))
	else:
		draw_rect(Rect2(-10, -16, 20, 5), WOOD_DARK)
		draw_rect(Rect2(-9, -15, 18, 3), WOOD.lightened(0.1))
		draw_rect(Rect2(-1, -12, 2, 4), GLOW)
	draw_prompt()
