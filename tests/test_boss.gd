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
	for name: String in ["title", "eolis", "trunk", "boss", "amb_trunk", "amb_eolis"]:
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
