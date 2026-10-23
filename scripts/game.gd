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
##   --room=ID|PATH             room to load: an id like "eolis/gate" or a .room path
##   --shot=PATH                save a screenshot and quit
##   --shot-frames=N            frames to wait before the screenshot (default 30)
##   --shot-at=X,Y              place the player at tile X,Y first
##   --map                      open the map before the screenshot
##   --open=shop:ID|guru|skills open a menu before the screenshot
##   --gold=N                   start with N gold (for screenshots)

const DEFAULT_ROOM := "gym/gym"
const BASE_SIZE := Vector2i(640, 360)
const MARGIN := 1

var view: SubViewport
var display: Sprite2D
var world: World
var hud: GameHud
var dialog: DialogBox
var map_screen: MapScreen
var menu: ListMenu
var fader: ColorRect
var debug_hud: DebugHud

var room: Room:
	get: return world.room
var player: Player:
	get: return world.player
var camera: GameCamera:
	get: return world.camera

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

	var room_id: String = _args.get("room", DEFAULT_ROOM)
	if room_id.begins_with("res://"):
		room_id = room_id.trim_prefix("res://levels/").trim_suffix(".room")

	world = World.new()
	# The gym gives every ability and keeps no save data.
	world.use_game_state = not room_id.begins_with("gym/")
	GameState.active = world.use_game_state
	view.add_child(world)
	world.build_catalog()
	if world.use_game_state:
		GameState.new_game()
	var at := Vector2.INF
	if _args.has("shot-at"):
		var xy: PackedStringArray = _args["shot-at"].split(",")
		at = Vector2(int(xy[0]) * Room.TILE + 8, int(xy[1]) * Room.TILE + 16)
	world.view_size = Vector2(view.size)
	world.start(room_id, at)

	var ui := CanvasLayer.new()
	ui.layer = 5
	add_child(ui)
	hud = GameHud.new()
	hud.player = player
	ui.add_child(hud)
	dialog = DialogBox.new()
	ui.add_child(dialog)
	menu = ListMenu.new()
	ui.add_child(menu)
	map_screen = MapScreen.new()
	map_screen.world = world
	ui.add_child(map_screen)
	fader = ColorRect.new()
	fader.color = Color(0.07, 0.06, 0.11, 0.0)
	fader.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fader.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.add_child(fader)
	world.fader = fader

	debug_hud = DebugHud.new()
	debug_hud.player = player
	debug_hud.visible = not world.use_game_state
	add_child(debug_hud)


func _process(_delta: float) -> void:
	if camera == null:
		return
	# Shift the upscaled world by the camera's fractional position.
	display.position = (-Vector2(MARGIN, MARGIN) - camera.subpixel)
	_frames += 1
	if _frames == 2:
		_debug_open()
	if _args.has("shot") and _frames == int(_args.get("shot-frames", "30")):
		var img := get_viewport().get_texture().get_image()
		img.save_png(_args["shot"])
		get_tree().quit()


func _debug_open() -> void:
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
