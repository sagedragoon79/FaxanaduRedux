class_name Room
extends Node2D
## A room built from a text file: a header of `key: value` lines, a `---`
## separator, then an ASCII tile grid. See levels/README.md for the legend.

const TILE := TilesetFactory.TILE
## One screen in tiles (640x360 px). Map cells and room sizes count in screens.
const SCREEN_TILES := Vector2(40, 22.5)
const DOOR_CHARS := "123456789"

## Room id: its path under res://levels without the extension, e.g. "eolis/gate".
var id := ""
var title := ""
var zone := ""
var header := {}
var size_tiles := Vector2i.ZERO
var spawn_position := Vector2.ZERO
var tiles: TileMapLayer
var secrets: TileMapLayer
## Door number -> {rect: Rect2 (pixels), edge: "left"/"right"/"top"/"bottom"/"inner",
## target: room id, target_door: int}.
var doors := {}

var _one_way := {}
var _secret_cells := {}
var _secret_revealed := false


func _ready() -> void:
	add_to_group("room")


func _physics_process(delta: float) -> void:
	if secrets == null:
		return
	var p := get_tree().get_first_node_in_group("player") as Player
	var inside := p != null and is_secret_at(p.global_position + Vector2(0, -12))
	var target := 0.25 if inside else 1.0
	secrets.modulate.a = move_toward(secrets.modulate.a, target, delta * 4.0)
	if inside and not _secret_revealed:
		_secret_revealed = true
		Sfx.play("secret", 0.0)
		GameState.set_flag("secret:" + id)


static func from_file(path: String, room_id := "") -> Room:
	var text := FileAccess.get_file_as_string(path)
	assert(text != "", "Room file missing or empty: " + path)
	var room := Room.new()
	room.id = room_id if room_id != "" else path.trim_prefix("res://levels/").trim_suffix(".room")
	room.build(text)
	return room


static func from_text(text: String, room_id := "") -> Room:
	var room := Room.new()
	room.id = room_id
	room.build(text)
	return room


## Splits room text into {header: Dictionary, lists: {key: [values]}, grid: Array[String]}.
## Keys that may repeat (label, door, sign, npc) are collected in `lists`.
static func parse(text: String) -> Dictionary:
	var lines := text.replace("\r", "").split("\n")
	var header := {}
	var lists := {}
	var grid: Array[String] = []
	var in_grid := not text.contains("\n---")
	for line in lines:
		if not in_grid:
			if line.strip_edges() == "---":
				in_grid = true
				continue
			var colon := line.find(":")
			if colon > 0:
				var key := line.substr(0, colon).strip_edges()
				var value := line.substr(colon + 1).strip_edges()
				if key in ["label", "door", "sign", "npc"]:
					if not lists.has(key):
						lists[key] = []
					lists[key].append(value)
				else:
					header[key] = value
			continue
		if line.strip_edges() != "":
			grid.append(line)
	return {"header": header, "lists": lists, "grid": grid}


## Finds door cells in a grid: door number -> {rect: Rect2i (tiles), edge}.
static func scan_doors(grid: Array[String]) -> Dictionary:
	var found := {}
	var width := 0
	for row in grid:
		width = maxi(width, row.length())
	for y in grid.size():
		for x in grid[y].length():
			var ch := grid[y][x]
			if DOOR_CHARS.contains(ch):
				var n := int(ch)
				var r := Rect2i(x, y, 1, 1)
				if found.has(n):
					r = r.merge(found[n])
				found[n] = r
	var out := {}
	for n: int in found:
		var r: Rect2i = found[n]
		var edge := "inner"
		if r.position.x == 0:
			edge = "left"
		elif r.end.x == width:
			edge = "right"
		elif r.position.y == 0:
			edge = "top"
		elif r.end.y == grid.size():
			edge = "bottom"
		out[n] = {"rect": r, "edge": edge}
	return out


## Room size in screens (for the map), at least 1x1.
static func screens_for(size: Vector2i) -> Vector2i:
	return Vector2i(maxi(1, roundi(size.x / SCREEN_TILES.x)), maxi(1, roundi(size.y / SCREEN_TILES.y)))


func build(text: String) -> void:
	var parsed := Room.parse(text)
	header = parsed.header
	var grid: Array[String] = parsed.grid
	var lists: Dictionary = parsed.lists

	title = header.get("name", "Untitled room")
	zone = header.get("zone", "")
	var width := 0
	for row in grid:
		width = maxi(width, row.length())
	size_tiles = Vector2i(width, grid.size())

	tiles = TileMapLayer.new()
	tiles.name = "Tiles"
	tiles.tile_set = TilesetFactory.build()
	add_child(tiles)

	for y in grid.size():
		var row := grid[y]
		for x in row.length():
			_place(row[x], Vector2i(x, y), grid)

	var found := Room.scan_doors(grid)
	for spec: String in lists.get("door", []):
		var parts := spec.split(",")
		if parts.size() < 3:
			push_warning("Bad door line in %s: %s" % [id, spec])
			continue
		var n := int(parts[0])
		if not found.has(n):
			push_warning("Door %d in %s has no cells in the grid" % [n, id])
			continue
		var r: Rect2i = found[n].rect
		doors[n] = {
			"rect": Rect2(Vector2(r.position * TILE), Vector2(r.size * TILE)),
			"edge": found[n].edge,
			"target": parts[1].strip_edges(),
			"target_door": int(parts[2]),
		}
		if found[n].edge == "inner":
			var marker := DoorMarker.new()
			marker.door = n
			_spawn(marker, Vector2((r.position.x + r.size.x * 0.5) * TILE, r.end.y * TILE))

	for spec: String in lists.get("label", []):
		_add_label(spec)
	for spec: String in lists.get("sign", []):
		var parts := spec.split(",", true, 2)
		if parts.size() == 3:
			var tablet := LoreTablet.new()
			tablet.text = parts[2].strip_edges()
			_spawn(tablet, Vector2(int(parts[0]) * TILE + TILE * 0.5, (int(parts[1]) + 1) * TILE))

	for spec: String in lists.get("npc", []):
		var parts := spec.split(",")
		if parts.size() == 3:
			var npc := Npc.new()
			npc.npc_id = parts[2].strip_edges()
			_spawn(npc, Vector2(int(parts[0]) * TILE + TILE * 0.5, (int(parts[1]) + 1) * TILE))

	_restore_purse()


func _place(ch: String, cell: Vector2i, grid: Array[String]) -> void:
	var cell_origin := Vector2(cell * TILE)
	var bottom_center := cell_origin + Vector2(TILE * 0.5, TILE)
	var center := cell_origin + Vector2(TILE, TILE) * 0.5
	match ch:
		"#":
			var above_open := cell.y == 0 or _char_at(grid, cell + Vector2i(0, -1)) not in ["#", "C", "%"]
			var tile := TilesetFactory.Tile.TOP if above_open and cell.y > 0 else TilesetFactory.Tile.INNER
			tiles.set_cell(cell, TilesetFactory.SOURCE_ID, Vector2i(tile, 0))
		"-":
			tiles.set_cell(cell, TilesetFactory.SOURCE_ID, Vector2i(TilesetFactory.Tile.ONE_WAY, 0))
			_one_way[cell] = true
		"%":
			_place_secret(cell, grid)
		"^":
			_spawn(Spikes.new(), bottom_center)
		"o":
			_spawn(ThornBulb.new(), center)
		"C":
			var block := CrackedBlock.new()
			if zone != "gym" and zone != "":
				# In the real world a broken wall stays broken.
				block.respawns = false
				block.persist_id = _pickup_id(cell)
				if GameState.is_collected(block.persist_id):
					block.free()
					return
			_spawn(block, center)
		"E":
			_spawn(TrainingDummy.new(), bottom_center)
		"M":
			_spawn_enemy(Monodron.new(), bottom_center)
		"H":
			_spawn_enemy(Hornet.new(), center)
		"D":
			_spawn_enemy(RotDwarf.new(), bottom_center)
		"S":
			_spawn(SaveShrine.new(), bottom_center)
		"J":
			var door_id := _pickup_id(cell)
			if not GameState.is_collected(door_id):
				var key_door := KeyDoor.new()
				key_door.persist_id = door_id
				_spawn(key_door, bottom_center)
		"$":
			var chest := Chest.new()
			chest.pickup_id = _pickup_id(cell)
			chest.value = int(header.get("chest_gold", "100"))
			_spawn(chest, bottom_center)
		"G", "L", "W", "F", "*":
			var item_id := _pickup_id(cell)
			if not GameState.is_collected(item_id):
				var item := ItemPickup.new()
				item.kind = ItemPickup.KIND_BY_CHAR[ch]
				item.pickup_id = item_id
				_spawn(item, center)
		"P":
			spawn_position = bottom_center


func _place_secret(cell: Vector2i, grid: Array[String]) -> void:
	if secrets == null:
		secrets = TileMapLayer.new()
		secrets.name = "Secrets"
		secrets.tile_set = TilesetFactory.build(false)
		secrets.z_index = 3
		add_child(secrets)
	var above_open := _char_at(grid, cell + Vector2i(0, -1)) not in ["#", "C", "%"]
	var tile := TilesetFactory.Tile.TOP if above_open and cell.y > 0 else TilesetFactory.Tile.INNER
	secrets.set_cell(cell, TilesetFactory.SOURCE_ID, Vector2i(tile, 0))
	_secret_cells[cell] = true


func _pickup_id(cell: Vector2i) -> String:
	return "%s:%d,%d" % [id, cell.x, cell.y]


func _spawn(node: Node2D, pos: Vector2) -> void:
	node.position = pos
	add_child(node)


func _spawn_enemy(enemy: Enemy, pos: Vector2) -> void:
	enemy.respawn_time = float(header.get("enemy_respawn", "0"))
	_spawn(enemy, pos)


## Puts back the gold purse dropped in this room on the last death.
func _restore_purse() -> void:
	var purse: Dictionary = GameState.data.get("purse", {})
	if id == "" or purse.get("room", "") != id:
		return
	var bag := GoldPurse.new()
	bag.value = int(purse.value)
	_spawn(bag, Vector2(float(purse.x), float(purse.y)))


func _char_at(grid: Array[String], cell: Vector2i) -> String:
	if cell.y < 0 or cell.y >= grid.size() or cell.x < 0 or cell.x >= grid[cell.y].length():
		return "."
	return grid[cell.y][cell.x]


func _add_label(spec: String) -> void:
	var parts := spec.split(",", true, 2)
	if parts.size() < 3:
		return
	var label := Label.new()
	label.text = parts[2].strip_edges()
	label.position = Vector2(int(parts[0]) * TILE, int(parts[1]) * TILE)
	label.add_theme_font_size_override("font_size", 8)
	label.add_theme_color_override("font_color", Color("d8cfb4"))
	label.add_theme_color_override("font_outline_color", Color("1d1a2b"))
	label.add_theme_constant_override("outline_size", 2)
	label.z_index = -2
	add_child(label)


func pixel_rect() -> Rect2:
	return Rect2(Vector2.ZERO, Vector2(size_tiles * TILE))


func cell_at(world_pos: Vector2) -> Vector2i:
	return Vector2i(floori(world_pos.x / TILE), floori(world_pos.y / TILE))


## True if the tile under `world_pos` is solid ground (not a one-way platform).
func is_solid_at(world_pos: Vector2) -> bool:
	var cell := cell_at(world_pos)
	if tiles.get_cell_source_id(cell) == -1:
		return false
	return tiles.get_cell_atlas_coords(cell).x != TilesetFactory.Tile.ONE_WAY


func is_one_way_at(world_pos: Vector2) -> bool:
	return _one_way.has(cell_at(world_pos))


## True if `world_pos` is inside a fake wall (a secret passage).
func is_secret_at(world_pos: Vector2) -> bool:
	return _secret_cells.has(cell_at(world_pos))
