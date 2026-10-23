extends TestSuite
## The player's sprite animation (design bible 12.4): the generated sheet, which
## animation plays for each action, and swing recovery.

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
const POSES := ["idle", "run", "rise", "apex", "fall", "dash", "wall", "attack_side", "attack_up",
	"attack_down", "drink", "block", "cast", "hurt"]


func test_sheet_covers_every_pose() -> void:
	var d := PlayerVisual.data()
	var anims: Dictionary = d.animations
	var missing: Array[String] = []
	for pose: String in POSES:
		var names := ["slash1", "slash2", "slash3"] if pose == "attack_side" else [PlayerVisual.anim_for(null, pose)]
		for n: String in names:
			if not anims.has(n):
				missing.append(n)
	check(missing.is_empty(), "every pose has an animation (missing %s)" % [missing])
	var bad: Array[String] = []
	for n: String in anims:
		var a: Dictionary = anims[n]
		for f: Dictionary in a.frames:
			if not f.has("hand") or not f.has("neck"):
				bad.append(n)
		var swing: bool = n.begins_with("slash") or n == "strike_down"
		for f: Dictionary in a.frames:
			if swing != f.has("blade"):
				bad.append(n)
		for i: Variant in a.seq:
			if int(i) >= a.frames.size():
				bad.append(n)
	check(bad.is_empty(), "frames carry hand and neck points, and blades only in swings (bad %s)" % [bad])
	var sheet := (load(PlayerVisual.SHEET) as Texture2D).get_image()
	var cell: Vector2 = d.cell
	check(sheet.get_width() >= int(d.columns) * cell.x and sheet.get_height() >= anims.size() * cell.y,
		"the sheet is big enough for every row")


func test_sheets_use_the_master_palette() -> void:
	var allowed := {}
	for line in FileAccess.get_file_as_string("res://art/palette/master.gpl").split("\n"):
		var parts := line.replace("\t", " ").strip_edges().split(" ", false)
		if parts.size() >= 3 and parts[0].is_valid_int():
			allowed[Color8(int(parts[0]), int(parts[1]), int(parts[2])).to_rgba32()] = true
	var bad: Array[String] = []
	var count := 0
	for file in DirAccess.get_files_at(Sheet.DIR):
		if not file.ends_with(".json"):
			continue
		count += 1
		var img := (load(Sheet.DIR + file.trim_suffix(".json") + ".png") as Texture2D).get_image()
		img.decompress()
		var off := 0
		for y in img.get_height():
			for x in img.get_width():
				var c := img.get_pixel(x, y)
				if c.a > 0.0 and not allowed.has(Color(c.r, c.g, c.b, 1.0).to_rgba32()):
					off += 1
		if off > 0:
			bad.append("%s (%d px)" % [file, off])
	check(count >= 4 and bad.is_empty(), "every character sheet is on the master palette (%d sheets; off: %s)" % [count, bad])


func test_cast_has_sheets() -> void:
	var want := {"monodron": ["idle", "windup", "hop"], "hornet": ["fly", "windup", "swoop"],
		"rot_dwarf": ["walk", "windup", "swing", "recover", "stagger"]}
	var missing: Array[String] = []
	for sheet: String in want:
		for anim: String in want[sheet]:
			if not Sheet.exists(sheet) or not Sheet.has_anim(sheet, anim):
				missing.append(sheet + ":" + anim)
	for npc_id: String in GameData.table("npcs"):
		if not Sheet.exists("npc_" + npc_id):
			missing.append("npc_" + npc_id)
	check(missing.is_empty(), "every enemy state and every person has a sheet (missing %s)" % [missing])
	check(Sheet.info("monodron", "idle", 0).has("eye"), "the Monodron's frames mark its eye for the pupil")


func test_combo_plays_three_swings() -> void:
	var room := make_room(ARENA)
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	var seen: Array[String] = []
	var first: Array[int] = []
	for i in 3:
		p.input.attack_pressed = true
		await frames(2)
		seen.append(p.visual.anim)
		first.append(p.visual.frame)
		await frames(int(p.combat.combo_cooldowns[i] * 60.0))
	check(seen == ["slash1", "slash2", "slash3"], "the combo plays each swing (%s)" % [seen])
	check(first == [0, 0, 0], "each swing starts on its strike frame (%s)" % [first])


func test_swing_recovery_holds_then_returns_to_idle() -> void:
	var room := make_room(ARENA)
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	p.input.attack_pressed = true
	await frames(int(p.tuning.slash_active * 60.0) + 2)
	check(not p.is_attacking and p.visual.anim == "slash1", "the recovery frames play after the hitbox ends (%s)" % p.visual.anim)
	await frames(20)
	check(p.visual.anim == "idle", "then back to idle (%s)" % p.visual.anim)


func test_actions_pick_their_animations() -> void:
	var room := make_room(ARENA)
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	p.input.move_x = 1
	await frames(12)
	var run_frame := p.visual.frame
	await frames(6)
	check(p.visual.anim == "run" and p.visual.frame != run_frame, "running animates (%s %d)" % [p.visual.anim, p.visual.frame])
	p.input.move_x = 0
	p.input.attack_pressed = true
	p.input.up = true
	await frames(2)
	check(p.visual.anim == "slash_up", "up slash (%s)" % p.visual.anim)
	p.input.up = false
	await frames(30)
	p.take_damage(1, false, -1)
	await frames(2)
	check(p.visual.anim == "hurt", "hurt (%s)" % p.visual.anim)
	await frames(30)
	check(p.visual.anim != "hurt", "the hurt pose is brief (%s)" % p.visual.anim)


func test_scarf_hangs_from_the_neck() -> void:
	var room := make_room(ARENA)
	var p := make_player(room, Vector2i(3, 6))
	await frames(6)
	p.input.dash_pressed = true
	await frames(3)
	var neck := p.visual.neck_position()
	check(p.scarf.anchor().distance_to(neck) < 4.0, "the scarf follows the frame's neck (%s vs %s)" % [p.scarf.anchor(), neck])
