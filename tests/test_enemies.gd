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
