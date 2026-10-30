extends TestSuite
## Ground movement and jump feel: the numbers in design bible section 6.

const FLAT := [
	"##############################",
	"#............................#",
	"#............................#",
	"#............................#",
	"#............................#",
	"#............................#",
	"#............................#",
	"#............................#",
	"#............................#",
	"#............................#",
	"#............................#",
	"#............................#",
	"##############################",
]

const LEDGE := [
	"#####################",
	"#...................#",
	"#...................#",
	"#...................#",
	"#####...............#",
	"#...................#",
	"#...................#",
	"#...................#",
	"#...................#",
	"#...................#",
	"#...................#",
	"#...................#",
	"#...................#",
	"#...................#",
	"#####################",
]


func _settle(p: Player) -> void:
	await frames(6)


func test_settles_on_floor() -> void:
	var room := make_room(FLAT)
	var p := make_player(room, Vector2i(3, 11))
	await _settle(p)
	check(p.is_on_floor(), "player should rest on the floor")


func test_run_speed_and_acceleration() -> void:
	var room := make_room(FLAT)
	var p := make_player(room, Vector2i(3, 11))
	await _settle(p)
	var t := p.tuning
	var frames_to_max := -1
	for i in 30:
		p.input.move_x = 1
		await frames(1)
		if frames_to_max < 0 and is_equal_approx(p.velocity.x, t.run_speed):
			frames_to_max = i + 1
	check_near(p.velocity.x, t.run_speed, 0.01, "max run speed")
	check(frames_to_max > 0 and frames_to_max <= 7, "reaches max speed within 7 frames (got %d)" % frames_to_max)
	# Releasing stops quickly.
	var stop_frames := 0
	p.input.move_x = 0
	while absf(p.velocity.x) > 0.0 and stop_frames < 30:
		await frames(1)
		stop_frames += 1
	check(stop_frames <= 5, "stops within 5 frames (got %d)" % stop_frames)


## Pass 183 (Sean): a stick walks into a run the farther it leans. A light tilt
## walks at 40% of a run, the pace climbs with the tilt, and a full lean (or a
## key, or the d-pad) is the same run as ever, so jumps and dashes don't change.
func test_the_stick_walks_into_a_run_the_farther_it_leans() -> void:
	var t := MovementTuning.new()
	check(t.walk_fraction == 0.4 and t.walk_tilt == 0.45 and t.run_tilt == 0.9, "the bible's walk numbers (6.1)")
	check(t.speed_fraction(0.2) == 0.4 and t.speed_fraction(0.45) == 0.4, "a light tilt walks")
	check_near(t.speed_fraction(0.675), 0.7, 0.001, "halfway up the band, halfway to a run")
	check(t.speed_fraction(0.9) == 1.0 and t.speed_fraction(1.0) == 1.0, "near full tilt, a full run")
	var last := 0.0
	var climbs := true
	for i in 21:
		var f := t.speed_fraction(i / 20.0)
		climbs = climbs and f >= last
		last = f
	check(climbs, "the pace never drops as the stick leans further")
	# The real input: keys are full tilt; a stick's lean comes through.
	var input := PlayerInput.new()
	Input.action_press("move_right")
	input.poll()
	check(input.move_x == 1 and input.tilt == 1.0, "a key runs (tilt %.2f)" % input.tilt)
	Input.action_release("move_right")
	Input.action_press("move_left", 0.3)
	input.poll()
	check(input.move_x == -1 and is_equal_approx(input.tilt, 0.3), "a stick leaned 0.3 left walks (tilt %.2f)" % input.tilt)
	Input.action_release("move_left")
	input.poll()
	check(input.move_x == 0 and input.tilt == 1.0, "let go, nothing")
	# On the floor.
	var room := make_room(FLAT)
	var p := make_player(room, Vector2i(3, 11))
	await _settle(p)
	p.input.move_x = 1
	p.input.tilt = 0.3
	await frames(20)
	check_near(p.velocity.x, t.run_speed * t.walk_fraction, 0.5, "a light lean walks at %.0f px/s" % (t.run_speed * t.walk_fraction))
	check(PlayerVisual.current_pose(p) == "walk", "and looks it")
	var anim := PlayerVisual.anim_for(p, "walk")
	check(anim == ("walk" if Sheet.has_anim(PlayerVisual.sheet_for("walk"), "walk") else "run"), "the walk clip, or the run slowed until it exists (%s)" % anim)
	p.input.tilt = 1.0
	await frames(20)
	check_near(p.velocity.x, t.run_speed, 0.01, "lean all the way and it is the same run as a key")
	check(PlayerVisual.current_pose(p) == "run", "and looks it")
	p.input.move_x = 0


func test_full_jump_height_and_apex_time() -> void:
	var room := make_room(FLAT)
	var p := make_player(room, Vector2i(10, 11))
	await _settle(p)
	var start_y := p.global_position.y
	var min_y := start_y
	var apex_frame := 0
	p.input.jump_pressed = true
	p.input.jump_held = true
	for i in 70:
		await frames(1)
		if p.global_position.y < min_y:
			min_y = p.global_position.y
			apex_frame = i
	var t := p.tuning
	check_near(start_y - min_y, t.jump_height, 3.0, "full jump height (px)")
	check_near(apex_frame / 60.0, t.jump_time_to_apex, 0.07, "time to apex (s)")
	check(p.is_on_floor(), "lands again")


func test_tap_jump_is_short() -> void:
	var room := make_room(FLAT)
	var p := make_player(room, Vector2i(10, 11))
	await _settle(p)
	var start_y := p.global_position.y
	var min_y := start_y
	p.input.jump_pressed = true
	p.input.jump_held = true
	await frames(1)
	p.input.jump_held = false
	for i in 40:
		await frames(1)
		min_y = minf(min_y, p.global_position.y)
	var h := start_y - min_y
	check(h > 10.0 and h < 26.0, "tap jump height between 10 and 26 px (got %.1f)" % h)


func test_fall_speed_caps() -> void:
	var room := make_room(LEDGE)
	var p := make_player(room, Vector2i(10, 1))
	p.abilities["glove"] = false
	var max_vy := 0.0
	for i in 40:
		await frames(1)
		max_vy = maxf(max_vy, p.velocity.y)
	check(max_vy <= p.tuning.max_fall_speed + 0.01, "fall speed capped at %.0f (got %.1f)" % [p.tuning.max_fall_speed, max_vy])


func _walk_off_ledge(p: Player) -> int:
	# Runs right off the ledge; returns once the player has left the floor.
	for i in 60:
		p.input.move_x = 1
		await frames(1)
		if not p.is_on_floor():
			return i
	return -1


func test_coyote_time_allows_late_jump() -> void:
	var room := make_room(LEDGE)
	var p := make_player(room, Vector2i(2, 3), {"boots": false})
	await _settle(p)
	await _walk_off_ledge(p)
	await frames(4)  # 5 frames off the ledge = 0.083 s < 0.10 s coyote
	p.input.jump_pressed = true
	p.input.jump_held = true
	await frames(1)
	check(p.velocity.y < -300.0, "jump 5 frames after leaving the ledge (vy %.1f)" % p.velocity.y)


func test_coyote_time_expires() -> void:
	var room := make_room(LEDGE)
	var p := make_player(room, Vector2i(2, 3), {"boots": false})
	await _settle(p)
	await _walk_off_ledge(p)
	await frames(8)  # 9 frames = 0.15 s, past coyote and buffer leeway
	p.input.jump_pressed = true
	p.input.jump_held = true
	await frames(1)
	check(p.velocity.y > 0.0, "no jump 9 frames after leaving the ledge (vy %.1f)" % p.velocity.y)


func test_jump_buffer_before_landing() -> void:
	var room := make_room(FLAT)
	var p := make_player(room, Vector2i(10, 4), {"boots": false})
	var pressed := false
	var rose := false
	for i in 90:
		if not pressed and p.velocity.y > 0.0:
			# Press once the floor is about 5 frames of fall away.
			var look := Vector2(0, p.velocity.y / 60.0 * 5.0)
			if p.test_move(p.global_transform, look):
				p.input.jump_pressed = true
				p.input.jump_held = true
				pressed = true
		await frames(1)
		if pressed and p.velocity.y < -300.0:
			rose = true
			break
	check(pressed, "reached the press window")
	check(rose, "buffered jump fires on landing")


func test_corner_correction_slides_past_ceiling_edge() -> void:
	var rows := [
		"############",
		"#..........#",
		"#..........#",
		"#..........#",
		"#...#......#",
		"#..........#",
		"#..........#",
		"#..........#",
		"#..........#",
		"############",
	]
	# Block at cell (4,4) spans x 64..80. Player half-width is 6, so x = 62 overlaps by 4 px.
	var room := make_room(rows)
	var p := make_player(room, Vector2i(3, 8))
	p.position.x = 62.0
	await _settle(p)
	var start_y := p.global_position.y
	var min_y := start_y
	p.input.jump_pressed = true
	p.input.jump_held = true
	for i in 30:
		await frames(1)
		min_y = minf(min_y, p.global_position.y)
	check(start_y - min_y > 55.0, "corner correction lets the jump continue (rise %.1f)" % (start_y - min_y))
	check(p.global_position.x <= 58.5, "nudged sideways off the corner (x %.1f)" % p.global_position.x)


func test_one_way_platform_and_drop_through() -> void:
	var rows := [
		"##########",
		"#........#",
		"#........#",
		"#........#",
		"#........#",
		"#.------.#",
		"#........#",
		"#........#",
		"#........#",
		"##########",
	]
	var room := make_room(rows)
	var p := make_player(room, Vector2i(4, 8))
	await _settle(p)
	# Jump up through the platform from below.
	p.input.jump_pressed = true
	p.input.jump_held = true
	await frames(45)
	p.input.jump_held = false
	await frames(10)
	var platform_y := 5 * Room.TILE
	check(p.is_on_floor() and absf(p.global_position.y - platform_y) < 1.5, "jumped up onto the one-way platform (y %.1f)" % p.global_position.y)
	# Down + jump drops through.
	p.input.down = true
	p.input.jump_pressed = true
	await frames(1)
	p.input.down = false
	await frames(20)
	check(p.global_position.y > platform_y + 20.0, "dropped through the platform (y %.1f)" % p.global_position.y)


func _drift_room() -> Room:
	var rows := ["##############################"]
	for y in 28:
		rows.append("#...vvvvvv...................#")
	rows.append("##############################")
	return make_room(rows)


## Bible 8.9: in a wrong-gravity pocket the player keeps GravityDrift.PULL of
## their weight: a full jump rises well past the 9 tiles the checker allows,
## and a fall drifts down slowly.
func test_wrong_gravity_lifts_a_jump_and_slows_a_fall() -> void:
	var room := _drift_room()
	var p := make_player(room, Vector2i(6, 28))
	await _settle(p)
	var start_y := p.global_position.y
	var min_y := start_y
	p.input.jump_pressed = true
	p.input.jump_held = true
	var fastest := 0.0
	for i in 240:
		await frames(1)
		min_y = minf(min_y, p.global_position.y)
		fastest = maxf(fastest, p.velocity.y)
		if i > 10 and p.is_on_floor():
			break
	var rise := start_y - min_y
	check(rise >= 9.5 * Room.TILE, "a jump in the drift rises past nine tiles (%d px)" % rise)
	check(rise > p.tuning.jump_height * 2.0, "over twice a normal jump")
	check(fastest <= p.tuning.max_fall_speed * GravityDrift.PULL + 1.0, "and the fall drifts (%d px/s)" % fastest)
	check(p.is_on_floor(), "it lands again")
	# Outside the pocket, the jump is a plain jump.
	var q := make_player(room, Vector2i(20, 28))
	p.queue_free()
	await _settle(q)
	start_y = q.global_position.y
	min_y = start_y
	q.input.jump_pressed = true
	q.input.jump_held = true
	for i in 70:
		await frames(1)
		min_y = minf(min_y, q.global_position.y)
	check_near(start_y - min_y, q.tuning.jump_height, 3.0, "outside it a jump is a normal jump")


## A pool 10 tiles deep (rows 8-17) with a stone bank on its right whose top is
## level with the water (row 8).
func _pool_room() -> Room:
	var rows := ["##############################"]
	for y in range(1, 8):
		rows.append("#............................#")
	for y in range(8, 18):
		rows.append("#aaaaaaaaaaaaaaaa#############")
	rows.append("##############################")
	return make_room(rows)


## Bible 6.8: in deep water the player floats up to the surface, sinks while
## Down is held, strokes up with jump, moves slower, and jumps out from the surface.
func test_swimming_floats_sinks_strokes_and_jumps_out() -> void:
	var room := _pool_room()
	var p := make_player(room, Vector2i(6, 16))
	await frames(4)
	check(p.swimming, "deep in the pool the player is swimming")
	var surface := 8.0 * Room.TILE
	# Floats up to the surface and bobs there with the head out.
	for i in 240:
		await frames(1)
	var mid := p.body_rect().get_center().y
	check(absf(mid - surface) < 6.0, "floats up until the body's middle sits at the surface (%.1f vs %.1f)" % [mid, surface])
	check(p.global_position.y - Player.BODY_SIZE.y < surface, "with the head above the water")
	# Holding Down sinks, no faster than swim_sink.
	p.input.down = true
	var fastest := 0.0
	for i in 60:
		await frames(1)
		fastest = maxf(fastest, p.velocity.y)
	p.input.down = false
	check(p.global_position.y > surface + 3.0 * Room.TILE, "holding Down sinks (feet at %.0f)" % p.global_position.y)
	check(fastest <= p.tuning.swim_sink + 0.5, "slowly (%.0f px/s)" % fastest)
	# A jump press under water is a stroke up.
	var y0 := p.global_position.y
	p.input.jump_pressed = true
	await frames(1)
	check_near(p.velocity.y, -p.tuning.swim_stroke, 30.0, "a jump press under water is a stroke up")
	for i in 20:
		await frames(1)
	check(p.global_position.y < y0 - Room.TILE, "and it carries the body up (%.0f -> %.0f)" % [y0, p.global_position.y])
	# Swimming across is slower than running.
	p.input.move_x = 1
	var top := 0.0
	for i in 40:
		await frames(1)
		top = maxf(top, absf(p.velocity.x))
	p.input.move_x = 0
	check_near(top, p.tuning.run_speed * p.tuning.swim_speed_multiplier, 2.0, "swimming across is slower than a run")
	# At the surface, a jump is a full jump out onto the bank.
	p.global_position = Vector2(15 * Room.TILE + 8, surface + 20.0)
	p.velocity = Vector2.ZERO
	for i in 60:
		await frames(1)
	p.input.move_x = 1
	p.input.jump_pressed = true
	p.input.jump_held = true
	await frames(1)
	p.input.jump_held = true
	for i in 50:
		await frames(1)
		p.input.jump_held = true
		if p.is_on_floor():
			break
	p.input.move_x = 0
	check(p.is_on_floor() and not p.swimming and p.global_position.x > 17 * Room.TILE, "from the surface a jump carries you out onto the bank (%s)" % p.global_position)


## A 50-wide room with a current blowing east (`>`) across rows 6-9, cols 2-47,
## and a shelf on the floor (cols 20-24, top row 8) standing up into it.
func _wind_room() -> Room:
	var rows := ["##################################################"]
	for y in range(1, 18):
		var row := "#" + ".".repeat(48) + "#"
		if y >= 6 and y <= 9:
			row = "#." + ">".repeat(46) + ".#"
		if y >= 8:
			row = row.substr(0, 20) + "#####" + row.substr(25)
		rows.append(row)
	rows.append("##################################################")
	return make_room(rows)


## Bible 6.9: in the air in a current the player is carried along it and borne
## level; there's no headway against it; Down drops out; on a floor it does nothing.
func test_a_current_carries_you_and_bears_you_level() -> void:
	GameState.new_game()
	var room := _wind_room()
	var p := make_player(room, Vector2i(8, 9))
	p.global_position = Vector2(8 * Room.TILE, 8 * Room.TILE + 4)
	p.velocity = Vector2.ZERO
	await frames(2)
	var y0 := p.global_position.y
	var x0 := p.global_position.x
	for i in 40:
		await frames(1)
	check(p.velocity.x > p.tuning.wind_speed - 10.0, "with no input it is carried at the wind's speed (%.0f px/s)" % p.velocity.x)
	check(absf(p.global_position.y - y0) < Room.TILE, "and borne level, not falling (%.1f px)" % (p.global_position.y - y0))
	check(p.global_position.x > x0 + 80.0, "downwind (%.0f px)" % (p.global_position.x - x0))
	# Running against it: still carried downwind, slowly.
	p.global_position = Vector2(30 * Room.TILE, 8 * Room.TILE + 4)
	p.velocity = Vector2.ZERO
	p.input.move_x = -1
	await frames(2)
	x0 = p.global_position.x
	for i in 40:
		await frames(1)
	check(p.global_position.x > x0, "running against it makes no headway (%.0f px)" % (p.global_position.x - x0))
	p.input.move_x = 0
	# Down drops out.
	p.input.down = true
	y0 = p.global_position.y
	for i in 20:
		await frames(1)
	check(p.global_position.y > y0 + Room.TILE, "holding Down drops you out of it (%.0f px)" % (p.global_position.y - y0))
	p.input.down = false


func test_a_current_doesnt_move_you_on_a_floor() -> void:
	GameState.new_game()
	var room := _wind_room()
	var p := make_player(room, Vector2i(22, 7))
	for i in 20:
		await frames(1)
	var x0 := p.global_position.x
	for i in 30:
		await frames(1)
	check(p.is_on_floor() and absf(p.global_position.x - x0) < 1.0, "standing on the shelf in the current, you brace and stay put")


func test_the_spring_of_sky_turns_the_wind() -> void:
	GameState.new_game()
	var room := _wind_room()
	var w: WindCurrent = null
	for c in room.get_children():
		if c is WindCurrent:
			w = c
	check(w != null and w.dir() == 1, "a `>` current blows east")
	GameState.set_flag("spring:sky")
	check(w.dir() == -1, "once the Spring of Sky is restored it blows west")
	var p := make_player(room, Vector2i(8, 9))
	p.global_position = Vector2(30 * Room.TILE, 8 * Room.TILE + 4)
	await frames(2)
	var x0 := p.global_position.x
	for i in 30:
		await frames(1)
	check(p.global_position.x < x0 - 60.0, "and carries you west (%.0f px)" % (p.global_position.x - x0))
	GameState.new_game()


func test_wind_numbers_match_the_bible() -> void:
	var t := MovementTuning.new()
	check(t.wind_speed == 200.0 and t.wind_drag == 2400.0, "wind speed and drag are the bible's (6.9)")
	check(t.wind_speed > t.run_speed, "faster than a run, so there is no headway against it")


func test_sap_numbers_match_bible_6_12() -> void:
	var t := MovementTuning.new()
	check(t.sap_speed == 0.5 and t.sap_jump == 0.72, "sap holds the run to half and a jump to 72% (6.12)")
	var bible := FileAccess.get_file_as_string("res://docs/design-bible.md")
	check(bible.contains("### 6.12 Sap") and bible.contains("| Run | 50% of the pace"), "the bible has the sap section and its numbers")
	# A jump at 72% of its speed rises about half as high: (0.72)^2 of 72 px.
	check(absf(t.jump_height * t.sap_jump * t.sap_jump - 37.3) < 0.5, "about 37 px, a little over two tiles")


func test_swim_numbers_match_the_bible() -> void:
	var t := MovementTuning.new()
	check(t.swim_speed_multiplier == 0.7 and t.swim_float == 50.0 and t.swim_sink == 120.0, "swim speed, float and sink are the bible's (6.8)")
	check(t.swim_drag == 520.0 and t.swim_stroke == 230.0, "drag and stroke too")
	check(t.swim_stroke < t.jump_velocity, "a stroke is weaker than a jump")



# --- Bible 6.2 to 6.6, pinned (pass 107) -------------------------------------------

const LIP := [
	"################",
	"#..............#",
	"#..............#",
	"#..............#",
	"#..............#",
	"#..............#",
	"#..............#",
	"#..............#",
	"#.........######",
	"#.........######",
	"#.........######",
	"#.........######",
	"################",
]
## LIP's ledge: its top edge and its left face.
const LIP_TOP := 128.0
const LIP_FACE := 160.0


func test_movement_numbers_match_bible_6_2_to_6_6() -> void:
	var t := MovementTuning.new()
	# 6.2
	check_near(t.coyote_time, 0.10, 0.0001, "coyote time")
	check_near(t.jump_buffer_time, 0.12, 0.0001, "jump buffer")
	check(t.corner_correction_px == 6, "corner correction 6 px")
	check(t.ledge_correction_px == 4, "ledge correction 4 px")
	check(t.head_correction_px == 4, "head correction 4 px (pass 139)")
	# 6.3
	check_near(t.wall_slide_speed, 90.0, 0.0001, "wall slide speed")
	check_near(t.wall_stick_time, 0.08, 0.0001, "wall stick")
	check_near(t.wall_jump_x, 220.0, 0.0001, "wall jump outward")
	check_near(t.wall_jump_y, 380.0, 0.0001, "wall jump up")
	check_near(t.wall_climb_jump_x, 120.0, 0.0001, "climb jump outward")
	check_near(t.wall_jump_lock, 0.10, 0.0001, "wall jump input lock")
	check_near(t.wall_climb_jump_lock, 0.06, 0.0001, "climb jump input lock")
	check_near(t.wall_jump_blend, 0.10, 0.0001, "control blends back over 0.10 s")
	check_near(t.wall_coyote_time, 0.08, 0.0001, "wall coyote")
	# 6.4
	check_near(t.double_jump_height, 48.0, 0.0001, "double jump height")
	check_near(t.double_jump_velocity, 326.0, 1.0, "double jump velocity")
	# 6.5
	check_near(t.dash_speed, 380.0, 0.0001, "dash speed")
	check_near(t.dash_time, 0.15, 0.0001, "dash time")
	check_near(t.dash_invuln, 0.10, 0.0001, "dash invulnerability")
	check(t.air_dash_charges == 1, "one air dash")
	check_near(t.ground_dash_cooldown, 0.25, 0.0001, "ground dash cooldown")
	check_near(t.ground_dash_snap, 10.0, 0.0001, "ground dash snap")
	check_near(t.dash_buffer_time, 0.10, 0.0001, "dash buffer")
	# 6.6
	check_near(t.pogo_bounce, 380.0, 0.0001, "pogo bounce")
	check_near(t.pogo_bounce_held, 420.0, 0.0001, "pogo bounce, jump held")
	check_near(t.down_strike_active, 0.14, 0.0001, "down-strike active")
	# Pass 256: the swing's own timing, in the tuning since the prototype but
	# never in 6.6's table nor held by a test.
	check_near(t.slash_active, 0.10, 0.0001, "a slash or up-slash cuts for 0.10 s")
	check_near(t.attack_cooldown, 0.28, 0.0001, "an up-slash or down-strike recovers for 0.28 s")
	check(Player.DOWN_STRIKE_SIZE == Vector2(28, 24), "down-strike hitbox 28x24")
	# Pass 208: the rest of 6.6 and 6.10, until now only read back from the
	# tuning by their play tests, and the pogo's hit-stop, a literal in the player.
	check_near(t.pogo_hitstop, 0.045, 0.0001, "pogo hit-stop 45 ms")
	check_near(t.pod_bounce, 600.0, 0.0001, "bounce-pod launch")
	# 6.10
	check_near(t.glide_fall_speed, 60.0, 0.0001, "glide fall speed")
	check_near(t.glide_brake, 1500.0, 0.0001, "glide brake")
	# 5.3, the slash's push back
	check_near(t.slash_recoil, 120.0, 0.0001, "slash recoil")


## Pass 256: an up-slash cuts for `slash_active` and the next swing waits out
## `attack_cooldown`, however fast Attack is pressed.
func test_an_up_slash_cuts_then_recovers_as_6_6_says() -> void:
	var room := make_room(FLAT)
	var p := make_player(room, Vector2i(3, 11))
	await _settle(p)
	var t := p.tuning
	p.input.up = true
	p.input.attack_pressed = true
	await frames(1)
	check(p.attack_kind == "up" and p.is_attacking, "Up and Attack on the floor is an up-slash")
	var cutting := 0
	var next := -1
	var last := p._attack_timer
	for i in 40:
		p.input.attack_pressed = true
		await frames(1)
		if p._attack_timer > last:
			next = i + 1
			break
		if p._attack_timer > 0.0:
			cutting += 1
		last = p._attack_timer
	p.input.up = false
	check(absi(cutting - roundi(t.slash_active * 60.0)) <= 1, "it cuts for about %d frames (%d)" % [roundi(t.slash_active * 60.0), cutting])
	check(absi(next - roundi(t.attack_cooldown * 60.0)) <= 1, "and with Attack pressed every frame the next swing comes %d frames on (%d)" % [roundi(t.attack_cooldown * 60.0), next])


## Pass 200: 6.1 and the core of 6.2 were only read back from the tuning by the
## behaviour tests, so a changed number moved the test with it. These hold the
## numbers to the bible, and the tests after them hold what each one does.
func test_movement_numbers_match_bible_6_1_and_6_2() -> void:
	var t := MovementTuning.new()
	# 6.1
	check_near(t.run_speed, 165.0, 0.0001, "max run speed")
	check_near(t.ground_accel, 1800.0, 0.0001, "ground acceleration")
	check_near(t.ground_decel, 2600.0, 0.0001, "ground deceleration")
	check_near(t.turn_multiplier, 1.6, 0.0001, "turnaround boost")
	# 6.2
	check_near(t.jump_height, 72.0, 0.0001, "full jump height")
	check_near(t.jump_time_to_apex, 0.36, 0.0001, "time to apex")
	check_near(t.gravity, 1111.0, 1.0, "rising gravity, derived 2h/t^2")
	check_near(t.jump_velocity, 400.0, 0.5, "jump velocity, derived 2h/t")
	check_near(t.fall_gravity_multiplier, 1.6, 0.0001, "falling gravity x 1.6")
	check_near(t.jump_cut_multiplier, 0.45, 0.0001, "jump cut x 0.45")
	check_near(t.apex_threshold, 40.0, 0.0001, "apex hang below 40 px/s")
	check_near(t.apex_gravity_multiplier, 0.5, 0.0001, "apex hang x 0.5")
	check_near(t.max_fall_speed, 520.0, 0.0001, "max fall speed")
	check_near(t.max_fast_fall_speed, 620.0, 0.0001, "max fall speed holding Down")
	check_near(t.air_accel, 1400.0, 0.0001, "air acceleration")
	check_near(t.air_decel, 900.0, 0.0001, "air deceleration")
	# 5.3, Damage taken
	check_near(t.hurt_invuln, 0.8, 0.0001, "0.8 s invulnerability after a hit")


## Bible 6.1: pushing against your own run brakes at deceleration x 1.6, harder
## than letting go, so a turn comes round in a few frames.
func test_a_turn_brakes_harder_than_letting_go() -> void:
	var drops: Array[float] = []
	for reverse in [false, true]:
		var room := make_room(FLAT)
		var p := make_player(room, Vector2i(3, 11))
		await _settle(p)
		p.input.move_x = 1
		await frames(12)
		var before := p.velocity.x
		p.input.move_x = -1 if reverse else 0
		await frames(1)
		drops.append(before - p.velocity.x)
		var turned := -1
		for i in 20:
			if p.velocity.x <= -p.tuning.run_speed + 0.01:
				turned = i + 1
				break
			await frames(1)
		if reverse:
			check(turned > 0 and turned <= 9, "a turn is at full speed the other way within 9 frames (got %d)" % turned)
		room.free()
	var t := MovementTuning.new()
	check_near(drops[0], t.ground_decel / 60.0, 0.5, "letting go brakes at the deceleration")
	check_near(drops[1], t.ground_decel * t.turn_multiplier / 60.0, 0.5, "a turn brakes at 1.6x it")


## Bible 6.2: letting go of Jump on the way up keeps 0.45 of the rise.
func test_letting_go_of_jump_cuts_the_rise() -> void:
	var room := make_room(FLAT)
	var p := make_player(room, Vector2i(10, 11))
	await _settle(p)
	p.input.jump_pressed = true
	p.input.jump_held = true
	await frames(4)
	var before := p.velocity.y
	p.input.jump_held = false
	await frames(1)
	var g := p.tuning.gravity / 60.0
	check(before < -250.0, "still rising fast before the release (%.0f)" % before)
	check_near(p.velocity.y, before * p.tuning.jump_cut_multiplier + g, 0.5, "the release keeps 0.45 of the rise")
	room.free()


## Bible 6.2: a fall pulls 1.6x as hard as the rise, tops out at 520 px/s, and
## at 620 px/s while Down is held.
func test_a_fall_pulls_harder_and_down_falls_faster() -> void:
	var fastest: Array[float] = []
	var pull := 0.0
	for down in [false, true]:
		var room := make_room(LEDGE)
		var p := make_player(room, Vector2i(10, 1), {"glove": false})
		var top := 0.0
		for i in 40:
			var before := p.velocity.y
			p.input.down = down
			await frames(1)
			if not down and pull == 0.0 and before > 100.0 and p.velocity.y < p.tuning.max_fall_speed:
				pull = p.velocity.y - before
			top = maxf(top, p.velocity.y)
		fastest.append(top)
		room.free()
	var t := MovementTuning.new()
	check_near(pull, t.gravity * t.fall_gravity_multiplier / 60.0, 0.5, "a fall pulls at 1.6x the rising gravity")
	check_near(fastest[0], t.max_fall_speed, 0.01, "a fall tops out at 520 px/s")
	check_near(fastest[1], t.max_fast_fall_speed, 0.01, "holding Down it tops out at 620 px/s")


## Frames off a ledge before Jump is pressed -> whether it jumped.
func _jump_after_ledge(k: int) -> bool:
	var room := make_room(LEDGE)
	var p := make_player(room, Vector2i(2, 3), {"boots": false, "glove": false})
	await _settle(p)
	await _walk_off_ledge(p)
	await frames(k - 1)
	p.input.jump_pressed = true
	p.input.jump_held = true
	await frames(1)
	var jumped := p.velocity.y < -300.0
	room.free()
	return jumped


func test_coyote_time_is_a_tenth_of_a_second() -> void:
	# 0.10 s is 6 frames: a jump on the 6th frame off the ledge still counts.
	var last := 0
	for k in range(4, 10):
		if await _jump_after_ledge(k):
			last = k
	check(last == 6, "the last frame a ledge jump counts is the 6th, 0.10 s (got %d)" % last)


## Drops from row 4 onto FLAT's floor with Jump pressed `early` frames before
## the first frame on the floor (`land`, measured first); returns whether it jumped.
func _buffered_landing(early: int, land: int) -> bool:
	var room := make_room(FLAT)
	var p := make_player(room, Vector2i(10, 4), {"boots": false})
	var jumped := false
	for i in land + 4:
		if i == land - early:
			p.input.jump_pressed = true
			p.input.jump_held = true
		await frames(1)
		if p.velocity.y < -300.0:
			jumped = true
			break
	room.free()
	return jumped


func test_jump_buffer_holds_a_press_for_0_12_s() -> void:
	var room := make_room(FLAT)
	var p := make_player(room, Vector2i(10, 4), {"boots": false})
	var land := 0
	for i in 90:
		await frames(1)
		if p.is_on_floor():
			land = i + 1  # the next frame starts on the floor
			break
	room.free()
	check(land > 10, "the drop takes a while (%d frames)" % land)
	# 0.12 s is 7.2 frames: a press 7 frames early still jumps, 8 is too early.
	check(await _buffered_landing(7, land), "a press 7 frames (0.117 s) before landing jumps")
	check(await _buffered_landing(3, land), "a press 3 frames before landing jumps")
	check(not await _buffered_landing(8, land), "a press 8 frames (0.133 s) before landing is dropped")


## Jumps under a block that overhangs the body by `overlap` px; returns the rise.
func _rise_under_corner(overlap: float) -> float:
	var rows := [
		"############",
		"#..........#",
		"#..........#",
		"#..........#",
		"#...#......#",
		"#..........#",
		"#..........#",
		"#..........#",
		"#..........#",
		"############",
	]
	# The block at cell (4,4) starts at x 64; the body is 12 wide.
	var room := make_room(rows)
	var p := make_player(room, Vector2i(3, 8), {"boots": false})
	p.position.x = 64.0 - 6.0 + overlap
	await _settle(p)
	var start_y := p.global_position.y
	var min_y := start_y
	p.input.jump_pressed = true
	p.input.jump_held = true
	for i in 30:
		await frames(1)
		min_y = minf(min_y, p.global_position.y)
	room.free()
	return start_y - min_y


func test_corner_correction_reaches_6_px_and_no_further() -> void:
	check(await _rise_under_corner(6.0) > 55.0, "a 6 px overhang is slid past")
	check(await _rise_under_corner(7.0) < 40.0, "a 7 px overhang bumps the head")


## Falls toward LIP's ledge from `depth` px below its top, already touching it.
func _clip_lip(depth: float, glove: bool) -> bool:
	var room := make_room(LIP)
	var p := make_player(room, Vector2i(3, 3), {"glove": glove})
	await frames(1)  # a body collides only from its second frame
	p.position = Vector2(LIP_FACE - 6.0 - 0.3, LIP_TOP + depth)
	p.velocity = Vector2(p.tuning.run_speed, 0.0)
	for i in 12:
		p.input.move_x = 1
		await frames(1)
	var up := p.is_on_floor() and p.global_position.y <= LIP_TOP + 0.5
	room.free()
	return up


func test_ledge_correction_lifts_you_4_px_onto_a_ledge() -> void:
	for glove in [false, true]:
		var with := "with" if glove else "without"
		check(await _clip_lip(2.0, glove), "%s the glove, clipping a ledge by 2 px steps onto it" % with)
		check(await _clip_lip(4.0, glove), "%s the glove, clipping it by 4 px steps onto it" % with)
		check(not await _clip_lip(5.0, glove), "%s the glove, 5 px below the top is too far" % with)



# --- Pass 111: the core moves on special terrain ---------------------------------

const ONE_WAY_LEDGE := [
	"#####################",
	"#...................#",
	"#...................#",
	"#...................#",
	"#----...............#",
	"#...................#",
	"#...................#",
	"#...................#",
	"#...................#",
	"#...................#",
	"#...................#",
	"#...................#",
	"#...................#",
	"#...................#",
	"#####################",
]


func _jump_after_one_way_edge(k: int) -> bool:
	var room := make_room(ONE_WAY_LEDGE)
	var p := make_player(room, Vector2i(2, 3), {"boots": false, "glove": false})
	await _settle(p)
	await _walk_off_ledge(p)
	await frames(k - 1)
	p.input.jump_pressed = true
	p.input.jump_held = true
	await frames(1)
	var jumped := p.velocity.y < -300.0
	room.free()
	return jumped


## Bible 6.2: coyote time off a one-way platform's end is the same 0.10 s.
func test_coyote_time_off_a_one_way_platform() -> void:
	var last := 0
	for k in range(4, 10):
		if await _jump_after_one_way_edge(k):
			last = k
	check(last == 6, "the last frame a jump off a one-way's end counts is the 6th (got %d)" % last)


## Falls past the end of ONE_WAY_LEDGE's platform with the feet `d` px under its
## top, moving toward it; returns whether the player ends up standing on it.
func _clip_one_way_lip(d: float) -> bool:
	var room := make_room(ONE_WAY_LEDGE)
	var p := make_player(room, Vector2i(10, 13), {"boots": false, "glove": false})
	await frames(3)
	var lip := 5.0 * Room.TILE
	var top := 4.0 * Room.TILE
	p.teleport(Vector2(lip + Player.BODY_SIZE.x * 0.5 + 1.5, top + d))
	p.velocity = Vector2(-120, 0)
	var stood := false
	for i in 12:
		p.input.move_x = -1
		await frames(1)
		if p.is_on_floor() and p.global_position.y < top + 1.0:
			stood = true
	room.free()
	return stood


## Bible 6.2: ledge correction lifts you onto a one-way platform's lip as it does
## a solid ledge's. A one-way has no side to bump, so before pass 111 a clip of
## even 1 px fell straight past it.
func test_ledge_correction_lifts_you_onto_a_one_way_lip() -> void:
	for d in [1.0, 2.0, 4.0]:
		check(await _clip_one_way_lip(d), "a %.0f px clip steps up onto the one-way" % d)
	check(not await _clip_one_way_lip(5.0), "a 5 px clip doesn't")
	# Dropping through while running along it isn't lifted back up.
	var room := make_room(ONE_WAY_LEDGE)
	var p := make_player(room, Vector2i(2, 3), {"boots": false, "glove": false})
	await _settle(p)
	p.input.move_x = 1
	await frames(2)
	p.input.down = true
	p.input.jump_pressed = true
	await frames(1)
	p.input.down = false
	for i in 30:
		p.input.move_x = 1
		await frames(1)
	check(p.global_position.y > 8.0 * Room.TILE, "a drop-through on the run still drops (y %.0f)" % p.global_position.y)


## Bible 6.8: bobbing at the surface lifts the body clear of the water for a few
## frames. Water counts as footing for coyote time, so a jump pressed at any point
## of the bob jumps out on that frame (before pass 111 it could wait 6 frames, or
## come out as a weak stroke).
func test_a_jump_at_the_surface_jumps_out_at_any_point_of_the_bob() -> void:
	var late := 0
	var out_of_water := 0
	for phase in 20:
		var room := _pool_room()
		var p := make_player(room, Vector2i(6, 10), {"boots": false})
		await frames(240 + phase)
		if not p.swimming:
			out_of_water += 1
		p.input.jump_pressed = true
		p.input.jump_held = true
		await frames(1)
		if p.velocity.y > -300.0:
			late += 1
		room.free()
	check(out_of_water > 0, "the bob does lift the body out of the water (%d of 20 frames)" % out_of_water)
	check(late == 0, "a jump at every point of the bob jumps out at once (%d late)" % late)


## Bible 6.9: a wind current doesn't change coyote time.
func test_coyote_time_holds_in_a_wind_current() -> void:
	var rows := [
		"#####################",
		"#...................#",
		"#.....>>>>>>>>>>....#",
		"#.....>>>>>>>>>>....#",
		"#######>>>>>>>>>....#",
		"#.....>>>>>>>>>>....#",
		"#...................#",
		"#...................#",
		"#...................#",
		"#####################",
	]
	var last := 0
	for k in range(4, 10):
		var room := make_room(rows)
		var p := make_player(room, Vector2i(4, 3), {"boots": false, "glove": false})
		await _settle(p)
		await _walk_off_ledge(p)
		await frames(k - 1)
		p.input.jump_pressed = true
		p.input.jump_held = true
		await frames(1)
		if p.velocity.y < -300.0:
			last = k
		room.free()
	check(last == 6, "off a ledge into the wind, the 6th frame is still the last (got %d)" % last)


## Bible 8.9: in a drift pocket you fall slowly, but the jump buffer is still 0.12 s.
func test_the_jump_buffer_holds_in_a_drift_pocket() -> void:
	var rows := ["##############################"]
	for y in 12:
		rows.append("#...vvvvvv...................#")
	rows.append("##############################")
	var room := make_room(rows)
	var p := make_player(room, Vector2i(6, 3), {"boots": false})
	var land := 0
	for i in 400:
		await frames(1)
		if p.is_on_floor():
			land = i + 1
			break
	room.free()
	check(land > 30, "the drop is slow in the pocket (%d frames)" % land)
	for early in [7, 8]:
		room = make_room(rows)
		p = make_player(room, Vector2i(6, 3), {"boots": false})
		var jumped := false
		for i in land + 4:
			if i == land - early:
				p.input.jump_pressed = true
				p.input.jump_held = true
			await frames(1)
			if p.velocity.y < -300.0:
				jumped = true
				break
		room.free()
		check(jumped == (early == 7), "a press %d frames before landing %s" % [early, "jumps" if early == 7 else "is dropped"])


## Pass 115: a ramp up four tiles, a plateau, and a ramp back down (design bible 6.1).
const RAMP := [
	"##############################",
	"#............................#",
	"#............................#",
	"#............................#",
	"#............................#",
	"#............................#",
	"#............................#",
	"#............................#",
	"#............/######\\........#",
	"#.........../########\\.......#",
	"#........../##########\\......#",
	"#........./############\\.....#",
	"##############################",
]


## Bible 6.1: slopes up to 45 degrees are floor. You run up at full speed (along
## the slope), run down without leaving the ground, and stand still on one.
func test_slopes_keep_your_speed_and_your_footing() -> void:
	var room := make_room(RAMP)
	var p := make_player(room, Vector2i(4, 11))
	await _settle(p)
	var airborne := 0
	var up_speeds: Array[float] = []
	var down_speeds: Array[float] = []
	var x0 := p.global_position.x
	for i in 150:
		p.input.move_x = 1
		var before := p.global_position
		await frames(1)
		if not p.is_on_floor():
			airborne += 1
		var step := (p.global_position - before) * 60.0
		var x := p.global_position.x
		if x > 11.5 * 16 and x < 13.5 * 16:
			up_speeds.append(step.length())
		elif x > 21.5 * 16 and x < 23.5 * 16:
			down_speeds.append(step.length())
		if x > 26 * 16:
			break
	check(airborne == 0, "never leaves the ground over the ramps (%d frames in the air)" % airborne)
	check(not up_speeds.is_empty() and up_speeds.min() > p.tuning.run_speed * 0.9,
		"runs up at full speed along the slope (slowest %.0f px/s)" % (up_speeds.min() if not up_speeds.is_empty() else 0.0))
	check(not down_speeds.is_empty() and down_speeds.max() < p.tuning.run_speed * 1.1 and down_speeds.min() > p.tuning.run_speed * 0.9,
		"and down at the same speed (%.0f to %.0f px/s)" % [down_speeds.min() if not down_speeds.is_empty() else 0.0, down_speeds.max() if not down_speeds.is_empty() else 0.0])
	check(absf(p.global_position.y - 12 * 16) < 1.0, "and is back on the floor below (y %.1f)" % p.global_position.y)
	check(p.visual.position.y == 0.0, "where the sprite stands on its own feet again")
	check(p.global_position.x > x0 + 300.0, "having crossed it all")
	# Stand still halfway up a ramp: no creeping down it.
	p.teleport(Vector2(12.5 * 16, 9.5 * 16 - 2.0))
	p.input.move_x = 0
	await frames(20)
	var rest := p.global_position
	await frames(40)
	check(p.is_on_floor() and rest.distance_to(p.global_position) < 0.5,
		"stands still on a slope (moved %.2f px)" % rest.distance_to(p.global_position))
	# The box rests on its corner; the sprite is drawn down onto the slope.
	check(p.visual.position.y > Player.BODY_SIZE.x * 0.5 - 1.5, "the feet are drawn on the slope (sunk %.1f px)" % p.visual.position.y)
	# And a jump from a slope is the same jump as from flat ground.
	var vy: Array[float] = []
	for at: Vector2 in [Vector2(5.5 * 16, 12 * 16), rest]:
		p.teleport(at)
		p.velocity = Vector2.ZERO
		await frames(10)
		p.input.jump_pressed = true
		p.input.jump_held = true
		await frames(1)
		p.input.jump_pressed = false
		vy.append(-p.velocity.y)
		await frames(50)
	p.input.jump_held = false
	check(vy[0] > 300.0 and absf(vy[1] - vy[0]) < 1.0, "a jump from a slope is a full jump (%.1f, flat %.1f)" % [vy[1], vy[0]])
	room.free()


## Pass 121: a ground stride hugs the floor (bible 6.5). Down a slope the
## dash's 6 px a frame used to carry you off the ramp into the air for a third
## of a second; now it rides the slope down, as it already rode one up. A
## ledge deeper than the snap still drops away, and an air dash never snaps.
func test_a_ground_stride_follows_a_slope() -> void:
	var room := make_room(RAMP)
	var p := make_player(room, Vector2i(4, 11), {"stride": true})
	await _settle(p)
	# [start, dir, label]: down off the plateau's edge, down from mid-ramp, up a ramp.
	for run: Array in [[Vector2(17.5 * 16, 8 * 16), 1, "off the plateau down the ramp"],
			[Vector2(21.7 * 16, 9.4 * 16), 1, "down from mid-ramp"],
			[Vector2(8.5 * 16, 12 * 16), 1, "up a ramp"],
			[Vector2(16.5 * 16, 8 * 16), -1, "down the west ramp"]]:
		p.teleport(run[0])
		p.velocity = Vector2.ZERO
		await frames(15)
		check(p.is_on_floor(), "standing to start (%s)" % run[2])
		var start := p.global_position
		p.input.move_x = run[1]
		p.input.dash_pressed = true
		await frames(1)
		p.input.dash_pressed = false
		var air := 0
		var path := 0.0
		var last := p.global_position
		while p.is_dashing:
			await frames(1)
			path += last.distance_to(p.global_position)
			last = p.global_position
			if not p.is_on_floor():
				air += 1
		p.input.move_x = 0
		check(air == 0, "a ground stride %s keeps its footing (%d frames in the air)" % [run[2], air])
		check(path > p.tuning.dash_speed * p.tuning.dash_time * 0.9, "and covers a full stride along the floor (%.0f px)" % path)
		check(absf(p.global_position.y - start.y) > 8.0 or run[2] == "up a ramp" and p.global_position.y < start.y, "following the slope (%.0f px)" % (p.global_position.y - start.y))
		await frames(20)
	room.free()
	# Off a real ledge (a whole tile and more) the stride still sails out.
	room = make_room(LEDGE)
	p = make_player(room, Vector2i(2, 3), {"stride": true})
	await _settle(p)
	p.input.move_x = 1
	p.input.dash_pressed = true
	await frames(1)
	p.input.dash_pressed = false
	var y0 := p.global_position.y
	var flew := false
	while p.is_dashing:
		await frames(1)
		flew = flew or (not p.is_on_floor() and absf(p.global_position.y - y0) < 1.0)
	p.input.move_x = 0
	check(flew, "a stride off a ledge flies level out over the drop")
	room.free()
	check(MovementTuning.new().ground_dash_snap == 10.0, "the ground stride snaps from 10 px")


## A slope's face is floor, not a wall: with the Climbing Glove, falling against
## it never catches you in a wall slide, and the ledge clip leaves it alone.
func test_a_slope_is_floor_not_a_wall() -> void:
	var room := make_room(RAMP)
	var p := make_player(room, Vector2i(4, 11), {"glove": true})
	await _settle(p)
	var slid := false
	var walled := false
	# Fall onto each ramp's face, pushing into it.
	for start: Array in [[Vector2(10.6 * 16, 7 * 16), 1], [Vector2(23.4 * 16, 7 * 16), -1]]:
		p.teleport(start[0])
		p.velocity = Vector2.ZERO
		for i in 60:
			p.input.move_x = start[1]
			await frames(1)
			slid = slid or p.is_wall_sliding
			walled = walled or p.wall_dir != 0
			if p.is_on_floor() and i > 5:
				break
		check(p.is_on_floor(), "lands on the slope (%s)" % ("/" if start[1] > 0 else "\\"))
	p.input.move_x = 0
	check(not walled, "a slope is never a wall")
	check(not slid, "and never catches you in a slide")
	# A real wall still does.
	p.teleport(Vector2(1.5 * 16 + 1.0, 6 * 16))
	p.velocity = Vector2.ZERO
	var caught := false
	for i in 30:
		p.input.move_x = -1
		await frames(1)
		caught = caught or p.is_wall_sliding
	p.input.move_x = 0
	check(caught, "while the room's wall still catches you")
	room.free()


## Things that ask the room what is solid (seeds, globs, bolts) see the diagonal.
func test_a_slope_is_solid_below_its_diagonal() -> void:
	var room := make_room(RAMP)
	# `/` at (10, 11) rises east; `\` at (23, 11) rises west.
	check(room.is_solid_at(Vector2(10 * 16 + 14, 11 * 16 + 6)), "/ is solid under its high side")
	check(not room.is_solid_at(Vector2(10 * 16 + 2, 11 * 16 + 6)), "/ is open over its low side")
	check(room.is_solid_at(Vector2(23 * 16 + 2, 11 * 16 + 6)), "\\ is solid under its high side")
	check(not room.is_solid_at(Vector2(23 * 16 + 14, 11 * 16 + 6)), "\\ is open over its low side")
	room.free()


## Bible 6.11 (pass 124): a shaft with a ladder up through the floor of a loft,
## and a short ladder hanging in the air on the right.
const LADDERS := [
	"####################",
	"#..................#",
	"#..................#",
	"#..................#",
	"#########\"#########",
	"#........\"........#",
	"#........\"....\"...#",
	"#........\"....\"...#",
	"#........\"....\"...#",
	"#........\"........#",
	"#........\"........#",
	"####################",
]


func test_ladders_climb_hang_and_step_off_the_top() -> void:
	var room := make_room(LADDERS)
	var p := make_player(room, Vector2i(9, 10))
	await frames(3)
	var x_mid := 9.5 * 16.0
	p.global_position.x = x_mid + 5.0
	p.input.up = true
	await frames(1)
	check(p.on_ladder, "Up at a ladder takes hold of it")
	await frames(20)
	check(p.on_ladder and is_equal_approx(p.velocity.y, -MovementTuning.new().ladder_speed), "it climbs at ladder speed, with no gravity (vy %.0f)" % p.velocity.y)
	check(absf(p.global_position.x - x_mid) < 0.5, "and centers you on the rungs (x %.1f)" % p.global_position.x)
	check(PlayerVisual.current_pose(p) == "climb", "in the climbing pose")
	p.input.up = false
	var y := p.global_position.y
	await frames(30)
	check(p.on_ladder and absf(p.global_position.y - y) < 0.5, "let go of Up and you hang there")
	p.input.up = true
	for i in 120:
		await frames(1)
		if not p.on_ladder:
			break
	p.input.up = false
	await frames(5)
	check(not p.on_ladder and p.is_on_floor(), "over the top you step onto it")
	check(absf(p.global_position.y - 4 * 16.0) < 1.0, "standing on the ladder's top plank (y %.1f)" % p.global_position.y)
	# Back down: Down on the top plank climbs on.
	p.input.down = true
	await frames(2)
	check(p.on_ladder, "Down on the top takes hold again")
	for i in 120:
		await frames(1)
		if not p.on_ladder:
			break
	p.input.down = false
	await frames(3)
	check(p.is_on_floor() and absf(p.global_position.y - 11 * 16.0) < 1.0, "and climbing down onto the floor lets go (y %.1f)" % p.global_position.y)
	room.free()


func test_ladders_jump_off_hits_and_hanging_ends() -> void:
	var room := make_room(LADDERS)
	var p := make_player(room, Vector2i(9, 10))
	await frames(3)
	p.input.up = true
	await frames(30)
	p.input.up = false
	check(p.on_ladder, "on the ladder")
	var x0 := p.global_position.x
	p.input.move_x = 1
	p.input.jump_pressed = true
	p.input.jump_held = true
	await frames(1)
	check(not p.on_ladder and p.velocity.y < -300.0, "Jump leaves with a full jump (vy %.0f)" % p.velocity.y)
	await frames(10)
	check(p.global_position.x > x0 + 10.0, "off to the side you pressed")
	p.input.move_x = 0
	p.input.jump_held = false
	p.input.up = true
	await frames(1)
	check(not p.on_ladder, "and can't catch the same ladder again straight away")
	p.input.up = false
	# A blow knocks you off.
	p.teleport(Vector2(9.5 * 16.0, 11 * 16.0))
	await frames(3)
	p.input.up = true
	await frames(20)
	p.input.up = false
	check(p.on_ladder, "back on the ladder")
	p.take_damage(1)
	await frames(1)
	check(not p.on_ladder, "a blow knocks you off the rungs")
	await frames(20)
	# The hanging ladder: climb down off its bottom and you fall.
	p.teleport(Vector2(14.5 * 16.0, 8 * 16.0 + 2.0))
	p.input.up = true
	await frames(1)
	p.input.up = false
	check(p.on_ladder, "you catch a hanging ladder from the air")
	p.input.down = true
	for i in 90:
		await frames(1)
		if not p.on_ladder:
			break
	p.input.down = false
	check(not p.on_ladder, "climb off its bottom and you let go")
	await frames(30)
	check(p.is_on_floor(), "and drop to the floor")
	room.free()


func _until(cond: Callable, max_frames: int) -> bool:
	for i in max_frames:
		if cond.call():
			return true
		await frames(1)
	return cond.call()


## Bible 6.11 (pass 280): taking hold of a ladder refreshes the double jump
## and the air dash; a swing in progress can't take hold until it ends; and on
## the rungs there are no attacks: a swing, a throw or a spell pressed there
## does nothing, and you stay on.
func test_a_ladder_refreshes_air_moves_and_holds_no_attacks() -> void:
	var room := make_room(LADDERS)
	var p := make_player(room, Vector2i(9, 10), {"rune_dagger": true})
	await frames(3)
	# From the air, with the double jump and the air dash spent.
	p.teleport(Vector2(14.5 * 16.0, 7 * 16.0))
	await frames(2)
	check(not p.is_on_floor(), "in the air beside the hanging ladder")
	p.has_double_jump = false
	p.air_dash_charges = 0
	p.input.up = true
	await frames(1)
	p.input.up = false
	check(p.on_ladder, "you catch the hanging ladder from the air")
	check(p.has_double_jump and p.air_dash_charges >= 1, "and taking hold gives back the double jump and the air dash (%s, %d)" % [p.has_double_jump, p.air_dash_charges])
	p.input.down = true
	await _until(func() -> bool: return not p.on_ladder, 120)
	p.input.down = false
	await frames(30)
	# Mid-swing at the foot of the long ladder: Up waits for the swing to end.
	p.teleport(Vector2(9.5 * 16.0, 11 * 16.0))
	await frames(3)
	p.input.attack_pressed = true
	await frames(1)
	check(p.is_attacking, "a swing starts")
	p.input.up = true
	await frames(1)
	check(not p.on_ladder, "mid-swing, Up does not take hold")
	await _until(func() -> bool: return p.on_ladder, 60)
	check(p.on_ladder and not p.is_attacking, "once the swing ends, it does")
	await frames(20)
	p.input.up = false
	await frames(2)
	# On the rungs: no swing, no throw, no spell.
	var y := p.global_position.y
	var mp := p.mp
	var throws := p.throws
	var kids := room.get_child_count()
	p.input.attack_pressed = true
	await frames(1)
	p.input.throw_pressed = true
	await frames(1)
	p.input.spell_pressed = true
	await frames(10)
	check(p.on_ladder and absf(p.global_position.y - y) < 0.5, "you stay on the rungs (y %.1f -> %.1f)" % [y, p.global_position.y])
	check(not p.is_attacking, "a swing pressed on a ladder does not swing")
	check(p.throws == throws, "nor does a throw throw")
	check(p.mp >= mp and room.get_child_count() == kids, "nor a spell cast (mp %.0f -> %.0f, nodes %d -> %d)" % [mp, p.mp, kids, room.get_child_count()])
	room.free()


## Dash on a ladder (bible 6.11, pass 240): a stride leaves the rungs and
## dashes; a press that can't dash (no Elven Stride yet) keeps you on them.
func test_a_dash_only_lets_go_of_a_ladder_when_it_dashes() -> void:
	var room := make_room(LADDERS)
	var p := make_player(room, Vector2i(9, 10), {"stride": false})
	await frames(3)
	p.input.up = true
	await frames(30)
	p.input.up = false
	check(p.on_ladder, "on the ladder")
	var y := p.global_position.y
	p.input.dash_pressed = true
	await frames(1)
	await frames(20)
	check(p.on_ladder and not p.is_dashing and absf(p.global_position.y - y) < 0.5, "without the Elven Stride a dash press keeps you on the rungs (y %.1f -> %.1f)" % [y, p.global_position.y])
	p.abilities["stride"] = true
	p.input.move_x = 1
	p.input.dash_pressed = true
	await frames(1)
	check(not p.on_ladder and p.is_dashing, "with it, the stride leaves the ladder and dashes")
	await frames(9)
	check(p.global_position.x > 9.5 * 16.0 + 40.0, "off to the side (x %.1f)" % p.global_position.x)
	p.input.move_x = 0
	room.free()


## The camera on a ladder (bible 6.7, pass 130): it leads the way you climb.
func test_the_camera_leads_the_way_up_or_down_a_ladder() -> void:
	check(GameCamera.CLIMB_LEAD == 64.0 and GameCamera.CLIMB_LEAD_EASE == 0.5, "the climb lead is 64 px, eased over 0.5 s")
	var room := make_room(LADDERS)
	var p := make_player(room, Vector2i(9, 10))
	var cam := GameCamera.new()
	cam.target = p
	cam.view_size = Vector2(160, 90)
	cam.set_room_limits(room.pixel_rect())
	arena.add_child(cam)
	await frames(30)
	check(absf(cam._climb_lead) < 0.5, "off a ladder there is no lead")
	p.input.up = true
	await frames(40)
	check(p.on_ladder and cam._climb_lead < -0.8 * GameCamera.CLIMB_LEAD, "climbing up, it looks up the ladder (%.1f)" % cam._climb_lead)
	check(absf(cam._look_ahead) < 0.3 * GameCamera.LOOK_AHEAD, "and stops looking sideways (%.1f)" % cam._look_ahead)
	p.input.up = false
	await frames(30)
	check(p.on_ladder and cam._climb_lead < -0.8 * GameCamera.CLIMB_LEAD, "hanging still keeps the lead (%.1f)" % cam._climb_lead)
	p.input.down = true
	await frames(30)
	check(cam._climb_lead > 0.8 * GameCamera.CLIMB_LEAD, "climbing down, it looks down (%.1f)" % cam._climb_lead)
	for i in 120:
		await frames(1)
		if not p.on_ladder:
			break
	p.input.down = false
	await frames(40)
	check(not p.on_ladder and absf(cam._climb_lead) < 0.1 * GameCamera.CLIMB_LEAD, "off the ladder it eases back (%.1f)" % cam._climb_lead)
	cam.queue_free()


func test_ladder_numbers_match_bible_6_11() -> void:
	var t := MovementTuning.new()
	check(t.ladder_speed == 90.0, "ladder speed 90 px/s")
	check(t.ladder_snap == 240.0, "ladder snap 240 px/s")
	check(t.ladder_regrab == 0.25, "regrab 0.25 s")
	var bible := FileAccess.get_file_as_string("res://docs/design-bible.md")
	check(bible.contains("### 6.11 Ladders"), "the bible has the ladder section")
	check(bible.contains("| Climb speed | 90 px/s"), "and its numbers")



## Pass 137 (bible 13.3): a field that takes hold of you is heard. A wind
## current's gust catches you; a wrong-gravity pocket shimmers as it lifts your
## weight and hums down as you leave it, and the edge does not chatter.
func test_wind_and_wrong_gravity_are_heard() -> void:
	var rows := ["##############################"]
	for y in 12:
		rows.append("#...vvvvvv...................#")
	rows.append("##############################")
	var room := make_room(rows)
	Sfx.recent.clear()
	var p := make_player(room, Vector2i(6, 3), {"boots": false})
	await frames(4)
	check(Sfx.recent.count("drift_in") == 1, "the pocket lifts your weight with a shimmer, once (%s)" % [Sfx.recent])
	for i in 300:
		await frames(1)
		if p.is_on_floor():
			break
	p.input.move_x = 1
	for i in 120:
		await frames(1)
		if Sfx.recent.has("drift_out"):
			break
	p.input.move_x = 0
	check(Sfx.recent.has("drift_out") and not p.gravity_scale < 1.0, "and walking out, the weight returns with a hum")
	check(Sfx.recent.count("drift_in") == 1 and Sfx.recent.count("drift_out") == 1, "each cue sounds once at the edge")
	room.free()

	rows = [
		"#####################",
		"#...................#",
		"#.....>>>>>>>>>>....#",
		"#.....>>>>>>>>>>....#",
		"#######>>>>>>>>>....#",
		"#.....>>>>>>>>>>....#",
		"#...................#",
		"#...................#",
		"#...................#",
		"#####################",
	]
	room = make_room(rows)
	p = make_player(room, Vector2i(4, 3), {"boots": false, "glove": false})
	await _settle(p)
	Sfx.recent.clear()
	check(not Sfx.recent.has("wind_catch"), "no gust on the ledge")
	await _walk_off_ledge(p)
	await frames(10)
	check(Sfx.recent.count("wind_catch") == 1, "off the ledge, the current catches you with a gust, once (%s)" % [Sfx.recent])
	check(Player.FIELD_CUE_GAP == 0.3, "a cue waits 0.3 s before it may sound again")
	room.free()



## Pass 139 (bible 6.2, 6.5): a mid-air dash that clips the top of a tunnel's
## mouth with the head by up to 4 px slides in; 5 px stops on the lip.
const TUNNEL := [
	"######################",
	"#.........############",
	"#.........############",
	"#.........############",
	"#.........############",
	"#.........############",
	"#.........############",
	"#.........############",
	"#.........############",
	"#.........############",
	"#....................#",
	"#....................#",
	"#....................#",
	"#.........############",
	"#.........############",
	"#.........############",
	"######################",
]


func _dash_into_tunnel(clip: float) -> bool:
	var room := make_room(TUNNEL)
	var p := make_player(room, Vector2i(5, 15), {"stride": true, "boots": false})
	await _settle(p)
	# Hang with the head `clip` px above the tunnel's ceiling (y 160), just short of its mouth.
	p.teleport(Vector2(9 * 16 + 2, 160.0 - clip + 40.0))
	p.velocity = Vector2.ZERO
	p.input.move_x = 1
	p.input.dash_pressed = true
	await frames(12)
	p.input.move_x = 0
	var inside := p.global_position.x > 10 * 16 + 20
	room.free()
	return inside


func test_head_correction_slides_a_dash_into_a_tunnel() -> void:
	check(await _dash_into_tunnel(2.0), "clipping the tunnel's top by 2 px, the dash slides in")
	check(await _dash_into_tunnel(4.0), "by 4 px, it still slides in")
	check(not await _dash_into_tunnel(5.0), "by 5 px, it stops on the lip")


## Pass 264 (bible 6.5): what the feet kick up takes the ground's look, as the
## steps take its sound. A landing on stone puffs pale dust, in the Mist's marsh
## it flings dark mud, and in Dartmoor's standing water it throws spray that
## falls back. The run, the jump and a dash along the floor do the same.
func test_what_the_feet_kick_up_takes_the_ground_s_look() -> void:
	var landing := func(room: Room) -> Dust:
		for i in 90:
			await frames(1)
			for c in room.get_children():
				if c is Dust and c.kind == "land":
					return c
		return null
	var stone := Room.from_text(room_text(["name: T", "zone: tower", "surface: stone"], grid_rows(10, 23)), "t/stone")
	arena.add_child(stone)
	var p := make_player(stone, Vector2i(5, 12))
	var d: Dust = await landing.call(stone)
	check(d != null and d.surface == "" and d._color == Dust.KINDS["land"]["color"], "a landing on stone puffs pale dust")
	stone.queue_free()
	await frames(1)
	var marsh := Room.from_text(room_text(["name: T", "zone: mist"], grid_rows(10, 23)), "t/marsh")
	arena.add_child(marsh)
	p = make_player(marsh, Vector2i(5, 12))
	d = await landing.call(marsh)
	check(d != null and d.surface == "mud" and d._color == Dust.GROUND_TINT["mud"], "in the marsh it flings mud (%s)" % (d.surface if d else "none"))
	await frames(10)
	p.input.move_x = 1
	var kicked := ""
	for i in 40:
		await frames(1)
		for c in marsh.get_children():
			if c is Dust and c.kind == "run":
				kicked = c.surface
	p.input.move_x = 0
	check(kicked == "mud", "and the run kicks up mud too (%s)" % kicked)
	marsh.queue_free()
	await frames(1)
	var w := make_world({}, "dartmoor/flooded_hall")
	await frames(3)
	var tide: Tide = w.room.tide
	var wade := Vector2(w.room.size_tiles.x * 0.5 * Room.TILE, (tide.row + 1) * Room.TILE)
	while w.room.tiles.get_cell_source_id(w.room.cell_at(wade + Vector2(0, 2))) == -1 or w.room.tiles.get_cell_source_id(w.room.cell_at(wade + Vector2(0, -Room.TILE + 2))) != -1:
		wade.x += Room.TILE
	w.player.teleport(wade - Vector2(0, Room.TILE * 5))
	d = await landing.call(w.room)
	check(d != null and d.surface == "wade" and d._color == Dust.GROUND_TINT["wade"], "in standing water a landing throws spray (%s)" % (d.surface if d else "none"))
	if d != null:
		var up := 0
		for q: Array in d._particles:
			if (q[1] as Vector2).y < 0.0:
				up += 1
		check(up == d._particles.size() and d._rise > 0.0, "thrown up, every drop, to fall back (%d of %d)" % [up, d._particles.size()])
	GameState.set_flag(Tide.DRAIN_FLAG)
	w._enter("dartmoor/flooded_hall")
	await frames(3)
	w.player.teleport(wade - Vector2(0, Room.TILE * 5))
	d = await landing.call(w.room)
	check(d != null and d.surface == "", "drained, the hall's floor puffs dust again")
	GameState.data.flags.erase(Tide.DRAIN_FLAG)


## Pass 272: bible 4.4 says Dartmoor's standing water (pass 259) is not deep
## enough to swim, and that it neither slows you nor hides a hazard. Nothing
## held that: a tide cell that read as swimming water, or a drag on the wade,
## would have passed every test. Here, in the Flooded Hall's water: the run
## reaches full speed, a jump rises its full height, and the spike pit under
## the surface still bites, all without a stroke of swimming.
func test_wading_neither_slows_nor_floats_nor_hides_the_spikes() -> void:
	var w := make_world({}, "dartmoor/flooded_hall", cell_feet(10, 19))
	for c in w.room.get_children():
		if c is Enemy:
			c.queue_free()
	await frames(3)
	var p := w.player
	var t := p.tuning
	var tide: Tide = w.room.tide
	check(tide != null and not tide.drained(), "the hall stands in water")
	if tide == null:
		return
	await _settle(p)
	check(w.room.surface_at(p.global_position + Vector2(0, 2)) == "wade", "the hero stands in it (%s)" % w.room.surface_at(p.global_position + Vector2(0, 2)))
	# Run east through the water, short of the pit (tiles 26-29).
	var swam := false
	var top := 0.0
	p.input.move_x = 1
	for i in 36:
		await frames(1)
		swam = swam or p.swimming
		top = maxf(top, p.velocity.x)
	p.input.move_x = 0
	check(not swam, "wading is not swimming")
	check_near(top, t.run_speed, 1.0, "the run reaches full speed in the water (px/s)")
	await _settle(p)
	var start_y := p.global_position.y
	var min_y := start_y
	p.input.jump_pressed = true
	p.input.jump_held = true
	for i in 70:
		await frames(1)
		swam = swam or p.swimming
		min_y = minf(min_y, p.global_position.y)
	p.input.jump_held = false
	check_near(start_y - min_y, t.jump_height, 3.0, "a jump out of the water rises its full height (px)")
	check(not swam, "and never takes a stroke")
	# The pit under the surface: water to the spikes, and the spikes still bite.
	var pit := Vector2i(27, 20)
	check(tide.has_point(Vector2(pit) * Room.TILE + Vector2(8, 8)), "the spike pit is full of water")
	p.max_hp = 999
	p.hp = 999
	p.teleport(w.room.to_global(Vector2(pit.x * Room.TILE + Room.TILE * 0.5, pit.y * Room.TILE + 4)))
	for i in 40:
		await frames(1)
		swam = swam or p.swimming
		if p.hp < 999:
			break
	check(p.hp < 999, "the spikes under the water still hurt (hp %d)" % p.hp)
	check(not swam, "and the pit is waded, not swum")
