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


## Bible 4.4: bound fog seals the shaft above Lantern Landing. It tells you what
## it needs, holds without the Lantern Key, and parts for good when the key's
## light comes near. The key is not used up.
func test_bound_fog_parts_for_the_lantern_key() -> void:
	var w := make_world({}, "mist/lantern_landing", cell_feet(30, 19))
	await frames(3)
	var curtains := runner.get_tree().get_nodes_in_group("mist_curtain")
	check(curtains.size() == 3, "three tiles of bound fog seal the shaft (%d)" % curtains.size())
	var said: Array[String] = []
	var listen := func(text: String) -> void: said.append(text)
	GameState.toast.connect(listen)
	var c := curtains[0] as MistCurtain
	w.player.teleport(c.global_position + Vector2(0, 30))
	await frames(3)
	check(not c.parted and said.size() == 1 and said[0].contains("lantern"), "without the key it holds and says what it needs: %s" % [said])
	w.player.teleport(cell_feet(37, 9))
	await frames(2)
	GameState.add_key("lantern")
	await frames(3)
	var all_parted := true
	for n in runner.get_tree().get_nodes_in_group("mist_curtain"):
		all_parted = all_parted and (n as MistCurtain).parted
	check(all_parted and GameState.flag("curtain:mist/lantern_landing"), "the key's light parts every tile and the room remembers")
	check(GameState.key_count("lantern") == 1, "the Lantern Key is kept")
	GameState.toast.disconnect(listen)
	await frames(1)
	w._enter("mist/lantern_landing")
	await frames(2)
	var again := runner.get_tree().get_nodes_in_group("mist_curtain")
	check(not again.is_empty() and (again[0] as MistCurtain).parted, "back in the room, the fog is still parted")


## Bible 4.1 (A3): the Wing Boots lie on a perch in Feather Hollow. Taking them
## grants the double jump, and the game remembers it.
func test_wing_boots_grant_the_double_jump() -> void:
	var w := make_world({}, "mist/feather_hollow")
	await frames(3)
	var p := w.player
	check(not p.abilities.boots, "the run starts without the Wing Boots")
	var boots: ItemPickup = null
	for c in w.room.get_children():
		if c is ItemPickup and (c as ItemPickup).kind == "boots":
			boots = c
	check(boots != null, "the boots lie on the perch")
	if boots == null:
		return
	p.teleport(boots.global_position + Vector2(0, 12))
	await frames(3)
	check(p.abilities.boots and GameState.data.abilities.boots, "taking them grants the double jump and the save remembers it")
	w._enter("mist/feather_hollow")
	await frames(2)
	var again := false
	for c in w.room.get_children():
		again = again or (c is ItemPickup and (c as ItemPickup).kind == "boots")
	check(not again, "they don't come back")


## Bible 4.1 (A4) and 4.5: the Deluge scroll grants the spell, the fire seal
## burns whoever touches it, and one Deluge bolt douses the whole seal for good.
func test_deluge_douses_the_fire_seal_for_good() -> void:
	var w := make_world({}, "mist/marsh_road")
	await frames(3)
	var p := w.player
	p.max_hp = 9999
	p.hp = 9999
	var seals := runner.get_tree().get_nodes_in_group("fire_seal")
	check(seals.size() == 3, "three tiles of fire seal the road east (%d)" % seals.size())
	check(not p.abilities.deluge, "the run starts without Deluge")
	var scroll: ItemPickup = null
	for c in w.room.get_children():
		if c is ItemPickup and (c as ItemPickup).kind == "deluge":
			scroll = c
	check(scroll != null, "the scroll lies on the perch")
	if scroll == null:
		return
	p.teleport(scroll.global_position + Vector2(0, 12))
	await frames(3)
	check(p.abilities.deluge and GameState.data.abilities.deluge, "taking it grants Deluge and the save remembers")
	# Touching the flames burns.
	var hp := p.hp
	var seal := seals[1] as FireSeal
	p.teleport(seal.global_position + Vector2(-9, 24))
	await frames(4)
	check(p.hp < hp, "the flames burn on touch")
	# Back off, face the seal and cast.
	p.teleport(seal.global_position + Vector2(-80, 24))
	p.mp = p.max_mp
	await frames(30)
	p.facing = 1
	p.input.spell_pressed = true
	var out := false
	for i in 60:
		await frames(1)
		if seal.doused:
			out = true
			break
	var all_out := true
	for s in runner.get_tree().get_nodes_in_group("fire_seal"):
		all_out = all_out and (s as FireSeal).doused
	check(out and all_out and GameState.flag("seal:mist/marsh_road"), "one bolt douses every tile and the room remembers")
	w._enter("mist/marsh_road")
	await frames(2)
	var again := runner.get_tree().get_nodes_in_group("fire_seal")
	check(not again.is_empty() and (again[0] as FireSeal).doused, "back in the room the seal is still out")


## Bible 4.5: a Deluge bolt cast across a dry basin fills it, and a raft floats
## up to the water-line stain, standing as a one-way platform for good.
func test_drowned_boardwalks_rise_with_the_spring_of_mist() -> void:
	for id: String in ["mist/victim_causeway", "mist/fog_cut"]:
		var w := make_world({}, id)
		await frames(2)
		var cell := Vector2(17 * Room.TILE + 4, 20 * Room.TILE + 4)
		check(not w.room.is_one_way_at(cell) and not w.room.is_solid_at(cell), "%s: the boardwalk is under the water while the spring is dry" % id)
		GameState.set_flag("spring:mist")
		w._enter(id)
		await frames(2)
		check(w.room.is_one_way_at(cell), "%s: with the spring flowing it rises" % id)
		w.player.teleport(Vector2(cell.x, 20 * Room.TILE))
		await frames(20)
		check(w.player.is_on_floor() and absf(w.player.global_position.y - 20 * Room.TILE) < 2.0, "%s: and holds the player over the spikes" % id)
		w.queue_free()
		await frames(2)


func test_deluge_fills_the_dry_basin_and_floats_a_raft() -> void:
	var w := make_world({}, "mist/dry_cistern")
	await frames(3)
	var p := w.player
	p.max_hp = 9999
	p.hp = 9999
	p.abilities["deluge"] = true
	var basins := runner.get_tree().get_nodes_in_group("dry_basin")
	check(basins.size() == 1, "the cistern has one basin (%d)" % basins.size())
	if basins.is_empty():
		return
	var b := basins[0] as DryBasin
	var raft := Vector2((b.x0 + 8) * Room.TILE + 8, b.water_row * Room.TILE + 4)
	var surface := b.water_row * Room.TILE
	check(not w.room.is_one_way_at(raft), "dry, there is nothing to stand on at the stain")
	# From the west rim, cast across the tank.
	p.teleport(cell_feet(b.x0 - 1, b.water_row - 1))
	p.mp = p.max_mp
	await frames(20)
	p.facing = 1
	p.input.spell_pressed = true
	var full := false
	for i in 120:
		await frames(1)
		if b.filled and b.level >= 1.0:
			full = true
			break
	check(full and GameState.flag(b.flag_id), "the bolt fills the basin and the room remembers")
	check(w.room.is_one_way_at(raft), "the raft stands at the stain as a one-way platform")
	var left := 0
	for e in runner.get_tree().get_nodes_in_group("enemy"):
		if not (e as Enemy).dead and (e as Enemy).center().y > b.water_row * Room.TILE:
			left += 1
	check(left == 0, "the myconids in the tank drown (%d left)" % left)
	# Walk out onto the raft: it holds.
	p.teleport(raft + Vector2(0, -6))
	await frames(30)
	check(p.is_on_floor() and absf(p.global_position.y - b.water_row * Room.TILE) < 2.0, "the player stands on the raft (%.1f)" % p.global_position.y)
	w._enter("mist/dry_cistern")
	await frames(2)
	check(w.room.is_one_way_at(raft), "back in the room, the basin is still full")
	await frames(2)
	var back := 0
	for e in runner.get_tree().get_nodes_in_group("enemy"):
		if is_instance_valid(e) and not e.is_queued_for_deletion() and (e as Enemy).center().y > surface:
			back += 1
	check(back == 0, "and nothing lives in the water (%d)" % back)
