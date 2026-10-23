extends TestSuite
## Melee combo, shield, potion, spells, MP, gold and death (design bible section 5).

const ARENA := [
	"####################",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"####################",
]


func _arena_with(ch: String, cell: Vector2i) -> Room:
	var rows := ARENA.duplicate()
	var row: String = rows[cell.y]
	rows[cell.y] = row.substr(0, cell.x) + ch + row.substr(cell.x + 1)
	return make_room(rows)


func _find(room: Room, type: Variant) -> Node:
	for c in room.get_children():
		if is_instance_of(c, type):
			return c
	return null


func test_three_hit_ground_combo() -> void:
	var room := _arena_with("E", Vector2i(5, 6))
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	var dummy: TrainingDummy = _find(room, TrainingDummy)
	var c := p.combat
	var seen: Array[int] = []
	for i in 3:
		p.input.attack_pressed = true
		await frames(1)
		seen.append(p.combo_index)
		await frames(int(c.combo_cooldowns[i] * 60.0) + 1)
	check(seen == [1, 2, 3], "combo indices %s" % [seen])
	check(dummy.hp == TrainingDummy.HP - c.slash_damage * 2 - c.heavy_damage, "two light hits and one heavy (dummy hp %d)" % dummy.hp)


func test_combo_resets_after_window() -> void:
	var room := make_room(ARENA)
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	p.input.attack_pressed = true
	await frames(1)
	await frames(int(p.combat.combo_window * 60.0) + 5)
	p.input.attack_pressed = true
	await frames(1)
	check(p.combo_index == 1, "combo restarts after the window (index %d)" % p.combo_index)


func test_air_combo_is_two_hits() -> void:
	var rows := ARENA.duplicate()
	for i in 12:
		rows.insert(1, "#..................#")
	var room := make_room(rows)
	var p := make_player(room, Vector2i(9, 1), {"glove": false})
	var seen: Array[int] = []
	for i in 3:
		p.input.attack_pressed = true
		await frames(1)
		seen.append(p.combo_index)
		await frames(13)
	check(seen == [1, 2, 1], "air combo cycles after two hits %s" % [seen])


func test_attack_press_is_buffered() -> void:
	var room := make_room(ARENA)
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	p.input.attack_pressed = true
	await frames(4)
	# Pressed during the cooldown; it should fire as soon as the cooldown ends.
	p.input.attack_pressed = true
	await frames(int(p.combat.combo_cooldowns[0] * 60.0))
	check(p.combo_index == 2, "buffered press continued the combo (index %d)" % p.combo_index)


func _dwarf_arena() -> Array:
	var room := _arena_with("D", Vector2i(6, 6))
	var p := make_player(room, Vector2i(3, 6))
	var dwarf: RotDwarf = _find(room, RotDwarf)
	return [room, p, dwarf]


## Waits until the swing is `frames_before` frames away (1 = it lands next frame).
func _wait_for_swing(dwarf: RotDwarf, frames_before: int) -> void:
	for i in 120:
		if dwarf.state == "windup" and dwarf.state_time >= RotDwarf.WINDUP - frames_before / 60.0:
			return
		await frames(1)


func test_parry_staggers_and_prevents_damage() -> void:
	var a := _dwarf_arena()
	var p: Player = a[1]
	var dwarf: RotDwarf = a[2]
	await _wait_for_swing(dwarf, 3)
	p.input.block_pressed = true
	p.input.block_held = true
	await frames(6)
	check(p.hp == p.max_hp, "parried swing does no damage (hp %d)" % p.hp)
	check(dwarf.is_staggered(), "parry staggers the Rot Dwarf")


func test_guard_halves_damage_and_costs_mp() -> void:
	var a := _dwarf_arena()
	var p: Player = a[1]
	var dwarf: RotDwarf = a[2]
	p.input.block_held = true
	await _wait_for_swing(dwarf, 1)
	var mp_before := p.mp
	await frames(4)
	var expected := p.max_hp - int(round(RotDwarf.SWING_DAMAGE * (1.0 - p.combat.guard_reduction)))
	check(p.hp == expected, "guarded hit takes reduced damage (hp %d, want %d)" % [p.hp, expected])
	check(p.mp < mp_before - p.combat.guard_mp_cost + 1.0, "guarding costs MP")


func test_clean_hit_knocks_back() -> void:
	var a := _dwarf_arena()
	var p: Player = a[1]
	var dwarf: RotDwarf = a[2]
	await _wait_for_swing(dwarf, 1)
	await frames(3)
	check(p.hp == p.max_hp - RotDwarf.SWING_DAMAGE, "full damage without the shield (hp %d)" % p.hp)
	check(p.velocity.x < 0.0 and p.invulnerable, "knocked away and briefly invulnerable")


func test_red_potion_heals_over_drink_time() -> void:
	var room := make_room(ARENA)
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	p.hp = 50
	var x0 := p.global_position.x
	p.input.heal_pressed = true
	p.input.move_x = 1
	await frames(int(p.combat.drink_time * 60.0) - 5)
	check(p.hp == 50 and p.is_drinking, "still drinking before the drink time ends")
	check(absf(p.global_position.x - x0) < 0.5, "can't walk while drinking")
	await frames(8)
	check(p.hp == 50 + p.combat.flask_heal, "healed %d (hp %d)" % [p.combat.flask_heal, p.hp])
	check(p.flask_charges == p.combat.flask_charges - 1, "one charge used")


func test_potion_interrupted_keeps_charge() -> void:
	var room := make_room(ARENA)
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	p.hp = 50
	p.input.heal_pressed = true
	await frames(10)
	p.take_damage(10)
	await frames(40)
	check(p.hp == 40, "no heal after being hit mid-drink (hp %d)" % p.hp)
	check(p.flask_charges == p.combat.flask_charges, "interrupted drink keeps the charge")


func test_deluge_costs_mp_and_hits() -> void:
	var room := _arena_with("E", Vector2i(12, 6))
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	var dummy: TrainingDummy = _find(room, TrainingDummy)
	var mp0 := p.mp
	p.input.spell_pressed = true
	await frames(1)
	check(p.mp < mp0 - Spells.cost("deluge") + 0.5, "Deluge costs %.0f MP" % Spells.cost("deluge"))
	await frames(40)
	check(dummy.hits_taken == 1, "water bolt hits the dummy")


func test_deluge_needs_mp_and_ability() -> void:
	var room := make_room(ARENA)
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	p.mp = 5.0
	p.input.spell_pressed = true
	await frames(1)
	check(runner.get_tree().get_nodes_in_group("projectile").is_empty(), "no cast without enough MP")
	p.mp = p.combat.max_mp
	p.abilities["deluge"] = false
	p.input.spell_pressed = true
	await frames(1)
	check(runner.get_tree().get_nodes_in_group("projectile").is_empty(), "no cast without the spell")


func test_melee_hit_restores_mp() -> void:
	var room := _arena_with("E", Vector2i(5, 6))
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	p.mp = 20.0
	p.input.attack_pressed = true
	await frames(3)
	check(p.mp >= 20.0 + p.combat.mp_per_melee_hit, "MP from a melee hit (mp %.1f)" % p.mp)


func test_enemy_drops_gold_that_flies_to_player() -> void:
	var room := _arena_with("M", Vector2i(6, 6))
	var p := make_player(room, Vector2i(3, 6))
	var m: Monodron = _find(room, Monodron)
	m.gold_min = 7
	m.gold_max = 7
	m.contact_damage = 0
	await frames(2)
	m.take_hit(999, Vector2(1, 0))
	await frames(150)
	check(p.gold == 7, "collected all 7 gold (got %d)" % p.gold)


func test_death_drops_purse_and_respawns() -> void:
	var room := make_room(ARENA)
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	p.spawn_point = p.global_position
	p.gold = 100
	p.teleport(p.global_position + Vector2(160, 0))
	await frames(3)
	var death_x := p.global_position.x
	p.take_damage(999)
	check(p.dead, "player died")
	check(p.gold == 40 and p.purse != null and p.purse.value == 60, "60% of gold dropped in a purse")
	await frames(int(p.combat.respawn_delay * 60.0) + 2)
	check(not p.dead and p.hp == p.max_hp, "respawned with full health")
	check(absf(p.global_position.x - p.spawn_point.x) < 2.0, "respawned at the spawn point")
	# Walk back to the purse.
	for i in 120:
		p.input.move_x = 1
		await frames(1)
		if p.global_position.x > death_x:
			break
	p.input.move_x = 0
	await frames(2)
	check(p.gold == 100, "recovered the purse (gold %d)" % p.gold)


func test_second_death_loses_the_purse() -> void:
	var room := make_room(ARENA)
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	p.gold = 100
	p.teleport(p.global_position + Vector2(160, 0))
	await frames(2)
	p.take_damage(999)
	var first := p.purse
	await frames(int(p.combat.respawn_delay * 60.0) + 70)
	p.take_damage(999)
	await frames(1)
	check(not is_instance_valid(first), "the first purse is gone")
	check(p.purse != null and p.purse.value == 24, "new purse holds 60%% of the remaining 40 (got %s)" % [p.purse.value if p.purse else -1])


func test_contact_damage() -> void:
	var room := _arena_with("M", Vector2i(3, 6))
	var p := make_player(room, Vector2i(3, 6))
	await frames(3)
	check(p.hp == p.max_hp - 20, "touching an enemy hurts (hp %d)" % p.hp)


func test_camera_subpixel_and_bounds() -> void:
	var room := make_room(ARENA)
	var p := make_player(room, Vector2i(3, 6))
	var cam := GameCamera.new()
	cam.target = p
	cam.view_size = Vector2(160, 90)
	cam.set_room_limits(room.pixel_rect())
	arena.add_child(cam)
	var ok := true
	for i in 60:
		p.input.move_x = 1
		await frames(1)
		var whole := cam.global_position == cam.global_position.floor()
		var frac_ok := cam.subpixel.x >= 0.0 and cam.subpixel.x < 1.0 and cam.subpixel.y >= 0.0 and cam.subpixel.y < 1.0
		var inside := cam.exact_position.x >= 80.0 - 0.01 and cam.exact_position.x <= room.pixel_rect().end.x - 80.0 + 0.01
		ok = ok and whole and frac_ok and inside
	check(ok, "camera stays on whole pixels, sub-pixel remainder in [0,1), inside room bounds")
