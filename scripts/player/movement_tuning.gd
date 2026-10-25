class_name MovementTuning
extends Resource
## Every movement number from the design bible (section 6), in px and seconds at
## the 640x360 internal resolution. Tests assert against these values.

@export_group("Ground")
@export var run_speed := 165.0
@export var ground_accel := 1800.0
@export var ground_decel := 2600.0
@export var turn_multiplier := 1.6

@export_group("Jump")
@export var jump_height := 72.0
@export var jump_time_to_apex := 0.36
@export var fall_gravity_multiplier := 1.6
@export var jump_cut_multiplier := 0.45
@export var apex_threshold := 40.0
@export var apex_gravity_multiplier := 0.5
@export var max_fall_speed := 520.0
@export var max_fast_fall_speed := 620.0
@export var air_accel := 1400.0
@export var air_decel := 900.0
@export var coyote_time := 0.10
@export var jump_buffer_time := 0.12
@export var corner_correction_px := 6
@export var ledge_correction_px := 4

@export_group("Wall")
@export var wall_slide_speed := 90.0
@export var wall_stick_time := 0.08
@export var wall_jump_x := 220.0
@export var wall_jump_y := 380.0
@export var wall_climb_jump_x := 120.0
@export var wall_jump_lock := 0.10
@export var wall_climb_jump_lock := 0.06
@export var wall_jump_blend := 0.10
@export var wall_coyote_time := 0.08

@export_group("Double jump")
@export var double_jump_height := 48.0

@export_group("Dash")
@export var dash_speed := 380.0
@export var dash_time := 0.15
@export var dash_invuln := 0.10
@export var air_dash_charges := 1
@export var ground_dash_cooldown := 0.25

@export_group("Pogo and attacks")
@export var pogo_bounce := 380.0
@export var pogo_bounce_held := 420.0
## A bounce-pod's launch (Branches): about 9 tiles of rise.
@export var pod_bounce := 600.0
@export var slash_active := 0.10
@export var down_strike_active := 0.14
@export var attack_cooldown := 0.28
@export var slash_recoil := 90.0

@export_group("Swimming")
## Deep water (the Sunken Spring, bible 6.8): the body floats up toward the
## surface, sinks while Down is held, and each jump press is a stroke upward.
## With the head above water a jump press is a full jump out.
@export var swim_speed_multiplier := 0.7
@export var swim_float := 50.0
@export var swim_sink := 120.0
@export var swim_drag := 520.0
@export var swim_stroke := 230.0

@export_group("Wind")
## A wind current in the Branches (bible 6.9): in the air inside one, the run
## target is shifted by wind_speed along the wind, so you can't make headway
## against it, and the current bears you level (velocity.y eases to 0 at
## wind_drag once you stop rising). Hold Down to drop out of it.
@export var wind_speed := 200.0
@export var wind_drag := 2400.0

@export_group("Damage")
@export var hurt_invuln := 0.8


var gravity: float:
	get: return 2.0 * jump_height / (jump_time_to_apex * jump_time_to_apex)

var jump_velocity: float:
	get: return 2.0 * jump_height / jump_time_to_apex

var double_jump_velocity: float:
	get: return sqrt(2.0 * gravity * double_jump_height)
