class_name Player
extends CharacterBody2D
## The elf wanderer's controller. Hand-written kinematic movement at a fixed
## 60 Hz, tuned by MovementTuning. The node origin is at the player's feet.

signal health_changed(hp: int, max_hp: int)
signal jumped(kind: String)
signal landed(fall_speed: float)
## A footstep (or the scuff under a landing) on `surface`: see Room.surface_at.
signal footstep(surface: String)
signal died
signal respawned

const BODY_SIZE := Vector2(12, 40)

# Collision layers (see docs/architecture.md).
const LAYER_WORLD := 1
const LAYER_PLAYER := 2
const LAYER_HAZARD := 4
const LAYER_ENEMY := 8

## Sap pools (Trunk Hollows) halve run speed and weaken jumps.
const SAP_SPEED := 0.5
const SAP_JUMP := 0.72
## How long an Ointment protects you (design bible 10.2).
const OINTMENT_TIME := 10.0
## Poison (a Faxanadu drop): seconds it lasts, and health lost each POISON_TICK.
## It never takes your last point of health.
const POISON_TIME := 8.0
const POISON_TICK := 1.0
const POISON_DAMAGE := 2

const SLASH_SIZE := Vector2(36, 26)
const UP_SLASH_SIZE := Vector2(34, 36)
const DOWN_STRIKE_SIZE := Vector2(28, 24)


@export var tuning: MovementTuning = MovementTuning.new()
@export var combat: CombatTuning = CombatTuning.new()

var input := PlayerInput.new()
var abilities := {"glove": true, "mattock": true, "boots": true, "stride": true, "deluge": true, "fire": true, "thunder": true}

var max_hp := 100
var hp := 100
var max_mp := 60.0
var mp := 60.0
var gold := 0
var flask_max := 2
var flask_charges := 2
var equipped_spell := "deluge"

# Derived from gear and skills by GameState.refresh_stats. Defaults are the
# Hand Dagger with a shield and no skills, which is what the gym uses.
var slash_damage := 8
var heavy_damage := 14
var reach_bonus := 0.0
var defense := 0.0
var has_shield := true
## Share of damage a guard blocks; the shield sets it (data/items.json "guard").
var guard_reduction := 0.5
## Elixirs carried: dying with one revives you where you fell.
var elixirs := 0
## Ointments carried: each makes you immune to harm for OINTMENT_TIME.
var ointments := 0
var melee_mult := 1.0
var mp_hit_mult := 1.0
var gold_mult := 1.0
var magnet_mult := 1.0
var ground_combo_length := 3
## Skill tree effects (design bible 9), set by GameState.refresh_stats.
var rising_cut := false
var down_strike_mult := 1.0
var spell_pierce := false
var drink_mult := 1.0
var bonus_air_dashes := 0
## Set each frame by the World when the feet are in a sap pool.
var in_sap := false
var dead := false
var purse: GoldPurse

var facing := 1
var wall_dir := 0
var is_wall_sliding := false
var is_dashing: bool:
	get: return _dash_timer > 0.0
var is_attacking: bool:
	get: return _attack_timer > 0.0
var attack_kind := ""
var combo_index := 0
var is_heavy_swing := false
var is_blocking := false
var is_drinking: bool:
	get: return _drink_timer > 0.0
var has_double_jump := true
var air_dash_charges := 1
var invulnerable: bool:
	get: return _invuln_timer > 0.0 or _ointment_timer > 0.0
## Seconds of Ointment left (0 when none is on).
var ointment_left: float:
	get: return maxf(_ointment_timer, 0.0)
## Seconds of poison left (0 when you are well).
var poison_left: float:
	get: return maxf(_poison_timer, 0.0)
## Counts swings, so the visual can restart an attack animation on each press.
var swing_count := 0
var is_casting: bool:
	get: return _cast_cooldown > combat.cast_cooldown - 0.2
var is_hurt: bool:
	get: return _invuln_timer > tuning.hurt_invuln - 0.25 and not dead

var spawn_point := Vector2.ZERO
var safe_position := Vector2.ZERO
## When set, called instead of the default respawn at `spawn_point` (the World
## uses it to return the player to the last save shrine, in any room).
var respawn_handler: Callable
## While frozen (room transitions, dialog, menus) the controller does nothing.
var frozen := false
## A drag in px/s that something outside the player applies this frame (a
## boss's web line reeling you in). Moves the body directly, so it works
## against any input; a dash breaks it. Cleared every frame.
var pull := Vector2.ZERO

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
var _ointment_timer := 0.0
var _poison_timer := 0.0
var _poison_tick := 0.0
var _attack_timer := 0.0
var _attack_cooldown := 0.0
var _attack_hits := {}
var _was_on_floor := false
var _peak_fall_speed := 0.0
var _dust_timer := 0.0
var _step_timer := 0.0
var _combo_timer := 0.0
var _attack_buffer_timer := 0.0
var _swing_damage := 0
var _parry_timer := 0.0
var _drink_timer := 0.0
var _cast_cooldown := 0.0
var _dead_timer := 0.0
var _gold_frac := 0.0


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

	# The scarf is added first so it draws behind the body. A sheet whose art
	# carries its own cloak turns it off (flags "scarf": false).
	scarf = Scarf.new()
	scarf.player = self
	scarf.visible = Sheet.flag(PlayerVisual.SHEET_NAME, "scarf", true)
	add_child(scarf)
	add_child(visual)

	air_dash_charges = tuning.air_dash_charges + bonus_air_dashes
	max_mp = max_mp
	mp = max_mp
	flask_max = combat.flask_charges
	flask_charges = flask_max
	spawn_point = global_position
	safe_position = global_position


func _physics_process(delta: float) -> void:
	if frozen:
		input.clear()
		return
	if dead:
		_dead_timer -= delta
		input.clear()
		if _dead_timer <= 0.0:
			_respawn()
		return
	input.poll()
	_tick_timers(delta)
	mp = minf(mp + combat.mp_regen_per_second * delta, max_mp)

	var on_floor := is_on_floor()
	if on_floor:
		_coyote_timer = tuning.coyote_time
		_refresh_air_moves()
	if input.jump_pressed:
		_jump_buffer_timer = tuning.jump_buffer_time

	if input.attack_pressed:
		_attack_buffer_timer = combat.attack_buffer

	if _try_interact(on_floor):
		input.end_frame()
		return
	_update_wall_contact(on_floor)
	_update_block()
	_update_drink(delta, on_floor)
	_try_drop_through(on_floor)
	_try_dash(on_floor)
	_try_cycle_spell()
	_try_cast()
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

	if velocity.x != 0.0 and not is_attacking and not is_dashing and not is_wall_sliding and not is_blocking and input.move_x != 0:
		facing = input.move_x

	_apply_corner_correction(delta)
	_apply_ledge_correction(delta, on_floor)
	var pre_velocity := velocity
	move_and_slide()
	if pull != Vector2.ZERO and not is_dashing:
		move_and_collide(pull * delta)
	pull = Vector2.ZERO
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
	if _ointment_timer > 0.0:
		_ointment_timer -= delta
		if _ointment_timer <= 0.0:
			GameState.toast.emit("The Ointment wears off.")
	if _poison_timer > 0.0:
		_tick_poison(delta)
	_attack_cooldown -= delta
	_dust_timer -= delta
	_step_timer -= delta
	_combo_timer -= delta
	_attack_buffer_timer -= delta
	_parry_timer -= delta
	_cast_cooldown -= delta


func _refresh_air_moves() -> void:
	has_double_jump = true
	air_dash_charges = tuning.air_dash_charges + bonus_air_dashes


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
	if is_drinking:
		target = 0.0
	elif is_blocking:
		target *= combat.guard_move_multiplier
	if in_sap:
		target *= SAP_SPEED
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
	velocity.y = -tuning.jump_velocity * (SAP_JUMP if in_sap else 1.0)
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
	if _attack_buffer_timer <= 0.0 or _attack_cooldown > 0.0 or is_dashing or is_blocking or is_drinking:
		return
	_attack_buffer_timer = 0.0
	is_heavy_swing = false
	_swing_damage = roundi(slash_damage * melee_mult)
	if not on_floor and input.down and abilities.mattock:
		attack_kind = "down"
		combo_index = 0
		_swing_damage = roundi(slash_damage * melee_mult * down_strike_mult)
		_attack_timer = tuning.down_strike_active
		_attack_cooldown = tuning.attack_cooldown
	elif input.up:
		attack_kind = "up"
		combo_index = 0
		_attack_timer = tuning.slash_active
		_attack_cooldown = tuning.attack_cooldown
	else:
		attack_kind = "side"
		var max_combo := ground_combo_length if on_floor else combat.air_combo_length
		combo_index = combo_index + 1 if _combo_timer > 0.0 and combo_index < max_combo else 1
		_combo_timer = combat.combo_window
		_attack_timer = tuning.slash_active
		# The last hit of a ground combo is the heavy finisher.
		is_heavy_swing = on_floor and combo_index == max_combo
		var cd: Array[float] = combat.combo_cooldowns
		_attack_cooldown = cd[cd.size() - 1] if is_heavy_swing else cd[mini(combo_index - 1, cd.size() - 2)]
		if is_heavy_swing:
			_swing_damage = roundi(heavy_damage * melee_mult)
	_attack_hits.clear()
	swing_count += 1
	var fx := SlashFx.new()
	fx.setup(attack_kind, facing, combo_index, is_heavy_swing)
	add_child(fx)
	if is_heavy_swing:
		visual.squash(Vector2(1.2, 0.9))
		velocity.x += facing * 60.0
	Sfx.play("heavy" if is_heavy_swing else "slash", 0.1)


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
			size = SLASH_SIZE + Vector2(reach_bonus, 0)
			center = Vector2(facing * (BODY_SIZE.x * 0.5 + 16 + reach_bonus * 0.5), -BODY_SIZE.y * 0.55)
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
			var dir := Vector2(facing, 0) if attack_kind == "side" else Vector2(0, 1 if attack_kind == "down" else -1)
			collider.take_hit(_swing_damage, dir * (1.8 if is_heavy_swing else 1.0))
			hit_something = true
			if attack_kind == "up" and rising_cut and collider.has_method("launch"):
				collider.launch()
			if collider.is_in_group("enemy"):
				mp = minf(mp + combat.mp_per_melee_hit * mp_hit_mult, max_mp)
		if attack_kind == "down" and collider.is_in_group("pogo") and not bounced:
			bounced = true
			_pogo_bounce()
	if hit_something and not bounced:
		Feel.hitstop(combat.heavy_hitstop if is_heavy_swing else combat.hit_hitstop)
		Feel.add_trauma(0.3 if is_heavy_swing else 0.15)
		Feel.rumble(0.3, 0.2 if is_heavy_swing else 0.0, 0.08)
		Sfx.play("hit", 0.08, 2.0 if is_heavy_swing else 0.0)
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


## A bounce-pod throws the player up (design bible 6.6): a full-height launch
## that jump release doesn't cut short, and the air moves come back.
func pod_launch() -> void:
	velocity.y = -tuning.pod_bounce
	_refresh_air_moves()
	_jump_cut_available = false
	_coyote_timer = 0.0
	visual.squash(Vector2(0.75, 1.25))
	_spawn_dust(Vector2(0, 0), "jump")
	Feel.add_trauma(0.08)
	Feel.rumble(0.3, 0.1, 0.08)
	jumped.emit("pod")


func _query_rect(rect: Rect2, mask: int) -> Array:
	return Query.rect(get_world_2d(), rect, mask, [get_rid()])


func body_rect() -> Rect2:
	return Rect2(global_position + Vector2(-BODY_SIZE.x * 0.5, -BODY_SIZE.y), BODY_SIZE)


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
			_footstep(lerpf(-10.0, -4.0, k))
		if impact > 450.0:
			Feel.add_trauma(0.12)
		landed.emit(impact)
		_peak_fall_speed = 0.0
	if on_floor and absf(velocity.x) > 40.0 and _step_timer <= 0.0:
		_step_timer = 0.26
		_footstep(-10.0)
	if on_floor and not _hazard_near():
		safe_position = global_position
	_was_on_floor = on_floor


## Plays the step sound for the ground underfoot (design bible 11), falling back
## to the plain step outside a room.
func _footstep(volume_db: float) -> void:
	var surface := ""
	var room := get_tree().get_first_node_in_group("room") as Room
	if room != null:
		surface = room.surface_at(global_position + Vector2(0, 2))
	Sfx.play("step_" + surface if surface != "" else "step", 0.15, volume_db)
	footstep.emit(surface)


# --- Shield, potion and spells -------------------------------------------------

func _update_block() -> void:
	if not has_shield:
		is_blocking = false
		return
	if input.block_pressed:
		_parry_timer = combat.parry_window
	is_blocking = input.block_held and not is_dashing and not is_attacking and not is_drinking


func _update_drink(delta: float, on_floor: bool) -> void:
	if is_drinking:
		if not on_floor or is_dashing:
			_drink_timer = 0.0
			return
		_drink_timer -= delta
		if _drink_timer <= 0.0:
			hp = mini(hp + combat.flask_heal, max_hp)
			flask_charges -= 1
			_spawn_dust(Vector2(0, -20), "heal")
			Sfx.play("heal")
			health_changed.emit(hp, max_hp)
		return
	if input.heal_pressed and flask_charges > 0 and on_floor and hp < max_hp and not is_attacking and not is_dashing:
		_drink_timer = combat.drink_time * drink_mult
		Sfx.play("drink")


## Next Spell: equips the next spell you own, in `Spells.ORDER`.
func _try_cycle_spell() -> void:
	if not input.spell_next_pressed:
		return
	var next := Spells.next_owned(equipped_spell, abilities)
	if next == equipped_spell:
		if not abilities.get(next, false):
			Sfx.play("fizzle")
		return
	equipped_spell = next
	Sfx.play("blip", 0.0, -2.0)
	GameState.toast.emit("Spell: " + String(Spells.DATA[next].name))


func _try_cast() -> void:
	if not input.spell_pressed or _cast_cooldown > 0.0 or is_dashing or is_drinking or is_blocking:
		return
	if not abilities.get(equipped_spell, false):
		return
	var cost := Spells.cost(equipped_spell)
	if mp < cost:
		Sfx.play("fizzle")
		return
	mp -= cost
	_cast_cooldown = combat.cast_cooldown
	var bolt := Spells.cast(equipped_spell, self)
	get_parent().add_child(bolt)
	bolt.global_position = global_position + Vector2(facing * 12, -24)
	visual.squash(Vector2(1.1, 0.95))
	Sfx.play("cast")


# --- Damage ---------------------------------------------------------------------

func _check_hazards() -> void:
	if invulnerable or dead:
		return
	var body := Rect2(global_position + Vector2(-BODY_SIZE.x * 0.5 + 1, -BODY_SIZE.y + 2), BODY_SIZE - Vector2(2, 3))
	for c: Variant in _query_rect(body, LAYER_HAZARD | LAYER_ENEMY):
		if c.is_in_group("hazard"):
			take_damage(combat.hazard_damage, true)
			return
		if c.is_in_group("enemy") and "contact_damage" in c and c.contact_damage > 0 and not c.dead:
			receive_attack(c.contact_damage, c, false)
			return


func _hazard_near() -> bool:
	var area := Rect2(global_position + Vector2(-20, -BODY_SIZE.y), Vector2(40, BODY_SIZE.y + 6))
	for c: Variant in _query_rect(area, LAYER_HAZARD):
		if c.is_in_group("hazard"):
			return true
	return false


## Entry point for every enemy attack. Resolves parry, guard or a clean hit.
## Returns "parried", "guarded", "hit" or "ignored".
func receive_attack(damage: int, source: Node2D, parryable := true) -> String:
	if dead:
		return "ignored"
	var src_dir := int(signf(source.global_position.x - global_position.x))
	var from_front := src_dir == 0 or src_dir == facing
	if parryable and _parry_timer > 0.0 and from_front:
		_parry_timer = 0.0
		_invuln_timer = maxf(_invuln_timer, 0.25)
		mp = minf(mp + combat.parry_mp_gain, max_mp)
		Feel.hitstop(combat.parry_hitstop)
		Feel.add_trauma(0.2)
		Feel.rumble(0.6, 0.2, 0.1)
		Sfx.play("parry")
		_spawn_dust(Vector2(facing * 12, -24), "parry")
		visual.squash(Vector2(1.15, 0.9))
		if source.has_method("stagger"):
			source.stagger()
		return "parried"
	if invulnerable:
		return "ignored"
	var knock := -src_dir if src_dir != 0 else -facing
	if is_blocking and from_front and mp >= combat.guard_mp_cost:
		mp -= combat.guard_mp_cost
		_spawn_dust(Vector2(facing * 10, -24), "guard")
		Sfx.play("guard")
		take_damage(int(round(damage * (1.0 - guard_reduction))), false, knock)
		return "guarded"
	take_damage(damage, false, knock)
	return "hit"


func take_damage(amount: int, from_hazard := false, knock_dir := 0) -> void:
	if invulnerable or dead:
		return
	if defense > 0.0:
		amount = maxi(1, roundi(amount * (1.0 - defense)))
	hp -= amount
	_invuln_timer = tuning.hurt_invuln
	_drink_timer = 0.0
	_attack_timer = 0.0
	_dash_timer = 0.0
	Feel.hitstop(0.15)
	Feel.add_trauma(0.35)
	Feel.rumble(0.5, 0.6, 0.2)
	Sfx.play("hurt")
	visual.flash_hurt()
	if hp <= 0 and elixirs > 0:
		_drink_elixir()
		return
	if hp <= 0:
		hp = 0
		health_changed.emit(hp, max_hp)
		_die(safe_position if from_hazard else global_position)
		return
	if from_hazard:
		teleport(safe_position)
	elif knock_dir != 0:
		velocity = Vector2(knock_dir * combat.hurt_knockback.x, -combat.hurt_knockback.y)
		_control_lock_timer = combat.hurt_control_lock
		_control_blend_timer = 0.0
	health_changed.emit(hp, max_hp)


## Rubs on an Ointment (from the pause menu): nothing can hurt you for
## OINTMENT_TIME seconds. False if you have none or one is already on.
func use_ointment() -> bool:
	if ointments <= 0 or _ointment_timer > 0.0 or dead:
		return false
	ointments -= 1
	_ointment_timer = OINTMENT_TIME
	Sfx.play("heal", 0.0)
	GameState.toast.emit("The Ointment shimmers on your skin.")
	return true


## Drinks in poison: for POISON_TIME seconds you lose POISON_DAMAGE health
## every POISON_TICK, down to 1. An Ointment keeps it off. False if it didn't take.
func poison() -> bool:
	if dead or _ointment_timer > 0.0:
		return false
	_poison_timer = POISON_TIME
	_poison_tick = POISON_TICK
	return true


## Bread, a shrine or the Guru clears poison.
func cure_poison() -> void:
	_poison_timer = 0.0


func _tick_poison(delta: float) -> void:
	_poison_timer -= delta
	_poison_tick -= delta
	if _poison_tick <= 0.0:
		_poison_tick += POISON_TICK
		if not dead and _ointment_timer <= 0.0 and hp > 1:
			hp = maxi(1, hp - POISON_DAMAGE)
			health_changed.emit(hp, max_hp)
	if _poison_timer <= 0.0:
		GameState.toast.emit("The poison fades.")


## Dying with an Elixir: it is used up and you rise where you fell, fully healed.
func _drink_elixir() -> void:
	elixirs -= 1
	hp = max_hp
	_invuln_timer = tuning.hurt_invuln * 2.0
	velocity = Vector2(0, -180)
	Feel.slowmo(0.4, 0.6)
	GameState.flash.emit(0.6)
	Sfx.play("heal", 0.0)
	var d := Dust.new()
	d.setup("heal")
	get_parent().add_child(d)
	d.global_position = global_position + Vector2(0, -20)
	GameState.toast.emit("The Elixir burns. You rise again.")
	health_changed.emit(hp, max_hp)


func _die(where: Vector2) -> void:
	dead = true
	_dead_timer = combat.respawn_delay
	velocity = Vector2.ZERO
	var drop := int(floor(gold * combat.death_gold_fraction))
	if is_instance_valid(purse):
		purse.queue_free()
	purse = null
	if drop > 0:
		gold -= drop
		purse = GoldPurse.new()
		purse.value = drop
		get_parent().add_child(purse)
		purse.global_position = where
	var d := Dust.new()
	d.setup("debris")
	get_parent().add_child(d)
	d.global_position = global_position + Vector2(0, -20)
	Feel.hitstop(0.35)
	Feel.add_trauma(0.5)
	Sfx.play("death")
	died.emit()


func _respawn() -> void:
	dead = false
	_poison_timer = 0.0
	hp = max_hp
	mp = max_mp
	flask_charges = flask_max
	if respawn_handler.is_valid():
		respawn_handler.call()
	else:
		teleport(spawn_point)
	_invuln_timer = 1.0
	health_changed.emit(hp, max_hp)
	respawned.emit()


## Adds gold. Found gold (coins) gets the Gold Sense bonus; returned gold doesn't.
func add_gold(amount: int, found := false) -> void:
	if not found:
		gold += amount
		return
	var g := amount * gold_mult + _gold_frac
	var whole := floori(g)
	_gold_frac = g - whole
	gold += whole


## Refills health, magic and potion charges (save shrines, the Guru).
func restore() -> void:
	_poison_timer = 0.0
	hp = max_hp
	mp = max_mp
	flask_charges = flask_max
	health_changed.emit(hp, max_hp)


## Pressing Up on the ground next to an interactable (shrine, sign, NPC, door)
## uses it. Returns true if something was used this frame.
func _try_interact(on_floor: bool) -> bool:
	if not input.up_pressed or not on_floor or is_attacking or is_dashing or is_drinking:
		return false
	var best: Node2D = null
	var best_dist := INF
	for n: Node in get_tree().get_nodes_in_group("interactable"):
		var it := n as Node2D
		if it == null or not it.has_method("interact") or not can_reach(it):
			continue
		var d := absf(it.global_position.x - global_position.x)
		if d < best_dist:
			best = it
			best_dist = d
	if best == null:
		return false
	velocity.x = 0.0
	best.call("interact", self)
	return true


## True if `node` is close enough to interact with (about one tile either side).
func can_reach(node: Node2D) -> bool:
	var d := node.global_position - global_position
	return absf(d.x) <= 22.0 and absf(d.y) <= 24.0


func teleport(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
	_dash_timer = 0.0
	_attack_timer = 0.0
	_drink_timer = 0.0
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
