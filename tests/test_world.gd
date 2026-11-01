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


## Pass 120: lights that matter to play (a hag's wisp, a boss's lanterns) are
## lit before the decor's lanterns, so a room crowded with lanterns can never
## leave a foe dark.
func test_play_lights_come_before_the_lanterns() -> void:
	var w := _fog_world()
	await frames(3)
	var fog := w.fog
	var decor := w.room.get_node("Decor") as Decor
	var p := w.player
	for i in Fog.MAX_LIGHTS + 10:
		decor.glows.append(p.global_position + Vector2(i * 4.0, -30.0))
	var wisp := MarshHag.HagWisp.new()
	w.room.add_child(wisp)
	wisp.global_position = p.global_position + Vector2(200, -40)
	fog._update()
	check(fog.lights.size() == Fog.MAX_LIGHTS, "the room is crowded with lanterns (%d lights)" % fog.lights.size())
	check(fog.lights.has(Vector3(wisp.global_position.x, wisp.global_position.y, wisp.light_radius)), "and the wisp is still lit")
	check(fog.clear_at(wisp.global_position) == 1.0, "so the fog clears around it")


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


## Pass 358 (bible 13.3): a tablet read and a ward that turns you away each
## have their own sound. The tablets had borrowed the door's creak and the fog
## and the veil the spell-fail fizzle; a refusal is not a spell gone wrong.
func test_tablets_and_wards_sound_like_themselves() -> void:
	# The fog and the veil, refusing for real: once each, and never a fizzle.
	for stop: Array in [["mist/lantern_landing", "mist_curtain", Vector2(0, 30)], ["branches/north_bough", "stride_veil", Vector2(0, 16)]]:
		var w := make_world({}, stop[0], cell_feet(2, 2))
		await frames(3)
		var walls := runner.get_tree().get_nodes_in_group(stop[1])
		check(not walls.is_empty(), "%s has its %s" % [stop[0], stop[1]])
		if walls.is_empty():
			w.queue_free()
			await frames(2)
			continue
		Sfx.recent.clear()
		w.player.teleport((walls[0] as Node2D).global_position + stop[2])
		await frames(4)
		check(Sfx.recent.count("ward_refuse") == 1 and not Sfx.recent.has("fizzle"), "the %s pushes back once, no fizzle (%s)" % [stop[1], Sfx.recent])
		w.queue_free()
		await frames(2)
	# A tablet read for real.
	var w2 := make_world({}, "mist/lantern_landing")
	await frames(2)
	var tablet: LoreTablet = null
	for c in w2.room.get_children():
		if c is LoreTablet:
			tablet = c
	check(tablet != null, "the landing has a tablet")
	if tablet != null:
		Sfx.recent.clear()
		tablet.interact(w2.player)
		check(Sfx.recent == ["tablet_read"], "reading a tablet is heard as stone and runes, not a door (%s)" % [Sfx.recent])
	w2.queue_free()
	await frames(2)
	# Each is its own: no other script borrows them, and these three play neither cue they left.
	var owners := {"tablet_read": ["lore_tablet.gd"], "ward_refuse": ["mist_curtain.gd", "stride_veil.gd"]}
	var plays := RegEx.create_from_string("Sfx\\.play\\(\"([a-z_]+)\"")
	var dirs: Array[String] = ["res://scripts"]
	while not dirs.is_empty():
		var d: String = dirs.pop_back()
		for sub: String in DirAccess.get_directories_at(d):
			dirs.append(d + "/" + sub)
		for f: String in DirAccess.get_files_at(d):
			if not f.ends_with(".gd"):
				continue
			for m: RegExMatch in plays.search_all(FileAccess.get_file_as_string(d + "/" + f)):
				var cue := m.get_string(1)
				if owners.has(cue):
					check(f in owners[cue], "%s is played only by its own (%s)" % [cue, f])
				if f == "lore_tablet.gd":
					check(cue != "door", "a tablet does not creak like a door")
				if f in ["mist_curtain.gd", "stride_veil.gd"]:
					check(cue != "fizzle", "%s does not fizzle" % f)
	for cue: String in owners:
		check(FileAccess.file_exists("res://assets/sfx/%s.wav" % cue), "%s has a file" % cue)


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


## Bible 4.1 (A5): the Elven Stride in the Windloft grants the dash, which
## does nothing before it, and the game remembers it.
func test_elven_stride_grants_the_dash() -> void:
	var w := make_world({}, "branches/windloft")
	await frames(3)
	var p := w.player
	check(not p.abilities.stride, "the run starts without the Elven Stride")
	p.input.dash_pressed = true
	await frames(1)
	check(not p.is_dashing, "Dash does nothing without it")
	var feather: ItemPickup = null
	for c in w.room.get_children():
		if c is ItemPickup and (c as ItemPickup).kind == "stride":
			feather = c
	check(feather != null, "the Stride rests on the plinth")
	if feather == null:
		return
	p.teleport(feather.global_position + Vector2(0, 12))
	await frames(3)
	check(p.abilities.stride and GameState.data.abilities.stride, "taking it grants the dash and the save remembers it")
	await frames(10)
	p.input.dash_pressed = true
	await frames(1)
	check(p.is_dashing, "and now Dash strides")
	w._enter("branches/windloft")
	await frames(2)
	var again := false
	for c in w.room.get_children():
		again = again or (c is ItemPickup and (c as ItemPickup).kind == "stride")
	check(not again, "it doesn't come back")


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


## Bible 4.5: a bramble wall blocks like stone and shrugs off blades, but one
## fireball sets the whole knot alight; it burns to ash and stays burnt.
func test_fire_burns_the_bramble_for_good() -> void:
	var w := make_world({}, "daybreak/daybreak")
	await frames(3)
	var p := w.player
	var brambles := runner.get_tree().get_nodes_in_group("bramble")
	check(brambles.size() == 4, "four tiles of bramble choke the bell cellar (%d)" % brambles.size())
	if brambles.is_empty():
		return
	var first := brambles[0] as BrambleWall
	# A blade does nothing to it.
	p.teleport(first.global_position + Vector2(-20, 8 + 16 * 3))
	await frames(3)
	p.facing = 1
	p.input.attack_pressed = true
	await frames(12)
	check(brambles.all(func(b: BrambleWall) -> bool: return not b.burning and not b.burnt), "a blade only snags in it")
	# A fireball at its foot: the fire creeps through the whole knot.
	var ball := Fireball.new()
	w.room.add_child(ball)
	ball.global_position = (brambles[3] as BrambleWall).global_position + Vector2(-14, 0)
	ball.velocity = Vector2(200, 0)
	await frames(3)
	check((brambles[3] as BrambleWall).burning, "the fireball sets it alight")
	await frames(90)
	check(brambles.all(func(b: BrambleWall) -> bool: return b.burnt), "every tile burns to ash")
	check(GameState.is_collected((brambles[0] as BrambleWall).persist_id), "the save remembers")
	# Back again: it stays ash, and the cellar is open.
	w._enter("daybreak/daybreak")
	await frames(2)
	var again := runner.get_tree().get_nodes_in_group("bramble")
	var left := again.filter(func(b: BrambleWall) -> bool: return not b.burnt)
	check(again.size() == 4 and left.is_empty(), "it doesn't grow back (%d unburnt)" % left.size())


## Bible 4.1 (A6) and 4.5: the Thunder scroll grants the spell; a bolt cast near
## a dead conduit leaps to it and wakes it, and when the room's last conduit
## wakes its gate slides open for good.
func test_thunder_wakes_the_conduit_and_opens_the_gate() -> void:
	var w := make_world({}, "daybreak/spire_foot")
	await frames(3)
	var p := w.player
	check(not p.abilities.thunder, "the run starts without Thunder")
	var scroll: ItemPickup = null
	for c in w.room.get_children():
		if c is ItemPickup and (c as ItemPickup).kind == "thunder":
			scroll = c
	check(scroll != null, "the scroll lies on the lectern")
	if scroll == null:
		return
	p.teleport(scroll.global_position + Vector2(0, 12))
	await frames(3)
	check(p.abilities.thunder and GameState.data.abilities.thunder, "taking it grants Thunder")
	check(p.equipped_spell == "thunder", "and, with no other spell, puts it on the Spell button")
	var conduits := runner.get_tree().get_nodes_in_group("conductor")
	var gates := runner.get_tree().get_nodes_in_group("conduit_gate")
	check(conduits.size() == 1 and gates.size() == 3, "one conduit and a gate three tiles tall (%d, %d)" % [conduits.size(), gates.size()])
	if conduits.is_empty() or gates.is_empty():
		return
	var conduit := conduits[0] as Conduit
	# Cast from four tiles short of it: the bolt leaps the rest.
	p.teleport(conduit.global_position + Vector2(-64, 0))
	p.mp = p.max_mp
	await frames(20)
	p.facing = 1
	p.input.spell_pressed = true
	for i in 30:
		await frames(1)
		if conduit.powered:
			break
	check(conduit.powered, "the bolt leaps to the conduit and wakes it")
	check(GameState.flag("conduits:daybreak/spire_foot"), "the room remembers")
	await frames(60)
	check(gates.all(func(g: ConduitGate) -> bool: return g.opened), "and the gate slides open")
	w._enter("daybreak/spire_foot")
	await frames(2)
	var again := runner.get_tree().get_nodes_in_group("conduit_gate")
	check(not again.is_empty() and again.all(func(g: ConduitGate) -> bool: return g.opened), "back in the room the gate stays open")
	check((runner.get_tree().get_nodes_in_group("conductor")[0] as Conduit).powered, "and the conduit stays awake")


## The Spire Stair's hatch needs both its conduits awake, not just one.
func test_the_spire_hatch_needs_every_conduit() -> void:
	var w := make_world({}, "daybreak/spire_stair")
	await frames(3)
	var conduits := runner.get_tree().get_nodes_in_group("conductor")
	var gates := runner.get_tree().get_nodes_in_group("conduit_gate")
	check(conduits.size() == 2 and gates.size() == 3, "two conduits and a hatch three tiles wide (%d, %d)" % [conduits.size(), gates.size()])
	if conduits.size() < 2:
		return
	(conduits[0] as Conduit).power()
	await frames(2)
	check(gates.all(func(g: ConduitGate) -> bool: return not g.opened), "one conduit is not enough")
	(conduits[1] as Conduit).power()
	await frames(2)
	check(gates.all(func(g: ConduitGate) -> bool: return g.opened), "the second opens the hatch")
	check(GameState.flag("conduits:daybreak/spire_stair"), "for good")



# --- The Spring of Sky (bible 4.4, pass 62) -----------------------------------

func _spring_in(w: World) -> Spring:
	for c in w.room.get_children():
		if c is Spring:
			return c
	return null


func test_spring_of_sky_waits_for_the_roc_and_breaks_the_storm() -> void:
	var w := make_world({}, "daybreak/sky_spring", cell_feet(4, 19))
	GameState.set_flag("spring:trunk")
	GameState.set_flag("spring:mist")
	await frames(3)
	var spring := _spring_in(w)
	check(spring != null and spring.spring_id == "sky", "the Spring of Sky stands past the roost")
	check(not spring.is_in_group("interactable"), "it can't be cleared while Borabohra lives")
	var rain := w.motes._motes.size()
	check(rain == int(Motes.ZONES["daybreak"][0]), "the storm rains hard (%d drops)" % rain)
	GameState.set_flag("boss:borabohra")
	await frames(2)
	check(spring.is_in_group("interactable"), "once the roc falls it can")
	spring.interact(w.player)
	check(GameState.flag("spring:sky"), "clearing it restores the Spring of Sky")
	check(Fountain.level() == 3, "and the Eolis fountain runs full")
	check(w.motes._motes.size() < rain / 2, "the storm breaks: the rain thins to a drizzle (%d drops)" % w.motes._motes.size())


func test_eolis_holds_a_festival_for_the_last_spring() -> void:
	GameState.new_game()
	var names := func() -> Array:
		var room := Room.from_file("res://levels/eolis/plaza.room")
		arena.add_child(room)
		var out := []
		for c in room.get_children():
			if c is Npc:
				out.append((c as Npc).npc_id)
		room.queue_free()
		out.sort()
		return out
	var before: Array = names.call()
	check(before == ["townsfolk_well"], "before: Old Wena by the dry fountain (%s)" % [before])
	GameState.set_flag("spring:sky")
	var after: Array = names.call()
	check(after == ["festival_piper", "townsfolk_well_glad"], "after: a piper plays and Wena is glad (%s)" % [after])


func test_the_tree_blooms_once_the_evil_one_is_dead() -> void:
	var w := make_world({}, "eolis/plaza", cell_feet(10, 19))
	await frames(2)
	check(w.blossom.zone == "" and w.motes.count() > 0, "before the end: Eolis's dust, and no blossom")
	var dust := w.motes.count()
	GameState.set_flag("cleared")
	w.travel("trunk/entrance", cell_feet(6, 19))
	await frames(3)
	check(w.blossom.zone == "trunk" and w.blossom.count() == int(Motes.BLOSSOM[0]), "after it, blossom drifts through the Trunk")
	check(w.blossom.get("_motes").size() == w.blossom.count(), "a petal for each count (%d)" % w.blossom.count())
	for z: String in ["eolis", "trunk", "tower", "mist", "branches", "daybreak"]:
		check(Motes.blossom_table().has(z), "%s is a living zone of the Tree: it blooms" % z)
	check(not Motes.blossom_table().has("zenis") and not Motes.blossom_table().has("dartmoor"), "the meteor and the drowned city don't")
	w.travel("zenis/threshold", cell_feet(20, 19))
	await frames(3)
	check(w.blossom.get("_motes").is_empty(), "no blossom in the dead meteor")
	check(w.motes.count() == roundi(int(Motes.ZONES.zenis[0]) * 0.2), "and its spores have settled (%d)" % w.motes.count())
	check(dust > 0, "Eolis kept its dust (%d)" % dust)


func test_the_town_speaks_of_the_blooming_tree() -> void:
	var npcs: Dictionary = GameData.table("npcs")
	var talkers := 0
	for id: String in npcs:
		if String(npcs[id].get("role", "talk")) in ["talk", "king"]:
			talkers += 1
			check(npcs[id].has("lines_cleared") or not _stands_in_a_living_town(id), "%s has something to say once the Tree blooms" % id)
	check(talkers > 10, "the scan reads the talkers (%d)" % talkers)
	var king := GameData.npc("king")
	GameState.new_game()
	check(Npc.lines(king, "lines_after") == king.lines_after, "before the end the King says his piece")
	GameState.set_flag("cleared")
	check(Npc.lines(king, "lines_after") == king.lines_cleared and Npc.lines(king, "lines") == king.lines_cleared,
		"after it, he speaks of the blooming Tree")
	GameState.new_game()


## Victim (pass 145): a town in the fog is a string of warm pockets. Its lamp
## posts burn holes in the murk, its houses are lit from the first visit (its
## people never left), and the Feather Hollow's west shelf is the way in.
func test_victims_lamps_burn_pockets_in_the_fog() -> void:
	var w := make_world({}, "mist/victim", cell_feet(40, 19))
	await frames(3)
	var lamps: Array = []
	var houses := 0
	for c in w.room.get_children():
		if c is TownLamp:
			lamps.append(c)
		elif c is HouseFront:
			houses += 1
			check((c as HouseFront).style == "mist" and (c as HouseFront).lit(), "a boardwalk house is lit before any spring flows")
	check(lamps.size() >= 4 and houses >= 3, "Victim has its lamps (%d) and houses (%d)" % [lamps.size(), houses])
	check(w.fog.visible and w.fog.density > 0.0 and w.fog.density < Fog.ZONES["mist"], "the fog lies over the town, thinner than out in the marsh (%.2f)" % w.fog.density)
	var lamp := lamps[0] as TownLamp
	check(lamp.is_in_group("light"), "a lamp is a light")
	w.player.global_position = Vector2(lamp.global_position.x + 400, w.player.global_position.y)
	await frames(2)
	var seen := false
	for l: Vector3 in w.fog.lights:
		if is_equal_approx(l.x, lamp.global_position.x) and is_equal_approx(l.y, lamp.global_position.y):
			seen = l.z >= 80.0
	check(seen, "and the fog clears a pocket around its flame")
	check(w.fog.clear_at(lamp.global_position + Vector2(0, 20)) > 0.5, "so the street under it can be seen")
	check(w.fog.clear_at(lamp.global_position + Vector2(170, 0)) < 0.5, "while the dark between the lamps stays dark")
	# The door east is the Feather Hollow's west shelf.
	w._enter("mist/feather_hollow")
	await frames(2)
	check(w.room.doors.has(2) and String(w.room.doors[2].target) == "mist/victim", "the Feather Hollow's west door leads to Victim")


## Pass 146: coming up a shaft, you arrive inside the floor door of the room
## above, still rising. Fall back before you clear it and the door takes you
## back down; it used to be ignored, and you dropped out of the room's bottom.
func test_falling_back_down_a_shaft_takes_the_door_down() -> void:
	var w := make_world({}, "tower/mine_vault")
	await frames(3)
	w.use_door(1)
	while w.busy:
		await frames(1)
	check(w.room.id == "tower/rail_gallery", "the vault's shaft rises into the Rail Gallery")
	check(w.room.doors[2].edge == "bottom" and (w.room.doors[2].rect as Rect2).intersects(w.player.body_rect()), "arriving inside its floor door")
	# Stall at once, as a dash into the shaft's wall does, and fall.
	w.player.velocity = Vector2.ZERO
	var fell_out := false
	for i in 90:
		await frames(1)
		if w.room.id == "tower/rail_gallery" and w.player.global_position.y > w.room.pixel_rect().end.y + 8.0:
			fell_out = true
	check(not fell_out, "you never drop out of the bottom of the room")
	check(w.room.id == "tower/mine_vault", "the door takes you back down to the vault")


## Pass 151: the Mascon soak dropped down the Scorched Hall's floor shaft and met
## Mascon's spikes before it first landed. The hazard set it back at its last
## safe footing, which was still the Scorched Hall's, so it appeared inside
## Mascon's ground. A floor or ceiling door now makes its arrival the first safe spot.
func test_spikes_before_the_first_landing_set_you_back_in_the_new_room() -> void:
	var w := make_world({}, "mist/scorched_hall", cell_feet(4, 19))
	await frames(5)
	var old_safe := w.player.safe_position
	w.use_door(3)
	while w.busy:
		await frames(1)
	check(w.room.id == "mist/mascon", "the Scorched Hall's floor shaft drops into Mascon")
	var p := w.player
	check(p.safe_position != old_safe and w.room.pixel_rect().has_point(p.safe_position) and not w.room.is_solid_at(p.safe_position + Vector2(0, -8)),
		"the arrival under the shaft is the first safe spot (%s, was %s)" % [p.safe_position, old_safe])
	# Spikes before any landing: set back in Mascon, in the open.
	p._invuln_timer = 0.0
	p.take_damage(1, true)
	await frames(2)
	var body := p.body_rect().grow(-3.0)
	var embedded := false
	for corner in [body.position, Vector2(body.end.x, body.position.y), Vector2(body.position.x, body.end.y), body.end, body.get_center()]:
		embedded = embedded or w.room.is_solid_at(corner)
	check(w.room.id == "mist/mascon" and not embedded, "and a hazard there sets you back in the open (%s)" % p.global_position)
	# The first landing takes over as the safe footing.
	for i in 60:
		await frames(1)
		if p.is_on_floor():
			break
	await frames(3)
	check(p.is_on_floor() and absf(p.safe_position.y - p.global_position.y) < 1.0, "landing makes the footing safe again (%s)" % p.safe_position)


## People a player meets once the Evil One is dead: everyone but the Trunk's
## widow and Old Wena before their springs, who are swapped for glad selves.
func _stands_in_a_living_town(id: String) -> bool:
	return not id in ["townsfolk_well", "apolune_widow"]


func test_the_sky_key_opens_dartmoors_upper_gate() -> void:
	var w := make_world({}, "daybreak/sky_spring", cell_feet(30, 19))
	await frames(3)
	var gate: KeyDoor = null
	for c in w.room.get_children():
		if c is KeyDoor:
			gate = c
	check(gate != null and gate.kind == "sky", "a sky gate bars the way down")
	w.player.input.move_x = 1
	await frames(40)
	check(is_instance_valid(gate) and w.player.global_position.x < gate.global_position.x, "without the Sky Key it holds")
	GameState.add_key("sky")
	await frames(30)
	check(not is_instance_valid(gate) or gate.is_queued_for_deletion(), "with it, the gate opens")
	check(GameState.key_count("sky") == 0, "and the key stays in the lock")
	w.player.input.move_x = 0
	w._enter("daybreak/sky_spring")
	await frames(3)
	var again := 0
	for c in w.room.get_children():
		if c is KeyDoor:
			again += 1
	check(again == 0, "it stays open")



# --- Dartmoor (bible zone 6, pass 63) -----------------------------------------

func test_the_upper_gate_drops_you_into_dartmoor() -> void:
	var w := make_world({}, "daybreak/sky_spring", cell_feet(36, 19))
	await frames(3)
	for c in w.room.get_children():
		if c is KeyDoor:
			c.queue_free()
	var fell := false
	for i in 240:
		await frames(1)
		if w.room.id == "dartmoor/upper_stair":
			fell = true
			break
	check(fell, "the shaft past the upper gate drops you into the Upper Stair (%s)" % w.room.id)
	await frames(60)
	check(w.player.is_on_floor() and w.player.global_position.y < 9 * Room.TILE, "onto the top landing (%s)" % w.player.global_position)
	check(w.room.zone == "dartmoor" and Music.track == "dartmoor" and Music.ambience_track == "amb_dartmoor", "Dartmoor has its own theme and ambience (%s, %s)" % [Music.track, Music.ambience_track])
	check(w.motes.zone == "dartmoor" and w.motes._motes.size() > 0, "and crystal dust in the air")
	check(World.ZONES.has("dartmoor"), "the map knows the zone")


func test_the_gate_hall_has_a_shrine() -> void:
	var w := make_world({}, "dartmoor/gate_hall")
	await frames(3)
	var shrines := 0
	for c in w.room.get_children():
		if c is SaveShrine:
			shrines += 1
	check(shrines == 1, "the Upper Gate-Hall has a shrine to rest at")


## Eolis of Old (design bible 11, pass 152): a hidden room behind the Temple of
## Mantras, drawn as the NES drew it, with a four-voice chip tune.
func test_retro_rooms_keep_everything_inside_the_frame() -> void:
	# Playtest: Eolis of Old's way out sat behind the 4:3 frame's black bar.
	var cols := RetroFilter.visible_columns()
	check(cols == Vector2i(5, 34), "a one-screen room shows columns 5 to 34 in the frame (%s)" % cols)
	var parsed := Room.parse(FileAccess.get_file_as_string("res://levels/eolis/old_eolis.room"))
	check(str(parsed.header.get("retro", "")) == "true", "Eolis of Old is a retro room")
	var grid: Array[String] = parsed.grid
	var hidden := 0
	for y in grid.size():
		for x in grid[y].length():
			if (x < cols.x or x > cols.y) and grid[y][x] != "#":
				hidden += 1
	check(hidden == 0, "every column outside the frame is wall (%d open cells hidden)" % hidden)
	var doors := Room.scan_doors(grid)
	for n: int in doors:
		var r: Rect2i = doors[n].rect
		check(r.position.x - 1 >= cols.x and r.end.x <= cols.y, "door %d and its frame are in view (%s)" % [n, r])
	for key: String in ["sign", "chest", "prop"]:
		for spec: String in parsed.lists.get(key, []):
			var x := int(spec.split(",")[0])
			check(x >= cols.x and x <= cols.y, "%s at column %d is in view" % [key, x])


func test_eolis_of_old_hides_behind_the_temple() -> void:
	var w := make_world({}, "eolis/guru_temple", cell_feet(30, 19))
	await frames(5)
	check(not w.retro.visible and Music.track == "eolis", "the temple is drawn and scored as usual (%s)" % Music.track)
	check(not GameState.flag("secret:eolis/guru_temple"), "the chamber starts hidden")
	# Walk east into the stone: it is a fake wall, and the chamber behind is found.
	var p := w.player
	p.input.move_x = 1
	for i in 120:
		await frames(1)
		if p.global_position.x > 36.5 * Room.TILE:
			break
	p.input.move_x = 0
	check(p.global_position.x > 36.0 * Room.TILE, "the player walks through the temple's east wall (%s)" % p.global_position)
	check(GameState.flag("secret:eolis/guru_temple"), "and finds the hidden chamber")
	await frames(10)
	p.input.up_pressed = true
	p.input.up = true
	await frames(1)
	p.input.up_pressed = false
	p.input.up = false
	for i in 120:
		await frames(1)
		if not w.busy and w.room.id == "eolis/old_eolis":
			break
	check(w.room.id == "eolis/old_eolis", "Up at the chamber's door goes to Eolis of Old (%s)" % w.room.id)
	check(w.retro.visible and RetroFilter.is_retro(w.room), "Eolis of Old is drawn through the NES filter")
	check(w.retro.layer < 5, "under the game's UI layer, so the HUD is untouched")
	check(Music.track == "old_eolis", "and plays its chip tune (%s)" % Music.track)
	var stream := Music.stream_for("old_eolis")
	check(stream is AudioStreamOggVorbis and (stream as AudioStreamOggVorbis).loop, "the chip tune loads as a loop")
	check(w.room._chest_gold.values().has(1987), "its chest holds 1987 gold, the year of the original")
	w.use_door(1)
	while w.busy:
		await frames(1)
	check(w.room.id == "eolis/guru_temple" and not w.retro.visible and Music.track == "eolis", "back in the temple the filter is off and the town theme returns")


## Pass 155: the NES filter's blocks are whole world pixels. The world view draws
## at GameCamera.DETAIL with a pixel of margin (1284 x 724), so the filter takes
## its detail from the view (2), not from the view's height over 360 (2.01).
func test_the_nes_filter_blocks_on_world_pixels() -> void:
	check(RetroFilter.detail_for(null) == 1.0, "no view: one render pixel a world pixel")
	var vp := SubViewport.new()
	vp.size = Vector2i(642, 362) * GameCamera.DETAIL
	arena.add_child(vp)
	check(RetroFilter.detail_for(vp) == float(GameCamera.DETAIL), "the game's world view: %d (%.2f)" % [GameCamera.DETAIL, RetroFilter.detail_for(vp)])
	vp.queue_free()
	check(RetroFilter.SHADER.code.contains("block * detail"), "and a block is block x detail render pixels")


## Pass 178: the mini-bosses' towns know them. A squire by Conflate's east door
## points to the Thorn Yard and speaks differently once the Captain falls; in
## the Drowned Market, woken by King Grieve's fall, the old houndkeeper tells of
## the Alpha under the kennels and rests once it is wound down. Several room
## conditions, space-separated, must all hold.
func test_the_towns_know_their_mini_bosses() -> void:
	GameState.new_game()
	var ids := func(path: String) -> Array:
		var room := Room.from_file(path)
		arena.add_child(room)
		var out := room.get_children().filter(func(c: Node) -> bool: return c is Npc).map(func(c: Npc) -> String: return c.npc_id)
		room.free()
		return out
	const CONFLATE := "res://levels/branches/conflate.room"
	const MARKET := "res://levels/dartmoor/drowned_market.room"
	const MASCON := "res://levels/mist/mascon.room"
	var r: Array = ids.call(MASCON)
	check(r.has("mascon_reedcutter") and not r.has("mascon_reedcutter_glad"), "in Mascon, the reedcutter warns of the Matriarch past the east door (pass 179)")
	check(" ".join(GameData.npc("mascon_reedcutter").lines).contains("east door"), "and names where she waits")
	GameState.set_flag("boss:hag_matriarch")
	r = ids.call(MASCON)
	check(r.has("mascon_reedcutter_glad") and not r.has("mascon_reedcutter"), "and is glad once she sinks for good")
	var c: Array = ids.call(CONFLATE)
	check(c.has("conflate_squire") and not c.has("conflate_squire_glad"), "before the Captain falls, the squire points to the Thorn Yard")
	var m: Array = ids.call(MARKET)
	check(not m.has("dartmoor_houndkeeper") and not m.has("dartmoor_houndkeeper_glad"), "the drowned market is empty while Grieve reigns")
	GameState.set_flag("boss:clockwork_alpha")
	m = ids.call(MARKET)
	check(not m.has("dartmoor_houndkeeper_glad"), "an Alpha beaten first changes nothing until the market wakes")
	GameState.set_flag("boss:clockwork_alpha", false)
	GameState.set_flag("boss:king_grieve")
	m = ids.call(MARKET)
	check(m.has("dartmoor_houndkeeper") and not m.has("dartmoor_houndkeeper_glad"), "with Grieve gone, the houndkeeper tells of the Alpha")
	GameState.set_flag("boss:clockwork_alpha")
	GameState.set_flag("boss:bark_captain")
	m = ids.call(MARKET)
	c = ids.call(CONFLATE)
	check(m.has("dartmoor_houndkeeper_glad") and not m.has("dartmoor_houndkeeper"), "and rests once the Alpha is wound down")
	check(c.has("conflate_squire_glad") and not c.has("conflate_squire"), "the squire speaks of the Captain's fall")
	var hint: Array = GameData.npc("conflate_squire").lines
	check(" ".join(hint).contains("Thorn Yard") and " ".join(GameData.npc("dartmoor_houndkeeper").lines).contains("kennels"), "each hint names where the guardian waits")
	check(Room.flags_hold("boss:king_grieve boss:clockwork_alpha") and not Room.flags_hold("boss:king_grieve !boss:clockwork_alpha") and Room.flags_hold(""),
		"conditions all have to hold")
	GameState.new_game()


## Design bible 3 (pass 195): no room is more than SAVE_REACH rooms (doors
## walked) from a Meditation Shrine or a Guru, and where foes hit at double
## (CombatTuning.ZONE_THREAT, 5.5) no more than DEEP_SAVE_REACH.
const SAVE_REACH := 4
const DEEP_SAVE_REACH := 3


func test_no_room_is_far_from_a_rest() -> void:
	var npcs: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/npcs.json"))
	var links := {}
	var zones := {}
	var rests: Array[String] = []
	for zone in DirAccess.get_directories_at("res://levels"):
		if zone == "gym" or zone == "trials":
			continue
		for f in DirAccess.get_files_at("res://levels/" + zone):
			if not f.ends_with(".room"):
				continue
			var id := zone + "/" + f.get_basename()
			var parsed := Room.parse(FileAccess.get_file_as_string("res://levels/%s/%s" % [zone, f]))
			zones[id] = zone
			if not links.has(id):
				links[id] = {}
			for spec: String in parsed.lists.get("door", []):
				var to := spec.split(",")[1].strip_edges()
				links[id][to] = true
				if not links.has(to):
					links[to] = {}
				links[to][id] = true
			var rest := false
			for row: String in parsed.grid:
				rest = rest or row.contains("S")
			for spec: String in parsed.lists.get("npc", []):
				var who := spec.split(",")[2].strip_edges()
				rest = rest or str(npcs.get(who, {}).get("role", "")) == "guru"
			if rest:
				rests.append(id)
	check(rests.size() >= 25, "the world has its shrines and Gurus (%d)" % rests.size())
	var dist := {}
	var queue: Array[String] = []
	for id in rests:
		dist[id] = 0
		queue.append(id)
	while not queue.is_empty():
		var at: String = queue.pop_front()
		for to: String in links.get(at, {}):
			if not dist.has(to):
				dist[to] = dist[at] + 1
				queue.append(to)
	for id: String in zones:
		var deep := float(CombatTuning.ZONE_THREAT.get(zones[id], 1.0)) >= 2.0
		var reach := DEEP_SAVE_REACH if deep else SAVE_REACH
		check(dist.has(id) and int(dist[id]) <= reach, "%s is within %d rooms of a rest (%s)" % [id, reach, dist.get(id, "none")])
