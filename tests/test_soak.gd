extends TestSuite
## Random-input soak in the gym: catches the player escaping the room, getting
## embedded in solid tiles, or producing invalid positions.

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
			# Inputs persist for random spans, like a button-mashing player.
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
