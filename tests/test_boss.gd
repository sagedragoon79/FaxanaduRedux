extends TestSuite
## Rokusutahn and its arena (design bible 8 and 8.1), the Spring of Trunk and
## the world-state change it makes (4.4).

const ARENA_ROOM := "trunk/root_chamber"


func _until(cond: Callable, max_frames: int) -> bool:
	for i in max_frames:
		if cond.call():
			return true
		await frames(1)
	return cond.call()


func _arena(w: World) -> BossArena:
	for c in w.room.get_children():
		if c is BossArena:
			return c
	return null


## A boss dropped straight into the Root Chamber, without the arena.
func _boss_world() -> Array:
	var w := make_world({}, ARENA_ROOM, cell_feet(4, 19))
	GameState.set_flag("boss:rokusutahn")  # keep the arena from starting its own fight
	var boss := Rokusutahn.new()
	boss.room = w.room
	w.room.add_child(boss)
	return [w, boss]


func _count(w: World, type: Variant) -> int:
	var n := 0
	for c in w.room.get_children():
		if is_instance_of(c, type) and not c.is_queued_for_deletion():
			n += 1
	return n


func test_arena_seals_the_doors_and_wakes_the_boss() -> void:
	var w := make_world({}, ARENA_ROOM)
	var p := w.player
	await frames(3)
	var arena := _arena(w)
	check(arena != null, "the Root Chamber has a boss arena")
	check(arena.entry_door == 1 and arena.seals.size() == 1 and arena.seals.has(2), "the exit is sealed, the way in is not (%s)" % [arena.seals.keys()])
	check(get_tree_boss() == null, "the boss waits until the player is inside")
	p.teleport(cell_feet(12, 19))
	var woke := await _until(func() -> bool: return arena.fighting, 20)
	check(woke and get_tree_boss() != null, "walking in wakes Rokusutahn")
	check(arena.seals.size() == 2, "both doors are sealed during the fight")
	p.teleport(cell_feet(2, 19))
	p.input.move_x = -1
	await frames(40)
	check(w.room.id == ARENA_ROOM, "the sealed door can't be used")


func get_tree_boss() -> Node:
	return runner.get_tree().get_first_node_in_group("boss")


func test_telegraphs_are_fair() -> void:
	for tell: float in [Rokusutahn.LUNGE_TELL, Rokusutahn.PLUNGE_TELL, Rokusutahn.DANGLE_TELL, SapClump.TELL]:
		check(tell >= Enemy.MIN_TELEGRAPH, "every wind-up is at least %.2f s (%.2f)" % [Enemy.MIN_TELEGRAPH, tell])


func test_tail_takes_full_damage_and_the_plates_a_quarter() -> void:
	var setup := _boss_world()
	var boss: Rokusutahn = setup[1]
	await frames(2)
	boss.state = "stuck"
	var tail := boss.segments[Rokusutahn.SEGMENTS - 1]
	var body := boss.segments[8]
	check(tail.is_tail and not body.is_tail, "the last segments are the tail")
	boss.hit_segment(tail, 20, Vector2.RIGHT)
	check(boss.hp == Rokusutahn.MAX_HP - 20, "the tail takes full damage (hp %d)" % boss.hp)
	await frames(1)
	boss.hit_segment(body, 20, Vector2.RIGHT)
	check(boss.hp == Rokusutahn.MAX_HP - 25, "the bark plates take a quarter (hp %d)" % boss.hp)
	await frames(1)
	var before := boss.hp
	boss.hit_segment(body, 20, Vector2.RIGHT)
	boss.hit_segment(tail, 20, Vector2.RIGHT)
	boss.hit_segment(boss.segments[Rokusutahn.SEGMENTS - 2], 20, Vector2.RIGHT)
	check(before - boss.hp == 20, "one swing over several segments counts once, at the best rate (%d)" % (before - boss.hp))


func test_floor_lunge_misses_the_ledges() -> void:
	var setup := _boss_world()
	var w: World = setup[0]
	var boss: Rokusutahn = setup[1]
	var p := w.player
	# On the low wall ledge, above the lunge.
	p.teleport(cell_feet(4, 13))
	await frames(5)
	check(p.is_on_floor(), "standing on the ledge")
	boss._start_lunge(Rokusutahn.FLOOR_LANE, false)
	var done := await _until(func() -> bool: return boss.state == "rest", 400)
	check(done, "the lunge crosses the room and leaves (state %s)" % boss.state)
	check(p.hp == p.max_hp, "the ledge is safe from a floor lunge (hp %d)" % p.hp)
	# On the floor, it hits.
	p.teleport(cell_feet(20, 19))
	await frames(5)
	boss._start_lunge(Rokusutahn.FLOOR_LANE, false)
	await _until(func() -> bool: return p.hp < p.max_hp, 300)
	check(p.hp < p.max_hp, "standing on the floor, the lunge hits")


func test_stuck_lunge_leaves_the_tail_by_the_entry_wall() -> void:
	var setup := _boss_world()
	var w: World = setup[0]
	var boss: Rokusutahn = setup[1]
	w.player.teleport(cell_feet(4, 13))
	await frames(3)
	boss._start_lunge(Rokusutahn.FLOOR_LANE, true)
	var stuck := await _until(func() -> bool: return boss.state == "stuck", 300)
	check(stuck, "the second kind of lunge bites into the far wall")
	# The player is on the left, so it came from the right wall.
	var tail := boss.tail_position()
	check(tail.x > Rokusutahn.ARENA.end.x - 140.0 and tail.x < Rokusutahn.ARENA.end.x, "the tail is near the wall it came from (x %.0f)" % tail.x)
	check(boss.segments[Rokusutahn.SEGMENTS - 1].active, "the tail can be hit")
	check(boss.head_position().x < Rokusutahn.ARENA.position.x + 4.0, "the head is in the far wall (x %.0f)" % boss.head_position().x)
	var free := await _until(func() -> bool: return boss.state == "rest", 400)
	check(free, "it pulls itself through and leaves")


func test_phases_follow_health() -> void:
	var setup := _boss_world()
	var w: World = setup[0]
	var boss: Rokusutahn = setup[1]
	await frames(2)
	boss.hp = int(Rokusutahn.MAX_HP * 0.61)
	boss._next_move()
	check(boss.phase == 1, "above 60 percent it stays in phase 1")
	boss.hp = int(Rokusutahn.MAX_HP * 0.59)
	boss._next_move()
	check(boss.phase == 2 and boss.state == "roar", "below 60 percent it roars into phase 2")
	await _until(func() -> bool: return boss.state != "roar", 200)
	check(boss.state == "rain", "phase 2 opens with sap rain (%s)" % boss.state)
	boss.hp = int(Rokusutahn.MAX_HP * 0.29)
	boss._next_move()
	check(boss.phase == 3, "below 30 percent it enters phase 3")
	var mid := Vector2(20 * Room.TILE + 8, Rokusutahn.FLOOR_Y + 4)
	check(w.room.is_solid_at(mid), "the floor is whole before the tear")
	await _until(func() -> bool: return boss.state != "roar", 200)
	check(not w.room.is_solid_at(mid), "phase 3 tears the floor away")
	check(_count(w, Spikes) >= 20, "spikes line the pit (%d)" % _count(w, Spikes))
	check(w.room.is_solid_at(Vector2(3 * Room.TILE, Rokusutahn.FLOOR_Y + 4)), "the floor by the walls stays")
	check(boss.state == "lunge_tell" and absf(boss._rail_from.y - Rokusutahn.LOW_LANE) < 1.0, "phase 3 lunges along the ledges")


func test_sap_clump_hardens_into_a_platform() -> void:
	var setup := _boss_world()
	var w: World = setup[0]
	var p := w.player
	var clump := SapClump.new()
	clump.room = w.room
	clump.position = Vector2(300, 34)
	w.room.add_child(clump)
	var landed := await _until(func() -> bool: return _count(w, SapMound) > 0, 120)
	check(landed, "the clump lands and hardens")
	var mound: SapMound
	for c in w.room.get_children():
		if c is SapMound:
			mound = c
	check_near(mound.position.y, Rokusutahn.FLOOR_Y, 0.5, "the mound sits on the floor")
	p.teleport(Vector2(300, Rokusutahn.FLOOR_Y - SapMound.SIZE.y - 2))
	await frames(10)
	check(p.is_on_floor() and absf(p.global_position.y - (Rokusutahn.FLOOR_Y - SapMound.SIZE.y)) < 1.5, "the player can stand on it (y %.1f)" % p.global_position.y)
	await frames(int(SapMound.LIFETIME * 60.0) + 5)
	check(_count(w, SapMound) == 0, "it crumbles after a while")


func test_sap_clump_hurts() -> void:
	var setup := _boss_world()
	var w: World = setup[0]
	var p := w.player
	p.teleport(cell_feet(20, 19))
	await frames(3)
	var clump := SapClump.new()
	clump.room = w.room
	clump.position = Vector2(p.global_position.x, 34)
	w.room.add_child(clump)
	await _until(func() -> bool: return p.hp < p.max_hp, 120)
	check(p.hp == p.max_hp - SapClump.DAMAGE, "a falling clump hurts (hp %d)" % p.hp)


func test_defeat_gives_the_reward_once() -> void:
	var w := make_world({}, ARENA_ROOM)
	var p := w.player
	await frames(3)
	var arena := _arena(w)
	p.teleport(cell_feet(12, 19))
	await _until(func() -> bool: return arena.fighting, 20)
	var boss: Rokusutahn = get_tree_boss()
	await frames(2)
	boss.state = "stuck"
	boss.hp = 1
	boss.hit_segment(boss.segments[Rokusutahn.SEGMENTS - 1], 10, Vector2.RIGHT)
	check(boss.dead and boss.state == "dying", "the last hit starts the death")
	var gone := await _until(func() -> bool: return boss.state == "dead", 900)
	check(gone, "every segment shatters")
	check(GameState.data.rings.has("elf"), "the Elf Ring is won")
	check(GameState.flag("boss:rokusutahn"), "the boss is marked beaten")
	check(int(GameState.data.xp) == Rokusutahn.XP, "boss XP (%d)" % int(GameState.data.xp))
	var expected_points := 1 + int(GameState.data.rank)
	check(int(GameState.data.skill_points) == expected_points, "one skill point plus the rank-ups (%d)" % int(GameState.data.skill_points))
	# Slow motion runs on wall-clock time, so wait on the result, not a frame count.
	var opened := await _until(func() -> bool: return arena.seals.is_empty() and _count(w, ArenaSeal) == 0, 1200)
	check(opened, "the doors open again")
	w._enter(ARENA_ROOM)
	await frames(5)
	check(get_tree_boss() == null and _count(w, ArenaSeal) == 0, "it never comes back")


func test_spring_hardens_sap_and_fills_the_fountain() -> void:
	var rows := grid_rows(40, 23)
	put_tiles(rows, 3, 19, "P")
	put_tiles(rows, 20, 19, "~", 4, 2)
	put_tiles(rows, 20, 20, "#", 4, 1)
	put_tiles(rows, 20, 21, "#", 4, 1)
	put_tiles(rows, 20, 19, "~", 4, 1)
	var rooms := {"test/spring": room_text(["name: Spring", "zone: trunk", "prop: 8, 19, spring_trunk"], rows)}
	var w := make_world(rooms, "test/spring")
	var p := w.player
	var sap_at := Vector2(21 * Room.TILE + 8, 19 * Room.TILE + 8)
	check(w.room.is_sap_at(sap_at) and not w.room.is_solid_at(sap_at), "sap before the spring")
	check(Fountain.level() == 0, "the fountain starts dry")
	p.teleport(cell_feet(8, 19))
	await frames(3)
	p.input.up_pressed = true
	await frames(2)
	check(GameState.flag("spring:trunk"), "pressing Up restores the spring")
	check(Fountain.level() == 1, "the fountain is a third full")
	w._enter("test/spring")
	check(w.room.is_solid_at(sap_at) and not w.room.is_sap_at(sap_at), "the sap is solid amber now")


func test_music_follows_rooms_and_bosses() -> void:
	for name: String in ["title", "eolis", "trunk", "tower", "boss", "miniboss", "zoradohna", "forepaw", "amb_trunk", "amb_eolis", "amb_tower", "amb_heights", "amb_mine"]:
		var stream := Music.stream_for(name)
		check(stream is AudioStreamOggVorbis and (stream as AudioStreamOggVorbis).loop, "%s is a looping track" % name)
	var w := make_world({}, "trunk/boss_gate")
	check(Music.track == "trunk" and Music.ambience_track == "amb_trunk", "the Trunk plays its theme and ambience (%s)" % Music.track)
	w.use_door(2)
	await frames(3)
	check(Music.track == "trunk", "the arena keeps the zone theme until the fight")
	var arena := _arena(w)
	w.player.teleport(cell_feet(12, 19))
	await _until(func() -> bool: return arena.fighting, 20)
	check(Music.track == "boss", "the fight plays the boss theme")


func test_tower_rooms_pick_their_ambience_and_theme() -> void:
	# Bible 11: each part of the Tower has its own bed; Forepaw has its own theme.
	var w := make_world({}, "tower/winch_hall")
	check(Music.track == "tower" and Music.ambience_track == "amb_tower", "the Tower's halls hum with machinery")
	GameState.set_flag("boss:zoradohna")
	for stop: Array in [["tower/old_flue", "tower", "amb_heights"], ["tower/rafters", "tower", "amb_heights"],
			["tower/forepaw", "forepaw", "amb_tower"], ["tower/mine_mouth", "tower", "amb_mine"], ["tower/smelter", "tower", "amb_mine"]]:
		w._enter(stop[0])
		await frames(1)
		check(Music.track == stop[1] and Music.ambience_track == stop[2], "%s plays %s over %s (%s, %s)" % [stop[0], stop[1], stop[2], Music.track, Music.ambience_track])


func test_reveal_bursts_out_and_withdraws() -> void:
	var setup := _boss_world()
	var boss: Rokusutahn = setup[1]
	var cards: Array = []
	var on_banner := func(title: String, sub: String) -> void: cards.append(title + " " + sub)
	GameState.banner.connect(on_banner)
	await frames(2)
	boss.begin()
	GameState.banner.disconnect(on_banner)
	check(cards.size() == 1 and String(cards[0]).begins_with(Rokusutahn.DISPLAY_NAME), "a name card announces him (%s)" % [cards])
	await frames(int((Rokusutahn.INTRO_EMERGE + 0.3) * 60.0))
	var head := boss.head_position()
	check(Rokusutahn.ARENA.has_point(head) and absf(head.x - 4 * 16) > 300.0, "the head bursts out of the far wall (%s)" % head)
	var hit_before := boss.hp
	boss.hit_segment(boss.segments[0], 50, Vector2.RIGHT)
	check(boss.hp == hit_before, "he can't be hurt during the reveal")
	var moved := await _until(func() -> bool: return boss.state != "intro", 200)
	check(moved and boss.state == "lunge_tell", "then the fight begins (%s)" % boss.state)


func test_tail_damage_staggers_him() -> void:
	var setup := _boss_world()
	var boss: Rokusutahn = setup[1]
	await frames(2)
	boss._start_lunge(Rokusutahn.FLOOR_LANE, true)
	var stuck := await _until(func() -> bool: return boss.state == "stuck", 400)
	check(stuck, "a stuck lunge")
	var tail := boss.segments[Rokusutahn.SEGMENTS - 1]
	for i in 5:
		boss.hit_segment(tail, 8, Vector2.RIGHT)
		await frames(1)
	check(boss.stagger_left == 0.0, "40 tail damage is not enough")
	boss.hit_segment(tail, 8, Vector2.RIGHT)
	check(boss.stagger_left > 0.0, "48 tail damage in one window staggers him")
	check(boss.state_time < 0.0, "and pins him in the wall longer (state time %.2f)" % boss.state_time)
	await frames(1)
	var hp0 := boss.hp
	boss.hit_segment(boss.segments[8], 20, Vector2.RIGHT)
	check(boss.hp == hp0 - 20, "while staggered the plates take full damage (hp %d)" % boss.hp)
	var still := await _until(func() -> bool: return boss.stagger_left == 0.0, 200)
	await frames(1)
	var hp1 := boss.hp
	boss.hit_segment(boss.segments[8], 20, Vector2.RIGHT)
	check(still and boss.hp == hp1 - 5, "and back to a quarter when it passes (hp %d)" % boss.hp)


# --- The Foreman (Tower of Trunk mini-boss) ------------------------------------------

const FOREMAN_ROOM := "tower/foreman_hall"


## The Foreman dropped into his hall without the arena, awake.
func _foreman_world(cell := Vector2i(30, 19)) -> Array:
	var w := make_world({}, FOREMAN_ROOM, cell_feet(4, 19))
	GameState.set_flag("boss:foreman")  # keep the arena from starting its own fight
	var f := Foreman.new()
	f.arena = Rect2(16, 64, 608, 256)
	f.position = cell_feet(cell.x, cell.y)
	w.room.add_child(f)
	w.player.max_hp = 9999
	w.player.hp = 9999
	await frames(2)
	f.set_state("walk")
	return [w, f]


func _count_rubble(w: World, mode: String) -> int:
	var n := 0
	for c in w.room.get_children():
		if c is Rubble and c.mode == mode and not c.is_queued_for_deletion():
			n += 1
	return n


func test_foreman_hall_wakes_the_golem() -> void:
	var w := make_world({}, FOREMAN_ROOM)
	await frames(3)
	var arena := _arena(w)
	check(arena != null and arena.boss_id == "foreman", "the Foreman's Hall is a boss arena")
	w.player.teleport(cell_feet(10, 19))
	var woke := await _until(func() -> bool: return arena.fighting, 20)
	var f := get_tree_boss() as Foreman
	check(woke and f != null, "walking in wakes the Foreman")
	check(f != null and f.global_position.x > w.player.global_position.x + 200.0, "he stands at the far end of the hall")
	check(arena.seals.has(1), "the way in seals behind the player")


func test_foreman_telegraphs_are_fair() -> void:
	var f := Foreman.new()
	for ph in [1, 2]:
		f.phase = ph
		for t: float in [Foreman.POUND_TELL, Foreman.THROW_TELL, Foreman.CHARGE_TELL]:
			check(f.tell(t) >= Enemy.MIN_TELEGRAPH, "phase %d tell %.2f s is at least %.2f s" % [ph, f.tell(t), Enemy.MIN_TELEGRAPH])
	check(Rubble.TELL >= Enemy.MIN_TELEGRAPH, "a falling rock marks its spot for at least %.2f s" % Enemy.MIN_TELEGRAPH)
	f.free()


func test_foreman_charges_into_the_wall_and_is_stunned() -> void:
	var r := await _foreman_world(Vector2i(20, 19))
	var w: World = r[0]
	var f: Foreman = r[1]
	w.player.teleport(cell_feet(6, 19))
	await frames(1)
	f.facing = 1
	f.set_state("charge_tell")
	var tell_frames := [0]  # lambdas capture locals by value, so count in an array
	var stunned := await _until(func() -> bool:
		if f.state == "charge_tell":
			tell_frames[0] += 1
		return f.stunned(), 240)
	check(tell_frames[0] / 60.0 >= Enemy.MIN_TELEGRAPH, "he scrapes the floor for at least %.2f s first (%d frames)" % [Enemy.MIN_TELEGRAPH, tell_frames[0]])
	check(stunned and f.global_position.x > 34 * Room.TILE, "charged into the far wall and is stunned (x %.0f)" % f.global_position.x)
	check(_count_rubble(w, "fall") >= 3, "the impact shakes rocks loose from the ceiling (%d)" % _count_rubble(w, "fall"))
	var hp0 := f.hp
	f.take_hit(8, Vector2.LEFT)
	check(f.hp == hp0 - 8, "stunned, he takes a blow in full")


func test_foreman_rock_halves_blows_unless_from_above() -> void:
	var r := await _foreman_world()
	var f: Foreman = r[1]
	var hp0 := f.hp
	f.take_hit(8, Vector2.RIGHT)
	check(f.hp == hp0 - 4, "his rock halves a blow (%d)" % (hp0 - f.hp))
	f.take_hit(8, Vector2(0, 1))
	check(f.hp == hp0 - 12, "a blow from above lands in full")
	check(f.state == "walk", "blows don't interrupt him")


func test_foreman_pound_sends_a_shockwave_each_way() -> void:
	var r := await _foreman_world()
	var w: World = r[0]
	var f: Foreman = r[1]
	w.player.teleport(cell_feet(26, 19))
	f.facing = -1
	f.set_state("pound_tell")
	var dirs := {}
	await _until(func() -> bool:
		for c in w.room.get_children():
			if c is Shockwave:
				dirs[c.direction] = true
		return dirs.size() == 2, 120)
	check(dirs.has(-1) and dirs.has(1), "two shockwaves roll out, one each way (%s)" % [dirs.keys()])


func test_foreman_throws_a_boulder_at_the_player() -> void:
	var r := await _foreman_world()
	var w: World = r[0]
	var f: Foreman = r[1]
	w.player.teleport(cell_feet(22, 19))
	f.facing = -1
	f.set_state("throw_tell")
	var hp := w.player.hp
	var thrown := await _until(func() -> bool: return _count_rubble(w, "thrown") > 0, 90)
	check(thrown, "he lobs a boulder")
	var hit := await _until(func() -> bool: return w.player.hp < hp, 90)
	check(hit, "it lands on the player standing still")


func test_foreman_defeat_gives_the_mattock() -> void:
	var w := make_world({}, FOREMAN_ROOM)
	var p := w.player
	await frames(3)
	check(not p.abilities.mattock, "no Mattock before the fight")
	var arena := _arena(w)
	p.teleport(cell_feet(10, 19))
	await _until(func() -> bool: return arena.fighting, 20)
	var f := get_tree_boss() as Foreman
	await frames(2)
	f.set_state("stunned")
	f.hp = 1
	f.take_hit(8, Vector2.RIGHT)
	check(f.state == "dying", "the last blow topples him")
	var gone := await _until(func() -> bool: return GameState.flag("boss:foreman"), 600)
	check(gone, "the Foreman is marked beaten")
	check(p.abilities.mattock and bool(GameState.data.abilities.mattock), "the Mattock is the player's")
	var opened := await _until(func() -> bool: return arena.seals.is_empty() and _count(w, ArenaSeal) == 0, 1200)
	check(opened, "the way out opens")
	w._enter(FOREMAN_ROOM)
	await frames(5)
	check(get_tree_boss() == null, "he never comes back")


# --- Zoradohna (Tower of Trunk boss) ---------------------------------------------------

const LIFT_ROOM := "tower/forepaw_lift"


## Zoradohna dropped onto the lift without the arena, awake.
func _zora_world(cell := Vector2i(30, 19)) -> Array:
	var w := make_world({}, LIFT_ROOM, cell_feet(4, 19))
	GameState.set_flag("boss:zoradohna")  # keep the arena from starting its own fight
	await frames(1)
	var arena := _arena(w)
	for n: int in w.room.doors:
		arena._seal(n)  # as in the real fight: both doorways barred
	var z := Zoradohna.new()
	z.arena = Rect2(16, 64, 608, 256)
	z.position = cell_feet(cell.x, cell.y)
	w.room.add_child(z)
	w.player.max_hp = 9999
	w.player.hp = 9999
	await frames(2)
	z.set_state("walk")
	return [w, z]


func test_forepaw_lift_wakes_zoradohna() -> void:
	var w := make_world({}, LIFT_ROOM)
	await frames(3)
	var arena := _arena(w)
	check(arena != null and arena.boss_id == "zoradohna", "the Forepaw Lift is a boss arena")
	w.player.teleport(cell_feet(10, 19))
	var woke := await _until(func() -> bool: return arena.fighting, 20)
	var z := get_tree_boss() as Zoradohna
	check(woke and z != null, "walking in wakes Zoradohna")
	check(z != null and z.global_position.x > w.player.global_position.x + 200.0, "the drill waits across the lift")
	check(_count(w, LiftShaft) == 1, "the shaft is drawn behind the fight")
	check(arena.seals.has(1), "the way in seals behind the player")


func test_zoradohna_telegraphs_are_fair() -> void:
	var z := Zoradohna.new()
	for ph in [1, 2, 3]:
		z.phase = ph
		for t: float in [Zoradohna.DRILL_TELL, Zoradohna.SLAM_TELL, Zoradohna.DIVE_TELL]:
			check(z.tell(t) >= Enemy.MIN_TELEGRAPH, "phase %d tell %.2f s is at least %.2f s" % [ph, z.tell(t), Enemy.MIN_TELEGRAPH])
	z.free()


func test_zoradohna_hull_shrugs_off_side_blows_but_not_the_vents() -> void:
	var r := await _zora_world()
	var z: Zoradohna = r[1]
	var hp0 := z.hp
	z.take_hit(8, Vector2.RIGHT)
	check(z.hp == hp0 - 2, "the hull lets a quarter through (%d)" % (hp0 - z.hp))
	z.take_hit(8, Vector2(0, 1))
	check(z.hp == hp0 - 10, "a down-strike on the vents lands in full")
	check(z.is_in_group("pogo"), "and the player bounces off it")


func test_zoradohna_drills_into_the_wall_and_sticks() -> void:
	var r := await _zora_world(Vector2i(20, 19))
	var w: World = r[0]
	var z: Zoradohna = r[1]
	w.player.teleport(cell_feet(4, 14))
	await frames(1)
	z.facing = 1
	z.set_state("drill_tell")
	var tell_frames := [0]
	var stuck := await _until(func() -> bool:
		if z.state == "drill_tell":
			tell_frames[0] += 1
		return z.stuck(), 240)
	check(tell_frames[0] / 60.0 >= Enemy.MIN_TELEGRAPH, "the drill spins up for at least %.2f s (%d frames)" % [Enemy.MIN_TELEGRAPH, tell_frames[0]])
	check(stuck and z.global_position.x > 32 * Room.TILE, "rammed the far wall and stuck fast (x %.0f)" % z.global_position.x)
	var hp0 := z.hp
	z.take_hit(8, Vector2.LEFT)
	check(z.hp == hp0 - 8, "stuck, it takes a side blow in full")


func test_zoradohna_drill_hurts_the_player_in_its_path() -> void:
	var r := await _zora_world(Vector2i(24, 19))
	var w: World = r[0]
	var z: Zoradohna = r[1]
	w.player.teleport(cell_feet(14, 19))
	await frames(1)
	z.facing = -1
	z.set_state("drill_tell")
	var hp := w.player.hp
	var hit := await _until(func() -> bool: return w.player.hp < hp, 120)
	check(hit, "the charge runs the player down")


func test_zoradohna_slam_sends_shockwaves() -> void:
	var r := await _zora_world()
	var w: World = r[0]
	var z: Zoradohna = r[1]
	w.player.teleport(cell_feet(24, 19))
	z.facing = -1
	z.set_state("slam_tell")
	var dirs := {}
	await _until(func() -> bool:
		for c in w.room.get_children():
			if c is Shockwave:
				dirs[c.direction] = true
		return dirs.size() == 2, 120)
	check(dirs.has(-1) and dirs.has(1), "a shockwave rolls each way (%s)" % [dirs.keys()])


func test_zoradohna_phase_two_raises_the_lift_and_climbs() -> void:
	var r := await _zora_world()
	var w: World = r[0]
	var z: Zoradohna = r[1]
	var shaft := LiftShaft.new()
	shaft.area = z.arena
	shaft.boss = z
	w.room.add_child(shaft)
	z.set_state("stuck")
	z.hp = int(Zoradohna.MAX_HP * Zoradohna.PHASES[0]) + 4
	z.take_hit(8, Vector2(0, 1))
	check(z.phase == 2 and z.rising, "below %d%% the lift starts to rise" % int(Zoradohna.PHASES[0] * 100))
	var rocks := await _until(func() -> bool: return _count_rubble(w, "fall") > 0, 120)
	check(rocks, "debris falls from the shaft")
	await frames(30)
	check(shaft.is_rising(), "the girders stream past")
	w.player.teleport(cell_feet(20, 19))
	z.global_position = cell_feet(22, 19)
	z._since_climb = 2
	z.set_state("walk")
	var dove := await _until(func() -> bool: return z.state == "dive_tell", 300)
	check(dove and z.global_position.y < 12 * Room.TILE, "it climbs the wall (y %.0f)" % z.global_position.y)
	check(absf(z.dive_target.x - w.player.global_position.x) < 48.0, "and marks the player's spot")
	var landed := await _until(func() -> bool: return z.stuck(), 180)
	check(landed and z.is_on_floor(), "then dives and buries the drill in the floor")


func test_zoradohna_phase_three_opens_the_cockpit() -> void:
	var r := await _zora_world()
	var z: Zoradohna = r[1]
	z.phase = 2
	z.rising = true
	z.set_state("stuck")
	z.hp = int(Zoradohna.MAX_HP * Zoradohna.PHASES[1]) + 4
	z.take_hit(8, Vector2(0, 1))
	check(z.phase == 3 and z.state == "opening", "below %d%% the cockpit bursts open" % int(Zoradohna.PHASES[1] * 100))
	await frames(roundi(Zoradohna.OPEN_TIME * 60.0) + 5)
	var hp0 := z.hp
	z.take_hit(8, Vector2.RIGHT)
	check(z.hp == hp0, "now side blows glance off")
	z.take_hit(8, Vector2(0, 1))
	check(z.hp == hp0 - 12, "but a strike on the harness from above lands hard (%d)" % (hp0 - z.hp))


func test_zoradohna_defeat_gives_the_ruby_ring() -> void:
	var w := make_world({}, LIFT_ROOM)
	var p := w.player
	await frames(3)
	var arena := _arena(w)
	p.teleport(cell_feet(10, 19))
	await _until(func() -> bool: return arena.fighting, 20)
	var z := get_tree_boss() as Zoradohna
	await frames(2)
	z.set_state("stuck")
	z.hp = 1
	var points := int(GameState.data.skill_points)
	var rank := int(GameState.data.rank)
	z.take_hit(8, Vector2(0, 1))
	check(z.state == "dying", "the last blow shatters the harness")
	var gone := await _until(func() -> bool: return GameState.flag("boss:zoradohna"), 600)
	check(gone, "Zoradohna is marked beaten")
	check((GameState.data.rings as Array).has("ruby"), "the Ruby Ring is the player's")
	var ranks := int(GameState.data.rank) - rank
	check(int(GameState.data.skill_points) == points + 1 + ranks, "with a skill point (plus %d from rank-ups)" % ranks)
	var opened := await _until(func() -> bool: return arena.seals.is_empty() and _count(w, ArenaSeal) == 0, 1200)
	check(opened, "the way out opens")
	w._enter(LIFT_ROOM)
	await frames(5)
	check(get_tree_boss() == null, "it never comes back")
