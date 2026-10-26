extends TestSuite
## Random-input soaks: catch the player escaping a room, getting embedded in
## solid tiles or producing invalid positions, and scenes that pile up nodes or
## blow the frame budget.

const RUNS := [1987, 2026, 42]
const FRAMES_PER_RUN := 900

const ACTIONS := ["jump", "attack", "dash", "spell", "heal", "block"]


func test_random_input_soak_in_gym() -> void:
	var problems: Array[String] = []
	for seed in RUNS:
		var room := Room.from_file("res://levels/gym/gym.room")
		arena.add_child(room)
		var p := Player.new()
		p.input.scripted = true
		p.position = room.spawn_position
		room.add_child(p)
		p.spawn_point = room.spawn_position
		var rng := RandomNumberGenerator.new()
		rng.seed = seed
		var hold := {"move": 0, "down": 0, "up": 0, "jump": 0, "block": 0}
		var bounds := room.pixel_rect().grow(8.0)
		for f in FRAMES_PER_RUN:
			_mash(p, rng, hold)
			await frames(1)
			var pos := p.global_position
			if not (is_finite(pos.x) and is_finite(pos.y)):
				problems.append("seed %d frame %d: invalid position" % [seed, f])
				break
			if p.dead:
				continue
			if not bounds.has_point(pos):
				problems.append("seed %d frame %d: left the room at %s" % [seed, f, pos])
				break
			var body := p.body_rect().grow(-3.0)
			for corner in [body.position, Vector2(body.end.x, body.position.y), Vector2(body.position.x, body.end.y), body.end, body.get_center()]:
				if room.is_solid_at(corner):
					problems.append("seed %d frame %d: embedded in a solid tile at %s" % [seed, f, pos])
					break
			if problems.size() > 0:
				break
		room.queue_free()
		await frames(1)
	check(problems.is_empty(), "soak found no problems: %s" % [problems])


## One frame of button-mashing: inputs persist for random spans, like a player.
func _mash(p: Player, rng: RandomNumberGenerator, hold: Dictionary) -> void:
	if hold.move <= 0:
		p.input.move_x = rng.randi_range(-1, 1)
		hold.move = rng.randi_range(5, 40)
	if hold.down <= 0:
		p.input.down = rng.randf() < 0.2
		hold.down = rng.randi_range(5, 30)
	if hold.up <= 0:
		p.input.up = rng.randf() < 0.15
		hold.up = rng.randi_range(5, 30)
	if hold.jump <= 0:
		p.input.jump_held = rng.randf() < 0.4
		p.input.jump_pressed = p.input.jump_held
		hold.jump = rng.randi_range(3, 30)
	if hold.block <= 0:
		p.input.block_held = rng.randf() < 0.1
		p.input.block_pressed = p.input.block_held
		hold.block = rng.randi_range(5, 40)
	# Attack is held for spans too (pass 151), most of them long enough to
	# charge a Thrust; letting go then thrusts if the skill is learned.
	var was_held := p.input.attack_held
	if int(hold.get("attack", 0)) <= 0:
		p.input.attack_held = rng.randf() < 0.3
		hold["attack"] = rng.randi_range(4, 60)
	for k: String in hold:
		hold[k] -= 1
	p.input.attack_pressed = rng.randf() < 0.08 or (p.input.attack_held and not was_held)
	p.input.dash_pressed = rng.randf() < 0.03
	p.input.spell_pressed = rng.randf() < 0.01
	p.input.heal_pressed = rng.randf() < 0.005


func _embedded(room: Room, p: Player) -> bool:
	var body := p.body_rect().grow(-3.0)
	for corner in [body.position, Vector2(body.end.x, body.position.y), Vector2(body.position.x, body.end.y), body.end, body.get_center()]:
		if room.is_solid_at(corner):
			return true
	return false


const TOWER_FRAMES := 420
## Long enough for the Hour Glass to be turned twice in each room.
const GLASS_FRAMES := 660


## Every Tower room, live (enemies, doors, gates), with every ability and a
## mashing player: no escapes, no embedding, and the room's node count settles.
func test_random_input_soak_in_every_tower_room() -> void:
	await _soak_zone("tower", "Tower")


## The same soak over every Eolis and Trunk room, so the first two zones keep up
## with changes made for later ones.
func test_random_input_soak_in_every_eolis_and_trunk_room() -> void:
	await _soak_zone("eolis", "Eolis")
	await _soak_zone("trunk", "Trunk")


## The Mist under its fog: the same soak, and the fog never runs out of lights.
func test_random_input_soak_in_every_mist_room() -> void:
	await _soak_zone("mist", "Mist")


## The Branches: the canopy's rooms, bounce-pods and all.
func test_random_input_soak_in_every_branches_room() -> void:
	await _soak_zone("branches", "Branches")


## Daybreak: storm rain, sky islands and crystal-thorned cliffs.
func test_random_input_soak_in_every_daybreak_room() -> void:
	await _soak_zone("daybreak", "Daybreak")


## Dartmoor, with the Hour Glass turned whenever it is ready: frozen water,
## projectiles held in the air, and time running on again, room after room.
func test_random_input_soak_in_every_dartmoor_room() -> void:
	await _soak_zone("dartmoor", "Dartmoor", true)


## Zenis: spores, flesh and the meteor's light, room after room.
func test_random_input_soak_in_every_zenis_room() -> void:
	await _soak_zone("zenis", "Zenis")


## The Sunken Spring: swimming, eels and the water drawn over everything.
func test_random_input_soak_in_every_sunken_spring_room() -> void:
	await _soak_zone("sunken", "Sunken Spring")


## The Guru Trials' mantra-space (pass 113), off the map but built like any zone.
func test_random_input_soak_in_every_trial_room() -> void:
	await _soak_zone("trials", "Trials")


## Daybreak's storm: rain streaks on the wind over the lightning backdrop,
## the player running and dashing about. The rain stays on screen, keeps its
## count, and the frame stays well inside budget.
func test_daybreak_rain_stays_cheap() -> void:
	var w := make_world({}, "daybreak/sky_steps")
	var p := w.player
	p.abilities["stride"] = true
	await frames(2)
	check(w.motes.zone == "daybreak" and w.motes._motes.size() == int(Motes.ZONES["daybreak"][0]), "the rain is falling (%d drops)" % w.motes._motes.size())
	var total_usec := 0
	var worst := 0
	const RAIN_FRAMES := 600
	for f in RAIN_FRAMES:
		p.input.move_x = 1 if (f / 90) % 2 == 0 else -1
		p.input.jump_pressed = f % 40 == 0
		p.input.jump_held = f % 40 < 12
		p.input.dash_pressed = f % 40 == 14
		var t0 := Time.get_ticks_usec()
		await frames(1)
		var dt := Time.get_ticks_usec() - t0
		total_usec += dt
		worst = maxi(worst, dt)
	var avg_ms := total_usec / 1000.0 / RAIN_FRAMES
	print("  Daybreak rain: %.2f ms a frame on average, %.2f ms at worst" % [avg_ms, worst / 1000.0])
	var inside := true
	for m: Array in w.motes._motes:
		var at: Vector2 = m[0]
		inside = inside and at.x >= 0.0 and at.x < Motes.VIEW.x and at.y >= 0.0 and at.y < Motes.VIEW.y
	check(inside, "every drop wraps back onto the screen")
	check(w.motes._motes.size() == int(Motes.ZONES["daybreak"][0]), "and none are lost or added")
	check(avg_ms < 8.0, "a storm frame averages well under budget (%.2f ms)" % avg_ms)
	w._enter("branches/crown_leaf")
	await frames(2)
	check(w.motes.zone == "branches", "back in the Branches the rain stops")
	w.queue_free()
	await frames(2)


## The fog's CPU side in every Mist room: the player walked across the room,
## the light list rebuilt each frame. It must stay cheap and never hit
## Fog.MAX_LIGHTS (the shader would drop lanterns).
func test_fog_stays_cheap_in_every_mist_room() -> void:
	var dir := DirAccess.open("res://levels/mist")
	var problems: Array[String] = []
	var report: Array[String] = []
	for f in dir.get_files():
		if not f.ends_with(".room"):
			continue
		var id := "mist/" + f.trim_suffix(".room")
		var w := make_world({}, id)
		await frames(2)
		var fog := w.fog
		var rect := w.room.pixel_rect()
		var most := 0
		var total_usec := 0
		const STEPS := 120
		for i in STEPS:
			# Sweep the player (and so the camera) across the room, row by row.
			var at := Vector2(rect.position.x + rect.size.x * fmod(i * 0.083, 1.0), rect.position.y + rect.size.y * (0.2 + 0.6 * float(i) / STEPS))
			w.player.global_position = at
			await frames(1)
			var t0 := Time.get_ticks_usec()
			fog._update()
			total_usec += Time.get_ticks_usec() - t0
			most = maxi(most, fog.lights.size())
		var avg_ms := total_usec / 1000.0 / STEPS
		report.append("%s %.3f ms, %d lights" % [id, avg_ms, most])
		if most >= Fog.MAX_LIGHTS:
			problems.append("%s: the fog ran out of lights (%d)" % [id, most])
		if avg_ms > 0.5:
			problems.append("%s: the fog update takes %.3f ms" % [id, avg_ms])
		w.queue_free()
		await frames(2)
	print("  Fog: " + ", ".join(report))
	check(problems.is_empty(), "the fog is cheap and never short of lights: %s" % [problems])


## Ripasheiku at full tilt for 30 seconds against a mashing player who can't
## die: under the fog, with her lanterns as lights. Effects clean up after
## themselves and a frame stays well inside the 60 fps budget.
func test_widow_fight_soak_stays_lean() -> void:
	var w := make_world({}, "mist/sunken_chapel", cell_feet(10, 19))
	w.player.max_hp = 99999
	w.player.hp = 99999
	await frames(30)
	var boss := runner.get_tree().get_first_node_in_group("boss") as Ripasheiku
	check(boss != null, "Ripasheiku wakes")
	if boss == null:
		return
	boss.max_hp = 99999
	boss.hp = 99999
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var hold := {"move": 0, "down": 0, "up": 0, "jump": 0, "block": 0}
	var start_nodes := _count_nodes(w)
	var peak := start_nodes
	var total_usec := 0
	var slowest := 0
	var states := {}
	const FIGHT_FRAMES := 1800
	for f in FIGHT_FRAMES:
		_mash(w.player, rng, hold)
		# Force phase 2 halfway through, so the vault, webs and drops are soaked too.
		if f == FIGHT_FRAMES / 2 and boss.phase == 1:
			boss.hp = roundi(boss.max_hp * 0.6)
			boss._check_phase()
		var t0 := Time.get_ticks_usec()
		await frames(1)
		var dt := Time.get_ticks_usec() - t0
		total_usec += dt
		slowest = maxi(slowest, dt)
		states[boss.state] = true
		peak = maxi(peak, _count_nodes(w))
		if not boss.arena.grow(32.0).has_point(boss.global_position):
			check(false, "she left the chapel at %s (%s)" % [boss.global_position, boss.state])
			break
	var avg_ms := total_usec / 1000.0 / FIGHT_FRAMES
	print("  Widow soak: %.2f ms a frame on average, slowest %.1f ms, nodes %d -> %d, states %s" % [avg_ms, slowest / 1000.0, start_nodes, peak, states.keys()])
	check(peak < start_nodes + 60, "effects never pile up (%d -> %d nodes)" % [start_nodes, peak])
	check(avg_ms < 16.6, "a frame averages under the 60 fps budget (%.2f ms)" % avg_ms)
	check(states.has("hang") or states.has("climb"), "the soak reached her vault phase")
	check(is_instance_valid(boss) and boss.state != "dead", "the fight ran its course")
	w.player.pull = Vector2.ZERO
	w.queue_free()
	await frames(2)


## Zorugeriru through all three phases, 30 seconds against a mashing player who
## can't die: breaths, bites, the fourth head and the flood clean up after
## themselves, and a frame stays well inside the 60 fps budget.
func test_hydra_fight_soak_stays_lean() -> void:
	var w := make_world({}, "mist/spring_of_mist", cell_feet(7, 19))
	w.player.max_hp = 99999
	w.player.hp = 99999
	await frames(30)
	var boss := runner.get_tree().get_first_node_in_group("boss") as Zorugeriru
	check(boss != null, "Zorugeriru wakes")
	if boss == null:
		return
	boss.max_hp = 99999
	boss.hp = 99999
	var rng := RandomNumberGenerator.new()
	rng.seed = 23
	var hold := {"move": 0, "down": 0, "up": 0, "jump": 0, "block": 0}
	var start_nodes := _count_nodes(w)
	var peak := start_nodes
	var total_usec := 0
	var slowest := 0
	var modes := {}
	const FIGHT_FRAMES := 1800
	for f in FIGHT_FRAMES:
		_mash(w.player, rng, hold)
		# Phase 2 a third of the way in (the tanks filled), phase 3 at two thirds.
		if f == FIGHT_FRAMES / 3 and boss.phase == 1:
			boss.hp = roundi(boss.max_hp * 0.6)
			boss._check_phase()
			for c in w.room.get_children():
				if c is DryBasin:
					c.douse()
		if f == FIGHT_FRAMES * 2 / 3 and boss.phase == 2:
			boss.hp = roundi(boss.max_hp * 0.3)
			boss._check_phase()
		var t0 := Time.get_ticks_usec()
		await frames(1)
		var dt := Time.get_ticks_usec() - t0
		total_usec += dt
		slowest = maxi(slowest, dt)
		for h in boss.heads:
			modes[h.mode] = true
		peak = maxi(peak, _count_nodes(w))
	var avg_ms := total_usec / 1000.0 / FIGHT_FRAMES
	print("  Hydra soak: %.2f ms a frame on average, slowest %.1f ms, nodes %d -> %d, modes %s" % [avg_ms, slowest / 1000.0, start_nodes, peak, modes.keys()])
	check(peak < start_nodes + 60, "effects never pile up (%d -> %d nodes)" % [start_nodes, peak])
	check(avg_ms < 16.6, "a frame averages under the 60 fps budget (%.2f ms)" % avg_ms)
	check(boss.phase == 3 and is_instance_valid(boss.flood), "the soak reached the flood")
	check(modes.has("breath") and modes.has("emerge"), "breaths and the fourth head were soaked too")
	w.queue_free()
	await frames(2)


func _soak_zone(zone: String, label: String, glass := false) -> void:
	var problems: Array[String] = []
	var turns := 0
	var total_usec := 0
	var counted := 0
	var thrusts := 0
	var dir := DirAccess.open("res://levels/" + zone)
	var ids: Array[String] = []
	for f in dir.get_files():
		if f.ends_with(".room"):
			ids.append(zone + "/" + f.trim_suffix(".room"))
	ids.sort()
	if OS.get_environment("SOAK_ONLY") != "":
		ids = ids.filter(func(i: String) -> bool: return i in OS.get_environment("SOAK_ONLY").split(","))
	for id in ids:
		var w := make_world({}, id)
		for k: String in GameState.data.abilities:
			GameState.data.abilities[k] = true
			w.player.abilities[k] = true
		_learn_the_blade(w)
		w.player.max_hp = 99999
		w.player.hp = 99999
		var rng := RandomNumberGenerator.new()
		rng.seed = hash(id)
		var hold := {"move": 0, "down": 0, "up": 0, "jump": 0, "block": 0}
		await frames(2)
		var start_nodes := _count_nodes(w)
		var peak := start_nodes
		for f in (GLASS_FRAMES if glass else TOWER_FRAMES):
			_mash(w.player, rng, hold)
			if glass and f % 45 == 0 and TimeStop.ready_to_turn():
				w.player.input.hourglass_pressed = true
				turns += 1
			var t0 := Time.get_ticks_usec()
			await frames(1)
			total_usec += Time.get_ticks_usec() - t0
			counted += 1
			var p := w.player
			if p.dead or w.room == null:
				continue
			var pos := p.global_position
			if not (is_finite(pos.x) and is_finite(pos.y)):
				problems.append("%s frame %d: invalid position" % [id, f])
				break
			if not w.room.pixel_rect().grow(24.0).has_point(pos):
				problems.append("%s frame %d: left %s at %s" % [id, f, w.room.id, pos])
				break
			if _embedded(w.room, p):
				var vel := p.velocity
				await frames(3)
				if _embedded(w.room, w.player):
					problems.append("%s frame %d: embedded in %s at %s (vel %s), still at %s" % [id, f, w.room.id, pos, vel, w.player.global_position])
					break
				print("  transient overlap: %s frame %d in %s at %s vel %s" % [id, f, w.room.id, pos, vel])
			peak = maxi(peak, _count_nodes(w))
		if peak > start_nodes + 400:
			problems.append("%s: nodes grew from %d to %d" % [id, start_nodes, peak])
		thrusts += w.player.thrusts
		w.queue_free()
		await frames(2)
	check(problems.is_empty(), "%d %s rooms soaked with no problems: %s" % [ids.size(), label, problems])
	var avg_ms := total_usec / 1000.0 / maxi(counted, 1)
	print("  %s soak: %.2f ms a frame on average" % [label, avg_ms])
	check(avg_ms < 16.6, "a %s frame averages under the 60 fps budget (%.2f ms)" % [label, avg_ms])
	print("  %s soak: %d thrusts" % [label, thrusts])
	if zone != "sunken":
		# (Underwater a charge is spent: the Sunken Spring is all swimming.)
		check(thrusts > 0, "the mashing player thrust %d times across %d %s rooms" % [thrusts, ids.size(), label])
	if glass:
		check(turns >= ids.size() * 2, "the Hour Glass was turned %d times along the way" % turns)
		TimeStop.reset()


## The Foreman fight at full tilt: a mashing player who can't die, 30 seconds.
## Shockwaves, boulders and falling rocks must clean up after themselves, and a
## frame must stay well inside the 60 fps budget.
func test_foreman_fight_soak_stays_lean() -> void:
	var w := make_world({}, "tower/foreman_hall", cell_feet(10, 19))
	w.player.max_hp = 99999
	w.player.hp = 99999
	await frames(30)
	var boss := runner.get_tree().get_first_node_in_group("boss") as Foreman
	check(boss != null, "the Foreman wakes")
	if boss == null:
		return
	boss.max_hp = 99999
	boss.hp = 99999
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var hold := {"move": 0, "down": 0, "up": 0, "jump": 0, "block": 0}
	var transient := 0
	var worst := 0
	var total_usec := 0
	var slowest := 0
	const FIGHT_FRAMES := 1800
	for f in FIGHT_FRAMES:
		_mash(w.player, rng, hold)
		var t0 := Time.get_ticks_usec()
		await frames(1)
		var dt := Time.get_ticks_usec() - t0
		total_usec += dt
		slowest = maxi(slowest, dt)
		transient = 0
		for c in w.room.get_children():
			if c is Shockwave or c is Rubble or c is Dust:
				transient += 1
		worst = maxi(worst, transient)
	var avg_ms := total_usec / 1000.0 / FIGHT_FRAMES
	print("  Foreman soak: %.2f ms a frame on average, slowest %.1f ms, at most %d effects live" % [avg_ms, slowest / 1000.0, worst])
	check(worst < 60, "effects never pile up (at most %d live)" % worst)
	check(avg_ms < 16.6, "a frame averages under the 60 fps budget (%.2f ms)" % avg_ms)
	check(boss.state != "dead" and is_instance_valid(boss), "the fight ran its course")
	w.queue_free()
	await frames(2)


## The HUD redraws every frame: health draining and refilling through every
## part-filled mask, poisoned half the time, a Life Fruit's half mask, the
## magic bar and the flasks changing. It must draw each frame and stay cheap.
func test_hud_soak_draws_every_frame_and_stays_lean() -> void:
	var w := make_world({}, "tower/winch_hall")
	var hud := GameHud.new()
	hud.player = w.player
	arena.add_child(hud)
	w.player.max_hp = 110
	w.player.abilities["hourglass"] = true
	await frames(2)
	var start := hud.draws
	var total_usec := 0
	const HUD_FRAMES := 600
	for f in HUD_FRAMES:
		w.player.hp = int(absf(sin(f * 0.05)) * w.player.max_hp)
		w.player.mp = fmod(f * 3.0, w.player.max_mp + 1.0)
		w.player.poison_left = 1.0 if (f / 60) % 2 == 1 else 0.0
		w.player.flask_charges = f % (w.player.flask_max + 1)
		if f % 200 == 0:
			TimeStop.reset()
			TimeStop.start()
		var t0 := Time.get_ticks_usec()
		await frames(1)
		total_usec += Time.get_ticks_usec() - t0
	var drawn := hud.draws - start
	var avg_ms := total_usec / 1000.0 / HUD_FRAMES
	print("  HUD soak: %.2f ms a frame on average, %d draws" % [avg_ms, drawn])
	check(drawn >= HUD_FRAMES - 2, "the HUD redraws every frame (%d of %d)" % [drawn, HUD_FRAMES])
	check(avg_ms < 16.6, "a frame with the HUD averages under the 60 fps budget (%.2f ms)" % avg_ms)
	w.player.poison_left = 0.0
	hud.queue_free()
	w.queue_free()
	await frames(2)


func _count_nodes(w: World) -> int:
	return w.room.get_child_count() if w.room != null else 0


## Mantra Path hops and lift rides, back and forth, with mashing in between:
## every arrival is in the right room, on open floor.
func test_mantra_path_and_lift_travel_soak() -> void:
	var w := make_world({}, "tower/forepaw")
	await frames(2)
	var menu := ListMenu.new()
	arena.add_child(menu)
	GameState.set_flag("spring:trunk")
	GameState.set_flag("boss:zoradohna")
	for stop: Array in [["eolis/guru_temple", 22], ["trunk/apolune", 12], ["tower/forepaw", 10]]:
		GameState.meet_guru(stop[0], Vector2(int(stop[1]) * Room.TILE + 8, 20 * Room.TILE))
	var problems: Array[String] = []
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var hold := {"move": 0, "down": 0, "up": 0, "jump": 0, "block": 0}
	w.player.input.scripted = true
	for hop in 9:
		var stops := GameState.mantra_stops(w.room.id)
		Menus.open_mantra_path(arena.get_tree(), w.player)
		menu.cursor = hop % stops.size()
		var to: String = stops[menu.cursor]
		menu.confirm()
		await frames(3)
		if w.room.id != to:
			problems.append("hop %d: in %s, not %s" % [hop, w.room.id, to])
			break
		if _embedded(w.room, w.player) or not w.room.pixel_rect().has_point(w.player.global_position):
			problems.append("hop %d: bad arrival in %s at %s" % [hop, to, w.player.global_position])
		for f in 40:
			_mash(w.player, rng, hold)
			await frames(1)
		w.player.input.move_x = 0
	# The lift, down and up three times, picking the stop from its menu.
	w.travel("tower/forepaw", Vector2(71 * Room.TILE + 8, 20 * Room.TILE))
	await frames(3)
	for ride in 6:
		var cage: LiftCage = null
		for c in w.room.get_children():
			if c is LiftCage:
				cage = c
		var to: String = cage.destination()[0]
		cage.interact(w.player)
		await frames(1)
		# The cage asks for a stop: pick its usual one.
		menu.cursor = cage.other_stops().map(func(st: Array) -> String: return st[0]).find(to)
		menu.confirm()
		await frames(3)
		if w.room.id != to or _embedded(w.room, w.player):
			problems.append("ride %d: in %s at %s" % [ride, w.room.id, w.player.global_position])
			break
	check(problems.is_empty(), "travel soak found no problems: %s" % [problems])
	menu.queue_free()


func test_bloom_fight_soak_stays_lean() -> void:
	var w := make_world({}, "branches/crown_leaf", cell_feet(9, 19))
	w.player.max_hp = 99999
	w.player.hp = 99999
	w.player.abilities["stride"] = true
	await frames(30)
	var boss := runner.get_tree().get_first_node_in_group("boss") as Pakukame
	check(boss != null, "Pakukame wakes")
	if boss == null:
		return
	boss.max_hp = 99999
	boss.hp = 99999
	var rng := RandomNumberGenerator.new()
	rng.seed = 31
	var hold := {"move": 0, "down": 0, "up": 0, "jump": 0, "block": 0}
	var start_nodes := _count_nodes(w)
	var peak := start_nodes
	var total_usec := 0
	var slowest := 0
	var states := {}
	const FIGHT_FRAMES := 1800
	for f in FIGHT_FRAMES:
		_mash(w.player, rng, hold)
		if f % 300 == 150 and w.player.is_on_floor() and not w.player.dead:
			# Into biting range now and then: the mashing alone may keep its
			# distance for the whole fight, and then the bite is never soaked.
			var side := -1.0 if w.player.global_position.x < boss.global_position.x else 1.0
			w.player.teleport(Vector2(boss.global_position.x + side * Pakukame.BITE_RANGE * 0.5, w.player.global_position.y))
		# Phase 2 halfway through, so the leaf gets torn too.
		if f == FIGHT_FRAMES / 2 and boss.phase == 1:
			boss.phase = 2
		var t0 := Time.get_ticks_usec()
		await frames(1)
		var dt := Time.get_ticks_usec() - t0
		total_usec += dt
		slowest = maxi(slowest, dt)
		states[boss.state] = true
		peak = maxi(peak, _count_nodes(w))
	var avg_ms := total_usec / 1000.0 / FIGHT_FRAMES
	print("  Bloom soak: %.2f ms a frame on average, slowest %.1f ms, nodes %d -> %d, gaps %d, states %s" % [avg_ms, slowest / 1000.0, start_nodes, peak, boss.gaps.size(), states.keys()])
	check(peak < start_nodes + 60, "effects never pile up (%d -> %d nodes)" % [start_nodes, peak])
	check(avg_ms < 16.6, "a frame averages under the 60 fps budget (%.2f ms)" % avg_ms)
	check(states.has("gape") and states.has("whip"), "bites and lashes were soaked")
	check(boss.gaps.size() <= Pakukame.MAX_GAPS, "the leaf is never torn past %d gaps" % Pakukame.MAX_GAPS)
	w.queue_free()
	await frames(2)


## The Storm Roc fight at full tilt: a mashing player who can't die, 30 seconds,
## with the conduits woken every ten seconds so it is grounded and rises again.
func test_roc_fight_soak_stays_lean() -> void:
	var w := make_world({}, "daybreak/roost", cell_feet(9, 25))
	w.player.max_hp = 99999
	w.player.hp = 99999
	w.player.abilities["stride"] = true
	await frames(30)
	var boss := runner.get_tree().get_first_node_in_group("boss") as Borabohra
	check(boss != null, "Borabohra wakes")
	if boss == null:
		return
	boss.max_hp = 99999
	boss.hp = 99999
	var rng := RandomNumberGenerator.new()
	rng.seed = 37
	var bolts := 0
	var seen := {}
	var hold := {"move": 0, "down": 0, "up": 0, "jump": 0, "block": 0}
	var start_nodes := _count_nodes(w)
	var peak := start_nodes
	var total_usec := 0
	var slowest := 0
	var states := {}
	const FIGHT_FRAMES := 1800
	for f in FIGHT_FRAMES:
		_mash(w.player, rng, hold)
		if f % 600 == 450:
			for c in runner.get_tree().get_nodes_in_group("conductor"):
				(c as Conduit).power()
		# The storm breaks halfway through, so its bolts are soaked too.
		if f == FIGHT_FRAMES / 2:
			boss.phase = 2
		var t0 := Time.get_ticks_usec()
		await frames(1)
		var dt := Time.get_ticks_usec() - t0
		total_usec += dt
		slowest = maxi(slowest, dt)
		states[boss.state] = true
		peak = maxi(peak, _count_nodes(w))
		for c in w.room.get_children():
			if c is StormStrike and not seen.has(c.get_instance_id()):
				seen[c.get_instance_id()] = true
				bolts += 1
	var avg_ms := total_usec / 1000.0 / FIGHT_FRAMES
	print("  Roc soak: %.2f ms a frame on average, slowest %.1f ms, nodes %d -> %d, states %s" % [avg_ms, slowest / 1000.0, start_nodes, peak, states.keys()])
	check(peak < start_nodes + 60, "effects never pile up (%d -> %d nodes)" % [start_nodes, peak])
	check(avg_ms < 16.6, "a frame averages under the 60 fps budget (%.2f ms)" % avg_ms)
	check(states.has("dive") and states.has("volley_tell") and states.has("grounded") and states.has("rise"), "dives, volleys and groundings were soaked")
	check(bolts > 0, "and storm bolts (%d)" % bolts)
	check(boss.state != "dead" and is_instance_valid(boss), "the fight ran its course")
	w.queue_free()
	await frames(2)


## The Waterfall Stair's two falls, flowing and frozen in turn: their streaks
## are two scrolled textures each, so a frame stays cheap.
func test_waterfalls_stay_cheap() -> void:
	var w := make_world({}, "dartmoor/waterfall_stair")
	w.player.abilities["hourglass"] = true
	await frames(2)
	var falls: Array = w.room.get_children().filter(func(c: Node) -> bool: return c is Waterfall)
	check(falls.size() == 2 and falls.all(func(f: Waterfall) -> bool: return f._streaks.size() == 2), "each fall draws from two streak textures")
	var total_usec := 0
	const FALL_FRAMES := 600
	for f in FALL_FRAMES:
		if f % 300 == 0:
			TimeStop.reset()
			TimeStop.start()
		var t0 := Time.get_ticks_usec()
		await frames(1)
		total_usec += Time.get_ticks_usec() - t0
	var avg_ms := total_usec / 1000.0 / FALL_FRAMES
	print("  Waterfall Stair: %.2f ms a frame on average" % avg_ms)
	check(avg_ms < 8.0, "a frame by the falls averages well under budget (%.2f ms)" % avg_ms)
	TimeStop.reset()
	w.queue_free()
	await frames(2)


## King Grieve's fight at full tilt: a mashing player who can't die, 30 seconds,
## the second half on his throne with the Hour Glass turned whenever it is ready.
func test_king_grieve_fight_soak_stays_lean() -> void:
	var w := make_world({}, "dartmoor/throne_hall", cell_feet(10, 19))
	w.player.max_hp = 99999
	w.player.hp = 99999
	w.player.abilities["hourglass"] = true
	await frames(30)
	var boss := runner.get_tree().get_first_node_in_group("boss") as KingGrieve
	check(boss != null, "King Grieve wakes")
	if boss == null:
		return
	boss.max_hp = 99999
	boss.hp = 99999
	var rng := RandomNumberGenerator.new()
	rng.seed = 71
	var hold := {"move": 0, "down": 0, "up": 0, "jump": 0, "block": 0}
	var start_nodes := _count_nodes(w)
	var peak := start_nodes
	var total_usec := 0
	var slowest := 0
	var states := {}
	var shards := 0
	var seen := {}
	const FIGHT_FRAMES := 1800
	for f in FIGHT_FRAMES:
		_mash(w.player, rng, hold)
		if f == FIGHT_FRAMES / 3:
			boss.phase = 2
			boss._to_throne()
		if boss.phase == 2 and TimeStop.ready_to_turn() and f % 120 == 0:
			TimeStop.start()
		var t0 := Time.get_ticks_usec()
		await frames(1)
		var dt := Time.get_ticks_usec() - t0
		total_usec += dt
		slowest = maxi(slowest, dt)
		states[boss.state] = true
		peak = maxi(peak, _count_nodes(w))
		for c in w.room.get_children():
			if c is CrystalShard and not seen.has(c.get_instance_id()):
				seen[c.get_instance_id()] = true
				shards += 1
	TimeStop.reset()
	var avg_ms := total_usec / 1000.0 / FIGHT_FRAMES
	print("  King soak: %.2f ms a frame on average, slowest %.1f ms, nodes %d -> %d, states %s" % [avg_ms, slowest / 1000.0, start_nodes, peak, states.keys()])
	check(peak < start_nodes + 60, "effects never pile up (%d -> %d nodes)" % [start_nodes, peak])
	check(avg_ms < 16.6, "a frame averages under the 60 fps budget (%.2f ms)" % avg_ms)
	check(states.has("chop_tell") and states.has("ward") and states.has("summon_tell"), "duels and the throne were soaked")
	check(shards > 0, "and shard waves (%d)" % shards)
	check(boss.state != "dead" and is_instance_valid(boss), "the fight ran its course")


func test_shadow_eura_fight_soak_stays_lean() -> void:
	var w := make_world({}, "dartmoor/zenis_gate", cell_feet(14, 19))
	w.player.max_hp = 99999
	w.player.hp = 99999
	w.player.has_shield = true
	await frames(30)
	var boss := runner.get_tree().get_first_node_in_group("boss") as ShadowEura
	check(boss != null, "Shadow Eura wakes")
	if boss == null:
		return
	boss.max_hp = 99999
	boss.hp = 99999
	var rng := RandomNumberGenerator.new()
	rng.seed = 74
	var hold := {"move": 0, "down": 0, "up": 0, "jump": 0, "block": 0}
	var start_nodes := _count_nodes(w)
	var peak := start_nodes
	var total_usec := 0
	var slowest := 0
	var states := {}
	const FIGHT_FRAMES := 3000
	var doubles := 0
	for f in FIGHT_FRAMES:
		# Mash for a while, then stand still so it comes through the mirror.
		# Halfway the mirror breaks and it fights on its own, with arcana.
		if f == 1200:
			GameState.data.skills = ["clear_mind"]
			boss._break_free()
		if f == 2000:
			# The last fifth: it splits in two (the soak's mashing bursts the false one).
			boss.phase = 3
			boss._split()
		if is_instance_valid(boss.double):
			doubles += 1
		if f >= 1200 or f % 500 < 330:
			_mash(w.player, rng, hold)
		else:
			w.player.input.clear()
		var t0 := Time.get_ticks_usec()
		await frames(1)
		var dt := Time.get_ticks_usec() - t0
		total_usec += dt
		slowest = maxi(slowest, dt)
		states[boss.state] = true
		peak = maxi(peak, _count_nodes(w))
	var avg_ms := total_usec / 1000.0 / FIGHT_FRAMES
	print("  Eura soak: %.2f ms a frame on average, slowest %.1f ms, nodes %d -> %d, states %s" % [avg_ms, slowest / 1000.0, start_nodes, peak, states.keys()])
	check(peak < start_nodes + 60, "effects never pile up (%d -> %d nodes)" % [start_nodes, peak])
	check(avg_ms < 16.6, "a frame averages under the 60 fps budget (%.2f ms)" % avg_ms)
	check(states.has("echo") and states.has("rise"), "the soak saw it echo your swings and come through the mirror (%s)" % [states.keys()])
	check(states.has("stalk") and states.has("cast_tell"), "and fight on its own, casting (%s)" % [states.keys()])
	check(states.has("split") and doubles > 0, "and split in two (%d frames with a double)" % doubles)
	GameState.data.skills = []
	check(boss._history.size() < 60, "its memory of you stays short (%d frames)" % boss._history.size())


func test_evil_avatar_fight_soak_stays_lean() -> void:
	var w := make_world({}, "zenis/throne", cell_feet(10, 19))
	w.player.max_hp = 99999
	w.player.hp = 99999
	w.player.has_shield = true
	await frames(30)
	var boss := runner.get_tree().get_first_node_in_group("boss") as EvilAvatar
	check(boss != null, "the Evil One's avatar wakes")
	if boss == null:
		return
	boss.max_hp = 99999
	boss.hp = 99999
	var rng := RandomNumberGenerator.new()
	rng.seed = 81
	var hold := {"move": 0, "down": 0, "up": 0, "jump": 0, "block": 0}
	var start_nodes := _count_nodes(w)
	var peak := start_nodes
	var total_usec := 0
	var slowest := 0
	var states := {}
	const FIGHT_FRAMES := 2400
	for f in FIGHT_FRAMES:
		if f == FIGHT_FRAMES / 2:
			boss.phase = 2
		_mash(w.player, rng, hold)
		var t0 := Time.get_ticks_usec()
		await frames(1)
		var dt := Time.get_ticks_usec() - t0
		total_usec += dt
		slowest = maxi(slowest, dt)
		states[boss.state] = true
		peak = maxi(peak, _count_nodes(w))
	var avg_ms := total_usec / 1000.0 / FIGHT_FRAMES
	print("  Avatar soak: %.2f ms a frame on average, slowest %.1f ms, nodes %d -> %d, states %s" % [avg_ms, slowest / 1000.0, start_nodes, peak, states.keys()])
	check(peak < start_nodes + 60, "effects never pile up (%d -> %d nodes)" % [start_nodes, peak])
	check(avg_ms < 16.6, "a frame averages under the 60 fps budget (%.2f ms)" % avg_ms)
	check(states.has("cleave_tell") and states.has("pull") and (states.has("lunge_tell") or states.has("rain_tell")), "its attacks were soaked (%s)" % [states.keys()])
	check(boss.state != "dead" and is_instance_valid(boss), "the fight ran its course")


func test_evil_core_fight_soak_stays_lean() -> void:
	var w := make_world({}, "zenis/veins", cell_feet(8, 65))
	w.player.max_hp = 99999
	w.player.hp = 99999
	w.player.abilities["hourglass"] = true
	await frames(30)
	var boss := runner.get_tree().get_first_node_in_group("boss") as EvilCore
	check(boss != null, "the core wakes")
	if boss == null:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = 82
	var hold := {"move": 0, "down": 0, "up": 0, "jump": 0, "block": 0}
	var start_nodes := _count_nodes(w)
	var peak := start_nodes
	var total_usec := 0
	var states := {}
	var beams := 0
	var seen := {}
	const FIGHT_FRAMES := 2400
	for f in FIGHT_FRAMES:
		if f == FIGHT_FRAMES / 2:
			boss.phase = 2
		if f % 400 == 200 and TimeStop.ready_to_turn():
			TimeStop.start()
		_mash(w.player, rng, hold)
		var t0 := Time.get_ticks_usec()
		await frames(1)
		total_usec += Time.get_ticks_usec() - t0
		states[boss.state] = true
		peak = maxi(peak, _count_nodes(w))
		for c in w.room.get_children():
			if c is CoreBeam and not seen.has(c.get_instance_id()):
				seen[c.get_instance_id()] = true
				beams += 1
	TimeStop.reset()
	var avg_ms := total_usec / 1000.0 / FIGHT_FRAMES
	print("  Core soak: %.2f ms a frame on average, nodes %d -> %d, %d beams" % [avg_ms, start_nodes, peak, beams])
	check(peak < start_nodes + 60, "effects never pile up (%d -> %d nodes)" % [start_nodes, peak])
	check(avg_ms < 16.6, "a frame averages under the 60 fps budget (%.2f ms)" % avg_ms)
	check(beams > 10, "it fired beams all the while (%d)" % beams)


func test_evil_heart_fight_soak_stays_lean() -> void:
	GameState.new_game()
	GameState.data.equipment["blade"] = "dragon_slayer"
	var w := make_world({}, "zenis/heart", cell_feet(14, 20))
	w.player.max_hp = 99999
	w.player.hp = 99999
	w.player.abilities["hourglass"] = true
	GameState.data.equipment["blade"] = "dragon_slayer"
	await frames(30)
	var boss := runner.get_tree().get_first_node_in_group("boss") as EvilHeart
	check(boss != null, "the heart wakes")
	if boss == null:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = 83
	var hold := {"move": 0, "down": 0, "up": 0, "jump": 0, "block": 0}
	var start_nodes := _count_nodes(w)
	var peak := start_nodes
	var total_usec := 0
	var states := {}
	const FIGHT_FRAMES := 2400
	for f in FIGHT_FRAMES:
		if f == FIGHT_FRAMES / 3:
			boss.phase = 2
		if f == FIGHT_FRAMES * 2 / 3:
			boss.phase = 3
		if f % 400 == 200 and TimeStop.ready_to_turn():
			TimeStop.start()
		_mash(w.player, rng, hold)
		var t0 := Time.get_ticks_usec()
		await frames(1)
		total_usec += Time.get_ticks_usec() - t0
		if is_instance_valid(boss):
			states[boss.state] = true
		peak = maxi(peak, _count_nodes(w))
	TimeStop.reset()
	var avg_ms := total_usec / 1000.0 / FIGHT_FRAMES
	print("  Heart soak: %.2f ms a frame on average, nodes %d -> %d, states %s" % [avg_ms, start_nodes, peak, states.keys()])
	check(peak < start_nodes + 80, "effects never pile up (%d -> %d nodes)" % [start_nodes, peak])
	check(avg_ms < 16.6, "a frame averages under the 60 fps budget (%.2f ms)" % avg_ms)
	check(states.has("bound") and states.has("float"), "the roots bound it and let it go again")



## Every room id in the game (not the gym), in a fixed order.
func _all_room_ids(w: World) -> Array:
	var ids := w.catalog.keys()
	ids.sort()
	return ids


## Clears foes from the room so an arrival is judged on the room, not on a fight.
func _clear_foes(w: World) -> void:
	for c in w.room.get_children():
		if c is Enemy:
			c.queue_free()


## Walks through every door of every room, one at a time, starting fresh in its
## room each time: the far side must load, put the player in its matching door
## inside the room and out of the walls, standing (side doors) and unhurt, and a
## lap of the whole game must leave no nodes behind.
func test_every_door_in_the_game_lands_you_safely() -> void:
	var w := make_world({}, "eolis/west_gate")
	w.player.max_hp = 99999
	w.player.hp = 99999
	for a: String in w.player.abilities:
		w.player.abilities[a] = true
	# The gate of Zenis stands open for whoever reaches the far side of it.
	GameState.data.rings = ZenisGate.RINGS.duplicate()
	GameState.set_flag(ZenisGate.FLAG)
	await frames(5)
	var start_count := runner.get_tree().get_node_count()
	var problems: Array[String] = []
	var walked := 0
	for id: String in _all_room_ids(w):
		w.start(id)
		var doors: Dictionary = w.room.doors.duplicate()
		for n: int in doors:
			var d: Dictionary = doors[n]
			w.start(id)
			_clear_foes(w)
			await frames(1)
			var hp := w.player.hp
			w.use_door(n)
			await frames(1)
			_clear_foes(w)
			await frames(20)
			walked += 1
			var p := w.player
			var where := "%s door %d -> %s" % [id, n, w.room.id]
			if w.room.id == id:
				problems.append(where + ": never left")
			elif p.dead or p.hp < hp:
				problems.append(where + ": hurt on arrival")
			elif _embedded(w.room, p) or not w.room.pixel_rect().has_point(p.global_position):
				problems.append(where + ": inside a wall at %s" % p.global_position)
			elif String(d.edge) in ["left", "right"] and not p.is_on_floor() and not p.swimming:
				problems.append(where + ": not standing at %s" % p.global_position)
	w.start("eolis/west_gate")
	await frames(10)
	var end_count := runner.get_tree().get_node_count()
	print("  Door walk: %d doors, nodes %d -> %d" % [walked, start_count, end_count])
	check(walked > 150, "walked every door in the game (%d)" % walked)
	check(problems.is_empty(), "every door lands you safely: %s" % [problems])
	check(end_count - start_count < 40, "and a lap of the whole game leaves nothing behind (%d -> %d nodes)" % [start_count, end_count])


## Rests at every shrine in the game, then loads that save into a fresh world
## the way Continue does: you wake in the shrine's room, standing, out of the walls.
func test_every_shrine_saves_and_continues_where_you_rested() -> void:
	var w := make_world({}, "eolis/west_gate")
	await frames(2)
	const SLOT := 9
	GameState.slot = SLOT
	var problems: Array[String] = []
	var shrines := 0
	for id: String in _all_room_ids(w):
		w.start(id)
		var found: Array = w.room.get_children().filter(func(c: Node) -> bool: return c is SaveShrine)
		if found.is_empty():
			continue
		for shrine: SaveShrine in found:
			shrines += 1
			w.player.teleport(shrine.global_position)
			shrine.interact(w.player)
			GameState.data.save_room = ""
			if not GameState.load_game(SLOT) or GameState.data.save_room != id:
				problems.append("%s: the save did not come back" % id)
				continue
			var w2 := World.new()
			w2.instant = true
			arena.add_child(w2)
			w2.start(String(GameState.data.save_room), Vector2(float(GameState.data.save_pos[0]), float(GameState.data.save_pos[1])))
			w2.player.input.scripted = true
			await frames(20)
			var p := w2.player
			if w2.room.id != id or p.dead or not p.is_on_floor() or _embedded(w2.room, p):
				problems.append("%s: woke at %s (on floor %s)" % [w2.room.id, p.global_position, p.is_on_floor()])
			w2.queue_free()
			await frames(1)
	GameState.delete_save(SLOT)
	check(shrines >= 15, "rested at every shrine (%d)" % shrines)
	check(problems.is_empty(), "every shrine's save continues where you rested: %s" % [problems])



const JOURNEY_DOORS := 160
const JOURNEY_SAVE_EVERY := 20
const JOURNEY_SLOT := 8
## Doors walked per lap of the post-game journey (pass 144).
const POSTGAME_DOORS := 100

## A long run through the whole game the way a player strings it together: a
## walk from door to door (leaning toward rooms not seen yet) with real play
## between (mashing, foes left in), a rest and a Continue into a fresh world every
## few rooms, and the pause and skills screens opened and shut on the way. It runs
## twice: the first lap may fill caches, the second must leave nothing behind
## (live objects, orphan nodes), and no frame of play may spike far past budget.
func test_a_long_journey_through_the_whole_game_stays_lean() -> void:
	GameState.slot = JOURNEY_SLOT
	var first: Dictionary = await _journey(1987)
	var obj0 := Performance.get_monitor(Performance.OBJECT_COUNT)
	var orphans0 := Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	var nodes0 := runner.get_tree().get_node_count()
	var second: Dictionary = await _journey(2026)
	var obj1 := Performance.get_monitor(Performance.OBJECT_COUNT)
	var orphans1 := Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	var nodes1 := runner.get_tree().get_node_count()
	GameState.delete_save(JOURNEY_SLOT)
	for r: Dictionary in [first, second]:
		print("  Journey: %d rooms, %d reloads, worst frame %.1f ms (%s), %d over 33 ms" % [r.rooms, r.reloads, r.worst / 1000.0, r.where, r.spikes])
	print("  Second lap: objects %d -> %d, orphans %d -> %d, nodes %d -> %d" % [obj0, obj1, orphans0, orphans1, nodes0, nodes1])
	for r: Dictionary in [first, second]:
		check(r.problems.is_empty(), "every rest continues where it was taken: %s" % [r.problems])
		check(r.rooms >= 30, "the walk saw much of the world (%d rooms)" % r.rooms)
		check(r.reloads >= JOURNEY_DOORS / JOURNEY_SAVE_EVERY - 1, "and rested and continued along the way (%d)" % r.reloads)
	check(orphans1 <= orphans0, "no orphan nodes left behind (%d -> %d)" % [orphans0, orphans1])
	check(obj1 - obj0 < 50, "a second lap leaves no live objects behind (%d -> %d)" % [obj0, obj1])
	check(nodes1 <= nodes0, "and the tree is no bigger (%d -> %d)" % [nodes0, nodes1])
	for r: Dictionary in [first, second]:
		check(r.worst < 50_000, "no frame of play spikes past 50 ms (%.1f ms, %s)" % [r.worst / 1000.0, r.where])


## The same journey on a save that has seen the ending (pass 144): every boss
## beaten, the Tree in bloom (its blossom layer and the post-game music) and
## Wanderer's Grace feeding the air dashes on every kill. Two laps: the second must leave nothing behind and log no errors.
func test_a_journey_after_the_end_stays_lean() -> void:
	GameState.slot = JOURNEY_SLOT
	var errors := ErrorCatcher.start()
	# Each lap walks out of Eolis and, separately, out of the dead meteor.
	var first: Dictionary = _merge(await _journey(1987, true, POSTGAME_DOORS), await _journey(1987, true, POSTGAME_DOORS / 2, "zenis/threshold"))
	var obj0 := Performance.get_monitor(Performance.OBJECT_COUNT)
	var orphans0 := Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	var nodes0 := runner.get_tree().get_node_count()
	var second: Dictionary = _merge(await _journey(2026, true, POSTGAME_DOORS), await _journey(2026, true, POSTGAME_DOORS / 2, "zenis/threshold"))
	# The second lap walks new ground, and the first sight of a zone's music,
	# sheets and tiles is cached for good. So the leak check walks it again:
	# the same lap, retraced, must leave nothing behind (pass 151).
	obj0 = Performance.get_monitor(Performance.OBJECT_COUNT)
	orphans0 = Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	nodes0 = runner.get_tree().get_node_count()
	await _journey(2026, true, POSTGAME_DOORS)
	await _journey(2026, true, POSTGAME_DOORS / 2, "zenis/threshold")
	var obj1 := Performance.get_monitor(Performance.OBJECT_COUNT)
	var orphans1 := Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	var nodes1 := runner.get_tree().get_node_count()
	var caught := errors.stop()
	GameState.delete_save(JOURNEY_SLOT)
	for r: Dictionary in [first, second]:
		print("  After the end: %d rooms, %d reloads, worst frame %.1f ms (%s), bloom in %d room stays, still meteor %d, festival %d" % [
			r.rooms, r.reloads, r.worst / 1000.0, r.where, r.bloomed, r.still, r.festival])
	print("  Retraced lap: objects %d -> %d, orphans %d -> %d, nodes %d -> %d" % [obj0, obj1, orphans0, orphans1, nodes0, nodes1])
	check(caught.is_empty(), "no engine or script errors on the way: %s" % [caught.slice(0, 3)])
	for r: Dictionary in [first, second]:
		check(r.problems.is_empty(), "every rest continues where it was taken, still cleared: %s" % [r.problems])
		check(r.rooms >= 20, "the walk saw much of the world (%d rooms)" % r.rooms)
		check(r.bloomed > 0, "blossom drifted through the living Tree (%d room stays)" % r.bloomed)
		check(r.still > 0 and r.festival > 0, "Zenis played still and Eolis its festival (%d, %d room stays)" % [r.still, r.festival])
		check(r.worst < 50_000, "no frame of play spikes past 50 ms (%.1f ms, %s)" % [r.worst / 1000.0, r.where])
	check(orphans1 <= orphans0, "no orphan nodes left behind (%d -> %d)" % [orphans0, orphans1])
	check(obj1 - obj0 < 50, "a retraced lap leaves no live objects behind (%d -> %d)" % [obj0, obj1])
	check(nodes1 <= nodes0, "and the tree is no bigger (%d -> %d)" % [nodes0, nodes1])
	GameState.new_game()


## A boss fight starts mid-play, so its arena loads the boss's sheet and music
## while the room loads (pass 99): the fight's first frame must not hitch.
func test_a_boss_arena_loads_the_fight_before_it_starts() -> void:
	Sheet._cache.erase("zoradohna")
	Music._streams.erase("zoradohna")
	var w := make_world({}, "tower/forepaw_lift")
	await frames(2)
	var a := runner.get_tree().get_first_node_in_group("boss_arena") as BossArena
	check(a != null and a.warmed, "the arena warmed up with the room")
	check(Sheet._cache.has("zoradohna") and Music._streams.has("zoradohna"), "the drill's sheet and theme are loaded before the fight")
	w.player.input.move_x = 1
	var worst := 0
	var started := false
	for i in 90:
		var t0 := Time.get_ticks_usec()
		await frames(1)
		worst = maxi(worst, Time.get_ticks_usec() - t0)
		started = started or a.fighting
	check(started, "the fight began as the player walked in")
	check(worst < 33_000, "and no frame of the walk in hitched (worst %.1f ms)" % (worst / 1000.0))
	w.queue_free()
	await frames(2)


func _journey(seed: int, postgame := false, doors := JOURNEY_DOORS, start := "eolis/west_gate") -> Dictionary:
	var w := make_world({}, start)
	GameState.data.rings = ZenisGate.RINGS.duplicate()
	GameState.set_flag(ZenisGate.FLAG)
	if postgame:
		_clear_the_game(w)
		# Enter the first room again as the cleared save would, bloom and all.
		w._enter(start)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	# The hand mashes on its own dice, so the doors the walk picks don't
	# hang on how the mashing draws (pass 151).
	var hand := RandomNumberGenerator.new()
	hand.seed = seed * 31 + 7
	var hold := {"move": 0, "down": 0, "up": 0, "jump": 0, "block": 0}
	var menus := ListMenu.new()
	arena.add_child(menus)
	_journey_buff(w)
	await frames(10)
	var r := {"rooms": 0, "reloads": 0, "worst": 0, "where": "", "spikes": 0, "problems": [],
		"bloomed": 0, "still": 0, "festival": 0}
	var visited := {w.room.id: true}
	if postgame:
		_tally_bloom(w, r)
	for i in doors:
		var exits: Array = w.room.doors.keys()
		if exits.is_empty():
			break
		var fresh := exits.filter(func(k: int) -> bool: return not visited.has(String(w.room.doors[k].target)))
		var pick: Array = fresh if not fresh.is_empty() and rng.randf() < 0.8 else exits
		var n: int = pick[rng.randi() % pick.size()]
		w.use_door(n)
		visited[w.room.id] = true
		var entered := 0
		for f in 40:
			_mash(w.player, hand, hold)
			var before := w.room
			var t0 := Time.get_ticks_usec()
			await frames(1)
			var dt := Time.get_ticks_usec() - t0
			if w.room != before:
				# Mashing walked out through an edge door: a load, not play.
				entered = f
				visited[w.room.id] = true
			# The first frames in a room build it; judge play, not loading.
			if f >= entered + 3:
				if dt > r.worst:
					r.worst = dt
					r.where = "%s frame %d" % [w.room.id, f]
				if dt > 33_000:
					r.spikes += 1
					print("    spike %.1f ms in %s frame %d" % [dt / 1000.0, w.room.id, f])
		if postgame:
			_tally_bloom(w, r)
		if w.player.dead:
			await frames(int(w.player.combat.respawn_delay * 60.0) + 30)
			_journey_buff(w)
		if i % 7 == 3:
			Menus.open_pause(runner.get_tree(), w.player, func() -> void: pass)
			await frames(3)
			_close_menus()
			Menus.open_skills(runner.get_tree(), w.player)
			await frames(3)
			_close_menus()
		if i % JOURNEY_SAVE_EVERY == JOURNEY_SAVE_EVERY - 1:
			# Rest, then Continue into a brand-new world, as after quitting.
			var room_id := w.room.id
			w.save_at(w.player.global_position)
			w.queue_free()
			await frames(2)
			if not GameState.load_game(JOURNEY_SLOT):
				r.problems.append("the save at %s did not load" % room_id)
				break
			w = World.new()
			w.instant = true
			arena.add_child(w)
			w.build_catalog()
			w.start(String(GameState.data.save_room), Vector2(float(GameState.data.save_pos[0]), float(GameState.data.save_pos[1])))
			w.player.input.scripted = true
			_journey_buff(w)
			r.reloads += 1
			if postgame and not GameState.flag("cleared"):
				r.problems.append("the save at %s forgot the ending" % room_id)
			await frames(5)
			if w.room.id != room_id:
				r.problems.append("continued in %s, not %s" % [w.room.id, room_id])
	r.rooms = visited.size()
	w.queue_free()
	menus.queue_free()
	await frames(10)
	return r


## Counts what the room shows of the post-game: blossom, the still meteor, the festival.
func _tally_bloom(w: World, r: Dictionary) -> void:
	if not w.blossom.get("_motes").is_empty():
		r.bloomed += 1
	if Music.track == "zenis_still":
		r.still += 1
	if Music.track == "eolis_bloom":
		r.festival += 1


## Two journeys' tallies as one.
func _merge(a: Dictionary, b: Dictionary) -> Dictionary:
	var out := a.duplicate(true)
	for k: String in ["rooms", "reloads", "spikes", "bloomed", "still", "festival"]:
		out[k] = int(a[k]) + int(b[k])
	if int(b.worst) > int(a.worst):
		out.worst = b.worst
		out.where = b.where
	out.problems = a.problems + b.problems
	return out


## A save that has seen the ending: every boss beaten, every spring running, the
## Tree in bloom, and Wanderer's Grace learned so kills feed the air dashes.
func _clear_the_game(w: World) -> void:
	for id: String in BossArena.BOSSES:
		GameState.set_flag("boss:" + id)
	for spring: String in ["trunk", "mist", "sky"]:
		GameState.set_flag("spring:" + spring)
	GameState.set_flag("cleared")
	var skills: Array = GameState.data.skills
	for id: String in ["deep_pockets", "gold_sense", "quick_draught", "second_stride", "feather_fall", "treasure_sense",
			"resilience", "last_stand", "second_wind", "wanderers_grace"]:
		if not skills.has(id):
			skills.append(id)
	GameState.refresh_stats(w.player)


func _journey_buff(w: World) -> void:
	for k: String in GameState.data.abilities:
		GameState.data.abilities[k] = true
		w.player.abilities[k] = true
	_learn_the_blade(w)
	w.player.max_hp = 99999
	w.player.hp = 99999


## The whole Blade branch, Thrust included (pass 151): the soaks mash every
## melee skill, Riposte's counter and Rising Cut's launch with them.
func _learn_the_blade(w: World) -> void:
	var skills: Array = GameState.data.skills
	for n: Dictionary in Skills.nodes():
		if String(n.branch) == "Blade" and not skills.has(n.id):
			skills.append(String(n.id))
	GameState.refresh_stats(w.player)


func _close_menus() -> void:
	for m in runner.get_tree().get_nodes_in_group("list_menu"):
		m.close()
	runner.get_tree().paused = false


## Every boss fight, mashed for 15 s with the boss knocked down a phase every
## 5 s, holds the frame budget (bible 15.3) and loads nothing from disk once it
## has begun: the boss's sheet comes with the arena (`BossArena.warm`) and every
## sound with the game (`Sfx.load_all`).
const BOSS_ROOMS := ["trunk/root_chamber", "tower/foreman_hall", "tower/forepaw_lift",
	"mist/sunken_chapel", "mist/spring_of_mist", "branches/crown_leaf", "daybreak/roost",
	"dartmoor/throne_hall", "dartmoor/zenis_gate", "zenis/throne", "zenis/veins", "zenis/heart",
	"sunken/wellspring"]
const BOSS_AUDIT_FRAMES := 900


func test_every_boss_fight_holds_the_frame_budget() -> void:
	var report: Array[String] = []
	var problems: Array[String] = []
	var wavs := Array(DirAccess.get_files_at(Sfx.SFX_DIR)).filter(func(f: String) -> bool: return f.ends_with(".wav"))
	check(Sfx.loads >= wavs.size() and wavs.size() > 80, "every sound loaded with the game (%d of %d)" % [Sfx.loads, wavs.size()])
	for id: String in BOSS_ROOMS:
		GameState.new_game()
		Sheet._cache.clear()
		var w := make_world({}, id)
		w.player.max_hp = 99999
		w.player.hp = 99999
		w.player.has_shield = true
		await frames(5)
		var ar := runner.get_tree().get_first_node_in_group("boss_arena") as BossArena
		if not check(ar != null, "%s has a boss arena" % id):
			continue
		ar._start()
		await frames(2)
		var boss := ar.boss
		var rng := RandomNumberGenerator.new()
		rng.seed = 103
		var hold := {"move": 0, "down": 0, "up": 0, "jump": 0, "block": 0}
		var sheets := Sheet._cache.size()
		var loads := Sfx.loads
		var start_nodes := _count_nodes(w)
		var peak := start_nodes
		var times: Array[int] = []
		var total := 0
		for f in BOSS_AUDIT_FRAMES:
			_mash(w.player, rng, hold)
			w.player.hp = 99999
			if f % 300 == 299 and is_instance_valid(boss) and boss.has_method("take_hit") and boss.hp > 50:
				boss.take_hit(int(boss.max_hp * 0.2), Vector2.RIGHT)
			var t0 := Time.get_ticks_usec()
			await frames(1)
			var dt := Time.get_ticks_usec() - t0
			times.append(dt)
			total += dt
			peak = maxi(peak, _count_nodes(w))
		times.sort()
		var avg := total / 1000.0 / BOSS_AUDIT_FRAMES
		var p99 := times[int(BOSS_AUDIT_FRAMES * 0.99)] / 1000.0
		report.append("%s %.2f/%.2f ms" % [id.get_file(), avg, p99])
		if avg > 8.0 or p99 > 16.6:
			problems.append("%s: average %.2f ms, 99th percentile %.2f ms" % [id, avg, p99])
		if Sheet._cache.size() != sheets or Sfx.loads != loads:
			problems.append("%s: loaded %d sheets and %d sounds mid-fight" % [id, Sheet._cache.size() - sheets, Sfx.loads - loads])
		if peak >= start_nodes + 40:
			problems.append("%s: nodes piled up (%d -> %d)" % [id, start_nodes, peak])
		w.queue_free()
		await frames(2)
	TimeStop.reset()
	print("  Boss frames (average/99th): %s" % ", ".join(report))
	check(report.size() == BOSS_ROOMS.size(), "every boss fight ran (%d)" % report.size())
	check(problems.is_empty(), "every fight holds the budget and loads nothing mid-fight: %s" % [problems])
