class_name TilesetFactory
extends RefCounted
## Builds graybox tilesets entirely in code: pixel textures plus collision.
## Final zone tilesets replace the textures; the atlas layout stays the same.

enum Tile { INNER, TOP, ONE_WAY }

const TILE := 16
const SOURCE_ID := 0

const STONE := Color("4a4458")
const STONE_LIGHT := Color("5d5670")
const STONE_DARK := Color("37324a")
const MOSS := Color("5f8a4a")
const MOSS_LIGHT := Color("7fae5e")
const WOOD := Color("8a5a34")
const WOOD_DARK := Color("5e3b22")


static func build() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, Player.LAYER_WORLD)
	ts.set_physics_layer_collision_mask(0, 0)

	var src := TileSetAtlasSource.new()
	src.texture = ImageTexture.create_from_image(_paint_atlas())
	src.texture_region_size = Vector2i(TILE, TILE)
	ts.add_source(src, SOURCE_ID)

	var half := TILE * 0.5
	var full := PackedVector2Array([Vector2(-half, -half), Vector2(half, -half), Vector2(half, half), Vector2(-half, half)])
	var strip := PackedVector2Array([Vector2(-half, -half), Vector2(half, -half), Vector2(half, -half + 4), Vector2(-half, -half + 4)])
	for tile: int in [Tile.INNER, Tile.TOP, Tile.ONE_WAY]:
		var coords := Vector2i(tile, 0)
		src.create_tile(coords)
		var data := src.get_tile_data(coords, 0)
		data.add_collision_polygon(0)
		if tile == Tile.ONE_WAY:
			data.set_collision_polygon_points(0, 0, strip)
			data.set_collision_polygon_one_way(0, 0, true)
		else:
			data.set_collision_polygon_points(0, 0, full)
	return ts


static func _paint_atlas() -> Image:
	var img := Image.create(TILE * 3, TILE, false, Image.FORMAT_RGBA8)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1987
	for tile in 2:
		var ox := tile * TILE
		for y in TILE:
			for x in TILE:
				var c := STONE
				var n := rng.randf()
				if n < 0.12:
					c = STONE_DARK
				elif n > 0.9:
					c = STONE_LIGHT
				# Brick seams every 8 px, offset per row of bricks.
				var row := y / 8
				if y % 8 == 7 or (x + row * 4) % 8 == 0:
					c = STONE_DARK
				img.set_pixel(ox + x, y, c)
		if tile == Tile.TOP:
			for x in TILE:
				var depth := 3 + int(rng.randf() < 0.4)
				for y in depth:
					img.set_pixel(ox + x, y, MOSS_LIGHT if y == 0 else MOSS)
	var wx := Tile.ONE_WAY * TILE
	for x in TILE:
		for y in 5:
			var c := WOOD if y < 3 else WOOD_DARK
			if y == 0:
				c = WOOD.lightened(0.2)
			img.set_pixel(wx + x, y, c)
		if x % 8 == 0:
			for y in range(5, 10):
				img.set_pixel(wx + x, y, WOOD_DARK)
	return img
