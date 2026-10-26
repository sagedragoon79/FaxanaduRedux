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
