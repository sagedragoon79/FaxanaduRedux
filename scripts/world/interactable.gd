class_name Interactable
extends Node2D
## Base for things the player uses by pressing Up next to them (shrines, signs,
## doors, chests, NPCs). Shows a bobbing prompt while the player is in reach.
## Subclasses override `interact()` and call `draw_prompt()` from `_draw()`.

const PROMPT := Color("f1ead2")
const PROMPT_OUTLINE := Color("1d1a2b")

## Height above the origin (the feet) where the prompt floats.
var prompt_height := 44.0
var near := false
var t := 0.0


func _ready() -> void:
	add_to_group("interactable")


func _process(delta: float) -> void:
	t += delta
	var p := get_tree().get_first_node_in_group("player") as Player
	near = p != null and not p.dead and is_in_group("interactable") and p.can_reach(self)
	queue_redraw()


func interact(_p: Player) -> void:
	pass


func draw_prompt() -> void:
	if not near:
		return
	var y := -prompt_height - 6.0 + roundf(sin(t * 5.0) * 1.5)
	draw_colored_polygon(PackedVector2Array([Vector2(-5, y + 4), Vector2(0, y - 2), Vector2(5, y + 4)]), PROMPT_OUTLINE)
	draw_colored_polygon(PackedVector2Array([Vector2(-3, y + 3), Vector2(0, y), Vector2(3, y + 3)]), PROMPT)
