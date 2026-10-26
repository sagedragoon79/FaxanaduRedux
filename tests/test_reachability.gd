extends TestSuite
## The reachability checker on the real rooms (design bible 14): the critical
## path works in order, every pickup can be reached, ability gates hold, and
## no reachable spot is a soft-lock.

const START_ROOM := "eolis/west_gate"
const PICKUPS := "GXOdhnzLWF*$SN&{("
## Secrets that only open once the Spring of Trunk hardens the sap (bible 4.4):
## [room, tile x, tile y].
const AMBER_SECRETS := [["trunk/amber_falls", 31, 13]]
## Caches behind cracked stone outside the Mattock rooms (pass 135): the town
## shows you one from the first step, and only the Mattock opens it.
const MATTOCK_SECRETS := [["eolis/west_gate", 2, 19]]
## Pickups only a second jump reaches, once the Wing Boots are found (bible 4.1, A3).
const BOOT_SECRETS := [["mist/feather_hollow", 18, 7]]
## Pickups only an air dash reaches, once the Elven Stride is found (bible 4.1, A5).
const STRIDE_SECRETS := [["branches/north_bough", 8, 7], ["daybreak/sky_steps", 6, 20]]
## Pickups only the Branches' wind reaches once the Spring of Sky turns it
## (bible 6.9, the "sky_spring" ability): the elves' wind-niche over the Thicket Road.
const WIND_SECRETS := [["branches/thicket_road", 38, 8]]
## Pickups behind bramble, which only the Fire spell burns away (bible 4.5).
const FIRE_SECRETS := [["daybreak/daybreak", 76, 19]]
## Rooms beyond cracked stone, open only once the Foreman gives up the Mattock,
## or above the flue damper, open once Zoradohna falls (the "winch" ability),
## and the Mist, reached by the ore road east of the Deep Workings (its rooms
## past the bound fog also need the Lantern Key: the "lantern" ability).
const MATTOCK_ROOMS := ["tower/old_flue", "tower/rafters", "tower/forepaw_stair", "tower/forepaw_gate", "tower/forepaw_lift", "tower/forepaw", "tower/ore_vault",
	"tower/mine_mouth", "tower/mine_shaft", "tower/rail_gallery", "tower/mine_vault", "tower/smelter", "tower/sorting_floor", "tower/slag_heap",
	"tower/crown_lookout", "tower/bell_loft", "mist/fog_cut", "mist/drowned_stair", "mist/lantern_landing", "mist/sunken_chapel",
	"mist/veiled_rise", "mist/victim_causeway", "mist/feather_hollow", "mist/victim", "mist/marsh_road", "mist/scorched_hall", "mist/dry_cistern",
	"mist/spring_of_mist", "branches/windward_climb", "branches/sunlit_bough", "branches/leaf_landing", "branches/thicket_road", "branches/canopy_bridge", "branches/conflate",
	"branches/north_bough", "branches/windloft", "branches/crown_leaf", "daybreak/storm_ledge", "daybreak/sky_steps",
	"daybreak/broken_shrine", "daybreak/fallen_bridge", "daybreak/daybreak", "daybreak/spire_foot", "daybreak/spire_stair", "daybreak/roost", "daybreak/sky_spring", "dartmoor/upper_stair", "dartmoor/gate_hall", "dartmoor/flooded_hall", "dartmoor/sunken_stair", "dartmoor/onyx_crypt", "dartmoor/drowned_nave", "dartmoor/waterfall_stair", "dartmoor/drowned_market", "dartmoor/kings_stair", "dartmoor/kings_kennels", "dartmoor/throne_hall", "dartmoor/meteor_rise", "dartmoor/zenis_gate", "zenis/threshold", "zenis/heart_stair", "zenis/drift_well", "zenis/heart_gate", "zenis/throne", "zenis/veins", "zenis/heart", "sunken/spring_gate", "sunken/drowned_aqueduct", "sunken/source_hall", "sunken/wellspring"]
## Rooms past an air-dash gap: open only with the Elven Stride (above Daybreak's
## Sky Steps, bible 3.2). The Stride test checks them.
const STRIDE_ROOMS := ["daybreak/broken_shrine", "daybreak/fallen_bridge", "daybreak/daybreak", "daybreak/spire_foot"]
## Rooms past a conduit gate: open only once Thunder wakes the conduits (bible 4.1, A6).
const THUNDER_ROOMS := ["daybreak/spire_stair", "daybreak/roost", "daybreak/sky_spring", "dartmoor/upper_stair", "dartmoor/gate_hall", "dartmoor/flooded_hall", "dartmoor/sunken_stair", "dartmoor/onyx_crypt", "dartmoor/drowned_nave", "dartmoor/waterfall_stair", "dartmoor/drowned_market", "dartmoor/kings_stair", "dartmoor/kings_kennels", "dartmoor/throne_hall", "dartmoor/meteor_rise", "dartmoor/zenis_gate", "zenis/threshold", "zenis/heart_stair", "zenis/drift_well", "zenis/heart_gate", "zenis/throne", "zenis/veins", "zenis/heart", "sunken/spring_gate", "sunken/drowned_aqueduct", "sunken/source_hall", "sunken/wellspring"]


func _texts() -> Dictionary:
	var out := {}
	for zone: String in DirAccess.get_directories_at("res://levels"):
		# The trials are entered through the Guru's menu, not doors: tested on their own.
		if zone in World.OFF_MAP:
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
		if not reach.touchable(nodes, p[0], p[2], p[3]) and not AMBER_SECRETS.has([p[0], p[2], p[3]]) and not MATTOCK_ROOMS.has(p[0]) \
				and not WIND_SECRETS.has([p[0], p[2], p[3]]) and not MATTOCK_SECRETS.has([p[0], p[2], p[3]]):
			missing.append(p)
	check(missing.is_empty(), "every pickup, chest and shrine is reachable: missing %s" % [missing])
	var opened := MATTOCK_ROOMS.filter(func(id: String) -> bool: return rooms.has(id))
	check(opened.is_empty(), "the cracked stone keeps the Mattock rooms shut: %s" % [opened])


func test_amber_secrets_need_the_spring() -> void:
	var reach := Reach.new(_texts(), {"glove": true}, true)
	var nodes := reach.reachable(reach.spot_of(START_ROOM, "P"))
	for s: Array in AMBER_SECRETS:
		check(not reach.touchable(nodes, s[0], s[1], s[2]), "%s is out of reach until the sap hardens" % [s])


func test_mattock_secrets_need_the_mattock() -> void:
	var reach := Reach.new(_texts(), {"glove": true, "amber": true}, true)
	var nodes := reach.reachable(reach.spot_of(START_ROOM, "P"))
	var dug := Reach.new(_texts(), {"glove": true, "amber": true, "mattock": true}, true)
	var dug_nodes := dug.reachable(dug.spot_of(START_ROOM, "P"))
	for s: Array in MATTOCK_SECRETS:
		check(not reach.touchable(nodes, s[0], s[1], s[2]), "%s waits behind cracked stone" % [s])
		check(dug.touchable(dug_nodes, s[0], s[1], s[2]), "%s opens to the Mattock" % [s])


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
		if not reach.touchable(nodes, p[0], p[2], p[3]) and not MATTOCK_ROOMS.has(p[0]) and not WIND_SECRETS.has([p[0], p[2], p[3]]) \
				and not MATTOCK_SECRETS.has([p[0], p[2], p[3]]):
			missing.append(p)
	check(missing.is_empty(), "with amber, every pickup is still reachable: missing %s" % [missing])
	var stuck := reach.stuck(nodes, _save_spots(reach))
	check(stuck.is_empty(), "with amber, no soft-locks: %s" % [stuck.slice(0, 6)])


func test_with_the_mattock_everything_is_reachable() -> void:
	# The Act I set: glove, Mattock (from the Foreman), keys, the Spring restored,
	# Zoradohna beaten (the winch opens the flue damper) and Ripasheiku's Lantern Key.
	var reach := Reach.new(_texts(), {"glove": true, "mattock": true, "amber": true, "winch": true, "lantern": true, "deluge": true}, true)
	var nodes := reach.reachable(reach.spot_of(START_ROOM, "P"))
	var rooms := _rooms_reached(nodes)
	var missing_rooms: Array[String] = []
	for id: String in reach.rooms:
		if not rooms.has(id) and not STRIDE_ROOMS.has(id) and not THUNDER_ROOMS.has(id):
			missing_rooms.append(id)
	check(missing_rooms.is_empty(), "with the Mattock every room is reachable: missing %s" % [missing_rooms])
	check(STRIDE_ROOMS.all(func(id: String) -> bool: return not rooms.has(id)), "but not the sky islands past the air-dash gaps")
	var missing: Array = []
	for p: Array in _pickups(reach):
		if not reach.touchable(nodes, p[0], p[2], p[3]) and not BOOT_SECRETS.has([p[0], p[2], p[3]]) and not STRIDE_SECRETS.has([p[0], p[2], p[3]]) \
				and not STRIDE_ROOMS.has(p[0]) and not THUNDER_ROOMS.has(p[0]) and not WIND_SECRETS.has([p[0], p[2], p[3]]):
			missing.append(p)
	check(missing.is_empty(), "with the Mattock every pickup is reachable: missing %s" % [missing])
	var stuck := reach.stuck(nodes, _save_spots(reach))
	check(stuck.is_empty(), "with the Mattock, no soft-locks: %s" % [stuck.slice(0, 6)])


func test_bound_fog_holds_until_the_lantern_key() -> void:
	# Bible 4.4: the Lantern Key opens the way past Lantern Landing. Without it
	# the bound fog seals the shaft, and the rooms above stay out of reach.
	var set := {"glove": true, "mattock": true, "amber": true, "winch": true}
	var shut := Reach.new(_texts(), set, true)
	var rooms := _rooms_reached(shut.reachable(shut.spot_of(START_ROOM, "P")))
	check(rooms.has("mist/lantern_landing") and rooms.has("mist/sunken_chapel"), "the landing and the chapel are open without the key")
	check(not rooms.has("mist/veiled_rise") and not rooms.has("mist/victim_causeway"), "but the bound fog keeps the Veiled Rise shut")
	set["lantern"] = true
	var open := Reach.new(_texts(), set, true)
	var opened := _rooms_reached(open.reachable(open.spot_of(START_ROOM, "P")))
	check(opened.has("mist/veiled_rise") and opened.has("mist/victim_causeway"), "with the Lantern Key the shaft climbs to the causeway")
	check(not rooms.has("mist/victim") and opened.has("mist/victim"), "and on past the Feather Hollow to Victim")


func test_everyone_in_victim_can_be_reached() -> void:
	# Pass 145: Victim, the Mist's lamp town, is reached by the Feather Hollow's
	# west shelf with no more than the Lantern Key, and every person in it can be
	# spoken to, the fogwalker on his loft too.
	var set := {"glove": true, "mattock": true, "amber": true, "winch": true, "lantern": true}
	var reach := Reach.new(_texts(), set, true)
	var nodes := reach.reachable(reach.spot_of(START_ROOM, "P"))
	var people := 0
	for line: String in _texts()["mist/victim"].split("\n"):
		if line.begins_with("npc:"):
			var parts := line.substr(4).split(",")
			people += 1
			check(reach.touchable(nodes, "mist/victim", int(parts[0]), int(parts[1])), "%s can be reached" % parts[2].strip_edges())
	check(people >= 5, "Victim has its people (%d)" % people)


func test_wing_boots_reach_the_high_perch() -> void:
	# Bible 4.1 (A3): the Wing Boots wait in Feather Hollow, reachable without
	# them; the Life Fruit on the perch above is six rows up, past any single jump.
	var set := {"glove": true, "mattock": true, "amber": true, "winch": true, "lantern": true, "deluge": true}
	var bare := Reach.new(_texts(), set, true)
	var nodes := bare.reachable(bare.spot_of(START_ROOM, "P"))
	check(bare.touchable(nodes, "mist/feather_hollow", 30, 15), "the Wing Boots can be reached without them")
	for s: Array in BOOT_SECRETS:
		check(not bare.touchable(nodes, s[0], s[1], s[2]), "%s is out of reach without the Wing Boots" % [s])
	set["boots"] = true
	var reach := Reach.new(_texts(), set, true)
	var with_boots := reach.reachable(reach.spot_of(START_ROOM, "P"))
	var missing: Array = []
	for p: Array in _pickups(reach):
		if not reach.touchable(with_boots, p[0], p[2], p[3]) and not STRIDE_SECRETS.has([p[0], p[2], p[3]]) and not STRIDE_ROOMS.has(p[0]) \
				and not THUNDER_ROOMS.has(p[0]) and not WIND_SECRETS.has([p[0], p[2], p[3]]):
			missing.append(p)
	check(missing.is_empty(), "with the Wing Boots every pickup is reachable: missing %s" % [missing])
	var stuck := reach.stuck(with_boots, _save_spots(reach))
	check(stuck.is_empty(), "with the Wing Boots, no soft-locks: %s" % [stuck.slice(0, 6)])


func test_fire_seal_and_dry_basin_hold_until_deluge() -> void:
	# Bible 4.1 (A4) and 4.5: the Deluge scroll lies on the Marsh Road before
	# the fire seal, and the seal keeps the Scorched Hall shut until water douses it.
	var set := {"glove": true, "mattock": true, "amber": true, "winch": true, "lantern": true}
	var dry := Reach.new(_texts(), set, true)
	var nodes := dry.reachable(dry.spot_of(START_ROOM, "P"))
	var rooms := _rooms_reached(nodes)
	check(rooms.has("mist/marsh_road") and dry.touchable(nodes, "mist/marsh_road", 21, 14), "the Deluge scroll can be reached without it")
	check(not rooms.has("mist/scorched_hall"), "but the fire seal keeps the Scorched Hall shut")
	set["deluge"] = true
	var wet := Reach.new(_texts(), set, true)
	var wet_nodes := wet.reachable(wet.spot_of(START_ROOM, "P"))
	check(_rooms_reached(wet_nodes).has("mist/scorched_hall"), "with Deluge the road east opens")
	check(wet.touchable(wet_nodes, "mist/dry_cistern", 18, 7), "and the raft floats up to the cistern shelf")


func test_checker_floats_the_basin_raft_only_with_deluge() -> void:
	# A dry tank too wide to jump, a shelf over its middle: only the raft reaches it.
	var rows := grid_rows(40, 23)
	put_tiles(rows, 3, 19, "P")
	put_tiles(rows, 2, 16, "-", 3, 1)
	put_tiles(rows, 6, 13, "#", 1, 7)
	put_tiles(rows, 31, 13, "#", 1, 7)
	put_tiles(rows, 7, 19, "u", 24, 1)
	put_tiles(rows, 7, 13, "=", 24, 1)
	put_tiles(rows, 17, 8, "-", 4, 1)
	put_tiles(rows, 18, 7, "W")
	var texts := {"t/tank": room_text(["name: Tank"], rows)}
	for kit: Dictionary in [{"glove": true}, {"glove": true, "boots": true}]:
		var dry := Reach.new(texts, kit)
		check(not dry.touchable(dry.reachable(dry.spot_of("t/tank", "P")), "t/tank", 18, 7), "the shelf is out of reach while the tank is dry (%s)" % [kit.keys()])
	var wet := Reach.new(texts, {"glove": true, "deluge": true})
	check(wet.touchable(wet.reachable(wet.spot_of("t/tank", "P")), "t/tank", 18, 7), "with Deluge the raft floats up to it")


func test_checker_stands_on_drowned_boardwalks_only_after_the_spring() -> void:
	# A spiked dip too wide to jump, a drowned boardwalk over it, a fruit past it.
	var rows := grid_rows(40, 23)
	put_tiles(rows, 3, 19, "P")
	put_tiles(rows, 8, 20, ".", 22, 2)
	put_tiles(rows, 8, 21, "^", 22, 1)
	put_tiles(rows, 8, 20, "b", 22, 1)
	put_tiles(rows, 34, 19, "L")
	var texts := {"t/dip": room_text(["name: Dip"], rows)}
	var dry := Reach.new(texts, {"glove": true})
	check(not dry.touchable(dry.reachable(dry.spot_of("t/dip", "P")), "t/dip", 34, 19), "the drowned boardwalk is nothing to stand on")
	var risen := Reach.new(texts, {"glove": true, "spring_mist": true})
	check(risen.touchable(risen.reachable(risen.spot_of("t/dip", "P")), "t/dip", 34, 19), "once the spring flows it carries you across")


func test_checker_stands_on_hidden_planks_without_the_onyx() -> void:
	# Hidden planks are always there; the Black Onyx only shows them.
	var rows := grid_rows(40, 23)
	put_tiles(rows, 3, 19, "P")
	put_tiles(rows, 8, 20, ".", 22, 2)
	put_tiles(rows, 8, 21, "^", 22, 1)
	put_tiles(rows, 8, 20, "i", 22, 1)
	put_tiles(rows, 34, 19, "L")
	var texts := {"t/dip": room_text(["name: Dip"], rows)}
	var blind := Reach.new(texts, {"glove": true})
	check(blind.touchable(blind.reachable(blind.spot_of("t/dip", "P")), "t/dip", 34, 19), "the unseen planks carry you across")


func test_checker_climbs_falling_water_only_with_the_hour_glass() -> void:
	# A shaft full of falling water, a fruit at its top: it beats you back down
	# until the Hour Glass freezes it into footholds (bible A8).
	var rows := grid_rows(40, 23)
	put_tiles(rows, 0, 4, "#", 40, 16)
	put_tiles(rows, 1, 17, ".", 12, 3)
	put_tiles(rows, 3, 19, "P")
	put_tiles(rows, 13, 4, "f", 3, 16)
	put_tiles(rows, 16, 5, ".", 10, 3)
	put_tiles(rows, 22, 7, "L")
	var texts := {"t/falls": room_text(["name: Falls"], rows)}
	var dry := Reach.new(texts, {"glove": true})
	check(not dry.touchable(dry.reachable(dry.spot_of("t/falls", "P")), "t/falls", 22, 7), "the falling water bars the shaft")
	var held := Reach.new(texts, {"glove": true, "hourglass": true})
	check(held.touchable(held.reachable(held.spot_of("t/falls", "P")), "t/falls", 22, 7), "frozen, its footholds climb it")


func test_checker_rides_bounce_pods() -> void:
	# A ledge seven tiles up: out of reach, even with the Wing Boots, but for the pod.
	var rows := grid_rows(40, 23)
	put_tiles(rows, 3, 19, "P")
	put_tiles(rows, 14, 13, "#", 25, 1)
	put_tiles(rows, 30, 12, "L")
	var texts := {"t/ledge": room_text(["name: Ledge"], rows)}
	var bare := Reach.new(texts, {"boots": true})
	check(not bare.touchable(bare.reachable(bare.spot_of("t/ledge", "P")), "t/ledge", 30, 12), "the ledge is too high to jump to")
	put_tiles(rows, 12, 19, "@")
	texts = {"t/ledge": room_text(["name: Ledge"], rows)}
	var pod := Reach.new(texts, {})
	check(pod.touchable(pod.reachable(pod.spot_of("t/ledge", "P")), "t/ledge", 30, 12), "a bounce-pod beside it throws you up there")


func test_checker_rides_wind_currents_downwind_only() -> void:
	# A current blowing east across the sky, and a ledge past its far end, far
	# beyond any jump from the launch shelf.
	var rows := grid_rows(60, 23)
	put_tiles(rows, 3, 19, "P")
	put_tiles(rows, 5, 16, "#", 4, 4)
	put_tiles(rows, 10, 9, ">", 40, 3)
	put_tiles(rows, 52, 13, "#", 4, 1)
	put_tiles(rows, 53, 12, "L")
	var texts := {"t/wind": room_text(["name: Wind"], rows)}
	var east := Reach.new(texts, {})
	var nodes := east.reachable(east.spot_of("t/wind", "P"))
	check(east.touchable(nodes, "t/wind", 53, 12), "a jump into the current rides it east, past its end, onto the ledge")
	var west := Reach.new(texts, {"sky_spring": true})
	nodes = west.reachable(west.spot_of("t/wind", "P"))
	check(not west.touchable(nodes, "t/wind", 53, 12), "turned west, it carries you away from the ledge")
	check(west.stuck(nodes, [west.spot_of("t/wind", "P")]).is_empty(), "and wherever it drops you, you can walk back")
	put_tiles(rows, 10, 9, ".", 40, 3)
	texts = {"t/wind": room_text(["name: Wind"], rows)}
	var calm := Reach.new(texts, {"boots": true, "stride": true})
	check(not calm.touchable(calm.reachable(calm.spot_of("t/wind", "P")), "t/wind", 53, 12), "with no current, not even the boots and stride get there")


func test_the_turned_wind_reaches_the_thicket_niche() -> void:
	# Bible 6.9: the Spring of Sky turns the Branches' wind, and the Thicket
	# Road's current then carries you west into the elves' wind-niche.
	var set := {"glove": true, "mattock": true, "amber": true, "winch": true, "lantern": true, "deluge": true, "stride": true,
		"fire": true, "thunder": true, "sky_key": true, "hourglass": true, "boots": true}
	var before := Reach.new(_texts(), set, true)
	var nodes := before.reachable(before.spot_of(START_ROOM, "P"))
	for s: Array in WIND_SECRETS:
		check(not before.touchable(nodes, s[0], s[1], s[2]), "%s is out of reach while the storm wind blows east" % [s])
	set["sky_spring"] = true
	var reach := Reach.new(_texts(), set, true)
	var turned := reach.reachable(reach.spot_of(START_ROOM, "P"))
	var missing: Array = []
	for p: Array in _pickups(reach):
		if not reach.touchable(turned, p[0], p[2], p[3]):
			missing.append(p)
	check(missing.is_empty(), "with the wind turned, every pickup in the game is reachable: missing %s" % [missing])
	var stuck := reach.stuck(turned, _save_spots(reach))
	check(stuck.is_empty(), "with the wind turned, no soft-locks: %s" % [stuck.slice(0, 6)])


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


func test_the_old_flue_skips_the_tower_once_the_winch_turns() -> void:
	# Bible 4.3: after Zoradohna, a wall-jump climb from the Tower Foot over the
	# Rafters reaches the Deep Workings without the lift or Forepaw.
	var texts := _texts()
	var skip := {}
	for id: String in texts:
		if id.begins_with("tower/") and id not in ["tower/forepaw", "tower/forepaw_lift", "tower/mine_mouth", "tower/winch_hall"]:
			skip[id] = texts[id]
	var shut := Reach.new(skip, {"glove": true, "mattock": true})
	check(not _rooms_reached(shut.reachable(_foot_spot(shut))).has("tower/rafters"), "the damper keeps the flue shut before Zoradohna falls")
	var open := Reach.new(skip, {"glove": true, "mattock": true, "winch": true})
	var reached := _rooms_reached(open.reachable(_foot_spot(open)))
	check(reached.has("tower/rafters") and reached.has("tower/rail_gallery"), "with the winch turning, the flue climbs to the Deep Workings: %s" % [reached.keys()])


func _foot_spot(reach: Reach) -> String:
	for x in range(1, 39):
		if reach.standable("tower/foot", x, 41):
			return Reach.key("tower/foot", x, 41)
	return ""


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


func test_checker_wont_climb_through_thorns() -> void:
	# The same wall faced with thorn bulbs (Daybreak's crystal-thorned cliffs):
	# the glove can't cling through them.
	var rows := grid_rows(30, 23)
	put_tiles(rows, 3, 19, "P")
	put_tiles(rows, 14, 13, "#", 3, 7)
	put_tiles(rows, 13, 13, "o", 1, 7)
	put_tiles(rows, 22, 19, "L")
	var texts := {"t/wall": room_text(["name: Wall"], rows)}
	var gloved := Reach.new(texts, {"glove": true})
	var n1 := gloved.reachable(gloved.spot_of("t/wall", "P"))
	check(not gloved.touchable(n1, "t/wall", 22, 19), "thorns on the wall stop the climb")


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



func test_elven_stride_crosses_the_gap_to_the_warden_cache() -> void:
	# Bible 4.1 (A5): the Elven Stride waits in the Windloft, reachable without
	# it; the cache across the north bough's gap needs an air dash.
	var set := {"glove": true, "mattock": true, "amber": true, "winch": true, "lantern": true, "deluge": true}
	var bare := Reach.new(_texts(), set, true)
	var nodes := bare.reachable(bare.spot_of(START_ROOM, "P"))
	check(bare.touchable(nodes, "branches/windloft", 30, 14), "the Elven Stride can be reached without it")
	for s: Array in STRIDE_SECRETS:
		check(not bare.touchable(nodes, s[0], s[1], s[2]), "%s is out of reach without the Stride" % [s])
	set["stride"] = true
	var reach := Reach.new(_texts(), set, true)
	var strided := reach.reachable(reach.spot_of(START_ROOM, "P"))
	var missing: Array = []
	for p: Array in _pickups(reach):
		if not reach.touchable(strided, p[0], p[2], p[3]) and not BOOT_SECRETS.has([p[0], p[2], p[3]]) and not FIRE_SECRETS.has([p[0], p[2], p[3]]) \
				and not THUNDER_ROOMS.has(p[0]) and not WIND_SECRETS.has([p[0], p[2], p[3]]):
			missing.append(p)
	check(missing.is_empty(), "with the Stride every other pickup is reachable: missing %s" % [missing])
	var rooms := _rooms_reached(strided)
	check(STRIDE_ROOMS.all(func(id: String) -> bool: return rooms.has(id)), "and the Stride reaches the sky islands")
	# Daybreak's spell gates (bible 4.5), checked on the same flood to keep the suite quick.
	check(reach.touchable(strided, "daybreak/daybreak", 66, 13), "the bell-ringer on the gallery can be reached")
	check(reach.touchable(strided, "daybreak/spire_foot", 16, 19), "the Thunder scroll can be reached without it")
	for s: Array in FIRE_SECRETS:
		check(not reach.touchable(strided, s[0], s[1], s[2]), "%s is out of reach behind the bramble" % [s])
	check(THUNDER_ROOMS.all(func(id: String) -> bool: return not rooms.has(id)), "the conduit gate keeps the Spire Stair shut")
	var stuck := reach.stuck(strided, _save_spots(reach))
	check(stuck.is_empty(), "with the Stride, no soft-locks: %s" % [stuck.slice(0, 6)])


func test_fire_and_thunder_open_the_daybreak_gates() -> void:
	# Bible 4.5: bramble holds until Fire, conduit gates until Thunder. The
	# without-spell side is checked in the Stride test's flood.
	var set := {"glove": true, "mattock": true, "amber": true, "winch": true, "lantern": true, "deluge": true, "stride": true,
		"fire": true, "thunder": true, "sky_key": true, "hourglass": true, "dragon_slayer": true}
	var reach := Reach.new(_texts(), set, true)
	var lit := reach.reachable(reach.spot_of(START_ROOM, "P"))
	for s: Array in FIRE_SECRETS:
		check(reach.touchable(lit, s[0], s[1], s[2]), "%s is reachable once the bramble burns" % [s])
	var opened := _rooms_reached(lit)
	check(THUNDER_ROOMS.all(func(id: String) -> bool: return opened.has(id)), "with Thunder the Spire Stair opens, and with the Sky Key the stair down to Dartmoor")
	check(reach.touchable(lit, "daybreak/spire_stair", 24, 8), "and its top landing's chest can be reached")
	var missing: Array = []
	for p: Array in _pickups(reach):
		if THUNDER_ROOMS.has(p[0]) and not reach.touchable(lit, p[0], p[2], p[3]):
			missing.append(p)
	check(missing.is_empty(), "every pickup past the conduit gate (Dartmoor too, with the Hour Glass) is reachable: missing %s" % [missing])
	var stuck := reach.stuck(lit, _save_spots(reach))
	check(stuck.is_empty(), "with Fire and Thunder, no soft-locks: %s" % [stuck.slice(0, 6)])


func test_dartmoors_upper_gate_needs_the_sky_key() -> void:
	# The flood above runs with the Sky Key; this checks the gate tile itself.
	var texts := _texts()
	check(Reach.new(texts, {}).solid("daybreak/sky_spring", 33, 19), "the upper gate is shut without the Sky Key")
	check(not Reach.new(texts, {"sky_key": true}).solid("daybreak/sky_spring", 33, 19), "and open with it")


func test_the_throne_lies_behind_the_flesh_only_the_dragon_slayer_cuts() -> void:
	var set := {"glove": true, "mattock": true, "amber": true, "winch": true, "lantern": true, "deluge": true, "stride": true,
		"fire": true, "thunder": true, "sky_key": true, "hourglass": true}
	var reach := Reach.new(_texts(), set, true)
	var rooms := _rooms_reached(reach.reachable(reach.spot_of(START_ROOM, "P")))
	check(rooms.has("zenis/heart_gate") and not rooms.has("zenis/throne"), "without the Dragon Slayer the flesh holds the throne shut")
	set["dragon_slayer"] = true
	reach = Reach.new(_texts(), set, true)
	rooms = _rooms_reached(reach.reachable(reach.spot_of(START_ROOM, "P")))
	check(rooms.has("zenis/throne"), "with it, the way to the throne is open")


func test_checker_swims_through_deep_water() -> void:
	# A ledge (left) over a pool whose only way on is a passage under a low wall,
	# and a bank (right) level with the surface. Without water the drop is a pit.
	var rows := [
		"##############################",
		"#............................#",
		"#............................#",
		"#............................#",
		"#............................#",
		"#P.....######................#",
		"#####aaa######aaaaaaa#########",
		"#####aaa######aaaaaaa#########",
		"#####aaaaaaaaaaaaaaaa#########",
		"#####aaaaaaaaaaaaaaaa#########",
		"#####aaaaaaaaaaaaaaaa#########",
		"##############################",
	]
	var reach := Reach.new({"t/pool": "zone: test\n---\n" + "\n".join(PackedStringArray(rows))}, {})
	var nodes := reach.reachable(reach.spot_of("t/pool", "P"))
	check(nodes.has(Reach.key("t/pool", 6, 10)), "the checker swims down to the bottom of the pool")
	check(nodes.has(Reach.key("t/pool", 15, 9)), "and under the low wall into the next pool")
	check(nodes.has(Reach.key("t/pool", 22, 5)), "and jumps out of the surface onto the bank")
	check(reach.stuck(nodes, [reach.spot_of("t/pool", "P")]).is_empty(), "and can always swim back up and out the way it came")


func test_the_sunken_spring_lies_under_the_last_stone_of_the_rise() -> void:
	var texts := _texts()
	check(Reach.new(texts, {}).solid("dartmoor/meteor_rise", 14, 60), "the cracked stone holds without the Mattock")
	check(not Reach.new(texts, {"mattock": true}).solid("dartmoor/meteor_rise", 14, 60), "and breaks with it")
	var set := {"glove": true, "mattock": true, "amber": true, "winch": true, "lantern": true, "deluge": true, "stride": true,
		"fire": true, "thunder": true, "sky_key": true, "hourglass": true, "boots": true}
	var reach := Reach.new(texts, set, true)
	var rooms := _rooms_reached(reach.reachable(reach.spot_of(START_ROOM, "P")))
	check(rooms.has("sunken/spring_gate") and rooms.has("sunken/drowned_aqueduct") and rooms.has("sunken/source_hall"),
		"down through it, every room of the Sunken Spring is in reach")


## The Guru Trials (bible 3.1) are entered through the Guru, not by doors: each
## built trial's bell can be reached from its start with only the Climbing
## Glove (the first trials open after the first spring), and no spot the trial
## can put you on is cut off from the bell.
func test_every_guru_trial_can_be_cleared_with_the_glove() -> void:
	for t: Dictionary in Trials.built():
		var text := FileAccess.get_file_as_string(World.room_path(t.room))
		var reach := Reach.new({t.room: text}, {"glove": true})
		var start := reach.spot_of(t.room, "P")
		check(start != "", "%s has a start" % t.name)
		var goal := ""
		for line: String in text.split("\n"):
			if line.begins_with("prop:") and line.ends_with("trial_goal"):
				var parts := line.substr(5).split(",")
				goal = Reach.key(t.room, int(parts[0]), int(parts[1]))
		check(goal != "", "%s has a bell" % t.name)
		var nodes := reach.reachable(start)
		check(nodes.has(goal), "%s: the bell can be reached from the start" % t.name)
		var stuck := reach.stuck(nodes, [goal])
		check(stuck.is_empty(), "%s: every spot can still get to the bell: %s" % [t.name, stuck.slice(0, 6)])


## Bible 6.11 (pass 124): the checker climbs ladders. A shaft through a floor too
## high to jump has a ladder up it: the loft is in reach only with the ladder
## there, and the ladder is the way back down.
func test_checker_climbs_ladders() -> void:
	var rows := [
		"####################",
		"#..................#",
		"#..................#",
		"#..................#",
		"#########\"#########",
		"#........\"........#",
		"#........\"........#",
		"#........\"........#",
		"#........\"........#",
		"#........\"........#",
		"#P.......\"........#",
		"####################",
	]
	var text := "zone: test\n---\n" + "\n".join(PackedStringArray(rows))
	var reach := Reach.new({"t/shaft": text}, {})
	var nodes := reach.reachable(reach.spot_of("t/shaft", "P"))
	check(nodes.has(Reach.key("t/shaft", 9, 7)), "the checker hangs on the ladder halfway up")
	check(nodes.has(Reach.key("t/shaft", 3, 3)), "and climbs over its top into the loft")
	check(reach.stuck(nodes, [reach.spot_of("t/shaft", "P")]).is_empty(), "and can always climb back down")
	var bare := Reach.new({"t/shaft": text.replace("\"", ".").replace("#########.#########", "####################")}, {})
	check(not bare.reachable(bare.spot_of("t/shaft", "P")).has(Reach.key("t/shaft", 3, 3)), "without the ladder the loft is out of reach")


## Pass 125: ladders are a convenience, never a key. Take every ladder out (its
## top cell left as a plank, the rest open air) and nothing the player could
## reach before the Glove, or with it, is lost: no ladder opens a room a gate
## should hold shut.
func test_ladders_never_open_a_gated_room() -> void:
	var texts := _texts()
	var bare := {}
	var ladders := 0
	for id: String in texts:
		var parsed := Room.parse(texts[id])
		var grid: Array[String] = parsed.grid
		if not "\n".join(PackedStringArray(grid)).contains(Reach.LADDER):
			bare[id] = texts[id]
			continue
		var head: String = texts[id].substr(0, texts[id].find("\n---\n") + 5)
		var rows := []
		for y in grid.size():
			var row := grid[y]
			var out := ""
			for x in row.length():
				var c := row[x]
				if c == Reach.LADDER:
					ladders += 1
					var top := y == 0 or x >= grid[y - 1].length() or grid[y - 1][x] != Reach.LADDER
					c = "-" if top else "."
				out += c
			rows.append(out)
		bare[id] = head + "\n".join(PackedStringArray(rows))
	check(ladders > 0, "the world has ladders (%d cells)" % ladders)
	for abilities: Dictionary in [{}, {"glove": true}]:
		var with := Reach.new(texts, abilities, true)
		var without := Reach.new(bare, abilities, true)
		var a := _rooms_reached(with.reachable(with.spot_of(START_ROOM, "P")))
		var b := _rooms_reached(without.reachable(without.spot_of(START_ROOM, "P")))
		var extra := a.keys().filter(func(id: String) -> bool: return not b.has(id))
		check(extra.is_empty(), "with %s, ladders open no room the rooms without them keep shut: %s" % [abilities.keys(), extra])

