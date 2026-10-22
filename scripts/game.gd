extends Node2D
## Prototype entry point: loads the movement gym, spawns the player and camera.
## Command-line options after `--`:
##   --room=res://levels/...    room file to load
##   --shot=PATH                save a screenshot and quit
##   --shot-frames=N            frames to wait before the screenshot (default 30)
##   --shot-at=X,Y              place the player at tile X,Y first

const DEFAULT_ROOM := "res://levels/gym/gym.room"

var room: Room
var player: Player
var camera: GameCamera
var hud: DebugHud

var _args := {}
var _frames := 0


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		var kv := arg.trim_prefix("--").split("=", true, 1)
		_args[kv[0]] = kv[1] if kv.size() > 1 else ""

	room = Room.from_file(_args.get("room", DEFAULT_ROOM))
	add_child(room)

	player = Player.new()
	player.position = room.spawn_position
	if _args.has("shot-at"):
		var xy: PackedStringArray = _args["shot-at"].split(",")
		player.position = Vector2(int(xy[0]) * Room.TILE + 8, int(xy[1]) * Room.TILE + 16)
	room.add_child(player)
	player.spawn_point = room.spawn_position

	camera = GameCamera.new()
	camera.target = player
	camera.set_room_limits(room.pixel_rect())
	add_child(camera)
	camera.make_current()

	hud = DebugHud.new()
	hud.player = player
	add_child(hud)


func _process(_delta: float) -> void:
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
	elif event.is_action_pressed("debug_reset"):
		player.hp = player.max_hp
		player.teleport(room.spawn_position)
		camera.snap_to_target()
	elif event.is_action_pressed("debug_hud"):
		hud.visible = not hud.visible


func _toggle(ability: String) -> void:
	player.abilities[ability] = not player.abilities[ability]
	Sfx.play("pogo" if player.abilities[ability] else "land")
