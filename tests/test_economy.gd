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


func test_card_doors_take_only_their_own_key() -> void:
	# A `lock:` line turns a J into a Queen door; a `chest:` line sets one chest's gold.
	var rooms := _town({Vector2i(12, 19): "J", Vector2i(14, 19): "$"}, ["lock: 12, 19, queen", "chest: 14, 19, 900"])
	var w := make_world(rooms, "test/town", cell_feet(9, 19))
	var p := w.player
	var door := _find(w.room, KeyDoor) as KeyDoor
	check(door != null and door.kind == "queen", "the lock line makes it a Queen door")
	check((_find(w.room, Chest) as Chest).value == 900, "the chest line sets that chest's gold")
	await frames(3)
	GameState.add_key("jack")
	GameState.add_key("king")
	Sfx.recent.clear()
	p.input.move_x = 1
	await frames(40)
	check(is_instance_valid(door) and not door.is_queued_for_deletion(), "a Jack or King Key won't open a Queen door")
	check(GameState.key_count("jack") == 1 and GameState.key_count("king") == 1, "and neither is spent")
	# Pass 122: a locked door rattles its latch (not the spell-fail fizzle), once per touch.
	check(Sfx.recent.count("door_locked") == 1 and not Sfx.recent.has("fizzle"), "a locked door rattles once, no fizzle (%s)" % [Sfx.recent])
	Sfx.recent.clear()
	GameState.add_key("queen")
	await frames(30)
	check(not is_instance_valid(door) or door.is_queued_for_deletion(), "the Queen Key opens it")
	check(Sfx.recent.has("key_turn") and not Sfx.recent.has("door"), "the key turns with its own click and chime (%s)" % [Sfx.recent])
	for sound in ["door_locked", "key_turn"]:
		check(ResourceLoader.exists("res://assets/sfx/%s.wav" % sound), "%s is rendered" % sound)
	check(GameState.key_count("queen") == 0 and GameState.key_count("jack") == 1, "only the Queen Key is used up")
	check(MapScreen.key_line() == "Keys: Jack 1, King 1", "the map lists the keys you hold (%s)" % MapScreen.key_line())
	# Every card has its look; an unknown kind falls back to the Jack's.
	for kind in ["jack", "queen", "king", "ace", "joker"]:
		check(KeyDoor.CARDS.has(kind), "%s door has a look" % kind)


func test_the_card_keys_are_sold_and_the_joker_is_found() -> void:
	var rooms := _town({}, ["prop: 12, 19, joker_key"])
	var w := make_world(rooms, "test/town", cell_feet(5, 19))
	var p := w.player
	var prices := {}
	for shop: String in ["eolis_items", "apolune_items", "forepaw_smith", "conflate_items", "daybreak_items"]:
		var stock: Array = GameData.shop(shop).stock
		for i in stock.size():
			var item: String = stock[i].item
			if item.ends_with("_key"):
				prices[item] = int(stock[i].price)
				if item != "jack_key":
					p.gold = 5000
					check(Shop.buy(shop, i, p) and GameState.key_count(item.trim_suffix("_key")) == 1, "%s sells the %s" % [shop, item])
	check(prices.get("queen_key") == 400 and prices.get("king_key") == 900 and prices.get("ace_key") == 1800, "Queen 400, King 900, Ace 1,800 (bible 10.1): %s" % prices)
	check(not prices.has("joker_key"), "no one sells the Joker Key")
	# The Joker Key lies in the Drowned Market, once.
	var market := Room.parse(FileAccess.get_file_as_string("res://levels/dartmoor/drowned_market.room"))
	check("49, 12, joker_key" in market.lists.get("prop", []), "the Joker Key lies in the Drowned Market")
	var key := _find(w.room, ItemPickup) as ItemPickup
	check(key != null and key.kind == "joker_key", "the prop lays a Joker Key")
	check(GameState.key_count("joker") == 0, "none held yet")
	p.input.move_x = 1
	await frames(60)
	check(GameState.key_count("joker") == 1, "touching it gives the Joker Key")
	w.texts["test/town"] = rooms["test/town"]
	w._enter("test/town")
	check(_find(w.room, ItemPickup) == null, "it never comes back")


func test_every_card_door_guards_a_vault() -> void:
	# The four card vaults (bible 3, Key doors): each lock names a J, and a chest waits behind it.
	var vaults := {"mist/feather_hollow": "queen", "branches/north_bough": "king", "daybreak/spire_stair": "ace", "dartmoor/meteor_rise": "joker"}
	for room: String in vaults:
		var parsed := Room.parse(FileAccess.get_file_as_string("res://levels/%s.room" % room))
		var locks: Array = parsed.lists.get("lock", [])
		check(locks.size() == 1, "%s has one lock" % room)
		var l: PackedStringArray = locks[0].split(",")
		var x := int(l[0])
		var y := int(l[1])
		var grid: Array[String] = parsed.grid
		check(grid[y][x] == "J" and l[2].strip_edges() == vaults[room], "%s: a %s door at %d,%d" % [room, vaults[room], x, y])
		var inside := false
		for cx in range(1, x):
			inside = inside or grid[y][cx] == "$"
		check(inside, "%s: a chest behind it" % room)
		check(grid[y - 3].substr(1, x).count("#") == x, "%s: a roof over the vault, so the door is the only way in" % room)


func test_the_battle_helmet_is_a_secret_worth_a_mask() -> void:
	# Bible 5.2: a helmet in its own slot (pass 185), found, not bought.
	var rooms := _town({}, ["prop: 12, 19, battle_helmet"])
	var w := make_world(rooms, "test/town", cell_feet(5, 19))
	var p := w.player
	await frames(3)
	var hp0 := p.max_hp
	GameState.data.equipment.shield = "magic_shield"
	GameState.data.equipment.armor = "battle_suit"
	GameState.refresh_stats(p)
	var def0 := p.defense
	var helm := _find(w.room, ItemPickup) as ItemPickup
	check(helm != null and helm.kind == "battle_helmet", "the prop lays the Battle Helmet")
	p.input.move_x = 1
	await frames(60)
	check(GameState.data.equipment.helmet == "battle_helmet", "touching it puts it on, in the helmet's own slot")
	check(GameState.data.equipment.shield == "magic_shield" and p.has_shield and p.reflects, "and the Magic Shield stays in hand")
	check(p.max_hp == hp0 + 20 and p.hp == p.max_hp, "one more mask, filled (%d -> %d)" % [hp0, p.max_hp])
	check(is_equal_approx(def0, 0.6) and is_equal_approx(p.defense, 0.64), "10%% less on top of the Battle Suit's 60%%: 64%% (%.2f)" % p.defense)
	GameState.data.equipment.armor = ""
	GameState.refresh_stats(p)
	check(is_equal_approx(p.defense, 0.1), "10%% on its own (%.2f)" % p.defense)
	var shields := 0
	var stock: Array = GameData.shop("daybreak_armor").stock
	p.gold = 9999
	GameState.data.equipment.shield = "small_shield"
	for i in stock.size():
		if GameData.item(stock[i].item).kind == "shield" and int(GameData.item(stock[i].item).tier) > 1:
			shields += 1
			check(Shop.status("daybreak_armor", i, p) != "owned", "%s is still worth buying with the helmet on" % stock[i].item)
	check(shields > 0, "the armorer sells shields")
	check(not GameData.shop("daybreak_armor").stock.any(func(e: Dictionary) -> bool: return e.item == "battle_helmet"), "and no one sells it")
	# It survives a save: the mask comes from the gear, not from the base stat.
	check(int(GameState.data.max_hp) == hp0, "the base health is untouched")
	w.texts["test/town"] = rooms["test/town"]
	w._enter("test/town")
	check(_find(w.room, ItemPickup) == null, "it never comes back")
	# Where it lies: a hidden pocket at the meteor's threshold, behind fake wall.
	var t := Room.parse(FileAccess.get_file_as_string("res://levels/zenis/threshold.room"))
	check("2, 19, battle_helmet" in t.lists.get("prop", []), "it lies in the Threshold")
	var hidden := false
	for spec: String in t.lists.get("secret", []):
		var r := spec.split(",")
		hidden = hidden or (int(r[0]) <= 2 and int(r[2]) >= 2 and int(r[1]) <= 19 and int(r[3]) >= 19)
	check(hidden, "behind a secret wall")


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


## The Act II tier of each branch (design bible 9): each needs the node before it.
func test_act_two_skills_chain_and_apply() -> void:
	var w := make_world(_town(), "test/town")
	var p := w.player
	GameState.data.skill_points = 20
	check(Skills.status("rising_cut") == "locked" and Skills.status("deluge_pierce") == "locked"
		and Skills.status("quick_draught") == "locked", "the new nodes wait on the old ones")
	for id: String in ["keen_edge", "fourth_strike", "rising_cut", "mattock_mastery", "clear_mind", "siphon",
			"deluge_pierce", "deep_pockets", "gold_sense", "quick_draught", "second_stride"]:
		check(Skills.learn(id, p), "learned " + id)
	check(p.rising_cut and p.spell_pierce, "Rising Cut and Deluge Pierce switch on")
	check(is_equal_approx(p.down_strike_mult, 1.5), "Mattock Mastery: the down strike hits 50% harder")
	check(is_equal_approx(p.drink_mult, 0.6), "Quick Draught: drinking takes 60% as long")
	check(p.bonus_air_dashes == 1, "Second Stride: one more air dash")
	check(int(GameState.data.skill_points) == 20 - 13, "the eleven nodes cost 13 points")
	p.gold = 1000
	check(Skills.respec(p) and not p.rising_cut and p.bonus_air_dashes == 0, "a respec takes them all back")


func test_quick_draught_drinks_faster() -> void:
	var w := make_world(_town(), "test/town")
	var p := w.player
	GameState.data.skill_points = 3
	for id: String in ["deep_pockets", "gold_sense", "quick_draught"]:
		Skills.learn(id, p)
	await frames(6)
	p.hp = 1
	p.input.heal_pressed = true
	await frames(1)
	var n := 0
	while p.is_drinking and n < 120:
		await frames(1)
		n += 1
	var expected := p.combat.drink_time * 0.6 * 60.0
	check(p.hp > 1 and absf(n - expected) <= 2.0, "healed after %d frames (want about %d)" % [n, roundi(expected)])


func test_second_stride_gives_two_air_dashes() -> void:
	var w := make_world(_town(), "test/town")
	var p := w.player
	p.abilities["stride"] = true
	GameState.data.skill_points = 5
	for id: String in ["deep_pockets", "gold_sense", "quick_draught", "second_stride"]:
		Skills.learn(id, p)
	p.teleport(cell_feet(12, 6))
	await frames(2)
	var dashes := 0
	for i in 3:
		p.input.dash_pressed = true
		await frames(1)
		if p.is_dashing:
			dashes += 1
		# Past the dash and its cooldown, so each press stands alone.
		await frames(int((p.tuning.dash_time + p.tuning.ground_dash_cooldown) * 60.0) + 2)
	check(dashes == 2, "two air dashes, then no more (%d)" % dashes)
	# Landing refills both.
	var n := 0
	while not p.is_on_floor() and n < 240:
		await frames(1)
		n += 1
	await frames(1)
	check(p.air_dash_charges == 2, "landing refills both charges (%d)" % p.air_dash_charges)


func test_rising_cut_launches_small_foes_only() -> void:
	var w := make_world(_town({Vector2i(20, 19): "M", Vector2i(30, 19): "I"}), "test/town", cell_feet(8, 19))
	var p := w.player
	await frames(6)
	var m: Monodron = _find(w.room, Monodron)
	var dwarf: IronDwarf = _find(w.room, IronDwarf)
	m.hp = 999
	var nudge := await _rise_after_up_slash(p, m)
	check(nudge < 30.0, "without Rising Cut an up-slash only nudges it (%.0f px)" % nudge)
	await frames(40)
	GameState.data.skill_points = 4
	for id: String in ["keen_edge", "fourth_strike", "rising_cut"]:
		Skills.learn(id, p)
	var rise := await _rise_after_up_slash(p, m)
	check(rise > 30.0, "Rising Cut throws a Monodron up (%.0f px)" % rise)
	check(not dwarf.launch(), "an Iron Dwarf is too heavy to lift")
	var spitter := SapSpitter.new()
	check(not spitter.launch(), "a rooted Sap Spitter stays put")
	spitter.free()


## Holds the foe just over the player's head, up-slashes, and returns how far
## above that spot it flew.
func _rise_after_up_slash(p: Player, foe: Enemy) -> float:
	foe.global_position = p.global_position + Vector2(0, -Player.BODY_SIZE.y - 6)
	foe.velocity = Vector2.ZERO
	var y0 := foe.global_position.y
	p.input.up = true
	p.input.attack_pressed = true
	var top := y0
	for i in 30:
		await frames(1)
		top = minf(top, foe.global_position.y)
	p.input.up = false
	return y0 - top


func test_mattock_mastery_hits_harder_downward() -> void:
	var w := make_world(_town(), "test/town")
	var p := w.player
	p.abilities["mattock"] = true
	GameState.data.skill_points = 5
	for id: String in ["keen_edge", "fourth_strike", "rising_cut", "mattock_mastery"]:
		Skills.learn(id, p)
	p.teleport(cell_feet(12, 10))
	await frames(2)
	p.input.down = true
	p.input.attack_pressed = true
	await frames(1)
	p.input.down = false
	check(p.attack_kind == "down", "a downward strike in the air")
	check(p._swing_damage == roundi(p.slash_damage * 1.1 * 1.5), "Keen Edge and Mattock Mastery stack (%d)" % p._swing_damage)


func test_deluge_pierce_strikes_every_foe_in_line() -> void:
	var w := make_world(_town({Vector2i(14, 19): "E", Vector2i(18, 19): "E"}), "test/town", cell_feet(8, 19))
	var p := w.player
	p.abilities["deluge"] = true
	await frames(6)
	var dummies: Array[TrainingDummy] = []
	for c in w.room.get_children():
		if c is TrainingDummy:
			dummies.append(c)
	var cast := func() -> void:
		for d in dummies:
			d.hp = TrainingDummy.HP
		p.mp = p.max_mp
		p.facing = 1
		p.input.spell_pressed = true
		await frames(40)
	await cast.call()
	var hurt := dummies.filter(func(d: TrainingDummy) -> bool: return d.hp < TrainingDummy.HP).size()
	check(hurt == 1, "a plain bolt stops at the first dummy (%d hit)" % hurt)
	GameState.data.skill_points = 3
	for id: String in ["clear_mind", "siphon", "deluge_pierce"]:
		Skills.learn(id, p)
	await cast.call()
	hurt = dummies.filter(func(d: TrainingDummy) -> bool: return d.hp < TrainingDummy.HP).size()
	check(hurt == 2, "a piercing bolt strikes both (%d hit)" % hurt)


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



## Bible 7 (pass 147): any foe may rarely leave one of the original's rare
## items. The War Glove (the original's Glove) makes every blade hit land half
## again as hard for 15 s; an Ointment goes in the pouch, or straight on when
## the pouch is full.
func test_rare_drops_a_war_glove_and_an_ointment() -> void:
	var w := make_world(_town({Vector2i(12, 19): "M", Vector2i(16, 19): "M", Vector2i(24, 19): "D"}), "test/town", cell_feet(8, 19))
	var p := w.player
	await frames(3)
	check(Drop.rare_chance == 0.0, "the runner keeps rare drops off")
	check_near(p.combat.war_glove_mult, 1.5, 0.0001, "the glove multiplies blade hits by 1.5")
	check_near(p.combat.war_glove_time, 15.0, 0.0001, "for 15 s")
	# Rolled with the real odds, about one kill in forty leaves a rare item, and
	# the glove is the commoner of the two.
	Drop.rare_chance = 0.025
	seed(147)
	var kinds := {}
	for i in 4000:
		var d := Drop.roll(w.room, cell_feet(30, 10))
		if d != null:
			kinds[d.kind] = int(kinds.get(d.kind, 0)) + 1
			d.free()
	var rare := int(kinds.get("glove", 0)) + int(kinds.get("ointment", 0))
	check(kinds.size() == 2 and rare > 60 and rare < 140, "about 1 kill in 40 leaves a rare item (%s)" % [kinds])
	check(int(kinds.get("glove", 0)) > int(kinds.get("ointment", 0)), "the glove more often than the ointment")
	Drop.rare_chance = 0.0
	# The glove: a Monodron dies to it, and the next blows hit harder.
	var monos: Array = w.room.get_children().filter(func(c: Node) -> bool: return c is Monodron)
	var glove := Drop.new()
	glove.kind = "glove"
	w.room.add_child(glove)
	glove.global_position = p.global_position + Vector2(0, -4)
	var plain := p.blade_mult()
	await frames(25)
	check(not is_instance_valid(glove) and p.glove_left > 14.0, "walking over the glove puts it on (%.1f s)" % p.glove_left)
	check_near(p.blade_mult(), plain * 1.5, 0.0001, "and blade hits land half again as hard")
	# A real swing: the next slash at a Monodron carries the glove.
	var mono: Monodron = monos[0]
	mono.hp = 999
	p.teleport(mono.global_position + Vector2(-22, 0))
	p.facing = 1
	await frames(2)
	p.input.attack_pressed = true
	await frames(8)
	check(999 - mono.hp == roundi(p.slash_damage * plain * 1.5), "a slash deals %d with it (the short sword's %d)" % [999 - mono.hp, p.slash_damage])
	await frames(roundi(15.0 * 60.0) + 2)
	check(p.glove_left == 0.0 and is_equal_approx(p.blade_mult(), plain), "after 15 s it wears off")
	# Dying takes a glove off.
	p.put_on_glove()
	p._invuln_timer = 0.0
	p.take_damage(9999)
	check(p.dead, "(a killing blow)")
	var n := 0
	while p.dead and n < 300:
		await frames(1)
		n += 1
	await frames(5)
	check(not p.dead and p.glove_left == 0.0, "and death takes it off")
	for f in w.room.get_children():
		if f is Enemy:
			f.queue_free()
	# The ointment: into the pouch, or straight on when the pouch is full.
	p.ointments = 0
	for i in 2:
		var jar := Drop.new()
		jar.kind = "ointment"
		w.room.add_child(jar)
		jar.global_position = p.global_position + Vector2(0, -4)
		await frames(25)
	check(p.ointments == 2 and p.ointment_left == 0.0, "an ointment goes in the pouch (%d)" % p.ointments)
	p.ointments = Shop.OINTMENT_MAX
	var full := Drop.new()
	full.kind = "ointment"
	w.room.add_child(full)
	full.global_position = p.global_position + Vector2(0, -4)
	await frames(25)
	check(p.ointments == Shop.OINTMENT_MAX and p.ointment_left > 9.0, "with the pouch full it goes straight on (%.1f s)" % p.ointment_left)


func test_tower_kills_can_leave_poison() -> void:
	var w := make_world(_town({Vector2i(12, 19): "M"}), "test/town")
	var p := w.player
	await frames(3)
	Drop.poison_chance = 1.0
	check(Drop.roll(w.room, cell_feet(30, 19)) == null, "enemies without poison_drops never leave poison")
	var mono: Monodron = w.room.get_children().filter(func(c: Node) -> bool: return c is Monodron)[0]
	mono.poison_drops = true
	mono.take_hit(999, Vector2.RIGHT)
	Drop.poison_chance = 0.0
	var vial: Drop = _find(w.room, Drop)
	check(vial != null and vial.kind == "poison", "a Tower enemy can leave a poison flask")
	var dwarf := IronDwarf.new()
	var bat := GearBat.new()
	check(dwarf.poison_drops and bat.poison_drops, "Iron Dwarves and Gear Bats leave poison")
	dwarf.free()
	bat.free()
	await frames(40)
	p.hp = 40
	p.teleport(vial.global_position)
	await frames(3)
	check(not is_instance_valid(vial) and p.poison_left > 0.0, "walking over it poisons you")
	await frames(roundi(Player.POISON_TICK * 60.0 * 3.0) + 2)
	check(p.hp == 40 - 3 * Player.POISON_DAMAGE, "poison saps %d health a second (%d)" % [Player.POISON_DAMAGE, p.hp])
	p.hp = 2
	await frames(roundi(Player.POISON_TICK * 60.0 * 2.0) + 2)
	check(p.hp == 1 and not p.dead, "but never takes the last point (%d)" % p.hp)
	await frames(roundi(Player.POISON_TIME * 60.0))
	check(p.poison_left == 0.0, "and wears off")


func test_bread_shrines_and_ointment_beat_poison() -> void:
	var w := make_world(_town(), "test/town")
	var p := w.player
	await frames(3)
	check(p.poison() and p.poison_left > 0.0, "poisoned")
	Drop.bread_chance = 1.0
	var bread := Drop.roll(w.room, p.global_position)
	Drop.bread_chance = 0.0
	await frames(40)
	check(not is_instance_valid(bread) and p.poison_left == 0.0, "bread settles the stomach")
	p.poison()
	p.restore()
	check(p.poison_left == 0.0, "resting at a shrine or the Guru cures it")
	p.ointments = 1
	p.use_ointment()
	check(not p.poison(), "an Ointment keeps poison off")



func test_the_guru_names_your_title_once() -> void:
	var w := make_world(_town({}, ["npc: 8, 19, guru"]), "test/town", cell_feet(9, 19))
	var p := w.player
	await frames(2)
	var guru: Npc = _find(w.room, Npc)
	var said := []
	var hear := func(who: String, pages: Array) -> void: said.append([who, pages])
	GameState.dialog_requested.connect(hear)
	guru.interact(p)
	check(said.is_empty(), "a Novice gets no ceremony")
	GameState.add_xp(100)
	check(GameState.rank_name() == "Battler" and GameState.unnamed_title() == "Battler", "ranks rise in the field, unnamed (%s)" % GameState.unnamed_title())
	guru.interact(p)
	check(said.size() == 1 and String(said[0][1][1]).contains("BATTLER"), "the Guru names you by your title: %s" % [said])
	check(int(GameState.data.named_rank) == int(GameState.data.rank) and GameState.unnamed_title() == "", "and it is yours from then on")
	guru.interact(p)
	check(said.size() == 1, "only once per title")
	check(Npc.title_lines(14, "Paladin")[0] != Npc.title_lines(1, "Aspirant")[0], "higher ranks hear grander words")
	GameState.dialog_requested.disconnect(hear)

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
		if npc.role in ["talk", "king", "physician"] and npc.get("lines", []).is_empty():
			bad.append("%s has nothing to say" % id)
		if npc.role == "physician" and npc.get("lines_treated", []).is_empty():
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
	check(Shop.status("apolune_armor", 1, p) == "owned", "the Large Shield shows as owned")
	check(Shop.status("eolis_arms", 2, p) != "owned", "a shield you never had stays for sale (pass 186)")


func test_the_magic_shield_is_sold_in_daybreak_and_reflects() -> void:
	var w := make_world(_town(), "test/town")
	var p := w.player
	await frames(3)
	GameState.data.equipment.shield = "large_shield"
	GameState.refresh_stats(p)
	check(not p.reflects, "the Large Shield doesn't reflect")
	var stock: Array = GameData.shop("daybreak_armor").stock
	check(stock[1].item == "magic_shield" and int(stock[1].price) == 3600, "Calder's armory sells the Magic Shield for 3,600 g")
	p.gold = 3600
	check(Shop.buy("daybreak_armor", 1, p), "bought the Magic Shield")
	check(p.reflects and p.has_shield, "it reflects small shots on a parry")
	check_near(p.guard_reduction, 0.7, 0.001, "and guards like the Large Shield")
	check(Shop.status("daybreak_armor", 1, p) == "owned", "it shows as owned")
	check(Shop.status("apolune_armor", 1, p) != "owned", "a Large Shield you never had stays for sale (pass 186)")


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


# --- Forepaw freed ---------------------------------------------------------------

## Pass 175: Forepaw keeps the original's hospital and a larder. The physician
## mends health, magic and poison for nothing, but neither saves nor refills
## the flask (that is the Guru's rest); with nothing to mend he only talks.
func test_forepaws_physician_mends_you_and_its_larder_sells() -> void:
	var w := make_world(_town({}, ["npc: 8, 19, forepaw_physician"]), "test/town", cell_feet(8, 19))
	var p := w.player
	var said := []
	var listener := func(who: String, pages: Array) -> void: said.append(pages)
	GameState.dialog_requested.connect(listener)
	await frames(3)
	var gold := p.gold
	p.input.up_pressed = true
	await frames(2)
	check(said.size() == 1 and said[0] == GameData.npc("forepaw_physician").lines, "whole and well, he only talks")
	p.hp = 10
	p.mp = 0.0
	p.poison()
	p.flask_charges = 0
	GameState.data.save_room = ""
	p.input.up_pressed = true
	await frames(2)
	GameState.dialog_requested.disconnect(listener)
	check(p.hp == p.max_hp and is_equal_approx(p.mp, p.max_mp) and p.poison_left <= 0.0, "hurt, drained and poisoned: he mends all three (hp %d)" % p.hp)
	check(said.size() == 2 and said[1] == GameData.npc("forepaw_physician").lines_treated, "and says what he did")
	check(p.gold == gold and p.flask_charges == 0 and String(GameState.data.save_room) == "", "for no gold, with no save and no flask refill")
	var room := Room.from_file("res://levels/tower/forepaw.room")
	arena.add_child(room)
	var ids := room.get_children().filter(func(c: Node) -> bool: return c is Npc).map(func(c: Npc) -> String: return c.npc_id)
	check(ids.has("forepaw_physician") and ids.has("forepaw_grocer"), "both keep house in Forepaw (%s)" % [ids])
	room.queue_free()
	var stock: Array = GameData.shop(GameData.npc("forepaw_grocer").shop).stock
	check(stock.map(func(e: Dictionary) -> String: return e.item) == ["elixir", "queen_key"], "the Larder sells an Elixir and the Queen Key")


func test_the_forepaw_smith_tempers_a_blade_twice() -> void:
	var w := make_world(_town(), "test/town")
	var p := w.player
	p.gold = 5000
	var base := p.slash_damage
	var heavy := p.heavy_damage
	check(Shop.status("forepaw_smith", 1, p) == "locked", "the second temper waits for the first")
	check(Shop.buy("forepaw_smith", 0, p), "bought Temper Blade I")
	check(p.slash_damage == roundi(base * 1.15) and p.heavy_damage == roundi(heavy * 1.15),
		"+15%% damage (%d -> %d)" % [base, p.slash_damage])
	check(Shop.status("forepaw_smith", 0, p) == "owned", "one first temper per blade")
	GameState.data.meteor_shards = 1
	check(Shop.buy("forepaw_smith", 1, p), "bought Temper Blade II")
	check(p.slash_damage == roundi(base * 1.3), "+30%% in all (%d)" % p.slash_damage)
	check(Shop.status("forepaw_smith", 1, p) == "owned", "and that is the most a blade takes")
	check(Shop.buy("eolis_arms", 0, p), "a new blade")
	check(p.slash_damage == 11 and Shop.status("forepaw_smith", 0, p) == "", "starts untempered")


func test_the_second_temper_costs_a_meteor_shard() -> void:
	var w := make_world(_town(), "test/town")
	var p := w.player
	p.gold = 5000
	check(Shop.buy("forepaw_smith", 0, p), "Temper Blade I needs gold alone")
	check(Shop.status("forepaw_smith", 1, p) == "shards", "Temper Blade II waits for a Meteor Shard")
	check(not Shop.buy("forepaw_smith", 1, p) and p.gold == 4300, "and can't be bought without one")
	var shard := ItemPickup.new()
	shard.kind = ItemPickup.KIND_BY_CHAR["("]
	w.room.add_child(shard)
	shard.grant(p)
	check(int(GameState.data.meteor_shards) == 1, "a Meteor Shard picked up is carried")
	check(Shop.status("forepaw_smith", 1, p) == "", "now the smith can fold it in")
	check(Shop.buy("forepaw_smith", 1, p), "bought Temper Blade II")
	check(int(GameState.data.meteor_shards) == 0 and p.gold == 2700, "it spends the shard and the gold")
	check(GameState.temper_level("short_sword") == 2, "the short sword is tempered twice")
	check(Shop.buy("eolis_arms", 0, p) and Shop.buy("forepaw_smith", 0, p), "a new blade, tempered once")
	check(Shop.status("forepaw_smith", 1, p) == "shards", "each blade's second temper takes its own shard")


func test_the_world_holds_a_meteor_shard_for_every_blade() -> void:
	var found := 0
	var zones := {}
	for zone in DirAccess.get_directories_at("res://levels"):
		for f in DirAccess.get_files_at("res://levels/" + zone):
			if not f.ends_with(".room"):
				continue
			var text := FileAccess.get_file_as_string("res://levels/%s/%s" % [zone, f])
			var n := text.substr(text.find("\n---\n") + 5).count("(")
			found += n
			if n > 0:
				zones[zone] = true
	var blades := 0
	for id: String in GameData.table("items"):
		if String(GameData.item(id).get("kind", "")) == "blade":
			blades += 1
	check(found >= blades, "%d Meteor Shards in the world for %d blades" % [found, blades])
	check(zones.has("tower"), "one lies in the Tower, near the smith who uses them")
	check(zones.size() >= 4, "they are spread over %d zones" % zones.size())


func test_the_forepaw_lift_runs_once_zoradohna_falls() -> void:
	var w := make_world({}, "tower/forepaw")
	await frames(2)
	var cage: LiftCage = _find(w.room, LiftCage)
	check(cage != null and cage.destination()[0] == "tower/foot", "Forepaw has a lift down to the Tower Foot")
	cage.interact(w.player)
	await frames(3)
	check(w.room.id == "tower/forepaw", "it hangs still while Zoradohna holds the city")
	GameState.set_flag("boss:zoradohna")
	cage.interact(w.player)
	await frames(3)
	check(w.room.id == "tower/foot", "once freed, it carries you down")
	check(not w.room.is_solid_at(w.player.global_position + Vector2(0, -8)), "onto open floor")
	var back: LiftCage = _find(w.room, LiftCage)
	check(back != null and absf(back.global_position.x - w.player.global_position.x) < 24.0, "beside the cage at the bottom")
	back.interact(w.player)
	await frames(3)
	check(w.room.id == "tower/forepaw", "and back up again")


func test_the_lift_runs_down_the_trunk_to_eolis() -> void:
	# Bible 3: the elevator shortcut back to Eolis. The cage offers its other stops.
	var w := make_world({}, "eolis/east_gate")
	await frames(2)
	var gate: LiftCage = _find(w.room, LiftCage)
	check(gate != null and gate.destination()[0] == "tower/foot", "the East Gate of Eolis has a lift cage up the trunk")
	gate.interact(w.player)
	await frames(3)
	check(w.room.id == "eolis/east_gate", "it hangs still until Forepaw is free")
	GameState.set_flag("boss:zoradohna")
	var menu := ListMenu.new()
	arena.add_child(menu)
	gate.interact(w.player)
	await frames(1)
	var labels := menu.rows.map(func(r: Dictionary) -> String: return r.label)
	check(menu.title == "Forepaw Lift" and labels == ["Forepaw", "Tower Foot"], "it offers the other stops (%s)" % [labels])
	menu.cursor = 0
	menu.confirm()
	await frames(3)
	check(w.room.id == "tower/forepaw", "and carries you up to Forepaw")
	check(not w.room.is_solid_at(w.player.global_position + Vector2(0, -8)), "onto open floor")
	var top: LiftCage = _find(w.room, LiftCage)
	top.interact(w.player)
	await frames(1)
	menu.cursor = menu.rows.map(func(r: Dictionary) -> String: return r.label).find("Eolis, East Gate")
	menu.confirm()
	await frames(3)
	check(w.room.id == "eolis/east_gate", "and all the way home again")
	check(not w.room.is_solid_at(w.player.global_position + Vector2(0, -8)), "beside the cage in Eolis")
	menu.queue_free()


func test_the_mantra_path_joins_the_gurus_after_a_spring() -> void:
	var w := make_world({}, "tower/forepaw")
	await frames(2)
	var menu := ListMenu.new()
	arena.add_child(menu)
	GameState.meet_guru("trunk/apolune", Vector2(12 * Room.TILE + 8, 20 * Room.TILE))
	var guru: Npc = null
	for n in w.room.get_children():
		if n is Npc and (n as Npc).npc_id == "guru":
			guru = n
	guru.interact(w.player)
	await frames(1)
	check(GameState.data.gurus.has("tower/forepaw"), "speaking to a Guru marks a stop on the path")
	check(menu.title == "Guru" and menu.rows[3].label == "Mantra Path", "the Guru offers the Mantra Path")
	check(not menu.rows[3].enabled, "but it stays dry until a spring flows")
	menu.close()
	GameState.set_flag("spring:trunk")
	guru.interact(w.player)
	await frames(1)
	check(menu.rows[3].enabled, "a restored spring opens it")
	menu.cursor = 3
	menu.confirm()
	check(menu.title == "Mantra Path" and menu.rows.size() == 1 and menu.rows[0].label == "Apolune", "it lists the other Gurus met")
	menu.cursor = 0
	menu.confirm()
	await frames(3)
	check(w.room.id == "trunk/apolune", "and walks you to one")
	check(not w.room.is_solid_at(w.player.global_position + Vector2(0, -8)), "onto open floor")
	check(absf(w.player.global_position.x - (12 * Room.TILE + 8 + Menus.MANTRA_STEP)) < 4.0, "a step from the Guru")
	menu.queue_free()


func test_the_forepaw_forge_rings_and_throws_sparks() -> void:
	var w := make_world({}, "tower/forepaw")
	await frames(2)
	var forge: Forge = _find(w.room, Forge)
	check(forge != null, "Forepaw has a forge beside the smith")
	var before := forge.strikes
	await frames(int(Forge.STRIKE_EVERY * 60.0) + 5)
	check(forge.strikes > before, "the smith's hammer rings on the anvil")
	forge._next_strike = 10.0
	forge.strike()
	check(not forge.sparks.is_empty(), "each strike throws sparks")
	forge._process(0.6)
	check(forge.sparks.is_empty(), "and the sparks die away")


func test_the_great_winch_turns_once_forepaw_is_free() -> void:
	var w := make_world({}, "tower/winch_hall")
	await frames(2)
	var winch: Winch = _find(w.room, Winch)
	check(winch != null, "Winch Hall has its great winch")
	await frames(30)
	check(winch.angle == 0.0, "it stands still while Zoradohna holds Forepaw")
	GameState.set_flag("boss:zoradohna")
	await frames(30)
	check(winch.angle > 0.0, "and turns once the dwarves are free")


func test_the_flue_damper_opens_once_zoradohna_falls() -> void:
	var w := make_world({}, "tower/foot")
	await frames(2)
	var shut := w.room.get_children().filter(func(n: Node) -> bool: return n is FlueDamper)
	check(shut.size() == 3, "the Tower Foot's ceiling holds a three-tile damper (%d)" % shut.size())
	check(shut.all(func(d: FlueDamper) -> bool: return not d.open), "it is shut while Zoradohna holds Forepaw")
	GameState.set_flag("boss:zoradohna")
	w.travel("tower/winch_hall", cell_feet(5, 19))
	await frames(4)
	w.travel("tower/foot", cell_feet(20, 41))
	await frames(4)
	var opened := w.room.get_children().filter(func(n: Node) -> bool: return n is FlueDamper and not n.is_queued_for_deletion())
	check(opened.size() == 3 and opened.all(func(d: FlueDamper) -> bool: return d.open), "and stands open once the winch turns")


func test_the_smelter_crucible_pours() -> void:
	var w := make_world({}, "tower/smelter")
	await frames(2)
	var c: Crucible = _find(w.room, Crucible)
	check(c != null, "the Smelter has its crucible")
	await frames(40)
	check(not c.sparks.is_empty(), "the pour throws sparks")
	check(c.lip().y < -100.0, "from a pot hung high above the walkway")


func test_a_cartographer_chart_outlines_unseen_rooms() -> void:
	var w := make_world({}, "eolis/market")
	await frames(2)
	var p := w.player
	p.gold = 1000
	check(MapScreen.shown("trunk/entrance", w.catalog["trunk/entrance"], w.room.id) == "", "unseen rooms are hidden at first")
	var index := -1
	var stock: Array = GameData.shop("eolis_charts").stock
	for i in stock.size():
		if stock[i].item == "chart_trunk":
			index = i
	check(Shop.buy("eolis_charts", index, p), "the Cartographer sells the Trunk chart")
	check(Shop.status("eolis_charts", index, p) == "owned", "once")
	check(MapScreen.shown("trunk/entrance", w.catalog["trunk/entrance"], w.room.id) == "charted", "and its rooms show, dimmed")
	check(MapScreen.shown("tower/foot", w.catalog["tower/foot"], w.room.id) == "", "other zones stay hidden")
	GameState.visit("trunk/entrance")
	check(MapScreen.shown("trunk/entrance", w.catalog["trunk/entrance"], w.room.id) == "visited", "a visit shows it in full")


func test_map_pins_drop_and_lift_where_you_stand() -> void:
	var w := make_world({}, "eolis/market")
	await frames(2)
	var map := MapScreen.new()
	map.world = w
	arena.add_child(map)
	Sfx.recent.clear()
	check(map.pin() == "placed" and GameState.data.pins.size() == 1, "Jump on the map drops a pin where you stand")
	check(map.pin() == "removed" and GameState.data.pins.is_empty(), "and again lifts it")
	check(Sfx.recent == ["pin", "pin_lift"], "a pin goes in with a tick and comes out with its own (%s)" % [Sfx.recent])
	for i in GameState.MAX_PINS:
		GameState.toggle_pin("eolis/market", Vector2(i * 100, 0))
	check(GameState.toggle_pin("eolis/market", Vector2(5000, 0)) == "full", "pins are limited to %d" % GameState.MAX_PINS)
	Sfx.recent.clear()
	check(map.pin() == "full" and Sfx.recent == ["fizzle"], "a full map fizzles")
	# The parchment (pass 128): the map unrolls and folds with its own sounds.
	Sfx.recent.clear()
	map.toggle()
	check(map.is_open and Sfx.recent == ["map_open"], "opening the map unrolls it (%s)" % [Sfx.recent])
	map.toggle()
	check(not map.is_open and Sfx.recent == ["map_open", "map_close"], "closing folds it (%s)" % [Sfx.recent])
	map.queue_free()


## Conflate (pass 50): the elves' town on the leaf road has a Guru, a grocer
## and a skywatcher who charts the Mist and the Branches.
func test_conflate_has_a_guru_a_grocer_and_a_skywatcher() -> void:
	var w := make_world({}, "branches/conflate")
	await frames(2)
	var ids: Array = []
	for c in w.room.get_children():
		if c is Npc:
			ids.append((c as Npc).npc_id)
	for id: String in ["guru", "conflate_grocer", "conflate_cartographer", "conflate_elder", "conflate_warden", "conflate_weaver"]:
		check(ids.has(id), "%s lives in Conflate" % id)
		check(Sheet.exists("npc_" + id), "and has a sheet (npc_%s)" % id)
	for i in GameData.shop("conflate_items").stock.size():
		var entry: Dictionary = GameData.shop("conflate_items").stock[i]
		check(GameData.item(entry.item).has("name"), "the grocer's %s is a real item" % entry.item)
	var p := w.player
	p.gold = 2000
	var stock: Array = GameData.shop("conflate_charts").stock
	for i in stock.size():
		check(Shop.buy("conflate_charts", i, p), "the skywatcher sells %s" % stock[i].item)
	check(GameState.has_chart("mist") and GameState.has_chart("branches"), "and both zones are charted")
	check(MapScreen.shown("mist/fog_cut", w.catalog["mist/fog_cut"], w.room.id) == "charted", "the Mist shows, dimmed")
	check(p.gold == 2000 - 500 - 650, "for 1,150 gold (%d left)" % p.gold)


## Victim (pass 145): the original's town in the Mist, west of the Feather
## Hollow. It has a Guru, the key master bible 10.2 puts there, a fogwalker who
## charts the Mist, and two people who remember the drowned miners.
func test_victim_has_a_guru_a_keymaster_and_a_fogwalker() -> void:
	var w := make_world({}, "mist/victim")
	await frames(2)
	var ids: Array = []
	for c in w.room.get_children():
		if c is Npc:
			ids.append((c as Npc).npc_id)
	for id: String in ["guru", "victim_keymaster", "victim_cartographer", "victim_widow", "victim_lamplighter"]:
		check(ids.has(id), "%s lives in Victim" % id)
		check(Sheet.exists("npc_" + id), "and has a sheet (npc_%s)" % id)
	for id: String in ["victim_widow", "victim_lamplighter"]:
		check(GameData.npc(id).lines.size() >= 2 and GameData.npc(id).has("lines_cleared"), "%s has her say, and another once the Tree blooms" % id)
	var keys: Array = GameData.shop("victim_keys").stock
	var prices := {}
	for entry: Dictionary in keys:
		check(GameData.item(entry.item).has("name"), "the key master's %s is a real item" % entry.item)
		prices[entry.item] = int(entry.price)
	check(prices.get("jack_key") == 150 and prices.get("queen_key") == 400, "he cuts Jack (150 g) and Queen (400 g) keys, at bible 10.1's prices")
	var p := w.player
	p.gold = 1000
	check(Shop.buy("victim_keys", keys.find_custom(func(e: Dictionary) -> bool: return e.item == "queen_key"), p), "you can buy a Queen Key")
	check(GameState.key_count("queen") == 1, "and carry it to the Feather Hollow's vault next door")
	check(Shop.buy("victim_charts", 0, p) and GameState.has_chart("mist"), "the fogwalker sells the Mist chart")
	check(p.gold == 1000 - 400 - 500, "for 900 gold in all (%d left)" % p.gold)
	# The Guru is a stop on the Mantra Path like any other.
	var guru: Npc = null
	for c in w.room.get_children():
		if c is Npc and (c as Npc).npc_id == "guru":
			guru = c
	GameState.meet_guru(w.room.id, guru.global_position)
	check(GameState.data.gurus.has("mist/victim"), "and Victim's Guru joins the Mantra Path")


## Mascon (pass 148): the stilt town on the black water, under the Scorched
## Hall. Bible 10.2 puts a spell-scroll shop there: Fire, a zone before Daybreak.
func test_mascon_has_a_guru_a_scribe_and_stores() -> void:
	GameState.set_flag("spring:mist")
	var w := make_world({}, "mist/mascon")
	await frames(2)
	var ids: Array = []
	for c in w.room.get_children():
		if c is Npc:
			ids.append((c as Npc).npc_id)
	for id: String in ["guru", "mascon_scribe", "mascon_grocer", "mascon_ferryman"]:
		check(ids.has(id), "%s lives in Mascon" % id)
		check(Sheet.exists("npc_" + id), "and has a sheet (npc_%s)" % id)
	var teague := GameData.npc("mascon_ferryman")
	check(teague.lines.size() >= 2 and teague.has("lines_cleared"), "the poler has his say, and another once the Tree blooms")
	for entry: Dictionary in GameData.shop("mascon_items").stock:
		check(GameData.item(entry.item).has("name"), "the stores' %s is a real item" % entry.item)
	var p := w.player
	p.gold = 1500
	var scroll: Dictionary = GameData.shop("mascon_scrolls").stock[0]
	check(scroll.item == "fire_scroll" and int(scroll.price) == 1200, "the scribe sells Fire for 1,200 g, as Daybreak's does")
	check(Shop.buy("mascon_scrolls", 0, p) and p.abilities.fire, "and the scroll teaches it")
	check(Shop.status("daybreak_scrolls", 0, p) == "owned", "so Daybreak's scroll shows as owned")
	var guru: Npc = null
	for c in w.room.get_children():
		if c is Npc and (c as Npc).npc_id == "guru":
			guru = c
	GameState.meet_guru(w.room.id, guru.global_position)
	check(GameState.data.gurus.has("mist/mascon"), "and Mascon's Guru joins the Mantra Path")


func test_daybreak_sells_plate_charts_and_the_fire_scroll() -> void:
	# Bible 10.2: Daybreak has a Guru, an armorer, the spell-scroll shop (Fire,
	# 1,200 g), a grocer and a cartographer.
	var w := make_world({}, "daybreak/daybreak")
	await frames(2)
	var ids: Array = []
	for c in w.room.get_children():
		if c is Npc:
			ids.append((c as Npc).npc_id)
	for id: String in ["guru", "daybreak_armorer", "daybreak_scribe", "daybreak_grocer", "daybreak_cartographer", "daybreak_mayor", "daybreak_bellkeeper"]:
		check(ids.has(id), "%s lives in Daybreak" % id)
		check(Sheet.exists("npc_" + id), "and has a sheet (npc_%s)" % id)
	var p := w.player
	p.gold = 6100
	check(not p.abilities.get("fire", false), "the run starts without Fire")
	var scroll: Dictionary = GameData.shop("daybreak_scrolls").stock[0]
	check(scroll.item == "fire_scroll" and int(scroll.price) == 1200, "the scribe sells Fire for 1,200 g")
	check(Shop.buy("daybreak_scrolls", 0, p), "and you can buy it")
	check(p.abilities.fire and GameState.data.abilities.fire, "the scroll teaches Fire for good")
	check(p.equipped_spell == "fire", "with no other spell, Fire goes on the Spell button")
	check(Shop.status("daybreak_scrolls", 0, p) == "owned", "and the scroll shows as owned")
	check(Shop.buy("daybreak_armor", 0, p), "the armorer sells Full Plate")
	check(is_equal_approx(p.defense, 0.45), "which takes 45%% off a hit (%.2f)" % p.defense)
	check(Shop.buy("daybreak_charts", 0, p) and GameState.has_chart("daybreak"), "the bell-ringer sells the Daybreak chart")
	check(p.gold == 6100 - 1200 - 4200 - 700, "for 6,100 gold in all (%d left)" % p.gold)
	# The Spell button's choice is saved with the rest.
	GameState.capture(p)
	check(GameState.data.spell == "fire", "the save remembers the equipped spell")
	p.equipped_spell = "deluge"
	GameState.apply(p)
	check(p.equipped_spell == "fire", "and puts it back on load")


func test_the_final_tier_comes_with_the_spring_of_sky() -> void:
	var w := make_world(_town(), "test/town")
	var p := w.player
	await frames(3)
	p.gold = 10000
	var arms: Array = GameData.shop("eolis_arms").stock
	var blade := -1
	for i in arms.size():
		if arms[i].item == "dwarvish_broad_sword":
			blade = i
	check(blade >= 0 and int(arms[blade].price) == 2800, "Eolis Arms stocks the Dwarvish Broad Sword at 2,800 g")
	check(not Shop.shelf("eolis_arms").has(blade), "but not before the Spring of Sky")
	check(Shop.status("eolis_arms", blade, p) == "hidden" and not Shop.buy("eolis_arms", blade, p), "so it can't be bought")
	var stores: Array = GameData.shop("daybreak_items").stock
	var fruit := stores.size() - 1
	check(stores[fruit].item == "life_fruit" and int(stores[fruit].price) == 2000 and stores[fruit].get("once", false), "Daybreak's grocer keeps one Life Fruit for 2,000 g")
	check(Shop.status("daybreak_items", fruit, p) == "hidden", "off the shelf while the storm lasts")
	GameState.set_flag("spring:sky")
	check(Shop.shelf("eolis_arms").has(blade) and Shop.status("eolis_arms", blade, p) == "", "the sky road opens and the blade comes in")
	check(Shop.buy("eolis_arms", blade, p) and GameState.data.equipment.blade == "dwarvish_broad_sword", "bought the Dwarvish Broad Sword")
	check(p.gold == 7200 and p.reach_bonus == 16.0 and p.arc_bonus == 20.0, "its reach and arc are yours")
	check(Shop.status("eolis_arms", 0, p) == "", "the Long Sword is still for sale: only what you have counts as owned (pass 186)")
	check(Shop.buy("daybreak_items", fruit, p) and Shop.status("daybreak_items", fruit, p) == "sold out", "the fruit is sold once")
	GameState.wear("short_sword", p)
	check(Shop.status("eolis_arms", blade, p) == "owned", "put down, the Broad Sword is still yours")


func test_the_tilte_scroll_is_sold_in_daybreak() -> void:
	var w := make_world(_town(), "test/town")
	var p := w.player
	await frames(3)
	var stock: Array = GameData.shop("daybreak_scrolls").stock
	check(stock[1].item == "tilte_scroll" and int(stock[1].price) == 2500, "the scriptorium sells Tilte for 2,500 g")
	p.gold = 2500
	check(not p.abilities.get("tilte", false), "you start without it")
	check(Shop.buy("daybreak_scrolls", 1, p) and p.abilities.tilte, "bought, it is learned")
	check(Shop.status("daybreak_scrolls", 1, p) == "owned", "and can't be bought twice")
	GameState.data.skills = ["clear_mind", "siphon", "deluge_pierce", "tilte_swarm"]
	GameState.refresh_stats(p)
	check(p.tilte_swarm, "the Tilte Swarm skill reaches the player")


## The Act III tier (pass 100): three more nodes in each branch, each after the
## one before, and a tree that now costs more than the 29 points the game gives.
func test_act_three_skills_chain_and_apply() -> void:
	var w := make_world(_town(), "test/town")
	var p := w.player
	GameState.data.skill_points = 40
	var hp0 := p.max_hp
	for id: String in ["riposte", "thrift", "treasure_sense"]:
		check(Skills.status(id) == "locked", id + " waits on the end of its branch")
	for id: String in ["keen_edge", "fourth_strike", "rising_cut", "mattock_mastery", "riposte", "keener_edge", "bloodletting",
			"clear_mind", "siphon", "deluge_pierce", "tilte_swarm", "thrift", "chain_thunder", "time_thief",
			"deep_pockets", "gold_sense", "quick_draught", "second_stride", "feather_fall", "treasure_sense", "resilience", "last_stand", "second_wind"]:
		check(Skills.learn(id, p), "learned " + id)
	check(p.riposte and p.bloodletting and p.chain_thunder and p.time_thief, "Riposte, Bloodletting, Chain Thunder and Time Thief switch on")
	check(p.last_stand and p.second_wind and GameState.has_skill("treasure_sense"), "Treasure Sense, Last Stand and Second Wind are learned")
	check(is_equal_approx(p.melee_mult, 1.2), "Keener Edge stacks with Keen Edge: +20%% (%.2f)" % p.melee_mult)
	check(is_equal_approx(p.spell_cost_mult, 0.85), "Thrift: spells cost 15% less")
	check(p.max_hp == hp0 + GameState.RESILIENCE_HP, "Resilience: one more mask (%d)" % p.max_hp)
	var total := 0
	for n: Dictionary in Skills.nodes():
		total += int(n.cost)
	check(total > 29, "the tree costs more than the game's 29 points, so choices matter (%d)" % total)
	p.gold = 1000
	check(Skills.respec(p) and not p.riposte and p.max_hp == hp0 and is_equal_approx(p.spell_cost_mult, 1.0), "a respec takes them all back")


func _learn_all(p: Player, ids: Array) -> void:
	GameState.data.skill_points = 60
	for id: String in ids:
		Skills.learn(id, p)


const BLADE_TO := ["keen_edge", "fourth_strike", "rising_cut", "mattock_mastery", "riposte", "keener_edge", "bloodletting"]
const ARCANA_TO := ["clear_mind", "siphon", "deluge_pierce", "tilte_swarm", "thrift", "chain_thunder", "time_thief"]
const WANDERER_TO := ["deep_pockets", "gold_sense", "quick_draught", "second_stride", "feather_fall", "treasure_sense", "resilience", "last_stand", "second_wind"]


func test_riposte_answers_a_parry_with_a_heavy_cut() -> void:
	var w := make_world(_town({Vector2i(9, 19): "D"}), "test/town", cell_feet(6, 19))
	var p := w.player
	_learn_all(p, BLADE_TO.slice(0, 5))
	GameState.data.equipment.shield = "small_shield"
	GameState.refresh_stats(p)
	var dwarf: RotDwarf = _find(w.room, RotDwarf)
	for i in 180:
		if dwarf.state == "windup" and dwarf.state_time >= RotDwarf.WINDUP - 3 / 60.0:
			break
		await frames(1)
	var hp0 := dwarf.hp
	p.input.block_pressed = true
	p.input.block_held = true
	await frames(6)
	check(p.hp == p.max_hp and dwarf.is_staggered(), "the parry lands")
	check(p.ripostes == 1, "and Riposte answers it once")
	check(hp0 - dwarf.hp == roundi(p.heavy_damage * p.melee_mult) or dwarf.dead, "for a heavy hit (%d -> %d)" % [hp0, dwarf.hp])


func test_bloodletting_heals_on_a_staggered_foe() -> void:
	var w := make_world(_town({Vector2i(8, 19): "D"}), "test/town", cell_feet(6, 19))
	var p := w.player
	_learn_all(p, BLADE_TO)
	var dwarf: RotDwarf = _find(w.room, RotDwarf)
	dwarf.max_hp = 999
	dwarf.hp = 999
	await frames(3)
	# Hold the dwarf still: this is about the heal, not its swing.
	dwarf.set_physics_process(false)
	p.hp = 50
	p.facing = 1
	p.input.attack_pressed = true
	await frames(2)
	check(p.hp == 50, "a hit on a foe on its feet heals nothing (%d)" % p.hp)
	await frames(30)
	dwarf.stagger()
	p.input.attack_pressed = true
	await frames(2)
	check(p.hp == 50 + Player.BLOODLETTING_HEAL, "a hit on a staggered foe heals 2 (%d)" % p.hp)


## Thrust (pass 149, bible 9): the Blade branch's eighth node. Hold Attack
## through the first cut, and letting go past 0.4 s lunges for half again a
## heavy hit. In the air it strikes in place; a blow spends the charge.
func test_thrust_charges_and_lunges() -> void:
	var w := make_world(_town({Vector2i(26, 19): "M"}), "test/town", cell_feet(8, 19))
	var p := w.player
	var mono: Monodron = _find(w.room, Monodron)
	mono.max_hp = 999
	mono.hp = 999
	mono.set_physics_process(false)
	await frames(3)
	check_near(p.combat.thrust_charge, 0.4, 0.0001, "the charge takes 0.4 s")
	check_near(p.combat.thrust_mult, 1.5, 0.0001, "for half again a heavy hit")
	check(String(GameData.skill("thrust").needs) == "bloodletting" and int(GameData.skill("thrust").cost) == 2, "Thrust costs 2, after Bloodletting")
	# Without the skill, a held button is only a cut.
	p.facing = 1
	p.input.attack_pressed = true
	p.input.attack_held = true
	await frames(40)
	p.input.attack_held = false
	await frames(2)
	check(p.thrusts == 0 and not p.thrust_ready(), "without Thrust, holding Attack does nothing more")
	await frames(30)
	_learn_all(p, BLADE_TO + ["thrust"])
	check(p.thrust, "the skill reaches the player")
	# A tap is a cut, never a thrust.
	p.input.attack_pressed = true
	p.input.attack_held = true
	await frames(5)
	p.input.attack_held = false
	await frames(30)
	check(p.thrusts == 0 and p.swing_count > 0, "a tap is only a cut")
	# Held: the press cuts at once, the charge comes ready at 0.4 s.
	var x0 := p.global_position.x
	var swings := p.swing_count
	p.input.attack_pressed = true
	p.input.attack_held = true
	await frames(2)
	check(p.swing_count == swings + 1 and p.attack_kind == "side", "the press still cuts at once")
	await frames(19)
	check(not p.thrust_ready(), "not ready at 0.35 s")
	await frames(5)
	check(p.thrust_ready(), "ready by 0.43 s")
	p.input.attack_held = false
	await frames(1)
	check(p.thrusts == 1 and p.attack_kind == "thrust" and p.is_attacking, "letting go thrusts")
	await frames(12)
	var lunge := p.global_position.x - x0
	check(lunge > 35.0 and lunge < 80.0, "on the floor it lunges forward (%.0f px)" % lunge)
	# At a foe: the point reaches farther than a cut and bites for the full sum.
	await frames(30)
	p.teleport(mono.global_position + Vector2(-60, 0))
	p.facing = 1
	await frames(2)
	p.input.attack_pressed = true
	p.input.attack_held = true
	await frames(27)
	p.input.attack_held = false
	await frames(12)
	var want := roundi(p.heavy_damage * 1.5 * p.blade_mult())
	check(999 - mono.hp == want, "a thrust deals %d (heavy %d x 1.5 x %.1f), expected %d" % [999 - mono.hp, p.heavy_damage, p.blade_mult(), want])
	check(p.global_position.x < mono.global_position.x - 8.0, "and the lunge stops at the foe, not inside it")
	# In the air it strikes where you are.
	await frames(30)
	mono.queue_free()
	p.teleport(cell_feet(10, 19))
	await frames(5)
	p.input.attack_pressed = true
	p.input.attack_held = true
	await frames(16)
	p.input.jump_pressed = true
	p.input.jump_held = true
	await frames(12)
	check(not p.is_on_floor() and p.thrust_ready(), "(charged, in the air)")
	x0 = p.global_position.x
	p.input.attack_held = false
	await frames(10)
	check(p.thrusts == 3 and p.attack_kind == "thrust" and absf(p.global_position.x - x0) < 4.0, "in the air it strikes but carries you nowhere (%.1f px)" % (p.global_position.x - x0))
	p.input.jump_held = false
	# A blow spends the charge.
	var n := 0
	while not p.is_on_floor() and n < 120:
		await frames(1)
		n += 1
	await frames(30)
	p.input.attack_pressed = true
	p.input.attack_held = true
	await frames(28)
	check(p.thrust_ready(), "(charged again)")
	p._invuln_timer = 0.0
	p.take_damage(1)
	await frames(1)
	check(not p.thrust_ready(), "a blow spends the charge")
	p.input.attack_held = false
	await frames(2)
	check(p.thrusts == 3, "so letting go after it doesn't thrust")


func test_thrift_and_time_thief() -> void:
	var w := make_world(_town(), "test/town")
	var p := w.player
	p.abilities["deluge"] = true
	p.abilities["hourglass"] = true
	_learn_all(p, ARCANA_TO)
	await frames(3)
	p.mp = p.max_mp
	p.equipped_spell = "deluge"
	p.input.spell_pressed = true
	await frames(1)
	check_near(p.max_mp - p.mp, Spells.cost("deluge") * 0.85, 0.2, "Thrift: a Deluge costs 15% less")
	TimeStop.reset()
	p.input.hourglass_pressed = true
	await frames(1)
	check_near(TimeStop.total, TimeStop.DURATION + Player.TIME_THIEF_EXTRA, 0.01, "Time Thief: the glass holds a second longer")
	TimeStop.reset()


## Mantra of Death (pass 134), the Arcana branch's last node: Death costs half.
func test_mantra_of_death_halves_the_death_spell() -> void:
	var w := make_world(_town(), "test/town")
	var p := w.player
	p.abilities["death"] = true
	p.abilities["deluge"] = true
	_learn_all(p, ARCANA_TO.slice(0, 6))
	check(Skills.status("mantra_of_death") == "locked", "Mantra of Death waits on Time Thief")
	_learn_all(p, ARCANA_TO + ["mantra_of_death"])
	check(p.mantra_of_death and int(GameData.skill("mantra_of_death").cost) == 3, "it costs 3 points and switches on")
	check_near(p.spell_cost("death"), Spells.cost("death") * 0.85 * Player.MANTRA_OF_DEATH_MULT, 0.01, "Death costs half, after Thrift (%.1f)" % p.spell_cost("death"))
	check_near(p.spell_cost("deluge"), Spells.cost("deluge") * 0.85, 0.01, "other spells only get Thrift")
	await frames(3)
	p.mp = p.max_mp
	p.equipped_spell = "death"
	p.input.spell_pressed = true
	await frames(1)
	check_near(p.max_mp - p.mp, 17.0, 0.2, "a cast takes 17 MP, not 34 (%.1f)" % (p.max_mp - p.mp))
	p.gold = 1000
	check(Skills.respec(p) and is_equal_approx(p.spell_cost("death"), Spells.cost("death")), "a respec puts Death back at 40")


func test_chain_thunder_leaps_to_two_more_foes() -> void:
	var foes := {Vector2i(10, 19): "D", Vector2i(14, 19): "D", Vector2i(18, 19): "D", Vector2i(36, 19): "D"}
	var w := make_world(_town(foes), "test/town", cell_feet(6, 19))
	var p := w.player
	p.abilities["thunder"] = true
	_learn_all(p, ARCANA_TO.slice(0, 6))
	var dwarves: Array = w.room.get_children().filter(func(c: Node) -> bool: return c is RotDwarf)
	for d: RotDwarf in dwarves:
		d.max_hp = 999
		d.hp = 999
	await frames(3)
	p.facing = 1
	p.mp = p.max_mp
	p.equipped_spell = "thunder"
	p.input.spell_pressed = true
	await frames(20)
	var hit := dwarves.filter(func(d: RotDwarf) -> bool: return d.hp < 999)
	check(hit.size() == 3, "the bolt strikes one and leaps to two more (%d struck)" % hit.size())
	check(dwarves[3].hp == 999, "but not to one far away")


func test_treasure_sense_marks_rooms_with_something_left() -> void:
	var a := grid_rows(40, 23)
	put_tiles(a, 5, 19, "P")
	put_tiles(a, 20, 19, "L")
	put_tiles(a, 30, 19, "$")
	var w := make_world({"test/town": room_text(["name: Town", "zone: test"], a)}, "test/town")
	var p := w.player
	var info: Dictionary = w.catalog["test/town"]
	check(info.treasures == ["test/town:20,19", "test/town:30,19"], "the catalog knows the room's fruit and chest (%s)" % [info.treasures])
	check(MapScreen.unfound(info) == 2, "two things left to find")
	check(not MapScreen.senses_treasure(info, "visited"), "no mark without the skill")
	_learn_all(p, WANDERER_TO.slice(0, 6))
	check(MapScreen.senses_treasure(info, "visited") and MapScreen.senses_treasure(info, "charted"), "with Treasure Sense the map marks it, seen or charted")
	check(not MapScreen.senses_treasure(info, ""), "but never a room the map doesn't show")
	GameState.collect("test/town:20,19")
	GameState.collect("test/town:30,19")
	check(MapScreen.unfound(info) == 0 and not MapScreen.senses_treasure(info, "visited"), "and the mark goes once all is found")


func test_the_map_marks_key_doors_still_shut() -> void:
	# A Queen door and a plain Jack door in a test room.
	var rooms := _town({Vector2i(12, 19): "J", Vector2i(30, 19): "J"}, ["lock: 12, 19, queen"])
	var w := make_world(rooms, "test/town", cell_feet(5, 19))
	var info: Dictionary = w.catalog["test/town"]
	var shut := MapScreen.locked_doors(info)
	check(shut.size() == 2, "the catalog lists both doors (%s)" % [shut])
	check(shut[0].kind == "queen" and shut[0].id == "test/town:12,19" and shut[1].kind == "jack", "with their card and pickup id")
	check(MapScreen.lock_color("queen") == KeyDoor.CARDS.queen.panel and MapScreen.lock_color("sky") == KeyDoor.SHRINE, "each marked in its own door's color")
	GameState.collect("test/town:12,19")
	shut = MapScreen.locked_doors(info)
	check(shut.size() == 1 and shut[0].kind == "jack", "an opened door leaves the map")
	# The real world: every card vault and the sky gate are on the map.
	var real := World.new()
	real.build_catalog()
	var kinds := {}
	for room_id: String in real.catalog:
		for lock: Dictionary in real.catalog[room_id].locks:
			kinds[lock.kind] = room_id
	for kind: String in ["queen", "king", "ace", "joker", "sky"]:
		check(kinds.has(kind), "the map knows where the %s door is (%s)" % [kind, kinds])
	check(kinds.get("queen", "") == "mist/feather_hollow", "the Queen vault is in the Feather Hollow")
	real.free()


func test_wanderers_grace_lengthens_the_dash_and_a_kill_gives_it_back() -> void:
	var w := make_world(_town({Vector2i(14, 19): "D"}), "test/town", cell_feet(6, 19))
	var p := w.player
	p.abilities.stride = true
	await frames(2)
	var foe: Enemy = null
	for c in w.room.get_children():
		if c is Enemy:
			foe = c
	check(foe != null, "a foe to kill")
	_learn_all(p, WANDERER_TO)
	check(is_equal_approx(p.dash_invuln(), p.tuning.dash_invuln), "without it, a dash's usual %.2f s" % p.tuning.dash_invuln)
	p.air_dash_charges = 0
	check(not p.on_kill(), "without it, a kill gives nothing back")
	check(Skills.status("wanderers_grace") == "", "Wanderer's Grace opens after Second Wind")
	check(Skills.learn("wanderers_grace", p) and p.wanderers_grace, "learned Wanderer's Grace")
	check(is_equal_approx(p.dash_invuln(), p.tuning.dash_invuln + Player.GRACE_INVULN), "a dash lets harm through 0.1 s longer (%.2f)" % p.dash_invuln())
	p._invuln_timer = 0.0
	p.input.dash_pressed = true
	await frames(1)
	p.input.dash_pressed = false
	check(p.is_dashing and p._invuln_timer > p.tuning.dash_invuln, "and the dash really does (%.3f s left)" % p._invuln_timer)
	await frames(20)
	p.air_dash_charges = 0
	foe.die()
	var full := p.tuning.air_dash_charges + p.bonus_air_dashes
	check(p.air_dash_charges == full, "a kill gives back both air dashes (%d of %d)" % [p.air_dash_charges, full])
	check(not p.on_kill(), "and does nothing when none were spent")
	p.gold = 5000
	check(Skills.respec(p) and not p.wanderers_grace and is_equal_approx(p.dash_invuln(), p.tuning.dash_invuln), "a respec takes it back")


func test_last_stand_and_second_wind() -> void:
	var w := make_world(_town(), "test/town")
	var p := w.player
	_learn_all(p, WANDERER_TO)
	await frames(2)
	p.hp = 100
	p.take_damage(20)
	check(p.hp == 80, "Last Stand does nothing at good health (%d)" % p.hp)
	p._invuln_timer = 0.0
	p.hp = 15
	p.take_damage(8)
	check(p.hp == 9, "below 20%%, a hit does 25%% less (%d)" % p.hp)
	p._invuln_timer = 0.0
	p.take_damage(200)
	check(p.hp == 1 and not p.dead and p.second_wind_used, "Second Wind: a killing blow leaves you at 1 HP")
	p._invuln_timer = 0.0
	p.hp = 5
	p.take_damage(200)
	check(p.dead, "but only once between rests")
	await frames(int(p.combat.respawn_delay * 60.0) + 10)
	check(not p.dead and not p.second_wind_used, "a respawn (like a rest) gives it back")
	p.second_wind_used = true
	p.restore()
	check(not p.second_wind_used, "and so does resting at a shrine")


## Pass 136: Ilse the Dyer in the Market Row sells six cloak dyes (bible 10's
## cosmetic gold sink); one you own is worn again for free, and 100% completion
## puts the glowing Lord's Gold on her shelf (bible 11).
func test_the_dyer_dyes_the_cloak() -> void:
	var w := make_world({}, "eolis/market")
	await frames(2)
	var dyer: Npc = null
	for c in w.room.get_children():
		if c is Npc and (c as Npc).npc_id == "eolis_dyer":
			dyer = c
	check(dyer != null and Sheet.exists("npc_eolis_dyer"), "Ilse the Dyer stands in the Market Row, with a sheet")
	var p := w.player
	var stock: Array = GameData.shop("eolis_dyes").stock
	var sold := stock.filter(func(e: Dictionary) -> bool: return int(e.price) > 0)
	check(sold.size() == 6, "she sells six dyes (%d)" % sold.size())
	PlayerVisual.body_sets = false  # the ranger's cloak takes dyes; the body sets have none yet
	check(GameState.dye() == "warden_dye" and PlayerVisual.dye_look().is_empty(), "a new game wears Warden Green, the cloak's own")
	check(p.visual.material == null, "so the sprite is drawn as it is")
	check(Shop.status("eolis_dyes", 0, p) == "worn", "which shows as worn")
	p.gold = 300
	check(Shop.buy("eolis_dyes", 1, p) and p.gold == 0, "Ember Red costs 300 g")
	await frames(2)
	check(GameState.dye() == "ember_dye" and PlayerVisual.dye_look()[0] == Color("d0453f"), "and goes straight on the cloak")
	var mat := p.visual.material as ShaderMaterial
	check(mat != null and mat.get_shader_parameter("dye") == Color("d0453f"), "the sprite takes the dye's shader")
	check(Shop.status("eolis_dyes", 2, p) == "gold", "Tide Blue is out of reach with no gold")
	check(Shop.buy("eolis_dyes", 0, p) and GameState.dye() == "warden_dye", "back to Warden Green, for nothing")
	await frames(2)
	check(p.visual.material == null, "and the shader comes off")
	check(Shop.status("eolis_dyes", 1, p) == "" and Shop.buy("eolis_dyes", 1, p) and p.gold == 0, "Ember again, free: it is yours")
	var lord := stock.size() - 1
	check(stock[lord].item == "lord_dye" and not Shop.shelf("eolis_dyes").has(lord), "the Lord's Gold is not on the shelf yet")
	check(not Completion.award({"percent": 99}) and not GameState.flag("lord"), "99% of the world is not enough")
	check(Completion.award({"percent": 100}) and Shop.shelf("eolis_dyes").has(lord), "100% puts it on the shelf")
	check(Shop.buy("eolis_dyes", lord, p) and PlayerVisual.dye_look()[1], "it is given, and it glows")
	PlayerVisual.body_sets = true


## A plateau that runs down a six-tile ramp, and one that ends at a lip over a pit.
func _lunge_rooms() -> Dictionary:
	var s := grid_rows(40, 23)
	put_tiles(s, 1, 14, "#", 10, 6)
	for i in 6:
		put_tiles(s, 11 + i, 14 + i, "\\")
		put_tiles(s, 11 + i, 15 + i, "#", 1, 5 - i)
	var l := grid_rows(40, 23)
	put_tiles(l, 1, 14, "#", 14, 6)
	return {"test/slope": room_text(["name: Slope", "zone: test"], s), "test/ledge": room_text(["name: Ledge", "zone: test"], l)}


func _charge_and_thrust(p: Player) -> void:
	p.facing = 1
	p.input.attack_pressed = true
	p.input.attack_held = true
	await frames(27)
	p.input.attack_held = false
	await frames(1)


## Pass 153: the lunge is as fast as a dash, so it hugs a ramp the way a ground
## dash does (pass 121), and off a lip you step down at no more than a run.
func test_thrust_lunge_rides_slopes_and_steps_off_ledges() -> void:
	var w := make_world(_lunge_rooms(), "test/slope", cell_feet(10, 13))
	var p := w.player
	_learn_all(p, BLADE_TO + ["thrust"])
	await frames(10)
	var x0 := p.global_position.x
	var y0 := p.global_position.y
	await _charge_and_thrust(p)
	var air := 0
	for i in 14:
		air += 0 if p.is_on_floor() else 1
		await frames(1)
	check(air == 0 and p.global_position.y > y0 + 24.0, "a thrust down a ramp rides it all the way (%d frames in the air, %.0f px down)" % [air, p.global_position.y - y0])
	check(p.global_position.x - x0 > 35.0, "and still lunges its length (%.0f px)" % (p.global_position.x - x0))
	# A ground dash down the same ramp, and the slide out of it, stay on it too.
	await frames(40)
	p.teleport(cell_feet(10, 13))
	await frames(10)
	GameState.data.abilities["stride"] = true
	GameState.apply(p)
	p.facing = 1
	p.input.dash_pressed = true
	await frames(1)
	check(p.is_dashing, "the dash goes")
	air = 0
	for i in 16:
		await frames(1)
		air += 0 if p.is_on_floor() else 1
	check(air == 0, "a ground dash down the ramp and its slide-out never leave it (%d frames in the air)" % air)
	w.queue_free()
	await frames(2)
	# Off a lip: the lunge ends there, at no more than a run.
	w = make_world(_lunge_rooms(), "test/ledge", cell_feet(14, 13))
	p = w.player
	_learn_all(p, BLADE_TO + ["thrust"])
	await frames(10)
	await _charge_and_thrust(p)
	var off_speed := -1.0
	var airborne := 0
	for i in 60:
		await frames(1)
		airborne += 0 if p.is_on_floor() else 1
		if airborne == 2:
			# The frame after the feet leave the lip is the first the lunge sees it.
			off_speed = absf(p.velocity.x)
		if p.is_on_floor() and p.global_position.y > 300.0:
			break
	check(off_speed >= 0.0 and off_speed <= p.tuning.run_speed + 0.5, "the lunge ends at the lip and you step off at no more than a run (%.0f px/s)" % off_speed)
	var past := p.global_position.x - 15 * Room.TILE
	check(p.is_on_floor() and past < 32.0, "and lands within two tiles of it (%.0f px out; a full-speed lunge flew 67)" % past)


## Executioner (pass 163, bible 9): the Blade branch's ninth node, after Thrust.
## Melee blows on a boss in its opening (Enemy.punishable: each boss names its
## own window) land for 35% more; a common foe gets nothing more, and a boss on
## its guard nothing either. Bloodletting heals on a boss's opening too.
func test_executioner_strikes_harder_into_a_bosss_opening() -> void:
	check(String(GameData.skill("executioner").needs) == "thrust" and int(GameData.skill("executioner").cost) == 3, "Executioner costs 3, after Thrust")
	var w := make_world(_town({Vector2i(8, 19): "D"}), "test/town", cell_feet(6, 19))
	var p := w.player
	check_near(p.combat.executioner_mult, 1.35, 0.0001, "for 35% more")
	_learn_all(p, BLADE_TO + ["thrust", "executioner"])
	check(p.executioner, "the skill switches on")
	var dwarf: RotDwarf = _find(w.room, RotDwarf)
	dwarf.max_hp = 999
	dwarf.hp = 999
	await frames(3)
	dwarf.set_physics_process(false)
	p.facing = 1
	var cut := roundi(p.slash_damage * p.blade_mult())
	var blows := []
	for step in 2:
		if step == 1:
			dwarf.add_to_group("boss")
		dwarf.stagger()
		var hp0 := dwarf.hp
		p.hp = 50
		Sfx.recent.clear()
		p.input.attack_pressed = true
		await frames(2)
		blows.append([hp0 - dwarf.hp, p.hp, Sfx.recent.has("execute")])
		await frames(40)
	check(blows[0][0] == cut, "a staggered common foe takes a plain cut (%d, a cut is %d)" % [blows[0][0], cut])
	check(blows[1][0] == roundi(cut * 1.35), "a boss in its opening takes 35%% more (%d)" % blows[1][0])
	check(blows[1][1] == 50 + Player.BLOODLETTING_HEAL, "and Bloodletting heals on it (%d)" % blows[1][1])
	check(blows[1][2] and not blows[0][2], "the blow into the opening cleaves with its own sound, a plain one does not (pass 165)")
	dwarf._stagger = 0.0
	var hp1 := dwarf.hp
	p.input.attack_pressed = true
	await frames(2)
	check(hp1 - dwarf.hp == cut, "a boss on its guard takes a plain cut (%d)" % (hp1 - dwarf.hp))
	# Every boss names its opening (bible 8), so the skill has a window in every fight.
	var dir := "res://scripts/bosses/"
	for file in DirAccess.get_files_at(dir):
		if not file.ends_with(".gd"):
			continue
		var src := FileAccess.get_file_as_string(dir + file)
		if not src.contains("add_to_group(\"boss\")") or file in ["shadow_eura.gd", "evil_core.gd"]:
			continue
		check(src.contains("func punishable() -> bool") or src.contains("func segment_punishable("), "%s names its opening" % file)


## Pass 186 (Sean): gear you buy or find is kept, and the Equipment page puts
## any of it on; tempers stay with each blade. The Dwarvish Broad Sword (once
## the Giant Blade) takes both hands: no guard or parry while you hold it.
## Pass 193: the original sold twelve pieces of gear. Each is an item under
## its own name, or bible 5.2's table of what changed names the item that
## took its place; and every id the save renames has a row there.
func test_the_originals_twelve_pieces_of_gear_are_all_here() -> void:
	const ORIGINAL := ["Hand Dagger", "Long Sword", "Giant Blade", "Dragon Slayer",
		"Leather Armor", "Studded Mail", "Full Plate", "Battle Suit",
		"Small Shield", "Large Shield", "Magic Shield", "Battle Helmet"]
	var names := {}
	var items := GameData.table("items")
	for id: String in items:
		names[String(items[id].get("name", ""))] = id
	var bible := FileAccess.get_file_as_string("res://docs/design-bible.md")
	var at := bible.find("**The original's gear, and what changed")
	check(at >= 0, "bible 5.2 has the table of what changed")
	var table := {}
	for line: String in bible.substr(at, 3000).split("\n"):
		var cells := line.split("|")
		if cells.size() >= 5 and line.begins_with("| ") and not line.begins_with("| Original") and not line.begins_with("|--"):
			table[cells[1].strip_edges()] = cells[2].strip_edges()
	var missing := []
	for name: String in ORIGINAL:
		if names.has(name):
			continue
		var row := String(table.get(name, ""))
		var now := row.get_slice(" (", 0)
		if row == "" or not names.has(now):
			missing.append(name)
	check(missing.is_empty(), "every original piece of gear is an item or has a row naming its heir: %s" % [missing])
	var unrecorded := []
	for old: String in GameState.RENAMED_ITEMS:
		if not bible.substr(at, 3000).contains("from `%s`" % old):
			unrecorded.append(old)
	check(unrecorded.is_empty(), "every renamed id has a row: %s" % [unrecorded])
	check(names.has("Battle Helmet") and String(items[names["Battle Helmet"]].kind) == "helmet", "the Battle Helmet keeps its name in its own slot")


## Every room file, as id -> Room.parse (the gym and the trials included).
func _all_rooms() -> Dictionary:
	var out := {}
	for zone in DirAccess.get_directories_at("res://levels"):
		for f in DirAccess.get_files_at("res://levels/" + zone):
			if f.ends_with(".room"):
				out[zone + "/" + f.get_basename()] = Room.parse(FileAccess.get_file_as_string("res://levels/%s/%s" % [zone, f]))
	return out


## The rooms whose `prop:` lines lay `kind`.
func _rooms_with_prop(rooms: Dictionary, kind: String) -> Array:
	var out := []
	for id: String in rooms:
		for spec: String in rooms[id].lists.get("prop", []):
			if spec.get_slice(",", 2).strip_edges() == kind:
				out.append(id)
	return out


## Pass 201: the rubric's faithfulness checklist (bible 15.3), held as a whole:
## the original's eight towns each with a Guru, its sixteen ranks, four rings,
## five keys, three springs, its guardians and the Evil One, its five spells
## and its relics.
func test_the_faithfulness_checklist_is_all_here() -> void:
	var rooms := _all_rooms()
	const TOWNS := {"Eolis": "eolis/guru_temple", "Apolune": "trunk/apolune", "Forepaw": "tower/forepaw",
		"Mascon": "mist/mascon", "Victim": "mist/victim", "Conflate": "branches/conflate",
		"Daybreak": "daybreak/daybreak", "Dartmoor": "dartmoor/drowned_market"}
	var no_guru := []
	for town: String in TOWNS:
		var has := false
		for spec: String in rooms.get(TOWNS[town], {"lists": {}}).lists.get("npc", []):
			has = has or spec.get_slice(",", 2).strip_edges() == "guru"
		if not has:
			no_guru.append(town)
	check(no_guru.is_empty(), "each of the original's eight towns has a Guru (missing: %s)" % [no_guru])
	check(GameState.RANKS == ["Novice", "Aspirant", "Battler", "Fighter", "Adept", "Chevalier", "Veteran", "Warrior",
		"Swordman", "Hero", "Soldier", "Myrmidon", "Champion", "Superhero", "Paladin", "Lord"], "the original's sixteen ranks, in order")
	var rings := []
	for id: String in BossArena.BOSSES:
		if BossArena.BOSSES[id].has("ring"):
			rings.append(BossArena.BOSSES[id].ring)
	rings.sort()
	check(rings == ["demon", "dworf", "elf", "ruby"] and ZenisGate.RINGS.size() == 4, "the four rings, each a guardian's, open Zenis (%s)" % [rings])
	var items := GameData.table("items")
	var locks := {}
	for id: String in rooms:
		for spec: String in rooms[id].lists.get("lock", []):
			locks[spec.get_slice(",", 2).strip_edges()] = true
	for card: String in ["jack", "queen", "king", "ace"]:
		check(items.has(card + "_key"), "the %s Key is an item" % card.capitalize())
	check(locks.has("queen") and locks.has("king") and locks.has("ace") and locks.has("joker"), "and each card but the Jack (the default) has a door (%s)" % [locks.keys()])
	check(_rooms_with_prop(rooms, "joker_key").size() == 1, "the one Joker Key lies in one room")
	check(Fountain.SPRINGS == ["trunk", "mist", "sky"], "the three springs fill Eolis's fountain")
	for spring: String in Fountain.SPRINGS:
		check(_rooms_with_prop(rooms, "spring_" + spring).size() == 1, "the Spring of %s has its room" % spring.capitalize())
	var arenas := {}
	for id: String in rooms:
		var b := String(rooms[id].header.get("boss", ""))
		if b != "":
			arenas[b] = int(arenas.get(b, 0)) + 1
	for boss: String in ["rokusutahn", "zoradohna", "ripasheiku", "zorugeriru", "pakukame", "borabohra", "king_grieve", "shadow_eura", "evil_one"]:
		check(BossArena.BOSSES.has(boss) and arenas.get(boss, 0) == 1, "%s has one arena" % boss)
	check(Spells.ORDER == ["deluge", "thunder", "fire", "tilte", "death"], "the original's five spells")
	var abilities: Dictionary = GameState.fresh().abilities
	check(BossArena.BOSSES.foreman.get("ability", "") == "mattock", "the Mattock is the Foreman's")
	for relic: String in ["boots", "onyx", "hourglass", "pendant", "magical_rod"]:
		check(ItemPickup.INFO.has(relic) and relic in ItemPickup.ABILITIES, "the %s can be found" % relic)
	for relic: String in ["pendant", "magical_rod"]:
		check(_rooms_with_prop(rooms, relic).size() == 1 and relic in Room.FOUND_PROPS, "the %s lies in one room and counts as a treasure" % relic)
	check(abilities.has("pendant") and abilities.has("magical_rod"), "a save carries the relics")



## Pass 209: the original's towns each kept a tool shop and sold keys. Every
## one of the eight has a keeper standing in it who sells goods (an Ointment or
## an Elixir) and one who sells Jack Keys; the four card keys are each sold a
## zone before their doors, and the Joker is never sold. Bible 10.2's item-shop
## row is held to the shelves: no shop sells anything the items table lacks.
func test_every_town_keeps_the_originals_shops() -> void:
	var rooms := _all_rooms()
	var npcs := GameData.table("npcs")
	var shops := GameData.table("shops")
	var items := GameData.table("items")
	var standing := {}
	for id: String in rooms:
		for spec: String in rooms[id].lists.get("npc", []):
			standing[spec.get_slice(",", 2).strip_edges()] = true
	var sells := {}
	for npc: String in npcs:
		if npcs[npc].get("role", "") != "shop" or not standing.has(npc):
			continue
		var shop: String = npcs[npc].shop
		var town := shop.get_slice("_", 0)
		for entry: Dictionary in shops[shop].stock:
			sells[town + ":" + String(entry.item)] = true
	var no_goods := []
	var no_keys := []
	for town: String in ["eolis", "apolune", "forepaw", "mascon", "victim", "conflate", "daybreak", "dartmoor"]:
		if not (sells.has(town + ":ointment") or sells.has(town + ":elixir")):
			no_goods.append(town)
		if not sells.has(town + ":jack_key"):
			no_keys.append(town)
	check(no_goods.is_empty(), "every town sells goods, an Ointment or an Elixir (missing: %s)" % [no_goods])
	check(no_keys.is_empty(), "every town sells Jack Keys (missing: %s)" % [no_keys])
	for card: String in ["queen", "king", "ace"]:
		check(sells.keys().any(func(k: String) -> bool: return k.ends_with(":" + card + "_key")), "the %s Key is sold" % card.capitalize())
	check(not sells.keys().any(func(k: String) -> bool: return k.ends_with(":joker_key")), "the Joker Key is only found")
	var unknown := []
	for shop: String in shops:
		for entry: Dictionary in shops[shop].stock:
			if not items.has(String(entry.item)):
				unknown.append("%s: %s" % [shop, entry.item])
	check(unknown.is_empty(), "every shelf sells a real item (%s)" % [unknown])

## Pass 201: the original's Pendant (the end of the Tower of Suffer, in the
## corner of its guardian's room) and Magical Rod (Conflate, up a ladder to the
## right). The Pendant was meant to raise the blade's power (a slip in the
## original's code lowered it instead); the Rod raised Deluge from 6 to 9.
func test_the_pendant_and_the_magical_rod() -> void:
	GameState.new_game()
	check(_rooms_with_prop(_all_rooms(), "pendant") == ["mist/hag_mire"], "the Pendant lies in the Matriarch's Mire")
	check(_rooms_with_prop(_all_rooms(), "magical_rod") == ["branches/conflate"], "the Magical Rod lies in Conflate")
	var room := make_room(_GOLD_ROOM)
	var p := make_player(room, Vector2i(2, 3))
	p.abilities["pendant"] = false
	p.abilities["magical_rod"] = false
	await frames(2)
	var plain := p.blade_mult()
	var bolt := Spells.cast("deluge", p) as DelugeBolt
	check(bolt.damage == Spells.DATA.deluge.damage, "without the Rod, Deluge hits for %d" % bolt.damage)
	bolt.free()
	for kind: String in ["pendant", "magical_rod"]:
		var item := ItemPickup.new()
		item.kind = kind
		item.pickup_id = "test:" + kind
		room.add_child(item)
		item.global_position = p.global_position + Vector2(0, -12)
		await frames(2)
		check(p.abilities.get(kind, false) and GameState.is_collected("test:" + kind) and bool(GameState.data.abilities.get(kind, false)),
			"touching the %s takes it, for good" % kind)
	check_near(p.blade_mult(), plain * p.combat.pendant_mult, 0.0001, "the Pendant: every blade hit a tenth harder")
	bolt = Spells.cast("deluge", p) as DelugeBolt
	check(bolt.damage == roundi(Spells.DATA.deluge.damage * 1.5), "the Rod: Deluge half again as hard (%d)" % bolt.damage)
	bolt.free()
	room.free()
	GameState.new_game()


## Pass 189: the shop and the Equipment page give each blade's numbers, and
## the Equipment page changes the cloak's dye anywhere, not only at Ilse's.
func test_the_equipment_page_shows_blade_numbers_and_changes_the_cloak() -> void:
	GameState.new_game()
	check(Menus.blade_numbers("short_sword") == "Cuts 8, heavy 14.", "the Short Sword's numbers (%s)" % Menus.blade_numbers("short_sword"))
	check(Menus.blade_numbers("dwarvish_broad_sword") == "Cuts 17, heavy 32, reach +16, 30% slower.",
		"the Broad Sword says how slow it is (%s)" % Menus.blade_numbers("dwarvish_broad_sword"))
	GameState.data.tempers = {"long_sword": 2}
	var t := 1.0 + GameState.TEMPER_BONUS * 2
	check(Menus.blade_numbers("long_sword").begins_with("Cuts %d, heavy %d, reach +8." % [roundi(11 * t), roundi(19 * t)]), "with its tempers in (%s)" % Menus.blade_numbers("long_sword"))
	var dyer: Array = GameData.shop("eolis_dyes").stock
	check(GameData.items_of_kind("dye").size() == dyer.size(), "every dye is on Ilse's shelf (%d of %d)" % [GameData.items_of_kind("dye").size(), dyer.size()])
	check(Menus.cloak_dyes() == ["warden_dye"], "a new cloak has only Warden Green (%s)" % [Menus.cloak_dyes()])
	GameState.data.dyes = ["tide_dye"]
	GameState.earn_dye("slate_dye")
	check(Menus.cloak_dyes() == ["warden_dye", "tide_dye", "slate_dye"], "then each dye bought or won (%s)" % [Menus.cloak_dyes()])
	GameState.set_flag("lord")
	check(Menus.cloak_dyes().has("lord_dye"), "and the Lord's Gold once it is yours")
	var rows := Menus.equipment_rows()
	var labels: Array = rows.map(func(r: Dictionary) -> String: return r.label)
	var at := labels.find("Cloak")
	check(at > 0 and rows[at].get("header", false) and labels.slice(at + 1) == ["Warden Green", "Tide Blue", "Lord's Gold", "Mantra Slate"],
		"the page ends with the Cloak and its dyes (%s)" % [labels])
	check(rows[labels.find("Mantra Slate")].right == "Worn", "marking the one on")
	check(String(rows[1].detail).contains("Cuts 8, heavy 14."), "a blade's row gives its numbers")
	# Every row's detail fits the menu's box (three lines), the longest gear
	# worn: the Broad Sword held, so a shield's row adds why it is on your back.
	GameState.data.gear = ["short_sword", "long_sword", "dwarvish_broad_sword", "dragon_slayer", "leather_armor", "studded_mail",
		"full_plate", "battle_suit", "small_shield", "large_shield", "magic_shield", "battle_helmet"]
	GameState.data.equipment = {"blade": "dwarvish_broad_sword", "armor": "battle_suit", "shield": "magic_shield", "helmet": "battle_helmet"}
	GameState.data.tempers = {"dwarvish_broad_sword": 2}
	var width := ListMenu.PANEL.size.x - 28
	var long := []
	for row: Dictionary in Menus.equipment_rows():
		var n := PixelFont.wrap_lines(String(row.get("detail", "")), width, 9).size()
		if n > 3:
			long.append("%s: %d lines" % [row.label, n])
	check(long.is_empty(), "every detail fits in three lines: %s" % [long])
	var w := make_world(_town(), "test/town")
	await frames(3)
	GameState.data.dyes = ["tide_dye"]
	Menus.choose_equipment("tide_dye", w.player)
	check(GameState.dye() == "tide_dye", "choosing a dye puts it on, away from the Dyeworks")
	Menus.choose_equipment("night_dye", w.player)
	check(GameState.dye() == "tide_dye", "but not one you don't have")
	Menus.choose_equipment("tide_dye", w.player)
	check(GameState.dye() == "tide_dye", "and choosing the worn one again keeps the cloak dyed")


func test_gear_is_kept_and_swapped_and_the_broad_sword_takes_both_hands() -> void:
	var w := make_world(_town(), "test/town")
	var p := w.player
	await frames(3)
	GameState.set_flag("spring:sky")
	p.gold = 20000
	check(GameState.data.gear == ["short_sword"], "you start with the Short Sword (%s)" % [GameState.data.gear])
	var buy := func(shop: String, id: String) -> bool:
		var stock: Array = GameData.shop(shop).stock
		for i in stock.size():
			if stock[i].item == id:
				return Shop.buy(shop, i, p)
		return false
	check(buy.call("eolis_arms", "long_sword") and buy.call("eolis_arms", "dwarvish_broad_sword"), "bought the Long Sword and the Broad Sword")
	check(buy.call("eolis_arms", "small_shield"), "and a Small Shield")
	check(GameState.data.gear.has("long_sword") and GameState.data.gear.has("dwarvish_broad_sword"), "both blades are kept (%s)" % [GameState.data.gear])
	check(GameState.data.equipment.blade == "dwarvish_broad_sword" and GameState.two_handed(), "the new one goes in hand, two-handed")
	check(not p.has_shield and not p.reflects, "so the shield stays on your back: no guard, no parry")
	p.input.block_held = true
	p.input.block_pressed = true
	await frames(2)
	check(not p.is_blocking, "Block does nothing while it is held")
	p.input.block_held = false
	GameState.data.tempers["long_sword"] = 2
	GameState.wear("long_sword", p)
	check(GameState.data.equipment.blade == "long_sword" and p.has_shield, "swapped back to the Long Sword, the shield comes to hand")
	check(p.slash_damage == roundi(11 * (1.0 + 2 * GameState.TEMPER_BONUS)), "with the Long Sword's own tempers (%d)" % p.slash_damage)
	GameState.wear("long_sword", p)
	check(GameState.data.equipment.blade == "long_sword", "a blade can't be taken off")
	GameState.wear("small_shield", p)
	check(GameState.data.equipment.shield == "" and not p.has_shield, "the shield can")
	GameState.wear("magic_shield", p)
	check(GameState.data.equipment.shield == "", "gear you don't have can't be put on")
	var rows := Menus.equipment_rows()
	var labels: Array = rows.map(func(r: Dictionary) -> String: return r.label)
	check(labels.slice(0, 4) == ["Blades", "Short Sword", "Long Sword", "Dwarvish Broad Sword"], "the Equipment page lists blades by tier (%s)" % [labels])
	check(labels.has("Shields") and labels.has("Small Shield"), "and the shields you have")
	check(rows[2].right == "Worn", "marking what you wear")
	# A save keeps the gear, and an older save gets what it wore, renamed.
	var src := GameState.fresh()
	src.equipment = {"blade": "giant_blade", "armor": "leather_armor", "shield": "large_shield"}
	src.tempers = {"giant_blade": 1}
	src.erase("gear")
	var got := GameState.sanitize(JSON.parse_string(JSON.stringify(src)))
	check(got.equipment.blade == "dwarvish_broad_sword" and int(got.tempers.dwarvish_broad_sword) == 1, "the Giant Blade is the Dwarvish Broad Sword, tempers kept")
	check(got.gear == ["short_sword", "dwarvish_broad_sword", "leather_armor", "large_shield"], "an old save keeps what it wore (%s)" % [got.gear])


## The gold sheet (design bible 10.1, pass 197): along the critical path, a
## player who opens half the chests and fells each foe once can buy the par kit
## of the damage sheet (5.5) where its shops stand, with no grinding.
## Each step: the zone just walked, then what the par player buys before the next.
const GOLD_PATH := [
	["eolis", [["eolis_arms", "long_sword"], ["eolis_arms", "leather_armor"]]],
	["trunk", [["apolune_armor", "studded_mail"]]],
	["tower", [["forepaw_smith", "temper_1"]]],
	["mist", []],
	["branches", []],
	["daybreak", [["forepaw_smith", "temper_2"], ["daybreak_armor", "full_plate"]]],
	["dartmoor", []],
	["zenis", []],
]
const _GOLD_ROOM := [
	"############",
	"#..........#",
	"#..........#",
	"#..........#",
	"############",
]
const GOLD_FOES := {
	"M": "monodron", "H": "hornet", "D": "rot_dwarf", "T": "sap_spitter", "U": "grub_lump",
	"I": "iron_dwarf", "B": "gear_bat", "K": "minecart_rider", "A": "lantern_ghost",
	"V": "bog_myconid", "p": "drowned_dwarf", "m": "leaf_mantis", "!": "bark_knight",
	";": "seed_bomber", "?": "marsh_hag", "t": "thunder_beetle", "y": "storm_harpy",
	"]": "spire_sentinel", "q": "crystal_dwarf", "e": "shade_knight", "j": "clockwork_hound",
	"s": "meteor_slug", "l": "spring_eel",
}


## [chest gold, one pass of foes' gold] in a zone's rooms. Foes pay their
## zone's threat over (Enemy.die, pass 197).
func _zone_gold(zone: String) -> Array[int]:
	var chests := 0
	var foes := 0.0
	var mean := {}
	for f in DirAccess.get_files_at("res://levels/" + zone):
		if not f.ends_with(".room"):
			continue
		var parsed := Room.parse(FileAccess.get_file_as_string("res://levels/%s/%s" % [zone, f]))
		var each := int(parsed.header.get("chest_gold", "100"))
		var over := {}
		for spec: String in parsed.lists.get("chest", []):
			var c := spec.split(",")
			over[Vector2i(int(c[0]), int(c[1]))] = int(c[2])
		var grid: Array = parsed.grid
		for y in grid.size():
			var row: String = grid[y]
			for x in row.length():
				var ch := row[x]
				if ch == "$":
					chests += int(over.get(Vector2i(x, y), each))
				elif GOLD_FOES.has(ch):
					if not mean.has(ch):
						var foe: Enemy = load("res://scripts/enemies/%s.gd" % GOLD_FOES[ch]).new()
						mean[ch] = (foe.gold_min + foe.gold_max) * 0.5
						foe.free()
					foes += mean[ch] * (Enemy.CORRUPT_GOLD if zone == "zenis" else 1) * float(CombatTuning.ZONE_THREAT.get(zone, 1.0))
	return [chests, roundi(foes)]


func test_the_par_kit_is_affordable_without_grinding() -> void:
	var shops: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/shops.json"))
	var purse := Npc.KING_GOLD
	for step: Array in GOLD_PATH:
		var zone: String = step[0]
		var gold := _zone_gold(zone)
		purse += gold[0] / 2 + gold[1]
		for buy: Array in step[1]:
			var price := -1
			for entry: Dictionary in shops[buy[0]].stock:
				if entry.item == buy[1]:
					price = int(entry.price)
			check(price > 0, "%s sells %s" % [buy[0], buy[1]])
			purse -= price
			check(purse >= 0, "after %s, half the chests and one pass of foes buy %s (%d g left)" % [zone, buy[1], purse])


func test_a_deep_zones_foes_pay_as_they_hit() -> void:
	var room := Room.from_text("zone: dartmoor\n---\n" + "\n".join(PackedStringArray(_GOLD_ROOM)))
	arena.add_child(room)
	var foe := Monodron.new()
	foe.gold_min = 10
	foe.gold_max = 10
	foe.position = cell_feet(6, 3)
	room.add_child(foe)
	await frames(2)
	foe.die()
	await frames(2)
	var coins := 0
	for c in room.get_children():
		if c is Coin:
			coins += (c as Coin).value
	check(coins == 20, "a Dartmoor foe's 10 gold comes out as 20 (%d)" % coins)
