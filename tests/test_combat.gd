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


## A guard break (pass 242): a guard held with too little MP to pay for the
## blow breaks with its own sound, the blow lands whole, and the shield stays
## down until Block is let go and raised again.
func test_a_guard_with_no_mp_breaks_and_drops() -> void:
	var a := _dwarf_arena()
	var p: Player = a[1]
	var dwarf: RotDwarf = a[2]
	p.input.block_held = true
	await frames(2)
	p.mp = p.combat.guard_mp_cost - 1.0
	check(p.is_blocking, "the guard is up")
	await _wait_for_swing(dwarf, 1)
	Sfx.recent.clear()
	await frames(4)
	check(p.hp == p.max_hp - RotDwarf.SWING_DAMAGE, "with too little MP the blow lands whole (hp %d)" % p.hp)
	check(Player.GUARD_BREAK_SOUND in Sfx.recent and not ("guard" in Sfx.recent), "the guard breaks with its own sound, not the held guard's (%s)" % [Sfx.recent])
	check(p.guard_broken and not p.is_blocking, "and the shield drops")
	await frames(10)
	check(not p.is_blocking, "it stays down while Block is still held")
	p.input.block_held = false
	await frames(1)
	p.input.block_held = true
	await frames(1)
	check(p.is_blocking and not p.guard_broken, "let go and raise it again and it is back")
	p.input.block_held = false


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



func test_the_dwarvish_broad_sword_sweeps_wide_but_swings_slow() -> void:
	var room := _arena_with("E", Vector2i(6, 6))
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	var dummy: TrainingDummy = _find(room, TrainingDummy)
	var plain := p._attack_rect().size
	GameState.data.equipment.blade = "dwarvish_broad_sword"
	GameState.refresh_stats(p)
	check(p.slash_damage == 17 and p.heavy_damage == 32, "it cuts for 17 and 32 (%d, %d)" % [p.slash_damage, p.heavy_damage])
	p.input.attack_pressed = true
	await frames(1)
	var big := p._attack_rect().size
	check(big == plain + Vector2(16, 20), "its slash reaches 16 px further and sweeps 20 px taller (%s from %s)" % [big, plain])
	var wait := p.combat.combo_cooldowns[0] * 1.3
	check_near(p._attack_cooldown, wait - 1.0 / 60.0, 0.02, "and the swing takes 30% longer to recover")
	await frames(3)
	check(dummy.hp == TrainingDummy.HP - 17, "it strikes the dummy two tiles away (hp %d)" % dummy.hp)
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


## Death (bible 4.1, pass 132): a ring of black light strikes every foe around
## you once, through walls; bosses take half.
func test_death_strikes_every_foe_around_through_walls() -> void:
	var rows := ARENA.duplicate()
	for y in range(1, 7):
		rows[y] = rows[y].substr(0, 9) + "#" + rows[y].substr(10)
	rows[6] = "#.E......#..E......#"
	var room := make_room(rows)
	var p := make_player(room, Vector2i(5, 6))
	await frames(6)
	var dummies: Array[TrainingDummy] = []
	for c in room.get_children():
		if c is TrainingDummy:
			dummies.append(c)
	check(dummies.size() == 2, "two dummies, one beyond a wall")
	if dummies.size() != 2:
		return
	var far := dummies[0] if dummies[0].global_position.x > dummies[1].global_position.x else dummies[1]
	far.add_to_group("boss")
	p.abilities["death"] = true
	p.max_mp = 60.0
	p.mp = 60.0
	p.equipped_spell = "death"
	Sfx.recent.clear()
	p.input.spell_pressed = true
	await frames(1)
	p.input.spell_pressed = false
	check(absf(p.mp - (60.0 - Spells.cost("death"))) < 0.5, "Death costs %.0f MP" % Spells.cost("death"))
	check(Spells.cost("death") >= 40.0 and Spells.ORDER.has("death"), "the dearest spell, on the Next Spell cycle")
	check(Sfx.recent.has("death_wave"), "it tolls (%s)" % [Sfx.recent])
	await frames(int(DeathWave.DURATION * 60.0) + 4)
	var near := dummies[0] if far == dummies[1] else dummies[1]
	check(near.hits_taken == 1 and near.hp == TrainingDummy.HP - 36, "the foe beside you takes 36, once (hp %d, hits %d)" % [near.hp, near.hits_taken])
	check(far.hits_taken == 1 and far.hp == TrainingDummy.HP - 18, "a boss beyond the wall takes half, 18 (hp %d)" % far.hp)
	await frames(20)
	check(runner.get_tree().get_nodes_in_group("projectile").is_empty(), "then the ring is gone")
	p.input.spell_pressed = true
	await frames(1)
	check(p.mp < Spells.cost("death") and runner.get_tree().get_nodes_in_group("projectile").is_empty(), "and there is not enough MP left for a second")
	p.input.spell_pressed = false
	far.remove_from_group("boss")


func test_the_death_scroll_is_a_late_secret() -> void:
	check(ItemPickup.KIND_BY_CHAR.get("{", "") == "death" and "death" in ItemPickup.ABILITIES, "legend { is the Death scroll")
	var text := FileAccess.get_file_as_string("res://levels/dartmoor/kings_kennels.room")
	check(text.contains("{"), "it lies in the King's Kennels' loft, up the hidden planks")
	GameState.new_game()
	check(GameState.data.abilities.has("death") and not GameState.data.abilities.death, "a new game starts without it")


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


# --- Combat audit (pass 105, design bible 5.3) -----------------------------------

func test_a_slash_that_lands_pushes_you_back_a_few_pixels() -> void:
	var room := _arena_with("E", Vector2i(5, 6))
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	var x0 := p.global_position.x
	p.input.attack_pressed = true
	await frames(1)
	var least := x0
	for i in 20:
		await frames(1)
		least = minf(least, p.global_position.x)
	check(x0 - least >= 3.0 and x0 - least <= 6.0, "a landed slash pushes you back about 4 px (%.1f)" % (x0 - least))


func test_the_parry_window_is_0_12_s_and_pays_6_mp() -> void:
	var a := _dwarf_arena()
	var p: Player = a[1]
	var dwarf: RotDwarf = a[2]
	p.mp = 20.0
	p.has_shield = true
	# Pressed 5 frames (0.083 s) before the blade lands: a parry.
	await _wait_for_swing(dwarf, 5)
	p.input.block_pressed = true
	await frames(1)
	p.input.block_pressed = false
	await frames(6)
	check(p.hp == p.max_hp and dwarf.is_staggered(), "inside the window it parries (hp %d)" % p.hp)
	check(p.mp >= 20.0 + p.combat.parry_mp_gain - 0.01, "a parry pays %d MP (%.1f)" % [p.combat.parry_mp_gain, p.mp])
	check(Feel.last_hitstop == p.combat.parry_hitstop, "with a 140 ms hit-stop")
	await frames(50)
	check(dwarf.is_staggered(), "the foe still reels after 0.9 s")
	await frames(10)
	check(not dwarf.is_staggered(), "and recovers by 1.1 s")
	# Pressed 10 frames (0.167 s) early: too soon, the blow lands.
	(a[0] as Node).queue_free()
	await frames(2)
	var b := _dwarf_arena()
	var p2: Player = b[1]
	var dwarf2: RotDwarf = b[2]
	p2.has_shield = true
	await _wait_for_swing(dwarf2, 10)
	p2.input.block_pressed = true
	await frames(1)
	p2.input.block_pressed = false
	await frames(12)
	check(p2.hp < p2.max_hp and not dwarf2.is_staggered(), "outside the window it doesn't (hp %d)" % p2.hp)


## Pass 210: a foe's fall and your own hold the world for the bible's times
## (6.7), read from CombatTuning; until then both were bare numbers in code.
func test_a_kill_and_a_fall_hold_their_hit_stops() -> void:
	var a := _dwarf_arena()
	var p: Player = a[1]
	var dwarf: RotDwarf = a[2]
	await frames(2)
	Feel.last_hitstop = 0.0
	dwarf.die()
	check_near(Feel.last_hitstop, p.combat.kill_hitstop, 0.0001, "a kill holds %d ms" % roundi(p.combat.kill_hitstop * 1000.0))
	await frames(2)
	Feel.last_hitstop = 0.0
	p.take_damage(p.hp + 50)
	check(p.dead, "a blow past your health fells you")
	check_near(Feel.last_hitstop, p.combat.death_hitstop, 0.0001, "and your fall holds %d ms" % roundi(p.combat.death_hitstop * 1000.0))


func test_being_hit_matches_the_bible() -> void:
	var a := _dwarf_arena()
	var p: Player = a[1]
	var dwarf: RotDwarf = a[2]
	await _wait_for_swing(dwarf, 1)
	var hit_at := -1
	for i in 6:
		await frames(1)
		if p.hp < p.max_hp:
			hit_at = i
			break
	check(hit_at >= 0, "the swing lands")
	check(Feel.last_hitstop == p.combat.hurt_hitstop, "being hit holds 150 ms (%.2f)" % Feel.last_hitstop)
	check(p.velocity.x < 0.0 and absf(p.velocity.x) <= p.combat.hurt_knockback.x + 0.1, "knocked back at up to 160 px/s (%.0f)" % p.velocity.x)
	check(p._control_lock_timer > 0.0 and p._control_lock_timer <= p.combat.hurt_control_lock, "control locked for 0.18 s")
	check(p.invulnerable, "and invulnerable")
	dwarf.set_physics_process(false)
	await frames(44)
	check(p._invuln_timer > 0.0, "still safe at 0.75 s")
	await frames(6)
	check(p._invuln_timer <= 0.0, "and open again by 0.85 s (0.8 s of i-frames)")


## Pass 202: bible 5.3's "Starting combat values" table says tests assert it,
## but a third of its rows were only read back from the tuning by the play
## tests (or by none), so a changed number moved its test with it. This holds
## every row to the bible's text; the test after it plays the two rows no test did.
func test_the_starting_combat_values_match_bible_5_3() -> void:
	var c := CombatTuning.new()
	check(c.slash_damage == 8 and c.heavy_damage == 14, "light 8, heavy third hit 14")
	check_near(c.combo_window, 0.40, 0.0001, "0.40 s to chain")
	check(c.combo_cooldowns == [0.20, 0.20, 0.38], "cooldowns 0.20, 0.20, 0.38 after hits 1 to 3")
	check(c.ground_combo_length == 3 and c.air_combo_length == 2, "3-hit ground combo, 2-hit air combo")
	check_near(c.attack_buffer, 0.15, 0.0001, "attack buffer 0.15 s")
	check_near(c.throw_buffer, 0.15, 0.0001, "throw buffer 0.15 s")
	check_near(c.hit_hitstop, 0.05, 0.0001, "50 ms on a hit (6.7)")
	check_near(c.heavy_hitstop, 0.09, 0.0001, "90 ms on a heavy hit (6.7)")
	check_near(c.kill_hitstop, 0.08, 0.0001, "80 ms on a kill (6.7, pass 210)")
	check_near(c.hurt_hitstop, 0.15, 0.0001, "150 ms when you are hit (5.3)")
	check_near(c.death_hitstop, 0.35, 0.0001, "350 ms when you fall (6.7, pass 210)")
	check_near(c.parry_window, 0.12, 0.0001, "parry window 0.12 s")
	check_near(c.parry_hitstop, 0.14, 0.0001, "parry hit-stop 140 ms")
	check_near(c.parry_mp_gain, 6.0, 0.0001, "a parry gives 6 MP")
	check_near(c.guard_reduction, 0.5, 0.0001, "the Small Shield's guard halves damage")
	check_near(c.guard_mp_cost, 8.0, 0.0001, "8 MP per blocked hit")
	check_near(c.guard_move_multiplier, 0.4, 0.0001, "40% walk speed on guard")
	check(c.hurt_knockback == Vector2(160, 220), "knocked 160 px/s back, 220 px/s up")
	check_near(c.hurt_control_lock, 0.18, 0.0001, "0.18 s control lock")
	check(c.low_health == 20 and c.low_health == GameHud.MASK_HP, "low health is one mask, 20 HP")
	check_near(c.heartbeat_interval, 0.85, 0.0001, "a heartbeat every 0.85 s")
	check_near(c.max_mp, 60.0, 0.0001, "60 MP")
	check_near(c.mp_regen_per_second, 2.0, 0.0001, "+2 MP a second")
	check_near(c.mp_per_melee_hit, 4.0, 0.0001, "+4 MP per melee hit")
	check(c.flask_charges == 2 and c.flask_heal == 40, "Red Potion: 2 charges of 40")
	check_near(c.drink_time, 0.7, 0.0001, "0.7 s to drink")
	var deluge: Dictionary = Spells.DATA.deluge
	check(deluge.cost == 15.0 and deluge.damage == 12 and deluge.speed == 300.0, "Deluge: 15 MP, 12 damage, 300 px/s")
	check(c.war_glove_mult == 1.5 and c.war_glove_time == 15.0, "War Glove: x1.5 for 15 s")
	check_near(c.thrust_charge, 0.4, 0.0001, "Thrust: hold 0.4 s")
	check_near(c.thrust_mult, 1.5, 0.0001, "Thrust: heavy hit x1.5")
	check(c.thrust_speed == 320.0 and c.thrust_time == 0.16 and c.thrust_cooldown == 0.35, "Thrust: 320 px/s for 0.16 s, 0.35 s cooldown")
	check(c.pendant_mult == 1.1 and c.rod_deluge_mult == 1.5, "relics: the Pendant x1.1, the Magical Rod's Deluge x1.5")
	check(Coin.MAGNET_DELAY == 0.4 and Coin.MAGNET_RANGE == 100.0, "coins: magnet after 0.4 s within 100 px")
	check_near(c.death_gold_fraction, 0.6, 0.0001, "death drops 60% of the purse (5.4)")
	check(c.hazard_damage == 20 and c.hazard_damage == GameHud.MASK_HP, "spikes and thorns cost a mask, 20 (pass 282)")
	check_near(c.cast_cooldown, 0.35, 0.0001, "0.35 s between casts (pass 282)")
	check(Drop.BREAD_HEAL == 15 and Drop.LOAF_HEAL == 40, "bread +15, the Naga's great loaf +40 (pass 282)")
	check(Drop.BREAD_CHANCE == 0.08 and Drop.MANA_CHANCE == 0.1 and Drop.POISON_CHANCE == 0.07 and Drop.RARE_CHANCE == 0.025, "drops: bread 8%, mana 10%, poison 7%, rare 2.5% (pass 290)")
	check(Drop.MANA_GAIN == 12.0 and Drop.GLOVE_SHARE == 0.6, "a mana orb gives 12 MP; a rare drop is the War Glove 60% of the time (pass 290)")


## Bible 5.3 (pass 282): spikes cost a mask (20) through no armor and set
## you back on safe ground; a spell can't be cast again within 0.35 s, and the
## press made too soon is spent, not saved.
func test_spikes_cost_a_mask_and_casts_wait_their_cooldown() -> void:
	var rows: Array = ARENA.duplicate()
	rows[6] = "#.........^^^......#"
	var room := make_room(rows)
	var p := make_player(room, Vector2i(3, 6))
	p.max_hp = 100
	p.hp = 100
	await frames(4)
	var safe := p.global_position
	p.teleport(cell_feet(11, 6))
	await frames(2)
	check(p.hp == 100 - CombatTuning.new().hazard_damage, "a spike costs a whole mask (%d)" % (100 - p.hp))
	await frames(2)
	check(p.global_position.distance_to(safe) < 2.0, "and sets you back where you last stood safe (%s)" % p.global_position)
	await frames(60)
	# Casting: a second press inside 0.35 s casts nothing; after it, it casts.
	p.mp = 60.0
	var cost := p.spell_cost(p.equipped_spell)
	p.input.spell_pressed = true
	await frames(1)
	check_near(p.mp, 60.0 - cost, 0.2, "a cast spends its MP (%.1f)" % p.mp)
	var after_one := p.mp
	await frames(int(CombatTuning.new().cast_cooldown * 60.0) - 6)
	p.input.spell_pressed = true
	await frames(1)
	check(p.mp > after_one - cost * 0.5, "pressed again inside the cooldown, nothing is cast (%.1f)" % p.mp)
	await frames(10)
	check(p.mp > after_one - cost * 0.5, "and the early press is not saved for later (%.1f)" % p.mp)
	p.input.spell_pressed = true
	await frames(1)
	check(p.mp < after_one - cost * 0.5, "once the cooldown is over, it casts again (%.1f)" % p.mp)
	room.free()


## Pass 288 (bible 6): a spike sets you back on ground that lasts. Footing that
## can go (a cracked block you broke, a Bark Knight's rooted lance, a held
## crystal) is never kept as the safe spot, or a fall onto the spikes it hid
## would set you back into the air above them, again and again.
func test_a_spike_never_sets_you_back_onto_footing_that_is_gone() -> void:
	var rows: Array = ARENA.duplicate()
	rows[5] = "#..........C.......#"
	rows[6] = "#.........^^^......#"
	var room := make_room(rows)
	var p := make_player(room, Vector2i(3, 6))
	p.max_hp = 100
	p.hp = 100
	await frames(4)
	var block: CrackedBlock = null
	for c in room.get_children():
		if c is CrackedBlock:
			block = c
	check(block != null, "the arena has its cracked block")
	if block == null:
		room.free()
		return
	block.respawns = false
	var ground := p.global_position
	# Stand on the block a while, then it breaks under you.
	p.teleport(block.global_position + Vector2(0, -8))
	await frames(20)
	check(p.is_on_floor(), "standing on the cracked block")
	block.break_block(true)
	await frames(180)
	check(p.hp == 100 - CombatTuning.new().hazard_damage, "the spikes cost one mask, not a run of them (%d)" % (100 - p.hp))
	check(p.is_on_floor() and p.global_position.distance_to(ground) < 2.0, "and set you back on the floor you stood on before the block (%s, floor %s)" % [p.global_position, ground])
	room.free()


## Pass 296 (bible 6.13): a set-back is a fresh start. A jump or dash pressed
## as you fell onto the spikes was still buffered when the spikes set you
## back, so it fired on arrival: you hopped (or dashed) off the safe spot with
## no press of your own, often straight back toward the spikes.
func test_a_set_back_drops_the_presses_buffered_on_the_way_down() -> void:
	var rows: Array = ARENA.duplicate()
	rows[6] = "#.........^^^......#"
	var room := make_room(rows)
	var p := make_player(room, Vector2i(3, 6), {"stride": true})
	p.max_hp = 100
	p.hp = 100
	await frames(4)
	var ground := p.global_position
	for press: String in ["jump", "dash"]:
		p.facing = 1
		# Dropped from high over the spikes; the press comes just before they bite.
		p.teleport(Vector2(11.5 * Room.TILE, 2 * Room.TILE))
		await _until(func() -> bool: return p.global_position.y > 6 * Room.TILE + 2.0, 60)
		p.air_dash_charges = 0
		if press == "jump":
			p.input.jump_pressed = true
			p.input.jump_held = true
		else:
			p.input.dash_pressed = true
		await frames(1)
		p.input.jump_pressed = false
		p.input.dash_pressed = false
		await _until(func() -> bool: return p.hp < 100, 30)
		check(p.hp < 100 and p.global_position.distance_to(ground) < 2.0, "the spikes set you back (%s, %s)" % [press, p.global_position])
		var moved := 0.0
		var rose := 0.0
		for i in 30:
			await frames(1)
			moved = maxf(moved, absf(p.global_position.x - ground.x))
			rose = maxf(rose, ground.y - p.global_position.y)
		p.input.jump_held = false
		check(rose < 1.0 and moved < 1.0, "and the %s pressed on the way down does not fire there (rose %.1f, moved %.1f)" % [press, rose, moved])
		check(p.facing == 1, "you still face the way you were")
		p.hp = 100
		await frames(70)
	room.free()


## Pass 298 (bible 7, 5.3): a foe that falls out of its room is a kill, and
## pays like one, but no blow lands as it dies below the screen, a moment after
## the blow that sent it. A kill's freeze and shake there only hitched the game.
func test_a_foe_that_falls_out_pays_without_a_kills_freeze() -> void:
	var rows: Array = ARENA.duplicate()
	rows[2] = "#.........M........#"
	rows[7] = "#########....#######"
	var room := make_room(rows)
	var p := make_player(room, Vector2i(3, 6))
	await frames(4)
	var foe: Enemy = null
	for c in room.get_children():
		if c is Monodron:
			foe = c
	check(foe != null, "a Monodron hangs over the gap")
	if foe == null:
		room.free()
		return
	foe.gold_min = 5
	foe.gold_max = 5
	var gone: Array = []
	foe.died.connect(func(e: Enemy) -> void: gone.append(e))
	Feel.last_hitstop = 0.0
	Feel.trauma = 0.0
	await _until(func() -> bool: return not gone.is_empty(), 120)
	check(not gone.is_empty() and foe.fell, "it falls out of the room and dies")
	check(Feel.last_hitstop == 0.0 and Feel.trauma < 0.01, "with no kill's freeze or shake (hitstop %.2f, trauma %.2f)" % [Feel.last_hitstop, Feel.trauma])
	var coins := 0
	for c in room.get_children():
		if c is Coin:
			coins += 1
	check(coins > 0, "but it still pays its gold (%d coins)" % coins)
	room.free()


## Pass 286 (bible 13.3): a press that does nothing is heard when there is a
## reason to tell you. An empty flask clinks; a spell short of MP and a glass
## still running back fizzle; each once per press, spending nothing. A cast
## pressed inside its cooldown stays silent: the cast just sounded.
func test_a_refused_drink_cast_or_glass_is_heard_once() -> void:
	var room := make_room(ARENA)
	var p := make_player(room, Vector2i(3, 6), {"hourglass": true})
	p.max_hp = 100
	p.hp = 50
	await frames(4)
	# The empty flask.
	p.flask_charges = 0
	Sfx.recent.clear()
	p.input.heal_pressed = true
	await frames(1)
	p.input.heal_pressed = false
	await frames(30)
	check(Sfx.recent == ["flask_empty"], "an empty flask clinks, once (%s)" % [Sfx.recent])
	check(p.hp == 50 and not p.is_drinking, "and nothing is drunk (%d)" % p.hp)
	check(ResourceLoader.exists("res://assets/sfx/flask_empty.wav"), "flask_empty is rendered")
	# A full flask at full health: nothing to drink for, nothing heard.
	p.flask_charges = 2
	p.hp = 100
	Sfx.recent.clear()
	p.input.heal_pressed = true
	await frames(1)
	await frames(30)
	check(Sfx.recent.is_empty() and p.flask_charges == 2, "at full health a press is quiet and spends nothing (%s)" % [Sfx.recent])
	# A spell short of MP.
	p.mp = p.spell_cost(p.equipped_spell) - 1.0
	var mp := p.mp
	Sfx.recent.clear()
	p.input.spell_pressed = true
	await frames(1)
	check(Sfx.recent.count("fizzle") == 1 and not Sfx.recent.has("cast"), "a spell short of MP fizzles, once (%s)" % [Sfx.recent])
	check(p.mp <= mp + 0.1, "and spends nothing (%.1f)" % p.mp)
	# A cast, then a press inside the cooldown: silent.
	p.mp = 60.0
	p.input.spell_pressed = true
	await frames(1)
	Sfx.recent.clear()
	await frames(6)
	p.input.spell_pressed = true
	await frames(1)
	check(not Sfx.recent.has("fizzle") and not Sfx.recent.has("cast"), "a press inside the cooldown is silent (%s)" % [Sfx.recent])
	# The glass, turned while it runs back.
	p.input.hourglass_pressed = true
	await frames(2)
	check(TimeStop.active(), "the glass turns")
	Sfx.recent.clear()
	p.input.hourglass_pressed = true
	await frames(1)
	check(Sfx.recent.count("fizzle") == 1 and not Sfx.recent.has("hourglass"), "turned again while it runs back, it fizzles, once (%s)" % [Sfx.recent])
	TimeStop.reset()
	room.free()


## Pass 290 (bible 5.3, Drops): a kill's roll gives each drop at its share.
## 40,000 seeded rolls, with and without poison, each within a point of the
## table; a foe without `poison_drops` never leaves poison.
func test_a_kills_drop_comes_at_the_tables_odds() -> void:
	var parent := Node2D.new()
	arena.add_child(parent)
	# The runner turns drops off for every test; turn on the game's own odds.
	Drop.bread_chance = Drop.BREAD_CHANCE
	Drop.mana_chance = Drop.MANA_CHANCE
	Drop.poison_chance = Drop.POISON_CHANCE
	Drop.rare_chance = Drop.RARE_CHANCE
	seed(290)
	for can_poison: bool in [false, true]:
		var counts := {"": 0, "bread": 0, "mana": 0, "poison": 0, "glove": 0, "ointment": 0}
		var n := 20000
		for i in n:
			var d := Drop.roll(parent, Vector2.ZERO, can_poison)
			counts[d.kind if d != null else ""] += 1
			if d != null:
				d.free()
		var share := func(k: String) -> float: return float(counts[k]) / n
		var rare: float = share.call("glove") + share.call("ointment")
		check(absf(share.call("bread") - Drop.BREAD_CHANCE) < 0.01, "bread at %.1f%% (%.1f%%)" % [Drop.BREAD_CHANCE * 100, share.call("bread") * 100])
		check(absf(share.call("mana") - Drop.MANA_CHANCE) < 0.01, "a mana orb at %.1f%% (%.1f%%)" % [Drop.MANA_CHANCE * 100, share.call("mana") * 100])
		check(absf(share.call("poison") - (Drop.POISON_CHANCE if can_poison else 0.0)) < 0.01, "poison at %.1f%% %s (%.1f%%)" % [Drop.POISON_CHANCE * 100 if can_poison else 0.0, "from a Tower foe" if can_poison else "from any other", share.call("poison") * 100])
		check(absf(rare - Drop.RARE_CHANCE) < 0.01, "a rare item at %.1f%% (%.1f%%)" % [Drop.RARE_CHANCE * 100, rare * 100])
		check(absf(float(counts["glove"]) / maxf(1.0, counts["glove"] + counts["ointment"]) - Drop.GLOVE_SHARE) < 0.08, "of them the War Glove %.0f%% (%d of %d)" % [Drop.GLOVE_SHARE * 100, counts["glove"], counts["glove"] + counts["ointment"]])
	randomize()
	Drop.bread_chance = 0.0
	Drop.mana_chance = 0.0
	Drop.poison_chance = 0.0
	Drop.rare_chance = 0.0
	parent.free()


## Bible 5.3: guarding you walk at 40% of a run; MP comes back at 2 a second.
func test_a_guard_walks_slow_and_mp_comes_back_slowly() -> void:
	var room := make_room(ARENA)
	var p := make_player(room, Vector2i(3, 6))
	await frames(4)
	p.input.block_held = true
	p.input.move_x = 1
	await frames(20)
	check(p.is_blocking, "holding Block guards")
	check_near(p.velocity.x, p.tuning.run_speed * 0.4, 0.5, "guarding, you walk at 40%% of a run (%.1f)" % p.velocity.x)
	p.input.block_held = false
	p.input.move_x = 0
	p.mp = 0.0
	await frames(60)
	check_near(p.mp, 2.0, 0.1, "a second later 2 MP has come back (%.2f)" % p.mp)
	room.free()


func test_the_heavy_finisher_drives_a_foe_back_and_holds_it_longer() -> void:
	var room := _arena_with("D", Vector2i(10, 6))
	var dwarf: RotDwarf = _find(room, RotDwarf)
	await frames(4)
	# From behind (it faces left; its shield guards the front).
	dwarf.take_hit(1, Vector2(-1, 0))
	check_near(dwarf._hitstun, Enemy.HITSTUN, 0.001, "a light hit stops it 0.18 s")
	var light := dwarf.velocity.x
	await frames(30)
	dwarf.take_hit(1, Vector2(-1.8, 0))
	check_near(dwarf._hitstun, Enemy.HITSTUN * 1.8, 0.001, "the heavy finisher holds it 0.32 s")
	check_near(dwarf.velocity.x, light * 1.8, 0.5, "and drives it back 1.8x as hard")


func test_a_midair_up_slash_that_lands_holds_you_up() -> void:
	var rows := ARENA.duplicate()
	for i in 8:
		rows.insert(1, "#..................#")
	var room := make_room(rows)
	var p := make_player(room, Vector2i(9, 8))
	var foe := Hornet.new()
	room.add_child(foe)
	foe.set_physics_process(false)
	for i in 3:
		foe.global_position = p.global_position + Vector2(0, -p.BODY_SIZE.y - 10)
		await frames(1)
	check(not p.is_on_floor(), "falling past a hornet")
	p.velocity.y = 120.0
	p.input.up = true
	p.input.attack_pressed = true
	await frames(1)
	p.input.attack_pressed = false
	check(foe.hits_taken == 1, "the up-slash hits the hornet above")
	check(p.velocity.y < -p.combat.up_slash_pop + 40.0, "and turns the fall into a little rise (%.0f)" % p.velocity.y)
	p.velocity.y = 120.0
	await frames(2)
	check(p.velocity.y > 0.0, "once per swing (%.0f)" % p.velocity.y)
	p.input.up = false


## The Rune Dagger (pass 184, bible 5.2): thrown, it strikes the first foe in
## its path, breaks into rune light, and reforms at your hip RETURN later; only
## one flies at a time, it costs no magic, and Up throws it straight up.
func test_the_rune_dagger_flies_strikes_and_reforms_at_your_hip() -> void:
	var room := _arena_with("E", Vector2i(10, 6))
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	var dummy: TrainingDummy = _find(room, TrainingDummy)
	p.input.throw_pressed = true
	await frames(1)
	check(p.rune_dagger == null, "no throw without the Rune Dagger")
	p.rune_dagger = null
	for d in runner.get_tree().get_nodes_in_group("projectile"):
		d.free()
	p.abilities["rune_dagger"] = true
	await frames(1)
	var mp0 := p.mp
	p.input.throw_pressed = true
	await frames(1)
	var dagger := p.rune_dagger
	check(dagger != null and dagger.dir == Vector2.RIGHT, "the Throw button hurls it the way you face")
	check(not p.dagger_ready(), "one dagger at a time")
	p.input.throw_pressed = true
	await frames(1)
	check(runner.get_tree().get_nodes_in_group("projectile").size() == 1, "a second press while it flies does nothing")
	await frames(20)
	check(dummy.hits_taken == 1, "it strikes the dummy (%d hits)" % dummy.hits_taken)
	check(dummy.hp == TrainingDummy.HP - RuneDagger.DAMAGE, "for %d damage (dummy hp %d)" % [RuneDagger.DAMAGE, dummy.hp])
	check(not is_instance_valid(dagger), "it breaks on the blow")
	check(is_equal_approx(p.mp, mp0), "it costs no magic")
	check(not p.dagger_ready(), "it is not back at once")
	await frames(int(RuneDagger.RETURN * 60.0) + 2)
	check(p.dagger_ready(), "it reforms at your hip after %.1f s" % RuneDagger.RETURN)
	p.input.up = true
	p.input.throw_pressed = true
	await frames(1)
	check(p.rune_dagger != null and p.rune_dagger.dir == Vector2.UP, "Up throws it straight up")
	p.input.up = false


## Pass 190: gear is heard. A dagger that lands bites, the two-handed Broad
## Sword swings with a heavier voice, and the Equipment page sheathes a blade,
## buckles on gear and swishes a dye.
func test_the_dagger_the_broad_sword_and_the_equipment_page_have_voices() -> void:
	var room := _arena_with("E", Vector2i(10, 6))
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	p.abilities["rune_dagger"] = true
	Sfx.recent.clear()
	p.input.throw_pressed = true
	await frames(20)
	check(Sfx.recent.has("dagger_throw") and Sfx.recent.has("dagger_hit"), "a dagger that lands bites (%s)" % [Sfx.recent])
	await frames(int(RuneDagger.RETURN * 60.0) + 4)
	Sfx.recent.clear()
	p.input.attack_pressed = true
	await frames(2)
	check(Sfx.recent.has("slash") and not Sfx.recent.has("broad_slash"), "the Short Sword cuts with the plain slash (%s)" % [Sfx.recent])
	GameState.obtain_gear("dwarvish_broad_sword", p)
	await frames(40)
	Sfx.recent.clear()
	p.input.attack_pressed = true
	await frames(2)
	check(Sfx.recent.has("broad_slash") and not Sfx.recent.has("slash"), "the Broad Sword's cut is its own (%s)" % [Sfx.recent])
	p.is_heavy_swing = true
	check(p.swing_sound() == "broad_heavy", "and so is its heavy cut")
	for sound: String in ["dagger_hit", "broad_slash", "broad_heavy", "sheathe", "gear_on"]:
		check(FileAccess.file_exists("res://assets/sfx/%s.wav" % sound), "%s.wav exists" % sound)
	check(Menus.equipment_sound("long_sword") == "sheathe", "a blade taken in hand slides from its sheath")
	for id: String in ["leather_armor", "small_shield", "battle_helmet"]:
		check(Menus.equipment_sound(id) == "gear_on", "%s buckles on" % id)
	check(Menus.equipment_sound("tide_dye") == "cloth", "and a dye is cloth")
	Sfx.recent.clear()
	Menus.choose_equipment("short_sword", p)
	check(Sfx.recent == ["sheathe"] and GameState.data.equipment.blade == "short_sword", "choosing a blade plays it (%s)" % [Sfx.recent])


## Pass 192: Throw is buffered like Attack. A press in the last moments of a
## swing, a dash or the dagger's return goes the first frame it can; one
## pressed long before is dropped.
func test_a_throw_pressed_a_moment_early_still_goes() -> void:
	var room := _arena_with("E", Vector2i(30, 6))
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	p.abilities["rune_dagger"] = true
	check(is_equal_approx(p.combat.throw_buffer, 0.15) and is_equal_approx(p.combat.throw_buffer, p.combat.attack_buffer), "Throw is buffered 0.15 s, as Attack is")
	p.input.attack_pressed = true
	await frames(1)
	check(p.is_attacking, "mid-swing")
	p.input.throw_pressed = true
	await frames(1)
	check(p.rune_dagger == null, "no throw while the swing is out")
	var waited := 0
	while p.is_attacking and waited < 30:
		await frames(1)
		waited += 1
	await frames(1)
	check(waited <= 9 and p.rune_dagger != null, "the press goes as the swing ends (%d frames later)" % waited)
	# Pressed while it reforms, a moment before it is whole.
	while is_instance_valid(p.rune_dagger):
		await frames(1)
	await frames(int((RuneDagger.RETURN - 0.1) * 60.0))
	p.input.throw_pressed = true
	await frames(1)
	check(not is_instance_valid(p.rune_dagger), "not while it reforms")
	await frames(8)
	check(is_instance_valid(p.rune_dagger), "but the press goes the frame it is whole")
	# Pressed too early, it is dropped.
	while is_instance_valid(p.rune_dagger):
		await frames(1)
	p.input.throw_pressed = true
	await frames(1)
	await frames(int(RuneDagger.RETURN * 60.0) + 4)
	check(not is_instance_valid(p.rune_dagger), "a press long before it is whole is dropped")


func test_the_rune_dagger_breaks_on_walls_and_at_the_end_of_its_reach() -> void:
	var room := make_room(ARENA)
	var p := make_player(room, Vector2i(3, 6), {"rune_dagger": true})
	await frames(6)
	var x0 := p.global_position.x
	p.input.throw_pressed = true
	await frames(1)
	var dagger := p.rune_dagger
	var far := 0.0
	while is_instance_valid(dagger):
		far = dagger.global_position.x - x0
		await frames(1)
	check(far <= RuneDagger.RANGE + 20.0 and far >= RuneDagger.RANGE - 20.0, "it flies about %d px and no farther (%.0f)" % [RuneDagger.RANGE, far])
	await frames(int(RuneDagger.RETURN * 60.0) + 2)
	p.facing = -1
	p.input.throw_pressed = true
	await frames(1)
	dagger = p.rune_dagger
	await frames(12)
	check(not is_instance_valid(dagger), "it breaks on the wall behind you")
	check(not p.dagger_ready(), "and comes home from there too")
	await frames(int(RuneDagger.RETURN * 60.0) + 2)
	check(p.dagger_ready(), "ready again")


## The damage balance sheet (design bible 5.5, pass 194): the kit the critical
## path has put in your hands by each zone, as [blade, tempers, armor, shield].
## The shield joined in pass 226: since pass 225 it wards a foe's sorcery.
const PAR_KIT := {
	"trunk": ["long_sword", 0, "leather_armor", "small_shield"],
	"tower": ["long_sword", 0, "leather_armor", "small_shield"],
	"mist": ["long_sword", 1, "studded_mail", "large_shield"],
	"branches": ["long_sword", 1, "studded_mail", "large_shield"],
	"daybreak": ["long_sword", 2, "studded_mail", "large_shield"],
	"dartmoor": ["long_sword", 2, "full_plate", "magic_shield"],
	"sunken": ["dragon_slayer", 0, "full_plate", "magic_shield"],
	"zenis": ["dragon_slayer", 0, "full_plate", "magic_shield"],
}
## Pass 218: King Grieve gives up the Dragon Slayer (pass 217), so everything
## past his throne is fought with it: the Meteor Rise, the Zenis Gate and its
## mirror, and the Sunken Spring below the Rise.
const PAST_GRIEVE_KIT := ["dragon_slayer", 0, "full_plate", "magic_shield"]
const PAST_GRIEVE_ROOMS := ["dartmoor/meteor_rise", "dartmoor/zenis_gate"]
const PAST_GRIEVE_BOSSES := ["ShadowEura"]
## Each room legend's foe, and the shot it fires (null for none).
var sheet_foes := {
	"M": [Monodron, null], "H": [Hornet, null], "D": [RotDwarf, null],
	"T": [SapSpitter, SapGlob], "U": [GrubLump, null], "I": [IronDwarf, Shockwave],
	"B": [GearBat, GearBlade], "K": [MinecartRider, null], "A": [LanternGhost, null],
	"V": [BogMyconid, SporeCloud], "p": [DrownedDwarf, null], "m": [LeafMantis, null],
	"!": [BarkKnight, null], ";": [SeedBomber, BomberSeed], "?": [MarshHag, MireGrasp],
	"t": [ThunderBeetle, null], "y": [StormHarpy, HarpyFeather], "]": [SpireSentinel, null],
	"q": [CrystalDwarf, CrystalSpike], "e": [ShadeKnight, null], "j": [ClockworkHound, null],
	"s": [MeteorSlug, MeteorGlob], "l": [SpringEel, null], ")": [Naga, null],
}


## A script's blows on the player: its *DAMAGE and *CONTACT constants, leaving
## out the damage a returned shot does to its thrower.
func _blows(script: Script) -> Array[int]:
	var out: Array[int] = []
	var consts := script.get_script_constant_map()
	for k: String in consts:
		if ("DAMAGE" in k or "CONTACT" in k) and not "REFLECT" in k and not "RETURN" in k and consts[k] is int:
			out.append(int(consts[k]))
	return out


## A blow of `b` as it lands through a zone's par kit, the way
## Player.receive_attack takes it: the zone's threat, the shield's ward if the
## blow is sorcery (pass 225), then the armor.
func _through_par(b: int, zone: String, script: Script) -> int:
	var kit: Array = PAR_KIT[zone]
	var d := roundi(b * float(CombatTuning.ZONE_THREAT[zone]))
	if _is_sorcery(script):
		d = maxi(roundi(d * (1.0 - float(GameData.item(kit[3]).get("ward", 0.0)))), 1)
	return maxi(1, roundi(d * (1.0 - float(GameData.item(kit[2]).defense))))


## A script whose nodes join Player.MAGIC: a hex, a bolt, a shard, a beam.
func _is_sorcery(script: Script) -> bool:
	return script != null and script.source_code.contains("add_to_group(Player.MAGIC)")


## Every foe placed in a zone, by legend character.
func _zone_foes(zone: String) -> Dictionary:
	var found := {}
	var dir := DirAccess.open("res://levels/" + zone)
	for f in dir.get_files():
		if not f.ends_with(".room"):
			continue
		var grid: Array = Room.parse(FileAccess.get_file_as_string("res://levels/%s/%s" % [zone, f])).grid
		for row: String in grid:
			for ch in row:
				if sheet_foes.has(ch):
					found[ch] = true
	return found


func test_the_damage_balance_sheet_stays_within_its_targets() -> void:
	var order := ["trunk", "tower", "mist", "branches", "daybreak", "dartmoor", "zenis"]
	var last := 0.0
	for zone: String in order:
		var t := float(CombatTuning.ZONE_THREAT[zone])
		check(t >= last, "%s is no softer than the zone before it (%.1f)" % [zone, t])
		last = t
	check(CombatTuning.ZONE_THREAT.trunk == 1.0 and CombatTuning.ZONE_THREAT.tower == 1.0, "the first two zones hit as written")
	var checked := 0
	for zone: String in PAR_KIT:
		var kit: Array = PAR_KIT[zone]
		var cut := roundi(int(GameData.item(kit[0]).slash) * (1.0 + GameState.TEMPER_BONUS * int(kit[1])))
		var armor := float(GameData.item(kit[2]).defense)
		var threat := float(CombatTuning.ZONE_THREAT[zone])
		var foes := _zone_foes(zone)
		check(not foes.is_empty(), "%s has foes" % zone)
		var zone_hardest := 0
		for ch: String in foes:
			var pair: Array = sheet_foes[ch]
			var foe: Enemy = pair[0].new()
			var hp := foe.max_hp
			if zone == "zenis":
				hp = ceili(hp * Enemy.CORRUPT_HP)
			var blows := _blows(foe.get_script())
			if foe.contact_damage > 0:
				blows.append(foe.contact_damage)
			var name := (foe.get_script() as Script).get_global_name()
			var hardest := 0
			for b in blows:
				hardest = maxi(hardest, _through_par(b, zone, foe.get_script()))
			foe.free()
			if pair[1] != null:
				for b in _blows(pair[1]):
					hardest = maxi(hardest, _through_par(b, zone, pair[1]))
			var slashes := ceili(float(hp) / cut)
			check(slashes >= 2 and slashes <= 7, "%s in %s falls in 2 to 7 slashes of the par blade (%d)" % [name, zone, slashes])
			check(hardest <= 28, "%s in %s hits for at most 1.4 masks through par armor (%d)" % [name, zone, hardest])
			zone_hardest = maxi(zone_hardest, hardest)
			checked += 1
		check(zone_hardest >= 15 and zone_hardest <= 28, "%s's hardest blow costs 0.75 to 1.4 masks through par armor (%d)" % [zone, zone_hardest])
	check(checked >= 40, "the sheet covers every zone's foes (%d rows)" % checked)
	# Past King Grieve the Dragon Slayer is in hand: the Rise's foes still take
	# two slashes or more (pass 218).
	var slayer := int(GameData.item(PAST_GRIEVE_KIT[0]).slash)
	for id: String in PAST_GRIEVE_ROOMS:
		for row: String in Room.parse(FileAccess.get_file_as_string("res://levels/%s.room" % id)).grid:
			for ch in row:
				if sheet_foes.has(ch):
					var foe: Enemy = sheet_foes[ch][0].new()
					var slashes := ceili(float(foe.max_hp) / slayer)
					check(slashes >= 2 and slashes <= 7, "%s past King Grieve falls in 2 to 7 Dragon Slayer slashes (%d)" % [(foe.get_script() as Script).get_global_name(), slashes])
					foe.free()


## Pass 258: a foe a guardian calls into its fight is a foe like any other,
## so it answers to the same sheet. The Matriarch's daughter (a Marsh Hag) and
## the Alpha's pack (Clockwork Hounds) stand in rooms too, so the sheet already
## held them; Pakukame's Liliths (pass 257) stand nowhere else, and fell to a
## single slash of the Branches' par blade. Every Enemy a guardian's script
## makes must be a room foe on the sheet or listed here with its zone.
const SUMMONED := {"Lilith": "branches"}

func test_a_guardians_brood_answers_to_the_sheet() -> void:
	var classes := {}
	for c: Dictionary in ProjectSettings.get_global_class_list():
		classes[String(c["class"])] = String(c["path"])
	var bosses := {}
	for row: Array in sheet_bosses:
		bosses[(row[0] as Script).get_global_name()] = true
		# A guardian's shots are on its own row of the sheet.
		for shot: Script in row[2]:
			bosses[shot.get_global_name()] = true
	var placed := {}
	for ch: String in sheet_foes:
		placed[(sheet_foes[ch][0] as Script).get_global_name()] = true
	var made := RegEx.create_from_string("\\b([A-Z][A-Za-z]+)\\.new\\(\\)")
	var found := {}
	for f in DirAccess.get_files_at("res://scripts/bosses/"):
		if not f.ends_with(".gd") or f == "boss_arena.gd":
			continue
		for m in made.search_all(FileAccess.get_file_as_string("res://scripts/bosses/" + f)):
			var name := m.get_string(1)
			if not classes.has(name) or bosses.has(name):
				continue
			var script := load(classes[name]) as Script
			var base := script
			while base != null and base.resource_path != "res://scripts/enemies/enemy.gd":
				base = base.get_base_script()
			if base != null:
				found[name] = f
	check(found.has("Lilith") and found.has("MarshHag") and found.has("ClockworkHound"), "found the guardians' broods (%s)" % [found])
	for name: String in found:
		check(placed.has(name) or SUMMONED.has(name), "%s (called by %s) is on the sheet" % [name, found[name]])
	for name: String in SUMMONED:
		var zone: String = SUMMONED[name]
		var kit: Array = PAR_KIT[zone]
		var cut := roundi(int(GameData.item(kit[0]).slash) * (1.0 + GameState.TEMPER_BONUS * int(kit[1])))
		var script := load(classes[name]) as Script
		var foe: Enemy = script.new()
		var slashes := ceili(float(foe.max_hp) / cut)
		var blows := _blows(script)
		if foe.contact_damage > 0:
			blows.append(foe.contact_damage)
		foe.free()
		var hardest := 0
		for b in blows:
			hardest = maxi(hardest, _through_par(b, zone, script))
		check(slashes >= 2 and slashes <= 7, "%s in %s falls in 2 to 7 slashes of the par blade (%d)" % [name, zone, slashes])
		check(hardest >= 1 and hardest <= 28, "%s in %s hits for at most 1.4 masks through par armor (%d)" % [name, zone, hardest])


## Pass 218: the sheet's kit past King Grieve is the one the game gives there.
func test_the_sheet_past_king_grieve_holds_the_dragon_slayer() -> void:
	check(String(BossArena.BOSSES.king_grieve.get("blade", "")) == PAST_GRIEVE_KIT[0], "King Grieve gives the blade the sheet expects past him")
	check(PAR_KIT.sunken == PAST_GRIEVE_KIT and PAR_KIT.zenis == PAST_GRIEVE_KIT, "the Sunken Spring and Zenis are fought with it")
	var rise: Dictionary = Room.parse(FileAccess.get_file_as_string("res://levels/dartmoor/throne_hall.room"))
	var past := []
	for spec: String in rise.lists.get("door", []):
		past.append(spec.get_slice(",", 1).strip_edges())
	check(past.has("dartmoor/meteor_rise"), "the Meteor Rise lies behind his throne (%s)" % [past])
	var rooms := {}
	for id: String in PAST_GRIEVE_ROOMS:
		rooms[id] = Room.parse(FileAccess.get_file_as_string("res://levels/%s.room" % id))
	check(String(rooms["dartmoor/zenis_gate"].header.get("boss", "")) == "shadow_eura", "and Shadow Eura waits past it, at the Zenis Gate")
	var down := []
	for spec: String in rooms["dartmoor/meteor_rise"].lists.get("door", []):
		down.append(spec.get_slice(",", 1).strip_edges())
	check(down.has("sunken/spring_gate") and down.has("dartmoor/zenis_gate"), "the Rise leads on to the Zenis Gate and down to the Sunken Spring (%s)" % [down])


func test_a_foe_hits_as_hard_as_its_zone_is_deep() -> void:
	var rows := ARENA.duplicate()
	var room := Room.from_text("zone: dartmoor\n---\n" + "\n".join(PackedStringArray(rows)))
	arena.add_child(room)
	var p := make_player(room, Vector2i(3, 6))
	var foe := Monodron.new()
	foe.position = cell_feet(8, 6)
	room.add_child(foe)
	await frames(2)
	p.defense = 0.0
	var before := p.hp
	p.receive_attack(10, foe, false)
	check(before - p.hp == 20, "a Dartmoor foe's 10 lands for 20 (took %d)" % (before - p.hp))
	# A fire seal is the world, not a foe: it burns as written.
	p.hp = p.max_hp
	p._invuln_timer = 0.0
	var seal := FireSeal.new()
	room.add_child(seal)
	p.receive_attack(10, seal, false)
	check(p.max_hp - p.hp == 10, "a fire seal burns for 10 anywhere (took %d)" % (p.max_hp - p.hp))
	# A boss's arena is as deep as its zone (pass 196).
	room.header["boss"] = "test"
	check(room.threat() == 2.0, "a Dartmoor arena's threat is its zone's")
	room.header.erase("boss")
	room.zone = "trunk"
	check(room.threat() == 1.0, "the Trunk hits as written")
	room.zone = "eolis"
	check(room.threat() == 1.0, "a zone off the sheet hits as written")


## The guardians' sheet (design bible 5.5, pass 196): each boss, its zone, and
## the shots it fires.
var sheet_bosses := [
	[Rokusutahn, "trunk", [SapClump]], [Zoradohna, "tower", [Rubble]],
	[Foreman, "tower", [Rubble]], [Ripasheiku, "mist", []],
	[HagMatriarch, "mist", [MireGrasp]], [Zorugeriru, "mist", [MistBreath]],
	[Pakukame, "branches", [SeedShot]], [BarkCaptain, "branches", []],
	[Borabohra, "daybreak", [StormStrike, HarpyFeather]],
	[KingGrieve, "dartmoor", [CrystalShard, Shockwave, CrystalSpike]],
	[ClockworkAlpha, "dartmoor", []], [ShadowEura, "dartmoor", [ShadowBolt]],
	[DrownedWarden, "sunken", [TidalWave]], [EvilAvatar, "zenis", [CrystalSpike]],
	[EvilCore, "zenis", [CoreBeam]], [EvilHeart, "zenis", [CoreBeam, CrystalSpike, MeteorSeed]],
]


func test_the_guardians_hit_as_hard_as_their_zone() -> void:
	var by_zone := {}
	for row: Array in sheet_bosses:
		var script: Script = row[0]
		var zone: String = row[1]
		var kit: Array = PAR_KIT[zone]
		var armor := float(GameData.item(kit[2]).defense)
		var threat := float(CombatTuning.ZONE_THREAT[zone])
		var hardest := 0
		for b in _blows(script):
			hardest = maxi(hardest, _through_par(b, zone, script))
		for shot: Script in row[2]:
			for b in _blows(shot):
				hardest = maxi(hardest, _through_par(b, zone, shot))
		var name := script.get_global_name()
		check(hardest >= 10 and hardest <= 30, "%s's hardest blow costs 0.5 to 1.5 masks through %s's par armor (%d)" % [name, zone, hardest])
		by_zone[zone] = maxi(int(by_zone.get(zone, 0)), hardest)
	# Each zone's guardians hit at least as hard as its foes' sheet floor (15),
	# so no boss is softer than the corridor that leads to it.
	for zone: String in by_zone:
		check(by_zone[zone] >= 15, "%s's guardians strike for at least 0.75 masks (%d)" % [zone, by_zone[zone]])


## Pass 204: the rubric's "balanced HP" (15.3) had no sheet. Each guardian's
## health in slashes of its zone's par blade (5.5): every one 15 to 40, a
## mini-boss never outlasting its zone's guardians, and the Evil One (avatar
## and heart) the longest fight of the critical path. Rokusutahn's 600 is
## spread over a plated body and a soft tail, and the Evil One's veins are a
## climb, not a health bar, so they stay off the sheet.
const MINI_BOSSES := ["Foreman", "HagMatriarch", "BarkCaptain", "ClockworkAlpha"]
const OPTIONAL_BOSSES := ["DrownedWarden"]

func test_the_guardians_last_as_long_as_their_place() -> void:
	var slashes := {}
	var zone_of := {}
	for row: Array in sheet_bosses:
		var script: Script = row[0]
		var name := script.get_global_name()
		if name in ["Rokusutahn", "EvilCore"]:
			continue
		var kit: Array = PAST_GRIEVE_KIT if name in PAST_GRIEVE_BOSSES else PAR_KIT[row[1]]
		var cut := roundi(int(GameData.item(kit[0]).slash) * (1.0 + GameState.TEMPER_BONUS * int(kit[1])))
		var boss: Enemy = script.new()
		slashes[name] = ceili(float(boss.max_hp) / cut)
		zone_of[name] = row[1]
		boss.free()
		check(slashes[name] >= 15 and slashes[name] <= 40, "%s falls in 15 to 40 par slashes (%d)" % [name, slashes[name]])
	for mini: String in MINI_BOSSES:
		var longest := 0
		for name: String in slashes:
			if zone_of[name] == zone_of[mini] and not name in MINI_BOSSES:
				longest = maxi(longest, slashes[name])
		check(slashes[mini] <= 25 and slashes[mini] <= longest, "%s (a mini-boss, %d) is no longer than %s's guardians (%d)" % [mini, slashes[mini], zone_of[mini], longest])
	var finale: int = slashes["EvilAvatar"] + slashes["EvilHeart"]
	for name: String in slashes:
		if not name in ["EvilAvatar", "EvilHeart"] and not name in OPTIONAL_BOSSES:
			check(finale >= slashes[name], "the Evil One (%d) lasts longer than %s (%d)" % [finale, name, slashes[name]])
	# Pass 212: no guardian outlasts every later zone's longest by more than two
	# slashes, so the fights grow (or hold) as the game goes on.
	var zones := PAR_KIT.keys()
	for name: String in slashes:
		if name in MINI_BOSSES or name in OPTIONAL_BOSSES or zone_of[name] == "zenis":
			continue
		var later := 0
		for other: String in slashes:
			var z: String = zone_of[other]
			if zones.find(z) > zones.find(zone_of[name]) and z != "zenis" and not other in MINI_BOSSES and not other in OPTIONAL_BOSSES:
				later = maxi(later, slashes[other])
		if later > 0:
			check(slashes[name] <= later + 2, "%s (%d) is no longer than a later zone's longest guardian (%d) by more than two" % [name, slashes[name], later])


## Design bible 5.3 (pass 198): a blow that costs a whole mask lands with a body
## thud under the yelp; a lighter one does not.
func test_a_blow_that_costs_a_mask_sounds_heavier() -> void:
	var room := make_room(ARENA)
	var p := make_player(room, Vector2i(3, 6))
	var foe := Monodron.new()
	foe.position = cell_feet(12, 6)
	room.add_child(foe)
	await frames(3)
	p.defense = 0.0
	Sfx.recent.clear()
	p.receive_attack(GameHud.MASK_HP - 1, foe, false)
	check(Sfx.recent.has("hurt") and not Sfx.recent.has("hurt_heavy"), "a blow under a mask only yelps (%s)" % [Sfx.recent])
	p._invuln_timer = 0.0
	Sfx.recent.clear()
	p.receive_attack(GameHud.MASK_HP, foe, false)
	check(Sfx.recent.has("hurt") and Sfx.recent.has("hurt_heavy"), "a blow of a whole mask thuds too (%s)" % [Sfx.recent])
	check(FileAccess.file_exists("res://assets/sfx/hurt_heavy.wav"), "hurt_heavy.wav exists")


## Pass 266 (bible 5.5): a guardian's brood goes down with its guardian, and
## no blow felled it. The Bloom, the Matriarch and the Clockwork Alpha had
## struck their brood down as if the player had: each Lilith, daughter or hound
## sprayed gold, rolled a drop, gave experience, counted as a kill for
## Wanderer's Grace, and piled a kill's hitstop and shake onto the guardian's
## own death. `Enemy.perish` dissolves a foe with none of that; a real kill
## still pays it all, and no guardian kills its brood any other way.
func test_a_brood_that_dies_with_its_guardian_pays_nothing() -> void:
	var room := Room.from_text("zone: trunk\n---\n" + "\n".join(PackedStringArray(ARENA)))
	arena.add_child(room)
	var p := make_player(room, Vector2i(3, 6))
	p.abilities["stride"] = true
	p.wanderers_grace = true
	var bread := Drop.bread_chance
	Drop.bread_chance = 1.0
	var paid := func(foe: Enemy, by_blow: bool) -> Array:
		foe.position = cell_feet(10, 6)
		room.add_child(foe)
		await frames(2)
		var xp: int = GameState.data.xp
		p.air_dash_charges = 0
		if by_blow:
			foe.take_hit(foe.hp, Vector2.RIGHT)
		else:
			foe.perish()
		var regained := p.air_dash_charges > 0
		await frames(2)
		var coins := room.get_children().filter(func(n: Node) -> bool: return n is Coin or n is Drop).size()
		for n in room.get_children():
			if n is Coin or n is Drop:
				n.free()
		return [GameState.data.xp - xp, coins, regained, foe.dead]
	var died: Array = await paid.call(Monodron.new(), false)
	check(died[3] and died[0] == 0 and died[1] == 0 and not died[2], "a foe that perishes pays no experience, gold or drop, and is no kill (%s)" % [died])
	var killed: Array = await paid.call(Monodron.new(), true)
	check(killed[3] and killed[0] > 0 and killed[1] > 0 and killed[2], "one struck down pays them all, and counts (%s)" % [killed])
	Drop.bread_chance = bread
	# No guardian kills its brood with a blow or a bare death any more.
	var strikes := RegEx.create_from_string("take_hit\\(\\s*\\w+\\.hp\\b|(?<![\\w.])(?!super\\b|self\\b)\\w+\\.die\\(\\)")
	var found := []
	for f in DirAccess.get_files_at("res://scripts/bosses/"):
		if f.ends_with(".gd"):
			for m in strikes.search_all(FileAccess.get_file_as_string("res://scripts/bosses/" + f)):
				found.append("%s: %s" % [f, m.get_string()])
	check(found.is_empty(), "every guardian's brood perishes with it (%s)" % [found])
	for f in ["pakukame", "hag_matriarch", "clockwork_alpha"]:
		check(FileAccess.get_file_as_string("res://scripts/bosses/%s.gd" % f).contains(".perish()"), "%s's brood perishes with it" % f)
