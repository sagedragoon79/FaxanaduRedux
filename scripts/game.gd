extends Node2D
## Entry point: builds the pixel-art viewport, the World (rooms, player,
## camera) and the UI layer (HUD, dialog box, map, fades).
##
## The world renders into a SubViewport at 642x362 world pixels (one spare
## pixel per side) times GameCamera.DETAIL, shown upscaled with sharp
## bilinear filtering (shaders/sharp_pixels.gdshader) and shifted by the
## camera's sub-pixel remainder, so scrolling is smooth while pixels stay
## crisp. The UI draws in the main viewport at native resolution.
##
## Command-line options after `--`:
## With no options it shows the title menu (continue or new game).
##   --room=ID|PATH             start a fresh game in a room: an id like "eolis/plaza",
##                              "gym/gym" for the movement gym, or a .room path
##   --continue                 load save slot 1 and skip the title
##   --shot=PATH                save a screenshot and quit
##   --shot-frames=N            frames to wait before the screenshot (default 30)
##   --shot-at=X,Y              place the player at tile X,Y first
##   --shot-climb=1|-1          hold Up (1) or Down (-1) from the start, to climb a ladder
##   --map                      open the map before the screenshot
##   --say=NPC                  open the dialog box on that NPC's lines (data/npcs.json)
##   --open=shop:ID|guru|trials|title|skills|pause|options|controls|journey|equipment|inventory
##                              (title: the nearest Guru names your rank; pair with --xp)
##   --xp=N                     earn N experience first
##                              open a menu before the screenshot
##   --cursor=N                 with --open: put the menu's cursor on row N
##   --carry=A,B                carry rings (elf), keys (jack_key) and shards (potion_shard), for screenshots
##   --gold=N                   start with N gold (for screenshots)
##   --dye=ID                   wear a cloak dye (data/items.json, kind "dye")
##   --armor=ID                 wear an armor (data/items.json, kind "armor"), and its body set
##   --hp=N                     start with N health (for screenshots)
##   --ointments=N, --use-ointment   carry N Ointments, and rub one on
##   --reflect                  fling a Magic Shield shot of sap-light from in front of the player
##   --drops                    drop a loaf of bread, a mana orb, a poison flask, a War Glove and an Ointment ahead of the player
##   --coins                    lay a 1, 5, 25 and 100 gold coin ahead of the player (pass 199)
##   --glove                    wear a War Glove (a rare drop) from the start
##   --shot-thrust=N            thrust (the Blade skill) on frame N
##   --damage-numbers           show damage numbers (the option) for this run
##   --poisoned                 start poisoned
##   --flags=A,B                set world flags first, e.g. spring:trunk
##   --trial=ID[,SECONDS]       run that Guru Trial's clock from here (SECONDS on it), e.g. walls,12.3
##   --rush=N[,SECONDS]         be on boss N (from 0) of a boss rush begun at the Guru (SECONDS on its clock)
##   --title                    with --shot: capture the title screen
##   --boss-hp=F                set a boss's health to fraction F when it appears
##   --conduits=N               wake every conduit in the room at frame N (Borabohra's grounding)
##   --cast=SPELL               learn SPELL and cast it on frame 10 (e.g. fire)
##   --glide=FRAME              glide with Feather Fall from FRAME on, drifting right
##   --dash=FRAME               dash right on this frame (Elven Stride)
##   --ending=SECONDS[,PART]    play the ending on frame 2 and run it SECONDS in (PART:
##                              epilogue, credits or thanks to start there)
##   --secret                   with --ending: the secret ending (no deaths, the Battle Suit)

const NEW_GAME_ROOM := "eolis/west_gate"
const SAVE_SLOT := 1
const BASE_SIZE := Vector2i(640, 360)
const MARGIN := 1
## The title menu sits under the logo.
const TITLE_PANEL := Rect2(190, 140, 260, 212)

var view: SubViewport
var display: Sprite2D
var world: World
var hud: GameHud
var dialog: DialogBox
var map_screen: MapScreen
var menu: ListMenu
var title_screen: TitleScreen
var ending: EndingScreen
var fader: ColorRect
var debug_hud: DebugHud

var room: Room:
	get: return world.room if world else null
var player: Player:
	get: return world.player if world else null
var camera: GameCamera:
	get: return world.camera if world else null

var _args := {}
var _frames := 0


func _ready() -> void:
	# The game node keeps running while paused (map, menus); the world does not.
	process_mode = Node.PROCESS_MODE_ALWAYS
	Settings.load_settings()
	Settings.apply()
	for arg in OS.get_cmdline_user_args():
		var kv := arg.trim_prefix("--").split("=", true, 1)
		_args[kv[0]] = kv[1] if kv.size() > 1 else ""
	if _args.has("damage-numbers"):
		Settings.damage_numbers = true

	view = SubViewport.new()
	view.size = (BASE_SIZE + Vector2i(MARGIN, MARGIN) * 2) * GameCamera.DETAIL
	view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	view.snap_2d_transforms_to_pixel = true
	view.snap_2d_vertices_to_pixel = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	view.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(view)

	display = Sprite2D.new()
	display.texture = view.get_texture()
	display.centered = false
	display.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var sharp := ShaderMaterial.new()
	sharp.shader = load("res://shaders/sharp_pixels.gdshader")
	display.material = sharp
	display.position = -Vector2(MARGIN, MARGIN)
	display.scale = Vector2.ONE / GameCamera.DETAIL
	add_child(display)

	var ui := CanvasLayer.new()
	ui.layer = 5
	add_child(ui)
	hud = GameHud.new()
	ui.add_child(hud)
	dialog = DialogBox.new()
	ui.add_child(dialog)
	title_screen = TitleScreen.new()
	title_screen.visible = false
	ui.add_child(title_screen)
	menu = ListMenu.new()
	ui.add_child(menu)
	map_screen = MapScreen.new()
	ui.add_child(map_screen)
	ending = EndingScreen.new()
	ending.visible = false
	ending.finished.connect(_end_of_ending)
	ui.add_child(ending)
	GameState.ending_started.connect(_play_ending)
	fader = ColorRect.new()
	fader.color = Color(0.07, 0.06, 0.11, 0.0)
	fader.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fader.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.add_child(fader)

	PlayerVisual.forced = _args.get("shot-pose", "")
	if _args.has("room"):
		var room_id: String = _args["room"]
		if room_id.begins_with("res://"):
			room_id = room_id.trim_prefix("res://levels/").trim_suffix(".room")
		var at := Vector2.INF
		if _args.has("shot-at"):
			var xy: PackedStringArray = _args["shot-at"].split(",")
			at = Vector2(int(xy[0]) * Room.TILE + 8, int(xy[1]) * Room.TILE + 16)
		GameState.new_game()
		for flag: String in String(_args.get("flags", "")).split(",", false):
			GameState.set_flag(flag)
		_start(room_id, at)
	elif _args.has("continue") and GameState.load_game(SAVE_SLOT):
		_continue()
	elif _args.has("shot") and not _args.has("title"):
		GameState.new_game()
		_start(NEW_GAME_ROOM)
	else:
		_title()


## Title menu: continue the save in slot 1, or start over.
func _title() -> void:
	var has_save := GameState.has_save(SAVE_SLOT)
	title_screen.visible = true
	menu.panel = TITLE_PANEL
	Music.play("title")
	var rows := func() -> Array:
		return [
			{"label": "Continue", "enabled": has_save, "detail": "Return to your last rest." if has_save else "No journey saved yet."},
			{"label": "New game", "detail": "Begin at the West Gate of Eolis." + ("  Your old save is replaced when you next rest." if has_save else "")},
			{"label": "Options", "detail": "Screen shake, flashes, rumble, volume and game speed."},
			{"label": "Controls", "detail": "Rebind the keyboard."},
			{"label": "Quit", "detail": ""},
		]
	var pick := func(i: int) -> void:
		if i == 2:
			Menus.open_options(get_tree(), _title)
			return
		if i == 3:
			Menus.open_controls(get_tree(), _title)
			return
		menu.close()
		title_screen.visible = false
		menu.panel = ListMenu.PANEL
		match i:
			0:
				if GameState.load_game(SAVE_SLOT):
					_continue()
				else:
					# Nothing in the slot could be read (pass 109): start over rather than fail.
					GameState.new_game()
					GameState.slot = SAVE_SLOT
					_start(NEW_GAME_ROOM)
					GameState.toast.emit("The old journey could not be read. A new one begins.")
			1:
				GameState.new_game()
				GameState.slot = SAVE_SLOT
				_start(NEW_GAME_ROOM)
				GameState.banner.emit("Eolis", "The root town")
			4:
				get_tree().quit()
	menu.open("A wanderer returns", "The World Tree's springs have run dry.", rows, pick)
	menu.cursor = 0 if has_save else 1


func _continue() -> void:
	var at := Vector2(float(GameState.data.save_pos[0]), float(GameState.data.save_pos[1]))
	var room := String(GameState.data.save_room)
	if not World.room_exists(room):
		# A rest in a room this build doesn't have: wake at the new-game spot.
		room = NEW_GAME_ROOM
		at = Vector2.INF
	_start(room, at)
	GameState.toast.emit("Welcome back. %s, rank %s." % [world.room.title, GameState.rank_name()])


## Builds the World in the viewport and hooks the UI to its player.
## Rooms under gym/ give every ability and keep no save data.
func _start(room_id: String, at := Vector2.INF) -> void:
	world = World.new()
	world.use_game_state = not room_id.begins_with("gym/")
	GameState.active = world.use_game_state
	view.add_child(world)
	world.build_catalog()
	world.view_size = Vector2(view.size) / GameCamera.DETAIL
	world.fader = fader
	world.start(room_id, at)
	if _args.has("shot-move"):
		# Screenshots: hold a direction from the start (e.g. to catch a room transition).
		world.player.input.scripted = true
		world.player.input.move_x = int(_args["shot-move"])
	if _args.has("shot-climb"):
		# Screenshots: hold Up (1) or Down (-1) from the start, to climb a ladder.
		world.player.input.scripted = true
		world.player.input.up = int(_args["shot-climb"]) > 0
		world.player.input.down = int(_args["shot-climb"]) < 0
	hud.player = player
	map_screen.world = world
	debug_hud = DebugHud.new()
	debug_hud.player = player
	debug_hud.visible = not world.use_game_state
	add_child(debug_hud)


func _process(_delta: float) -> void:
	_frames += 1
	if camera == null:
		_take_shot()
		return
	# Shift the upscaled world by the camera's fractional position.
	display.position = (-Vector2(MARGIN, MARGIN) - camera.subpixel)
	if _args.has("ending") and _frames == 2:
		var parts: PackedStringArray = String(_args["ending"]).split(",")
		if _args.has("secret"):
			GameState.data.equipment.armor = "battle_suit"
			GameState.data.deaths = 0
		GameState.begin_ending()
		if parts.size() > 1 and parts[1] == "thanks":
			ending.skip()
		elif parts.size() > 1 and parts[1] == "credits":
			ending._to("credits")
		ending.tick(float(parts[0]))
	if _args.has("cast") and _frames == 10:
		var spell := String(_args["cast"])
		player.abilities[spell] = true
		player.equipped_spell = spell
		player.mp = player.max_mp
		player.input.scripted = true
		player.input.spell_pressed = true
	if _args.has("give") and _frames == 2:
		# Screenshots: hand the player abilities (e.g. --give=onyx,glove).
		for a: String in String(_args["give"]).split(","):
			player.abilities[a] = true
	if _args.has("carry") and _frames == 2:
		# Screenshots: rings, keys and shards (e.g. --carry=elf,ruby,jack_key,jack_key,potion_shard).
		for c: String in String(_args["carry"]).split(","):
			if c.ends_with("_key"):
				GameState.add_key(c.trim_suffix("_key"))
			elif c.ends_with("_shard"):
				GameState.data[c + "s"] = int(GameState.data[c + "s"]) + 1
			elif not Array(GameState.data.rings).has(c):
				GameState.data.rings.append(c)
	if _args.has("equip") and _frames == 2:
		# Screenshots: equip gear (e.g. --equip=dwarvish_broad_sword,magic_shield).
		for id: String in String(_args["equip"]).split(","):
			GameState.obtain_gear(id, player)
		if menu.is_open:
			menu.refresh()
	if _args.has("dye") and _frames == 2:
		# Screenshots: wear a cloak dye (e.g. --dye=lord_dye).
		GameState.data.dye = String(_args["dye"])
	if _args.has("armor") and _frames == 2:
		# Screenshots: wear an armor (e.g. --armor=full_plate).
		GameState.data.equipment.armor = String(_args["armor"])
		GameState.refresh_stats(world.player)
	if _args.has("skills") and _frames == 2:
		# Screenshots: learn skills (e.g. --skills=tilte_swarm).
		for id: String in String(_args["skills"]).split(","):
			GameState.data.skills.append(id)
		GameState.refresh_stats(player)
	if _frames == 2:
		_debug_open()  # after the gear, finds and skills above, so a menu shows them
	if _args.has("glide") and _frames >= int(_args["glide"]):
		# Screenshots: glide from this frame on (Feather Fall, double jump spent).
		player.feather_fall = true
		player.abilities["boots"] = true
		player.has_double_jump = false
		player.input.scripted = true
		player.input.jump_held = true
		player.input.move_x = 1
	if _args.has("dash") and _frames == int(_args["dash"]):
		# Screenshots: dash right on this frame.
		player.abilities["stride"] = true
		player.input.scripted = true
		player.input.move_x = 1
		player.input.dash_pressed = true
	if _args.has("swing") and _frames == int(_args["swing"]):
		# Screenshots: swing the blade on this frame.
		player.input.scripted = true
		player.input.attack_pressed = true
	if _args.has("timestop") and _frames == int(_args["timestop"]):
		TimeStop.start()
	if _args.has("conduits") and _frames == int(_args["conduits"]):
		for c in get_tree().get_nodes_in_group("conductor"):
			(c as Conduit).power()
	if _args.has("fill-tanks") and _frames == 2:
		# Screenshots: fill the room's first N dry tanks, west to east.
		var tanks := get_tree().get_nodes_in_group("dry_basin")
		tanks.sort_custom(func(a: DryBasin, b: DryBasin) -> bool: return a.x0 < b.x0)
		for i in mini(int(_args["fill-tanks"]), tanks.size()):
			(tanks[i] as DryBasin).douse()
	if _args.has("boss-hp"):
		var boss := get_tree().get_first_node_in_group("boss")
		if boss is Rokusutahn and boss.state == "intro":
			boss.hp = roundi(Rokusutahn.MAX_HP * float(_args["boss-hp"]))
		elif boss is Zoradohna and boss.state == "intro":
			boss.set_health_fraction(float(_args["boss-hp"]))
		elif boss is Zorugeriru and boss.state == "intro" and boss.hp == Zorugeriru.MAX_HP:
			boss.hp = roundi(Zorugeriru.MAX_HP * float(_args["boss-hp"]))
			boss._check_phase()
			boss._check_phase()
		elif boss is Borabohra and boss.state == "intro" and boss.hp == Borabohra.MAX_HP:
			boss.hp = roundi(Borabohra.MAX_HP * float(_args["boss-hp"]))
			boss._check_phase()
		elif boss is KingGrieve and boss.state == "intro" and boss.hp == KingGrieve.MAX_HP:
			boss.hp = roundi(KingGrieve.MAX_HP * float(_args["boss-hp"]))
			if boss.health_fraction() <= KingGrieve.PHASES[1]:
				boss.phase = 3
			elif boss.health_fraction() <= KingGrieve.PHASES[0]:
				boss.phase = 2
			boss._check_phase()
		elif boss is ShadowEura and boss.state == "intro" and boss.hp == ShadowEura.MAX_HP:
			boss.hp = roundi(ShadowEura.MAX_HP * float(_args["boss-hp"]))
			if boss.health_fraction() <= ShadowEura.PHASES[0]:
				boss._break_free()
			if boss.health_fraction() <= ShadowEura.PHASES[1]:
				boss.phase = 3
				boss._split()
		elif boss is Pakukame and boss.state == "intro" and boss.hp == Pakukame.MAX_HP:
			boss.hp = roundi(Pakukame.MAX_HP * float(_args["boss-hp"]))
			if boss.health_fraction() <= Pakukame.PHASES[1]:
				boss.phase = 3
			elif boss.health_fraction() <= Pakukame.PHASES[0]:
				boss.phase = 2
	_check_pause()
	_take_shot()


## The Evil One is dead: freeze the world and play the ending over it.
func _play_ending() -> void:
	get_tree().paused = true
	menu.close()
	hud.visible = false
	Music.play("ending", 2.0)
	ending.start(GameState.rank_name(), GameState.total_play_time(), GameState.secret_ending(), int(GameState.data.get("deaths", 0)),
		_completion())


## The completion card's numbers: the world's tally, plus the clears so far.
func _completion() -> Dictionary:
	if world == null:
		return {}
	var c := Completion.tally(world.catalog)
	c.clears = int(GameState.data.get("clears", 0))
	Completion.award(c)
	return c


## The ending is over: keep the cleared save and go back to the title.
func _end_of_ending() -> void:
	if world != null and world.use_game_state:
		GameState.save_game()
	if world != null:
		world.queue_free()
		world = null
	if debug_hud != null:
		debug_hud.queue_free()
		debug_hud = null
	hud.player = null
	hud.visible = true
	map_screen.world = null
	get_tree().paused = false
	_title()


## Pause opens the pause menu during play, unless another screen is up or the
## press just closed one.
func _check_pause() -> void:
	if not Input.is_action_just_pressed("pause") or player == null or player.dead or ending.visible:
		return
	if menu.is_open or menu.closed_frame == Engine.get_process_frames() or map_screen.is_open or map_screen.closed_frame == Engine.get_process_frames() or dialog.is_open:
		return
	Menus.open_pause(get_tree(), player, func() -> void: get_tree().quit())


func _take_shot() -> void:
	if _args.has("shot-kill") and _frames == int(_args["shot-kill"]):
		# Screenshots: strike down every foe in the room on this frame (to catch the dissolve).
		for e in get_tree().get_nodes_in_group("enemy"):
			if e is Enemy and not e.is_in_group("boss") and not e.dead:
				(e as Enemy).take_hit(9999, Vector2.RIGHT)
	if _args.has("shot-thrust") and _frames == int(_args["shot-thrust"]):
		# Screenshots: a Thrust from the floor on this frame (to catch the lunge).
		player.thrust = true
		player._thrust(player.is_on_floor())
	if _args.has("shot-throw") and _frames == int(_args["shot-throw"]):
		# Screenshots: throw the Rune Dagger on this frame (to catch it in flight).
		player.throw_dagger()
	if _args.has("shot") and _frames == int(_args.get("shot-frames", "30")):
		var img := get_viewport().get_texture().get_image()
		img.save_png(_args["shot"])
		get_tree().quit()


func _debug_open() -> void:
	if world == null:
		return
	if _args.has("gold"):
		player.gold = int(_args["gold"])
	if _args.has("hp"):
		player.hp = int(_args["hp"])
	if _args.has("ointments"):
		player.ointments = int(_args["ointments"])
	if _args.has("use-ointment"):
		player.use_ointment()
	if _args.has("drops"):
		for i in 5:
			var d := Drop.new()
			d.kind = ["bread", "mana", "poison", "glove", "ointment"][i]
			d.velocity = Vector2(0, 1)
			world.room.add_child(d)
			d.global_position = player.global_position + Vector2(36 + i * 24, -8)
	if _args.has("coins"):
		for i in 4:
			var c := Coin.new()
			c.value = [1, 5, 25, 100][i]
			c.velocity = Vector2(0, 1)
			world.room.add_child(c)
			c.global_position = player.global_position + Vector2(140 + i * 16, -8)
	if _args.has("glove"):
		player.put_on_glove()
	if _args.has("reflect"):
		var src := Node2D.new()
		world.room.add_child(src)
		src.global_position = player.global_position + Vector2(player.facing * 14, -22)
		ReflectedShot.spawn(player, src, SapGlob.SAP)
		src.queue_free()
	if _args.has("xp"):
		GameState.add_xp(int(_args["xp"]))
	if _args.has("poisoned"):
		player.poison()
	for zone: String in String(_args.get("charts", "")).split(",", false):
		GameState.data.charts[zone] = true
	if _args.has("pin"):
		GameState.toggle_pin(world.room.id, player.global_position)
	if _args.has("map"):
		map_screen.toggle()
	if _args.has("say"):
		var npc: Dictionary = GameData.npc(_args["say"])
		GameState.say(npc.get("name", ""), Npc.lines(npc, "lines") if npc.has("lines") else [npc.get("greeting", "")])
	if _args.has("trial"):
		var spec := String(_args["trial"]).split(",")
		Trials.begin(spec[0], Trials.TEMPLE, Vector2(22 * Room.TILE, 20 * Room.TILE))
		if spec.size() > 1:
			Trials.run.time = float(spec[1])
	if _args.has("rush"):
		var spec := String(_args["rush"]).split(",")
		BossRush.begin(Trials.TEMPLE, Vector2(22 * Room.TILE, 20 * Room.TILE))
		BossRush.run.index = int(spec[0])
		if spec.size() > 1:
			BossRush.run.time = float(spec[1])
	var what: String = _args.get("open", "")
	if what.begins_with("shop:"):
		Menus.open_shop(get_tree(), what.trim_prefix("shop:"), player)
	elif what == "trials":
		Menus.open_trials(get_tree(), player)
	elif what == "guru":
		Menus.open_guru(get_tree(), GameData.npc("guru").greeting, player, null)
	elif what == "title":
		for n in get_tree().get_nodes_in_group("interactable"):
			if n is Npc and n.info.get("role", "") == "guru":
				n.interact(player)
				break
	elif what == "skills":
		Menus.open_skills(get_tree(), player)
	elif what == "pause":
		Menus.open_pause(get_tree(), player, func() -> void: pass)
	elif what == "options":
		Menus.open_options(get_tree(), func() -> void: pass)
	elif what == "controls":
		Menus.open_controls(get_tree(), func() -> void: pass)
	elif what == "journey":
		Menus.open_journey(get_tree(), func() -> void: pass)
	elif what == "equipment":
		Menus.open_equipment(get_tree(), player, func() -> void: pass)
	elif what == "inventory":
		Menus.open_inventory(get_tree(), player, func() -> void: pass)
	var menu := get_tree().get_first_node_in_group("list_menu") as ListMenu
	if _args.has("cursor") and menu != null:
		menu.cursor = int(_args["cursor"])


func _unhandled_input(event: InputEvent) -> void:
	if is_fullscreen_toggle(event):
		toggle_fullscreen()
		get_viewport().set_input_as_handled()
		return
	if world == null or not OS.is_debug_build():
		return
	if event.is_action_pressed("debug_glove"):
		_toggle("glove")
	elif event.is_action_pressed("debug_mattock"):
		_toggle("mattock")
	elif event.is_action_pressed("debug_boots"):
		_toggle("boots")
	elif event.is_action_pressed("debug_stride"):
		_toggle("stride")
	elif event.is_action_pressed("debug_deluge"):
		_toggle("deluge")
	elif event.is_action_pressed("debug_reset"):
		player.hp = player.max_hp
		player.mp = player.max_mp
		player.flask_charges = player.flask_max
		player.teleport(room.spawn_position)
		camera.snap_to_target()
	elif event.is_action_pressed("debug_hud"):
		debug_hud.visible = not debug_hud.visible


## F11 or Alt+Enter switches between a window and fullscreen.
static func is_fullscreen_toggle(event: InputEvent) -> bool:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return false
	return key.physical_keycode == KEY_F11 or (key.physical_keycode == KEY_ENTER and key.alt_pressed)


static func toggle_fullscreen() -> void:
	var full := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if full else DisplayServer.WINDOW_MODE_FULLSCREEN)


func _toggle(ability: String) -> void:
	player.abilities[ability] = not player.abilities[ability]
	Sfx.play("pogo" if player.abilities[ability] else "land")
