class_name LoreTablet
extends Interactable
## A carved stone tablet. Press Up to read it.

const STONE := Color("5d5670")
const STONE_DARK := Color("37324a")
const GLYPH := Color("c9b98f")

var text := ""
## [conditions, text] pairs from the room's sign lines, in the order written.
## A line may open with world flags in brackets ("[spring:trunk !boss:x]",
## the same as a person's fourth field): the first line whose flags all hold
## is the one read, and a line with none always holds (pass 251).
var variants: Array = []


## Adds one sign line. Text without brackets is read when no line before it holds.
func add_variant(line: String) -> void:
	line = line.strip_edges()
	var conds := ""
	if line.begins_with("["):
		var close := line.find("]")
		if close > 0:
			conds = line.substr(1, close - 1)
			line = line.substr(close + 1).strip_edges()
	variants.append([conds, line])
	text = current_text()


## What the tablet says now: the first line whose flags hold, else the last.
func current_text() -> String:
	for v: Array in variants:
		if Room.flags_hold(v[0]):
			return v[1]
	return "" if variants.is_empty() else String(variants[-1][1])


func _ready() -> void:
	super()
	prompt_height = 26.0
	z_index = -1


func interact(_p: Player) -> void:
	Sfx.play("tablet_read", 0.04)
	if not variants.is_empty():
		text = current_text()
	GameState.say("", text.split("|"))


func _draw() -> void:
	draw_rect(Rect2(-9, -20, 18, 20), STONE_DARK)
	draw_rect(Rect2(-8, -19, 16, 18), STONE)
	draw_rect(Rect2(-8, -19, 16, 2), STONE.lightened(0.15))
	for i in 4:
		draw_rect(Rect2(-5, -15 + i * 4, 4 + (i * 3) % 7, 1), GLYPH)
	draw_prompt()
