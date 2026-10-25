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
	# 6.6
	check_near(t.pogo_bounce, 380.0, 0.0001, "pogo bounce")
	check_near(t.pogo_bounce_held, 420.0, 0.0001, "pogo bounce, jump held")
	check_near(t.down_strike_active, 0.14, 0.0001, "down-strike active")
	check(Player.DOWN_STRIKE_SIZE == Vector2(28, 24), "down-strike hitbox 28x24")


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
