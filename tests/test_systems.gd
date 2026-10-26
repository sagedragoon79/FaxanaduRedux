extends TestSuite
## Options, key rebinding, the pause menu and the Ointment (design bible 10.2, 14).

const TEMP_SETTINGS := "user://test_settings.cfg"


func _town() -> Dictionary:
	var a := grid_rows(40, 23)
	put_tiles(a, 5, 19, "P")
	return {"test/town": room_text(["name: Town", "zone: test"], a)}


## Back to the defaults the rest of the suite runs on.
func _restore() -> void:
	Settings.reset()
	Settings.apply()
	Settings.path = Settings.PATH
	Feel.rumble_enabled = false
	for suffix: String in ["", ".bak", ".tmp"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SETTINGS + suffix))


func test_settings_save_load_and_apply() -> void:
	Settings.path = TEMP_SETTINGS
	Settings.reset()
	Settings.adjust("shake", 1)
	Settings.adjust("flashes", 2)
	Settings.adjust("music", -3)
	Settings.adjust("sound", 5)
	Settings.adjust("rumble", 1)
	check(Feel.shake_scale == 0.5 and Feel.flash_scale == 0.0 and not Feel.rumble_enabled, "shake, flashes and rumble reach Feel")
	check(Settings.sound_volume == Settings.VOLUME_MAX, "volume clamps at the top (%d)" % Settings.sound_volume)
	var music := AudioServer.get_bus_index("Music")
	check(music != -1 and is_equal_approx(AudioServer.get_bus_volume_db(music), -15.0), "music volume sets its bus")
	Settings.adjust("shake", 2)
	check(Settings.shake == 0, "lists wrap around")
	Settings.reset()
	check(Settings.music_volume == 8, "reset to defaults")
	Settings.load_settings()
	check(Settings.flashes == 2 and Settings.music_volume == 5 and not Settings.rumble, "settings survive a save and load")
	_restore()


func test_flashes_option_dims_the_screen_flash() -> void:
	var hud := GameHud.new()
	arena.add_child(hud)
	Feel.flash_scale = 0.35
	GameState.flash.emit(1.0)
	check(is_equal_approx(hud.get("_flash"), 0.35), "a reduced flash is 35%% as bright (%.2f)" % hud.get("_flash"))
	Feel.flash_scale = 1.0


func test_game_speed_slows_everything_evenly() -> void:
	Settings.speed = 3
	Settings.apply()
	check(is_equal_approx(Engine.time_scale, 0.7), "70%% speed (%.2f)" % Engine.time_scale)
	Feel.reset()
	check(is_equal_approx(Engine.time_scale, 0.7), "resets keep the chosen speed")
	Feel.slowmo(0.5, 0.2)
	check(is_equal_approx(Engine.time_scale, 0.35), "slow motion is relative to it (%.2f)" % Engine.time_scale)
	_restore()
	Feel.reset()
	check(is_equal_approx(Engine.time_scale, 1.0), "back to full speed")


func test_rebinding_swaps_and_resets() -> void:
	Settings.path = TEMP_SETTINGS
	var jump := Controls.primary_key("jump")
	var attack := Controls.primary_key("attack")
	Settings.bind_key("jump", KEY_B)
	check(Controls.primary_key("jump") == KEY_B, "jump is on B")
	check(_has_key("jump", KEY_Z), "jump keeps its other keys")
	Settings.bind_key("attack", KEY_B)
	check(Controls.primary_key("attack") == KEY_B and Controls.primary_key("jump") == attack, "taking another action's key swaps them")
	check(not _has_key("jump", KEY_B), "B now does only one thing")
	Settings.bind_key("dash", KEY_K)
	check(not _has_key("jump", KEY_K) and _has_key("dash", KEY_K), "a key taken from another action's spares leaves it")
	Settings.load_settings()
	Settings.apply()
	check(Controls.primary_key("attack") == KEY_B, "bindings survive a save and load")
	Settings.reset_keys()
	check(Controls.primary_key("jump") == jump and Controls.primary_key("attack") == attack, "reset puts the defaults back")
	_restore()


func _has_key(action: String, key: Key) -> bool:
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey and (ev as InputEventKey).physical_keycode == key:
			return true
	return false


func test_ointment_is_bought_used_and_wears_off() -> void:
	var w := make_world(_town(), "test/town")
	var p := w.player
	await frames(3)
	p.gold = 2000
	var shop := "eolis_items"
	var index := 3
	check(GameData.item(GameData.shop(shop).stock[index].item).kind == "ointment", "Eolis sells Ointment")
	for i in Shop.OINTMENT_MAX:
		Shop.buy(shop, index, p)
	check(p.ointments == Shop.OINTMENT_MAX and Shop.status(shop, index, p) == "full", "you can carry %d" % Shop.OINTMENT_MAX)
	check(int(GameState.data.ointments) == Shop.OINTMENT_MAX, "Ointments are saved")
	check(p.use_ointment() and p.ointments == Shop.OINTMENT_MAX - 1, "rubbing one on uses it")
	check(not p.use_ointment(), "only one at a time")
	var hp := p.hp
	p.take_damage(30)
	check(p.hp == hp and p.invulnerable, "nothing hurts while it lasts")
	await frames(roundi(Player.OINTMENT_TIME * 60.0) + 10)
	check(p.ointment_left == 0.0 and not p.invulnerable, "it wears off after %d s" % int(Player.OINTMENT_TIME))
	p.take_damage(30)
	check(p.hp < hp, "and then hits land again")


func test_pause_menu_and_its_sub_menus() -> void:
	Settings.path = TEMP_SETTINGS
	var w := make_world(_town(), "test/town")
	var p := w.player
	await frames(2)
	var menu := ListMenu.new()
	arena.add_child(menu)
	var quit := [false]
	check(Menus.open_pause(arena.get_tree(), p, func() -> void: quit[0] = true), "the pause menu opens")
	check(menu.title == "Paused" and arena.get_tree().paused, "and pauses the game")
	check(not menu.rows[1].enabled, "no Ointment to use yet")
	menu.cursor = 2
	menu.confirm()
	check(menu.title == "Options" and menu.is_open, "Options opens in place")
	var before := Settings.shake
	menu.cursor = 0
	menu.adjust(1)
	check(Settings.shake != before, "Left/Right changes the selected option")
	menu.back()
	check(menu.title == "Paused", "backing out returns to the pause menu")
	menu.cursor = 3
	menu.confirm()
	check(menu.title == "Controls" and menu.rows.size() == Settings.REBINDABLE.size() + 2, "Controls lists the rebindable actions")
	menu.cursor = 0
	menu.confirm()
	check(menu.capture.is_valid() and menu.rows[0].right == "...", "choosing one waits for a key")
	menu.back()
	menu.cursor = 4
	menu.confirm()
	check(quit[0] and not menu.is_open and not arena.get_tree().paused, "Quit closes the menu and quits")
	_restore()


## The pixel font (bible 12): every printable ASCII character has a glyph, and
## text only ever scales by whole numbers, so it stays on the pixel grid.
func test_pixel_font_covers_ascii_and_scales_by_whole_numbers() -> void:
	var f := PixelFont.font()
	var h := PixelFont.height()
	check(f != null and f.fixed_size == h, "the font builds at its native height (%d)" % h)
	var missing := ""
	for code in range(33, 127):
		if not f.has_char(code) or f.get_string_size(char(code), HORIZONTAL_ALIGNMENT_LEFT, -1, h).x <= 0.0:
			missing += char(code)
	check(missing == "", "every printable character has a glyph (missing: %s)" % missing)
	var one := f.get_string_size("Lantern Key", HORIZONTAL_ALIGNMENT_LEFT, -1, h)
	var two := f.get_string_size("Lantern Key", HORIZONTAL_ALIGNMENT_LEFT, -1, h * 2)
	check(one.x == roundf(one.x) and two.x == one.x * 2.0, "2x text is exactly twice as wide (%s, %s)" % [one.x, two.x])
	check(f.get_height(h * 3) == h * 3, "and three times as tall at 3x")
	var scales := [8, 10, 12, 14, 18, 22, 44].map(func(s: int) -> int: return PixelFont.scale_for(s))
	check(scales == [1, 1, 1, 1, 2, 2, 4], "requested sizes snap to whole scales (%s)" % [scales])
	var lines := PixelFont.wrap_lines("The Spring of Mist has dried, and the dwarves of Forepaw quake.", 120.0, 10)
	var widest := 0.0
	for l in lines:
		widest = maxf(widest, PixelFont.width(l, 10))
	check(lines.size() > 1 and widest <= 120.0, "wrapping keeps lines inside the box (%d lines, %.0f px)" % [lines.size(), widest])


## With the pixel font, every page anyone says still fits the dialog box.
func test_every_npc_line_fits_the_dialog_box() -> void:
	var npcs: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/npcs.json"))
	var width := DialogBox.BOX.size.x - 24
	var too_long: Array[String] = []
	var pages := 0
	for id: String in npcs:
		var info: Dictionary = npcs[id]
		var said: Array = []
		for key: String in info:
			var v: Variant = info[key]
			if v is String and key in ["greeting"]:
				said.append(v)
			elif v is Array and key.contains("lines"):
				said.append_array(v)
		for line: Variant in said:
			if not line is String:
				continue
			pages += 1
			var n := PixelFont.wrap_lines(line, width, 11).size()
			if n > DialogBox.MAX_LINES:
				too_long.append("%s: %d lines: %s" % [id, n, String(line).left(40)])
	check(pages > 20, "the scan reads the cast's lines (%d pages)" % pages)
	check(too_long.is_empty(), "every page fits in %d lines: %s" % [DialogBox.MAX_LINES, too_long])


func test_no_sound_starts_without_a_sound_device() -> void:
	# Headless runs use the Dummy driver, which never mixes: a started playback
	# would sit in the audio server until exit and be reported as a leak.
	check(Sfx.silent and Music.silent, "the test run has no sound device, and Sfx and Music know it")
	Sfx.play("blip")
	var playing := Sfx.get_children().any(func(p: Node) -> bool: return (p as AudioStreamPlayer).playing)
	check(not playing, "so a sound is never started")


func test_the_ending_tells_climbs_and_thanks() -> void:
	var e := EndingScreen.new()
	arena.add_child(e)
	e.start("Hero", 3725.0)
	check(e.phase == "epilogue" and e.card == 0, "the ending opens on its first card")
	e.tick(EndingScreen.CARD_TIME + 0.1)
	check(e.card == 1, "the cards turn on their own")
	e.advance()
	e.tick(0.01)
	check(e.card == 2, "and a press turns one sooner")
	e.tick(EndingScreen.CARD_TIME * 2.0)
	check(e.phase == "credits", "then the climb up the Tree begins")
	e.tick(10.0)
	check(e.climb > 0.0 and e.climb < EndingScreen.CLIMB, "climbing at its own pace (%.0f px)" % e.climb)
	var slow := e.climb
	e.fast = true
	e.tick(1.0)
	check(e.climb - slow > EndingScreen.SPEED * 3.0, "faster while a button is held")
	e.fast = false
	e.tick(EndingScreen.CLIMB / EndingScreen.SPEED)
	check(e.phase == "thanks", "the credits end on the thanks card")
	var done := [false]
	e.finished.connect(func() -> void: done[0] = true)
	e.advance()
	check(not done[0], "a press held over from the credits does not skip it")
	e.tick(EndingScreen.THANKS_GRACE)
	e.advance()
	check(done[0] and not e.visible, "a press after a moment ends it")
	e.queue_free()


func test_pause_skips_the_ending_to_the_thanks_card() -> void:
	var e := EndingScreen.new()
	arena.add_child(e)
	e.start("Hero", 0.0)
	e.tick(1.0)
	e.skip()
	check(e.phase == "thanks", "from the epilogue")
	e.start("Hero", 0.0)
	e.tick(EndingScreen.EPILOGUE.size() * EndingScreen.CARD_TIME + 1.0)
	e.skip()
	check(e.phase == "thanks", "and from the climb")
	e.queue_free()


func test_the_game_plays_the_ending_then_returns_to_the_title() -> void:
	Settings.path = TEMP_SETTINGS
	GameState.new_game()
	var g: Node2D = load("res://scripts/game.gd").new()
	arena.add_child(g)
	await frames(2)
	g.menu.close()
	g.title_screen.visible = false
	g._start("zenis/heart")
	# A test must not write the real save.
	g.world.use_game_state = false
	await frames(5)
	GameState.begin_ending()
	await frames(2)
	check(g.ending.visible and g.ending.phase == "epilogue", "the Evil One's death plays the ending")
	check(runner.get_tree().paused, "over a frozen world")
	check(Music.track == "ending", "to its own music (%s)" % Music.track)
	g.ending.skip()
	g.ending.tick(EndingScreen.THANKS_GRACE)
	g.ending.advance()
	await frames(3)
	check(g.world == null and g.title_screen.visible and g.menu.is_open, "then the game goes back to the title")
	check(not g.ending.visible and g.hud.visible, "with the ending gone and the HUD back for the next game")
	g.menu.close()
	g.queue_free()
	await frames(2)
	_restore()



## Bible 11: the secret ending counts every death of the run.
func test_deaths_are_counted_and_kept_in_the_save() -> void:
	var w := make_world({}, "eolis/west_gate")
	await frames(3)
	check(int(GameState.data.deaths) == 0, "a new game starts with no deaths")
	w.player._die(w.player.global_position)
	await frames(2)
	check(int(GameState.data.deaths) == 1, "falling counts one (%d)" % int(GameState.data.deaths))
	const SLOT := 9
	GameState.slot = SLOT
	GameState.save_game()
	GameState.new_game()
	check(int(GameState.data.deaths) == 0, "a new game clears the count")
	GameState.load_game(SLOT)
	check(int(GameState.data.deaths) == 1, "and loading the save brings it back")


func test_the_secret_ending_needs_no_deaths_and_the_battle_suit() -> void:
	GameState.new_game()
	check(not GameState.secret_ending(), "no deaths alone is not enough")
	GameState.data.equipment.armor = "battle_suit"
	check(GameState.secret_ending(), "no deaths in the Battle Suit is the secret ending")
	GameState.data.deaths = 1
	check(not GameState.secret_ending(), "one death and it is gone")
	GameState.data.deaths = 0
	GameState.begin_ending()
	check(GameState.flag("cleared") and GameState.flag("cleared_secret"), "a secret clear is marked in the save")
	GameState.new_game()


func test_the_secret_ending_adds_the_sources_cards() -> void:
	var e := EndingScreen.new()
	arena.add_child(e)
	e.start("Lord", 0.0, false, 3)
	e.tick(EndingScreen.EPILOGUE.size() * EndingScreen.CARD_TIME + 0.1)
	check(e.phase == "credits", "the plain ending climbs after its four cards")
	e.start("Lord", 0.0, true, 0)
	check(e.cards().size() == EndingScreen.EPILOGUE.size() + EndingScreen.SECRET_EPILOGUE.size(), "the secret ending has more cards")
	e.tick(EndingScreen.EPILOGUE.size() * EndingScreen.CARD_TIME + 0.1)
	check(e.phase == "epilogue" and e.cards()[e.card] == EndingScreen.SECRET_EPILOGUE[0], "after the four, the Sunken Spring wakes")
	e.tick(EndingScreen.SECRET_EPILOGUE.size() * EndingScreen.CARD_TIME)
	check(e.phase == "credits", "then the climb")
	e.queue_free()


func test_the_game_plays_the_secret_ending_for_a_flawless_run() -> void:
	Settings.path = TEMP_SETTINGS
	GameState.new_game()
	var g: Node2D = load("res://scripts/game.gd").new()
	arena.add_child(g)
	await frames(2)
	g.menu.close()
	g.title_screen.visible = false
	g._start("zenis/heart")
	g.world.use_game_state = false
	await frames(5)
	GameState.data.equipment.armor = "battle_suit"
	GameState.begin_ending()
	await frames(2)
	check(g.ending.visible and g.ending.secret and g.ending.deaths == 0, "no deaths in the Battle Suit plays the secret ending")
	g.ending.skip()
	g.ending.tick(EndingScreen.THANKS_GRACE)
	g.ending.advance()
	await frames(3)
	g.menu.close()
	GameState.new_game()


## Every field of the save, set away from its new-game value, must come back
## exactly through save_game and load_game (JSON makes whole numbers floats, so
## numbers compare by value), and a fresh world must hand it to the player.
func test_every_save_field_survives_a_round_trip() -> void:
	const ROUND_SLOT := 7
	GameState.new_game()
	var d := GameState.data
	var fresh := GameState.fresh()
	for k: String in d.abilities:
		d.abilities[k] = true
	d.spell = "tilte"
	d.max_hp = 150
	d.max_mp = 90.0
	d.flask_max = 4
	d.gold = 4321
	d.xp = 2600
	d.rank = 7
	d.named_rank = 6
	d.skill_points = 3
	d.skills = ["keen_edge", "deluge_pierce", "tilte_swarm"]
	d.respecs = 2
	d.equipment = {"blade": "giant_blade", "armor": "full_plate", "shield": "magic_shield"}
	d.tempers = {"giant_blade": 2, "long_sword": 1}
	d.keys = {"jack": true, "lantern": true}
	d.rings = ["elf", "ruby"]
	d.potion_shards = 5
	d.mantra_shards = 3
	d.elixirs = 1
	d.ointments = 2
	d.collected = {"eolis/plaza:12,30": true}
	d.visited = {"eolis/plaza": true, "trunk/entrance": true}
	d.gurus = {"eolis/guru_hall": [120, 304]}
	d.charts = {"trunk": true}
	d.pins = [["trunk/entrance", 64, 96], ["mist/fog_gate", 200, 40]]
	d.flags = {"spring:trunk": true, "boss:rokusutahn": true}
	d.purse = {"room": "trunk/sap_tunnel", "x": 100, "y": 200, "gold": 77}
	d.save_room = "eolis/guru_hall"
	d.save_pos = [120, 304]
	d.play_time = 3725.5
	d.clears = 1
	d.deaths = 4
	d.trials = {"walls": 41.27}
	var unset: Array[String] = []
	for k: String in fresh:
		if k != "version" and _same(d[k], fresh[k]):
			unset.append(k)
	check(unset.is_empty(), "the test sets every field of the save (missing: %s)" % [unset])
	var before := d.duplicate(true)
	GameState.save_game(ROUND_SLOT)
	GameState.new_game()
	check(GameState.load_game(ROUND_SLOT), "the save loads")
	var lost: Array[String] = []
	for k: String in before:
		if not _same(GameState.data[k], before[k]):
			lost.append("%s: %s became %s" % [k, before[k], GameState.data[k]])
	check(lost.is_empty(), "every field comes back as it was saved: %s" % [lost])
	# A fresh world hands it all to the player.
	var w := World.new()
	w.instant = true
	arena.add_child(w)
	w.build_catalog()
	w.start(String(GameState.data.save_room), Vector2(120, 304))
	w.player.input.scripted = true
	await frames(2)
	var p := w.player
	check(p.gold == 4321 and p.elixirs == 1 and p.ointments == 2 and p.equipped_spell == "tilte", "gold, elixirs, ointments and the spell reach the player")
	check(p.max_hp == 150 and p.flask_max == 4 and p.tilte_swarm and p.spell_pierce and p.reflects, "and the stats, skills and gear behind them")
	check(p.abilities.values().all(func(v: bool) -> bool: return v), "and every ability")
	w.queue_free()
	await frames(1)
	GameState.delete_save(ROUND_SLOT)
	GameState.new_game()


## Equal by value: numbers ignore int and float, containers compare deeply.
func _same(a: Variant, b: Variant) -> bool:
	if (a is int or a is float) and (b is int or b is float):
		return is_equal_approx(float(a), float(b))
	if a is Array and b is Array:
		if a.size() != b.size():
			return false
		for i in a.size():
			if not _same(a[i], b[i]):
				return false
		return true
	if a is Dictionary and b is Dictionary:
		if a.size() != b.size():
			return false
		for k: Variant in a:
			if not b.has(k) or not _same(a[k], b[k]):
				return false
		return true
	return typeof(a) == typeof(b) and a == b


## A save from an older build lacks keys added since: loading it fills them
## with their new-game values and keeps what it has.
func test_an_old_save_gains_the_new_keys() -> void:
	const OLD_SLOT := 6
	var old := {"version": 1, "gold": 300, "abilities": {"glove": true}, "save_room": "eolis/plaza", "save_pos": [100, 200]}
	var f := FileAccess.open(GameState.SAVE_PATH % OLD_SLOT, FileAccess.WRITE)
	f.store_string(JSON.stringify(old))
	f.close()
	check(GameState.load_game(OLD_SLOT), "the old save loads")
	var d := GameState.data
	check(int(d.gold) == 300 and bool(d.abilities.glove), "what it had is kept")
	check(d.abilities.has("hourglass") and not bool(d.abilities.hourglass), "abilities added since start off")
	var missing: Array[String] = []
	for k: String in GameState.fresh():
		if not d.has(k):
			missing.append(k)
	check(missing.is_empty() and d.pins == [] and int(d.deaths) == 0, "every newer key is there, at its new-game value (missing %s)" % [missing])
	GameState.delete_save(OLD_SLOT)
	GameState.new_game()


# --- Damaged saves and settings (pass 109) -----------------------------------------

const BAD_SLOT := 8


func _write_raw(path: String, text: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(text)
	f.close()


func test_a_damaged_save_is_refused_and_leaves_the_game_alone() -> void:
	GameState.delete_save(BAD_SLOT)
	GameState.new_game()
	GameState.data.gold = 777
	var path := GameState.SAVE_PATH % BAD_SLOT
	for text: String in ["", "{\"gold\": 5, \"save_ro", "not a save at all", "[1, 2, 3]", "42", "{\"gold\": 5}"]:
		_write_raw(path, text)
		check(not GameState.load_game(BAD_SLOT), "%s is refused" % JSON.stringify(text))
		check(int(GameState.data.gold) == 777 and GameState.data.has("abilities"), "and the game in play is untouched")
	GameState.delete_save(BAD_SLOT)
	GameState.new_game()


func test_wrong_types_in_a_save_fall_back_to_their_defaults() -> void:
	GameState.delete_save(BAD_SLOT)
	var bad := {"save_room": "eolis/plaza", "abilities": ["glove"], "gold": "lots", "max_hp": -5, "xp": INF,
		"equipment": {"blade": 3, "armor": "leather_armor"}, "skills": ["keen_edge", 7], "rings": "elf",
		"pins": [["mist/fog_cut", 10, 20], "x", [1]], "save_pos": "here", "gurus": {"a/b": [1], "c/d": [3, 4]},
		"purse": {"room": 5}, "flags": "all", "deaths": -3, "future_key": 12}
	_write_raw(GameState.SAVE_PATH % BAD_SLOT, JSON.stringify(bad))
	check(GameState.load_game(BAD_SLOT), "a save with wrong types still loads")
	var d := GameState.data
	var f := GameState.fresh()
	check(d.abilities is Dictionary and d.abilities.size() == f.abilities.size(), "abilities of the wrong type start over")
	check(d.gold == 0 and d.xp == 0 and d.deaths == 0, "a word, infinity or a negative becomes 0 (%s, %s, %s)" % [d.gold, d.xp, d.deaths])
	check(d.max_hp == f.max_hp, "health never falls below a new game's (%s)" % d.max_hp)
	check(d.equipment.blade == f.equipment.blade and d.equipment.armor == "leather_armor", "a bad blade id falls back, a good armor id stays")
	check(d.skills == ["keen_edge"] and d.rings == [], "lists keep only well-formed entries")
	check(_same(d.pins, [["mist/fog_cut", 10, 20]]), "and only whole pins (%s)" % [d.pins])
	check(d.save_pos == [0, 0] and d.gurus.keys() == ["c/d"] and d.purse == {}, "points and the purse must be whole")
	check(d.flags is Dictionary and d.flags.is_empty(), "flags of the wrong type start over")
	check(int(d.get("future_key", 0)) == 12 and int(d.version) == GameState.VERSION, "a newer build's keys are kept")
	GameState.delete_save(BAD_SLOT)
	GameState.new_game()


func test_a_damaged_save_falls_back_to_its_backup() -> void:
	GameState.delete_save(BAD_SLOT)
	GameState.new_game()
	GameState.data.save_room = "eolis/plaza"
	GameState.data.gold = 100
	check(GameState.save_game(BAD_SLOT), "the first save writes")
	GameState.data.gold = 200
	check(GameState.save_game(BAD_SLOT), "the second save writes")
	var path := GameState.SAVE_PATH % BAD_SLOT
	check(FileAccess.file_exists(path + ".bak") and not FileAccess.file_exists(path + ".tmp"), "the last save is kept as a backup, no temp file left")
	_write_raw(path, "{\"gold\": 2")
	GameState.new_game()
	check(GameState.load_game(BAD_SLOT) and int(GameState.data.gold) == 100, "a damaged save loads its backup (gold %s)" % GameState.data.gold)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	check(GameState.has_save(BAD_SLOT), "a backup alone still counts as a save")
	GameState.delete_save(BAD_SLOT)
	check(not GameState.has_save(BAD_SLOT) and not FileAccess.file_exists(path + ".bak"), "deleting a save takes its backup too")
	GameState.new_game()


func test_a_failed_write_keeps_the_last_good_save() -> void:
	GameState.delete_save(BAD_SLOT)
	GameState.new_game()
	GameState.data.save_room = "eolis/plaza"
	GameState.data.gold = 100
	GameState.save_game(BAD_SLOT)
	var path := GameState.SAVE_PATH % BAD_SLOT
	var good := FileAccess.get_file_as_string(path)
	# A directory where the temp file goes: the write can't open it.
	var tmp := ProjectSettings.globalize_path(path + ".tmp")
	DirAccess.make_dir_absolute(tmp)
	GameState.data.gold = 999
	check(not GameState.save_game(BAD_SLOT), "a write that fails says so")
	check(FileAccess.get_file_as_string(path) == good, "and the last good save is untouched")
	DirAccess.remove_absolute(tmp)
	GameState.delete_save(BAD_SLOT)
	GameState.new_game()


func test_damaged_settings_fall_back_to_defaults_or_their_backup() -> void:
	Settings.path = TEMP_SETTINGS
	_write_raw(TEMP_SETTINGS, "[feel\nshake = ]]]")
	Settings.shake = 2
	Settings.load_settings()
	check(Settings.shake == 0 and Settings.music_volume == 8 and Settings.keys.is_empty(), "an unreadable file gives the defaults")
	_write_raw(TEMP_SETTINGS, "[feel]\nshake=\"strong\"\nrumble=5\nspeed=-4\n[audio]\nmusic=99\nsound=[1]\n[keys]\njump=\"space\"\ndash=4194326\n")
	Settings.load_settings()
	check(Settings.shake == 0 and Settings.rumble and Settings.speed == 0, "wrong types fall back and a negative clamps (%d, %s, %d)" % [Settings.shake, Settings.rumble, Settings.speed])
	check(Settings.music_volume == Settings.VOLUME_MAX and Settings.sound_volume == 8, "an out-of-range volume clamps, a list falls back")
	check(not Settings.keys.has("jump") and Settings.keys.get("dash", 0) == 4194326, "only a real keycode is bound")
	# Save twice, damage the file: the backup comes back.
	Settings.reset()
	Settings.shake = 1
	Settings.save()
	Settings.shake = 2
	Settings.save()
	_write_raw(TEMP_SETTINGS, "[feel")
	Settings.load_settings()
	check(Settings.shake == 1, "a damaged settings file loads its backup (%d)" % Settings.shake)
	_restore()


func test_a_rest_in_a_missing_room_wakes_at_the_start() -> void:
	check(World.room_exists("eolis/plaza"), "a real room exists")
	check(not World.room_exists("nowhere/room") and not World.room_exists("../x") and not World.room_exists(""), "a missing or odd one doesn't")


# --- Completion (pass 106) --------------------------------------------------------

func test_completion_tallies_rooms_hidden_rooms_treasures_and_bosses() -> void:
	GameState.new_game()
	var catalog := {
		"a/x": {"secret": true, "treasures": ["a/x:1,1", "a/x:2,2"]},
		"a/y": {"secret": false, "treasures": []},
	}
	var none := Completion.tally(catalog)
	check(none.percent == 0 and none.rooms_total == 2 and none.secrets_total == 1 and none.treasures_total == 2, "a new save has seen nothing (%s)" % [none])
	check(none.bosses_total == BossArena.BOSSES.size(), "and every boss counts")
	GameState.visit("a/x")
	GameState.set_flag("secret:a/x")
	GameState.collect("a/x:1,1")
	GameState.set_flag("boss:rokusutahn")
	var some := Completion.tally(catalog)
	check(some.rooms == 1 and some.secrets == 1 and some.treasures == 1 and some.bosses == 1, "each find counts once (%s)" % [some])
	var want := int(floor((0.5 + 1.0 + 0.5 + 1.0 / BossArena.BOSSES.size()) / 4.0 * 100.0))
	check(some.percent == want, "the percent is the average of the four shares, rounded down (%d, want %d)" % [some.percent, want])
	GameState.visit("a/y")
	GameState.collect("a/x:2,2")
	for id: String in BossArena.BOSSES:
		GameState.set_flag("boss:" + id)
	check(Completion.tally(catalog).percent == 100, "everything found is 100%")
	GameState.new_game()


func test_the_whole_world_is_counted() -> void:
	var w := World.new()
	w.build_catalog()
	GameState.new_game()
	var c := Completion.tally(w.catalog)
	check(c.rooms_total > 100 and c.secrets_total >= 5 and c.treasures_total > 50, "the real world has rooms, hidden rooms and treasures to find (%s)" % [c])
	w.free()


func test_the_thanks_card_counts_up_the_completion() -> void:
	var e := EndingScreen.new()
	arena.add_child(e)
	var stats := {"rooms": 50, "rooms_total": 100, "secrets": 3, "secrets_total": 7, "treasures": 40, "treasures_total": 106,
		"bosses": 13, "bosses_total": 13, "percent": 60, "clears": 2}
	e.start("Hero", 3725.0, false, 4, stats)
	e.skip()
	check(e.phase == "thanks" and e.stats.percent == 60, "the thanks card carries the save's completion")
	var rows := e.completion_rows()
	check(rows.size() == 4 and rows[0] == ["Rooms explored", 50, 100] and rows[3] == ["Bosses", 13, 13], "four rows of found against total (%s)" % [rows])
	e.tick(EndingScreen.COUNT_TIME + 0.1)
	await frames(1)
	check(e.visible, "it draws through the count")
	e.start("Hero", 10.0)
	e.skip()
	e.tick(0.5)
	await frames(1)
	check(e.stats.is_empty(), "with no tally it shows only rank, time and deaths")
	e.queue_free()


# --- Guru Trials (pass 113) -------------------------------------------------------

func _temple() -> Dictionary:
	var rows := grid_rows(30, 20)
	return {"test/a": room_text(["name: Temple", "zone: eolis"], rows)}


## Bible 3.1: the trials open two by two as springs are restored, and only
## built ones are offered.
func test_guru_trials_open_as_the_springs_flow() -> void:
	GameState.new_game()
	var ids := Trials.built().map(func(t: Dictionary) -> String: return t.id)
	check(ids.slice(0, 2) == ["walls", "edges"], "the first two trials are built (%s)" % [ids])
	for t: Dictionary in Trials.built():
		check(World.room_exists(t.room), "%s has its room" % t.name)
	check(not Trials.is_open(Trials.find("walls")), "with no spring flowing, they are sealed")
	GameState.set_flag("spring:trunk")
	check(Trials.is_open(Trials.find("walls")) and Trials.is_open(Trials.find("edges")), "the first spring opens the first two")
	check(not Trials.is_open(Trials.find("thorns")), "the next two want a second spring")
	GameState.set_flag("spring:mist")
	check(Trials.is_open(Trials.find("thorns")), "which opens them")
	check(Trials.format_time(83.47) == "1:23.4" and Trials.format_time(INF) == "--", "times read m:ss.t")


## Bible 3.1: the Guru sends you to the trial's start, the clock runs, the bell
## clears it (a Mantra Shard the first time, the best time kept), and the mantra
## carries you back to where you stood.
func test_a_trial_runs_on_a_clock_and_the_bell_clears_it() -> void:
	var w := make_world(_temple(), "test/a", cell_feet(5, 16))
	GameState.set_flag("spring:trunk")
	var p := w.player
	await frames(5)
	var back := p.global_position
	Menus.start_trial(w, p, Trials.find("walls"))
	await frames(5)
	check(w.room.id == "trials/walls", "the mantra carries you to the trial")
	var start := Trials.start_pos(w.room_text("trials/walls"))
	check(p.global_position.distance_to(start) < 4.0, "to its start")
	check(Trials.active(), "and the trial is under way")
	await frames(60)
	check(Trials.run.time > 0.9 and Trials.run.time < 1.2, "the clock runs (%.2f s)" % Trials.run.time)
	var bell: TrialGoal = w.room.get_tree().get_first_node_in_group("trial_goal")
	check(bell != null, "the room has its bell")
	var shards := int(GameState.data.mantra_shards)
	p.teleport(bell.global_position)
	await frames(3)
	check(bell.rung, "touching the bell rings it")
	check(Trials.cleared("walls"), "the trial is cleared")
	check(int(GameState.data.mantra_shards) == shards + 1, "the first clear gives a Mantra Shard")
	var first := Trials.best("walls")
	check(first > 0.9 and first < 1.3, "and keeps the time (%.2f s)" % first)
	await frames(int(TrialGoal.RING * 60) + 10)
	check(w.room.id == "test/a" and p.global_position.distance_to(back) < 4.0, "then you are back where you stood")
	check(not Trials.active(), "with the trial over")
	# A slower second walk keeps the best and gives no second shard.
	Menus.start_trial(w, p, Trials.find("walls"))
	await frames(5)
	await frames(120)
	bell = w.room.get_tree().get_first_node_in_group("trial_goal")
	p.teleport(bell.global_position)
	await frames(3)
	check(Trials.best("walls") == first, "a slower clear keeps the best (%.2f)" % Trials.best("walls"))
	check(int(GameState.data.mantra_shards) == shards + 1, "and gives no second shard")
	await frames(int(TrialGoal.RING * 60) + 10)
	w.queue_free()
	Trials.abandon()


## Bible 3.1: in a trial a hazard costs time, never health: it sets you back on
## your last footing. Leaving from the pause menu returns you to the Guru.
func test_in_a_trial_hazards_cost_time_not_health() -> void:
	var w := make_world(_temple(), "test/a", cell_feet(5, 16))
	GameState.set_flag("spring:trunk")
	var p := w.player
	await frames(5)
	var back := p.global_position
	Menus.start_trial(w, p, Trials.find("walls"))
	await frames(10)
	var hp := p.hp
	var safe := p.safe_position
	# Step onto the spikes beside the start.
	p.teleport(cell_feet(8, 27))
	await frames(3)
	check(p.hp == hp, "spikes take no health in a trial (%d -> %d)" % [hp, p.hp])
	check(p.global_position.distance_to(safe) < 4.0, "they set you back on your footing")
	check(Trials.active(), "and the clock runs on")
	Menus.leave_trial(w.get_tree())
	await frames(5)
	check(w.room.id == "test/a" and p.global_position.distance_to(back) < 4.0, "leaving the trial returns you to the Guru")
	check(not Trials.active() and not Trials.cleared("walls"), "uncleared")
	w.queue_free()


## Best times are saved, and a bad one in a damaged save is dropped.
func test_trial_times_are_saved_and_sanitized() -> void:
	GameState.new_game()
	GameState.data.trials = {"walls": 12.34}
	var copy := GameState.sanitize(JSON.parse_string(JSON.stringify(GameState.data)))
	check(_same(copy.trials, {"walls": 12.34}), "a best time survives a save (%s)" % [copy.trials])
	var bad: Dictionary = JSON.parse_string(JSON.stringify(GameState.data))
	bad.trials = {"walls": -3, "edges": "fast", "thorns": 20}
	copy = GameState.sanitize(bad)
	check(_same(copy.trials, {"thorns": 20.0}), "negative or non-number times are dropped (%s)" % [copy.trials])
	bad.trials = [1, 2]
	check(_same(GameState.sanitize(bad).trials, {}), "a list in their place falls back to none")
	GameState.new_game()
