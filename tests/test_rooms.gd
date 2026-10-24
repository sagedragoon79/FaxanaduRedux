extends TestSuite
## The World: doors between rooms, saving, respawn, the gold purse, pickups,
## chests, secrets, the map catalog and dialog.

const SAVE_SLOT := 9


# --- Helpers ---------------------------------------------------------------------

## Room A: shrine, spawn, a right-edge door (1) to B and a floor shaft (2) down to B.
## Room B: a left-edge door (1), a ceiling door (2), an inner door (3) to C.
## Room C: an inner door (1) back to B.
func _rooms(extra_a := {}) -> Dictionary:
	var a := grid_rows(40, 23)
	put_tiles(a, 39, 17, "1", 1, 3)
	put_tiles(a, 5, 19, "P")
	put_tiles(a, 10, 19, "S")
	put_tiles(a, 20, 20, ".", 3, 2)
	put_tiles(a, 20, 22, "2", 3, 1)
	for k: Vector2i in extra_a:
		put_tiles(a, k.x, k.y, extra_a[k])
	var b := grid_rows(40, 23)
	put_tiles(b, 0, 17, "1", 1, 3)
	put_tiles(b, 20, 0, "2", 3, 1)
	put_tiles(b, 30, 19, "3")
	put_tiles(b, 6, 19, "P")
	var c := grid_rows(40, 23)
	put_tiles(c, 10, 19, "1")
	put_tiles(c, 5, 19, "P")
	return {
		"test/a": room_text(["name: Room A", "zone: test", "map: 0, 0", "door: 1, test/b, 1", "door: 2, test/b, 2"], a),
		"test/b": room_text(["name: Room B", "zone: test", "map: 1, 0", "door: 1, test/a, 1", "door: 2, test/a, 2", "door: 3, test/c, 1"], b),
		"test/c": room_text(["name: Room C", "zone: test", "map: 1, 1", "door: 1, test/b, 3"], c),
	}


# --- Doors -----------------------------------------------------------------------

func test_side_door_moves_player_to_next_room() -> void:
	var w := make_world(_rooms(), "test/a", cell_feet(35, 19))
	await frames(5)
	w.player.input.move_x = 1
	await frames(40)
	check(w.room.id == "test/b", "walked through the right door into room B (in %s)" % w.room.id)
	check(w.player.global_position.x < 120.0, "arrived at B's left edge (x %.0f)" % w.player.global_position.x)
	check(GameState.is_visited("test/a") and GameState.is_visited("test/b"), "both rooms marked visited")
	w.player.input.move_x = 0
	await frames(30)
	check(w.room.id == "test/b" and w.player.is_on_floor(), "stays in B, standing (no ping-pong)")
	w.player.input.move_x = -1
	await frames(30)
	check(w.room.id == "test/a", "walking back left returns to A")
	check(w.player.global_position.x > 560.0, "arrived at A's right edge (x %.0f)" % w.player.global_position.x)


func test_floor_and_ceiling_doors() -> void:
	var w := make_world(_rooms(), "test/a", cell_feet(18, 19))
	await frames(5)
	w.player.input.move_x = 1
	await frames(14)
	w.player.input.move_x = 0
	await frames(60)
	check(w.room.id == "test/b", "falling down the shaft leads to room B (in %s)" % w.room.id)
	check(w.player.is_on_floor(), "landed on B's floor")


func test_inner_door_needs_up() -> void:
	var w := make_world(_rooms(), "test/b", cell_feet(30, 19))
	await frames(10)
	check(w.room.id == "test/b", "standing in an inner doorway does nothing by itself")
	w.player.input.up_pressed = true
	await frames(3)
	check(w.room.id == "test/c", "pressing Up goes through (in %s)" % w.room.id)
	check(absf(w.player.global_position.x - (10 * 16 + 8)) < 2.0, "arrives at C's door")
	await frames(5)
	w.player.input.up_pressed = true
	await frames(3)
	check(w.room.id == "test/b", "and back again")


# --- Saving, death, purse ------------------------------------------------------------

func test_shrine_saves_and_round_trips() -> void:
	var w := make_world(_rooms(), "test/a", cell_feet(10, 19))
	GameState.slot = SAVE_SLOT
	await frames(5)
	w.player.gold = 321
	w.player.hp = 30
	w.player.input.up_pressed = true
	await frames(2)
	check(w.player.hp == w.player.max_hp, "resting restores health")
	check(GameState.data.save_room == "test/a", "save point recorded")
	check(GameState.has_save(SAVE_SLOT), "save file written")
	GameState.data.gold = 0
	GameState.data.save_room = ""
	check(GameState.load_game(SAVE_SLOT), "save loads")
	check(int(GameState.data.gold) == 321 and GameState.data.save_room == "test/a", "gold and save room survive the round trip")
	check(GameState.is_visited("test/a"), "visited rooms survive the round trip")
	GameState.delete_save(SAVE_SLOT)
	check(not GameState.has_save(SAVE_SLOT), "save deleted")


func test_act_one_state_survives_a_save_round_trip() -> void:
	GameState.slot = SAVE_SLOT
	GameState.set_flag("spring:trunk")
	GameState.set_flag("boss:zoradohna")
	GameState.meet_guru("trunk/apolune", Vector2(200, 320))
	GameState.meet_guru("tower/forepaw", Vector2(168, 320))
	GameState.data.tempers["hand_dagger"] = 2
	GameState.data.named_rank = 3
	GameState.data.mantra_shards = 2
	GameState.data.abilities["mattock"] = true
	check(GameState.save_game(), "the save writes")
	GameState.new_game()
	check(GameState.mantra_stops("").is_empty() and not GameState.mantra_path_open(), "a new game forgets it all")
	check(GameState.load_game(SAVE_SLOT), "and the save loads")
	check(GameState.mantra_path_open() and GameState.flag("boss:zoradohna"), "spring and boss flags survive")
	check(GameState.mantra_stops("trunk/apolune") == ["tower/forepaw"], "Mantra Path stops survive")
	var at: Array = GameState.data.gurus["tower/forepaw"]
	check(is_equal_approx(float(at[0]), 168.0), "with their positions")
	check(GameState.temper_level("hand_dagger") == 2, "the blade's temper survives")
	check(int(GameState.data.named_rank) == 3 and int(GameState.data.mantra_shards) == 2, "title and shards survive")
	check(GameState.has_ability("mattock"), "the Mattock survives")
	GameState.delete_save(SAVE_SLOT)


## Act II (the Mist): every world change made there comes back after a save,
## and the rooms rebuild in their changed state.
func test_act_two_state_survives_a_save_round_trip() -> void:
	var w := make_world({}, "mist/lantern_landing")
	GameState.slot = SAVE_SLOT
	for f: String in ["boss:ripasheiku", "boss:zorugeriru", "spring:mist", "curtain:mist/lantern_landing",
			"seal:mist/marsh_road", "basin:mist/dry_cistern:7"]:
		GameState.set_flag(f)
	(GameState.data.rings as Array).append_array(["elf", "ruby", "dworf"])
	GameState.add_key("lantern")
	GameState.data.abilities["boots"] = true
	GameState.data.abilities["deluge"] = true
	check(GameState.save_game(), "the save writes")
	GameState.new_game()
	check(not GameState.flag("spring:mist") and (GameState.data.rings as Array).is_empty(), "a new game forgets it all")
	check(GameState.load_game(SAVE_SLOT), "and the save loads")
	check(GameState.flag("boss:zorugeriru") and GameState.flag("spring:mist"), "boss and spring flags survive")
	check((GameState.data.rings as Array) == ["elf", "ruby", "dworf"], "the three rings survive")
	check(GameState.key_count("lantern") == 1, "the Lantern Key survives")
	check(GameState.has_ability("boots") and GameState.has_ability("deluge"), "the Wing Boots and Deluge survive")
	var found := {}
	for stop: Array in [["mist/lantern_landing", MistCurtain], ["mist/marsh_road", FireSeal], ["mist/dry_cistern", DryBasin],
			["mist/spring_of_mist", DryBasin]]:
		w._enter(stop[0])
		await frames(2)
		for c in w.room.get_children():
			if is_instance_of(c, stop[1]):
				var open: bool = c.parted if c is MistCurtain else (c.doused if c is FireSeal else c.filled)
				found[stop[0]] = found.get(stop[0], true) and open
	check(found.get("mist/lantern_landing", false), "the bound fog stays parted")
	check(found.get("mist/marsh_road", false), "the fire seal stays out")
	check(found.get("mist/dry_cistern", false), "the cistern stays full")
	check(found.get("mist/spring_of_mist", false), "the hydra's tanks stay full")
	check(_arena_quiet(w), "and Zorugeriru doesn't come back")
	w._enter("mist/victim_causeway")
	await frames(2)
	check(w.room.is_one_way_at(Vector2(17 * Room.TILE + 4, 20 * Room.TILE + 4)), "the drowned boardwalks stay risen")
	GameState.delete_save(SAVE_SLOT)


## Act II (the Branches): the Elven Stride, Conflate's charts, Pakukame's fall
## and the skills bought with its point all come back after a save.
func test_branches_state_survives_a_save_round_trip() -> void:
	var w := make_world({}, "branches/windloft")
	GameState.slot = SAVE_SLOT
	await frames(2)
	var stride_id := ""
	for c in w.room.get_children():
		if c is ItemPickup and (c as ItemPickup).kind == "stride":
			stride_id = (c as ItemPickup).pickup_id
	check(stride_id != "", "the Elven Stride waits in the Windloft")
	GameState.collect(stride_id)
	GameState.data.abilities["stride"] = true
	GameState.set_flag("boss:pakukame")
	GameState.data.charts["branches"] = true
	GameState.meet_guru("branches/conflate", Vector2(400, 320))
	GameState.data.skills = ["deep_pockets", "gold_sense", "quick_draught", "second_stride"]
	check(GameState.save_game(), "the save writes")
	GameState.new_game()
	check(not GameState.has_ability("stride") and GameState.data.skills.is_empty(), "a new game forgets it all")
	check(GameState.load_game(SAVE_SLOT), "and the save loads")
	check(GameState.has_ability("stride") and GameState.flag("boss:pakukame"), "the Stride and Pakukame's fall survive")
	check(GameState.has_chart("branches"), "the Branches chart survives")
	check(GameState.data.gurus.has("branches/conflate"), "Conflate's guru is still met")
	GameState.apply(w.player)
	check(w.player.bonus_air_dashes == 1 and w.player.abilities.get("stride", false), "Second Stride is back on the player")
	w._enter("branches/windloft")
	await frames(2)
	var left := false
	for c in w.room.get_children():
		left = left or (c is ItemPickup and (c as ItemPickup).kind == "stride")
	check(not left, "the Stride doesn't come back to its plinth")
	w._enter("branches/crown_leaf")
	await frames(2)
	check(_arena_quiet(w), "and Pakukame doesn't come back")
	GameState.delete_save(SAVE_SLOT)


func _arena_quiet(w: World) -> bool:
	return runner.get_tree().get_first_node_in_group("boss") == null


func test_death_respawns_at_last_shrine_and_purse_persists() -> void:
	var w := make_world(_rooms(), "test/a", cell_feet(10, 19))
	GameState.slot = SAVE_SLOT
	await frames(5)
	w.player.input.up_pressed = true
	await frames(2)
	w.use_door(1)
	await frames(2)
	check(w.room.id == "test/b", "moved to room B")
	w.player.teleport(cell_feet(25, 19))
	w.player.gold = 100
	w.player.take_damage(9999)
	await frames(2)
	check(GameState.data.purse.get("room", "") == "test/b", "purse recorded in room B")
	await frames(int(w.player.combat.respawn_delay * 60) + 10)
	check(not w.player.dead and w.room.id == "test/a", "respawned in the shrine room (in %s)" % w.room.id)
	check(absf(w.player.global_position.x - (10 * 16 + 8)) < 2.0, "respawned at the shrine")
	w.use_door(1)
	await frames(2)
	var purses := 0
	for c in w.room.get_children():
		if c is GoldPurse:
			purses += 1
	check(purses == 1, "the purse is waiting in room B")
	GameState.delete_save(SAVE_SLOT)


# --- Pickups ---------------------------------------------------------------------

func test_life_fruit_and_shards() -> void:
	var w := make_world(_rooms({Vector2i(8, 19): "L", Vector2i(12, 19): "F", Vector2i(14, 19): "F", Vector2i(16, 19): "F", Vector2i(18, 19): "*"}), "test/a", cell_feet(6, 19))
	await frames(5)
	var hp0 := w.player.max_hp
	var flask0 := w.player.flask_max
	w.player.input.move_x = 1
	await frames(74)
	w.player.input.move_x = 0
	await frames(10)
	check(w.player.max_hp == hp0 + GameState.LIFE_FRUIT_HP, "Life Fruit adds half a mask (%d)" % w.player.max_hp)
	check(w.player.flask_max == flask0 + 1, "three Potion Shards add a flask charge")
	check(int(GameState.data.mantra_shards) == 1, "one Mantra Shard counted")
	check(int(GameState.data.max_hp) == w.player.max_hp, "stats captured into the game state")
	w.player.input.move_x = 0
	w.use_door(1)
	await frames(2)
	w.use_door(1)
	await frames(2)
	var items := 0
	for c in w.room.get_children():
		if c is ItemPickup:
			items += 1
	check(items == 0, "collected items don't come back")


func test_mantra_shards_give_a_skill_point() -> void:
	var w := make_world(_rooms({Vector2i(8, 19): "*", Vector2i(10, 18): "*", Vector2i(12, 19): "*"}), "test/a", cell_feet(6, 19))
	await frames(5)
	w.player.input.move_x = 1
	await frames(50)
	check(int(GameState.data.skill_points) == 1, "three Mantra Shards make a skill point")


func test_glove_pickup_grants_wall_jump() -> void:
	var w := make_world(_rooms({Vector2i(8, 19): "G"}), "test/a", cell_feet(6, 19))
	check(not w.player.abilities.glove, "a new game starts without the glove")
	await frames(5)
	w.player.input.move_x = 1
	await frames(20)
	check(w.player.abilities.glove and GameState.has_ability("glove"), "glove picked up")


func test_chest_opens_once() -> void:
	var w := make_world(_rooms({Vector2i(8, 19): "$"}), "test/a", cell_feet(8, 19))
	await frames(5)
	w.player.input.up_pressed = true
	await frames(2)
	var coins := 0
	var chest: Chest = null
	for c in w.room.get_children():
		if c is Coin:
			coins += 1
		elif c is Chest:
			chest = c
	check(chest != null and chest.is_open(), "chest opened")
	check(coins > 0, "gold sprays out (%d coins)" % coins)
	await frames(90)
	check(w.player.gold == 100, "all chest gold collected (%d)" % w.player.gold)
	w.use_door(1)
	await frames(2)
	w.use_door(1)
	await frames(2)
	for c in w.room.get_children():
		if c is Chest:
			chest = c
	check(chest.is_open() and not chest.is_in_group("interactable"), "chest stays open after leaving")


func test_root_heart_opens_the_root_gate_for_good() -> void:
	var extra := {Vector2i(8, 19): "N", Vector2i(30, 17): "R", Vector2i(30, 18): "R", Vector2i(30, 19): "R"}
	var texts := _rooms(extra)
	var w := make_world(texts, "test/a", cell_feet(27, 19))
	var p := w.player
	await frames(2)
	p.input.move_x = 1
	await frames(40)
	p.input.move_x = 0
	check(p.global_position.x < 30 * Room.TILE, "the roots block the way (x %.0f)" % p.global_position.x)
	# Walk to the heart and strike it.
	p.teleport(cell_feet(6, 19))
	p.facing = 1
	await frames(2)
	p.input.attack_pressed = true
	await frames(12)
	var heart: RootHeart = null
	for c in w.room.get_children():
		if c is RootHeart:
			heart = c
	check(heart != null and heart.struck, "the blade strikes the Root Heart")
	check(GameState.flag("roots:test/a"), "and the room remembers")
	p.teleport(cell_feet(27, 19))
	await frames(45)
	p.input.move_x = 1
	await frames(40)
	p.input.move_x = 0
	check(p.global_position.x > 31 * Room.TILE, "the gate has drawn back (x %.0f)" % p.global_position.x)
	var again := Room.from_text(texts["test/a"], "test/a")
	arena.add_child(again)
	var still_open := true
	var passable := true
	for c in again.get_children():
		if c is RootGate:
			if not (c as RootGate).open:
				still_open = false
			for s in c.get_children():
				if s is CollisionShape2D and not (s as CollisionShape2D).disabled:
					passable = false
	check(still_open, "it stays open on the next visit")
	check(passable, "and its roots don't block the way (no solid shape left behind)")
	again.queue_free()


func test_fake_wall_is_passable() -> void:
	var extra := {}
	for y in range(1, 20):
		extra[Vector2i(14, y)] = "%"
	var w := make_world(_rooms(extra), "test/a", cell_feet(12, 19))
	await frames(5)
	w.player.input.move_x = 1
	await frames(30)
	check(w.player.global_position.x > 15 * 16, "walked through the fake wall (x %.0f)" % w.player.global_position.x)
	check(GameState.flag("secret:test/a"), "secret found flag set")


func test_cracked_wall_stays_broken() -> void:
	var w := make_world(_rooms({Vector2i(12, 19): "C"}), "test/a", cell_feet(10, 19))
	w.player.abilities.mattock = true
	await frames(5)
	var block: CrackedBlock = null
	for c in w.room.get_children():
		if c is CrackedBlock:
			block = c
	check(block != null and not block.respawns, "world cracked blocks don't regrow")
	block.break_block()
	w.use_door(1)
	await frames(2)
	w.use_door(1)
	await frames(2)
	var left := 0
	for c in w.room.get_children():
		if c is CrackedBlock:
			left += 1
	check(left == 0, "broken wall is remembered")


# --- Map and dialog --------------------------------------------------------------

func test_catalog_reads_map_and_doors() -> void:
	var w := make_world(_rooms())
	var a: Dictionary = w.catalog["test/a"]
	check(a.map == Vector2i(0, 0) and a.screens == Vector2i(1, 1), "room A at map 0,0, one screen")
	check(a.doors[1].edge == "right" and a.doors[1].target == "test/b", "door 1 is a right edge door to B")
	check(a.doors[2].edge == "bottom", "door 2 is a floor door")
	check(a.shrines.size() == 1, "shrine listed for the map")
	check(w.catalog["test/b"].doors[3].edge == "inner", "B's door 3 is an inner door")
	check(MapScreen.room_rect(w.catalog["test/c"]).position == Vector2(1, 1) * MapScreen.CELL, "map rect uses the map position")


func test_every_real_door_has_a_matching_door() -> void:
	var w := World.new()
	arena.add_child(w)
	w.build_catalog()
	var bad: Array[String] = []
	for room_id: String in w.catalog:
		var info: Dictionary = w.catalog[room_id]
		for n: int in info.doors:
			var d: Dictionary = info.doors[n]
			if not w.catalog.has(d.target):
				bad.append("%s door %d -> missing %s" % [room_id, n, d.target])
				continue
			var back: Dictionary = w.catalog[d.target].doors.get(d.target_door, {})
			if back.is_empty() or back.target != room_id or back.target_door != n:
				bad.append("%s door %d -> %s door %d does not lead back" % [room_id, n, d.target, d.target_door])
	check(bad.is_empty(), "all doors in levels/ pair up: %s" % ", ".join(bad))


func test_tablet_opens_dialog() -> void:
	var rooms := _rooms()
	rooms["test/a"] = rooms["test/a"].replace("---", "sign: 8, 19, First page|Second page\n---")
	var w := make_world(rooms, "test/a", cell_feet(8, 19))
	var got := []
	var listener := func(who: String, pages: Array) -> void: got.append(pages)
	GameState.dialog_requested.connect(listener)
	await frames(5)
	w.player.input.up_pressed = true
	await frames(2)
	GameState.dialog_requested.disconnect(listener)
	check(got.size() == 1 and got[0].size() == 2, "reading a tablet opens a two-page dialog")


func test_sap_slows_running_and_jumping() -> void:
	var extra := {}
	for x in range(10, 30):
		extra[Vector2i(x, 20)] = "~"
		extra[Vector2i(x, 21)] = "~"
	var w := make_world(_rooms(extra), "test/a", cell_feet(14, 21))
	var p := w.player
	await frames(5)
	p.input.move_x = 1
	await frames(30)
	check(p.in_sap, "standing in the sap pool")
	check_near(p.velocity.x, p.tuning.run_speed * Player.SAP_SPEED, 1.0, "run speed halved in sap")
	p.input.move_x = 0
	p.input.jump_pressed = true
	p.input.jump_held = true
	await frames(1)
	# One frame of gravity has already been applied.
	check_near(-p.velocity.y, p.tuning.jump_velocity * Player.SAP_JUMP - p.tuning.gravity / 60.0, 2.0, "weaker jump out of sap")


# --- Tiles ---------------------------------------------------------------------------

func test_autotiles_match_their_neighbours() -> void:
	check(TilesetFactory.blob_masks().size() == 47, "47 blob autotiles")
	var rows := grid_rows(30, 23)
	put_tiles(rows, 10, 10, "#")
	put_tiles(rows, 3, 19, "P")
	var room := Room.from_text(room_text(["name: T", "zone: trunk"], rows), "t/tiles")
	arena.add_child(room)
	var lone := room.tiles.get_cell_atlas_coords(Vector2i(10, 10))
	check(lone == TilesetFactory.ground(0), "a lone block uses the all-edges tile (%s)" % lone)
	var floor_top := room.tiles.get_cell_atlas_coords(Vector2i(10, 20))
	var top_mask := TilesetFactory.FULL & ~(TilesetFactory.N | TilesetFactory.NE | TilesetFactory.NW)
	check(floor_top == TilesetFactory.ground(top_mask), "the floor's top row has a top edge (%s)" % floor_top)
	var mid := room.tiles.get_cell_atlas_coords(Vector2i(10, 21))
	check(mid in TilesetFactory.MID, "two tiles into the floor is darker (%s)" % mid)
	var deep := room.tiles.get_cell_atlas_coords(Vector2i(10, 22))
	check(deep in TilesetFactory.DEEP, "three tiles in is darker still (%s)" % deep)
	check(room.is_solid_at(Vector2(10 * 16 + 8, 22 * 16 + 8)), "darker interior tiles are still solid")
	room.queue_free()


func test_footsteps_follow_the_surface_underfoot() -> void:
	var rows := grid_rows(40, 23)
	put_tiles(rows, 20, 15, "-", 5)
	put_tiles(rows, 30, 19, "~", 4)
	put_tiles(rows, 3, 19, "P")
	var room := Room.from_text(room_text(["name: T", "zone: tower"], rows), "t/steps")
	arena.add_child(room)
	var below := func(x: int, y: int) -> Vector2: return cell_feet(x, y) + Vector2(0, 2)
	check(room.surface_at(below.call(5, 19)) == "iron", "Tower floors ring as iron (%s)" % room.surface_at(below.call(5, 19)))
	check(room.surface_at(below.call(22, 14)) == "plank", "platforms are planks")
	check(room.surface_at(below.call(31, 19)) == "sap", "a sap pool squelches")
	check(room.surface_at(below.call(10, 10)) == "", "nothing underfoot in mid-air")
	for s: String in ["stone", "moss", "plank", "iron", "sap"]:
		check(ResourceLoader.exists("res://assets/sfx/step_%s.wav" % s), "a step sound for %s" % s)
	var heard: Array[String] = []
	var p := make_player(room, Vector2i(3, 19))
	p.footstep.connect(func(surface: String) -> void: heard.append(surface))
	await frames(5)
	p.input.move_x = 1
	await frames(60)
	p.input.move_x = 0
	check(heard.size() >= 2 and heard.has("iron"), "running plays iron footsteps (%s)" % [heard])
	room.queue_free()
	await frames(1)
	var trunk := Room.from_text(room_text(["name: T", "zone: trunk"], grid_rows(10, 23)), "t/moss")
	var paved := Room.from_text(room_text(["name: T", "zone: trunk", "surface: stone"], grid_rows(10, 23)), "t/paved")
	arena.add_child(trunk)
	arena.add_child(paved)
	check(trunk.surface_at(below.call(5, 19)) == "moss", "the Trunk is soft moss")
	check(paved.surface_at(below.call(5, 19)) == "stone", "a room's surface header overrides its zone")
	trunk.queue_free()
	paved.queue_free()


func test_every_zone_has_a_tileset() -> void:
	var missing: Array[String] = []
	for zone: String in DirAccess.get_directories_at("res://levels"):
		if not ResourceLoader.exists(TilesetFactory.TILES_DIR + zone + ".png"):
			missing.append(zone)
	check(missing.is_empty(), "every zone folder has a generated tileset: missing %s" % [missing])


func test_tiles_are_drawn_at_double_density() -> void:
	var size := TilesetFactory.TILE * TilesetFactory.DENSITY
	var small: Array[String] = []
	for zone: String in DirAccess.get_directories_at("res://levels"):
		var tex: Texture2D = load(TilesetFactory.TILES_DIR + zone + ".png")
		if tex.get_width() != TilesetFactory.COLUMNS * size or tex.get_height() != 7 * size:
			small.append(zone)
	check(small.is_empty(), "every atlas holds %d px tiles (wrong: %s)" % [size, small])
	var room := make_room(["##########", "#........#", "#........#", "#........#", "#........#", "##########", "##########"])
	check(room.tiles.map_to_local(Vector2i(3, 5)) * room.tiles.scale == Vector2(3 * 16 + 8, 5 * 16 + 8), "yet each tile still covers 16 world pixels")
	var p := make_player(room, Vector2i(3, 4))
	await frames(20)
	check(p.is_on_floor() and absf(p.global_position.y - 5 * 16) < 0.5, "and the player stands on the floor's top edge (y %.2f)" % p.global_position.y)
	room.queue_free()


func test_decor_and_backgrounds_are_drawn_at_double_density() -> void:
	for zone in ["trunk", "eolis"]:
		var meta: Dictionary = (load(Decor.DIR + zone + ".json") as JSON).data
		var tex: Texture2D = load(Decor.DIR + zone + ".png")
		var density := int(meta.get("density", 1))
		check(density == TilesetFactory.DENSITY, "%s decor is painted at %dx" % [zone, density])
		check(tex.get_height() == 4 * int(meta.cell[1]) * density, "%s decor atlas holds 4 rows of %dx cells" % [zone, density])
	var backdrop := Backdrop.new()
	arena.add_child(backdrop)
	backdrop.set_zone("trunk")
	check(backdrop.get_child_count() == 2, "the trunk has two parallax layers")
	for layer in backdrop.get_children():
		var sprite := layer.get_child(0) as Sprite2D
		check(sprite.texture.get_width() == Backdrop.SIZE.x * TilesetFactory.DENSITY, "a background is painted at %dx" % TilesetFactory.DENSITY)
		check(sprite.texture.get_size() * sprite.scale == Backdrop.SIZE, "yet it still covers %s world pixels" % [Backdrop.SIZE])
	backdrop.queue_free()


func test_every_zone_is_dressed() -> void:
	# A zone with rooms gets its name on the map, a decor atlas, parallax layers and motes.
	for zone: String in DirAccess.get_directories_at("res://levels"):
		if zone == "gym":
			continue
		check(World.ZONES.has(zone), "%s has a map name and color" % zone)
		check(ResourceLoader.exists(Decor.DIR + zone + ".png"), "%s has a decor atlas" % zone)
		check(Decor.GLOW_COLORS.has(zone), "%s has a glow color for its lights" % zone)
		check(Motes.ZONES.has(zone), "%s has motes in the air" % zone)
		var backdrop := Backdrop.new()
		arena.add_child(backdrop)
		backdrop.set_zone(zone)
		check(backdrop.get_child_count() == 2, "%s has two parallax layers" % zone)
		backdrop.queue_free()


func test_decor_dresses_open_surfaces_only() -> void:
	var rows := grid_rows(40, 23)
	put_tiles(rows, 3, 19, "P")
	put_tiles(rows, 20, 19, "^")
	put_tiles(rows, 39, 17, "1", 1, 3)
	var text := room_text(["name: T", "zone: trunk", "door: 1, t/x, 1"], rows)
	var room := Room.from_text(text, "t/decor")
	arena.add_child(room)
	var decor: Decor = room.get_node("Decor")
	check(decor.pieces.size() > 10, "a trunk room gets decor (%d pieces)" % decor.pieces.size())
	var bad: Array = []
	for piece: Array in decor.pieces:
		var cell: Vector2i = piece[2]
		if rows[cell.y][cell.x] != ".":
			bad.append(cell)
		elif piece[0] == 0 and (absi(cell.x - 20) <= 1 and cell.y == 19 or cell.x >= 38):
			bad.append(cell)
	check(bad.is_empty(), "decor sits in open cells, clear of hazards and doors (bad %s)" % [bad])
	var again := Room.from_text(text, "t/decor")
	arena.add_child(again)
	check(str(again.get_node("Decor").pieces) == str(decor.pieces), "the same room always gets the same decor")
	var glowing := false
	for c in decor.get_children():
		glowing = glowing or c is Node2D
		check(not c is CollisionObject2D, "decor has no collision")
	check(glowing == not decor.glows.is_empty(), "light-giving fungus gets a glow layer")
	var gym := Room.from_text(room_text(["name: G", "zone: gym"], rows), "g/decor")
	arena.add_child(gym)
	check((gym.get_node("Decor") as Decor).pieces.is_empty(), "zones without a decor atlas stay bare")


func test_motes_wrap_around_the_view() -> void:
	var motes := Motes.new()
	arena.add_child(motes)
	motes.set_zone("trunk")
	await frames(120)
	var inside := true
	for m: Array in motes._motes:
		var p: Vector2 = m[0]
		inside = inside and p.x >= 0.0 and p.x < Motes.VIEW.x and p.y >= 0.0 and p.y < Motes.VIEW.y
	check(motes._motes.size() == Motes.ZONES.trunk[0] and inside, "trunk spores stay within the screen as they drift")
	motes.set_zone("gym")
	check(motes._motes.is_empty(), "no motes in the gym")


func test_doors_within_a_zone_scroll_and_others_fade() -> void:
	var w := make_world(_rooms(), "test/a")
	var a: Dictionary = w.room.doors
	var side := {}
	for n: int in a:
		if a[n].edge in ["left", "right"]:
			side = a[n]
			break
	check(not side.is_empty() and w.transition_kind(side) == "scroll", "a side door to a room of the same zone scrolls")
	var inner := side.duplicate()
	inner.edge = "inner"
	check(w.transition_kind(inner) == "fade", "an inner doorway fades")
	var away := side.duplicate()
	away.target = "elsewhere/room"
	w.catalog["elsewhere/room"] = {"zone": "elsewhere"}
	check(w.transition_kind(away) == "fade", "a door into another zone fades")


func test_sap_falls_are_told_from_pools() -> void:
	# A stream 2 wide pouring from row 0 into a pool walled in at x 0 and x 5.
	var sap := {}
	for y in 4:
		sap[Vector2i(2, y)] = true
		sap[Vector2i(3, y)] = true
	for x in range(1, 5):
		sap[Vector2i(x, 4)] = true
		sap[Vector2i(x, 5)] = true
	var walls := {Vector2i(0, 4): true, Vector2i(5, 4): true, Vector2i(0, 5): true, Vector2i(5, 5): true}
	var falls := SapPool.find_falls(sap, func(c: Vector2i) -> bool: return walls.has(c))
	check(falls.has(Vector2i(2, 0)) and falls.has(Vector2i(3, 3)), "the stream pours")
	check(not falls.has(Vector2i(1, 4)) and not falls.has(Vector2i(3, 4)), "the walled pool is still a pool")
	check(not falls.has(Vector2i(2, 5)), "the pool's bottom row is not a falls")


func test_taproot_is_bitten_until_the_spring_returns() -> void:
	GameState.new_game()
	var root := Taproot.new()
	arena.add_child(root)
	var bite: Array = Taproot.BITES[0]
	var h: float = bite[0]
	var bitten := root.edges(h)
	var whole := root.edges(h + float(bite[2]) + 6.0)
	check(bitten.y < whole.y - 10.0, "a bite is taken out of the root (%.0f vs %.0f)" % [bitten.y, whole.y])
	GameState.set_flag("spring:trunk")
	check(root.edges(h).y > bitten.y + 10.0, "the spring heals the bite")


## Every sound and track the code asks for by name exists: a typo would play
## silence, not fail. Scans the scripts for Sfx.play("...") and Music.play("..."),
## and the boss arenas' music.
func test_every_sound_the_code_plays_exists() -> void:
	var sfx := RegEx.create_from_string("Sfx\\.play\\(\"([a-z0-9_]+)\"")
	var music := RegEx.create_from_string("Music\\.play\\(\"([a-z0-9_]+)\"")
	var missing: Array[String] = []
	var found := 0
	var dirs: Array[String] = ["res://scripts"]
	while not dirs.is_empty():
		var d: String = dirs.pop_back()
		var da := DirAccess.open(d)
		for sub in da.get_directories():
			dirs.append(d + "/" + sub)
		for f in da.get_files():
			if not f.ends_with(".gd"):
				continue
			var text := FileAccess.get_file_as_string(d + "/" + f)
			for m in sfx.search_all(text):
				found += 1
				# A name ending in "_" is a prefix completed at runtime ("step_" + surface).
				if not m.get_string(1).ends_with("_") and not ResourceLoader.exists("res://assets/sfx/%s.wav" % m.get_string(1)):
					missing.append("%s: sfx %s" % [f, m.get_string(1)])
			for m in music.search_all(text):
				found += 1
				if Music.stream_for(m.get_string(1)) == null:
					missing.append("%s: music %s" % [f, m.get_string(1)])
	for id: String in BossArena.BOSSES:
		var track: String = BossArena.BOSSES[id].get("music", "boss")
		if Music.stream_for(track) == null:
			missing.append("boss %s: music %s" % [id, track])
	check(found > 50, "the scan finds the game's sounds (%d)" % found)
	check(missing.is_empty(), "every sound and track exists: %s" % [missing])
