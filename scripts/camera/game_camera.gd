class_name GameCamera
extends Camera2D
## Follow camera: deadzone, eased look-ahead, look-down and look-up, a lead up
## or down a ladder, room bounds and shake.
##
## Smooth scrolling with crisp pixels (design bible 12.1): the world renders in
## a pixel-sized viewport, the camera itself sits on whole pixels, and the
## leftover fraction is exposed as `subpixel` so the game can shift the upscaled
## image by it. The camera runs every rendered frame, interpolating the target
## between physics ticks, so motion stays smooth on high refresh rate displays.

## Render pixels per world pixel (design bible 12.1). The world keeps its
## 640x360 units; at 2 the camera zooms in on a 1280x720 render, so sprites
## drawn at double density (Sheet "density") show their full detail.
const DETAIL := 2
const DEADZONE := Vector2(16, 24)
const LOOK_AHEAD := 48.0
const LOOK_AHEAD_EASE := 0.4
const LOOK_DOWN := 72.0
const LOOK_DOWN_DELAY := 0.4
## Holding Up while standing still looks up (pass 133), after the same delay.
## On a ladder Up climbs instead, and the climb lead takes over.
const LOOK_UP := 72.0
## On a ladder (design bible 6.7, pass 130) the camera leads the way you climb
## and stops looking sideways; hanging still keeps the lead you had.
const CLIMB_LEAD := 64.0
const CLIMB_LEAD_EASE := 0.5
const FOLLOW_SPEED := 10.0
const FOCUS_OFFSET := Vector2(0, -28)
## A wide room (header `camera: wide`, design bible 6.7) is framed at this
## scale: the world shows 25% more of the room each way.
const WIDE := 0.8
## Seconds the zoom takes to ease most of the way to a new room's framing.
const ZOOM_EASE := 0.6

var target: Player
## Size of the visible area in world pixels at the normal framing.
var view_size := Vector2(640, 360)
var bounds := Rect2()
## The framing now: 1 is normal, below 1 shows more of the world (WIDE).
var frame_scale := 1.0
## The framing the camera eases toward (set_room_limits).
var frame_goal := 1.0
## Fractional part of the camera position below one render pixel, in screen
## pixels (world pixels at the normal framing), in [0, 1 / DETAIL).
var subpixel := Vector2.ZERO
## The unrounded camera center.
var exact_position := Vector2.ZERO

var _prev_target := Vector2.ZERO
var _curr_target := Vector2.ZERO
var _focus := Vector2.ZERO
var _look_ahead := 0.0
var _look_down := 0.0
var _down_hold := 0.0
var _up_hold := 0.0
var _climb_lead := 0.0
var _climb_goal := 0.0


func _init() -> void:
	# Must be set before entering the tree, or Godot forces physics-tick updates.
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	process_callback = Camera2D.CAMERA2D_PROCESS_IDLE


func _ready() -> void:
	zoom = Vector2(DETAIL, DETAIL) * frame_scale
	position_smoothing_enabled = false
	if target:
		snap_to_target()


## Sets the room's bounds and framing. A wide room eases out to WIDE, but
## never so far that the view would show past the room's edges.
func set_room_limits(rect: Rect2, wide := false) -> void:
	bounds = rect
	frame_goal = 1.0
	if wide and rect.size != Vector2.ZERO:
		var fits := maxf(view_size.x / rect.size.x, view_size.y / rect.size.y)
		frame_goal = clampf(maxf(WIDE, fits), WIDE, 1.0)
	if frame_goal > frame_scale:
		# Out of a wide room into a normal one: frame it at once, or the view
		# would show past the smaller room's edges while it eased in.
		frame_scale = frame_goal


## The visible area in world pixels at the current framing.
func visible_size() -> Vector2:
	return view_size / frame_scale


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
	var looking_up := still and target.input.up and not target.input.down and not target.on_ladder
	_up_hold = _up_hold + delta if looking_up else 0.0


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

	if not target.on_ladder:
		_climb_goal = 0.0
	elif absf(target.velocity.y) > 1.0:
		_climb_goal = signf(target.velocity.y) * CLIMB_LEAD
	_climb_lead = lerpf(_climb_lead, _climb_goal, 1.0 - exp(-delta * (3.0 / CLIMB_LEAD_EASE)))
	var ahead_goal := 0.0 if target.on_ladder else target.facing * LOOK_AHEAD
	_look_ahead = lerpf(_look_ahead, ahead_goal, 1.0 - exp(-delta * (3.0 / LOOK_AHEAD_EASE)))
	var down_goal := 0.0
	if _down_hold > LOOK_DOWN_DELAY:
		down_goal = LOOK_DOWN
	elif _up_hold > LOOK_DOWN_DELAY:
		down_goal = -LOOK_UP
	_look_down = lerpf(_look_down, down_goal, 1.0 - exp(-delta * 6.0))

	if frame_scale != frame_goal:
		frame_scale = move_toward(lerpf(frame_scale, frame_goal, 1.0 - exp(-delta * (3.0 / ZOOM_EASE))), frame_goal, 0.0005)
		zoom = Vector2(DETAIL, DETAIL) * frame_scale
	var goal := _clamp_to_bounds(_focus + Vector2(_look_ahead, _look_down + _climb_lead))
	exact_position = exact_position.lerp(goal, 1.0 - exp(-delta * FOLLOW_SPEED))
	_apply(exact_position + Feel.shake_offset)


func _apply(exact: Vector2) -> void:
	var px := DETAIL * frame_scale
	var whole := (exact * px).floor() / px
	subpixel = (exact - whole) * frame_scale
	global_position = whole


func _clamp_to_bounds(c: Vector2) -> Vector2:
	if bounds.size == Vector2.ZERO:
		return c
	var half := visible_size() * 0.5
	var lo := bounds.position + half
	var hi := bounds.end - half
	return Vector2(
		clampf(c.x, lo.x, maxf(lo.x, hi.x)),
		clampf(c.y, lo.y, maxf(lo.y, hi.y))
	)
