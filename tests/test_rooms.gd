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


## Bible 5.4 (pass 250): the purse you drop on dying is in the save, and comes
## back with it. The save had kept it as "value" while loading asked for "gold",
## so every purse was thrown away the moment a save was loaded.
func test_a_dropped_purse_survives_a_save_and_load() -> void:
	var w := make_world(_rooms(), "test/a", cell_feet(10, 19))
	GameState.slot = SAVE_SLOT
	await frames(5)
	var p := w.player
	p.input.up_pressed = true
	await frames(2)
	p.gold = 100
	p.teleport(cell_feet(30, 19))
	await frames(3)
	p.take_damage(9999)
	check(p.dead and is_instance_valid(p.purse) and p.purse.value == 60, "dying drops 60 of 100 gold in a purse")
	await frames(int(p.combat.respawn_delay * 60.0) + 30)
	check(GameState.data.purse.get("value") == 60, "the purse is in the game state (%s)" % [GameState.data.purse])
	GameState.save_game()
	GameState.new_game()
	check(GameState.load_game(SAVE_SLOT), "the save loads")
	check(GameState.data.purse.get("room") == "test/a" and int(GameState.data.purse.get("value", 0)) == 60, "and the purse is still in it (%s)" % [GameState.data.purse])
	# Legacy and broken purses: one named "gold" is read; an empty one is dropped.
	var old := GameState.fresh()
	old.purse = {"room": "test/a", "x": 1, "y": 2, "gold": 9}
	check(int(GameState.sanitize(old).get("purse", {}).get("value", 0)) == 9, "a purse saved as gold is read")
	old.purse = {"room": "test/a", "x": 1, "y": 2, "value": 0}
	check(GameState.sanitize(old).get("purse", {"x": 1}).is_empty(), "an empty purse is dropped")
	w._enter("test/a")
	await frames(3)
	var bags := w.room.get_children().filter(func(c: Node) -> bool: return c is GoldPurse)
	check(bags.size() == 1 and bags[0].value == 60, "the loaded world lays it where you fell (%d)" % bags.size())
	GameState.delete_save(SAVE_SLOT)


func test_act_one_state_survives_a_save_round_trip() -> void:
	GameState.slot = SAVE_SLOT
	GameState.set_flag("spring:trunk")
	GameState.set_flag("boss:zoradohna")
	GameState.meet_guru("trunk/apolune", Vector2(200, 320))
	GameState.meet_guru("tower/forepaw", Vector2(168, 320))
	GameState.data.tempers["short_sword"] = 2
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
	check(GameState.temper_level("short_sword") == 2, "the blade's temper survives")
	check(int(GameState.data.named_rank) == 3 and int(GameState.data.mantra_shards) == 2, "title and shards survive")
	check(GameState.has_ability("mattock"), "the Mattock survives")
	GameState.delete_save(SAVE_SLOT)


## Pass 120: what passes 113 to 119 added comes back after a save: the card
## keys and the Joker, the Battle Helmet and its mask, a trial's best, the
## card vaults opened. A damaged key entry is dropped, never a crash.
func test_late_additions_survive_a_save_round_trip() -> void:
	var w := make_world({}, "zenis/threshold")
	var p := w.player
	await frames(2)
	GameState.slot = SAVE_SLOT
	GameState.add_key("queen", 2)
	GameState.add_key("joker")
	GameState.data.keys["lantern"] = true
	GameState.data.equipment.helmet = "battle_helmet"
	GameState.refresh_stats(p)
	var top := p.max_hp
	GameState.data.trials["walls"] = 31.5
	GameState.collect("mist/feather_hollow:4,19")
	check(GameState.save_game(), "the save writes")
	GameState.new_game()
	check(GameState.load_game(SAVE_SLOT), "and loads")
	check(GameState.key_count("queen") == 2 and GameState.key_count("joker") == 1, "the card keys survive")
	check(GameState.data.keys.get("lantern") == true, "and the Lantern Key, kept for good")
	GameState.apply(p)
	check(GameState.data.equipment.helmet == "battle_helmet" and p.max_hp == top, "the Battle Helmet and its mask survive, health full (%d)" % p.max_hp)
	check(p.hp == p.max_hp, "loading fills the new top, not the old one (%d/%d)" % [p.hp, p.max_hp])
	check(is_equal_approx(float(GameState.data.trials["walls"]), 31.5), "a trial's best survives")
	check(GameState.is_collected("mist/feather_hollow:4,19"), "an opened card door stays open")
	var bad := GameState.sanitize({"save_room": "eolis/plaza", "keys": {"jack": "two", "queen": -3, "king": [1], "ace": 1, "sky": true}})
	check(bad.keys == {"ace": 1, "sky": true}, "a damaged key entry is dropped (%s)" % [bad.keys])
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


## Daybreak: rest at the Broken Shrine with the Life Fruit taken and the Sky
## Steps chest opened; the save brings it all back, and the rooms rebuild that way.
func test_daybreak_state_survives_a_save_round_trip() -> void:
	var w := make_world({}, "daybreak/sky_steps")
	GameState.slot = SAVE_SLOT
	w.player.abilities["stride"] = true
	await frames(2)
	var chest: Chest = null
	for c in w.room.get_children():
		if c is Chest:
			chest = c
	check(chest != null, "the Sky Steps chest is there")
	chest.interact(w.player)
	w._enter("daybreak/broken_shrine")
	await frames(2)
	var fruit: ItemPickup = null
	var shrine: SaveShrine = null
	var beetles := 0
	for c in w.room.get_children():
		if c is ItemPickup and (c as ItemPickup).kind == "life_fruit":
			fruit = c
		elif c is SaveShrine:
			shrine = c
		elif c is ThunderBeetle:
			beetles += 1
	check(fruit != null and shrine != null and beetles == 1, "the shrine, its Life Fruit and a beetle are there")
	var hp0 := int(GameState.data.max_hp)
	fruit.grant(w.player)
	w.save_at(shrine.global_position)
	check(GameState.has_save(SAVE_SLOT), "resting at the shrine writes the save")
	GameState.new_game()
	check(int(GameState.data.max_hp) == hp0, "a new game starts without the fruit")
	check(GameState.load_game(SAVE_SLOT), "and the save loads")
	check(GameState.data.save_room == "daybreak/broken_shrine", "the save room is the Broken Shrine (%s)" % GameState.data.save_room)
	check(GameState.has_ability("stride"), "the Stride survives")
	check(int(GameState.data.max_hp) > hp0, "the Life Fruit's health survives")
	w._enter("daybreak/broken_shrine")
	await frames(2)
	var left := false
	for c in w.room.get_children():
		left = left or (c is ItemPickup and (c as ItemPickup).kind == "life_fruit")
	check(not left, "the fruit doesn't grow back")
	w._enter("daybreak/sky_steps")
	await frames(2)
	var open := false
	for c in w.room.get_children():
		if c is Chest:
			open = not (c as Chest).is_in_group("interactable")
	check(open, "and the chest stays open")
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


## Black Onyx (bible A7): illusory walls shimmer at their seams and hidden
## planks (legend `i`) show faintly, but only while you carry it.
func test_black_onyx_shows_seams_and_hidden_planks() -> void:
	var extra := {}
	for y in range(14, 20):
		extra[Vector2i(14, y)] = "%"
	for x in range(24, 30):
		extra[Vector2i(x, 15)] = "i"
	var w := make_world(_rooms(extra), "test/a", cell_feet(12, 19))
	w.player.abilities["onyx"] = false
	await frames(30)
	check(w.room.sheen != null and w.room.phantoms != null, "the room has a sheen and a hidden plank layer")
	check(w.room.sheen.strength == 0.0 and w.room.phantoms.modulate.a == 0.0, "without the Onyx nothing shows")
	w.player.abilities["onyx"] = true
	await frames(40)
	check(w.room.sheen.strength == 1.0, "with it the seams shimmer (strength %.2f)" % w.room.sheen.strength)
	check(w.room.phantoms.modulate.a > 0.2 and w.room.phantoms.modulate.a < 0.6, "and the hidden planks show faintly (alpha %.2f)" % w.room.phantoms.modulate.a)


func test_hidden_planks_hold_you_up_unseen() -> void:
	var extra := {}
	for x in range(8, 14):
		extra[Vector2i(x, 14)] = "i"
	var w := make_world(_rooms(extra), "test/a", cell_feet(11, 12))
	w.player.abilities["onyx"] = false
	await frames(40)
	check(w.player.is_on_floor() and absf(w.player.global_position.y - 14 * 16) < 2.0,
		"stood on an unseen plank (y %.0f)" % w.player.global_position.y)
	check(w.room.is_one_way_at(Vector2(11 * 16 + 8, 14 * 16 + 4)), "it is a one-way plank")


func test_the_onyx_waits_in_the_crypt_below_the_flooded_hall() -> void:
	GameState.new_game()
	var w := make_world({}, "dartmoor/onyx_crypt")
	w.player.abilities["onyx"] = false
	await frames(2)
	var onyx: ItemPickup = null
	for c in w.room.get_children():
		if c is ItemPickup and (c as ItemPickup).kind == "onyx":
			onyx = c
	check(onyx != null, "the Black Onyx lies on the crypt's dais")
	if onyx == null:
		return
	onyx.grant(w.player)
	check(w.player.abilities.get("onyx", false) and GameState.has_ability("onyx"), "taking it gives the Onyx for good")
	var way_on: Rect2 = w.room.doors[2].rect
	check(w.room.doors[2].target == "dartmoor/drowned_nave" and w.room.is_secret_at(way_on.get_center()),
		"the way on to the lower halls is behind an illusory wall")
	var hall := Room.from_file("res://levels/dartmoor/flooded_hall.room")
	check(hall.doors[2].target == "dartmoor/sunken_stair", "the flooded hall's west door leads down the stair")
	hall.free()


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


## Pass 251: a sign says what the world has become. Lines on one cell are one
## tablet, and it reads the first whose flags hold at the moment it is read.
func test_a_tablet_reads_what_the_world_has_become() -> void:
	var rooms := _rooms()
	rooms["test/a"] = rooms["test/a"].replace("---", "sign: 8, 19, [spring:trunk boss:rokusutahn] Both|Done\nsign: 8, 19, [spring:trunk] After\nsign: 8, 19, Before\n---")
	var w := make_world(rooms, "test/a", cell_feet(8, 19))
	await frames(3)
	var tablets: Array[LoreTablet] = []
	for n in w.room.get_children():
		if n is LoreTablet:
			tablets.append(n)
	check(tablets.size() == 1, "three lines on one cell make one tablet (%d)" % tablets.size())
	if tablets.is_empty():
		return
	var got := []
	var listener := func(_who: String, pages: Array) -> void: got.append(pages)
	GameState.dialog_requested.connect(listener)
	tablets[0].interact(w.player)
	GameState.set_flag("spring:trunk")
	tablets[0].interact(w.player)
	GameState.set_flag("boss:rokusutahn")
	tablets[0].interact(w.player)
	GameState.dialog_requested.disconnect(listener)
	check(got == [["Before"], ["After"], ["Both", "Done"]], "it reads Before, then After, then Both as the flags are set, without leaving the room (%s)" % [got])


## Pass 251: every sign that foretold a change the world makes has a line for
## after it, and every bracketed flag is one the game can set.
func test_every_world_change_rewrites_its_sign() -> void:
	var catalog := {}
	for zone in DirAccess.get_directories_at("res://levels"):
		for f in DirAccess.get_files_at("res://levels/" + zone):
			if f.ends_with(".room"):
				catalog[zone + "/" + f.get_basename()] = Room.parse(FileAccess.get_file_as_string("res://levels/%s/%s" % [zone, f]))
	var bosses := {}
	for id: String in catalog:
		var b := String(catalog[id].header.get("boss", ""))
		if b != "":
			bosses[b] = id
	var bad := []
	for id: String in catalog:
		var cells := {}
		for spec: String in catalog[id].lists.get("sign", []):
			var parts := spec.split(",", true, 2)
			var cell := "%s,%s" % [parts[0].strip_edges(), parts[1].strip_edges()]
			var line := parts[2].strip_edges()
			var conds := ""
			if line.begins_with("["):
				conds = line.substr(1, line.find("]") - 1)
			cells[cell] = cells.get(cell, []) + [conds]
			for c: String in conds.split(" ", false):
				c = c.trim_prefix("!")
				var known := false
				if c.begins_with("boss:"):
					known = bosses.has(c.trim_prefix("boss:"))
				elif c.begins_with("spring:"):
					known = c.trim_prefix("spring:") in ["trunk", "mist", "sky"]
				elif c.begins_with("conduits:"):
					var r = catalog.get(c.trim_prefix("conduits:"))
					known = r != null and "\n".join(r.grid).contains("c")
				if not known:
					bad.append("%s %s: no such flag %s" % [id, cell, c])
		for cell: String in cells:
			if cells[cell].size() > 1 and cells[cell][-1] != "":
				bad.append("%s %s: no plain line to fall back on" % [id, cell])
	check(bad.is_empty(), "every bracketed sign line names a real flag and falls back: %s" % [bad])
	# The signs that said "when the spring runs" or "something waits" each learn otherwise.
	var told := [["eolis/plaza", "40,19", "spring:trunk"], ["eolis/plaza", "40,19", "spring:sky"],
		["trunk/amber_falls", "18,36", "spring:trunk"], ["trunk/spring_of_trunk", "34,16", "spring:trunk"],
		["trunk/boss_gate", "16,19", "boss:rokusutahn"], ["mist/scorched_hall", "5,19", "spring:mist"],
		["mist/victim_causeway", "6,19", "spring:mist"], ["mist/spring_of_mist", "3,19", "spring:mist"],
		["tower/forepaw_gate", "28,19", "boss:zoradohna"], ["daybreak/spire_foot", "30,19", "conduits:daybreak/spire_foot"],
		["daybreak/spire_stair", "3,41", "boss:borabohra"], ["daybreak/sky_spring", "8,19", "spring:sky"],
		["dartmoor/kings_kennels", "76,16", "boss:king_grieve"], ["sunken/source_hall", "26,14", "boss:drowned_warden"],
		["branches/windloft", "22,19", "boss:pakukame"]]
	var missing := []
	for t: Array in told:
		var found := false
		for spec: String in catalog.get(t[0], {"lists": {}}).lists.get("sign", []):
			var parts := spec.split(",", true, 2)
			found = found or ("%s,%s" % [parts[0].strip_edges(), parts[1].strip_edges()] == t[1] and parts[2].strip_edges().begins_with("[") and parts[2].substr(0, parts[2].find("]")).contains(t[2]))
		if not found:
			missing.append("%s %s" % [t[0], t[2]])
	check(missing.is_empty(), "each foretold change has its sign line: missing %s" % [missing])


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
	check_near(p.velocity.x, p.tuning.run_speed * p.tuning.sap_speed, 1.0, "run speed halved in sap")
	p.input.move_x = 0
	p.input.jump_pressed = true
	p.input.jump_held = true
	await frames(1)
	# One frame of gravity has already been applied.
	check_near(-p.velocity.y, p.tuning.jump_velocity * p.tuning.sap_jump - p.tuning.gravity / 60.0, 2.0, "weaker jump out of sap")



## Bible 6.12 (pass 248): sap holds only the run and the ground jump. A dash goes
## out of it at full speed, and the run comes back the moment you step clear.
func test_sap_never_holds_a_dash_and_lets_go_at_its_edge() -> void:
	var extra := {}
	for x in range(10, 30):
		extra[Vector2i(x, 20)] = "~"
		extra[Vector2i(x, 21)] = "~"
	var w := make_world(_rooms(extra), "test/a", cell_feet(14, 21))
	var p := w.player
	p.abilities["stride"] = true
	await frames(5)
	p.input.move_x = 1
	await frames(20)
	check(p.in_sap and is_equal_approx(p.velocity.x, p.tuning.run_speed * p.tuning.sap_speed), "wading at half a run (%.0f)" % p.velocity.x)
	p.input.dash_pressed = true
	await frames(2)
	check(p.is_dashing and is_equal_approx(p.velocity.x, p.tuning.dash_speed), "a dash in the sap goes at full speed (%.0f)" % p.velocity.x)
	var left := false
	for i in 240:
		await frames(1)
		if not p.in_sap:
			left = true
			break
	check(left, "and wading on, you reach the pool's edge")
	await frames(12)
	check(not p.in_sap and is_equal_approx(p.velocity.x, p.tuning.run_speed), "where the run comes back at once (%.0f)" % p.velocity.x)


## Bible 4.2 (pass 249): in the original a keeper stood before each spring. Each
## of the remake's three has one: there while it is dry (at the Mist's and the
## Sky's once their guardian is beaten, never mid-fight), glad once it flows.
func test_every_spring_has_its_keeper() -> void:
	var springs := {"trunk/spring_of_trunk": ["trunk", "", "trunk_keeper"],
		"mist/spring_of_mist": ["mist", "boss:zorugeriru", "mist_keeper"],
		"daybreak/sky_spring": ["sky", "boss:borabohra", "sky_keeper"]}
	var people := func(w: World) -> Array:
		return w.room.get_children().filter(func(c: Node) -> bool: return c is Npc).map(func(n: Npc) -> String: return n.npc_id)
	for room: String in springs:
		var spring: String = springs[room][0]
		var guardian: String = springs[room][1]
		var keeper: String = springs[room][2]
		check(GameData.npc(keeper).has("name") and GameData.npc(keeper + "_glad").get("name") == GameData.npc(keeper).name, "%s and their glad self are one person" % keeper)
		check(Sheet.exists("npc_" + keeper) and Sheet.exists("npc_" + keeper + "_glad"), "with sheets")
		check(GameData.npc(keeper + "_glad").has("lines_cleared"), "and a word once the Tree blooms")
		var w := make_world({}, room)
		await frames(3)
		if guardian != "":
			check(not people.call(w).has(keeper), "no keeper at the %s spring while its guardian holds it (%s)" % [spring, people.call(w)])
			GameState.set_flag(guardian)
			w._enter(room)
			await frames(3)
		check(people.call(w) == [keeper], "the %s spring's keeper waits by it, dry (%s)" % [spring, people.call(w)])
		GameState.set_flag("spring:" + spring)
		w._enter(room)
		await frames(3)
		check(people.call(w) == [keeper + "_glad"], "and is glad once it flows (%s)" % [people.call(w)])
		w.queue_free()
		await frames(2)

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
	for s: String in ["stone", "moss", "mud", "plank", "iron", "sap", "wade"]:
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
	# Pass 181: the Mist's marsh squelches as mud, and its dwarf-built halls stay stone.
	var marsh := Room.from_text(room_text(["name: T", "zone: mist"], grid_rows(10, 23)), "t/mud")
	arena.add_child(marsh)
	check(marsh.surface_at(below.call(5, 19)) == "mud", "the Mist's marsh is mud (%s)" % marsh.surface_at(below.call(5, 19)))
	marsh.queue_free()
	for id: String in ["mist/scorched_hall", "mist/dry_cistern", "mist/sunken_chapel", "mist/spring_of_mist"]:
		var r := Room.from_file(World.room_path(id))
		check(String(r.header.get("surface", "")) == "stone", "%s, built by dwarves, rings as stone" % id)
		r.free()
	var mire := Room.from_file(World.room_path("mist/hag_mire"))
	check(not mire.header.has("surface"), "the Matriarch's mire is marsh mud underfoot")
	mire.free()


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
	var sfx := RegEx.create_from_string("(?:Sfx\\.play|_sound)\\(\"([a-z0-9_]+)\"")
	# A choice in the first argument ("a" if x else "b") names both.
	var choice := RegEx.create_from_string("Sfx\\.play\\(\"[a-z0-9_]+\" if [^,\\n]* else \"([a-z0-9_]+)\"")
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
			for m in choice.search_all(text):
				found += 1
				if not ResourceLoader.exists("res://assets/sfx/%s.wav" % m.get_string(1)):
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



## Pass 254: the pool of voices took turns, so in a busy fight a dozen steps
## and cuts would cut a long sound short. Now a new sound takes a free voice,
## or the one nearest its end, and a burst of one sound in a frame takes one.
func test_a_long_sound_keeps_its_voice_through_a_busy_moment() -> void:
	await frames(1)
	Sfx.play("boss_won", 0.0)
	var held := -1
	for i in Sfx.POOL_SIZE:
		if Sfx.voice_sound(i) == "boss_won":
			held = i
	check(held >= 0, "the victory takes a voice")
	var shorts := ["hit", "step", "slash"]
	for n in Sfx.POOL_SIZE * 2:
		Sfx.play(shorts[n % 3])
		await frames(1)
	check(Sfx.voice_sound(held) == "boss_won", "two pools' worth of short sounds later, the victory still rings (%s)" % Sfx.voice_sound(held))
	await frames(1)
	Sfx.recent.clear()
	for n in 8:
		Sfx.play("coin")
	var voices := 0
	for i in Sfx.POOL_SIZE:
		if Sfx.voice_sound(i) == "coin":
			voices += 1
	check(voices == 1, "eight coins in one frame take one voice (%d)" % voices)
	check(Sfx.recent.count("coin") == 8, "though each is still heard asked for")
	await frames(1)
	Sfx.play("coin")
	voices = 0
	for i in Sfx.POOL_SIZE:
		if Sfx.voice_sound(i) == "coin":
			voices += 1
	check(voices == 2, "and the next frame's coin sounds again (%d)" % voices)


## Pass 270: the hero's hurt sat 8.9 dB over the median sound effect, a tenth
## of a dB inside the mix check's spread, so any new quiet sound tipped the
## check red. The loudest cues are now saved under the line (levels.py keeps
## HEADROOM inside the spread) and Sfx.LIFT plays them back as loud as before.
func test_the_loudest_cues_are_lifted_in_game_not_in_the_file() -> void:
	await frames(1)
	check(Sfx.LIFT.has("hurt") and Sfx.LIFT.has("hit"), "the hurt and the cut landing are lifted (%s)" % [Sfx.LIFT])
	for sound: String in Sfx.LIFT:
		var lift := float(Sfx.LIFT[sound])
		check(lift > 0.0 and lift <= 6.0, "%s is lifted a few dB, not a remix (%.1f)" % [sound, lift])
		check(ResourceLoader.exists("res://assets/sfx/%s.wav" % sound), "a lifted sound has a file (%s)" % sound)
	# Another test may have muted the effects (AudioStreamPlayer floors at -80 dB).
	var base := Sfx.volume_db
	Sfx.volume_db = -6.0
	for sound: String in ["hurt", "hit", "slash"]:
		# The voice this play takes (one ringing from an earlier test can end later
		# than it, so look for the one whose end was just set).
		var before := Sfx._ends.duplicate()
		Sfx._started_on.erase(sound)
		Sfx.play(sound, 0.0, -1.0)
		var voice := -1
		for i in Sfx.POOL_SIZE:
			if Sfx._ends[i] != before[i] and Sfx.voice_sound(i) == sound:
				voice = i
		check(voice >= 0, "%s takes a voice" % sound)
		if voice >= 0:
			var want := Sfx.volume_db - 1.0 + float(Sfx.LIFT.get(sound, 0.0))
			check(is_equal_approx(Sfx._players[voice].volume_db, want),
				"%s plays at %.1f dB, its lift on top of the caller's offset (%.1f)" % [sound, want, Sfx._players[voice].volume_db])
		await frames(1)
	Sfx.volume_db = base
	# The hurt is still the hero's loudest cue in game: its file is as loud as
	# the cut landing's (levels.py), and it is lifted the more.
	check(float(Sfx.LIFT.hurt) > float(Sfx.LIFT.hit), "the hurt is lifted more than the cut landing")
	# The sound generator saves them that much under their old level.
	var gen := FileAccess.get_file_as_string("res://tools/audio/sfxgen.py")
	for pair: Array in [["hit", 0.8, 0.62], ["hurt", 0.6, 0.42]]:
		var drop := -20.0 * log(float(pair[2]) / float(pair[1])) / log(10.0)
		check(absf(drop - float(Sfx.LIFT[pair[0]])) < 0.15, "%s's lift (%.1f) gives back its file's cut (%.2f)" % [pair[0], Sfx.LIFT[pair[0]], drop])
		check(gen.contains('save("%s",' % pair[0]) and gen.contains("%s)" % pair[2]), "sfxgen saves %s at gain %s" % [pair[0], pair[2]])


## Sounds named at runtime (pass 207): the scan above reads only literal names,
## so a helper that picks a sound, or a name built from parts, could play
## silence unnoticed. `Sfx.missing` keeps every name asked for that has no
## file, and the runner fails any test that adds to it. Here: it notices one,
## and every choice the sound-picking helpers can make exists.
func test_a_sound_with_no_file_is_caught_at_runtime() -> void:
	Sfx.missing.clear()
	Sfx.play("no_such_sound")
	check(Sfx.missing == ["no_such_sound"], "a missing sound is kept (%s)" % [Sfx.missing])
	Sfx.missing.clear()
	var names: Array[String] = []
	for v: int in [1] + Array(Coin.DENOMINATIONS):
		names.append(Coin.sound(v))
	for id: String in GameData.items_of_kind("blade") + GameData.items_of_kind("armor") + GameData.items_of_kind("shield") \
			+ GameData.items_of_kind("helmet") + GameData.items_of_kind("dye"):
		names.append(Menus.equipment_sound(id))
	# Footsteps: each zone's ground, and every room's own `surface:` line.
	var surfaces: Array = Room.ZONE_SURFACES.values() + ["sap", "plank"]  # surface_at's own two
	var dirs: Array[String] = ["res://levels"]
	while not dirs.is_empty():
		var d: String = dirs.pop_back()
		for sub in DirAccess.get_directories_at(d):
			dirs.append(d + "/" + sub)
		for f in DirAccess.get_files_at(d):
			if f.ends_with(".room"):
				for line in FileAccess.get_file_as_string(d + "/" + f).split("\n"):
					if line.begins_with("surface:"):
						surfaces.append(line.trim_prefix("surface:").strip_edges())
	for surface: String in surfaces:
		if not names.has("step_" + surface):
			names.append("step_" + surface)
	var lost := names.filter(func(n: String) -> bool: return not ResourceLoader.exists("res://assets/sfx/%s.wav" % n))
	check(names.size() > 10 and lost.is_empty(), "every sound the helpers can pick exists (%d names; missing %s)" % [names.size(), lost])

func test_the_hour_glass_waits_by_the_stopped_water_clock() -> void:
	GameState.new_game()
	var w := make_world({}, "dartmoor/drowned_nave")
	await frames(2)
	var glass: ItemPickup = null
	for c in w.room.get_children():
		if c is ItemPickup and (c as ItemPickup).kind == "hourglass":
			glass = c
	check(glass != null, "the Hour Glass stands by the water-clock in the Drowned Nave")
	check(w.room.doors[2].target == "dartmoor/waterfall_stair", "and the nave's west door leads to the Waterfall Stair")
	w._enter("dartmoor/waterfall_stair")
	await frames(2)
	check(w.room.get_children().filter(func(c: Node) -> bool: return c is Waterfall).size() == 2, "where two falls bar the way up")


func test_the_waterfall_stair_gallery_opens_on_the_drowned_market() -> void:
	GameState.new_game()
	var w := make_world({}, "dartmoor/waterfall_stair")
	await frames(2)
	check(w.room.doors[2].target == "dartmoor/drowned_market", "the stair's top gallery leads on to the Drowned Market")
	w._enter("dartmoor/drowned_market")
	await frames(2)
	var falls: Array = w.room.get_children().filter(func(c: Node) -> bool: return c is Waterfall)
	check(falls.size() == 1, "where one fall pours down into a spiked pit")
	var slugs := w.room.get_children().filter(func(c: Node) -> bool: return c is MeteorSlug).size()
	check(slugs == 2, "and Meteor Slugs creep along the market floor (%d)" % slugs)


func test_the_kings_stair_runs_down_from_the_market_to_the_kennels() -> void:
	GameState.new_game()
	var w := make_world({}, "dartmoor/drowned_market")
	await frames(2)
	check(w.room.doors[2].edge == "inner" and w.room.doors[2].target == "dartmoor/kings_stair", "the market's cracked stair is a doorway down")
	w._enter("dartmoor/kings_stair")
	await frames(2)
	check(w.room.get_children().filter(func(c: Node) -> bool: return c is Waterfall).size() == 1, "where the king's fall pours down the stair-well")
	check(w.room.doors[2].target == "dartmoor/kings_kennels", "and the stair's foot opens on the kennels")
	w._enter("dartmoor/kings_kennels")
	await frames(2)
	var hounds := w.room.get_children().filter(func(c: Node) -> bool: return c is ClockworkHound).size()
	check(hounds == 3, "where the king's hounds still run (%d)" % hounds)


func test_the_way_past_the_throne_opens_once_the_king_is_at_rest() -> void:
	GameState.new_game()
	var w := make_world({}, "dartmoor/throne_hall")
	await frames(3)
	check(w.room.doors[2].target == "dartmoor/meteor_rise", "a door behind the throne leads on to the Meteor Rise")
	var arena: BossArena = null
	for c in w.room.get_children():
		if c is BossArena:
			arena = c
	check(arena != null and arena.seals.has(2), "and it is barred while the king still sits his throne")
	var npcs := func(world: World) -> Array: return world.room.get_children().filter(func(c: Node) -> bool: return c is Npc).map(func(n: Npc) -> String: return n.npc_id)
	check(not npcs.call(w).has("dartmoor_steward"), "no steward wakes while he lives")
	GameState.set_flag("boss:king_grieve")
	w._enter("dartmoor/drowned_market")
	await frames(2)
	check(npcs.call(w).has("dartmoor_mason"), "once he is at rest the drowned dwarves wake: a mason in the market")
	w.queue_free()
	await frames(2)
	w = make_world({}, "dartmoor/kings_kennels")
	GameState.set_flag("boss:king_grieve")
	w._enter("dartmoor/throne_hall")
	w.player.teleport(cell_feet(30, 19))
	await frames(3)
	check(npcs.call(w).has("dartmoor_steward"), "and his steward by the empty throne")
	check(w.room.get_children().all(func(c: Node) -> bool: return not c is ArenaSeal), "and nothing bars the way on")


func test_the_gate_of_zenis_waits_for_four_rings() -> void:
	GameState.new_game()
	var w := make_world({}, "dartmoor/meteor_rise")
	await frames(2)
	check(w.room.doors[2].target == "dartmoor/zenis_gate", "the Meteor Rise climbs to the gate of Zenis")
	w._enter("dartmoor/zenis_gate")
	await frames(2)
	var gates: Array = w.room.get_children().filter(func(c: Node) -> bool: return c is ZenisGate)
	check(gates.size() == 1, "where the gate stands")
	var gate: ZenisGate = gates[0]
	GameState.data.rings = ["elf", "demon"]
	check(gate.lit() == ["elf", "demon"], "its sockets glow for the rings you hold (%s)" % [gate.lit()])
	check(gate.message().contains("2 of them"), "and it says how many")
	GameState.data.rings = ["elf", "ruby", "dworf", "demon"]
	check(gate.lit().size() == 4 and gate.message().contains("does not open"), "with all four it still waits on the shadow before it")
	GameState.set_flag("boss:shadow_eura")
	check(gate.message().contains("nothing watches"), "and once the shadow is broken it says so")


func test_the_gate_of_zenis_opens_onto_the_meteor() -> void:
	GameState.new_game()
	var w := make_world({}, "dartmoor/meteor_rise")
	await frames(2)
	# The shadow is beaten (else walking in starts the fight).
	GameState.set_flag("boss:shadow_eura")
	w._enter("dartmoor/zenis_gate")
	await frames(2)
	var gate: ZenisGate = w.room.get_children().filter(func(c: Node) -> bool: return c is ZenisGate)[0]
	check(w.room.doors.has(2) and w.room.doors[2].target == "zenis/threshold", "the way into Zenis lies behind the gate")
	GameState.data.rings = ["elf", "ruby", "dworf"]
	check(not gate.is_open(), "three rings do not open it")
	# Shut, it bars the way: walk at it and you stop at its face.
	var p := w.player
	p.teleport(Vector2(gate.global_position.x - 80.0, gate.global_position.y))
	p.input.move_x = 1
	await frames(90)
	check(w.room.id == "dartmoor/zenis_gate" and p.global_position.x < gate.global_position.x - 20.0, "shut, it bars the way (%s)" % p.global_position)
	p.input.move_x = 0
	GameState.data.rings = ["elf", "ruby", "dworf", "demon"]
	check(gate.is_open(), "four rings and the shadow beaten open it")
	await frames(90)
	check(gate.swing >= 1.0, "its leaves swing wide")
	p.input.move_x = 1
	var through := false
	for i in 180:
		await frames(1)
		if w.room.id == "zenis/threshold":
			through = true
			break
	p.input.move_x = 0
	check(through, "and you walk through into Zenis")
	check(w.room.zone == "zenis" and Music.track == "zenis" and Music.ambience_track == "amb_zenis", "with its own theme and ambience (%s, %s)" % [Music.track, Music.ambience_track])
	check(World.ZONES.has("zenis") and w.motes.zone == "zenis", "the map knows the zone, and spores drift in the air")
	check(w.room.doors[2].target == "zenis/heart_stair", "the Threshold leads on to the Heart Stair")


## Bible 8.9: the Heart Stair leads up into the Drift Well, where wrong gravity
## carries a plain jump up ledges no jump could reach.
func test_the_drift_well_lifts_you_up_its_ledges() -> void:
	GameState.new_game()
	var w := make_world({}, "zenis/heart_stair")
	await frames(2)
	check(w.room.doors.has(2) and w.room.doors[2].target == "zenis/drift_well", "the Heart Stair leads on to the Drift Well")
	w._enter("zenis/drift_well")
	await frames(2)
	check(w.room.get_children().filter(func(c: Node) -> bool: return c is GravityDrift).size() == 3, "three pockets of wrong gravity")
	for e in w.room.get_children():
		if e is Enemy:
			e.queue_free()
	var p := w.player
	p.max_hp = 9999
	p.hp = 9999
	p.teleport(cell_feet(18, 42))
	await frames(10)
	# A full jump straight up the first pocket, then drift right onto the ledge nine tiles up.
	p.input.jump_pressed = true
	p.input.jump_held = true
	var landed := false
	for i in 240:
		await frames(1)
		if p.global_position.y < cell_feet(18, 33).y - 8.0:
			p.input.move_x = 1
		if p.is_on_floor() and i > 10:
			landed = p.global_position.y <= cell_feet(20, 33).y + 1.0
			break
	p.input.move_x = 0
	p.input.jump_held = false
	check(landed, "a jump in the drift lands on the ledge nine tiles up (%s)" % p.global_position)


## Bible 8.9, A10: past the Drift Well the heart's flesh turns every blade but
## the Dragon Slayer. Since pass 217 King Grieve gives it up, and the altar a
## drift pocket lifts you to is bare.
func test_the_dragon_slayer_cuts_the_flesh_of_the_heart() -> void:
	GameState.new_game()
	var w := make_world({}, "zenis/drift_well")
	await frames(2)
	check(w.room.doors.has(2) and w.room.doors[2].target == "zenis/heart_gate", "the Drift Well leads on to the Heart Gate")
	w._enter("zenis/heart_gate")
	await frames(2)
	for e in w.room.get_children():
		if e is Enemy:
			e.queue_free()
	var seal: HeartSeal = w.room.get_children().filter(func(c: Node) -> bool: return c is HeartSeal)[0]
	var p := w.player
	p.max_hp = 9999
	p.hp = 9999
	GameState.data.equipment.blade = "long_sword"
	GameState.refresh_stats(p)
	# Walk up to the flesh and cut at it with common steel.
	p.teleport(cell_feet(47, 20))
	await frames(10)
	p.input.move_x = 1
	await frames(30)
	p.input.move_x = 0
	check(p.global_position.x < seal.global_position.x, "the flesh is a wall (%s)" % p.global_position)
	p.input.attack_pressed = true
	await frames(30)
	check(not seal.is_open(), "a long sword glances off it")
	check(w.room.get_children().filter(func(c: Node) -> bool: return c is ItemPickup).is_empty(), "the altar is bare: King Grieve had the sword")
	# The Dragon Slayer, as King Grieve gives it up (test_boss.gd).
	p.abilities["dragon_slayer"] = true
	GameState.obtain_gear("dragon_slayer", p)
	check(p.slash_damage == int(GameData.item("dragon_slayer").slash), "it cuts harder than any bought blade (%d)" % p.slash_damage)
	p.teleport(cell_feet(48, 20))
	await frames(10)
	p.facing = 1
	p.input.attack_pressed = true
	await frames(30)
	check(seal.is_open(), "and one cut tears the flesh open")
	# Remember the seal before walking on: the way through may lead out of the room.
	var seal_x := seal.global_position.x
	var seal_id := seal.persist_id
	var room_id := w.room.id
	p.input.move_x = 1
	await frames(40)
	p.input.move_x = 0
	check(w.room.id != room_id or p.global_position.x > seal_x + 32.0, "you walk through (%s)" % p.global_position)
	check(GameState.is_collected(seal_id), "and it stays open")


## Bible 8.10: at the foot of the Meteor Rise the last stone is cracked; under it
## a flooded shaft drops into the Sunken Spring, a zone of its own, and the
## water carries you back up the way you came.
func test_the_sunken_spring_opens_under_the_last_stone_of_the_rise() -> void:
	var w := make_world({}, "dartmoor/meteor_rise", cell_feet(14, 59))
	w.player.abilities["mattock"] = true
	var p := w.player
	p.max_hp = 9999
	p.hp = 9999
	for e in w.room.get_children():
		if e is Enemy:
			e.queue_free()
	await frames(4)
	var stones := w.room.get_children().filter(func(c: Node) -> bool: return c is CrackedBlock and absf(c.global_position.y - (60 * Room.TILE + 8)) < 1.0)
	check(stones.size() == 3, "three cracked stones close the shaft at the foot of the Rise (%d)" % stones.size())
	for s: CrackedBlock in stones:
		s.break_block(true)
	p.input.down = true
	var arrived := false
	for i in 400:
		await frames(1)
		if w.room.id == "sunken/spring_gate":
			arrived = true
			break
	p.input.down = false
	check(arrived, "down through the water in the shaft and into the Sunken Spring")
	check(w.room.zone == "sunken" and Music.track == "sunken" and Music.ambience_track == "amb_sunken", "with its own theme and ambience (%s, %s)" % [Music.track, Music.ambience_track])
	check(World.ZONES.has("sunken") and w.motes.zone == "sunken", "the map knows the zone, and specks of light rise in the water")
	await frames(10)
	check(p.swimming, "the shaft is flooded: you arrive swimming")
	# Let go and the water floats you back up the shaft and out into the Rise.
	var back := false
	for i in 900:
		await frames(1)
		if w.room.id == "dartmoor/meteor_rise":
			back = true
			break
	check(back, "the water floats you back up into the Rise")
	for i in 240:
		await frames(1)
	p.input.move_x = -1
	p.input.jump_pressed = true
	p.input.jump_held = true
	for i in 60:
		await frames(1)
		p.input.jump_held = true
	p.input.move_x = 0
	check(w.room.id == "dartmoor/meteor_rise" and p.is_on_floor() and p.global_position.y <= 60 * Room.TILE + 0.5, "and a jump from the surface lands you back on the Rise's floor (%s)" % p.global_position)


## Bible 11 (pass 131): every zone of five rooms or more hides at least one
## room behind a fake wall, so each one rewards a closer look.
func test_every_large_zone_hides_a_room() -> void:
	var w := World.new()
	w.build_catalog()
	var rooms := {}
	var hidden := {}
	for id: String in w.catalog:
		var zone: String = w.catalog[id].zone
		rooms[zone] = int(rooms.get(zone, 0)) + 1
		if w.catalog[id].secret:
			hidden[zone] = int(hidden.get(zone, 0)) + 1
	for zone: String in rooms:
		if rooms[zone] >= 5:
			check(hidden.get(zone, 0) >= 1, "%s (%d rooms) hides a room (%d)" % [zone, rooms[zone], hidden.get(zone, 0)])
	for zone: String in ["mist", "branches", "daybreak"]:
		check(rooms.has(zone), "the catalog has %s" % zone)
	w.free()


## Pass 135: the Mattock breaks cracked stone, and every large zone the player
## walks with it in hand keeps something behind some. Zenis, the last climb,
## holds no side treasure at all by design.
func test_every_large_zone_hides_something_behind_cracked_stone() -> void:
	for zone: String in DirAccess.get_directories_at("res://levels"):
		if zone in ["gym", "test", "trials", "zenis"]:
			continue
		var rooms := 0
		var cracked := 0
		for f: String in DirAccess.get_files_at("res://levels/" + zone):
			if not f.ends_with(".room"):
				continue
			rooms += 1
			var grid := FileAccess.get_file_as_string("res://levels/%s/%s" % [zone, f]).split("---\n", true, 1)
			if grid.size() > 1 and grid[1].contains("C"):
				cracked += 1
		if rooms >= 5:
			check(cracked >= 1, "%s (%d rooms) has cracked stone (%d rooms)" % [zone, rooms, cracked])


## Pass 159: Dartmoor wakes a town, as the original's last town was. Once King
## Grieve falls, the Drowned Market's foes are gone (`calm:`), and a Guru and
## Keymaster Sigrun stand there, the last Guru and key master before Zenis.
func test_dartmoor_wakes_with_a_guru_and_a_key_master() -> void:
	GameState.new_game()
	var w := make_world({}, "dartmoor/drowned_market")
	await frames(2)
	var kinds := func() -> Dictionary:
		var out := {"enemies": 0, "npcs": []}
		for c in w.room.get_children():
			if c is Enemy:
				out.enemies += 1
			elif c is Npc:
				out.npcs.append((c as Npc).npc_id)
		return out
	var before: Dictionary = kinds.call()
	check(before.enemies > 0 and before.npcs.is_empty(), "under the flood the market is the slugs' and the crystal dwarf's (%d foes)" % before.enemies)
	GameState.set_flag("boss:king_grieve")
	w._enter("dartmoor/drowned_market")
	await frames(2)
	var after: Dictionary = kinds.call()
	check(after.enemies == 0, "with the king at rest, the market is a town again: no foes (%d)" % after.enemies)
	check(after.npcs.has("guru") and after.npcs.has("dartmoor_keymaster") and after.npcs.has("dartmoor_mason"),
		"a Guru, Keymaster Sigrun and the mason stand in it (%s)" % [after.npcs])
	var shop: Dictionary = GameData.shop("dartmoor_keys")
	var stock: Array = []
	for s: Dictionary in shop.get("stock", []):
		stock.append(String(s.item))
	check(stock.has("jack_key") and stock.has("queen_key") and stock.has("king_key") and stock.has("ace_key") and not stock.has("joker_key"),
		"Sigrun cuts every key but the Joker (%s)" % [stock])
	w.queue_free()


## Bible 3.2 and 4.2: Zenis's gauntlet, between the Dragon Slayer and the throne,
## asks for every ability once more (the checker proves each one is needed, in
## test_reachability.gd), and a shrine waits at its end.
func test_the_proving_scar_lies_between_the_slayer_and_the_throne() -> void:
	GameState.new_game()
	var w := make_world({}, "zenis/heart_gate")
	await frames(2)
	check(w.room.doors[2].target == "zenis/proving_scar", "past the flesh, the Heart Gate opens on the Proving Scar")
	w._enter("zenis/proving_scar")
	await frames(2)
	check(w.room.doors[1].target == "zenis/heart_gate" and w.room.doors[2].target == "zenis/throne", "and the Scar leads on to the throne")
	var kids := w.room.get_children()
	var count := func(t: Variant) -> int: return kids.filter(func(c: Node) -> bool: return is_instance_of(c, t)).size()
	check(count.call(FireSeal) > 0 and count.call(ConduitGate) > 0 and count.call(CrackedBlock) > 0 and count.call(Waterfall) > 0,
		"its gates: a fire seal, a conduit gate, cracked stone and time-locked water")
	var shrines := kids.filter(func(c: Node) -> bool: return c is SaveShrine)
	check(shrines.size() == 1 and (shrines[0] as Node2D).position.x > 66 * 16, "a shrine stands in its last hall, before the throne")
	var foes := kids.filter(func(c: Node) -> bool: return c is Enemy)
	check(foes.size() == 3 and foes.all(func(e: Enemy) -> bool: return e.corrupted), "its three foes are the meteor's, corrupted")
	w._enter("zenis/throne")
	await frames(2)
	check(w.room.doors[1].target == "zenis/proving_scar", "the throne's west door leads back into the Scar")


## Pass 199: a fat purse sprays a few big coins, not a thousand small ones
## (the Dartmoor vault's 5,000 g chest threw 1,004 coins and a 27 ms frame).
func test_a_big_purse_sprays_few_coins() -> void:
	var w := make_world(_rooms({}), "test/a", cell_feet(4, 19))
	await frames(5)
	for total: int in [3, 9, 10, 137, 1000, 5000]:
		for c in w.room.get_children():
			if c is Coin:
				c.free()
		Coin.spray(w.room, cell_feet(6, 19), total)
		var count := 0
		var sum := 0
		for c in w.room.get_children():
			if c is Coin:
				count += 1
				sum += (c as Coin).value
		check(sum == total, "%d g sprays as %d g" % [total, sum])
		check(count <= 64, "%d g is %d coins, at most 64" % [total, count])
		if total < 10:
			check(count == total, "%d g is still that many single coins" % total)
	await frames(90)
	check(w.player.gold > 0, "the big coins fly to you like the small ones (%d g)" % w.player.gold)


## A big coin sounds big (pass 206, bible 13): the 25 and 100 g coins ring
## `coin_big`, lower and longer than the small coins' `coin`, and taking one
## plays it.
func test_a_big_coin_rings_lower_and_longer() -> void:
	check([1, 5].all(func(v: int) -> bool: return Coin.sound(v) == "coin"), "1 and 5 g coins chime as before")
	check([25, 100].all(func(v: int) -> bool: return Coin.sound(v) == "coin_big"), "25 and 100 g coins ring the big coin")
	var small: AudioStreamWAV = load("res://assets/sfx/coin.wav")
	var big: AudioStreamWAV = load("res://assets/sfx/coin_big.wav")
	check(big != null and big.get_length() > small.get_length() * 2.0,
		"and ring longer (%.2f s against %.2f s)" % [big.get_length() if big else 0.0, small.get_length()])
	var w := make_world(_rooms({}), "test/a", cell_feet(4, 19))
	await frames(5)
	Sfx.recent.clear()
	var coin := Coin.new()
	coin.value = 100
	w.room.add_child(coin)
	coin.global_position = w.player.global_position + Vector2(0, -20)
	coin._age = 1.0
	await frames(3)
	check(not is_instance_valid(coin) and Sfx.recent.has("coin_big"), "taking a 100 g coin plays it (%s)" % [Sfx.recent])


## Pass 259 (bible 4.4): "King Grieve defeated: Dartmoor drains." Until pass
## 259 that was a line two people said; the drowned halls had no water in
## them. Now the Flooded Hall and the Drowned Nave stand a tile deep (the
## `tide:` header) and fill their spike pits, you wade with a splash, and once
## King Grieve is at rest the water is gone and only its mark is left.
func test_dartmoor_drains_when_king_grieve_is_at_rest() -> void:
	for id: String in ["dartmoor/flooded_hall", "dartmoor/drowned_nave"]:
		var w := make_world({}, id)
		await frames(3)
		var tide: Tide = w.room.tide
		check(tide != null and not tide.drained(), "%s stands in water" % id)
		if tide == null:
			continue
		var floor_cells := 0
		var pit_cells := 0
		for c: Vector2i in tide.cells:
			check(w.room.tiles.get_cell_source_id(c) == -1, "%s: no water in rock (%s)" % [id, c])
			if c.y == tide.row:
				floor_cells += 1
			elif c.y > tide.row:
				pit_cells += 1
		check(floor_cells >= w.room.size_tiles.x * 0.75, "%s: a tile deep across most of the floor (%d)" % [id, floor_cells])
		check(pit_cells >= 4, "%s: and the spike pit fills (%d)" % [id, pit_cells])
		var wade := Vector2(w.room.size_tiles.x * 0.5 * Room.TILE, (tide.row + 1) * Room.TILE + 2)
		while w.room.tiles.get_cell_source_id(w.room.cell_at(wade)) == -1 or w.room.tiles.get_cell_source_id(w.room.cell_at(wade + Vector2(0, -Room.TILE))) != -1:
			wade.x += Room.TILE
		check(w.room.surface_at(wade) == "wade", "%s: wading sloshes (%s)" % [id, w.room.surface_at(wade)])
		# Pass 262: a step in it sloshes with its own sound, not the Mist's mud.
		w.player.global_position = wade - Vector2(0, 2)
		Sfx.recent.clear()
		w.player.call("_footstep", -10.0)
		check(Sfx.recent.has("step_wade") and not Sfx.recent.has("step_mud"), "%s: a step in the water sloshes (%s)" % [id, Sfx.recent])
		GameState.set_flag(Tide.DRAIN_FLAG)
		w._enter(id)
		await frames(3)
		check(w.room.tide != null and w.room.tide.drained() and not w.room.tide.has_point(wade + Vector2(0, -8)), "%s drains once King Grieve is at rest" % id)
		check(w.room.surface_at(wade) == "stone", "%s: and the floor is stone again (%s)" % [id, w.room.surface_at(wade)])
		GameState.data.flags.erase(Tide.DRAIN_FLAG)
	# No hall above the flood, and no room outside Dartmoor, stands in it.
	for zone in DirAccess.get_directories_at("res://levels"):
		for f in DirAccess.get_files_at("res://levels/" + zone):
			if f.ends_with(".room"):
				var head: Dictionary = Room.parse(FileAccess.get_file_as_string("res://levels/%s/%s" % [zone, f])).header
				if head.has("tide"):
					check(zone == "dartmoor", "%s/%s: only Dartmoor drowned" % [zone, f])


## Pass 267 (bible 4.4): a guardian's hall answers its fall. Most arenas' signs
## read differently once their guardian is beaten (the Trunk's chewing stops,
## the Spires' nest is empty), but seven still spoke of theirs as alive: the
## Sunken Chapel's lanterns burned on after Ripasheiku went dark, the Bloom
## still grew on the crown-leaf, the Roost still told you to call the storm
## down. Now every sign in an arena outside Zenis has a word for after, and so
## do the doorways that named the Singer and the Foreman.
func test_every_guardians_hall_answers_its_fall() -> void:
	var missing := []
	for zone in DirAccess.get_directories_at("res://levels"):
		if zone == "zenis":
			continue
		for f in DirAccess.get_files_at("res://levels/" + zone):
			if not f.ends_with(".room"):
				continue
			var r := Room.parse(FileAccess.get_file_as_string("res://levels/%s/%s" % [zone, f]))
			var boss := String(r.header.get("boss", ""))
			if boss == "":
				continue
			var cells := {}
			for spec: String in r.lists.get("sign", []):
				var cell := spec.get_slice(",", 0).strip_edges() + "," + spec.get_slice(",", 1).strip_edges()
				cells[cell] = bool(cells.get(cell, false)) or spec.get_slice(",", 2).strip_edges().begins_with("[boss:%s]" % boss)
			for cell: String in cells:
				if not cells[cell]:
					missing.append("%s/%s (%s)" % [zone, f.get_basename(), cell])
	check(missing.is_empty(), "every arena sign has a word for after its guardian (missing: %s)" % [missing])
	# The doorways, read for real: before and after.
	for case: Array in [["mist/lantern_landing", "ripasheiku", "sings in there", "Nothing sings"], ["tower/foreman_gate", "foreman", "foreman's mattock", "mattock is yours"], ["mist/sunken_chapel", "ripasheiku", "still burn", "gone out"]]:
		var w := make_world({}, case[0])
		await frames(2)
		var tablet: LoreTablet = null
		for c in w.room.get_children():
			if c is LoreTablet and (c as LoreTablet).current_text().contains(case[2]):
				tablet = c
		check(tablet != null, "%s tells of its guardian before" % case[0])
		GameState.set_flag("boss:" + case[1])
		check(tablet != null and tablet.current_text().contains(case[3]), "and after (%s)" % (tablet.current_text() if tablet else "no tablet"))
		GameState.data.flags.erase("boss:" + case[1])
		w.queue_free()
		await frames(2)


## Pass 275 (bible 7, the Naga): "a climb past it is timed to its swing" was
## not true. Its coil froze it where it was, so by the time it struck, a
## climber holding Up was already above its bite: every climb past both Nagas
## went unbitten, whatever the swing. Now the coil follows the climber's height
## along its column, slower than a climb, and its recovery is longer. In each
## Naga's room, for climbs started at eight points of its swing: holding Up
## straight past is met by the bite nearly every time, and baiting it (climb into its
## level, drop back as it hoods, climb again once it has glided off the
## ladder) always gets past.
## Bible 7 (pass 283): the great loaf a slain Naga leaves (pass 281) falls
## down the Tower's ladder shafts. Wherever along its swing and strike the
## serpent dies, and whichever way the loaf pops, it must come to rest on a
## floor inside the room, where you can walk to it, not fall out through the
## gap in the shaft's floor to the room below.
func test_a_nagas_loaf_lands_where_you_can_reach_it() -> void:
	for id: String in ["tower/foot", "tower/mine_shaft"]:
		var w := make_world({}, id)
		await frames(2)
		var n: Naga = null
		for c in w.room.get_children():
			if c is Naga:
				n = c
			elif c is Enemy:
				c.queue_free()
		check(n != null, "%s keeps its Naga" % id)
		if n == null:
			w.queue_free()
			await frames(1)
			continue
		var bounds := Rect2(Vector2.ZERO, Vector2(w.room.size_tiles) * Room.TILE)
		# The hero waits up out of the way, so no loaf is eaten before it is judged.
		w.player.teleport(Vector2(3 * Room.TILE, 4 * Room.TILE))
		w.player.frozen = true
		var lost: Array[String] = []
		var tried := 0
		# Its strike carries it up to 104 px toward the ladder (to its right).
		for k in 8:
			for dy in [-Naga.SWING, 0.0, Naga.SWING]:
				for vx in [-40.0, 0.0, 40.0]:
					var at := n.home + Vector2(k * 15.0, dy - 22.0)
					var d := Drop.make(w.room, at, "loaf")
					d.velocity = Vector2(vx, -200)
					tried += 1
					for f in 240:
						await frames(1)
						if not is_instance_valid(d) or d.is_on_floor() and absf(d.velocity.x) < 1.0:
							break
					if not is_instance_valid(d) or not d.is_on_floor() or not bounds.has_point(d.global_position):
						lost.append("(%d, %d) vx %d -> %s" % [at.x, at.y, vx, d.global_position if is_instance_valid(d) else "gone"])
					if is_instance_valid(d):
						d.free()
		w.player.frozen = false
		check(lost.is_empty(), "%s: every loaf lands on a floor in the room (%d of %d lost: %s)" % [id, lost.size(), tried, lost])
		w.queue_free()
		await frames(2)


func test_a_nagas_gold_lands_where_you_can_reach_it() -> void:
	for id: String in ["tower/foot", "tower/mine_shaft"]:
		var w := make_world({}, id)
		await frames(2)
		var n: Naga = null
		for c in w.room.get_children():
			if c is Naga:
				n = c
			elif c is Enemy:
				c.queue_free()
		check(n != null, "%s keeps its Naga" % id)
		if n == null:
			w.queue_free()
			await frames(1)
			continue
		var bounds := Rect2(Vector2.ZERO, Vector2(w.room.size_tiles) * Room.TILE)
		# The hero struck from afar (a thrown Rune Dagger, a spell) and waits out
		# of the coins' magnet range, so each coin is judged where it comes to rest.
		w.player.teleport(Vector2(3 * Room.TILE, 4 * Room.TILE))
		w.player.frozen = true
		var lost: Array[String] = []
		var tried := 0
		var start_gold := w.player.gold
		for k in 8:
			for dy in [-Naga.SWING, 0.0, Naga.SWING]:
				for vx in [-80.0, 0.0, 80.0]:
					var at := n.home + Vector2(k * 15.0, dy - 22.0)
					var c := Coin.new()
					c.value = 5
					c.velocity = Vector2(vx, -200)
					w.room.add_child(c)
					c.global_position = at
					tried += 1
					for f in 240:
						await frames(1)
						if not is_instance_valid(c) or c._age > 0.8 and c.is_on_floor() and absf(c.velocity.x) < 1.0:
							break
					if not is_instance_valid(c) or not c.is_on_floor() or not bounds.has_point(c.global_position):
						lost.append("(%d, %d) vx %d -> %s" % [at.x, at.y, vx, c.global_position if is_instance_valid(c) else "gone"])
					if is_instance_valid(c):
						c.free()
		check(w.player.gold == start_gold, "%s: no coin was taken while it was judged" % id)
		w.player.frozen = false
		check(lost.is_empty(), "%s: every coin lands on a floor in the room (%d of %d lost: %s)" % [id, lost.size(), tried, lost])
		w.queue_free()
		await frames(2)


## Pass 291: a foe knocked through a gap in its room's floor dies as it leaves
## and pays out where you can reach it. In every room every walking foe is
## driven by blows to one side, then the other: none may be left alive below
## the room, and a fallen one's coins rest on a floor inside it.
func test_a_foe_knocked_out_of_its_room_falls_to_its_death() -> void:
	var w := make_world({}, Trials.TEMPLE)
	await frames(3)
	var ids: Array[String] = []
	for zone: String in DirAccess.get_directories_at("res://levels"):
		for file: String in DirAccess.get_files_at("res://levels/" + zone):
			if file.ends_with(".room"):
				ids.append(zone + "/" + file.trim_suffix(".room"))
	ids.sort()
	var lost: Array[String] = []
	var fell: Array[String] = []
	var unpaid: Array[String] = []
	for id in ids:
		for side: float in [-1.0, 1.0]:
			w.start(id)
			await frames(2)
			w.player.frozen = true
			w.player.dead = true
			var foes: Array = []
			for e in w.room.get_children():
				if e is Enemy and e.uses_gravity and not e.is_in_group("boss"):
					e.max_hp = 99999
					e.hp = 99999
					# Only a fall kills a foe here: no blow comes near its health.
					e.died.connect(func(x: Enemy) -> void: fell.append("%s %s" % [id, x.get_script().get_global_name()]))
					foes.append(e)
			if foes.is_empty():
				w.player.dead = false
				w.player.frozen = false
				break
			var gold_before := w.player.gold
			var bounds := Rect2(Vector2.ZERO, Vector2(w.room.size_tiles) * Room.TILE)
			for k in 12:
				for e: Variant in foes:
					if is_instance_valid(e) and not e.dead:
						e.take_hit(1, Vector2(side * 1.8, 0))
				await frames(18)
			await frames(90)
			for e: Variant in foes:
				if not is_instance_valid(e):
					continue
				if not e.dead and e.global_position.y > bounds.end.y:
					lost.append("%s %s" % [id, e.get_script().get_global_name()])
			for c in w.room.get_children():
				if c is Coin and not (c.is_on_floor() and bounds.has_point(c.global_position)):
					unpaid.append("%s coin at %s" % [id, c.global_position])
			w.player.dead = false
			w.player.frozen = false
	check(fell.size() >= 10, "foes were knocked through floor gaps (%d fell: %s)" % [fell.size(), fell])
	check(lost.is_empty(), "none is left alive below its room: %s" % [lost])
	check(unpaid.is_empty(), "and a fallen foe's coins rest on a floor in the room: %s" % [unpaid.slice(0, 8)])


func test_a_climb_past_a_naga_is_timed_to_its_strike() -> void:
	for id: String in ["tower/foot", "tower/mine_shaft"]:
		var w := make_world({}, id)
		await frames(2)
		var n: Naga = null
		for c in w.room.get_children():
			if c is Naga:
				n = c
			elif c is Enemy:
				c.queue_free()
		check(n != null, "%s keeps its Naga" % id)
		if n == null:
			w.queue_free()
			await frames(1)
			continue
		# Its ladder, and the floor at the ladder's foot.
		var cell := w.room.cell_at(n.home)
		var lx := -1
		for dx in range(1, 8):
			if w.room.is_ladder_at(Vector2((cell.x + dx) * Room.TILE + 8, cell.y * Room.TILE + 8)):
				lx = cell.x + dx
				break
		var foot := cell.y
		while w.room.is_ladder_at(Vector2(lx * Room.TILE + 8, (foot + 1) * Room.TILE + 8)):
			foot += 1
		var above := (cell.y - 6) * Room.TILE
		var p := w.player
		for bait: bool in [false, true]:
			var bitten := 0
			var past := 0
			for k in 8:
				p.max_hp = 999
				p.hp = 999
				p.teleport(Vector2(lx * Room.TILE + 8, (foot + 1) * Room.TILE))
				n.global_position = n.home
				n.velocity = Vector2.ZERO
				n.set_state("float")
				n._swung = k * Naga.SWING_TIME / 8.0
				n._cooldown = 0.0
				p.input.up = true
				var step := 0
				for f in 600:
					await frames(1)
					if bait and step == 0 and n.state == "coil":
						step = 1
						p.input.up = false
						p.input.down = true
					elif step == 1 and n.state in ["return", "float"] and absf(n.global_position.x - p.global_position.x) > 40.0:
						step = 2
						p.input.down = false
						p.input.up = true
					if p.global_position.y < above:
						break
				p.input.up = false
				p.input.down = false
				if p.hp < 999:
					bitten += 1
				if p.global_position.y < above:
					past += 1
				await frames(20)
			if bait:
				check(bitten == 0 and past == 8, "%s: baited, its strike spent, every climb gets past unbitten (%d bitten, %d past of 8)" % [id, bitten, past])
			else:
				check(bitten >= 6, "%s: holding Up straight past, the bite meets the climber nearly every time (%d of 8)" % [id, bitten])
		w.queue_free()
		await frames(1)


## Bible 10.1 (pass 307): a drop never rests at a side door. A door is three tiles
## tall: a jump over a flask lying on the tile just inside it meets the
## wall above the door and drops you on the flask, so poison there was a toll on
## the way out. It now stops two tiles in, and a hop clears it and lands short
## of the door across a wide window of timings.
func test_a_drop_never_rests_in_a_doorway() -> void:
	for lead: int in [20, 28, 36, 44]:
		var w := make_world(_rooms(), "test/b", cell_feet(8, 19))
		var p := w.player
		await frames(3)
		var flask := Drop.make(w.room, Vector2(4, 19 * 16 + 8), "poison")
		flask.velocity = Vector2(-60, 0)
		await frames(20)
		var door: Rect2 = w.room.doors[1].rect
		var fx := flask.global_position.x
		check(fx >= Drop.DOOR_CLEAR - 0.5 and not door.grow(16).has_point(flask.global_position + Vector2(0, -2)),
			"the flask rests two tiles in from the door (%.1f)" % fx)
		p.input.scripted = true
		p.input.move_x = -1
		var jumped := -1
		for f in 120:
			if jumped < 0 and p.global_position.x < fx + lead:
				p.input.jump_pressed = true
				jumped = f
			else:
				p.input.jump_pressed = false
			p.input.jump_held = jumped >= 0 and f - jumped < 8
			await frames(1)
			if w.room.id != "test/b":
				break
		check(w.room.id == "test/a" and p.poison_left == 0.0,
			"a hop %d px short of it clears it and the door takes you on" % lead)
		p.input.move_x = 0
		p.input.jump_held = false
		w.queue_free()
		await frames(2)


## Bible 5.2 (pass 315): the Hornet Gallery teaches the Rune Dagger, and since
## Sean's off hand (2026-10-31) the dagger goes straight into a shield's hand when
## found there. So every foe in the room must be in a dagger's reach from ground
## you can stand on (no thorns): straight up for a hornet, along the floor for the
## spitter. Each is thrown at for real from the nearest such spot.
func test_the_hornet_gallery_can_be_cleared_with_the_dagger() -> void:
	var text := FileAccess.get_file_as_string("res://levels/trunk/hornet_gallery.room")
	var grid: PackedStringArray = text.split("---\n")[1].strip_edges().split("\n")
	var spots: Array[Vector2i] = []
	for y in range(grid.size() - 1):
		for x in range(grid[y].length()):
			var c := grid[y][x]
			var below := grid[y + 1][x]
			if c in ".}T$" and below in "#-" and grid[y - 1][x] in ".}T$H" and grid[y - 2][x] in ".}T$H":
				spots.append(Vector2i(x, y))
	var foes := []
	for y in grid.size():
		for x in grid[y].length():
			if grid[y][x] in "HT":
				foes.append(Vector2i(x, y))
	check(foes.size() == 4, "three hornets and a spitter (%s)" % [foes])
	for foe_cell: Vector2i in foes:
		var hornet := grid[foe_cell.y][foe_cell.x] == "H"
		var w := make_world({}, "trunk/hornet_gallery")
		var p := w.player
		p.abilities["rune_dagger"] = true
		GameState.data.equipment.shield = ""
		await frames(3)
		var foe: Enemy = null
		for e: Node in runner.get_tree().get_nodes_in_group("enemy"):
			if e is Enemy and w.room.cell_at((e as Enemy).center()) == foe_cell:
				foe = e
		check(foe != null, "the foe at %s stands in the room" % [foe_cell])
		if foe == null:
			w.queue_free()
			await frames(2)
			continue
		var target := foe.center()
		var best := Vector2i(-1, -1)
		var best_d := INF
		for s: Vector2i in spots:
			var feet := cell_feet(s.x, s.y)
			var d := INF
			if hornet and absf(feet.x - target.x) <= 8.0 and target.y < feet.y:
				d = (feet.y - 22.0) - target.y
			elif not hornet and s.y == foe_cell.y and absf(feet.x - target.x) > 24.0:
				d = absf(feet.x - target.x) - 10.0
			if d < best_d:
				best_d = d
				best = s
		check(best_d <= RuneDagger.RANGE, "a %s at %s is in the dagger's reach from safe ground (%.0f px from %s)" % ["hornet" if hornet else "spitter", foe_cell, best_d, best])
		if best.x >= 0:
			var hp0 := foe.hp
			p.global_position = cell_feet(best.x, best.y)
			p.velocity = Vector2.ZERO
			p.facing = 1 if target.x > p.global_position.x else -1
			await frames(2)
			p.input.up = hornet
			p.throw_dagger()
			await frames(40)
			p.input.up = false
			check(foe.dead or foe.hp < hp0, "and a throw from there strikes it (hp %d of %d)" % [foe.hp, hp0])
		w.queue_free()
		await frames(2)


## Pass 323: the bible's zone table (3.2) and overview (3.1) count the rooms
## the game has. Until then they carried the plan's counts (about 190 rooms).
func test_the_bible_counts_each_zones_rooms() -> void:
	const ZONES := {"Eolis": "eolis", "Trunk Hollows": "trunk", "Tower of Trunk": "tower", "The Mist": "mist",
		"Branches (Conflate)": "branches", "Branches (Daybreak) and Canopy Spires": "daybreak", "Dartmoor": "dartmoor",
		"Zenis": "zenis", "Sunken Spring": "sunken", "Guru Trials": "trials"}
	var bible := FileAccess.get_file_as_string("res://docs/design-bible.md")
	var table := bible.get_slice("### 3.2 Zones", 1).get_slice("\n\n**", 0)
	var total := 0
	var folders := []
	for dir: String in DirAccess.get_directories_at("res://levels"):
		if dir != "gym":
			folders.append(dir)
	for zone: String in ZONES:
		var folder: String = ZONES[zone]
		var n := 0
		for f: String in DirAccess.get_files_at("res://levels/" + folder):
			if f.ends_with(".room"):
				n += 1
		total += n
		folders.erase(folder)
		var row := table.get_slice("| **%s** |" % zone, 1).get_slice("\n", 0)
		var said := row.get_slice("|", 1).strip_edges()
		check(said.get_slice(" ", 0).to_int() == n, "3.2 counts %s's rooms: \"%s\", and %s/ has %d" % [zone, said, folder, n])
	check(folders.is_empty(), "every zone folder has its row in 3.2 (missing: %s)" % [folders])
	check(bible.contains("**%d rooms** across 7 zones" % total), "3.1 counts the whole tree's rooms (%d)" % total)


## Pass 331: bible 3.3 said rooms were whole screens, 1x1 to 4x3, and 2 to 3
## shrines a zone. Neither was held, and the levels disagree with both: 14
## rooms are a screen and a half wide, and the zones keep 1 to 5 shrines. The
## bible now says what was built; these hold it to `levels/`.
func test_every_room_keeps_the_bibles_size() -> void:
	var bible := FileAccess.get_file_as_string("res://docs/design-bible.md")
	var rule := bible.get_slice("- **Room size:**", 1).get_slice("\n", 0)
	check(rule.contains("at least one screen (40x23 tiles) and no more than 4x3 screens (160x68)"), "3.3 states the bounds as built")
	var odd := []
	var halves := 0
	var count := 0
	for zone: String in DirAccess.get_directories_at("res://levels"):
		if zone in ["gym", "trials"]:
			continue
		for f: String in DirAccess.get_files_at("res://levels/" + zone):
			if not f.ends_with(".room"):
				continue
			count += 1
			var size := _room_size("res://levels/%s/%s" % [zone, f])
			if size.x < 40 or size.y < 23 or size.x > 160 or size.y > 68:
				odd.append("%s/%s %dx%d" % [zone, f, size.x, size.y])
			if size.x == 60:
				halves += 1
	check(count >= 100, "every map room is measured (%d)" % count)
	check(odd.is_empty(), "every map room is one screen to 4x3 screens (not: %s)" % [odd])
	check(rule.contains("%d are a screen and a half wide" % halves), "3.3 counts the screen-and-a-half rooms (%d)" % halves)
	var short := 0
	for f: String in DirAccess.get_files_at("res://levels/trials"):
		if f.ends_with(".room") and _room_size("res://levels/trials/" + f).y < 23:
			short += 1
	check(rule.contains("%s are shorter than a screen" % ["none", "one", "two", "three"][mini(short, 3)]), "3.3 counts the trials shorter than a screen (%d)" % short)


func test_every_zone_has_the_shrines_the_bible_counts() -> void:
	const ZONES := {"Trunk Hollows": "trunk", "Tower of Trunk": "tower", "The Mist": "mist",
		"Branches (Conflate)": "branches", "Branches (Daybreak)": "daybreak", "Dartmoor": "dartmoor",
		"Sunken Spring": "sunken", "Zenis": "zenis", "Eolis": "eolis"}
	var bible := FileAccess.get_file_as_string("res://docs/design-bible.md")
	var rule := bible.get_slice("- **Save points:**", 1).get_slice("\n", 0).get_slice("**As built (pass 331):**", 1)
	var total := 0
	for zone: String in ZONES:
		var folder: String = ZONES[zone]
		var n := 0
		for f: String in DirAccess.get_files_at("res://levels/" + folder):
			if f.ends_with(".room"):
				n += FileAccess.get_file_as_string("res://levels/%s/%s" % [folder, f]).get_slice("\n---\n", 1).count("S")
		total += n
		var said := rule.get_slice(zone + " ", 1).get_slice(" ", 0).trim_suffix(",")
		check(said == ("none" if n == 0 else str(n)), "3.3 counts %s's shrines: \"%s\", and the rooms hold %d" % [zone, said, n])
	check(total >= 20, "the tree has its shrines (%d)" % total)


func _room_size(path: String) -> Vector2i:
	var rows := FileAccess.get_file_as_string(path).get_slice("\n---\n", 1).split("\n", false)
	var w := 0
	for row: String in rows:
		w = maxi(w, row.length())
	return Vector2i(w, rows.size())


## Pass 334: bible 13.3 planned "about 180" effects and "about 22" tracks, and
## no line said what was built. This holds the as-built counts to `assets/`,
## and the reverse of `test_every_sound_the_code_plays_exists`: every effect on
## disk is named in the code, whole or after a prefix built at runtime.
func test_the_bible_counts_the_games_sounds() -> void:
	var sfx: Array[String] = []
	for f: String in DirAccess.get_files_at("res://assets/sfx"):
		if f.ends_with(".wav"):
			sfx.append(f.get_basename())
	var tracks := 0
	var beds := 0
	for f: String in DirAccess.get_files_at("res://assets/music"):
		if f.get_extension() in ["ogg", "mp3", "wav"]:
			if f.begins_with("amb_"):
				beds += 1
			else:
				tracks += 1
	var bible := FileAccess.get_file_as_string("res://docs/design-bible.md")
	var built := bible.get_slice("- **SFX (CODE synth + CC0 packs):**", 1).get_slice("**As built (pass 334):**", 1).get_slice("\n", 0)
	check(built.contains("**%d sound effects**" % sfx.size()), "13.3 counts the sound effects (%d)" % sfx.size())
	check(built.contains("**%d music tracks** with **%d ambience beds**" % [tracks, beds]), "13.3 counts the tracks and beds (%d, %d)" % [tracks, beds])
	var groups := RegEx.create_from_string("(\\d+) (?:for towns|variants|guardians' own)|each of the (\\d+) areas")
	var named := 4 # boss, miniboss, title, ending
	for m: RegExMatch in groups.search_all(built):
		named += int(m.get_string(1) if m.get_string(1) != "" else m.get_string(2))
	check(named == tracks, "13.3's list of tracks adds up to the folder (%d of %d)" % [named, tracks])
	var code := ""
	var dirs: Array[String] = ["res://scripts"]
	while not dirs.is_empty():
		var d: String = dirs.pop_back()
		for sub: String in DirAccess.get_directories_at(d):
			dirs.append(d + "/" + sub)
		for f: String in DirAccess.get_files_at(d):
			if f.ends_with(".gd"):
				code += FileAccess.get_file_as_string(d + "/" + f)
	var prefixes := RegEx.create_from_string("\"([a-z]+_)\" \\+")
	var built_from: Array[String] = []
	for m: RegExMatch in prefixes.search_all(code):
		built_from.append(m.get_string(1))
	var unplayed := []
	for s: String in sfx:
		if code.contains("\"%s\"" % s):
			continue
		if built_from.any(func(pre: String) -> bool: return s.begins_with(pre)):
			continue
		unplayed.append(s)
	check(unplayed.is_empty(), "every sound effect on disk is played by the code (not: %s)" % [unplayed])
