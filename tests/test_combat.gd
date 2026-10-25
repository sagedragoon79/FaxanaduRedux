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
		# Whole render pixels: GameCamera.DETAIL of them per world pixel.
		var scaled := cam.global_position * GameCamera.DETAIL
		var whole := scaled == scaled.floor()
		var step := 1.0 / GameCamera.DETAIL
		var frac_ok := cam.subpixel.x >= 0.0 and cam.subpixel.x < step and cam.subpixel.y >= 0.0 and cam.subpixel.y < step
		var inside := cam.exact_position.x >= 80.0 - 0.01 and cam.exact_position.x <= room.pixel_rect().end.x - 80.0 + 0.01
		ok = ok and whole and frac_ok and inside
	check(ok, "camera stays on whole render pixels, sub-pixel remainder under one, inside room bounds")


func test_camera_renders_at_detail() -> void:
	var cam := GameCamera.new()
	arena.add_child(cam)
	await frames(1)
	check(cam.zoom == Vector2(GameCamera.DETAIL, GameCamera.DETAIL), "the camera zooms the world to its render density (%s)" % cam.zoom)
	cam.queue_free()


func test_fire_arcs_bursts_and_scorches_foes_in_reach() -> void:
	# Bible 4.1: Fire is thrown in an arc and bursts on what it meets.
	var room := _arena_with("E", Vector2i(10, 6))
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	var dummy: TrainingDummy = _find(room, TrainingDummy)
	p.equipped_spell = "fire"
	var mp0 := p.mp
	p.input.spell_pressed = true
	await frames(1)
	check(absf(p.mp - (mp0 - Spells.cost("fire"))) < 0.5, "Fire costs %.0f MP" % Spells.cost("fire"))
	var balls := runner.get_tree().get_nodes_in_group("projectile")
	check(balls.size() == 1 and balls[0] is Fireball, "a fireball is thrown")
	if balls.is_empty():
		return
	var ball := balls[0] as Fireball
	var y0 := ball.global_position.y
	await frames(6)
	check(ball.global_position.y < y0 - 4.0, "it rises first (%.1f -> %.1f)" % [y0, ball.global_position.y])
	await frames(70)
	check(dummy.hits_taken == 1, "it bursts on the dummy (%d hits)" % dummy.hits_taken)
	check(runner.get_tree().get_nodes_in_group("projectile").is_empty(), "and is gone")


func test_next_spell_cycles_only_through_spells_you_own() -> void:
	var room := make_room(ARENA)
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	p.abilities["fire"] = false
	p.abilities["thunder"] = false
	p.abilities["tilte"] = false
	p.equipped_spell = "deluge"
	p.input.spell_next_pressed = true
	await frames(1)
	check(p.equipped_spell == "deluge", "with only Deluge, Next Spell keeps it")
	p.abilities["fire"] = true
	p.input.spell_next_pressed = true
	await frames(1)
	check(p.equipped_spell == "fire", "with Fire owned it switches to Fire")
	p.input.spell_next_pressed = true
	await frames(1)
	check(p.equipped_spell == "deluge", "and back round to Deluge")
	p.abilities["deluge"] = false
	p.input.spell_next_pressed = true
	await frames(1)
	check(p.equipped_spell == "fire", "it skips a spell you don't own")


func test_thunder_bolt_strikes_a_foe() -> void:
	var room := _arena_with("E", Vector2i(12, 6))
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	var dummy: TrainingDummy = _find(room, TrainingDummy)
	p.equipped_spell = "thunder"
	var mp0 := p.mp
	p.input.spell_pressed = true
	await frames(1)
	check(absf(p.mp - (mp0 - Spells.cost("thunder"))) < 0.5, "Thunder costs %.0f MP" % Spells.cost("thunder"))
	var bolts := runner.get_tree().get_nodes_in_group("projectile")
	check(bolts.size() == 1 and bolts[0] is ThunderBolt, "a bolt flies")
	await frames(20)
	check(dummy.hits_taken == 1, "and strikes the dummy (%d hits)" % dummy.hits_taken)



func test_the_giant_blade_sweeps_wide_but_swings_slow() -> void:
	var room := _arena_with("E", Vector2i(6, 6))
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	var dummy: TrainingDummy = _find(room, TrainingDummy)
	var plain := p._attack_rect().size
	GameState.data.equipment.blade = "giant_blade"
	GameState.refresh_stats(p)
	check(p.slash_damage == 15 and p.heavy_damage == 28, "it cuts for 15 and 28 (%d, %d)" % [p.slash_damage, p.heavy_damage])
	p.input.attack_pressed = true
	await frames(1)
	var big := p._attack_rect().size
	check(big == plain + Vector2(16, 20), "its slash reaches 16 px further and sweeps 20 px taller (%s from %s)" % [big, plain])
	var wait := p.combat.combo_cooldowns[0] * 1.3
	check_near(p._attack_cooldown, wait - 1.0 / 60.0, 0.02, "and the swing takes 30% longer to recover")
	await frames(3)
	check(dummy.hp == TrainingDummy.HP - 15, "it strikes the dummy two tiles away (hp %d)" % dummy.hp)
	GameState.data.equipment.blade = "long_sword"
	GameState.refresh_stats(p)
	check(p.arc_bonus == 0.0 and p.swing_mult == 1.0, "other blades keep the plain arc and pace")


func test_a_wide_room_eases_the_camera_out() -> void:
	# Bible 6.7: a room with `camera: wide` frames 25% more each way, easing out.
	var rows := ARENA.duplicate()
	for i in 30:
		rows.insert(1, "#..................#")
	var room := make_room(rows)
	var p := make_player(room, Vector2i(3, 36))
	var cam := GameCamera.new()
	cam.target = p
	cam.view_size = Vector2(160, 90)
	cam.set_room_limits(room.pixel_rect(), true)
	arena.add_child(cam)
	check(cam.frame_goal == GameCamera.WIDE and cam.frame_scale == 1.0, "it starts at the normal framing and aims wide")
	await frames(6)
	var mid := cam.frame_scale
	check(mid < 1.0 and mid > GameCamera.WIDE, "it eases out, not in one jump (%.3f)" % mid)
	await frames(int(GameCamera.ZOOM_EASE * 60.0 * 3.0))
	check_near(cam.frame_scale, GameCamera.WIDE, 0.002, "and settles wide")
	check(cam.zoom.is_equal_approx(Vector2.ONE * GameCamera.DETAIL * GameCamera.WIDE), "the zoom follows (%s)" % cam.zoom)
	check(cam.visible_size().is_equal_approx(Vector2(200, 112.5)), "showing 25%% more each way (%s)" % cam.visible_size())
	var half := cam.visible_size() * 0.5
	var r := room.pixel_rect()
	var e := cam.exact_position
	check(e.x >= r.position.x + half.x - 0.01 and e.y <= r.end.y - half.y + 0.01, "the wider view still stays inside the room (%s)" % e)
	var step := 1.0 / GameCamera.DETAIL
	check(cam.subpixel.x >= 0.0 and cam.subpixel.x < step and cam.subpixel.y < step, "the sub-pixel shift stays under one render pixel (%s)" % cam.subpixel)
	cam.set_room_limits(r)
	check(cam.frame_scale == 1.0 and cam.frame_goal == 1.0, "a normal room snaps back at once, so the view never shows past its edges")
	cam.queue_free()


func test_the_wide_camera_never_shows_past_a_small_room() -> void:
	var room := make_room(ARENA)  # 320 x 128 px
	var cam := GameCamera.new()
	cam.view_size = Vector2(160, 90)
	cam.set_room_limits(room.pixel_rect(), true)
	check(cam.visible_size().y <= 128.0 and cam.frame_goal >= 90.0 / 128.0 - 0.001, "the framing stops where the room's height runs out (%.3f)" % cam.frame_goal)
	cam.set_room_limits(Rect2(0, 0, 170, 200), true)
	check_near(cam.frame_goal, 160.0 / 170.0, 0.001, "and where its width runs out")
	cam.set_room_limits(Rect2(0, 0, 150, 80), true)
	check(cam.frame_goal == 1.0, "a room smaller than the screen is never zoomed in")
	cam.free()


func test_the_roost_frames_the_storm_wide() -> void:
	var w := make_world({}, "daybreak/roost")
	await frames(3)
	check(w.room.wide_camera(), "the Roost asks for the wide camera")
	check_near(w.camera.frame_goal, GameCamera.WIDE, 0.001, "and has the sky to frame it (%.3f)" % w.camera.frame_goal)
	check(w.room.pixel_rect().size.y >= w.camera.view_size.y / GameCamera.WIDE, "it is tall enough for the wide view")


func test_tilte_wakes_then_seeks_the_nearest_foe() -> void:
	# Bible 4.1: Tilte is a homing spirit orb.
	var room := _arena_with("E", Vector2i(12, 6))
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	var dummy: TrainingDummy = _find(room, TrainingDummy)
	p.equipped_spell = "tilte"
	var mp0 := p.mp
	p.input.spell_pressed = true
	await frames(1)
	check(absf(p.mp - (mp0 - Spells.cost("tilte"))) < 0.5, "Tilte costs %.0f MP" % Spells.cost("tilte"))
	var orbs := runner.get_tree().get_nodes_in_group("projectile")
	check(orbs.size() == 1 and orbs[0] is TilteOrb, "one spirit orb leaves the hand")
	if orbs.is_empty():
		return
	var orb := orbs[0] as TilteOrb
	await frames(int(TilteOrb.WAKE * 60.0) - 2)
	check(orb.velocity.length() < TilteOrb.DRIFT, "it hangs while it wakes, the tell (%.0f px/s)" % orb.velocity.length())
	await frames(4)
	check(orb.target == dummy, "then it chooses the dummy")
	await _until(func() -> bool: return dummy.hits_taken > 0, 90)
	check(dummy.hits_taken == 1 and dummy.hp == TrainingDummy.HP - 14, "and strikes it for 14 (hp %d)" % dummy.hp)


func test_tilte_turns_back_for_a_foe_behind() -> void:
	var rows := ARENA.duplicate()
	for i in 4:
		rows.insert(1, "#..................#")
	rows[10] = "#.E................#"
	var room := make_room(rows)
	var p := make_player(room, Vector2i(9, 10))
	await frames(6)
	var dummy: TrainingDummy = _find(room, TrainingDummy)
	p.facing = 1
	p.equipped_spell = "tilte"
	p.input.spell_pressed = true
	await frames(1)
	var hit := await _until(func() -> bool: return dummy.hits_taken > 0, 120)
	check(hit, "an orb cast away from the only foe wheels round and finds it")


func test_tilte_swarm_fans_three_orbs() -> void:
	var room := _arena_with("E", Vector2i(12, 6))
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	var dummy: TrainingDummy = _find(room, TrainingDummy)
	p.tilte_swarm = true
	p.equipped_spell = "tilte"
	var mp0 := p.mp
	p.input.spell_pressed = true
	await frames(1)
	var orbs := runner.get_tree().get_nodes_in_group("projectile")
	check(orbs.size() == 3, "Tilte Swarm throws three orbs (%d)" % orbs.size())
	check(absf(p.mp - (mp0 - Spells.cost("tilte"))) < 0.5, "for the cost of one")
	if orbs.size() == 3:
		var a := [(orbs[0] as TilteOrb).heading.angle(), (orbs[1] as TilteOrb).heading.angle(), (orbs[2] as TilteOrb).heading.angle()]
		a.sort()
		check(a[1] - a[0] > 0.4 and a[2] - a[1] > 0.4, "in a fan (%s)" % [a])
	await _until(func() -> bool: return dummy.hits_taken >= 3, 150)
	check(dummy.hp == TrainingDummy.HP - 30, "each strikes for 10 (hp %d)" % dummy.hp)


func _until(cond: Callable, max_frames: int) -> bool:
	for i in max_frames:
		if cond.call():
			return true
		await frames(1)
	return cond.call()


func test_a_hit_sparks_where_the_blade_meets_the_foe() -> void:
	var room := _arena_with("E", Vector2i(5, 6))
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	var dummy: TrainingDummy = _find(room, TrainingDummy)
	p.input.attack_pressed = true
	await frames(2)
	var spark: HitSpark = _find(room, HitSpark)
	if not check(spark != null, "a hit throws a spark"):
		return
	check(spark.dir.x > 0.0 and spark.size == 1.0, "along the swing, light-sized")
	var swing := p._attack_rect().grow(1.0)
	check(swing.has_point(spark.global_position), "inside the swing, where it meets the foe (%s)" % spark.global_position)
	check(spark.global_position.x <= dummy.global_position.x + 0.5, "on the near side of the foe")
	await frames(int(HitSpark.LIFE * 60.0) + 4)
	check(_find(room, HitSpark) == null, "and is gone in a blink")
	# The third hit of the combo is the heavy one: a bigger spark.
	await frames(30)
	for i in 3:
		p.input.attack_pressed = true
		await frames(1)
		if i < 2:
			await frames(int(p.combat.combo_cooldowns[i] * 60.0) + 1)
	var big: HitSpark = null
	for c in room.get_children():
		if c is HitSpark:
			big = c
	check(p.is_heavy_swing and big != null and big.size == Player.HEAVY_SPARK, "the heavy finisher sparks bigger")
	await frames(3)
	var count := room.get_children().filter(func(c: Node) -> bool: return c is HitSpark).size()
	check(count == 1, "one spark per foe per swing (%d)" % count)


func test_a_miss_throws_no_spark() -> void:
	var room := make_room(ARENA)
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	p.input.attack_pressed = true
	await frames(3)
	check(_find(room, HitSpark) == null, "a swing at the air sparks nothing")


func test_being_hurt_flashes_the_screen_edge_red() -> void:
	var room := make_room(ARENA)
	var p := make_player(room, Vector2i(3, 6))
	var hud := GameHud.new()
	hud.player = p
	arena.add_child(hud)
	await frames(2)
	check(hud.edge_strength() == 0.0, "no glow at full health")
	p.take_damage(30)
	await frames(2)
	check(hud.hurt > 0.8 and hud.edge_strength() > 0.4, "a hit flashes the edge (%.2f)" % hud.edge_strength())
	await frames(40)
	check(hud.edge_strength() < 0.05, "and it fades in well under a second (%.2f)" % hud.edge_strength())
	Feel.flash_scale = 0.0
	p._invuln_timer = 0.0
	p.take_damage(10)
	await frames(2)
	check(hud.edge_strength() == 0.0, "the Flashes option turns it off")
	Feel.flash_scale = 1.0
	p._invuln_timer = 0.0
	p.hp = 50
	await frames(2)
	p.take_damage(5)
	await frames(1)
	var healed := p.hp
	p.hp = healed + 20
	await frames(2)
	check(hud.hurt < 1.0, "healing doesn't flash")


func test_low_health_beats_and_pulses() -> void:
	var room := make_room(ARENA)
	var p := make_player(room, Vector2i(3, 6))
	var hud := GameHud.new()
	hud.player = p
	arena.add_child(hud)
	await frames(30)
	check(p.heartbeats == 0 and hud.edge_strength() == 0.0, "no heartbeat at full health")
	p.hp = p.combat.low_health
	await frames(2)
	check(p.is_low_health() and p.heartbeats == 1, "down to one mask, the heart beats at once")
	var lo := 1.0
	var hi := 0.0
	for i in int(p.combat.heartbeat_interval * 60.0) + 2:
		await frames(1)
		lo = minf(lo, hud.edge_strength())
		hi = maxf(hi, hud.edge_strength())
	check(p.heartbeats == 2, "and again each %.2f s (%d)" % [p.combat.heartbeat_interval, p.heartbeats])
	check(lo > 0.0 and hi - lo > 0.08, "the edge pulses with it (%.2f to %.2f)" % [lo, hi])
	p.hp = p.combat.low_health + 1
	await frames(60)
	check(p.heartbeats == 2 and hud.edge_strength() == 0.0, "healed above a mask, it stops")
