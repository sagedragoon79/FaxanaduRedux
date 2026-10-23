class_name TilesetFactory
extends RefCounted
## Builds a zone's TileSet from its generated atlas (tools/art/tilegen.py,
## assets/tiles/<zone>.png) and adds collision.
##
## Ground uses 47 "blob" autotiles: each solid cell picks the tile for which of
## its 8 neighbours are solid too (corners count only when both sides next to
## them are solid). The atlas has them in rows 0-5 in the order of
## `blob_masks()`; row 6 holds the one-way platform, amber, and darker interior
## tiles for wall cells two (MID) or three or more (DEEP) tiles from open air.

const TILE := 16
## Render density of the atlases (design bible 12.1): each 16 px world tile is
## drawn from a 32 px atlas tile. Tile layers run at TILE * DENSITY and are
## scaled by 1 / DENSITY (see `layer()`), so cell coordinates stay the same.
const DENSITY := 2
const SOURCE_ID := 0
const COLUMNS := 8
const TILES_DIR := "res://assets/tiles/"
const FALLBACK_ZONE := "gym"

const ONE_WAY := Vector2i(0, 6)
const AMBER := Vector2i(1, 6)
const MID: Array[Vector2i] = [Vector2i(2, 6), Vector2i(3, 6)]
const DEEP: Array[Vector2i] = [Vector2i(4, 6), Vector2i(5, 6)]

## Neighbour bits for blob masks.
const N := 1
const NE := 2
const E := 4
const SE := 8
const S := 16
const SW := 32
const W := 64
const NW := 128
const FULL := 255

static var _masks: Array[int] = []
static var _index := {}
static var _cache := {}


## The 47 distinct reduced masks, ascending (tilegen.py builds the same list).
static func blob_masks() -> Array[int]:
	if _masks.is_empty():
		var seen := {}
		for m in 256:
			seen[reduce_mask(m)] = true
		for m: int in seen:
			_masks.append(m)
		_masks.sort()
		for i in _masks.size():
			_index[_masks[i]] = i
	return _masks


## Drops corner bits whose two neighbouring sides are not both solid.
static func reduce_mask(m: int) -> int:
	if not (m & N and m & E):
		m &= ~NE
	if not (m & S and m & E):
		m &= ~SE
	if not (m & S and m & W):
		m &= ~SW
	if not (m & N and m & W):
		m &= ~NW
	return m


## Atlas coordinates of the ground tile for a neighbour mask. `depth` is how
## many tiles the cell is from open air (1 = touching it); deeper cells darken.
static func ground(mask: int, cell := Vector2i.ZERO, depth := 1) -> Vector2i:
	blob_masks()
	var m := reduce_mask(mask)
	if m == FULL and depth >= 2:
		var h := absi((cell.x * 73856093) ^ (cell.y * 19349663)) % 2
		return DEEP[h] if depth >= 3 else MID[h]
	var i: int = _index[m]
	return Vector2i(i % COLUMNS, i / COLUMNS)


static func is_ground(coords: Vector2i) -> bool:
	return coords != ONE_WAY and coords != AMBER


## Builds (and caches) the tileset for a zone. Without collision it is used for
## fake walls (secrets).
static func build(zone := "", with_collision := true) -> TileSet:
	var path := TILES_DIR + zone + ".png"
	if zone == "" or not ResourceLoader.exists(path):
		zone = FALLBACK_ZONE
		path = TILES_DIR + zone + ".png"
	var key := "%s:%s" % [zone, with_collision]
	if _cache.has(key):
		return _cache[key]
	var ts := TileSet.new()
	var size := TILE * DENSITY
	ts.tile_size = Vector2i(size, size)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, Player.LAYER_WORLD)
	ts.set_physics_layer_collision_mask(0, 0)

	var src := TileSetAtlasSource.new()
	src.texture = load(path)
	src.texture_region_size = Vector2i(size, size)
	ts.add_source(src, SOURCE_ID)

	var half := size * 0.5
	var full := PackedVector2Array([Vector2(-half, -half), Vector2(half, -half), Vector2(half, half), Vector2(-half, half)])
	var lip := 4.0 * DENSITY
	var strip := PackedVector2Array([Vector2(-half, -half), Vector2(half, -half), Vector2(half, -half + lip), Vector2(-half, -half + lip)])
	var all: Array[Vector2i] = [ONE_WAY, AMBER]
	all.append_array(MID)
	all.append_array(DEEP)
	for i in blob_masks().size():
		all.append(Vector2i(i % COLUMNS, i / COLUMNS))
	for coords in all:
		src.create_tile(coords)
		if not with_collision:
			continue
		var data := src.get_tile_data(coords, 0)
		data.add_collision_polygon(0)
		if coords == ONE_WAY:
			data.set_collision_polygon_points(0, 0, strip)
			data.set_collision_polygon_one_way(0, 0, true)
		else:
			data.set_collision_polygon_points(0, 0, full)
	_cache[key] = ts
	return ts


## A tile layer for a zone's tileset, scaled so its cells are TILE world pixels.
static func layer(zone := "", with_collision := true) -> TileMapLayer:
	var l := TileMapLayer.new()
	l.tile_set = build(zone, with_collision)
	l.scale = Vector2.ONE / DENSITY
	return l
