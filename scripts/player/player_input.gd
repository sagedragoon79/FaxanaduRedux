class_name PlayerInput
extends RefCounted
## One frame of player intent. Reads the real input map, or is driven by tests
## (scripted = true), so the controller never touches Input directly.

var scripted := false

var move_x := 0
## How far the stick leans that way, 0 to 1 past its deadzone (pass 183): a
## light tilt walks, a full one runs. Keys and the d-pad are always 1.
var tilt := 1.0
var up := false
var up_pressed := false
var down := false
var jump_pressed := false
var jump_held := false
var attack_pressed := false
var attack_held := false
var dash_pressed := false
var block_pressed := false
var block_held := false
var spell_pressed := false
var spell_next_pressed := false
var heal_pressed := false
var hourglass_pressed := false


func poll() -> void:
	if scripted:
		return
	var axis := Input.get_axis("move_left", "move_right")
	move_x = int(signf(axis))
	tilt = absf(axis) if move_x != 0 else 1.0
	up = Input.is_action_pressed("move_up")
	up_pressed = Input.is_action_just_pressed("move_up")
	down = Input.is_action_pressed("move_down")
	jump_pressed = Input.is_action_just_pressed("jump")
	jump_held = Input.is_action_pressed("jump")
	attack_pressed = Input.is_action_just_pressed("attack")
	attack_held = Input.is_action_pressed("attack")
	dash_pressed = Input.is_action_just_pressed("dash")
	block_pressed = Input.is_action_just_pressed("block")
	block_held = Input.is_action_pressed("block")
	spell_pressed = Input.is_action_just_pressed("spell")
	spell_next_pressed = Input.is_action_just_pressed("spell_next")
	heal_pressed = Input.is_action_just_pressed("heal")
	hourglass_pressed = Input.is_action_just_pressed("hourglass")


## Called by the player after it has consumed this frame. Scripted presses last one frame.
func end_frame() -> void:
	if scripted:
		up_pressed = false
		jump_pressed = false
		attack_pressed = false
		dash_pressed = false
		block_pressed = false
		spell_pressed = false
		spell_next_pressed = false
		heal_pressed = false
		hourglass_pressed = false


## Clears everything (used when control is taken away, e.g. on death).
func clear() -> void:
	move_x = 0
	tilt = 1.0
	up = false
	down = false
	jump_held = false
	attack_held = false
	block_held = false
	end_frame()
