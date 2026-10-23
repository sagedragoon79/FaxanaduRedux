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
