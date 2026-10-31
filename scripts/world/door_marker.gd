class_name DoorMarker
extends Interactable
## A doorway inside a room (as opposed to an exit at the room's edge). Press Up
## to go through; the World does the transition.

const FRAME := Color("8a5a34")
const FRAME_DARK := Color("5e3b22")
const INSIDE := Color("1d1a2b")

var door := 0
## False under a painted plate, which paints its own doorway (Room._apply_plate).
var framed := true


func _ready() -> void:
	super()
	prompt_height = 48.0
	z_index = -2


func interact(_p: Player) -> void:
	var world := get_tree().get_first_node_in_group("world") as World
	if world != null:
		# Deferred: the player is mid-physics-step and is about to be moved to another room.
		world.call_deferred("use_door", door)


func _draw() -> void:
	if not framed:
		draw_prompt()
		return
	draw_rect(Rect2(-14, -42, 28, 42), FRAME_DARK)
	draw_rect(Rect2(-12, -40, 24, 40), FRAME)
	draw_rect(Rect2(-9, -37, 18, 37), INSIDE)
	draw_circle(Vector2(0, -37), 9.0, INSIDE)
	draw_prompt()
