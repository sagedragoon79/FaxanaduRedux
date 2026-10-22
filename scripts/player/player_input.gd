class_name PlayerInput
extends RefCounted
## One frame of player intent. Reads the real input map, or is driven by tests
## (scripted = true), so the controller never touches Input directly.

var scripted := false

var move_x := 0
var up := false
var down := false
var jump_pressed := false
var jump_held := false
var attack_pressed := false
var dash_pressed := false


func poll() -> void:
	if scripted:
		return
	move_x = int(signf(Input.get_axis("move_left", "move_right")))
	up = Input.is_action_pressed("move_up")
	down = Input.is_action_pressed("move_down")
	jump_pressed = Input.is_action_just_pressed("jump")
	jump_held = Input.is_action_pressed("jump")
	attack_pressed = Input.is_action_just_pressed("attack")
	dash_pressed = Input.is_action_just_pressed("dash")


## Called by the player after it has consumed this frame. Scripted presses last one frame.
func end_frame() -> void:
	if scripted:
		jump_pressed = false
		attack_pressed = false
		dash_pressed = false
