extends TestSuite
## Ability moves: wall slide and wall jump, double jump, dash, pogo.

const SHAFT := [
	"################",
	"#..............#",
	"#..............#",
	"#..............#",
	"#..............#",
	"#..............#",
	"#..............#",
	"#..............#",
	"#..............#",
	"#..............#",
	"#..............#",
	"#..............#",
	"#..............#",
	"#..............#",
	"#..............#",
	"#..............#",
	"#..............#",
	"#..............#",
	"#..............#",
	"################",
]

## Top of the spike hitbox in SPIKE_FLOOR (row 10 bottom minus 9 px).
const SPIKE_TOP := 11 * 16 - 9

const SPIKE_FLOOR := [
	"####################",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..^^^^^^^^^^^^^^..#",
	"####################",
]


## Puts the player in the air against the right wall of the shaft, holding into it.
func _start_on_right_wall(abilities := {}) -> Player:
	var room := make_room(SHAFT)
	var p := make_player(room, Vector2i(14, 6), abilities)
	p.input.move_x = 1
	await frames(20)
	return p


func test_wall_slide_caps_fall_speed() -> void:
	var p := await _start_on_right_wall()
	await frames(20)
	check(p.is_wall_sliding, "sliding while holding into the wall")
	check(p.velocity.y <= p.tuning.wall_slide_speed + 0.01, "slide speed capped at %.0f (got %.1f)" % [p.tuning.wall_slide_speed, p.velocity.y])


func test_no_wall_slide_without_glove() -> void:
	var p := await _start_on_right_wall({"glove": false})
	await frames(5)
	check(not p.is_wall_sliding, "no wall slide without the Climbing Glove")
	check(p.velocity.y > p.tuning.wall_slide_speed, "falls at full speed (vy %.1f)" % p.velocity.y)


func test_wall_jump_away() -> void:
	var p := await _start_on_right_wall()
	p.input.move_x = -1
	p.input.jump_pressed = true
	p.input.jump_held = true
	await frames(1)
	check_near(p.velocity.x, -p.tuning.wall_jump_x, 1.0, "wall jump horizontal speed")
	check(p.velocity.y < -340.0, "wall jump launches upward (vy %.1f)" % p.velocity.y)
	check(p.facing == -1, "faces away from the wall")


func test_wall_climb_on_one_wall() -> void:
	var p := await _start_on_right_wall({"boots": false})
	var start_y := p.global_position.y
	p.input.move_x = 1
	for jump in 4:
		# Wait until touching the wall again, then jump.
		for i in 40:
			await frames(1)
			if p.wall_dir == 1:
				break
		p.input.jump_pressed = true
		p.input.jump_held = true
		await frames(1)
	await frames(10)
	check(start_y - p.global_position.y > 64.0, "four climb jumps gain height on one wall (gained %.1f)" % (start_y - p.global_position.y))


func test_double_jump_adds_height() -> void:
	var room := make_room(SHAFT)
	var p := make_player(room, Vector2i(7, 18), {"glove": false})
	await frames(6)
	p.input.jump_pressed = true
	p.input.jump_held = true
	var apex_y := p.global_position.y
	for i in 40:
		await frames(1)
		if p.velocity.y >= 0.0:
			apex_y = p.global_position.y
			break
	p.input.jump_pressed = true
	var min_y := apex_y
	for i in 40:
		await frames(1)
		min_y = minf(min_y, p.global_position.y)
	check_near(apex_y - min_y, p.tuning.double_jump_height, 4.0, "double jump extra height (px)")
	check(not p.has_double_jump, "double jump is spent")


func test_double_jump_needs_wing_boots() -> void:
	var room := make_room(SHAFT)
	var p := make_player(room, Vector2i(7, 10), {"boots": false, "glove": false})
	await frames(10)
	p.input.jump_pressed = true
	p.input.jump_held = true
	await frames(1)
	check(p.velocity.y > 0.0, "no mid-air jump without Wing Boots (vy %.1f)" % p.velocity.y)


func test_ground_dash_distance() -> void:
	var room := make_room(SHAFT)
	var p := make_player(room, Vector2i(2, 18))
	await frames(6)
	var x0 := p.global_position.x
	p.input.dash_pressed = true
	await frames(1)
	check(p.is_dashing, "dash started")
	var n := 1
	while p.is_dashing and n < 30:
		await frames(1)
		n += 1
	var expected := p.tuning.dash_speed * p.tuning.dash_time
	check_near(p.global_position.x - x0, expected, 7.0, "dash distance (px)")


func test_air_dash_holds_height_and_uses_charge() -> void:
	var room := make_room(SHAFT)
	var p := make_player(room, Vector2i(3, 5), {"glove": false})
	await frames(2)
	p.input.dash_pressed = true
	await frames(1)
	var y0 := p.global_position.y
	await frames(6)
	check_near(p.global_position.y, y0, 0.5, "no vertical movement during air dash")
	await frames(6)
	p.input.dash_pressed = true
	await frames(1)
	check(not p.is_dashing, "second air dash refused with one charge")


func test_dash_needs_elven_stride() -> void:
	var room := make_room(SHAFT)
	var p := make_player(room, Vector2i(2, 18), {"stride": false})
	await frames(6)
	p.input.dash_pressed = true
	await frames(1)
	check(not p.is_dashing, "no dash without Elven Stride")


func _drop_onto_spikes(abilities := {}) -> Player:
	var room := make_room(SPIKE_FLOOR)
	var p := make_player(room, Vector2i(9, 3), abilities)
	return p


func test_pogo_off_spikes() -> void:
	var p := _drop_onto_spikes()
	p.abilities["boots"] = true
	var bounced := false
	for i in 60:
		if p.velocity.y > 0.0 and p.global_position.y > SPIKE_TOP - 28.0 and not p.is_attacking:
			p.input.down = true
			p.input.attack_pressed = true
		await frames(1)
		if p.velocity.y < -300.0:
			bounced = true
			break
	check(bounced, "bounced off the spikes")
	check(p.hp == p.max_hp, "took no damage while pogoing (hp %d)" % p.hp)
	check(p.has_double_jump and p.air_dash_charges == p.tuning.air_dash_charges, "pogo refreshes double jump and dash")


func test_spikes_hurt_without_pogo() -> void:
	var p := _drop_onto_spikes()
	for i in 60:
		await frames(1)
		if p.hp < p.max_hp:
			break
	check(p.hp < p.max_hp, "spikes deal damage")
	check(p.invulnerable, "brief invulnerability after a hit")


func test_no_pogo_without_mattock() -> void:
	var p := _drop_onto_spikes({"mattock": false})
	for i in 60:
		if p.velocity.y > 0.0 and p.global_position.y > SPIKE_TOP - 28.0 and not p.is_attacking:
			p.input.down = true
			p.input.attack_pressed = true
		await frames(1)
		if p.hp < p.max_hp:
			break
	check(p.hp < p.max_hp, "without the Mattock the down-attack does not pogo")


const POD_FLOOR := [
	"####################",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#........@.........#",
	"####################",
]


func test_bounce_pod_throws_you_nine_tiles_up() -> void:
	var room := make_room(POD_FLOOR)
	var p := make_player(room, Vector2i(9, 10), {"boots": true, "stride": true})
	p.has_double_jump = false
	var launched := false
	var base_y := 0.0
	for i in 90:
		await frames(1)
		if p.velocity.y < -540.0:
			launched = true
			base_y = p.global_position.y
			break
	check(launched, "falling onto the pod launches the player")
	check_near(p.velocity.y, -p.tuning.pod_bounce, 30.0, "at the pod's launch speed")
	check(p.has_double_jump, "and gives the double jump back")
	p.input.jump_held = false
	var top := base_y
	for i in 80:
		await frames(1)
		top = minf(top, p.global_position.y)
		if p.velocity.y > 0.0:
			break
	var rise := base_y - top
	var expected := p.tuning.pod_bounce * p.tuning.pod_bounce / (2.0 * p.tuning.gravity)
	check(rise >= expected * 0.85 and rise <= expected + 4.0 and rise >= 8.5 * 16, "it rises about nine tiles, released jump or not (%.0f px of %.0f)" % [rise, expected])


func test_walking_into_a_bounce_pod_does_nothing_but_a_hop_launches() -> void:
	var room := make_room(POD_FLOOR)
	var p := make_player(room, Vector2i(4, 16), {})
	await frames(5)
	p.input.move_x = 1
	var launched := false
	for i in 40:
		await frames(1)
		if p.velocity.y < -450.0:
			launched = true
	p.input.move_x = 0
	check(not launched, "the pod isn't solid and walking through it doesn't launch")
	p.teleport(Vector2(9 * 16 + 8, 17 * 16))
	await frames(5)
	p.input.jump_pressed = true
	p.input.jump_held = false
	for i in 60:
		await frames(1)
		if p.velocity.y < -540.0:
			launched = true
			break
	check(launched, "a hop on the spot lands on it and launches")


## Bible A8: the Hour Glass stops time for 2.5 s and runs back for 8 s.
func test_hour_glass_stops_time_then_runs_back() -> void:
	var room := make_room(SHAFT)
	var p := make_player(room, Vector2i(7, 18), {"hourglass": true})
	await frames(5)
	p.input.hourglass_pressed = true
	await frames(2)
	check(TimeStop.active(), "turning the glass stops time")
	await frames(int(TimeStop.DURATION * 60) + 4)
	check(not TimeStop.active(), "for %.1f s" % TimeStop.DURATION)
	p.input.hourglass_pressed = true
	await frames(2)
	check(not TimeStop.active(), "it can't be turned again while it runs back")
	await frames(int((TimeStop.COOLDOWN - TimeStop.DURATION) * 60) + 4)
	p.input.hourglass_pressed = true
	await frames(2)
	check(TimeStop.active(), "after %.0f s it can" % TimeStop.COOLDOWN)
	p.abilities["hourglass"] = false
	TimeStop.reset()
	p.input.hourglass_pressed = true
	await frames(2)
	check(not TimeStop.active(), "without the glass nothing happens")


func test_stopped_time_holds_projectiles_in_the_air() -> void:
	var room := make_room(SHAFT)
	make_player(room, Vector2i(2, 18), {"hourglass": true})
	var f := HarpyFeather.new()
	f.velocity = Vector2(200, 0)
	room.add_child(f)
	f.position = Vector2(120, 100)
	TimeStop.start()
	await frames(20)
	check(f.position == Vector2(120, 100), "a feather hangs where it was (%s)" % f.position)
	TimeStop.reset()
	await frames(5)
	check(f.position.x > 120.0, "and flies on when time runs again")


## Bible 4.5: falling water beats you back down; frozen, it is a stair of footholds.
func test_falling_water_beats_you_down_until_time_stops() -> void:
	var rows := SHAFT.duplicate()
	for y in range(4, 19):
		var row: String = rows[y]
		rows[y] = row.substr(0, 6) + "fff" + row.substr(9)
	var room := make_room(rows)
	var p := make_player(room, Vector2i(7, 18), {"hourglass": true, "boots": false, "glove": false})
	await frames(5)
	var falls: Array = room.get_children().filter(func(c: Node) -> bool: return c is Waterfall)
	check(falls.size() == 1 and (falls[0] as Waterfall).cells == Rect2i(6, 4, 3, 15), "one waterfall over the column")
	p.input.jump_pressed = true
	p.input.jump_held = true
	var top := p.global_position.y
	for i in 30:
		await frames(1)
		top = minf(top, p.global_position.y)
	check(p.global_position.y - top < 12.0, "a jump in the falling water barely leaves the floor (rose %.0f)" % (p.global_position.y - top))
	p.input.jump_held = false
	await frames(10)
	TimeStop.start()
	await frames(2)
	p.input.jump_pressed = true
	p.input.jump_held = true
	await frames(40)
	p.input.jump_held = false
	await frames(10)
	check(p.is_on_floor() and p.global_position.y < 19 * 16 - 8.0, "frozen, a foothold holds you up (y %.0f)" % p.global_position.y)
	TimeStop.reset()
	await frames(40)
	check(absf(p.global_position.y - 19 * 16) < 2.0, "and when time runs again the water carries you down (y %.0f)" % p.global_position.y)


# --- Stride seeds (bible 6.4) ----------------------------------------------------

func _seed_shaft() -> Room:
	var rows := SHAFT.duplicate()
	rows[8] = "#......r.......#"
	return make_room(rows)


func _find_seed(room: Room) -> StrideSeed:
	for c in room.get_children():
		if c is StrideSeed:
			return c
	return null


func test_a_stride_seed_gives_back_the_double_jump_and_dash() -> void:
	var room := _seed_shaft()
	var seed := _find_seed(room)
	check(seed != null and seed.is_whole(), "legend r grows a stride seed")
	var p := make_player(room, Vector2i(7, 3))
	await frames(1)
	p.has_double_jump = false
	p.air_dash_charges = 0
	check(p.needs_air_refresh(), "with both spent, the player needs it")
	var burst := false
	for i in 60:
		await frames(1)
		if not seed.is_whole():
			burst = true
			break
	check(burst, "falling through it bursts it")
	check(p.has_double_jump and p.air_dash_charges == p.tuning.air_dash_charges, "and gives back the double jump and the dash")
	check(not p.is_on_floor(), "in mid-air")
	await frames(int(StrideSeed.REGROW * 60.0) + 2)
	check(seed.is_whole(), "it grows back after %.1f s" % StrideSeed.REGROW)


func test_a_stride_seed_is_never_wasted() -> void:
	var room := _seed_shaft()
	var seed := _find_seed(room)
	var p := make_player(room, Vector2i(7, 3))
	await frames(40)
	check(p.global_position.y > seed.global_position.y + 20.0, "the player fell past the seed")
	check(seed.is_whole(), "with nothing spent it stays whole for later")
	var q := make_player(_seed_shaft(), Vector2i(7, 3), {"boots": false, "stride": false})
	await frames(1)
	q.has_double_jump = false
	q.air_dash_charges = 0
	check(not q.needs_air_refresh(), "moves you don't own can't be spent")


# --- Audit checks (pass 97) -------------------------------------------------------

func test_the_jump_buffer_catches_a_wall_jump() -> void:
	# Bible 6.2: the buffer works on ground, wall and double jump.
	var room := make_room(SHAFT)
	var p := make_player(room, Vector2i(11, 4), {"boots": false})
	p.input.move_x = 1
	var pressed := false
	var jumped := false
	for i in 60:
		await frames(1)
		var gap := (15 * Room.TILE) - (p.global_position.x + Player.BODY_SIZE.x * 0.5)
		if not pressed and p.wall_dir == 0 and gap > 0.0 and gap < 8.0:
			p.input.jump_pressed = true
			p.input.jump_held = true
			pressed = true
		elif pressed and p.velocity.x < -100.0:
			jumped = true
			break
	check(pressed, "jump was pressed just short of the wall")
	check(jumped, "and the wall jump fires on contact")


func test_apex_hang_halves_gravity_near_the_top() -> void:
	# Bible 6.2: gravity x 0.5 while holding jump and |vy| < 40 px/s.
	var room := make_room(SHAFT)
	var p := make_player(room, Vector2i(7, 18))
	await frames(6)
	p.input.jump_pressed = true
	p.input.jump_held = true
	var dv := -1.0
	for i in 60:
		var before := p.velocity.y
		await frames(1)
		if absf(before) < p.tuning.apex_threshold - 15.0 and absf(p.velocity.y) < p.tuning.apex_threshold - 15.0 and before != 0.0:
			dv = p.velocity.y - before
			break
	check_near(dv, p.tuning.gravity * p.tuning.apex_gravity_multiplier / 60.0, 0.6, "near the apex, holding jump, it falls at half gravity")


func test_only_a_big_drop_thuds() -> void:
	# Bible 6.7: shake and rumble are for real impacts, not every jump.
	var room := make_room(SHAFT)
	var p := make_player(room, Vector2i(7, 18))
	await frames(6)
	Feel.trauma = 0.0
	Feel.last_rumble = Vector3.ZERO
	p.input.jump_pressed = true
	p.input.jump_held = true
	for i in 90:
		await frames(1)
		if i > 5 and p.is_on_floor():
			break
	check(p.is_on_floor() and Feel.last_rumble == Vector3.ZERO, "landing a full jump doesn't rumble")
	var q := make_player(room, Vector2i(4, 2))
	p.queue_free()
	for i in 120:
		await frames(1)
		if q.is_on_floor():
			break
	check(q.is_on_floor() and Feel.last_rumble.y > 0.0, "a fall of a whole shaft lands with a rumble (%s)" % Feel.last_rumble)


## A tall open room for falls: 40 rows of air above the floor.
func _tall_room() -> Room:
	var rows := ["################"]
	for i in 40:
		rows.append("#..............#")
	rows.append("################")
	return make_room(rows)


func test_feather_fall_glides_after_the_double_jump() -> void:
	var room := _tall_room()
	var p := make_player(room, Vector2i(7, 5), {"boots": true})
	p.feather_fall = true
	await frames(2)
	# Holding Jump with the double jump unspent is an ordinary fall.
	p.input.jump_held = true
	await frames(30)
	check(not p.is_gliding and p.velocity.y > p.tuning.glide_fall_speed * 2.0, "no glide before the double jump (vy %.0f)" % p.velocity.y)
	p.input.jump_pressed = true
	await frames(1)
	check(not p.has_double_jump, "double jump spent")
	var peak_frames := 0
	while p.velocity.y < 0.0 and peak_frames < 60:
		await frames(1)
		peak_frames += 1
	await frames(30)
	check(p.is_gliding, "holding Jump after the double jump glides")
	check_near(p.velocity.y, p.tuning.glide_fall_speed, 0.5, "at the glide speed")
	var y0 := p.global_position.y
	await frames(30)
	check_near(p.global_position.y - y0, p.tuning.glide_fall_speed * 0.5, 2.0, "half a second sinks 30 px")
	p.input.move_x = 1
	await frames(20)
	check(p.is_gliding and p.velocity.x > p.tuning.run_speed * 0.9, "air control is unchanged in a glide (vx %.0f)" % p.velocity.x)
	p.input.move_x = 0
	p.input.down = true
	await frames(10)
	check(not p.is_gliding and p.velocity.y > p.tuning.glide_fall_speed * 2.0, "Down drops out of it (vy %.0f)" % p.velocity.y)
	p.input.down = false
	p.input.jump_held = false
	await frames(2)
	p.input.jump_held = true
	await frames(10)
	check(p.is_gliding, "and Jump held again catches the air")
	p.input.jump_held = false
	await frames(5)
	check(not p.is_gliding, "letting go of Jump falls")


func test_feather_fall_needs_the_skill_and_brakes_a_fast_fall() -> void:
	var room := _tall_room()
	var p := make_player(room, Vector2i(7, 3), {"boots": true})
	await frames(2)
	p.input.jump_pressed = true
	await frames(1)
	p.input.jump_held = true
	await frames(60)
	check(not p.is_gliding and p.velocity.y > p.tuning.glide_fall_speed * 3.0, "without the skill there is no glide (vy %.0f)" % p.velocity.y)
	p.feather_fall = true
	var fast := p.velocity.y
	await frames(1)
	check(p.is_gliding and p.velocity.y < fast, "with it, a fast fall starts to brake")
	var n := 0
	while p.velocity.y > p.tuning.glide_fall_speed + 0.5 and n < 60:
		await frames(1)
		n += 1
	var expected := (fast - p.tuning.glide_fall_speed) / p.tuning.glide_brake * 60.0
	check(absf(n + 1 - expected) <= 2.0, "reaching glide speed in about %.0f frames (%d)" % [expected, n + 1])


## Bible 6.2: air acceleration 1,400 px/s² and deceleration 900 px/s².
func test_air_control_matches_the_bible() -> void:
	var room := _tall_room()
	var p := make_player(room, Vector2i(3, 3))
	await frames(1)
	p.velocity = Vector2.ZERO
	p.input.move_x = 1
	await frames(5)
	check_near(p.velocity.x, p.tuning.air_accel * 5.0 / 60.0, 1.0, "in the air, speed builds at 1,400 px/s²")
	await frames(20)
	check_near(p.velocity.x, p.tuning.run_speed, 0.5, "up to run speed")
	p.input.move_x = 0
	await frames(6)
	check_near(p.velocity.x, p.tuning.run_speed - p.tuning.air_decel * 6.0 / 60.0, 1.0, "and lets go at 900 px/s²")


## Bible 6.5: invulnerable for the first 0.10 s of a dash, and 0.25 s between ground dashes.
func test_dash_invulnerability_and_cooldown() -> void:
	var room := make_room(SHAFT)
	var p := make_player(room, Vector2i(2, 18))
	await frames(6)
	p.input.dash_pressed = true
	await frames(1)
	check(p.invulnerable, "invulnerable as the dash starts")
	await frames(int(p.tuning.dash_invuln * 60.0) + 1)
	check(not p.invulnerable and p.is_dashing, "but not for the whole dash")
	while p.is_dashing:
		await frames(1)
	check(p.velocity.y == 0.0 or p.is_on_floor(), "it ends level")
	p.input.dash_pressed = true
	await frames(1)
	check(not p.is_dashing, "the next ground dash waits on the cooldown")
	await frames(int(p.tuning.ground_dash_cooldown * 60.0) + 1)
	p.input.dash_pressed = true
	await frames(1)
	check(p.is_dashing, "then goes")
