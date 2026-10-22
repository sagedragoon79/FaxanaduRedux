class_name GameCamera
extends Camera2D
## Follow camera: deadzone, eased look-ahead, look-down, room limits and shake.

const DEADZONE := Vector2(16, 24)
const LOOK_AHEAD := 48.0
const LOOK_AHEAD_EASE := 0.4
const LOOK_DOWN := 72.0
const LOOK_DOWN_DELAY := 0.4
const FOLLOW_SPEED := 10.0
const FOCUS_OFFSET := Vector2(0, -28)

var target: Player

var _focus := Vector2.ZERO
var _look_ahead := 0.0
var _look_down := 0.0
var _down_hold := 0.0


func _ready() -> void:
	position_smoothing_enabled = false
	if target:
		snap_to_target()


func set_room_limits(rect: Rect2) -> void:
	limit_left = int(rect.position.x)
	limit_top = int(rect.position.y)
	limit_right = int(rect.end.x)
	limit_bottom = int(rect.end.y)


func snap_to_target() -> void:
	_focus = target.global_position + FOCUS_OFFSET
	global_position = _focus
	reset_physics_interpolation()


func _physics_process(delta: float) -> void:
	if target == null:
		return
	var p := target.global_position + FOCUS_OFFSET
	# Deadzone: the focus only moves once the player leaves a small box.
	var d := p - _focus
	if absf(d.x) > DEADZONE.x * 0.5:
		_focus.x = p.x - signf(d.x) * DEADZONE.x * 0.5
	if absf(d.y) > DEADZONE.y * 0.5:
		_focus.y = p.y - signf(d.y) * DEADZONE.y * 0.5

	var ahead_goal := target.facing * LOOK_AHEAD
	_look_ahead = lerpf(_look_ahead, ahead_goal, 1.0 - exp(-delta * (3.0 / LOOK_AHEAD_EASE)))

	var still := target.is_on_floor() and absf(target.velocity.x) < 10.0
	_down_hold = _down_hold + delta if (still and target.input.down) else 0.0
	var down_goal := LOOK_DOWN if _down_hold > LOOK_DOWN_DELAY else 0.0
	_look_down = lerpf(_look_down, down_goal, 1.0 - exp(-delta * 6.0))

	var goal := _focus + Vector2(_look_ahead, _look_down)
	global_position = global_position.lerp(goal, 1.0 - exp(-delta * FOLLOW_SPEED))
	offset = Feel.shake_offset
