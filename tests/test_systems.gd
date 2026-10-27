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
	Settings.bind_key("jump", KEY_N)
	check(Controls.primary_key("jump") == KEY_N, "jump is on N")
	check(_has_key("jump", KEY_Z), "jump keeps its other keys")
	Settings.bind_key("attack", KEY_N)
	check(Controls.primary_key("attack") == KEY_N and Controls.primary_key("jump") == attack, "taking another action's key swaps them")
	check(not _has_key("jump", KEY_N), "N now does only one thing")
	Settings.bind_key("dash", KEY_K)
	check(not _has_key("jump", KEY_K) and _has_key("dash", KEY_K), "a key taken from another action's spares leaves it")
	Settings.load_settings()
	Settings.apply()
	check(Controls.primary_key("attack") == KEY_N, "bindings survive a save and load")
	Settings.reset_keys()
	check(Controls.primary_key("jump") == jump and Controls.primary_key("attack") == attack, "reset puts the defaults back")
	_restore()


func _has_key(action: String, key: Key) -> bool:
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey and (ev as InputEventKey).physical_keycode == key:
			return true
	return false


func test_fullscreen_toggle_keys() -> void:
	var game := preload("res://scripts/game.gd")
	var key := func(code: Key, alt := false, pressed := true) -> InputEventKey:
		var ev := InputEventKey.new()
		ev.physical_keycode = code
		ev.alt_pressed = alt
		ev.pressed = pressed
		return ev
	check(game.is_fullscreen_toggle(key.call(KEY_F11)), "F11 toggles fullscreen")
	check(game.is_fullscreen_toggle(key.call(KEY_ENTER, true)), "Alt+Enter toggles fullscreen")
	check(not game.is_fullscreen_toggle(key.call(KEY_ENTER)), "plain Enter does not")
	check(not game.is_fullscreen_toggle(key.call(KEY_F11, false, false)), "releasing F11 does not")


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
	check(menu.title == "Equipment" and menu.rows[0].get("header", false) and menu.rows[1].label == "Short Sword", "Equipment lists your gear by slot")
	menu.back()
	menu.cursor = 3
	menu.confirm()
	check(menu.title == "Options" and menu.is_open, "Options opens in place")
	var before := Settings.shake
	menu.cursor = 0
	menu.adjust(1)
	check(Settings.shake != before, "Left/Right changes the selected option")
	menu.back()
	check(menu.title == "Paused", "backing out returns to the pause menu")
	menu.cursor = 4
	menu.confirm()
	check(menu.title == "Controls" and menu.rows.size() == Settings.REBINDABLE.size() + 2, "Controls lists the rebindable actions")
	menu.cursor = 0
	menu.confirm()
	check(menu.capture.is_valid() and menu.rows[0].right == "...", "choosing one waits for a key")
	menu.back()
	menu.cursor = 5
	menu.confirm()
	check(menu.title == "Journey" and menu.is_open, "Journey opens in place")
	menu.back()
	check(menu.title == "Paused", "and backs out to the pause menu")
	menu.cursor = 6
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
	e.tick(EndingScreen.CARD_TIME * (e.cards().size() - 2))
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


## Faxanadu's ending (pass 167): the town would thank you, and the wanderer
## walks on. The last two cards say so while the hero walks off east.
func test_the_ending_closes_on_the_wanderer_walking_on() -> void:
	var e := EndingScreen.new()
	arena.add_child(e)
	for secret: bool in [false, true]:
		e.start("Hero", 0.0, secret, 0)
		var n := e.cards().size()
		check(e.cards().slice(n - 2) == EndingScreen.FAREWELL, "the farewell closes the epilogue (secret %s)" % secret)
		check(String(EndingScreen.FAREWELL[0]).contains("King") and String(EndingScreen.FAREWELL[1]).contains("walking on"), "the King's thanks, then the road")
		e.tick(e.farewell_start() - 0.5)
		check(e.wanderer_x() < 0.0, "no one walks before the farewell")
		e.tick(0.6)
		var x0 := e.wanderer_x()
		check(x0 >= 320.0 and x0 < 350.0, "the wanderer sets out from the foot of the Tree (%.0f)" % x0)
		e.tick(EndingScreen.CARD_TIME * 2.0 - 0.2)
		check(e.phase == "epilogue" and e.wanderer_x() > 640.0, "and is off the east edge before the climb (%.0f)" % e.wanderer_x())
		e.tick(0.2)
		check(e.phase == "credits", "then the credits climb")
	check(Sheet.has_anim(PlayerVisual.SHEET_NAME, "run"), "the walk is the hero's own")
	for line: String in EndingScreen.FAREWELL:
		check(PixelFont.width(line, 12) < 600.0, "the card fits the screen: %s" % line)
	e.queue_free()


func test_pause_skips_the_ending_to_the_thanks_card() -> void:
	var e := EndingScreen.new()
	arena.add_child(e)
	e.start("Hero", 0.0)
	e.tick(1.0)
	e.skip()
	check(e.phase == "thanks", "from the epilogue")
	e.start("Hero", 0.0)
	e.tick(e.cards().size() * EndingScreen.CARD_TIME + 1.0)
	check(e.phase == "credits", "the climb has begun")
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
	e.tick((EndingScreen.EPILOGUE.size() + EndingScreen.FAREWELL.size()) * EndingScreen.CARD_TIME + 0.1)
	check(e.phase == "credits", "the plain ending climbs after its four cards and the farewell")
	e.start("Lord", 0.0, true, 0)
	check(e.cards().size() == EndingScreen.EPILOGUE.size() + EndingScreen.SECRET_EPILOGUE.size() + EndingScreen.FAREWELL.size(), "the secret ending has more cards")
	e.tick(EndingScreen.EPILOGUE.size() * EndingScreen.CARD_TIME + 0.1)
	check(e.phase == "epilogue" and e.cards()[e.card] == EndingScreen.SECRET_EPILOGUE[0], "after the four, the Sunken Spring wakes")
	e.tick(EndingScreen.SECRET_EPILOGUE.size() * EndingScreen.CARD_TIME)
	check(e.phase == "epilogue" and e.cards()[e.card] == EndingScreen.FAREWELL[0], "the farewell still comes last")
	e.tick(EndingScreen.FAREWELL.size() * EndingScreen.CARD_TIME)
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
	d.equipment = {"blade": "dragon_slayer", "armor": "full_plate", "shield": "magic_shield", "helmet": "battle_helmet"}
	d.gear = ["short_sword", "dwarvish_broad_sword", "dragon_slayer", "full_plate", "magic_shield", "battle_helmet"]
	d.tempers = {"dwarvish_broad_sword": 2, "long_sword": 1}
	d.keys = {"jack": true, "lantern": true}
	d.rings = ["elf", "ruby"]
	d.potion_shards = 5
	d.mantra_shards = 3
	d.meteor_shards = 2
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
	d.dyes = ["tide_dye"]
	d.dye = "tide_dye"
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
	check(p.max_hp == 170 and p.flask_max == 4 and p.tilte_swarm and p.spell_pierce and p.reflects, "and the stats, skills and gear behind them (150 and the helmet's mask)")
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


## A settings file from an older build has no line for the actions added since.
func test_older_settings_load_without_errors() -> void:
	Settings.path = TEMP_SETTINGS
	_write_raw(TEMP_SETTINGS, "[feel]\nshake=1\n[keys]\njump=4194326\n")
	var errors := ErrorCatcher.start()
	Settings.load_settings()
	var caught := errors.stop()
	check(caught.is_empty(), "the missing actions log no errors (%s)" % [caught])
	check(Settings.shake == 1 and Settings.keys.get("jump", 0) == 4194326, "what the file holds still loads")
	check(not Settings.keys.has("map") and not Settings.keys.has("heal"), "and the newer actions keep their default keys")
	# The catcher itself must see an engine error, or the check above proves nothing.
	var probe := ErrorCatcher.start()
	ConfigFile.new().get_value("keys", "map")
	check(not probe.stop().is_empty(), "the catcher hears an engine error")
	_restore()


## Pass 138: a save from an older or newer build can name things this build
## doesn't have: a renamed skill node, a blade, a ring, a dye. Loading it,
## dressing the player, learning, unlearning and the dyer must all go on
## without an engine error, and a skill listed twice can't be refunded twice.
func test_a_save_naming_things_this_build_lacks_plays_on() -> void:
	var w := make_world({}, "eolis/market")
	await frames(3)
	var p := w.player
	var src := GameState.fresh()
	src.save_room = "eolis/market"
	src.skills = ["keen_edge", "ghost_skill", "keen_edge", 7]
	src.equipment = {"blade": "ghost_blade", "armor": "ghost_armor", "shield": "ghost_shield"}
	src.rings = ["ghost_ring"]
	src.dyes = [5, "ghost_dye", "tide_dye", "tide_dye"]
	src.dye = "ghost_dye"
	src.tempers = {"ghost_blade": 2}
	var errors := ErrorCatcher.start()
	GameState.data = GameState.sanitize(JSON.parse_string(JSON.stringify(src)))
	check(GameState.data.skills == ["keen_edge", "ghost_skill"], "skills are kept once each, strings only (%s)" % [GameState.data.skills])
	check(GameState.data.dyes == ["ghost_dye", "tide_dye"], "and so are dyes (%s)" % [GameState.data.dyes])
	GameState.refresh_stats(p)
	check(p.slash_damage == int(GameData.item("short_sword").slash), "an unknown blade falls back to the Short Sword (%d)" % p.slash_damage)
	check(PlayerVisual.dye_look().is_empty(), "an unknown dye leaves the cloak as it is")
	for n: Dictionary in Skills.nodes():
		Skills.status(n.id)
	for i in GameData.shop("eolis_dyes").stock.size():
		Shop.status("eolis_dyes", i, p)
	await frames(2)
	p.gold = 1000
	var cost := Skills.respec_cost()
	check(Skills.respec(p), "unlearning goes through")
	check(p.gold == 1000 - cost and GameState.data.skills.is_empty(), "for its price, clearing every skill")
	check(int(GameState.data.skill_points) == int(GameData.skill("keen_edge").cost), "Keen Edge comes back once; the unknown node refunds nothing (%d)" % int(GameState.data.skill_points))
	var caught := errors.stop()
	check(caught.is_empty(), "and nothing logs an engine error (%s)" % [caught])


## Pass 184: the Hand Dagger is now the Short Sword. A save from before
## keeps it in hand and keeps its tempers; the Throw button is bound; and the
## Rune Dagger in the Hornet Gallery grants the throw.
func test_the_hand_dagger_is_the_short_sword_and_the_rune_dagger_is_found() -> void:
	var src := GameState.fresh()
	src.equipment = {"blade": "hand_dagger", "armor": "", "shield": ""}
	src.tempers = {"hand_dagger": 2, "long_sword": 1}
	var got := GameState.sanitize(JSON.parse_string(JSON.stringify(src)))
	check(got.equipment.blade == "short_sword", "an old save's Hand Dagger is the Short Sword (%s)" % got.equipment.blade)
	check(got.tempers.size() == 2 and int(got.tempers.short_sword) == 2 and int(got.tempers.long_sword) == 1, "with its tempers (%s)" % [got.tempers])
	check(GameData.item("short_sword").name == "Short Sword" and GameData.item("hand_dagger").is_empty(), "the item is the Short Sword")
	check(GameState.fresh().equipment.blade == "short_sword", "a new game starts with it")
	check(not bool(GameState.fresh().abilities.rune_dagger), "and without the Rune Dagger")
	check(InputMap.has_action("throw") and Controls.primary_key("throw") == KEY_B, "Throw is on B")
	var pad := false
	for ev in InputMap.action_get_events("throw"):
		pad = pad or (ev is InputEventJoypadButton and (ev as InputEventJoypadButton).button_index == JOY_BUTTON_RIGHT_SHOULDER)
	check(pad, "and on the right bumper")
	var found := []
	for f in DirAccess.get_files_at("res://levels/trunk"):
		if f.ends_with(".room") and FileAccess.get_file_as_string("res://levels/trunk/" + f).contains("}"):
			found.append(f)
	check(found == ["hornet_gallery.room"], "the Rune Dagger lies in the Hornet Gallery (%s)" % [found])
	var w := make_world({}, "eolis/market")
	await frames(3)
	var p := w.player
	var pick := ItemPickup.new()
	pick.kind = ItemPickup.KIND_BY_CHAR["}"]
	w.room.add_child(pick)
	pick.grant(p)
	check(bool(p.abilities.get("rune_dagger", false)), "picked up, it is yours")


## Pass 185: the Battle Helmet left the shield slot for its own. A save that
## wore it as a shield wears it as a helmet, with the Magic Shield in hand
## (the guard and parry it had); a save from before helmets gets an empty slot.
func test_a_save_with_the_helmet_in_the_shield_slot_moves_it_to_the_head() -> void:
	var src := GameState.fresh()
	src.equipment = {"blade": "long_sword", "armor": "full_plate", "shield": "battle_helmet"}
	var got := GameState.sanitize(JSON.parse_string(JSON.stringify(src)))
	check(got.equipment.helmet == "battle_helmet" and got.equipment.shield == "magic_shield", "helmet on the head, Magic Shield in hand (%s)" % [got.equipment])
	check(got.equipment.blade == "long_sword" and got.equipment.armor == "full_plate", "the rest untouched")
	src.equipment = {"blade": "short_sword", "armor": "", "shield": "small_shield"}
	got = GameState.sanitize(JSON.parse_string(JSON.stringify(src)))
	check(got.equipment.helmet == "" and got.equipment.shield == "small_shield", "an older save gains an empty helmet slot")
	check(GameData.item("battle_helmet").kind == "helmet" and not GameData.item("battle_helmet").has("guard"), "the helmet neither guards nor parries")


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


## Pass 187: the finds a `prop:` line lays (the Battle Helmet, the Joker Key)
## are treasures like the ones drawn in the grid: the percent, the Journey and
## Treasure Sense count them, under the same id the room gives the pickup.
func test_finds_laid_by_props_count_as_treasures() -> void:
	var w := make_world({}, "zenis/threshold")
	await frames(2)
	var helm_id := "zenis/threshold:2,19"
	check(w.catalog["zenis/threshold"].treasures.has(helm_id), "the Battle Helmet is a Threshold treasure (%s)" % [w.catalog["zenis/threshold"].treasures])
	check(w.catalog["dartmoor/drowned_market"].treasures.has("dartmoor/drowned_market:49,12"), "and the Joker Key a Drowned Market one")
	var helm: ItemPickup = null
	for c in w.room.get_children():
		if c is ItemPickup and (c as ItemPickup).kind == "battle_helmet":
			helm = c
	check(helm != null and helm.pickup_id == helm_id, "the pickup carries the same id (%s)" % [helm.pickup_id if helm else "none"])
	var before := int(Completion.tally(w.catalog).treasures)
	var left := MapScreen.unfound(w.catalog["zenis/threshold"])
	GameState.collect(helm_id)
	check(int(Completion.tally(w.catalog).treasures) == before + 1, "taking it counts toward the percent")
	check(MapScreen.unfound(w.catalog["zenis/threshold"]) == left - 1, "and Treasure Sense stops sensing it")
	GameState.new_game()


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
## Pass 116: the mantra-space sounds like itself: its own theme and bed, a
## shimmer as the mantra carries you in, a bronze bell, and a sting for a new best.
func test_the_guru_trials_have_a_sound_of_their_own() -> void:
	for name: String in ["trials", "amb_trials"]:
		var stream := Music.stream_for(name)
		check(stream is AudioStreamOggVorbis and (stream as AudioStreamOggVorbis).loop, "%s is a looping track" % name)
	for sound: String in ["trial_begin", "trial_bell", "trial_record"]:
		check(FileAccess.file_exists("res://assets/sfx/%s.wav" % sound), "%s.wav exists" % sound)
	var w := make_world(_temple(), "test/a", cell_feet(5, 16))
	GameState.set_flag("spring:trunk")
	var p := w.player
	await frames(5)
	for id: String in ["walls", "edges"]:
		Sfx.recent.clear()
		Menus.start_trial(w, p, Trials.find(id))
		await frames(5)
		check(Sfx.recent.has("trial_begin"), "%s: the mantra carries you in with a shimmer" % id)
		check(Music.track == "trials" and Music.ambience_track == "amb_trials",
			"%s plays the trials theme over the mantra-space (%s, %s)" % [id, Music.track, Music.ambience_track])
		var bell: TrialGoal = w.room.get_tree().get_first_node_in_group("trial_goal")
		Sfx.recent.clear()
		p.teleport(bell.global_position)
		await frames(3)
		check(Sfx.recent.has("trial_bell") and not Sfx.recent.has("save"), "%s: the bell rings bronze, not the save chime" % id)
		check(not Sfx.recent.has("trial_record"), "a first clear rings the shard, no record sting")
		await frames(int(TrialGoal.RING * 60) + 10)
	# A faster second walk is a new best, and stings.
	GameState.data.trials["walls"] = 999.0
	Menus.start_trial(w, p, Trials.find("walls"))
	await frames(5)
	var bell2: TrialGoal = w.room.get_tree().get_first_node_in_group("trial_goal")
	Sfx.recent.clear()
	p.teleport(bell2.global_position)
	await frames(3)
	check(Sfx.recent.has("trial_record"), "a new best plays the record sting")
	await frames(int(TrialGoal.RING * 60) + 10)
	w.queue_free()
	Trials.abandon()


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


func _numbers(room: Node) -> Array:
	var out := []
	for c in room.get_children():
		if c is DamageNumber:
			out.append(c)
	return out


## Pass 154 (bible 14): damage numbers, an option that is off by default.
func test_damage_numbers_show_what_each_blow_dealt() -> void:
	Settings.path = TEMP_SETTINGS
	Settings.reset()
	var rooms := _town()
	var rows := grid_rows(40, 23)
	put_tiles(rows, 5, 19, "P")
	put_tiles(rows, 12, 19, "M")
	put_tiles(rows, 22, 19, "D")
	rooms["test/town"] = room_text(["name: Town", "zone: test"], rows)
	var w := make_world(rooms, "test/town")
	var mono: Monodron = null
	var dwarf: RotDwarf = null
	for c in w.room.get_children():
		if c is Monodron:
			mono = c
		elif c is RotDwarf:
			dwarf = c
	mono.max_hp = 999
	mono.hp = 999
	mono.set_physics_process(false)
	dwarf.set_physics_process(false)
	await frames(3)
	mono.take_hit(8, Vector2.RIGHT)
	check(_numbers(w.room).is_empty() and not Settings.damage_numbers, "off by default: a blow shows no number")
	Settings.adjust("numbers", 1)
	check(Settings.damage_numbers and Settings.value_text("numbers") == "On", "the option turns them on")
	check(Menus.OPTIONS.any(func(o: Array) -> bool: return o[0] == "numbers"), "from the Options menu")
	# A cut: the number is what the foe lost.
	var before := mono.hp
	mono.take_hit(8, Vector2.RIGHT)
	var nums := _numbers(w.room)
	check(nums.size() == 1 and nums[0].amount == before - mono.hp and nums[0].kind == "hit", "a cut shows the damage it dealt (%s)" % [nums.map(func(n: DamageNumber) -> String: return "%d %s" % [n.amount, n.kind])])
	check(nums[0].global_position.y < mono.center().y, "over the foe")
	# A heavy blow (the finisher, a thrust) comes in at 1.8x: gold, and larger.
	mono.take_hit(14, Vector2(1.8, 0))
	nums = _numbers(w.room)
	check(nums.size() == 2 and nums[1].kind == "heavy" and nums[1].amount == 14, "a heavy blow's number is gold")
	check(DamageNumber.SIZES.heavy > DamageNumber.SIZES.hit, "and larger")
	# A blow the shield turns deals nothing, and shows nothing.
	dwarf.facing = -1
	var hp_before := dwarf.hp
	dwarf.take_hit(8, Vector2.RIGHT)
	check(_numbers(w.room).size() == 2 and dwarf.hp == hp_before, "a blocked blow shows no number")
	# The player's own losses, in red, as dealt after armor.
	var p := w.player
	p.defense = 0.4
	var php := p.hp
	p.take_damage(20)
	nums = _numbers(w.room)
	var hurt: Array = nums.filter(func(n: DamageNumber) -> bool: return n.kind == "hurt")
	check(hurt.size() == 1 and hurt[0].amount == php - p.hp and hurt[0].amount < 20, "a hit on the player shows the HP it took, after armor (%s)" % [hurt.map(func(n: DamageNumber) -> int: return n.amount)])
	# They rise, fade and are gone.
	var y0: float = nums[0].offset().y
	await frames(20)
	check(is_instance_valid(nums[0]) and nums[0].offset().y < y0 - 8.0, "a number rises")
	await frames(40)
	check(_numbers(w.room).is_empty(), "and is gone after %.1f s" % DamageNumber.LIFE)
	Settings.reset()
	Settings.load_settings()
	check(Settings.damage_numbers, "the choice is saved")
	_restore()
	check(not Settings.damage_numbers, "and the suite runs on the default, off")


## Pass 155: the third trial, the Mantra of Thorns, is a pogo course: a spike
## corridor, a pit under a chain of thorn bulbs, and two bulbs up to a hanging
## slab that nothing else reaches. A simple pogo-playing hand clears it in the
## real game: it walks right, jumps off edges, steers over the next bulb and
## strikes down whenever it falls.
func test_the_mantra_of_thorns_is_cleared_by_pogo() -> void:
	var t := Trials.find("thorns")
	check(Trials.built().has(t) and t.needs == ["glove", "mattock"], "the Mantra of Thorns is built, for the Glove and the Mattock")
	check(t.desc != "", "and the Guru describes it")
	# Without the Mattock the bell is out of reach (the checker).
	var text := FileAccess.get_file_as_string(World.room_path(t.room))
	var bare := Reach.new({t.room: text}, {"glove": true})
	check(not bare.reachable(bare.spot_of(t.room, "P")).has(Reach.key(t.room, 90, 7)), "without the Mattock the bell can't be reached")
	var w := make_world(_temple(), "test/a", cell_feet(5, 16))
	GameState.set_flag("spring:trunk")
	GameState.set_flag("spring:mist")
	GameState.data.abilities["glove"] = true
	GameState.data.abilities["mattock"] = true
	var p := w.player
	GameState.apply(p)
	await frames(5)
	Menus.start_trial(w, p, t)
	await frames(5)
	check(w.room.id == "trials/thorns", "the Guru sends you there")
	var bell: TrialGoal = w.room.get_tree().get_first_node_in_group("trial_goal")
	var bulbs: Array = []
	for c in w.room.get_children():
		if c is ThornBulb:
			bulbs.append(c)
	bulbs.sort_custom(func(a: Node2D, b: Node2D) -> bool: return a.global_position.x < b.global_position.x)
	check(bulbs.size() == 7, "seven thorn bulbs hang in the air (%d)" % bulbs.size())
	var done := {}
	var pogos := 0
	var f := 0
	while f < 60 * 30 and not bell.rung:
		var on := p.is_on_floor()
		var target: Node2D = null
		for b: Node2D in bulbs:
			if not done.has(b) and b.global_position.x > p.global_position.x - 24.0 and b.global_position.x < p.global_position.x + 140.0:
				target = b
				break
		p.input.move_x = 1
		if on:
			done.clear()
			var off_edge := not w.room.is_solid_at(p.global_position + Vector2(10, 4))
			p.input.jump_pressed = off_edge
			p.input.jump_held = off_edge
		elif target != null and p.velocity.y > -100.0:
			var dx := target.global_position.x - p.global_position.x
			p.input.move_x = 0 if absf(dx) < 3.0 else int(signf(dx))
		var falling := not on and p.velocity.y > 0.0
		p.input.down = falling
		p.input.attack_pressed = falling and f % 4 == 0
		var vy := p.velocity.y
		await frames(1)
		f += 1
		if vy > 0.0 and p.velocity.y < -300.0:
			pogos += 1
			if target != null and absf(target.global_position.x - p.global_position.x) < 30.0:
				done[target] = true
	check(bell.rung, "the pogo hand rings the bell (%.1f s, %d pogos)" % [f / 60.0, pogos])
	check(pogos >= 5, "by pogo (%d bounces)" % pogos)
	await frames(int(TrialGoal.RING * 60) + 10)
	w.queue_free()
	Trials.abandon()


## Bible 11: the boss rush opens at 100% and runs every guardian again in
## order, each through the door you first came in by, with a third of your
## health mended between fights. It wins nothing and plays no ending; the clock
## and its best time are kept; a killing blow ends it and sends you back whole.
func test_the_boss_rush_runs_every_guardian_again() -> void:
	var w := make_world(_temple(), "test/a", cell_feet(5, 16))
	var p := w.player
	await frames(5)
	check(not BossRush.unlocked() and not Menus._rush_row().enabled, "the rush is sealed before 100%")
	GameState.set_flag("lord")
	for pair: Array in BossRush.ORDER:
		GameState.set_flag("boss:" + String(pair[0]))
		check(w.has_room(String(pair[1])), "%s's arena exists" % pair[0])
	check(Menus._rush_row().enabled, "and open after")
	var flags_before: Dictionary = GameState.data.flags.duplicate()
	var rings_before: Array = GameState.data.rings.duplicate()
	var gold_before := p.gold
	var back := p.global_position
	p.hp = 3
	BossRush.start(w, p)
	await frames(5)
	check(p.hp == p.max_hp, "the rush begins whole")
	var n := 0
	for pair: Array in BossRush.ORDER:
		var boss_id := String(pair[0])
		check(w.room.id == String(pair[1]), "rush %d is %s's arena (%s)" % [n + 1, boss_id, w.room.id])
		check(BossRush.current_boss() == boss_id, "on %s" % boss_id)
		if n < 2:
			check(Music.track == BossRush.MUSIC, "%s's arena waits under the trials' theme (%s)" % [boss_id, Music.track])
		var arena: BossArena = w.get_tree().get_first_node_in_group("boss_arena")
		check(arena != null and arena.boss_id == boss_id, "%s's arena waits" % boss_id)
		if arena == null:
			break
		# Walk in from the door until the fight starts.
		var center := w.room.size_tiles.x * Room.TILE * 0.5
		for i in 300:
			if arena.fighting:
				break
			p.input.move_x = int(signf(center - p.global_position.x))
			p.input.jump_pressed = i % 40 == 0
			p.input.jump_held = i % 40 < 10
			await frames(1)
		p.input.clear()
		check(arena.fighting and arena.boss != null, "%s fights again" % boss_id)
		if not arena.fighting:
			break
		if n == 0:
			p.hp = 4
		if n == 0:
			check(Music.track != BossRush.MUSIC, "the boss brings its own music (%s)" % Music.track)
		Sfx.recent.clear()
		arena.boss.defeated.emit()
		await frames(5)
		if n < BossRush.ORDER.size() - 1:
			check(Sfx.recent.has("rush_mend") and Music.track == BossRush.MUSIC, "%s down: the bell mends you, the theme returns" % boss_id)
		else:
			check(Sfx.recent.has("rush_won") and Sfx.recent.has("trial_record"), "the last down: the bell rings the win, and a first rush is a best")
		if n == 0:
			check(p.hp == 4 + ceili(p.max_hp / 3.0) and p.mp == p.max_mp, "a third of your health and all your magic mended (%d)" % p.hp)
		n += 1
		await frames(int(BossRush.NEXT_DELAY * 60) + 10)
	check(n == BossRush.ORDER.size(), "all %d guardians fought (%d)" % [BossRush.ORDER.size(), n])
	check(not BossRush.active() and w.room.id == "test/a" and p.global_position.distance_to(back) < 4.0,
		"the rush won, the mantra carries you back to the Guru")
	check(GameState.data.flags == flags_before and GameState.data.rings == rings_before and p.gold == gold_before,
		"nothing is won again")
	check(int(GameState.data.get("clears", 0)) == 0, "and the Evil One's fall plays no ending")
	var best := BossRush.best()
	check(best > 1.0 and best < INF, "the best time is kept (%.1f s)" % best)
	check(Menus._rush_row().right == Trials.format_time(best), "and shown by the Guru")
	# A killing blow ends the rush and returns you whole.
	BossRush.start(w, p)
	await frames(5)
	p.hp = 2
	p._invuln_timer = 0.0
	Sfx.recent.clear()
	p.take_damage(5)
	check(Sfx.recent.has("rush_fall"), "a fall tolls the bell low")
	await frames(5)
	check(not BossRush.active() and not p.dead and p.hp == p.max_hp, "a killing blow ends the rush, and you live")
	check(w.room.id == "test/a", "back at the Guru")
	check(BossRush.best() == best, "a fallen rush keeps no time")
	w.queue_free()
	BossRush.abandon()


## Pass 158: the boss rush's edges. A fall while the mantra is mid-fade waits
## for the fade and then carries you back, once; the clock stops at the fall;
## no shrine on the way refills or saves you; no one stands in an arena; a
## world freed mid-rush leaves no timer behind; and a new game starts clean.
func test_the_boss_rush_holds_at_its_edges() -> void:
	var w := make_world(_temple(), "test/a", cell_feet(5, 16))
	var p := w.player
	await frames(5)
	for pair: Array in BossRush.ORDER:
		GameState.set_flag("boss:" + String(pair[0]))
	GameState.set_flag("lord")
	# No one stands in the fight: King Grieve's steward waits only outside a rush.
	w._enter("dartmoor/throne_hall")
	check(w.room.get_children().any(func(c: Node) -> bool: return c is Npc), "the steward stands in the throne hall after the king falls")
	BossRush.begin("test/a", cell_feet(5, 16))
	BossRush.run.index = 7
	w.travel_to_door("dartmoor/throne_hall", BossRush.ENTRY_DOOR)
	await frames(3)
	check(not w.room.get_children().any(func(c: Node) -> bool: return c is Npc), "but not in the rush's arena")
	# No rest on the way: the shrine by the Zenis gate neither refills nor saves.
	BossRush.run.index = 8
	BossRush.go(w)
	await frames(3)
	check(w.room.id == "dartmoor/zenis_gate", "on to the Zenis gate")
	var shrine: SaveShrine = null
	for c in w.room.get_children():
		if c is SaveShrine:
			shrine = c
	check(shrine != null, "whose shrine stands by the way in")
	p.hp = 3
	var saved_room = GameState.data.get("save_room", "")
	shrine.interact(p)
	check(p.hp == 3 and GameState.data.get("save_room", "") == saved_room, "the shrine allows no rest in the rush")
	# A fall while the world is mid-fade waits for it, and comes once.
	var banners := [0]
	var count := func(_a: String, _b: String) -> void: banners[0] += 1
	GameState.banner.connect(count)
	w.busy = true
	p._invuln_timer = 0.0
	p.take_damage(99)
	var at_fall := float(BossRush.run.time)
	p._invuln_timer = 0.0
	p.take_damage(99)
	check(not p.dead and BossRush.active(), "mid-fade the fall waits, and you live")
	await frames(30)
	check(is_equal_approx(float(BossRush.run.time), at_fall), "the clock stops at the fall")
	check(w.room.id == "dartmoor/zenis_gate", "nothing moves while the world is busy")
	w.busy = false
	await frames(12)
	check(not BossRush.active() and w.room.id == "test/a" and p.hp == p.max_hp, "once it settles, back to the Guru whole")
	check(banners[0] == 1, "and the rush ends once (%d banners)" % banners[0])
	GameState.banner.disconnect(count)
	# A world freed while the next arena is pending leaves nothing behind.
	BossRush.begin("test/a", cell_feet(5, 16))
	BossRush.on_boss_down(w, p)
	check(BossRush.active() and int(BossRush.run.index) == 1, "a boss down: on to the next")
	w.queue_free()
	await frames(int(BossRush.NEXT_DELAY * 60) + 10)
	check(true, "the pending move finds the world gone and does nothing")
	# A new game never starts in a rush.
	var w2 := make_world(_temple(), "test/a", cell_feet(5, 16))
	check(not BossRush.active() and not Trials.active(), "a new world starts clean")
	w2.queue_free()


## Pass 160: the Mantra of Winds, the fourth trial, opened with Thorns by the
## second spring and built for the Glove and the Wing Boots. Ride a current over
## the spikes, climb a wall into a second, take a double jump to a high plank,
## and drop out of the last current over the bell (ride it on and it throws you
## onto spikes). The mantra-space has no weather: its winds never turn.
func test_the_mantra_of_winds_is_ridden_climbed_and_let_go() -> void:
	var t := Trials.find("winds")
	check(Trials.built().has(t) and t.needs == ["glove", "boots"] and t.desc != "", "the Mantra of Winds is built, for the Glove and the Wing Boots")
	var text := FileAccess.get_file_as_string(World.room_path(t.room))
	var bell := Reach.key(t.room, 86, 11)
	for kit: Dictionary in [{"glove": true, "boots": true}, {"glove": true, "boots": true, "sky_spring": true}]:
		var reach := Reach.new({t.room: text}, kit)
		check(reach.reachable(reach.spot_of(t.room, "P")).has(bell), "the bell is reached with %s" % [kit.keys()])
	var bare := Reach.new({t.room: text}, {"glove": true})
	check(not bare.reachable(bare.spot_of(t.room, "P")).has(bell), "without the Wing Boots it is not")
	var calm_text := text.replace(">", ".")
	var calm := Reach.new({t.room: calm_text}, {"glove": true, "boots": true, "stride": true})
	check(not calm.reachable(calm.spot_of(t.room, "P")).has(bell), "and with no wind, not even with the Stride")
	# The Guru keeps it sealed, and says why, until the boots are found.
	GameState.new_game()
	GameState.set_flag("spring:trunk")
	GameState.set_flag("spring:mist")
	GameState.data.abilities["glove"] = true
	check(Trials.is_open(t) and not Trials.ready(t) and Trials.missing(t) == ["Wing Boots"], "two springs open it, but it wants the Wing Boots (%s)" % [Trials.missing(t)])
	GameState.data.abilities["boots"] = true
	check(Trials.ready(t), "and with them it is ready")
	# In the real game: the first current carries you over the spikes to the pillar.
	var w := make_world(_temple(), "test/a", cell_feet(5, 16))
	GameState.set_flag("spring:trunk")
	GameState.set_flag("spring:mist")
	GameState.set_flag("spring:sky")
	GameState.data.abilities["glove"] = true
	GameState.data.abilities["boots"] = true
	var p := w.player
	GameState.apply(p)
	await frames(5)
	Menus.start_trial(w, p, t)
	await frames(5)
	check(w.room.id == "trials/winds", "the Guru sends you there")
	var winds := w.room.get_children().filter(func(c: Node) -> bool: return c is WindCurrent)
	check(winds.size() == 3 and winds.all(func(c: WindCurrent) -> bool: return c.dir() == 1), "three currents, all blowing east even with the Spring of Sky restored")
	var landed := false
	# Run to the ledge's lip and jump into the current, then let it carry you.
	var jumped := -1
	for f in 300:
		var x := p.global_position.x / Room.TILE
		if jumped < 0 and x > 7.6:
			jumped = f
		p.input.move_x = 1 if jumped < 0 or f < jumped + 12 else 0
		p.input.jump_pressed = f == jumped
		p.input.jump_held = jumped >= 0 and f < jumped + 16
		await frames(1)
		if jumped >= 0 and f > jumped + 20 and p.is_on_floor():
			landed = true
			break
	var col := int(p.global_position.x / Room.TILE)
	check(landed and col >= 35 and col <= 39 and absf(p.global_position.y - (16 * Room.TILE)) < 2.0,
		"jump into the first current and it carries you over the spikes to the pillar (col %d, row %.1f)" % [col, p.global_position.y / Room.TILE])
	w.queue_free()
	Trials.abandon()


## Pass 162: the Mantra of Stillness, the fifth trial, opened by the third
## spring and built for the Glove and the Hour Glass. Still a fall and climb its
## footholds, cross a pit on a curtain of water that hangs from the void, and
## climb a long fall with a dry niche halfway to wait out the glass.
func test_the_mantra_of_stillness_is_climbed_in_frozen_moments() -> void:
	var t := Trials.find("stillness")
	check(Trials.built().has(t) and t.needs == ["glove", "hourglass"] and t.desc != "", "the Mantra of Stillness is built, for the Glove and the Hour Glass")
	var text := FileAccess.get_file_as_string(World.room_path(t.room))
	var bell := Reach.key(t.room, 68, 7)
	var reach := Reach.new({t.room: text}, {"glove": true, "hourglass": true})
	var nodes := reach.reachable(reach.spot_of(t.room, "P"))
	check(nodes.has(bell), "the bell is reached with the Glove and the Hour Glass")
	check(nodes.has(Reach.key(t.room, 50, 19)), "the dry niche halfway up the last fall is a place to wait")
	var bare := Reach.new({t.room: text}, {"glove": true, "boots": true, "stride": true, "mattock": true})
	check(not bare.reachable(bare.spot_of(t.room, "P")).has(Reach.key(t.room, 20, 38)), "without the glass not even the first ledge is in reach")
	GameState.new_game()
	for s: String in ["trunk", "mist", "sky"]:
		GameState.set_flag("spring:" + s)
	GameState.data.abilities["glove"] = true
	check(Trials.is_open(t) and Trials.missing(t) == ["Hour Glass"], "three springs open it, but it wants the Hour Glass (%s)" % [Trials.missing(t)])
	# In the real game: still the first fall and climb it to the ledge above.
	var w := make_world(_temple(), "test/a", cell_feet(5, 16))
	for s: String in ["trunk", "mist", "sky"]:
		GameState.set_flag("spring:" + s)
	GameState.data.abilities["glove"] = true
	GameState.data.abilities["hourglass"] = true
	var p := w.player
	GameState.apply(p)
	await frames(5)
	Menus.start_trial(w, p, t)
	await frames(5)
	check(w.room.id == "trials/stillness", "the Guru sends you there")
	var falls := w.room.get_children().filter(func(c: Node) -> bool: return c is Waterfall)
	check(falls.size() == 3, "three falls of time-locked water (%d)" % falls.size())
	for f in 120:
		p.input.move_x = 1 if p.global_position.x < 13.5 * Room.TILE else 0
		await frames(1)
	p.input.move_x = 0
	p.input.hourglass_pressed = true
	await frames(1)
	p.input.hourglass_pressed = false
	# A short hop from each foothold to the next, three rows up.
	var top := INF
	var hop := -100
	for f in 140:
		if p.is_on_floor() and f > hop + 3:
			hop = f
		p.input.jump_pressed = f == hop
		p.input.jump_held = f < hop + 15
		await frames(1)
		top = minf(top, p.global_position.y)
	p.input.jump_held = false
	check(top <= 40.0 * Room.TILE + 2.0, "jumping up the stilled fall reaches its top foothold (row %.1f)" % (top / Room.TILE))
	check(p.safe_position.y > 50.0 * Room.TILE, "a foothold of stilled water is never a footing to be set back to (row %.1f)" % (p.safe_position.y / Room.TILE))
	for f in 40:
		p.input.move_x = 1
		p.input.jump_pressed = f == 0
		p.input.jump_held = f < 10
		await frames(1)
	p.input.move_x = 0
	await frames(30)
	check(p.global_position.x > 15.0 * Room.TILE and absf(p.global_position.y - 39.0 * Room.TILE) < 2.0,
		"and steps off onto the ledge before time runs on (col %.1f, row %.1f)" % [p.global_position.x / Room.TILE, p.global_position.y / Room.TILE])
	w.queue_free()
	Trials.abandon()



## Pass 168 (bible 3.1): the sixth and last Guru Trial. A descent: ledges
## falling away over spikes, planks to drop through, and a needle of thorn bulbs
## to fall straight down. A bot that only steers its falls clears it.
func test_the_mantra_of_falling_is_steered_all_the_way_down() -> void:
	var t := Trials.find("falling")
	check(Trials.built().has(t) and t.desc != "" and not t.has("needs"), "the Mantra of Falling is built, for the Glove alone")
	check(Trials.built().size() == Trials.LIST.size(), "all six trials are built")
	var text := FileAccess.get_file_as_string(World.room_path(t.room))
	var reach := Reach.new({t.room: text}, {"glove": true})
	var nodes := reach.reachable(reach.spot_of(t.room, "P"))
	check(nodes.has(Reach.key(t.room, 21, 86)), "the checker falls to the bell")
	check(text.count("o") >= 6 and text.count("-") >= 24, "the needle has its thorns and the well its planks")
	var w := make_world(_temple(), "test/a", cell_feet(5, 16))
	for s: String in ["trunk", "mist", "sky"]:
		GameState.set_flag("spring:" + s)
	GameState.data.abilities["glove"] = true
	var p := w.player
	GameState.apply(p)
	await frames(5)
	check(Trials.ready(t), "three springs open it")
	Menus.start_trial(w, p, t)
	await frames(5)
	check(w.room.id == "trials/falling", "the Guru sends you there")
	# Waypoints: the column to stand on (or fall toward), and whether to drop
	# through the plank underfoot once there.
	var route := [[13, false], [8, false], [13, false], [19, false], [25, false], [34, true], [34, true], [34, true], [34, false], [21, false]]
	var step := 0
	# A waypoint counts only once you have been in the air since the last one.
	var flown := true
	var set_backs := 0
	var last := p.global_position
	var lowest := 0.0
	var goal: Node = w.room.get_children().filter(func(c: Node) -> bool: return c is TrialGoal)[0]
	for f in 1200:
		var target := (float(route[step][0]) + 0.5) * Room.TILE
		var dx := target - p.global_position.x
		p.input.move_x = 0 if absf(dx) < 3.0 else int(signf(dx))
		p.input.down = false
		p.input.jump_pressed = false
		p.input.jump_held = false
		if not p.is_on_floor():
			flown = true
		elif flown and absf(dx) < 4.0:
			flown = false
			if route[step][1]:
				p.input.down = true
				p.input.jump_pressed = true
				p.input.jump_held = true
			step = mini(step + 1, route.size() - 1)
		await frames(1)
		if p.global_position.y < last.y - 24.0:
			set_backs += 1
		last = p.global_position
		lowest = maxf(lowest, p.global_position.y)
		if goal.rung:
			break
	check(goal.rung, "the bot rings the bell (lowest row %.1f, waypoint %d)" % [lowest / Room.TILE, step])
	check(set_backs == 0, "without a single set-back (%d)" % set_backs)
	var best := Trials.best("falling")
	print("  Mantra of Falling: %.2f s" % best)
	check(best < float(t.mantra), "a clean run beats the mantra time (%.2f < %d)" % [best, t.mantra])
	check(best > float(t.mantra) * 0.5, "which still asks for a clean one")
	w.queue_free()
	Trials.abandon()


## Pass 164 (bible 10): the cosmetics the Guru Trials promise. Each trial has a
## mantra time; ring its bell within it and the trial dyes your cloak a color of
## its own, and Ilse keeps it on her shelf to wear again for nothing.
func test_a_trial_rung_within_its_mantra_dyes_the_cloak() -> void:
	var dyes := {}
	for t: Dictionary in Trials.built():
		check(float(t.get("mantra", 0)) > 0.0, "%s has a mantra time" % t.name)
		var item := GameData.item(String(t.get("dye", "")))
		check(String(item.get("kind", "")) == "dye" and String(item.get("color", "")) != "", "and a dye of its own (%s)" % t.get("dye", ""))
		dyes[String(t.dye)] = true
	check(dyes.size() == Trials.built().size(), "no two trials share a dye")
	var w := make_world(_temple(), "test/a", cell_feet(5, 16))
	var p := w.player
	await frames(2)
	var t := Trials.find("walls")
	var shop := "eolis_dyes"
	var index := -1
	var stock: Array = GameData.shop(shop).stock
	for i in stock.size():
		if String(stock[i].item) == String(t.dye):
			index = i
	check(index >= 0 and not Shop.shelf(shop).has(index), "Ilse keeps a place for it, off the shelf until it is earned")
	Trials.begin(t.id, "eolis/guru_temple", Vector2.ZERO)
	Trials.run.time = float(t.mantra) + 0.5
	var slow := Trials.finish()
	check(slow.dye == "" and not GameState.owns_dye(String(t.dye)), "a clear outside the mantra earns no dye")
	Trials.begin(t.id, "eolis/guru_temple", Vector2.ZERO)
	Trials.run.time = float(t.mantra) - 0.5
	var quick := Trials.finish()
	check(quick.dye == String(t.dye) and GameState.owns_dye(quick.dye) and GameState.dye() == quick.dye, "within it the cloak takes the trial's dye (%s)" % quick.dye)
	check(Shop.shelf(shop).has(index), "and it is on Ilse's shelf")
	PlayerVisual.body_sets = false  # the ranger's cloak takes dyes; the body sets have none yet
	await frames(2)
	check(not PlayerVisual.dye_look().is_empty() and p.visual.material != null, "the cloak is recolored")
	PlayerVisual.body_sets = true
	GameState.data.dye = ""
	check(Shop.status(shop, index, p) == "" and Shop.buy(shop, index, p) and GameState.dye() == String(t.dye), "Ilse puts it back on for nothing")
	Trials.begin(t.id, "eolis/guru_temple", Vector2.ZERO)
	Trials.run.time = 1.0
	check(Trials.finish().dye == "", "a second quick clear does not give it twice")
	var saved := GameState.sanitize(JSON.parse_string(JSON.stringify(GameState.data)))
	check(Array(saved.dyes).has(String(t.dye)), "the save keeps it")
	# The Guru's list names each mantra time and keeps the sealed ones sealed.
	GameState.set_flag("spring:trunk")
	p.abilities["glove"] = true
	GameState.data.abilities["glove"] = true
	var menu := ListMenu.new()
	arena.add_child(menu)
	check(Menus.open_trials(arena.get_tree(), p), "the trials list opens")
	var rows := {}
	for r: Dictionary in menu.rows:
		rows[String(r.label)] = r
	check(String(rows["Mantra of Walls"].detail).contains("Mantra Slate is yours"), "Walls says its dye is yours (%s)" % rows["Mantra of Walls"].detail)
	check(String(rows["Mantra of Edges"].detail).contains("Ring it within 0:14.0 for Ledge Coral"), "Edges names its mantra time and dye (%s)" % rows["Mantra of Edges"].detail)
	check(rows["Mantra of Stillness"].right == "Sealed" and not String(rows["Mantra of Stillness"].detail).contains("Ring it"), "a trial still sealed stays sealed, with no mantra yet")
	menu.queue_free()
	arena.get_tree().paused = false
	w.queue_free()
	Trials.abandon()


## Pass 165 (bible 13): a mantra dye won rings out with its own sound over the
## trial bell; a clear that earns none rings the bell alone.
func test_a_won_dye_sounds_over_the_bell() -> void:
	GameState.new_game()
	var heard := []
	for k in 2:
		Trials.begin("edges", Trials.TEMPLE, Vector2.ZERO)
		Trials.run.time = 1.0
		var goal := TrialGoal.new()
		arena.add_child(goal)
		Sfx.recent.clear()
		goal.ring(null)
		heard.append(Sfx.recent.duplicate())
		goal.queue_free()
	Trials.abandon()
	await frames(1)
	check(GameState.owns_dye("coral_dye"), "the quick clear won the dye")
	check(heard[0].has("trial_bell") and heard[0].has("dye_won"), "the first rings the bell and the dye (%s)" % [heard[0]])
	check(heard[1].has("trial_bell") and not heard[1].has("dye_won"), "a second rings the bell alone (%s)" % [heard[1]])


## Pass 172: the Journey page shows Completion's shares mid-game (the 100% goal
## gates the Lord's Gold and the Guru's rush) and the guardians found so far,
## never one whose arena you have not entered.
func test_the_journey_page_counts_the_world_and_the_guardians_found() -> void:
	var ids := Completion.GUARDIANS.map(func(g: Array) -> String: return g[0])
	check(ids.size() == BossArena.BOSSES.size() and BossArena.BOSSES.keys().all(func(k: String) -> bool: return ids.has(k)),
		"the Journey names every guardian the arena knows, once (%d of %d)" % [ids.size(), BossArena.BOSSES.size()])
	var w := make_world({}, "trunk/root_chamber")
	await frames(2)
	check(String(w.catalog["dartmoor/alpha_den"].boss) == "clockwork_alpha" and String(w.catalog["eolis/plaza"].get("boss", "")) == "",
		"the catalog knows which rooms are arenas")
	var found := Completion.guardians_found(w.catalog)
	check(found.size() == 1 and found[0].id == "rokusutahn" and not found[0].beaten, "standing in the Root Chamber, only Rokusutahn is found, still waiting")
	GameState.set_flag("boss:rokusutahn")
	w._enter("branches/thorn_yard")
	await frames(2)
	found = Completion.guardians_found(w.catalog)
	check(found.size() == 2 and found[0].beaten and found[1].id == "bark_captain", "a beaten guardian, then the Captain once his yard is entered, in climb order")
	var stats := Completion.tally(w.catalog)
	var rows := Completion.journey_rows(stats, found)
	check(rows[0].right == "%d%%" % int(stats.percent), "the page opens on the percent of the world")
	check(rows[4].label == "Guardians beaten" and rows[4].right == "1 / %d" % BossArena.BOSSES.size(), "and counts the guardians beaten (%s)" % rows[4].right)
	var names := rows.map(func(r: Dictionary) -> String: return r.label)
	check(names.has("Rokusutahn") and names.has("The Bark Knight Captain") and not names.has("Pakukame"), "it names the guardians found, and no other")
	check(rows[-1].label == "%d not yet found" % (BossArena.BOSSES.size() - 2), "and says how many are still to find (%s)" % rows[-1].label)
	var menu := ListMenu.new()
	arena.add_child(menu)
	check(Menus.open_journey(arena.get_tree(), func() -> void: pass), "the pause menu's Journey opens")
	check(menu.title == "Journey" and menu.rows.size() == rows.size(), "with those rows")
	for r: Dictionary in menu.rows:
		check(PixelFont.width(String(r.label), 9) < menu.panel.size.x * 0.7, "%s fits the panel" % r.label)
	menu.close()
	menu.queue_free()


## Pass 180: every Life Fruit and Mana Dew is counted, wherever it waits (the
## rooms, the four grocers, the guardians), and the totals are design bible 5.1's:
## 18 fruits (5 masks to 14) and 16 dews (60 MP to 220). The Journey page shows
## how many a save has taken, read from its health and magic, outside the percent.
func test_the_journey_counts_every_life_fruit_and_mana_dew() -> void:
	var w := make_world({}, "trunk/root_chamber")
	await frames(2)
	var s := Completion.stat_items(w.catalog)
	check(int(s.fruits_total) == 18 and int(s.dews_total) == 16, "18 Life Fruits and 16 Mana Dews in all, as the bible counts them (%d, %d)" % [s.fruits_total, s.dews_total])
	var in_rooms := [0, 0]
	for id: String in w.catalog:
		in_rooms[0] += int(w.catalog[id].fruits)
		in_rooms[1] += int(w.catalog[id].dews)
	check(in_rooms[0] == 13 and in_rooms[1] == 9, "13 fruits and 9 dews lie in the rooms (%d, %d)" % in_rooms)
	check(GameState.fresh().max_hp + 18 * GameState.LIFE_FRUIT_HP == 280 and GameState.fresh().max_mp + 16 * GameState.MANA_DEW_MP == 220.0,
		"all of them make 14 masks and 220 MP")
	check(int(s.fruits) == 0 and int(s.dews) == 0, "a new save has taken none")
	var before := Completion.tally(w.catalog)
	GameState.grant_stat_item("life_fruit", w.player)
	GameState.grant_stat_item("life_fruit", w.player)
	GameState.grant_stat_item("mana_dew", w.player)
	var after := Completion.tally(w.catalog)
	check(int(after.fruits) == 2 and int(after.dews) == 1, "two fruits and a dew are counted (%d, %d)" % [after.fruits, after.dews])
	check(int(after.percent) == int(before.percent), "and they stand outside the percent")
	var rows := Completion.journey_rows(after, [])
	check(rows[5].label == "Life Fruits" and rows[5].right == "2 / 18" and rows[6].label == "Mana Dew" and rows[6].right == "1 / 16",
		"the Journey page shows them (%s, %s)" % [rows[5].right, rows[6].right])
	GameState.new_game()
