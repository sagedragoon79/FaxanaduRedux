class_name World
extends Node2D
## Owns the current room, the player and the camera, and moves the player
## between rooms through doors. Also handles saving at shrines, respawning at
## the last save, the dropped gold purse, and the room catalog the map reads.
##
## Doors are digits in a room's grid plus a `door: N, target/room, M` header
## line. Edge doors trigger when the player walks into them; inner doors
## (digits away from the edge) are used by pressing Up.

signal room_changed(room: Room)

const FADE_OUT := 0.12
const FADE_IN := 0.18
## How far inside the room the player lands when arriving through a side door.
const ARRIVE_INSET := 14.0
## Upward speed when arriving through a floor door from below.
const RISE_SPEED := -430.0
## Falling this far below the room without a door puts the player back on safe ground.
const FALL_RESCUE := 64.0

const ZONES := {
	"eolis": {"name": "Eolis", "color": Color("c9a25a")},
	"trunk": {"name": "Trunk Hollows", "color": Color("6fb0a0")},
	"gym": {"name": "Movement Gym", "color": Color("8d84a3")},
	"test": {"name": "Test Rooms", "color": Color("8d84a3")},
}

var room: Room
var player: Player
var camera: GameCamera
## Optional full-screen ColorRect (in the UI layer) used for fades.
var fader: ColorRect
## Skips fades so transitions finish within one frame (tests).
var instant := false
## When false the player keeps its own stats (the gym gives every ability).
var use_game_state := true
## Room id -> {name, zone, map: Vector2i, screens: Vector2i, size: Vector2i,
## doors: {n: {rect: Rect2i, edge, target, target_door}}, shrines: [Vector2i]}.
var catalog := {}
## Room id -> room text. Tests register rooms here instead of writing files.
var texts := {}
var start_room := ""
## Visible area in world pixels, passed to the camera for its bounds clamp.
var view_size := Vector2(640, 360)
var busy := false
var backdrop: Backdrop

var _ignored_door := 0


func _ready() -> void:
	add_to_group("world")
	backdrop = Backdrop.new()
	add_child(backdrop)


# --- Rooms -----------------------------------------------------------------------

func has_room(room_id: String) -> bool:
	return texts.has(room_id) or FileAccess.file_exists(room_path(room_id))


static func room_path(room_id: String) -> String:
	return "res://levels/%s.room" % room_id


func room_text(room_id: String) -> String:
	if texts.has(room_id):
		return texts[room_id]
	return FileAccess.get_file_as_string(room_path(room_id))


## Reads every room file under res://levels (except the gym) plus any rooms in
## `texts`, so the map knows each room's place, size and doors.
func build_catalog() -> void:
	catalog.clear()
	var dir := DirAccess.open("res://levels")
	if dir != null:
		for zone_dir in dir.get_directories():
			if zone_dir == "gym":
				continue
			var sub := DirAccess.open("res://levels/" + zone_dir)
			for file in sub.get_files():
				if file.ends_with(".room"):
					var room_id := zone_dir + "/" + file.trim_suffix(".room")
					_catalog_room(room_id, room_text(room_id))
	for room_id: String in texts:
		_catalog_room(room_id, texts[room_id])


func _catalog_room(room_id: String, text: String) -> void:
	var parsed := Room.parse(text)
	var header: Dictionary = parsed.header
	var grid: Array[String] = parsed.grid
	var width := 0
	for row in grid:
		width = maxi(width, row.length())
	var size := Vector2i(width, grid.size())
	var map := Vector2i.ZERO
	if header.has("map"):
		var xy: PackedStringArray = String(header.map).split(",")
		map = Vector2i(int(xy[0]), int(xy[1]))
	var found := Room.scan_doors(grid)
	var doors := {}
	for spec: String in parsed.lists.get("door", []):
		var parts := spec.split(",")
		var n := int(parts[0])
		if found.has(n) and parts.size() >= 3:
			doors[n] = {"rect": found[n].rect, "edge": found[n].edge, "target": parts[1].strip_edges(), "target_door": int(parts[2])}
	var shrines: Array[Vector2i] = []
	for y in grid.size():
		for x in grid[y].length():
			if grid[y][x] == "S":
				shrines.append(Vector2i(x, y))
	catalog[room_id] = {
		"name": header.get("name", room_id),
		"zone": header.get("zone", ""),
		"map": map,
		"size": size,
		"screens": Room.screens_for(size),
		"doors": doors,
		"shrines": shrines,
	}


# --- Starting and changing rooms ---------------------------------------------------

## Creates the player (if needed) and puts it in `room_id`, at `at` if given,
## otherwise at the room's spawn marker.
func start(room_id: String, at := Vector2.INF) -> void:
	start_room = room_id
	if player == null:
		player = Player.new()
		player.respawn_handler = _on_player_respawn
		player.died.connect(_on_player_died)
		_enter(room_id)
		if use_game_state:
			GameState.apply(player)
	else:
		_enter(room_id)
	var pos := room.spawn_position if at == Vector2.INF else at
	if at == Vector2.INF and room.spawn_position == Vector2.ZERO and not room.doors.is_empty():
		# No spawn marker: arrive as if through the room's first door.
		var first: int = room.doors.keys().min()
		_place_at_door(room.doors[first], Vector2.ZERO)
		pos = player.global_position
	player.teleport(pos)
	player.spawn_point = pos
	player.safe_position = pos
	if camera == null:
		camera = GameCamera.new()
		camera.target = player
		camera.view_size = view_size
		add_child(camera)
		camera.make_current()
	camera.set_room_limits(room.pixel_rect())
	camera.snap_to_target()


func _enter(room_id: String) -> void:
	var next := Room.from_text(room_text(room_id), room_id)
	if room != null:
		if player.get_parent() == room:
			room.remove_child(player)
		room.queue_free()
	room = next
	add_child(room)
	backdrop.set_zone(room.zone)
	Music.for_room(room)
	if player.get_parent() != null:
		player.get_parent().remove_child(player)
	room.add_child(player)
	for c in room.get_children():
		if c is GoldPurse:
			player.purse = c
	if use_game_state:
		GameState.visit(room_id)
	if camera != null:
		camera.set_room_limits(room.pixel_rect())
	room_changed.emit(room)


func _physics_process(_delta: float) -> void:
	if busy or player == null or room == null or player.dead or player.frozen:
		return
	player.in_sap = room.is_sap_at(player.global_position + Vector2(0, -6))
	if player.global_position.y > room.pixel_rect().end.y + FALL_RESCUE:
		player.teleport(player.safe_position)
		camera.snap_to_target()
		return
	var body := player.body_rect()
	var touching := 0
	for n: int in room.doors:
		var d: Dictionary = room.doors[n]
		if d.edge != "inner" and (d.rect as Rect2).intersects(body):
			touching = n
			break
	if touching == 0:
		_ignored_door = 0
	elif touching != _ignored_door:
		use_door(touching)


## Takes door `n` of the current room to its target room.
func use_door(n: int) -> void:
	if busy or not room.doors.has(n):
		return
	var d: Dictionary = room.doors[n]
	if not has_room(d.target):
		push_warning("Door %d in %s leads to missing room %s" % [n, room.id, d.target])
		return
	busy = true
	var vel := player.velocity
	player.frozen = true
	if fader != null and not instant:
		Sfx.play("door", 0.05, -8.0)
		await _fade(1.0, FADE_OUT)
	if use_game_state:
		GameState.capture(player)
	_enter(d.target)
	var arrive: Dictionary = room.doors.get(d.target_door, {})
	if arrive.is_empty():
		push_warning("Room %s has no door %d" % [room.id, d.target_door])
		player.teleport(room.spawn_position)
	else:
		_place_at_door(arrive, vel)
	_ignored_door = d.target_door
	camera.snap_to_target()
	player.frozen = false
	if fader != null and not instant:
		await _fade(0.0, FADE_IN)
	busy = false


func _place_at_door(door: Dictionary, vel: Vector2) -> void:
	var r: Rect2 = door.rect
	var pos := Vector2(r.get_center().x, r.end.y)
	match door.edge:
		"left":
			pos.x = r.end.x + ARRIVE_INSET
			player.facing = 1
			vel.y = minf(vel.y, 0.0)
		"right":
			pos.x = r.position.x - ARRIVE_INSET
			player.facing = -1
			vel.y = minf(vel.y, 0.0)
		"top":
			pos.y = r.end.y + 40.0
		"bottom":
			pos.y = r.position.y + 8.0
			vel.y = RISE_SPEED
		"inner":
			vel = Vector2.ZERO
	player.teleport(pos)
	player.velocity = vel
	if door.edge in ["left", "right", "inner"]:
		player.safe_position = pos


func _fade(to: float, time: float) -> void:
	var tw := create_tween()
	tw.tween_property(fader, "color:a", to, time)
	await tw.finished


# --- Saving and death --------------------------------------------------------------

## Called by a save shrine at `pos` in the current room.
func save_at(pos: Vector2) -> void:
	player.spawn_point = pos
	if not use_game_state:
		return
	GameState.capture(player)
	GameState.data.save_room = room.id
	GameState.data.save_pos = [pos.x, pos.y]
	GameState.save_game()


func _on_player_died() -> void:
	if not use_game_state:
		return
	if is_instance_valid(player.purse):
		var pos := player.purse.position
		GameState.data.purse = {"room": room.id, "x": pos.x, "y": pos.y, "value": player.purse.value}
	else:
		GameState.data.purse = {}
	GameState.capture(player)


func _on_player_respawn() -> void:
	player.frozen = true
	call_deferred("_respawn_player")


func _respawn_player() -> void:
	var target := start_room
	var pos := player.spawn_point
	if use_game_state:
		pos = Vector2.INF
		if String(GameState.data.save_room) != "":
			target = GameState.data.save_room
			pos = Vector2(float(GameState.data.save_pos[0]), float(GameState.data.save_pos[1]))
	if target != room.id:
		_enter(target)
	if pos == Vector2.INF:
		pos = room.spawn_position
	player.teleport(pos)
	player.safe_position = pos
	camera.snap_to_target()
	player.frozen = false
