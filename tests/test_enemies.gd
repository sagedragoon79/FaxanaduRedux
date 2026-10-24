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


func test_minecart_rider_revs_charges_and_crashes_into_the_wall() -> void:
	var room := _room_with({Vector2i(22, 6): "K"})
	var m: MinecartRider = _find(room, MinecartRider)
	var p := make_player(room, Vector2i(13, 6))
	p.max_hp = 9999
	p.hp = 9999
	var hp := p.hp
	var rev_frames := 0
	var top_speed := 0.0
	for i in 240:
		await frames(1)
		if m.state == "rev":
			rev_frames += 1
		top_speed = maxf(top_speed, absf(m.velocity.x))
		if m.state == "crash":
			break
	check(rev_frames / 60.0 >= Enemy.MIN_TELEGRAPH, "the brakes shriek for at least %.2f s (%d frames)" % [Enemy.MIN_TELEGRAPH, rev_frames])
	check(top_speed > 150.0, "then the cart charges (%.0f px/s)" % top_speed)
	check(p.hp < hp, "and runs down a player who stays on the floor")
	check(m.state == "crash" and m.global_position.x < 4 * Room.TILE, "it stops dead at the far wall and tips over")
	m.queue_free()


func test_minecart_tub_turns_blows_until_it_crashes() -> void:
	var room := _room_with({Vector2i(12, 6): "K"})
	var m: MinecartRider = _find(room, MinecartRider)
	await frames(2)
	m.set_state("roll")
	var hp0 := m.hp
	m.take_hit(10, Vector2(1, 0))
	check(m.hp == hp0 - 4, "the iron tub turns most of a blow (%d)" % (hp0 - m.hp))
	m.take_hit(10, Vector2(0, 1))
	check(m.hp == hp0 - 14, "a pogo on the rider lands in full")
	m.set_state("crash")
	m.take_hit(10, Vector2(-1, 0))
	check(m.hp == hp0 - 24, "tipped over, he takes every blow")


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


func test_lantern_ghost_shows_only_near_light_and_lunges_through_walls() -> void:
	var rows := grid_rows(40, 23)
	put_tiles(rows, 6, 19, "P")
	put_tiles(rows, 14, 4, "#", 1, 16)
	put_tiles(rows, 16, 16, "A")
	var w := make_world({"test/a": room_text(["name: Fog", "zone: mist"], rows)}, "test/a")
	var p := w.player
	p.max_hp = 9999
	p.hp = 9999
	await frames(3)
	var g: LanternGhost = _find(w.room, LanternGhost)
	# Out in the murk, away from every light, it is all but invisible.
	var start := g.global_position
	var murk := Vector2.INF
	for y in range(80, 300, 16):
		for x in range(300, 620, 16):
			if murk == Vector2.INF and w.fog.clear_at(Vector2(x, y)) == 0.0 and w.fog.clear_at(Vector2(x, y) + Vector2(12, 12)) == 0.0:
				murk = Vector2(x, y)
	g.global_position = murk
	await frames(1)
	check(murk != Vector2.INF and g.seen < 0.15, "out in the fog the ghost is all but invisible (%.2f at %s)" % [g.seen, murk])
	g.global_position = start
	var windup_frames := 0
	var bright := true
	var hurt := false
	for i in 600:
		await frames(1)
		if g.state == "windup":
			windup_frames += 1
			bright = bright and g.seen >= LanternGhost.WINDUP_ALPHA
		if p.hp < p.max_hp:
			hurt = true
			break
	check(g.global_position.x < 16 * 14, "it drifted through the wall to the player")
	check(windup_frames / 60.0 >= Enemy.MIN_TELEGRAPH and bright, "its eyes flare for at least %.2f s, even in the fog (%d frames)" % [Enemy.MIN_TELEGRAPH, windup_frames])
	check(hurt, "and its lunge lands")
	check(g.seen > 0.8 or g.state == "fade", "near the player it shows (%.2f, %s)" % [g.seen, g.state])


## Bible 7: the Bog Myconid swells with glowing gills (a telegraph that lights
## the fog), bursts into a spore cloud that stings and can't be parried, and is soft
## while spent.
func test_bog_myconid_swells_bursts_spores_and_is_soft_when_spent() -> void:
	var room := _room_with({Vector2i(20, 6): "V"})
	var p := make_player(room, Vector2i(18, 6))
	p.max_hp = 9999
	p.hp = 9999
	var m: BogMyconid = _find(room, BogMyconid)
	var windup_frames := 0
	var lit := true
	var cloud: SporeCloud = null
	for i in 120:
		await frames(1)
		if m.state == "windup":
			windup_frames += 1
			lit = lit and m.is_in_group("light") and m.light_radius > 0.0
		cloud = _find(room, SporeCloud)
		if cloud != null:
			break
	check(windup_frames / 60.0 >= Enemy.MIN_TELEGRAPH, "the cap swells for at least %.2f s (%d frames)" % [Enemy.MIN_TELEGRAPH, windup_frames])
	check(windup_frames > 0 and lit, "its gills glow through the fog while it swells")
	check(cloud != null and not m.is_in_group("light"), "then it bursts into a spore cloud and the glow goes out")
	# The cloud reaches the player two tiles away and stings.
	var hp := p.hp
	var hurt_frames := 0
	for i in 60:
		await frames(1)
		if p.hp < hp:
			hurt_frames += 1
			hp = p.hp
	check(hurt_frames >= 1 and hurt_frames <= 2, "the spores sting on arrival and on the tick, not every frame (%d)" % hurt_frames)
	# Spent, it takes half again the damage.
	check(m.state == "spent" or m.state == "burst", "after the burst its cap sags open (%s)" % m.state)
	var before := m.hp
	m.take_hit(10, Vector2.RIGHT)
	check(before - m.hp == 15, "spent, a 10 hit deals 15 (%d)" % (before - m.hp))
	var firm := false
	for i in 160:
		await frames(1)
		firm = firm or m.state == "idle"
		if not is_instance_valid(cloud):
			break
	check(not is_instance_valid(cloud), "the cloud thins away")
	check(firm, "and the myconid firms up again")
	m.set_state("idle")
	before = m.hp
	m.take_hit(10, Vector2.RIGHT)
	check(before - m.hp == 10, "firm, it takes normal damage (%d)" % (before - m.hp))


## Bible 7: the Leaf Mantis hides as a leaf cluster (harmless to touch), unfolds
## for a fair telegraph when you come near, lunges with its scythes, then is left
## overreached and soft.
func test_leaf_mantis_hides_unfolds_lunges_and_is_soft_when_overreached() -> void:
	var room := _room_with({Vector2i(24, 6): "m"})
	var p := make_player(room, Vector2i(4, 6))
	p.max_hp = 9999
	p.hp = 9999
	var m: LeafMantis = _find(room, LeafMantis)
	await frames(30)
	check(m.state == "hide" and m.contact_damage == 0, "far off, it stays folded and harmless (%s)" % m.state)
	p.global_position = Vector2(19 * 16 + 8, 7 * 16)
	p.reset_physics_interpolation()
	var unfold_frames := 0
	var hp := p.hp
	var hurt := false
	var lunged := false
	for i in 90:
		await frames(1)
		if m.state == "unfold":
			unfold_frames += 1
		lunged = lunged or m.state == "lunge"
		if p.hp < hp:
			hurt = true
		if m.state == "recover":
			break
	check(unfold_frames / 60.0 >= Enemy.MIN_TELEGRAPH, "it unfolds for at least %.2f s (%d frames)" % [Enemy.MIN_TELEGRAPH, unfold_frames])
	check(lunged and hurt, "then lunges and its scythes land")
	check(hp - p.hp <= LeafMantis.SLASH_DAMAGE + 1, "once per lunge (%d)" % (hp - p.hp))
	check(m.state == "recover", "and it is left overreached (%s)" % m.state)
	var before := m.hp
	m.take_hit(10, Vector2.RIGHT)
	check(before - m.hp == 15, "overreached, a 10 hit deals 15 (%d)" % (before - m.hp))


## Striking a hidden mantis springs it open; its slash can be parried.
func test_leaf_mantis_springs_open_when_struck_and_can_be_parried() -> void:
	var room := _room_with({Vector2i(20, 6): "m"})
	var p := make_player(room, Vector2i(4, 6))
	p.max_hp = 9999
	p.hp = 9999
	var m: LeafMantis = _find(room, LeafMantis)
	await frames(10)
	m.take_hit(5, Vector2.RIGHT)
	check(m.state == "unfold", "struck while folded, it springs open (%s)" % m.state)
	await frames(40)
	# Now meet its next lunge with a parry.
	p.global_position = Vector2(m.global_position.x - 40.0, 7 * 16)
	p.reset_physics_interpolation()
	p.facing = 1
	for i in 120:
		await frames(1)
		if m.state == "unfold" and m.state_time >= LeafMantis.UNFOLD - 3.0 / 60.0:
			break
	var hp := p.hp
	p.input.block_pressed = true
	p.input.block_held = true
	await frames(10)
	check(p.hp == hp, "a parried slash does no damage (%d)" % (hp - p.hp))
	check(m.is_staggered(), "and staggers the mantis")
