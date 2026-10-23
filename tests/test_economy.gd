extends TestSuite
## Shops, gear, keys and key doors, the skill tree, ranks and the King
## (design bible 5.2, 9 and 10).


func _town(extra := {}, header := []) -> Dictionary:
	var a := grid_rows(40, 23)
	put_tiles(a, 5, 19, "P")
	for k: Vector2i in extra:
		put_tiles(a, k.x, k.y, extra[k])
	return {"test/town": room_text(["name: Town", "zone: test"] + header, a)}


func _find(room: Room, type: Variant) -> Node:
	for c in room.get_children():
		if is_instance_of(c, type):
			return c
	return null


# --- Shops and gear ------------------------------------------------------------------

func test_buying_a_blade_changes_damage() -> void:
	var w := make_world(_town(), "test/town")
	var p := w.player
	p.gold = 500
	check(Shop.status("eolis_arms", 0, p) == "", "Long Sword is for sale")
	check(Shop.buy("eolis_arms", 0, p), "bought the Long Sword")
	check(p.gold == 100 and GameState.data.equipment.blade == "long_sword", "paid 400 and equipped it")
	check(p.slash_damage == 11 and p.heavy_damage == 19 and p.reach_bonus > 0.0, "Long Sword stats applied")
	check(Shop.status("eolis_arms", 0, p) == "owned", "can't buy it twice")
	check(Shop.status("eolis_arms", 1, p) == "gold", "can't afford the armor with 100 gold")
	check(not Shop.buy("eolis_arms", 1, p) and p.gold == 100, "failed purchase costs nothing")


func test_once_only_stock_sells_out() -> void:
	var w := make_world(_town(), "test/town")
	var p := w.player
	p.gold = 2000
	var mp0 := p.max_mp
	check(Shop.buy("eolis_items", 1, p), "bought Mana Dew")
	check(p.max_mp == mp0 + GameState.MANA_DEW_MP, "max MP grew")
	check(Shop.status("eolis_items", 1, p) == "sold out", "Mana Dew sold out")
	check(Shop.buy("eolis_items", 0, p) and Shop.buy("eolis_items", 0, p), "keys can be bought again and again")
	check(GameState.key_count("jack") == 2, "two Jack Keys")


func test_armor_reduces_damage() -> void:
	var w := make_world(_town(), "test/town")
	var p := w.player
	await frames(3)
	GameState.data.equipment.armor = "leather_armor"
	GameState.refresh_stats(p)
	p.take_damage(20)
	check(p.hp == p.max_hp - 17, "Leather Armor: 20 damage becomes 17 (hp %d)" % p.hp)


func test_no_shield_no_block() -> void:
	var w := make_world(_town(), "test/town")
	var p := w.player
	await frames(3)
	check(not p.has_shield, "a new game starts without a shield")
	p.input.block_held = true
	await frames(3)
	check(not p.is_blocking, "can't block without a shield")
	GameState.data.equipment.shield = "small_shield"
	GameState.refresh_stats(p)
	await frames(2)
	check(p.is_blocking, "blocks once the Small Shield is bought")


# --- Keys ----------------------------------------------------------------------------

func test_jack_door_needs_a_key_and_stays_open() -> void:
	var rooms := _town({Vector2i(12, 19): "J"})
	var w := make_world(rooms, "test/town", cell_feet(9, 19))
	var p := w.player
	await frames(3)
	p.input.move_x = 1
	await frames(40)
	check(p.global_position.x < 12 * 16, "the door blocks the way (x %.0f)" % p.global_position.x)
	check(_find(w.room, KeyDoor) != null, "door still shut without a key")
	GameState.add_key("jack")
	await frames(30)
	check(_find(w.room, KeyDoor) == null or _find(w.room, KeyDoor).is_queued_for_deletion(), "the key opens it")
	check(GameState.key_count("jack") == 0, "the key is used up")
	await frames(30)
	check(p.global_position.x > 13 * 16, "walked through (x %.0f)" % p.global_position.x)
	w.texts["test/town"] = rooms["test/town"]
	w._enter("test/town")
	check(_find(w.room, KeyDoor) == null, "opened doors stay open")


# --- Skills and ranks --------------------------------------------------------------

func test_skill_rules() -> void:
	var w := make_world(_town(), "test/town")
	var p := w.player
	check(Skills.status("keen_edge") == "points", "no points, can't learn")
	GameState.data.skill_points = 3
	check(Skills.status("fourth_strike") == "locked", "Fourth Strike needs Keen Edge first")
	check(Skills.learn("keen_edge", p) and int(GameState.data.skill_points) == 2, "learned Keen Edge for 1 point")
	check(is_equal_approx(p.melee_mult, 1.1), "Keen Edge adds 10% melee damage")
	check(Skills.learn("fourth_strike", p) and p.ground_combo_length == 4, "Fourth Strike makes a 4-hit combo")
	check(Skills.status("clear_mind") == "points", "out of points")
	p.gold = 1000
	check(Skills.respec(p), "unlearned everything")
	check(p.gold == 800 and int(GameState.data.skill_points) == 3, "respec cost 200 and refunded 3 points")
	check(p.ground_combo_length == 3 and is_equal_approx(p.melee_mult, 1.0), "effects removed")
	check(Skills.respec_cost() == 400, "the next respec costs more")


func test_stat_skills() -> void:
	var w := make_world(_town(), "test/town")
	var p := w.player
	GameState.data.skill_points = 4
	var mp0 := p.max_mp
	var flask0 := p.flask_max
	Skills.learn("clear_mind", p)
	Skills.learn("deep_pockets", p)
	Skills.learn("gold_sense", p)
	check(p.max_mp == mp0 + 20.0, "Clear Mind: +20 max MP")
	check(p.flask_max == flask0 + 1, "Deep Pockets: +1 potion charge")
	p.gold = 0
	for i in 10:
		p.add_gold(10, true)
	check(p.gold == 110, "Gold Sense: 10%% more found gold (%d)" % p.gold)
	p.add_gold(100)
	check(p.gold == 210, "returned gold gets no bonus")


func test_fourth_strike_combo_ends_heavy() -> void:
	var w := make_world(_town({Vector2i(9, 19): "E"}), "test/town", cell_feet(7, 19))
	var p := w.player
	GameState.data.skill_points = 3
	Skills.learn("keen_edge", p)
	Skills.learn("fourth_strike", p)
	await frames(6)
	var dummy: TrainingDummy = _find(w.room, TrainingDummy)
	var seen: Array[int] = []
	var heavy: Array[bool] = []
	for i in 4:
		p.input.attack_pressed = true
		await frames(1)
		seen.append(p.combo_index)
		heavy.append(p.is_heavy_swing)
		await frames(int((0.38 if p.is_heavy_swing else 0.2) * 60.0) + 1)
	check(seen == [1, 2, 3, 4], "four hits (%s)" % [seen])
	check(heavy == [false, false, false, true], "only the fourth is heavy (%s)" % [heavy])
	var light := roundi(8 * 1.1)
	var big := roundi(14 * 1.1)
	check(dummy.hp == TrainingDummy.HP - light * 3 - big, "Keen Edge damage on every hit (dummy hp %d)" % dummy.hp)


func test_xp_raises_rank_and_gives_points() -> void:
	make_world(_town(), "test/town")
	GameState.add_xp(39)
	check(int(GameState.data.rank) == 0, "39 XP is still Novice")
	GameState.add_xp(1)
	check(GameState.rank_name() == "Aspirant" and int(GameState.data.skill_points) == 1, "40 XP: Aspirant and a skill point")
	GameState.add_xp(260)
	check(GameState.rank_name() == "Adept" and int(GameState.data.skill_points) == 4, "300 XP: Adept, four points")


func test_kills_give_xp() -> void:
	var w := make_world(_town({Vector2i(12, 19): "M"}), "test/town")
	await frames(3)
	var m: Monodron = _find(w.room, Monodron)
	var xp := m.xp
	m.take_hit(999, Vector2.RIGHT)
	await frames(2)
	check(xp > 0 and int(GameState.data.xp) == xp, "a Monodron kill gives %d XP (got %d)" % [xp, int(GameState.data.xp)])


func test_gym_kills_give_no_xp() -> void:
	make_world(_town(), "test/town")
	GameState.active = false
	GameState.add_xp(100)
	GameState.active = true
	check(int(GameState.data.xp) == 0, "no XP while the game state is inactive")


func test_kills_sometimes_drop_bread_or_mana() -> void:
	var w := make_world(_town({Vector2i(12, 19): "M", Vector2i(20, 19): "M"}), "test/town")
	var p := w.player
	await frames(3)
	var monos: Array = w.room.get_children().filter(func(c: Node) -> bool: return c is Monodron)
	Drop.bread_chance = 1.0
	monos[0].take_hit(999, Vector2.RIGHT)
	Drop.bread_chance = 0.0
	var bread: Drop = _find(w.room, Drop)
	check(bread != null and bread.kind == "bread", "a kill can leave bread")
	await frames(40)
	check(bread.is_on_floor(), "it settles on the floor")
	p.hp = 40
	p.teleport(bread.global_position)
	await frames(3)
	check(p.hp == 40 + Drop.BREAD_HEAL and not is_instance_valid(bread), "walking over it eats it: +%d health (%d)" % [Drop.BREAD_HEAL, p.hp])
	Drop.mana_chance = 1.0
	monos[1].take_hit(999, Vector2.RIGHT)
	Drop.mana_chance = 0.0
	var orb: Drop = _find(w.room, Drop)
	check(orb != null and orb.kind == "mana", "or a mana orb")
	await frames(40)
	p.mp = 10.0
	p.teleport(orb.global_position)
	await frames(3)
	check(p.mp >= 10.0 + Drop.MANA_GAIN and p.mp < 11.0 + Drop.MANA_GAIN, "which refills magic (%.1f, with a moment of regeneration)" % p.mp)
	Drop.mana_chance = 1.0
	Drop.bread_chance = 0.0
	var spare := Drop.roll(w.room, cell_feet(30, 19))
	Drop.mana_chance = 0.0
	await frames(roundi(Drop.LIFETIME * 60.0) + 5)
	check(not is_instance_valid(spare), "an uneaten drop fades away")


func test_the_guru_gives_a_mantra_for_the_journey() -> void:
	make_world(_town(), "test/town")
	var m := GameState.mantra()
	check(m.length() == 19 and m.split(" ").size() == 4, "four groups of four letters (%s)" % m)
	check(GameState.mantra() == m, "the same journey gives the same mantra")
	GameState.data.gold = int(GameState.data.gold) + 1
	check(GameState.mantra() != m, "any change to the journey changes it")


# --- NPCs ----------------------------------------------------------------------------

func test_king_gives_gold_once() -> void:
	var w := make_world(_town({}, ["npc: 8, 19, king"]), "test/town", cell_feet(8, 19))
	var p := w.player
	var said := []
	var listener := func(who: String, _pages: Array) -> void: said.append(who)
	GameState.dialog_requested.connect(listener)
	await frames(3)
	p.input.up_pressed = true
	await frames(2)
	check(p.gold == Npc.KING_GOLD, "the King gives 1,500 gold (%d)" % p.gold)
	p.input.up_pressed = true
	await frames(2)
	GameState.dialog_requested.disconnect(listener)
	check(p.gold == Npc.KING_GOLD, "only once")
	check(said.size() == 2 and said[0] == "King of Eolis", "he talks both times")


func test_every_npc_and_shop_entry_is_valid() -> void:
	var bad: Array[String] = []
	for id: String in GameData.table("npcs"):
		var npc: Dictionary = GameData.npc(id)
		if npc.role == "shop" and GameData.shop(npc.shop).is_empty():
			bad.append("%s sells from missing shop %s" % [id, npc.shop])
		if npc.role in ["talk", "king"] and npc.get("lines", []).is_empty():
			bad.append("%s has nothing to say" % id)
	for shop_id: String in GameData.table("shops"):
		for entry: Dictionary in GameData.shop(shop_id).stock:
			if GameData.item(entry.item).is_empty():
				bad.append("%s sells unknown item %s" % [shop_id, entry.item])
	for node: Dictionary in Skills.nodes():
		if String(node.needs) != "" and GameData.skill(node.needs).is_empty():
			bad.append("skill %s needs unknown %s" % [node.id, node.needs])
	check(bad.is_empty(), "data tables are consistent: %s" % ", ".join(bad))


# --- Apolune -------------------------------------------------------------------------

func test_large_shield_guards_more() -> void:
	var w := make_world(_town(), "test/town")
	var p := w.player
	await frames(3)
	GameState.data.equipment.shield = "small_shield"
	GameState.refresh_stats(p)
	check_near(p.guard_reduction, 0.5, 0.001, "the Small Shield halves a guarded hit")
	p.gold = 900
	check(Shop.buy("apolune_armor", 1, p), "bought the Large Shield")
	check_near(p.guard_reduction, 0.7, 0.001, "the Large Shield blocks 70%")
	var dummy := Node2D.new()
	w.room.add_child(dummy)
	dummy.global_position = p.global_position + Vector2(p.facing * 30, 0)
	p.input.block_held = true
	await frames(3)
	check(p.receive_attack(20, dummy, false) == "guarded" and p.hp == p.max_hp - 6, "a guarded 20 becomes 6 (hp %d)" % p.hp)
	check(Shop.status("eolis_arms", 2, p) == "owned", "the Small Shield counts as owned once you have a better one")


func test_elixir_revives_once_and_is_limited_to_one() -> void:
	var w := make_world(_town(), "test/town")
	var p := w.player
	await frames(3)
	p.gold = 4000
	check(Shop.buy("apolune_items", 0, p) and p.elixirs == 1, "bought an Elixir")
	check(Shop.status("apolune_items", 0, p) == "owned", "you can carry only one")
	check(int(GameState.data.elixirs) == 1, "the Elixir is saved")
	p.take_damage(p.max_hp + 50)
	check(not p.dead and p.hp == p.max_hp and p.elixirs == 0, "a fatal hit drinks the Elixir and revives you (hp %d)" % p.hp)
	check(p.invulnerable, "with a moment of safety")
	Feel.reset()
	await frames(150)
	p.take_damage(p.max_hp + 50)
	check(p.dead, "without an Elixir, a fatal hit kills")


func test_apolune_folk_return_with_the_spring() -> void:
	GameState.new_game()
	var before := Room.from_file("res://levels/trunk/apolune.room")
	arena.add_child(before)
	var ids := func(room: Room) -> Array:
		var out := []
		for c in room.get_children():
			if c is Npc:
				out.append((c as Npc).npc_id)
		out.sort()
		return out
	var b: Array = ids.call(before)
	check(b == ["apolune_miner", "apolune_widow", "guru"], "before the spring: the Guru, a dwarf and one townswoman (%s)" % [b])
	GameState.set_flag("spring:trunk")
	var after := Room.from_file("res://levels/trunk/apolune.room")
	arena.add_child(after)
	var a: Array = ids.call(after)
	check(a == ["apolune_armorer", "apolune_grocer", "apolune_miner", "apolune_widow_glad", "guru"], "after: the shops reopen (%s)" % [a])
	var lit := false
	for c in after.get_children():
		if c is HouseFront:
			lit = (c as HouseFront).lit()
	check(lit, "and the windows light up")
	GameState.new_game()
