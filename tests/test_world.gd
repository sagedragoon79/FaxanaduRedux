extends TestSuite
## Rooms, breakables, targets and the gym file.


func test_gym_room_loads() -> void:
	var room := Room.from_file("res://levels/gym/gym.room")
	arena.add_child(room)
	check(room.title == "Movement Gym", "room title from header")
	check(room.size_tiles == Vector2i(170, 46), "gym size 170x46 tiles (got %s)" % room.size_tiles)
	check(room.spawn_position != Vector2.ZERO, "spawn marker found")
	var dummies := 0
	var cracked := 0
	var spikes := 0
	var bulbs := 0
	for c in room.get_children():
		if c is TrainingDummy: dummies += 1
		elif c is CrackedBlock: cracked += 1
		elif c is Spikes: spikes += 1
		elif c is ThornBulb: bulbs += 1
	check(dummies >= 3 and cracked >= 6 and spikes >= 20 and bulbs == 3, "gym entities: %d dummies, %d cracked, %d spikes, %d bulbs" % [dummies, cracked, spikes, bulbs])


func test_gym_spawn_is_safe() -> void:
	var room := Room.from_file("res://levels/gym/gym.room")
	arena.add_child(room)
	var p := Player.new()
	p.input.scripted = true
	p.position = room.spawn_position
	room.add_child(p)
	await frames(30)
	check(p.is_on_floor() and p.hp == p.max_hp, "player stands safely at the gym spawn")


func test_slash_hits_dummy() -> void:
	var room := make_room([
		"############",
		"#..........#",
		"#..........#",
		"#..........#",
		"#....E.....#",
		"############",
	])
	var p := make_player(room, Vector2i(3, 4))
	await frames(6)
	var dummy: TrainingDummy
	for c in room.get_children():
		if c is TrainingDummy:
			dummy = c
	p.facing = 1
	p.input.attack_pressed = true
	await frames(8)
	check(dummy.hits_taken == 1, "one slash lands exactly one hit (got %d)" % dummy.hits_taken)


func test_down_strike_breaks_cracked_floor() -> void:
	var rows := [
		"##########",
		"#........#",
		"#........#",
		"#........#",
		"#........#",
		"#........#",
		"####CC####",
		"#........#",
		"##########",
	]
	var room := make_room(rows)
	var p := make_player(room, Vector2i(4, 1))
	p.position.x = 5 * Room.TILE
	var floor_y := 6 * Room.TILE
	for i in 60:
		if p.velocity.y > 0.0 and p.global_position.y > floor_y - 28.0 and not p.is_attacking:
			p.input.down = true
			p.input.attack_pressed = true
		await frames(1)
	check(p.global_position.y > 7 * Room.TILE, "fell through the broken floor (y %.1f)" % p.global_position.y)


func test_cracked_wall_needs_mattock() -> void:
	var rows := [
		"##########",
		"#........#",
		"#........#",
		"#....C...#",
		"#....C...#",
		"#....C...#",
		"##########",
	]
	var room := make_room(rows)
	var p := make_player(room, Vector2i(4, 5), {"mattock": false})
	await frames(6)
	p.facing = 1
	p.input.attack_pressed = true
	await frames(10)
	var intact := 0
	for c in room.get_children():
		if c is CrackedBlock and c.visible:
			intact += 1
	check(intact == 3, "slash without the Mattock leaves the wall intact")
	p.abilities["mattock"] = true
	await frames(20)
	p.input.attack_pressed = true
	await frames(10)
	intact = 0
	for c in room.get_children():
		if c is CrackedBlock and c.visible:
			intact += 1
	check(intact < 3, "slash with the Mattock breaks cracked stone")


func test_gym_enemies_stay_put() -> void:
	var room := Room.from_file("res://levels/gym/gym.room")
	arena.add_child(room)
	var enemies: Array[Enemy] = []
	for c in room.get_children():
		if c is Enemy:
			enemies.append(c)
	check(enemies.size() == 3, "gym has 3 enemies (got %d)" % enemies.size())
	await frames(120)
	for e in enemies:
		var inside := room.pixel_rect().has_point(e.global_position)
		check(inside and not e.dead and e.global_position.distance_to(e.home) < 120.0,
			"%s stays near its post (home %s, now %s)" % [e.get_script().get_global_name(), e.home, e.global_position])


func test_arriving_through_a_door_clears_cracked_stone_in_the_way() -> void:
	# The Forepaw Stair can be entered from its far side (a test, a later shortcut);
	# coming back must not leave the player inside Winch Hall's cracked wall.
	var w := make_world({}, "tower/forepaw_stair")
	await frames(2)
	w.use_door(1)
	await frames(3)
	check(w.room.id == "tower/winch_hall", "door 1 leads back to Winch Hall")
	var body := w.player.body_rect().grow(-1.0)
	var blocking := 0
	var cleared := 0
	for c in w.room.get_children():
		if c is CrackedBlock:
			var r := Rect2(c.global_position - Vector2(8, 8), Vector2(16, 16))
			if c.visible and r.intersects(body):
				blocking += 1
			if not c.visible:
				cleared += 1
	check(blocking == 0 and cleared > 0, "the stone around the arrival gave way (%d cleared)" % cleared)
	await frames(20)
	var feet := w.player.global_position
	check(w.player.is_on_floor() and not w.room.is_solid_at(feet + Vector2(0, -4)), "and the player stands on the floor, not in it (%s)" % feet)


# --- The Mist's fog ------------------------------------------------------------------

func _fog_world(ghost := Vector2i(-1, -1)) -> World:
	var rows := grid_rows(40, 23)
	put_tiles(rows, 3, 19, "P")
	put_tiles(rows, 30, 19, "S")
	put_tiles(rows, 20, 4, "#", 1, 16)
	if ghost.x >= 0:
		put_tiles(rows, ghost.x, ghost.y, "A")
	return make_world({"test/a": room_text(["name: Fog", "zone: mist"], rows)}, "test/a")


func test_the_mist_fog_hides_all_but_the_light() -> void:
	var w := _fog_world()
	await frames(3)
	var fog := w.fog
	check(fog.visible and fog.density == Fog.ZONES.mist, "the Mist is fogged (%.2f)" % fog.density)
	var p := w.player
	check(fog.clear_at(p.global_position + Vector2(0, -14)) == 1.0, "the player sees around themself")
	check(fog.lights[0] == Vector3(p.global_position.x, p.global_position.y - 14.0, Fog.VISION), "the player carries the first light")
	check(fog.lights.size() > 1, "the room's lanterns and shrine are lights too (%d)" % fog.lights.size())
	var own := fog.lights[0]
	fog.lights = [own]
	check(fog.clear_at(p.global_position + Vector2(Fog.VISION + 20.0, -14)) == 0.0, "past their sight the fog is thick")
	check(fog.visibility_at(Vector2(16 * 25, 100)) < 0.2, "out in the murk little shows through (%.2f)" % fog.visibility_at(Vector2(16 * 25, 100)))
	await frames(1)
	check(fog.clear_at(cell_feet(30, 19) + Vector2(0, -8)) == 1.0, "a shrine's glow clears a pocket")
	GameState.set_flag(Fog.SPRING_FLAG)
	fog.set_room(w.room)
	await frames(1)
	check(is_equal_approx(fog.density, Fog.ZONES.mist * Fog.SPRING_DENSITY), "the restored spring thins the fog by half")
	check(fog.clear_at(p.global_position + Vector2(Fog.VISION + 20.0, -14)) > 0.0, "and the player sees further")
	w._enter("tower/foot")
	await frames(1)
	check(not w.fog.visible and w.fog.visibility_at(Vector2(100, 100)) == 1.0, "other zones have no fog")
