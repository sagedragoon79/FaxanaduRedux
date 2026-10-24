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
