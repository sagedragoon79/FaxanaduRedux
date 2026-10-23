extends Node2D
## Entry point: builds the pixel-art viewport, the World (rooms, player,
## camera) and the UI layer (HUD, dialog box, map, fades).
##
## The world renders into a SubViewport at 642x362 (one spare pixel per side),
## shown upscaled with nearest filtering and shifted by the camera's sub-pixel
## remainder, so scrolling is smooth while pixels stay crisp. The UI draws in
## the main viewport at native resolution.
##
## Command-line options after `--`:
## With no options it shows the title menu (continue or new game).
##   --room=ID|PATH             start a fresh game in a room: an id like "eolis/plaza",
##                              "gym/gym" for the movement gym, or a .room path
##   --continue                 load save slot 1 and skip the title
##   --shot=PATH                save a screenshot and quit
##   --shot-frames=N            frames to wait before the screenshot (default 30)
##   --shot-at=X,Y              place the player at tile X,Y first
##   --map                      open the map before the screenshot
##   --open=shop:ID|guru|skills open a menu before the screenshot
##   --gold=N                   start with N gold (for screenshots)
##   --flags=A,B                set world flags first, e.g. spring:trunk
##   --title                    with --shot: capture the title screen
##   --boss-hp=F                set a boss's health to fraction F when it appears

const NEW_GAME_ROOM := "eolis/west_gate"
const SAVE_SLOT := 1
const BASE_SIZE := Vector2i(640, 360)
const MARGIN := 1
## The title menu sits under the logo.
const TITLE_PANEL := Rect2(190, 156, 260, 178)

var view: SubViewport
var display: Sprite2D
var world: World
var hud: GameHud
var dialog: DialogBox
var map_screen: MapScreen
var menu: ListMenu
var title_screen: TitleScreen
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
	for arg in OS.get_cmdline_user_args():
		var kv := arg.trim_prefix("--").split("=", true, 1)
		_args[kv[0]] = kv[1] if kv.size() > 1 else ""

	view = SubViewport.new()
	view.size = BASE_SIZE + Vector2i(MARGIN, MARGIN) * 2
	view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	view.snap_2d_transforms_to_pixel = true
	view.snap_2d_vertices_to_pixel = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	view.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(view)

	display = Sprite2D.new()
	display.texture = view.get_texture()
	display.centered = false
	display.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	display.position = -Vector2(MARGIN, MARGIN)
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
			{"label": "Quit", "detail": ""},
		]
	var pick := func(i: int) -> void:
		menu.close()
		title_screen.visible = false
		menu.panel = ListMenu.PANEL
		match i:
			0:
				GameState.load_game(SAVE_SLOT)
				_continue()
			1:
				GameState.new_game()
				GameState.slot = SAVE_SLOT
				_start(NEW_GAME_ROOM)
				GameState.banner.emit("Eolis", "The root town")
			2:
				get_tree().quit()
	menu.open("A wanderer returns", "The World Tree's springs have run dry.", rows, pick)
	menu.cursor = 0 if has_save else 1


func _continue() -> void:
	var at := Vector2(float(GameState.data.save_pos[0]), float(GameState.data.save_pos[1]))
	_start(String(GameState.data.save_room), at)
	GameState.toast.emit("Welcome back. %s, rank %s." % [world.room.title, GameState.rank_name()])


## Builds the World in the viewport and hooks the UI to its player.
## Rooms under gym/ give every ability and keep no save data.
func _start(room_id: String, at := Vector2.INF) -> void:
	world = World.new()
	world.use_game_state = not room_id.begins_with("gym/")
	GameState.active = world.use_game_state
	view.add_child(world)
	world.build_catalog()
	world.view_size = Vector2(view.size)
	world.fader = fader
	world.start(room_id, at)
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
	if _frames == 2:
		_debug_open()
	if _args.has("boss-hp"):
		var boss := get_tree().get_first_node_in_group("boss") as Rokusutahn
		if boss != null and boss.state == "intro":
			boss.hp = roundi(Rokusutahn.MAX_HP * float(_args["boss-hp"]))
	_take_shot()


func _take_shot() -> void:
	if _args.has("shot") and _frames == int(_args.get("shot-frames", "30")):
		var img := get_viewport().get_texture().get_image()
		img.save_png(_args["shot"])
		get_tree().quit()


func _debug_open() -> void:
	if world == null:
		return
	if _args.has("gold"):
		player.gold = int(_args["gold"])
	if _args.has("map"):
		map_screen.toggle()
	var what: String = _args.get("open", "")
	if what.begins_with("shop:"):
		Menus.open_shop(get_tree(), what.trim_prefix("shop:"), player)
	elif what == "guru":
		Menus.open_guru(get_tree(), GameData.npc("guru").greeting, player, null)
	elif what == "skills":
		Menus.open_skills(get_tree(), player)


func _unhandled_input(event: InputEvent) -> void:
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


func _toggle(ability: String) -> void:
	player.abilities[ability] = not player.abilities[ability]
	Sfx.play("pogo" if player.abilities[ability] else "land")
