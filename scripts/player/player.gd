class_name Player
extends CharacterBody2D
## The elf wanderer's controller. Hand-written kinematic movement at a fixed
## 60 Hz, tuned by MovementTuning. The node origin is at the player's feet.

signal health_changed(hp: int, max_hp: int)
signal jumped(kind: String)
signal landed(fall_speed: float)

const BODY_SIZE := Vector2(12, 40)

# Collision layers (see docs/architecture.md).
const LAYER_WORLD := 1
const LAYER_PLAYER := 2
const LAYER_HAZARD := 4
const LAYER_ENEMY := 8

const SLASH_SIZE := Vector2(36, 26)
const UP_SLASH_SIZE := Vector2(34, 36)
const DOWN_STRIKE_SIZE := Vector2(28, 24)


@export var tuning: MovementTuning = MovementTuning.new()

var input := PlayerInput.new()
var abilities := {"glove": true, "mattock": true, "boots": true, "stride": true}

var max_hp := 100
var hp := 100
var attack_damage := 1

var facing := 1
var wall_dir := 0
var is_wall_sliding := false
var is_dashing: bool:
	get: return _dash_timer > 0.0
var is_attacking: bool:
	get: return _attack_timer > 0.0
var attack_kind := ""
var has_double_jump := true
var air_dash_charges := 1
var invulnerable: bool:
	get: return _invuln_timer > 0.0

var spawn_point := Vector2.ZERO
var safe_position := Vector2.ZERO

var visual: PlayerVisual
var scarf: Scarf

var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0
var _wall_coyote_timer := 0.0
var _last_wall_dir := 0
var _wall_stick_timer := 0.0
var _control_lock_timer := 0.0
var _control_blend_timer := 0.0
var _jump_cut_available := false
var _dash_timer := 0.0
var _dash_cooldown := 0.0
var _dash_dir := 1
var _afterimage_timer := 0.0
var _invuln_timer := 0.0
var _attack_timer := 0.0
var _attack_cooldown := 0.0
var _attack_hits := {}
var _was_on_floor := false
var _peak_fall_speed := 0.0
var _dust_timer := 0.0
var _step_timer := 0.0


func _ready() -> void:
	collision_layer = LAYER_PLAYER
	collision_mask = LAYER_WORLD
	floor_snap_length = 4.0
	floor_max_angle = deg_to_rad(46.0)
	floor_constant_speed = true
	safe_margin = 0.05
	add_to_group("player")

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = BODY_SIZE
	shape.shape = rect
	shape.position = Vector2(0, -BODY_SIZE.y * 0.5)
	add_child(shape)

	visual = PlayerVisual.new()
	visual.player = self

	# The scarf is added first so it draws behind the body.
	scarf = Scarf.new()
	scarf.player = self
	add_child(scarf)
	add_child(visual)

	air_dash_charges = tuning.air_dash_charges
	spawn_point = global_position
	safe_position = global_position


func _physics_process(delta: float) -> void:
	input.poll()
	_tick_timers(delta)

	var on_floor := is_on_floor()
	if on_floor:
		_coyote_timer = tuning.coyote_time
		_refresh_air_moves()
	if input.jump_pressed:
		_jump_buffer_timer = tuning.jump_buffer_time

	_update_wall_contact(on_floor)
	_try_drop_through(on_floor)
	_try_dash(on_floor)
	_try_attack(on_floor)

	if is_dashing:
		_dash_step(delta)
	else:
		_horizontal_step(delta, on_floor)

	_try_jump()
	_apply_jump_cut()

	if not is_dashing:
		_apply_gravity(delta, on_floor)
	_apply_wall_slide()

	if is_attacking:
		_process_attack_hits()

	if velocity.x != 0.0 and not is_attacking and not is_dashing and not is_wall_sliding and input.move_x != 0:
		facing = input.move_x

	_apply_corner_correction(delta)
	_apply_ledge_correction(delta, on_floor)
	var pre_velocity := velocity
	move_and_slide()
	_after_move(pre_velocity, delta)
	_check_hazards()
	input.end_frame()


# --- Timers and refresh -------------------------------------------------------

func _tick_timers(delta: float) -> void:
	_coyote_timer -= delta
	_jump_buffer_timer -= delta
	_wall_coyote_timer -= delta
	_control_lock_timer -= delta
	_control_blend_timer -= delta
	_dash_cooldown -= delta
	_invuln_timer -= delta
	_attack_cooldown -= delta
	_dust_timer -= delta
	_step_timer -= delta


func _refresh_air_moves() -> void:
	has_double_jump = true
	air_dash_charges = tuning.air_dash_charges


# --- Walls ----------------------------------------------------------------------

func _update_wall_contact(on_floor: bool) -> void:
	wall_dir = 0
	if on_floor or not abilities.glove:
		return
	if test_move(global_transform, Vector2(2, 0)):
		wall_dir = 1
	elif test_move(global_transform, Vector2(-2, 0)):
		wall_dir = -1
	if wall_dir != 0:
		_last_wall_dir = wall_dir
		_wall_coyote_timer = tuning.wall_coyote_time
		_refresh_air_moves()


func _apply_wall_slide() -> void:
	var was_sliding := is_wall_sliding
	is_wall_sliding = false
	if wall_dir == 0 or is_dashing or velocity.y <= 0.0:
		_wall_stick_timer = tuning.wall_stick_time
		return
	if input.move_x == wall_dir:
		is_wall_sliding = true
		_wall_stick_timer = tuning.wall_stick_time
	elif input.move_x == -wall_dir:
		# Pushing away detaches only after a short stick, so wall jumps stay easy to aim.
		is_wall_sliding = was_sliding and _wall_stick_timer > 0.0
		_wall_stick_timer -= get_physics_process_delta_time()
	else:
		is_wall_sliding = was_sliding
	if is_wall_sliding:
		velocity.x = wall_dir * 10.0
		velocity.y = minf(velocity.y, tuning.wall_slide_speed)
		facing = -wall_dir
		if _dust_timer <= 0.0:
			_dust_timer = 0.06
			_spawn_dust(Vector2(wall_dir * BODY_SIZE.x * 0.5, -BODY_SIZE.y * 0.6), "wall")


# --- Horizontal -----------------------------------------------------------------

func _horizontal_step(delta: float, on_floor: bool) -> void:
	var target := input.move_x * tuning.run_speed
	var accel: float
	if on_floor:
		if input.move_x != 0:
			accel = tuning.ground_accel
			if velocity.x != 0.0 and signf(velocity.x) != input.move_x:
				accel = tuning.ground_decel * tuning.turn_multiplier
				if absf(velocity.x) > 80.0:
					_spawn_run_dust()
		else:
			accel = tuning.ground_decel
		if input.move_x != 0 and absf(velocity.x) < 10.0:
			_spawn_run_dust()
	else:
		accel = tuning.air_accel if input.move_x != 0 else tuning.air_decel

	if _control_lock_timer > 0.0:
		accel = 0.0
	elif _control_blend_timer > 0.0:
		accel *= 1.0 - _control_blend_timer / tuning.wall_jump_blend
	velocity.x = move_toward(velocity.x, target, accel * delta)


# --- Jumping --------------------------------------------------------------------

func _try_jump() -> void:
	if _jump_buffer_timer <= 0.0:
		return
	if _coyote_timer > 0.0:
		_do_jump()
	elif abilities.glove and (wall_dir != 0 or _wall_coyote_timer > 0.0):
		_do_wall_jump(wall_dir if wall_dir != 0 else _last_wall_dir)
	elif abilities.boots and has_double_jump and not is_dashing:
		_do_double_jump()


func _do_jump() -> void:
	velocity.y = -tuning.jump_velocity
	_end_dash_into_jump()
	_consume_jump()
	_jump_cut_available = true
	visual.squash(Vector2(0.85, 1.2))
	_spawn_dust(Vector2.ZERO, "jump")
	Sfx.play("jump")
	jumped.emit("ground")


func _do_wall_jump(side: int) -> void:
	var away := -side
	var climbing := input.move_x != away
	velocity.x = away * (tuning.wall_climb_jump_x if climbing else tuning.wall_jump_x)
	velocity.y = -tuning.wall_jump_y
	_control_lock_timer = tuning.wall_climb_jump_lock if climbing else tuning.wall_jump_lock
	_control_blend_timer = tuning.wall_jump_blend
	_end_dash_into_jump()
	_consume_jump()
	_wall_coyote_timer = 0.0
	is_wall_sliding = false
	_jump_cut_available = true
	has_double_jump = true
	facing = away
	visual.squash(Vector2(1.15, 0.9))
	_spawn_dust(Vector2(side * BODY_SIZE.x * 0.5, -BODY_SIZE.y * 0.5), "walljump")
	Sfx.play("wall_jump")
	jumped.emit("wall")


func _do_double_jump() -> void:
	velocity.y = -tuning.double_jump_velocity
	has_double_jump = false
	_consume_jump()
	_jump_cut_available = true
	visual.squash(Vector2(0.8, 1.25))
	_spawn_dust(Vector2(0, -4), "feathers")
	Sfx.play("double_jump")
	jumped.emit("double")


func _consume_jump() -> void:
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0


func _apply_jump_cut() -> void:
	if not _jump_cut_available:
		return
	if velocity.y >= 0.0:
		_jump_cut_available = false
	elif not input.jump_held:
		velocity.y *= tuning.jump_cut_multiplier
		_jump_cut_available = false


func _try_drop_through(on_floor: bool) -> void:
	if not (on_floor and input.down and input.jump_pressed):
		return
	var room: Variant = get_tree().get_first_node_in_group("room")
	if room and room.has_method("is_one_way_at") and room.is_one_way_at(global_position + Vector2(0, 2)):
		global_position.y += 3.0
		_jump_buffer_timer = 0.0
		input.jump_pressed = false
		_coyote_timer = 0.0


# --- Gravity --------------------------------------------------------------------

func _apply_gravity(delta: float, on_floor: bool) -> void:
	var g := tuning.gravity
	if not on_floor and input.jump_held and absf(velocity.y) < tuning.apex_threshold:
		g *= tuning.apex_gravity_multiplier
	elif velocity.y > 0.0:
		g *= tuning.fall_gravity_multiplier
	velocity.y += g * delta
	var max_fall := tuning.max_fast_fall_speed if input.down else tuning.max_fall_speed
	velocity.y = minf(velocity.y, max_fall)


# --- Dash -----------------------------------------------------------------------

func _try_dash(on_floor: bool) -> void:
	if not (input.dash_pressed and abilities.stride) or is_dashing or _dash_cooldown > 0.0:
		return
	if not on_floor and air_dash_charges <= 0:
		return
	if not on_floor:
		air_dash_charges -= 1
	_dash_dir = input.move_x if input.move_x != 0 else facing
	if is_wall_sliding:
		_dash_dir = -wall_dir
	facing = _dash_dir
	_dash_timer = tuning.dash_time
	_invuln_timer = maxf(_invuln_timer, tuning.dash_invuln)
	_jump_cut_available = false
	_attack_timer = 0.0
	is_wall_sliding = false
	velocity = Vector2(_dash_dir * tuning.dash_speed, 0.0)
	visual.squash(Vector2(1.3, 0.8))
	_afterimage_timer = 0.0
	Sfx.play("dash")
	Feel.add_trauma(0.05)


func _dash_step(delta: float) -> void:
	velocity = Vector2(_dash_dir * tuning.dash_speed, 0.0)
	_afterimage_timer -= delta
	if _afterimage_timer <= 0.0:
		_afterimage_timer = tuning.dash_time / 3.0
		var ghost := Afterimage.new()
		get_parent().add_child(ghost)
		ghost.setup(self)
	_dash_timer -= delta
	if _dash_timer <= 0.0:
		_finish_dash()


func _finish_dash() -> void:
	_dash_timer = 0.0
	velocity.x = _dash_dir * tuning.run_speed
	_dash_cooldown = tuning.ground_dash_cooldown


func _end_dash_into_jump() -> void:
	if is_dashing:
		_finish_dash()


# --- Attacks and pogo -----------------------------------------------------------

func _try_attack(on_floor: bool) -> void:
	if not input.attack_pressed or _attack_cooldown > 0.0 or is_dashing:
		return
	if not on_floor and input.down and abilities.mattock:
		attack_kind = "down"
		_attack_timer = tuning.down_strike_active
	elif input.up:
		attack_kind = "up"
		_attack_timer = tuning.slash_active
	else:
		attack_kind = "side"
		_attack_timer = tuning.slash_active
	_attack_cooldown = tuning.attack_cooldown
	_attack_hits.clear()
	var fx := SlashFx.new()
	fx.setup(attack_kind, facing)
	add_child(fx)
	Sfx.play("slash", 0.1)


func _attack_rect() -> Rect2:
	var center: Vector2
	var size: Vector2
	match attack_kind:
		"down":
			size = DOWN_STRIKE_SIZE
			center = Vector2(0, 8)
		"up":
			size = UP_SLASH_SIZE
			center = Vector2(0, -BODY_SIZE.y - 14)
		_:
			size = SLASH_SIZE
			center = Vector2(facing * (BODY_SIZE.x * 0.5 + 16), -BODY_SIZE.y * 0.55)
	return Rect2(global_position + center - size * 0.5, size)


func _process_attack_hits() -> void:
	_attack_timer -= get_physics_process_delta_time()
	var rect := _attack_rect()
	var bounced := false
	var hit_something := false
	for collider: Variant in _query_rect(rect, LAYER_WORLD | LAYER_HAZARD | LAYER_ENEMY):
		var id: int = collider.get_instance_id()
		if _attack_hits.has(id):
			continue
		_attack_hits[id] = true
		if collider.is_in_group("breakable") and abilities.mattock:
			collider.break_block()
			hit_something = true
			continue
		if collider.has_method("take_hit"):
			collider.take_hit(attack_damage, Vector2(facing, 0) if attack_kind == "side" else Vector2(0, 1 if attack_kind == "down" else -1))
			hit_something = true
		if attack_kind == "down" and collider.is_in_group("pogo") and not bounced:
			bounced = true
			_pogo_bounce()
	if hit_something and not bounced:
		Feel.hitstop(0.05)
		Feel.add_trauma(0.15)
		Feel.rumble(0.3, 0.0, 0.08)
		Sfx.play("hit")
		if attack_kind == "side":
			velocity.x = -facing * tuning.slash_recoil
	if attack_kind == "down" and bounced:
		_attack_timer = 0.0


func _pogo_bounce() -> void:
	velocity.y = -(tuning.pogo_bounce_held if input.jump_held else tuning.pogo_bounce)
	_refresh_air_moves()
	_jump_cut_available = false
	_coyote_timer = 0.0
	visual.squash(Vector2(0.8, 1.2))
	_spawn_dust(Vector2(0, 8), "pogo")
	Feel.hitstop(0.045)
	Feel.add_trauma(0.12)
	Feel.rumble(0.4, 0.1, 0.08)
	Sfx.play("pogo")
	jumped.emit("pogo")


func _query_rect(rect: Rect2, mask: int) -> Array:
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0.0, rect.get_center())
	params.collision_mask = mask
	params.collide_with_areas = true
	params.collide_with_bodies = true
	params.exclude = [get_rid()]
	var out: Array = []
	for r in get_world_2d().direct_space_state.intersect_shape(params, 32):
		var c: Object = r.get("collider")
		if c != null and not out.has(c):
			out.append(c)
	return out


# --- Collision helpers ----------------------------------------------------------

func _apply_corner_correction(delta: float) -> void:
	if velocity.y >= 0.0:
		return
	var motion := Vector2(0, velocity.y * delta)
	if not test_move(global_transform, motion):
		return
	for i in range(1, tuning.corner_correction_px + 1):
		for s in [1, -1]:
			var offset := Vector2(i * s, 0)
			if not test_move(global_transform, offset) and not test_move(global_transform.translated(offset), motion):
				global_position += offset
				return


func _apply_ledge_correction(delta: float, on_floor: bool) -> void:
	if on_floor or velocity.y < 0.0 or velocity.x == 0.0 or is_wall_sliding:
		return
	var motion := Vector2(velocity.x * delta, 0)
	if not test_move(global_transform, motion):
		return
	for i in range(1, tuning.ledge_correction_px + 1):
		var up := Vector2(0, -i)
		if not test_move(global_transform, up) and not test_move(global_transform.translated(up), motion):
			global_position += up
			return


func _after_move(pre_velocity: Vector2, _delta: float) -> void:
	var on_floor := is_on_floor()
	if not on_floor:
		_peak_fall_speed = maxf(_peak_fall_speed, velocity.y)
	if on_floor and not _was_on_floor:
		var impact := maxf(_peak_fall_speed, pre_velocity.y)
		var k := clampf(impact / tuning.max_fall_speed, 0.0, 1.0)
		visual.squash(Vector2(1.0 + 0.25 * k, 1.0 - 0.2 * k))
		if impact > 120.0:
			_spawn_dust(Vector2.ZERO, "land")
			Sfx.play("land", 0.08, lerpf(-8.0, 0.0, k))
		if impact > 450.0:
			Feel.add_trauma(0.12)
		landed.emit(impact)
		_peak_fall_speed = 0.0
	if on_floor and absf(velocity.x) > 40.0 and _step_timer <= 0.0:
		_step_timer = 0.26
		Sfx.play("step", 0.15, -10.0)
	if on_floor and not _hazard_near():
		safe_position = global_position
	_was_on_floor = on_floor


# --- Damage ---------------------------------------------------------------------

func _check_hazards() -> void:
	if invulnerable:
		return
	var body := Rect2(global_position + Vector2(-BODY_SIZE.x * 0.5 + 1, -BODY_SIZE.y + 2), BODY_SIZE - Vector2(2, 3))
	for c: Variant in _query_rect(body, LAYER_HAZARD):
		if c.is_in_group("hazard"):
			take_damage(20, true)
			return


func _hazard_near() -> bool:
	var area := Rect2(global_position + Vector2(-20, -BODY_SIZE.y), Vector2(40, BODY_SIZE.y + 6))
	for c: Variant in _query_rect(area, LAYER_HAZARD):
		if c.is_in_group("hazard"):
			return true
	return false


func take_damage(amount: int, from_hazard := false) -> void:
	if invulnerable:
		return
	hp -= amount
	_invuln_timer = tuning.hurt_invuln
	Feel.hitstop(0.15)
	Feel.add_trauma(0.35)
	Feel.rumble(0.5, 0.6, 0.2)
	Sfx.play("hurt")
	visual.flash_hurt()
	if hp <= 0:
		hp = max_hp
		teleport(spawn_point)
	elif from_hazard:
		teleport(safe_position)
	health_changed.emit(hp, max_hp)


func teleport(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
	_dash_timer = 0.0
	_attack_timer = 0.0
	reset_physics_interpolation()
	if scarf:
		scarf.snap()
	_refresh_air_moves()


# --- Effects --------------------------------------------------------------------

func _spawn_run_dust() -> void:
	if _dust_timer > 0.0:
		return
	_dust_timer = 0.1
	_spawn_dust(Vector2(-facing * 4, 0), "run")


func _spawn_dust(offset: Vector2, kind: String) -> void:
	if get_parent() == null:
		return
	var d := Dust.new()
	d.setup(kind, facing)
	get_parent().add_child(d)
	d.global_position = global_position + offset
