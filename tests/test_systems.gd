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
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SETTINGS))


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

