class_name Room
extends Node2D
## A room built from a text file: a header of `key: value` lines, a `---`
## separator, then an ASCII tile grid. See levels/README.md for the legend.

const TILE := TilesetFactory.TILE

var title := ""
var header := {}
var size_tiles := Vector2i.ZERO
var spawn_position := Vector2.ZERO
var tiles: TileMapLayer

var _one_way := {}


func _ready() -> void:
	add_to_group("room")


static func from_file(path: String) -> Room:
	var text := FileAccess.get_file_as_string(path)
	assert(text != "", "Room file missing or empty: " + path)
	var room := Room.new()
	room.build(text)
	return room


static func from_text(text: String) -> Room:
	var room := Room.new()
	room.build(text)
	return room


func build(text: String) -> void:
	var lines := text.replace("\r", "").split("\n")
	var grid: Array[String] = []
	var labels: Array = []
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
				if key == "label":
					labels.append(value)
				else:
					header[key] = value
			continue
		if line.strip_edges() != "":
			grid.append(line)

	title = header.get("name", "Untitled room")
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

	for spec: String in labels:
		_add_label(spec)


func _place(ch: String, cell: Vector2i, grid: Array[String]) -> void:
	var cell_origin := Vector2(cell * TILE)
	var bottom_center := cell_origin + Vector2(TILE * 0.5, TILE)
	match ch:
		"#":
			var above_open := cell.y == 0 or _char_at(grid, cell + Vector2i(0, -1)) not in ["#", "C"]
			var tile := TilesetFactory.Tile.TOP if above_open and cell.y > 0 else TilesetFactory.Tile.INNER
			tiles.set_cell(cell, TilesetFactory.SOURCE_ID, Vector2i(tile, 0))
		"-":
			tiles.set_cell(cell, TilesetFactory.SOURCE_ID, Vector2i(TilesetFactory.Tile.ONE_WAY, 0))
			_one_way[cell] = true
		"^":
			_spawn(Spikes.new(), bottom_center)
		"o":
			_spawn(ThornBulb.new(), cell_origin + Vector2(TILE, TILE) * 0.5)
		"C":
			_spawn(CrackedBlock.new(), cell_origin + Vector2(TILE, TILE) * 0.5)
		"E":
			_spawn(TrainingDummy.new(), bottom_center)
		"M":
			_spawn_enemy(Monodron.new(), bottom_center)
		"H":
			_spawn_enemy(Hornet.new(), cell_origin + Vector2(TILE, TILE) * 0.5)
		"D":
			_spawn_enemy(RotDwarf.new(), bottom_center)
		"P":
			spawn_position = bottom_center


func _spawn(node: Node2D, pos: Vector2) -> void:
	node.position = pos
	add_child(node)


func _spawn_enemy(enemy: Enemy, pos: Vector2) -> void:
	enemy.respawn_time = float(header.get("enemy_respawn", "0"))
	_spawn(enemy, pos)


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


## True if the tile under `world_pos` is solid ground (not a one-way platform).
func is_solid_at(world_pos: Vector2) -> bool:
	var cell := Vector2i(floori(world_pos.x / TILE), floori(world_pos.y / TILE))
	if tiles.get_cell_source_id(cell) == -1:
		return false
	return tiles.get_cell_atlas_coords(cell).x != TilesetFactory.Tile.ONE_WAY


func is_one_way_at(world_pos: Vector2) -> bool:
	var cell := Vector2i(floori(world_pos.x / TILE), floori(world_pos.y / TILE))
	return _one_way.has(cell)
