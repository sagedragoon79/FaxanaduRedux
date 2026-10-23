class_name GameCamera
extends Camera2D
## Follow camera: deadzone, eased look-ahead, look-down, room bounds and shake.
##
## Smooth scrolling with crisp pixels (design bible 12.1): the world renders in
## a pixel-sized viewport, the camera itself sits on whole pixels, and the
## leftover fraction is exposed as `subpixel` so the game can shift the upscaled
## image by it. The camera runs every rendered frame, interpolating the target
## between physics ticks, so motion stays smooth on high refresh rate displays.

const DEADZONE := Vector2(16, 24)
const LOOK_AHEAD := 48.0
const LOOK_AHEAD_EASE := 0.4
const LOOK_DOWN := 72.0
const LOOK_DOWN_DELAY := 0.4
const FOLLOW_SPEED := 10.0
const FOCUS_OFFSET := Vector2(0, -28)

var target: Player
## Size of the visible area in world pixels (the base resolution).
var view_size := Vector2(640, 360)
var bounds := Rect2()
## Fractional part of the camera position, in world pixels, in [0, 1).
var subpixel := Vector2.ZERO
## The unrounded camera center.
var exact_position := Vector2.ZERO

var _prev_target := Vector2.ZERO
var _curr_target := Vector2.ZERO
var _focus := Vector2.ZERO
var _look_ahead := 0.0
var _look_down := 0.0
var _down_hold := 0.0


func _init() -> void:
	# Must be set before entering the tree, or Godot forces physics-tick updates.
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	process_callback = Camera2D.CAMERA2D_PROCESS_IDLE


func _ready() -> void:
	position_smoothing_enabled = false
	if target:
		snap_to_target()


func set_room_limits(rect: Rect2) -> void:
	bounds = rect


func snap_to_target() -> void:
	_curr_target = target.global_position
	_prev_target = _curr_target
	_focus = _curr_target + FOCUS_OFFSET
	exact_position = _clamp_to_bounds(_focus)
	_apply(exact_position)


func _physics_process(delta: float) -> void:
	if target == null:
		return
	_prev_target = _curr_target
	_curr_target = target.global_position
	var still := target.is_on_floor() and absf(target.velocity.x) < 10.0
	_down_hold = _down_hold + delta if (still and target.input.down) else 0.0


func _process(delta: float) -> void:
	if target == null:
		return
	var t := _prev_target.lerp(_curr_target, Engine.get_physics_interpolation_fraction())
	if _curr_target.distance_to(_prev_target) > 64.0:
		t = _curr_target  # teleported; don't sweep across the room
	var p := t + FOCUS_OFFSET
	# Deadzone: the focus only moves once the player leaves a small box.
	var d := p - _focus
	if absf(d.x) > DEADZONE.x * 0.5:
		_focus.x = p.x - signf(d.x) * DEADZONE.x * 0.5
	if absf(d.y) > DEADZONE.y * 0.5:
		_focus.y = p.y - signf(d.y) * DEADZONE.y * 0.5

	_look_ahead = lerpf(_look_ahead, target.facing * LOOK_AHEAD, 1.0 - exp(-delta * (3.0 / LOOK_AHEAD_EASE)))
	var down_goal := LOOK_DOWN if _down_hold > LOOK_DOWN_DELAY else 0.0
	_look_down = lerpf(_look_down, down_goal, 1.0 - exp(-delta * 6.0))

	var goal := _clamp_to_bounds(_focus + Vector2(_look_ahead, _look_down))
	exact_position = exact_position.lerp(goal, 1.0 - exp(-delta * FOLLOW_SPEED))
	_apply(exact_position + Feel.shake_offset)


func _apply(exact: Vector2) -> void:
	var whole := exact.floor()
	subpixel = exact - whole
	global_position = whole


func _clamp_to_bounds(c: Vector2) -> Vector2:
	if bounds.size == Vector2.ZERO:
		return c
	var half := view_size * 0.5
	var lo := bounds.position + half
	var hi := bounds.end - half
	return Vector2(
		clampf(c.x, lo.x, maxf(lo.x, hi.x)),
		clampf(c.y, lo.y, maxf(lo.y, hi.y))
	)
