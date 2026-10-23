class_name Room
extends Node2D
## A room built from a text file: a header of `key: value` lines, a `---`
## separator, then an ASCII tile grid. See levels/README.md for the legend.

const TILE := TilesetFactory.TILE
## One screen in tiles (640x360 px). Map cells and room sizes count in screens.
const SCREEN_TILES := Vector2(40, 22.5)
const DOOR_CHARS := "123456789"
## What each zone's ground is made of, for footsteps (design bible 11). A room's
## `surface:` header overrides it; platforms are planks and sap pools are sap.
const ZONE_SURFACES := {"gym": "stone", "eolis": "stone", "trunk": "moss", "tower": "iron", "mist": "moss"}

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
var _sap_cells := {}
var _sap_node: SapPool
## Cells drawn as ground (real walls and fake ones), for picking autotiles.
var _solid_look := {}
var _secret_revealed := false
var _roots_open := false


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
## Keys that may repeat (label, door, sign, npc, secret, prop) are collected in `lists`.
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
				if key in ["label", "door", "sign", "npc", "secret", "prop"]:
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

	tiles = TilesetFactory.layer(zone)
	tiles.name = "Tiles"
	add_child(tiles)

	# Which cells look like ground, so each wall tile can match its neighbours.
	var amber := _amber_on()
	for y in grid.size():
		for x in grid[y].length():
			if grid[y][x] in ["#", "%"]:
				_solid_look[Vector2i(x, y)] = true
	# Hidden rooms: a rectangle of fake wall hides the contents until the player walks in.
	var covers := {}
	for spec: String in lists.get("secret", []):
		var r := spec.split(",")
		if r.size() == 4:
			for y in range(int(r[1]), int(r[3]) + 1):
				for x in range(int(r[0]), int(r[2]) + 1):
					var ch := _char_at(grid, Vector2i(x, y))
					if ch not in ["#", "-"] and not (ch == "~" and amber):
						covers[Vector2i(x, y)] = true
						_solid_look[Vector2i(x, y)] = true

	for y in grid.size():
		var row := grid[y]
		for x in row.length():
			_place(row[x], Vector2i(x, y), grid)
	for cell: Vector2i in covers:
		if not _secret_cells.has(cell):
			_place_secret(cell)
	var decor := Decor.new()
	decor.name = "Decor"
	add_child(decor)
	decor.build(id, zone, grid, covers)

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

	if not _sap_cells.is_empty():
		_sap_pool()
		_sap_node.falls = SapPool.find_falls(_sap_cells, func(c: Vector2i) -> bool: return _solid_look.has(c))

	for spec: String in lists.get("npc", []):
		var parts := spec.split(",")
		# An optional fourth field shows the person only once a world flag is set,
		# or ("!flag") only until it is.
		if parts.size() == 4:
			var cond := parts[3].strip_edges()
			if GameState.flag(cond.trim_prefix("!")) == cond.begins_with("!"):
				continue
			parts.resize(3)
		if parts.size() == 3:
			var npc := Npc.new()
			npc.npc_id = parts[2].strip_edges()
			_spawn(npc, Vector2(int(parts[0]) * TILE + TILE * 0.5, (int(parts[1]) + 1) * TILE))

	for spec: String in lists.get("prop", []):
		var parts := spec.split(",")
		if parts.size() == 3:
			_add_prop(parts[2].strip_edges(), Vector2(int(parts[0]) * TILE + TILE * 0.5, (int(parts[1]) + 1) * TILE))

	if header.has("boss"):
		var arena := BossArena.new()
		arena.boss_id = header.boss
		arena.room = self
		add_child(arena)

	_restore_purse()


## True once this room's Root Heart has been struck (on this visit or an earlier one).
func root_gates_open() -> bool:
	return _roots_open or (id != "" and GameState.flag("roots:" + id))


## The Root Heart was struck: every root-gate in the room withers open, for good.
func open_root_gates() -> void:
	_roots_open = true
	if id != "":
		GameState.set_flag("roots:" + id)
	for c in get_children():
		if c is RootGate:
			(c as RootGate).retract()
	Sfx.play("crumble", 0.0)


func _add_prop(kind: String, pos: Vector2) -> void:
	match kind:
		"fountain":
			_spawn(Fountain.new(), pos)
		"spring_trunk":
			var spring := Spring.new()
			spring.spring_id = "trunk"
			spring.spring_name = "Spring of Trunk"
			_spawn(spring, pos)
		"house":
			_spawn(HouseFront.new(), pos)
		"taproot":
			_spawn(Taproot.new(), pos)
		"crucible":
			_spawn(Crucible.new(), pos)
		"winch":
			_spawn(Winch.new(), pos)
		"forge":
			_spawn(Forge.new(), pos)
		"lift":
			var cage := LiftCage.new()
			cage.room_id = id
			_spawn(cage, pos)
		_:
			push_warning("Unknown prop in %s: %s" % [id, kind])


## Phase 3 of Rokusutahn: removes floor rows `row_from`..`row_to` between the
## columns, and lines the new pit's floor with spikes.
func tear_floor(col_from: int, col_to: int, row_from: int, row_to: int) -> void:
	for x in range(col_from, col_to + 1):
		for y in range(row_from, row_to + 1):
			tiles.erase_cell(Vector2i(x, y))
			_solid_look.erase(Vector2i(x, y))
		var below := Vector2i(x, row_to + 1)
		if tiles.get_cell_source_id(below) != -1:
			_spawn(Spikes.new(), Vector2((x + 0.5) * TILE, below.y * TILE))
	# The ground around the pit gets new edges.
	for x in range(col_from - 3, col_to + 4):
		for y in range(row_from - 3, row_to + 4):
			var cell := Vector2i(x, y)
			if _solid_look.has(cell) and tiles.get_cell_source_id(cell) != -1:
				tiles.set_cell(cell, TilesetFactory.SOURCE_ID, TilesetFactory.ground(_ground_mask(cell), cell, _depth(cell)))


func _amber_on() -> bool:
	return zone == "trunk" and GameState.flag("spring:trunk")


const _NEIGHBOURS := [
	[Vector2i(0, -1), TilesetFactory.N], [Vector2i(1, -1), TilesetFactory.NE],
	[Vector2i(1, 0), TilesetFactory.E], [Vector2i(1, 1), TilesetFactory.SE],
	[Vector2i(0, 1), TilesetFactory.S], [Vector2i(-1, 1), TilesetFactory.SW],
	[Vector2i(-1, 0), TilesetFactory.W], [Vector2i(-1, -1), TilesetFactory.NW],
]


## How far a ground cell is from open air, in tiles (1 to 3).
func _depth(cell: Vector2i) -> int:
	for r in [1, 2]:
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				var n := cell + Vector2i(dx, dy)
				var inside := n.x >= 0 and n.y >= 0 and n.x < size_tiles.x and n.y < size_tiles.y
				if inside and not _solid_look.has(n):
					return r
	return 3


## Which of a cell's 8 neighbours look like ground. Outside the room counts as ground.
func _ground_mask(cell: Vector2i) -> int:
	var m := 0
	for d: Array in _NEIGHBOURS:
		var n: Vector2i = cell + d[0]
		var outside := n.x < 0 or n.y < 0 or n.x >= size_tiles.x or n.y >= size_tiles.y
		if outside or _solid_look.has(n):
			m |= int(d[1])
	return m


func _place(ch: String, cell: Vector2i, grid: Array[String]) -> void:
	var cell_origin := Vector2(cell * TILE)
	var bottom_center := cell_origin + Vector2(TILE * 0.5, TILE)
	var center := cell_origin + Vector2(TILE, TILE) * 0.5
	match ch:
		"#":
			tiles.set_cell(cell, TilesetFactory.SOURCE_ID, TilesetFactory.ground(_ground_mask(cell), cell, _depth(cell)))
		"-":
			tiles.set_cell(cell, TilesetFactory.SOURCE_ID, TilesetFactory.ONE_WAY)
			_one_way[cell] = true
		"%":
			_place_secret(cell)
		"~":
			if _amber_on():
				# The restored spring hardens the Trunk's sap into walkable amber.
				tiles.set_cell(cell, TilesetFactory.SOURCE_ID, TilesetFactory.AMBER)
			else:
				_sap_cells[cell] = true
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
		"T":
			_spawn_enemy(SapSpitter.new(), bottom_center)
		"U":
			_spawn_enemy(GrubLump.new(), center)
		"I":
			_spawn_enemy(IronDwarf.new(), bottom_center)
		"B":
			_spawn_enemy(GearBat.new(), center)
		"K":
			_spawn_enemy(MinecartRider.new(), bottom_center)
		"A":
			_spawn_enemy(LanternGhost.new(), center)
		"R":
			var gate := RootGate.new()
			_spawn(gate, center)
			if root_gates_open():
				gate.retract(true)
		"Q":
			_spawn(FlueDamper.new(), center)
		"Y":
			var curtain := MistCurtain.new()
			curtain.flag_id = "curtain:" + id
			_spawn(curtain, center)
		"N":
			var heart := RootHeart.new()
			heart.room = self
			heart.struck = root_gates_open()
			_spawn(heart, bottom_center)
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


func _place_secret(cell: Vector2i) -> void:
	if secrets == null:
		secrets = TilesetFactory.layer(zone, false)
		secrets.name = "Secrets"
		secrets.z_index = 3
		add_child(secrets)
	secrets.set_cell(cell, TilesetFactory.SOURCE_ID, TilesetFactory.ground(_ground_mask(cell), cell, _depth(cell)))
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
	return tiles.get_cell_atlas_coords(cell) != TilesetFactory.ONE_WAY


func is_one_way_at(world_pos: Vector2) -> bool:
	return _one_way.has(cell_at(world_pos))


## The ground under `world_pos` (a point just below the feet) for footsteps:
## "stone", "moss", "plank", "iron" or "sap", or "" in mid-air.
func surface_at(world_pos: Vector2) -> String:
	if is_sap_at(world_pos + Vector2(0, -TILE * 0.5)):
		return "sap"
	if is_one_way_at(world_pos):
		return "plank"
	var cell := cell_at(world_pos)
	if tiles.get_cell_source_id(cell) == -1:
		return ""
	return str(header.get("surface", ZONE_SURFACES.get(zone, "stone")))


## True if `world_pos` is inside a fake wall (a secret passage).
func is_secret_at(world_pos: Vector2) -> bool:
	return _secret_cells.has(cell_at(world_pos))


## True if `world_pos` is inside a sap pool (slows the player).
func is_sap_at(world_pos: Vector2) -> bool:
	return _sap_cells.has(cell_at(world_pos))


## A Sap Spitter's glob lands: a puddle of sap, up to three tiles wide, on the
## floor around `world_pos`, that slows like a pool and dries after `seconds`.
## Returns the cells it covered (none in mid-air or where sap already is).
func splash_sap(world_pos: Vector2, seconds: float) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var at := cell_at(world_pos)
	for dx in [0, -1, 1]:
		var c: Vector2i = at + Vector2i(dx, 0)
		if _sap_cells.has(c) or tiles.get_cell_source_id(c) != -1 or not is_solid_at(Vector2(c + Vector2i.DOWN) * TILE + Vector2(8, 8)):
			continue
		_sap_cells[c] = true
		out.append(c)
	if out.is_empty():
		return out
	_sap_pool()
	get_tree().create_timer(seconds, false).timeout.connect(func() -> void:
		for c in out:
			_sap_cells.erase(c))
	return out


func _sap_pool() -> SapPool:
	if _sap_node == null:
		_sap_node = SapPool.new()
		_sap_node.cells = _sap_cells
		add_child(_sap_node)
	return _sap_node
