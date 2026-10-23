extends TestSuite
## Enemy behavior: telegraphs, movement toward the player, shields, respawn.

const WIDE := [
	"##############################",
	"#............................#",
	"#............................#",
	"#............................#",
	"#............................#",
	"#............................#",
	"#............................#",
	"##############################",
]


func _room_with(spots: Dictionary) -> Room:
	var rows := WIDE.duplicate()
	for cell: Vector2i in spots:
		var row: String = rows[cell.y]
		rows[cell.y] = row.substr(0, cell.x) + spots[cell] + row.substr(cell.x + 1)
	return make_room(rows)


func _find(room: Room, type: Variant) -> Node:
	for c in room.get_children():
		if is_instance_of(c, type):
			return c
	return null


func test_monodron_telegraphs_then_hops_toward_player() -> void:
	var room := _room_with({Vector2i(12, 6): "M"})
	var p := make_player(room, Vector2i(5, 6))
	p.max_hp = 9999
	p.hp = 9999
	var m: Monodron = _find(room, Monodron)
	var x0 := m.global_position.x
	var windup_frames := 0
	var hopped := false
	for i in 90:
		await frames(1)
		if m.state == "windup":
			windup_frames += 1
		if m.state == "hop":
			hopped = true
	check(windup_frames / 60.0 >= Enemy.MIN_TELEGRAPH, "telegraph lasts at least %.2f s (%d frames)" % [Enemy.MIN_TELEGRAPH, windup_frames])
	check(hopped and m.global_position.x < x0 - 20.0, "hopped toward the player (moved %.1f)" % (m.global_position.x - x0))


func test_hornet_swoops_at_player() -> void:
	var room := _room_with({Vector2i(12, 3): "H"})
	var p := make_player(room, Vector2i(6, 6))
	p.max_hp = 9999
	p.hp = 9999
	var h: Hornet = _find(room, Hornet)
	var start := h.center().distance_to(p.global_position + Vector2(0, -20))
	var closest := start
	var windup_frames := 0
	for i in 120:
		await frames(1)
		if h.state == "windup":
			windup_frames += 1
		closest = minf(closest, h.center().distance_to(p.global_position + Vector2(0, -20)))
	check(windup_frames / 60.0 >= Enemy.MIN_TELEGRAPH, "buzz telegraph lasts at least %.2f s" % Enemy.MIN_TELEGRAPH)
	check(closest < start - 40.0, "swooped at the player (closest %.1f from %.1f)" % [closest, start])


func test_sap_spitter_telegraphs_and_lobs_a_glob_that_leaves_sap() -> void:
	var room := _room_with({Vector2i(20, 6): "T"})
	var p := make_player(room, Vector2i(9, 6))
	p.max_hp = 9999
	p.hp = 9999
	var t: SapSpitter = _find(room, SapSpitter)
	var windup_frames := 0
	var glob: SapGlob = null
	for i in 90:
		await frames(1)
		if t.state == "windup":
			windup_frames += 1
		if glob == null:
			glob = _find(room, SapGlob)
		if glob != null:
			break
	check(windup_frames / 60.0 >= Enemy.MIN_TELEGRAPH, "the sac swells for at least %.2f s (%d frames)" % [Enemy.MIN_TELEGRAPH, windup_frames])
	check(glob != null and glob.velocity.x < 0.0 and glob.velocity.y < 0.0, "then it lobs a glob up and toward the player")
	var hp := p.hp
	for i in 80:
		await frames(1)
		if p.hp < hp:
			break
	check(p.hp < hp, "the glob lands on the player and hurts")
	# A miss leaves a puddle that slows.
	p.teleport(cell_feet(3, 6))
	await frames(1)
	var spot := cell_feet(9, 6)
	var target_x := spot.x
	var from := t.mouth()
	var miss := SapGlob.new()
	miss.velocity = SapGlob.launch(from, Vector2(target_x, spot.y - 2), SapSpitter.FLIGHT)
	miss.room = room
	room.add_child(miss)
	miss.global_position = from
	await frames(60)
	check(room.is_sap_at(spot + Vector2(0, -6)), "a glob that hits the floor leaves sap")
	await frames(roundi(SapGlob.PUDDLE_TIME * 60.0) + 5)
	check(not room.is_sap_at(spot + Vector2(0, -6)), "and the puddle dries")


func test_grub_lump_crawls_up_walls_and_over_the_ceiling() -> void:
	var room := _room_with({Vector2i(3, 6): "U"})
	var g: GrubLump = _find(room, GrubLump)
	check(g.clinging_side() == Vector2i(0, 1), "it starts on the floor")
	var sides := {}
	var inside := true
	var inner := Rect2(Vector2(16, 16), Vector2(28 * 16, 6 * 16))
	for i in 420:
		await frames(1)
		sides[g.clinging_side()] = true
		inside = inside and inner.has_point(g.global_position)
	check(sides.has(Vector2i(-1, 0)), "it climbed the left wall")
	check(sides.has(Vector2i(0, -1)), "and crossed onto the ceiling")
	check(inside, "without leaving the open space")


func test_grub_lump_telegraphs_and_drops_from_the_ceiling() -> void:
	var room := _room_with({Vector2i(12, 1): "U"})
	var g: GrubLump = _find(room, GrubLump)
	check(g.on_ceiling(), "placed under a ceiling, it clings to it")
	var p := make_player(room, Vector2i(12, 6))
	p.max_hp = 9999
	p.hp = 9999
	var hp := p.hp
	var windup_frames := 0
	var landed := false
	for i in 120:
		await frames(1)
		if g.state == "windup":
			windup_frames += 1
		if g.state == "land":
			landed = true
			break
	check(windup_frames / 60.0 >= Enemy.MIN_TELEGRAPH, "it rears for at least %.2f s before dropping (%d frames)" % [Enemy.MIN_TELEGRAPH, windup_frames])
	check(p.hp < hp, "the drop hurts the player below")
	check(landed and g.clinging_side() == Vector2i(0, 1), "it lands on the floor")
	p.teleport(cell_feet(24, 6))
	await frames(roundi(GrubLump.LAND_TIME * 60.0) + 30)
	check(g.state == "crawl", "and crawls on")


func test_iron_dwarf_telegraphs_then_slams_a_shockwave() -> void:
	var room := _room_with({Vector2i(18, 6): "I"})
	var d: IronDwarf = _find(room, IronDwarf)
	d.facing = -1
	var p := make_player(room, Vector2i(12, 6))
	p.max_hp = 9999
	p.hp = 9999
	var hp := p.hp
	var windup_frames := 0
	var wave_seen := false
	for i in 150:
		await frames(1)
		if d.state == "windup":
			windup_frames += 1
		for c in room.get_children():
			if c is Shockwave:
				wave_seen = true
		if d.state == "stuck" and p.hp < hp:
			break
	check(windup_frames / 60.0 >= Enemy.MIN_TELEGRAPH, "the hammer goes up for at least %.2f s (%d frames)" % [Enemy.MIN_TELEGRAPH, windup_frames])
	check(not d.slam_rect().intersects(p.body_rect()), "the player stood out of the hammer's reach")
	check(wave_seen and p.hp < hp, "yet the shockwave rolled along the floor and hit (hp %d)" % p.hp)
	check(d.state == "stuck", "the hammer sticks in the floor")


func test_iron_dwarf_plate_turns_blows_until_the_hammer_sticks() -> void:
	var room := _room_with({Vector2i(12, 6): "I"})
	var d: IronDwarf = _find(room, IronDwarf)
	await frames(2)
	d.set_state("patrol")
	var hp0 := d.hp
	d.take_hit(10, Vector2(1, 0))
	check(d.hp == hp0 - 5, "his plate halves a blow (%d)" % (hp0 - d.hp))
	d.set_state("stuck")
	d.take_hit(10, Vector2(-1, 0))
	check(d.hp == hp0 - 15, "with the hammer stuck, a blow lands in full")
	d.set_state("patrol")
	d.take_hit(10, Vector2(0, 1))
	check(d.hp == hp0 - 25, "a pogo from above lands in full")


func test_shockwave_hugs_the_floor_and_breaks_at_a_wall() -> void:
	var room := _room_with({})
	var w := Shockwave.new()
	w.room = room
	w.direction = 1
	room.add_child(w)
	w.global_position = cell_feet(20, 6)
	var body := Rect2(w.global_position + Vector2(-6, -40), Vector2(12, 40))
	check(w.hit_rect().intersects(body), "it hits a body standing on the floor")
	check(not w.hit_rect().intersects(Rect2(body.position - Vector2(0, 14), body.size)), "a small hop clears it")
	await frames(60)
	check(not is_instance_valid(w), "it breaks up at the wall")


func test_gear_bat_roosts_then_flings_a_gear_that_comes_back() -> void:
	var room := _room_with({Vector2i(16, 1): "B"})
	var b: GearBat = _find(room, GearBat)
	var p := make_player(room, Vector2i(26, 6))
	p.max_hp = 9999
	p.hp = 9999
	await frames(30)
	check(b.state == "roost", "it stays on its roost while the player is far off")
	p.teleport(cell_feet(10, 6))
	var hp := p.hp
	var windup_frames := 0
	var thrown := false
	var caught := false
	for i in 360:
		await frames(1)
		if b.state == "windup":
			windup_frames += 1
		if b.blade != null:
			thrown = true
		elif thrown:
			caught = true
			break
	check(windup_frames / 60.0 >= Enemy.MIN_TELEGRAPH, "the gear whirs for at least %.2f s before the throw (%d frames)" % [Enemy.MIN_TELEGRAPH, windup_frames])
	check(thrown and p.hp < hp, "the thrown gear cut the player (hp %d)" % p.hp)
	check(caught and b.has_gear(), "and flew back onto the bat's back")


func test_parried_gear_flies_home_and_staggers_its_bat() -> void:
	var room := _room_with({Vector2i(8, 3): "B"})
	var b: GearBat = _find(room, GearBat)
	await frames(2)
	b.set_state("bare")
	var g := GearBlade.new()
	g.owner_bat = b
	g.room = room
	g.direction = Vector2.RIGHT
	b.blade = g
	room.add_child(g)
	g.global_position = cell_center(20, 3)
	var hp0 := b.hp
	g.stagger()
	for i in 60:
		await frames(1)
		if b.is_staggered():
			break
	check(b.hp == hp0 - GearBlade.REFLECT_DAMAGE, "the parried gear hit its bat (%d)" % (hp0 - b.hp))
	check(b.is_staggered(), "and staggered it")
	check(b.has_gear(), "and the bat has its gear back")


func test_gear_turns_back_at_a_wall() -> void:
	var room := _room_with({Vector2i(8, 3): "B"})
	var b: GearBat = _find(room, GearBat)
	await frames(2)
	var g := GearBlade.new()
	g.owner_bat = b
	g.room = room
	g.direction = Vector2.RIGHT
	b.blade = g
	room.add_child(g)
	g.global_position = cell_center(27, 3)
	await frames(10)
	check(is_instance_valid(g) and g.phase == "back", "it rang off the wall and turned for home")
	check(g.global_position.x < 29 * Room.TILE, "without passing into the wall")


func test_rot_dwarf_shield_blocks_only_the_front() -> void:
	var room := _room_with({Vector2i(12, 6): "D"})
	var d: RotDwarf = _find(room, RotDwarf)
	await frames(2)
	d.facing = -1
	d.set_state("patrol")
	var hp0 := d.hp
	d.take_hit(8, Vector2(1, 0))  # player on his left, swinging right: front
	check(d.hp == hp0, "front hit blocked by the shield")
	d.take_hit(8, Vector2(-1, 0))  # from behind
	check(d.hp == hp0 - 8, "hit from behind lands")
	d.set_state("patrol")
	d.take_hit(8, Vector2(0, 1))  # pogo from above
	check(d.hp == hp0 - 16, "pogo from above lands")


func test_rot_dwarf_turns_to_face_player_behind() -> void:
	var room := _room_with({Vector2i(12, 6): "D"})
	var d: RotDwarf = _find(room, RotDwarf)
	d.facing = 1
	var p := make_player(room, Vector2i(10, 6))
	p.max_hp = 9999
	p.hp = 9999
	for i in 60:
		await frames(1)
		if d.facing == -1:
			break
	check(d.facing == -1, "turned around toward the player")


func test_enemies_respawn_when_configured() -> void:
	var room := _room_with({Vector2i(12, 6): "M"})
	var m: Monodron = _find(room, Monodron)
	m.respawn_time = 0.5
	await frames(2)
	m.take_hit(999, Vector2(1, 0))
	check(m.dead and not m.visible, "defeated")
	await frames(40)
	check(not m.dead and m.hp == m.max_hp and m.visible, "respawned at home")
