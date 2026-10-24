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
	for k: String in hold:
		hold[k] -= 1
	p.input.attack_pressed = rng.randf() < 0.08
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
		w.queue_free()
		await frames(2)
	check(problems.is_empty(), "%d %s rooms soaked with no problems: %s" % [ids.size(), label, problems])
	var avg_ms := total_usec / 1000.0 / maxi(counted, 1)
	print("  %s soak: %.2f ms a frame on average" % [label, avg_ms])
	check(avg_ms < 16.6, "a %s frame averages under the 60 fps budget (%.2f ms)" % [label, avg_ms])
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
	var w := make_world({}, "daybreak/roost", cell_feet(9, 19))
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
