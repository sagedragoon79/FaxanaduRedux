class_name LoreTablet
extends Interactable
## A carved stone tablet. Press Up to read it.

const STONE := Color("5d5670")
const STONE_DARK := Color("37324a")
const GLYPH := Color("c9b98f")

var text := ""


func _ready() -> void:
	super()
	prompt_height = 26.0
	z_index = -1


func interact(_p: Player) -> void:
	Sfx.play("door", 0.0, -4.0)
	GameState.say("", text.split("|"))


func _draw() -> void:
	draw_rect(Rect2(-9, -20, 18, 20), STONE_DARK)
	draw_rect(Rect2(-8, -19, 16, 18), STONE)
	draw_rect(Rect2(-8, -19, 16, 2), STONE.lightened(0.15))
	for i in 4:
		draw_rect(Rect2(-5, -15 + i * 4, 4 + (i * 3) % 7, 1), GLYPH)
	draw_prompt()
