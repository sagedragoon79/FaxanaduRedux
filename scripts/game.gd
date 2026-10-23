extends Node2D
## Prototype entry point: loads a room, spawns the player, camera and HUD.
##
## The world renders into a SubViewport at 642x362 (one spare pixel per side),
## shown upscaled with nearest filtering and shifted by the camera's sub-pixel
## remainder, so scrolling is smooth while pixels stay crisp. The HUD draws in
## the main viewport at native resolution.
##
## Command-line options after `--`:
##   --room=res://levels/...    room file to load
##   --shot=PATH                save a screenshot and quit
##   --shot-frames=N            frames to wait before the screenshot (default 30)
##   --shot-at=X,Y              place the player at tile X,Y first

const DEFAULT_ROOM := "res://levels/gym/gym.room"
const BASE_SIZE := Vector2i(640, 360)
const MARGIN := 1

var view: SubViewport
var display: Sprite2D
var room: Room
var player: Player
var camera: GameCamera
var hud: GameHud
var debug_hud: DebugHud

var _args := {}
var _frames := 0


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		var kv := arg.trim_prefix("--").split("=", true, 1)
		_args[kv[0]] = kv[1] if kv.size() > 1 else ""

	view = SubViewport.new()
	view.size = BASE_SIZE + Vector2i(MARGIN, MARGIN) * 2
	view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	view.snap_2d_transforms_to_pixel = true
	view.snap_2d_vertices_to_pixel = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(view)

	display = Sprite2D.new()
	display.texture = view.get_texture()
	display.centered = false
	display.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	display.position = -Vector2(MARGIN, MARGIN)
	add_child(display)

	room = Room.from_file(_args.get("room", DEFAULT_ROOM))
	view.add_child(room)

	player = Player.new()
	player.position = room.spawn_position
	if _args.has("shot-at"):
		var xy: PackedStringArray = _args["shot-at"].split(",")
		player.position = Vector2(int(xy[0]) * Room.TILE + 8, int(xy[1]) * Room.TILE + 16)
	room.add_child(player)
	player.spawn_point = room.spawn_position

	camera = GameCamera.new()
	camera.target = player
	camera.view_size = Vector2(view.size)
	camera.set_room_limits(room.pixel_rect())
	view.add_child(camera)
	camera.make_current()

	var ui := CanvasLayer.new()
	ui.layer = 5
	add_child(ui)
	hud = GameHud.new()
	hud.player = player
	ui.add_child(hud)

	debug_hud = DebugHud.new()
	debug_hud.player = player
	add_child(debug_hud)


func _process(_delta: float) -> void:
	# Shift the upscaled world by the camera's fractional position.
	display.position = (-Vector2(MARGIN, MARGIN) - camera.subpixel)
	_frames += 1
	if _args.has("shot") and _frames == int(_args.get("shot-frames", "30")):
		var img := get_viewport().get_texture().get_image()
		img.save_png(_args["shot"])
		get_tree().quit()


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
		player.mp = player.combat.max_mp
		player.flask_charges = player.combat.flask_charges
		player.teleport(room.spawn_position)
		camera.snap_to_target()
	elif event.is_action_pressed("debug_hud"):
		debug_hud.visible = not debug_hud.visible


func _toggle(ability: String) -> void:
	player.abilities[ability] = not player.abilities[ability]
	Sfx.play("pogo" if player.abilities[ability] else "land")
