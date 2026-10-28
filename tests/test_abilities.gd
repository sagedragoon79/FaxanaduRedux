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


func test_wall_slide_is_drawn_gripping_the_wall() -> void:
	var p := await _start_on_right_wall()
	await frames(20)
	check(p.is_wall_sliding and p.facing == -1, "sliding on a right wall, facing away for the jump")
	check(PlayerVisual.look_dir(p) == 1, "but the sprite faces the wall it grips (playtest)")
	await frames(1)
	check(p.visual.scale.x > 0.0, "and is drawn unflipped (scale.x %.2f)" % p.visual.scale.x)


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


## Pass 216 (bible 4.1 A5): an elven veil is a wall to the player, but a dash
## (ground or air) passes through it, and a dash that ends inside lets you out.
const VEIL_ROOM := [
	"################",
	"#..............#",
	"#..............#",
	"#.......|......#",
	"#.......|......#",
	"#.......|......#",
	"################",
]


func test_an_elven_veil_lets_only_a_dash_through() -> void:
	var room := make_room(VEIL_ROOM)
	var veil_x := 8 * Room.TILE
	var p := make_player(room, Vector2i(4, 5), {"stride": false})
	await frames(4)
	p.input.move_x = 1
	await frames(60)
	check(p.global_position.x < veil_x, "walking, the veil stops you like a wall (x %.0f, veil at %d)" % [p.global_position.x, veil_x])
	p.input.dash_pressed = true
	await frames(20)
	check(p.global_position.x < veil_x, "and without the Stride nothing gets through (x %.0f)" % p.global_position.x)
	p.abilities["stride"] = true
	p.input.move_x = 0
	await frames(20)
	p.input.dash_pressed = true
	await frames(25)
	check(p.global_position.x > veil_x + Room.TILE, "a ground stride carries you through it (x %.0f)" % p.global_position.x)
	p.input.move_x = -1
	await frames(40)
	check(p.global_position.x > veil_x + Room.TILE, "walking back, it stops you again (x %.0f)" % p.global_position.x)
	p.input.move_x = 0
	await frames(10)
	p.input.jump_pressed = true
	p.input.jump_held = true
	await frames(12)
	p.input.move_x = -1
	p.input.dash_pressed = true
	await frames(25)
	check(p.global_position.x < veil_x, "an air dash passes it too (x %.0f)" % p.global_position.x)
	# A dash that ends inside the veil doesn't trap you in it.
	p.input.move_x = 0
	await frames(30)
	p.teleport(Vector2(veil_x + 8, 5 * Room.TILE + Room.TILE))
	await frames(2)
	check(p.passes_veils(), "inside the veil, it lets you out")
	p.input.move_x = 1
	await frames(30)
	check(p.global_position.x > veil_x + Room.TILE and not p.passes_veils(), "and once clear of it, it is a wall again (x %.0f)" % p.global_position.x)
	var probe := StrideVeil.new()
	check(probe is StaticBody2D, "the veil is a body on its own layer")
	probe.free()


## The North Bough's warden cache sits behind a veil: from the porch, walking
## and jumping get nowhere, and a stride takes you in to the Life Fruit.
func test_the_warden_cache_needs_the_stride() -> void:
	var fruit := "branches/north_bough:2,6"
	for stride: bool in [false, true]:
		var w := make_world({}, "branches/north_bough", cell_feet(6, 6))
		var p := w.player
		p.abilities["stride"] = stride
		await frames(4)
		p.input.move_x = -1
		await frames(30)
		p.input.jump_pressed = true
		p.input.jump_held = true
		await frames(10)
		p.input.dash_pressed = true
		await frames(40)
		check(GameState.is_collected(fruit) == stride, "with the Stride %s, the Life Fruit is %s" % [stride, "taken" if GameState.is_collected(fruit) else "out of reach"])
		w.queue_free()
		await frames(1)


## Pass 219: the checker's jumps fall short of real ones, so it can show a
## secret is reached but never that it is out of reach. The Sky Steps' purse
## island stood four rows over the one below, and a plain running jump off
## that island's edge landed on it. Raised to five rows (80 px, past the 72 px
## apex), it takes the Wing Boots, as BOOT_SECRETS says.
func test_the_sky_steps_purse_needs_the_wing_boots() -> void:
	for boots: bool in [false, true]:
		var w := make_world({}, "daybreak/sky_steps", cell_feet(18, 24))
		for e in w.room.get_children():
			if e is Enemy:
				e.queue_free()
		var p := w.player
		p.abilities["boots"] = boots
		await frames(4)
		p.input.move_x = -1
		var jumped := 0
		var landed := false
		for i in 120:
			if jumped == 0 and p.is_on_floor() and p.global_position.x <= 14 * Room.TILE + 2:
				p.input.jump_pressed = true
				p.input.jump_held = true
				jumped = i
			elif jumped > 0 and i == jumped + 22:
				p.input.jump_pressed = true
			await frames(1)
			p.input.jump_pressed = false
			var x := p.global_position.x / Room.TILE
			# Standing anywhere over the purse's island columns, above the start.
			if p.is_on_floor() and p.global_position.y < 25 * Room.TILE - 8 and x >= 4.0 and x < 10.0:
				landed = true
		check(landed == boots, "with the Wing Boots %s, the purse's island is %s" % [boots, "reached" if landed else "out of reach"])
		w.queue_free()
		await frames(1)


## Pass 224: the wind-niche over the Thicket Road (WIND_SECRETS) sits at the
## far end of an east-blowing band, open only on its windward side. The checker
## can't prove "out of reach", so the real controller tries it: from the shelf
## under the band, with the Wing Boots and the Stride, a jump, a second jump and
## an air dash west at every timing in 0.1 s steps. The wind gives no headway
## until the Spring of Sky turns it; then any jump into the band carries you in.
func test_the_wind_niche_needs_the_spring_of_sky() -> void:
	var tries := 0
	var reached := 0
	for k1: int in range(4, 40, 6):
		for k2: int in range(k1 + 1, k1 + 40, 6):
			tries += 1
			if await _try_the_wind_niche(false, k1, k2):
				reached += 1
	check(tries >= 40 and reached == 0, "against the wind, no jump, second jump or dash gets in (%d of %d)" % [reached, tries])
	check(await _try_the_wind_niche(true, 22, -1), "with the Spring of Sky, a jump and a second jump into the band carry you in")


## From the shelf under the band: jump west, jump again at frame k1, air dash
## west at k2 (none if negative). True if you come to stand in the niche.
func _try_the_wind_niche(spring: bool, k1: int, k2: int) -> bool:
	var w := make_world({}, "branches/thicket_road", cell_feet(55, 12))
	GameState.set_flag(WindCurrent.FLAG, spring)
	for e in w.room.get_children():
		if e is Enemy:
			e.queue_free()
	var p := w.player
	p.abilities["boots"] = true
	p.abilities["stride"] = true
	await frames(3)
	p.input.move_x = -1
	p.input.jump_pressed = true
	p.input.jump_held = true
	var inside := false
	for i in 150:
		p.input.jump_pressed = i == 0 or i == k1
		p.input.dash_pressed = i == k2
		await frames(1)
		# Standing on the niche's floor, west of the band's end.
		if p.is_on_floor() and p.global_position.x < 43 * Room.TILE and p.global_position.y <= 9 * Room.TILE + 1:
			inside = true
	w.queue_free()
	await frames(1)
	return inside


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


## Bible 6.5 (pass 146): a dash pressed a beat early is held for 0.10 s and goes
## the first frame it can: at the end of the cooldown, on a landing that gives
## back the air dash, or when a kill refreshes it. Pressed too early, it's dropped.
func test_a_dash_pressed_early_is_held_for_a_moment() -> void:
	var room := make_room(SHAFT)
	var p := make_player(room, Vector2i(2, 18))
	await frames(6)
	check_near(p.tuning.dash_buffer_time, 0.10, 0.0001, "the dash buffer is 0.10 s")
	# On the cooldown: a press 4 frames before it ends goes when it ends.
	p.input.dash_pressed = true
	await frames(1)
	while p.is_dashing:
		await frames(1)
	await frames(int(p.tuning.ground_dash_cooldown * 60.0) - 4)
	p.input.dash_pressed = true
	await frames(1)
	check(not p.is_dashing, "a dash pressed on the cooldown doesn't go at once")
	await frames(5)
	check(p.is_dashing, "but goes as the cooldown ends, without a second press")
	while p.is_dashing:
		await frames(1)
	# A press long before the cooldown ends is dropped, not saved up.
	await frames(2)
	p.input.dash_pressed = true
	await frames(int(p.tuning.ground_dash_cooldown * 60.0) + 2)
	check(not p.is_dashing, "a press 0.2 s too early is dropped")
	# In the air with the dash spent: a press just before the landing is a
	# ground dash the frame the feet touch.
	p.velocity = Vector2.ZERO
	p.global_position = Vector2(p.global_position.x, 16 * 15)
	await frames(2)
	p.air_dash_charges = 0
	var landed := -1
	for i in 60:
		if not p.is_on_floor() and p.global_position.y > 16 * 19 - 20 and not p.is_dashing and landed < 0:
			p.input.dash_pressed = true
			landed = 0
		await frames(1)
		if landed >= 0:
			landed += 1
		if p.is_dashing:
			break
	check(p.is_dashing and p.is_on_floor() and landed <= 6, "a dash pressed just before landing goes on the landing (%d frames)" % landed)
	while p.is_dashing:
		await frames(1)
	await frames(30)
	# A kill with Wanderer's Grace gives the air dash back mid-air, and a dash
	# pressed a beat before it goes the moment it returns.
	p.wanderers_grace = true
	p.velocity = Vector2.ZERO
	p.global_position = Vector2(p.global_position.x, 16 * 6)
	await frames(2)
	p.air_dash_charges = 0
	p.input.dash_pressed = true
	await frames(2)
	check(not p.is_dashing, "with no air dash left, a press waits")
	p.on_kill()
	await frames(1)
	check(p.is_dashing and not p.is_on_floor(), "a kill gives it back and the held press dashes")


# --- Juice checklist (design bible 6.7) -----------------------------------------

## Counts the Dust puffs, by kind, spawned in `room` over the next `n` frames.
func _dust_during(room: Node, n: int) -> Dictionary:
	var seen := {}
	for c in room.get_children():
		seen[c.get_instance_id()] = true
	var counts := {}
	for i in n:
		await frames(1)
		for c in room.get_children():
			if c is Dust and not seen.has(c.get_instance_id()):
				seen[c.get_instance_id()] = true
				counts[c.kind] = int(counts.get(c.kind, 0)) + 1
	return counts


func test_juice_on_the_ground_dust_and_squash() -> void:
	var room := make_room(SHAFT)
	var p := make_player(room, Vector2i(3, 18))
	await frames(10)
	p.input.move_x = 1
	var start := await _dust_during(room, 12)
	check(int(start.get("run", 0)) >= 1, "starting a run kicks dust (%s)" % [start])
	await frames(12)
	p.input.move_x = -1
	var turn := await _dust_during(room, 8)
	check(int(turn.get("run", 0)) >= 1, "turning around at speed kicks dust (%s)" % [turn])
	p.input.move_x = 0
	await frames(30)
	p.input.jump_pressed = true
	p.input.jump_held = true
	var jump := await _dust_during(room, 1)
	p.input.jump_pressed = false
	check(int(jump.get("jump", 0)) == 1, "a jump puffs dust (%s)" % [jump])
	check(p.visual.squash_scale.x < 0.92 and p.visual.squash_scale.y > 1.12, "and stretches thin and tall (%s)" % p.visual.squash_scale)
	p.input.jump_held = false
	var land := {}
	for i in 90:
		var got := await _dust_during(room, 1)
		if got.has("land"):
			land = got
			break
	check(land.has("land") and p.is_on_floor(), "landing puffs dust (%s)" % [land])
	check(p.visual.squash_scale.x > 1.02 and p.visual.squash_scale.y < 0.98, "and squashes wide and low (%s)" % p.visual.squash_scale)
	await frames(20)
	p.input.dash_pressed = true
	var dash := await _dust_during(room, 1)
	p.input.dash_pressed = false
	check(int(dash.get("dash", 0)) == 1, "a ground dash kicks dust off the floor (%s)" % [dash])
	var ghosts := 0
	for i in 10:
		await frames(1)
		for c in room.get_children():
			if c is Afterimage:
				ghosts = maxi(ghosts, room.get_children().filter(func(n: Node) -> bool: return n is Afterimage).size())
	check(ghosts >= 2, "and leaves a trail of afterimages (%d)" % ghosts)


func test_juice_on_walls_and_in_the_air() -> void:
	var p := await _start_on_right_wall()
	var room := p.get_parent()
	var slide := await _dust_during(room, 36)
	# One puff every 0.06 s: 10 in 36 frames, give or take the first.
	check(p.is_wall_sliding and int(slide.get("wall", 0)) >= 9 and int(slide.get("wall", 0)) <= 11, "a wall slide sheds dust every 0.06 s (%s)" % [slide])
	p.input.move_x = -1
	p.input.jump_pressed = true
	p.input.jump_held = true
	var wj := await _dust_during(room, 1)
	p.input.jump_pressed = false
	check(int(wj.get("walljump", 0)) == 1, "a wall jump bursts dust off the wall (%s)" % [wj])
	check(p.visual.squash_scale.x > 1.05, "and stretches along the leap (%s)" % p.visual.squash_scale)
	await frames(6)
	p.input.dash_pressed = true
	var air := await _dust_during(room, 1)
	p.input.dash_pressed = false
	check(int(air.get("airdash", 0)) == 1 and not air.has("dash"), "an air dash puffs air, not floor dust (%s)" % [air])


func test_juice_camera_and_feel_numbers_match_the_bible() -> void:
	check(GameCamera.LOOK_AHEAD == 48.0 and GameCamera.LOOK_AHEAD_EASE == 0.4, "look-ahead 48 px eased over 0.4 s")
	check(GameCamera.LOOK_DOWN_DELAY == 0.4 and GameCamera.DEADZONE == Vector2(16, 24), "look-down after 0.4 s, deadzone 16x24")
	check(Feel.TRAUMA_DECAY == 1.5 and Feel.BOSS_KILL_HITSTOP == 0.35, "trauma decays 1.5/s; a boss kill holds 350 ms")
	var c := CombatTuning.new()
	check(c.hit_hitstop == 0.05 and c.heavy_hitstop == 0.09 and c.parry_hitstop == 0.14 and BossArena.PHASE_HITSTOP == 0.2, "hit-stops 50/90/140/200 ms")
	var room := make_room(SHAFT)
	var p := make_player(room, Vector2i(7, 18))
	var cam := GameCamera.new()
	cam.target = p
	cam.view_size = Vector2(160, 90)
	cam.set_room_limits(room.pixel_rect())
	arena.add_child(cam)
	await frames(60)
	p.facing = -1
	await frames(24)
	check(cam._look_ahead < -0.9 * GameCamera.LOOK_AHEAD, "turning eases the look-ahead most of the way over in 0.4 s (%.1f)" % cam._look_ahead)
	p.input.down = true
	await frames(18)
	check(cam._look_down < 1.0, "holding down 0.3 s doesn't look down yet (%.1f)" % cam._look_down)
	await frames(42)
	check(cam._look_down > 40.0, "holding it longer looks down (%.1f)" % cam._look_down)
	p.input.down = false
	# Look-up (pass 133): Up held still, after the same delay.
	check(GameCamera.LOOK_UP == 72.0, "look-up is 72 px")
	await frames(60)
	p.input.up = true
	await frames(18)
	check(absf(cam._look_down) < 2.0, "holding up 0.3 s doesn't look up yet (%.1f)" % cam._look_down)
	await frames(42)
	check(cam._look_down < -40.0, "holding it longer looks up (%.1f)" % cam._look_down)
	p.input.up = false
	await frames(60)
	check(absf(cam._look_down) < 2.0, "letting go eases back (%.1f)" % cam._look_down)
	cam.queue_free()


func test_a_boss_kill_freezes_then_ramps_back_from_slow_motion() -> void:
	Feel.reset()
	Feel.boss_kill(1.0)
	check_near(Feel.last_hitstop, 0.35, 0.001, "the death blow holds 350 ms")
	var from := Feel._ramp_from_usec
	var span := Feel._slowmo_until_usec - from
	check(span > 990000 and span < 1010000, "then a second of slow motion (%d us)" % span)
	var start := Feel._ramped_scale(from)
	var mid := Feel._ramped_scale(from + span / 2)
	var late := Feel._ramped_scale(from + span * 9 / 10)
	check_near(start, Feel.BOSS_KILL_SLOWMO, 0.001, "it starts at 0.3x")
	check(mid > start and late > mid and late < 1.0, "and ramps back toward full speed (%.2f, %.2f, %.2f)" % [start, mid, late])
	Feel.reset()
	check(Engine.time_scale == 1.0, "reset ends it")




# --- Bible 6.3, 6.4 and 6.6, pinned (pass 107) ----------------------------------

## Slides down the right wall of SHAFT, then returns the player mid-slide.
func _sliding(abilities := {}) -> Player:
	var p := await _start_on_right_wall(abilities)
	await frames(10)
	return p


func test_pushing_off_a_wall_sticks_for_0_08_s() -> void:
	var p := await _sliding({"boots": false})
	check(p.is_wall_sliding, "sliding")
	p.input.move_x = -1
	var held := 0
	for i in 20:
		await frames(1)
		if not p.is_wall_sliding:
			break
		held += 1
	# 0.08 s is 4.8 frames.
	check(held >= 4 and held <= 5, "pushing away holds the slide for 0.08 s (%d frames)" % held)


## Wall-jumps off the right wall with `jump_x` held, then holds `then_x`;
## returns vx for each of the next 16 frames.
func _wall_jump_vx(jump_x: int, then_x: int) -> Array[float]:
	var p := await _sliding({"boots": false})
	p.input.move_x = jump_x
	p.input.jump_pressed = true
	p.input.jump_held = true
	var vx: Array[float] = []
	for i in 16:
		await frames(1)
		vx.append(p.velocity.x)
		p.input.move_x = then_x
	return vx


func test_the_wall_jump_locks_input_then_blends_it_back() -> void:
	var t := MovementTuning.new()
	# Away from the wall, then straight back toward it.
	var vx := await _wall_jump_vx(-1, 1)
	check_near(vx[0], -t.wall_jump_x, 0.01, "a wall jump pushing away leaves at 220 px/s")
	check_near(vx[5], -t.wall_jump_x, 0.01, "steering is locked for 0.10 s (6 frames)")
	check(vx[7] > vx[6], "then control returns (%.1f -> %.1f)" % [vx[6], vx[7]])
	var first := vx[7] - vx[6]
	var full := t.air_accel / 60.0
	check(first < full * 0.5, "eased in, not all at once (%.1f of %.1f px/s a frame)" % [first, full])
	check_near(vx[13] - vx[12], full, 0.5, "full air control after the 0.10 s blend")


func test_a_climb_jump_goes_up_and_slightly_out() -> void:
	var t := MovementTuning.new()
	var vx := await _wall_jump_vx(0, 1)
	check_near(vx[0], -t.wall_climb_jump_x, 0.01, "a neutral wall jump leaves at 120 px/s")
	check_near(vx[3], -t.wall_climb_jump_x, 0.01, "locked for 0.06 s (4 frames)")
	check(vx[5] > vx[4], "then you can steer back to the wall")
	var p := await _sliding({"boots": false})
	p.input.move_x = 1
	p.input.jump_pressed = true
	p.input.jump_held = true
	await frames(1)
	check_near(p.velocity.x, -t.wall_climb_jump_x, 0.01, "holding toward the wall is a climb jump too")
	check(p.velocity.y < -t.wall_jump_y + 30.0, "rising at about 380 px/s (vy %.1f)" % p.velocity.y)


## Lets go of the right wall, then presses Jump `k` frames after the last frame
## that touched it (k >= 2).
func _jump_after_wall(k: int) -> bool:
	var p := await _sliding({"boots": false})
	p.input.move_x = -1
	for i in 30:
		await frames(1)
		if p.wall_dir == 0:
			break  # the first frame off the wall has run
	await frames(k - 2)
	p.input.jump_pressed = true
	p.input.jump_held = true
	await frames(1)
	return p.velocity.y < -300.0


func test_wall_coyote_lasts_0_08_s() -> void:
	# 0.08 s is 4.8 frames after the last frame on the wall.
	check(await _jump_after_wall(2), "a wall jump 2 frames off the wall still counts")
	check(await _jump_after_wall(4), "and 4 frames (0.067 s) off")
	check(not await _jump_after_wall(5), "5 frames (0.083 s) off is too late")


func test_double_jump_numbers_and_refresh() -> void:
	var t := MovementTuning.new()
	var room := make_room(SHAFT)
	var p := make_player(room, Vector2i(5, 10), {"glove": true})
	await frames(4)
	p.input.jump_pressed = true
	p.input.jump_held = true
	await frames(1)
	# Read after its first frame, which already carries a frame of gravity.
	check_near(p.velocity.y, -t.double_jump_velocity + t.gravity / 60.0, 0.05, "a double jump leaves at 326 px/s")
	check(not p.has_double_jump, "spent")
	# Touching a wall gives it back.
	p.input.move_x = 1
	for i in 60:
		await frames(1)
		if p.wall_dir == 1:
			break
	check(p.has_double_jump, "touching a wall gives the double jump back")


func test_the_buffer_carries_a_double_jump_through_an_air_dash() -> void:
	# Bible 6.2: the buffer works on the double jump too. Pressed late in an air
	# dash, it fires the frame the dash ends.
	var room := make_room(SHAFT)
	var p := make_player(room, Vector2i(3, 6), {"glove": false})
	await frames(3)
	p.input.dash_pressed = true
	await frames(1)
	check(p.is_dashing, "air dash")
	var n := 1
	while n < 30:
		if n == 5:
			p.input.jump_pressed = true
			p.input.jump_held = true
		await frames(1)
		n += 1
		if not p.is_dashing:
			break
	check(p.velocity.y < -300.0, "the double jump fires the frame the dash ends (vy %.1f)" % p.velocity.y)
	check(not p.has_double_jump, "and is spent")


## Pogos off SPIKE_FLOOR with Jump held or not; returns the bounce speed.
func _pogo_speed(hold_jump: bool) -> float:
	var p := _drop_onto_spikes()
	for i in 60:
		if p.velocity.y > 0.0 and p.global_position.y > SPIKE_TOP - 28.0 and not p.is_attacking:
			p.input.down = true
			p.input.attack_pressed = true
		p.input.jump_held = hold_jump
		await frames(1)
		if p.velocity.y < -300.0:
			return -p.velocity.y
	return 0.0


func test_pogo_numbers_match_the_bible() -> void:
	var t := MovementTuning.new()
	Feel.last_hitstop = 0.0
	check_near(await _pogo_speed(false), t.pogo_bounce, 0.5, "a pogo bounces at 380 px/s")
	check_near(Feel.last_hitstop, 0.045, 0.0001, "with a 45 ms hit-stop")
	check_near(await _pogo_speed(true), t.pogo_bounce_held, 0.5, "holding Jump bounces at 420 px/s")
