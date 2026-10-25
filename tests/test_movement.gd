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


func test_swim_numbers_match_the_bible() -> void:
	var t := MovementTuning.new()
	check(t.swim_speed_multiplier == 0.7 and t.swim_float == 50.0 and t.swim_sink == 120.0, "swim speed, float and sink are the bible's (6.8)")
	check(t.swim_drag == 520.0 and t.swim_stroke == 230.0, "drag and stroke too")
	check(t.swim_stroke < t.jump_velocity, "a stroke is weaker than a jump")
