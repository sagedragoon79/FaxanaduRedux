extends TestSuite
## The reachability checker on the real rooms (design bible 14): the critical
## path works in order, every pickup can be reached, ability gates hold, and
## no reachable spot is a soft-lock.

const START_ROOM := "eolis/west_gate"
const PICKUPS := "GLWF*$SN"
## Secrets that only open once the Spring of Trunk hardens the sap (bible 4.4):
## [room, tile x, tile y].
const AMBER_SECRETS := [["trunk/amber_falls", 31, 13]]
## Rooms beyond cracked stone, open only once the Foreman gives up the Mattock.
const MATTOCK_ROOMS := ["tower/forepaw_stair", "tower/forepaw_gate", "tower/ore_vault"]


func _texts() -> Dictionary:
	var out := {}
	for zone: String in DirAccess.get_directories_at("res://levels"):
		if zone == "gym":
			continue
		for file: String in DirAccess.get_files_at("res://levels/" + zone):
			if file.ends_with(".room"):
				out[zone + "/" + file.trim_suffix(".room")] = FileAccess.get_file_as_string("res://levels/%s/%s" % [zone, file])
	return out


func _rooms_reached(nodes: Dictionary) -> Dictionary:
	var out := {}
	for k: String in nodes:
		out[Reach.unkey(k)[0]] = true
	return out


## Every pickup marker in the rooms: [room, char, x, y].
func _pickups(reach: Reach) -> Array:
	var out := []
	for id: String in reach.rooms:
		var g: Array[String] = reach.rooms[id].grid
		for y in g.size():
			for x in g[y].length():
				if PICKUPS.contains(g[y][x]):
					out.append([id, g[y][x], x, y])
	return out


func _save_spots(reach: Reach) -> Array:
	var out := [reach.spot_of(START_ROOM, "P")]
	for id: String in reach.rooms:
		var spot := reach.spot_of(id, "S")
		if spot != "":
			out.append(spot)
	return out


func test_start_spot_exists() -> void:
	var reach := Reach.new(_texts(), {})
	check(reach.spot_of(START_ROOM, "P") != "", "the new game spawn is a standing spot")


func test_glove_reachable_without_abilities() -> void:
	var reach := Reach.new(_texts(), {})
	var nodes := reach.reachable(reach.spot_of(START_ROOM, "P"))
	var glove := false
	for p: Array in _pickups(reach):
		if p[1] == "G":
			glove = reach.touchable(nodes, p[0], p[2], p[3])
	check(glove, "the Climbing Glove can be reached with no abilities")
	var rooms := _rooms_reached(nodes)
	check(not rooms.has("trunk/root_chamber"), "the boss is behind the glove gate")
	check(rooms.has("eolis/king_hall") and rooms.has("eolis/guru_temple") and rooms.has("eolis/market"), "all of Eolis is open from the start")


func test_no_soft_locks_before_the_glove() -> void:
	var reach := Reach.new(_texts(), {})
	var nodes := reach.reachable(reach.spot_of(START_ROOM, "P"))
	var goals := _save_spots(reach)
	goals.append(reach.spot_of("trunk/glove_shrine", "G"))
	var stuck := reach.stuck(nodes, goals)
	check(stuck.is_empty(), "every spot reachable without the glove can get back to a save or on to the glove: %s" % [stuck.slice(0, 6)])


func test_with_glove_everything_is_reachable() -> void:
	var reach := Reach.new(_texts(), {"glove": true}, true)
	var nodes := reach.reachable(reach.spot_of(START_ROOM, "P"))
	var rooms := _rooms_reached(nodes)
	var missing_rooms: Array[String] = []
	for id: String in reach.rooms:
		if not rooms.has(id) and not MATTOCK_ROOMS.has(id):
			missing_rooms.append(id)
	check(missing_rooms.is_empty(), "with the glove and keys every room is reachable: missing %s" % [missing_rooms])
	var missing: Array = []
	for p: Array in _pickups(reach):
		if not reach.touchable(nodes, p[0], p[2], p[3]) and not AMBER_SECRETS.has([p[0], p[2], p[3]]) and not MATTOCK_ROOMS.has(p[0]):
			missing.append(p)
	check(missing.is_empty(), "every pickup, chest and shrine is reachable: missing %s" % [missing])
	var opened := MATTOCK_ROOMS.filter(func(id: String) -> bool: return rooms.has(id))
	check(opened.is_empty(), "the cracked stone keeps the Mattock rooms shut: %s" % [opened])


func test_amber_secrets_need_the_spring() -> void:
	var reach := Reach.new(_texts(), {"glove": true}, true)
	var nodes := reach.reachable(reach.spot_of(START_ROOM, "P"))
	for s: Array in AMBER_SECRETS:
		check(not reach.touchable(nodes, s[0], s[1], s[2]), "%s is out of reach until the sap hardens" % [s])


func test_no_soft_locks_with_glove() -> void:
	var reach := Reach.new(_texts(), {"glove": true}, true)
	var nodes := reach.reachable(reach.spot_of(START_ROOM, "P"))
	var stuck := reach.stuck(nodes, _save_spots(reach))
	check(stuck.is_empty(), "with the glove, every reachable spot can get back to a save: %s" % [stuck.slice(0, 6)])


func test_amber_keeps_everything_reachable() -> void:
	# After the Spring of Trunk, sap is solid amber: nothing may be cut off.
	var reach := Reach.new(_texts(), {"glove": true, "amber": true}, true)
	var nodes := reach.reachable(reach.spot_of(START_ROOM, "P"))
	var missing: Array = []
	for p: Array in _pickups(reach):
		if not reach.touchable(nodes, p[0], p[2], p[3]) and not MATTOCK_ROOMS.has(p[0]):
			missing.append(p)
	check(missing.is_empty(), "with amber, every pickup is still reachable: missing %s" % [missing])
	var stuck := reach.stuck(nodes, _save_spots(reach))
	check(stuck.is_empty(), "with amber, no soft-locks: %s" % [stuck.slice(0, 6)])


func test_with_the_mattock_everything_is_reachable() -> void:
	# The Act I set: glove, Mattock (from the Foreman), keys, and the Spring restored.
	var reach := Reach.new(_texts(), {"glove": true, "mattock": true, "amber": true}, true)
	var nodes := reach.reachable(reach.spot_of(START_ROOM, "P"))
	var rooms := _rooms_reached(nodes)
	var missing_rooms: Array[String] = []
	for id: String in reach.rooms:
		if not rooms.has(id):
			missing_rooms.append(id)
	check(missing_rooms.is_empty(), "with the Mattock every room is reachable: missing %s" % [missing_rooms])
	var missing: Array = []
	for p: Array in _pickups(reach):
		if not reach.touchable(nodes, p[0], p[2], p[3]):
			missing.append(p)
	check(missing.is_empty(), "with the Mattock every pickup is reachable: missing %s" % [missing])
	var stuck := reach.stuck(nodes, _save_spots(reach))
	check(stuck.is_empty(), "with the Mattock, no soft-locks: %s" % [stuck.slice(0, 6)])


func test_checker_pogoes_across_spikes_with_the_mattock() -> void:
	# A floor of spikes too wide to jump: only pogo bounces cross it.
	var rows := grid_rows(40, 23)
	put_tiles(rows, 3, 19, "P")
	put_tiles(rows, 6, 19, "^", 26, 1)
	put_tiles(rows, 34, 19, "L")
	var texts := {"t/pit": room_text(["name: Pit"], rows)}
	var bare := Reach.new(texts, {"glove": true})
	check(not bare.touchable(bare.reachable(bare.spot_of("t/pit", "P")), "t/pit", 34, 19), "the spike floor can't be crossed without the Mattock")
	var pogo := Reach.new(texts, {"glove": true, "mattock": true})
	check(pogo.touchable(pogo.reachable(pogo.spot_of("t/pit", "P")), "t/pit", 34, 19), "with it, the player pogoes across")


func test_checker_respects_walls() -> void:
	# A sanity check on a tiny pair of rooms: a 6-tile wall can't be jumped
	# without the glove, but can be climbed with it.
	var rows := grid_rows(30, 23)
	put_tiles(rows, 3, 19, "P")
	put_tiles(rows, 14, 13, "#", 3, 7)
	put_tiles(rows, 22, 19, "L")
	var texts := {"t/wall": room_text(["name: Wall"], rows)}
	var bare := Reach.new(texts, {})
	var n0 := bare.reachable(bare.spot_of("t/wall", "P"))
	check(not bare.touchable(n0, "t/wall", 22, 19), "a 6-tile wall stops a bare jump")
	var gloved := Reach.new(texts, {"glove": true})
	var n1 := gloved.reachable(gloved.spot_of("t/wall", "P"))
	check(gloved.touchable(n1, "t/wall", 22, 19), "the glove climbs it")


func test_checker_opens_root_gates_from_their_heart() -> void:
	var rows := grid_rows(30, 23)
	put_tiles(rows, 3, 19, "P")
	put_tiles(rows, 14, 2, "#", 1, 15)
	put_tiles(rows, 14, 17, "R", 1, 3)
	put_tiles(rows, 22, 19, "L")
	var blocked := {"t/gate": room_text(["name: Gate"], rows)}
	var r0 := Reach.new(blocked, {"glove": true})
	check(not r0.touchable(r0.reachable(r0.spot_of("t/gate", "P")), "t/gate", 22, 19), "a root-gate with no heart stays shut")
	put_tiles(rows, 6, 19, "N")
	var hearted := {"t/gate": room_text(["name: Gate"], rows)}
	var r1 := Reach.new(hearted, {})
	check(r1.touchable(r1.reachable(r1.spot_of("t/gate", "P")), "t/gate", 22, 19), "with its heart in reach, it opens")


func test_every_room_boots_and_the_player_lands() -> void:
	var bad: Array[String] = []
	for id: String in _texts():
		GameState.new_game()
		var w := World.new()
		w.instant = true
		arena.add_child(w)
		w.start(id)
		w.player.input.scripted = true
		await frames(40)
		var p := w.player
		if p.dead or p.hp < p.max_hp or not p.is_on_floor() or w.room.id != id:
			bad.append("%s (on floor %s, hp %d, in %s)" % [id, p.is_on_floor(), p.hp, w.room.id])
		w.queue_free()
		await frames(1)
	check(bad.is_empty(), "every room loads and the player lands safely at its entrance: %s" % [bad])
