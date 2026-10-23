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


## Every Tower room, live (enemies, doors, gates), with every ability and a
## mashing player: no escapes, no embedding, and the room's node count settles.
func test_random_input_soak_in_every_tower_room() -> void:
	var problems: Array[String] = []
	var dir := DirAccess.open("res://levels/tower")
	var ids: Array[String] = []
	for f in dir.get_files():
		if f.ends_with(".room"):
			ids.append("tower/" + f.trim_suffix(".room"))
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
		for f in TOWER_FRAMES:
			_mash(w.player, rng, hold)
			await frames(1)
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
	check(problems.is_empty(), "%d Tower rooms soaked with no problems: %s" % [ids.size(), problems])


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


func _count_nodes(w: World) -> int:
	return w.room.get_child_count() if w.room != null else 0
