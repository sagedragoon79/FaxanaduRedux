class_name GroundFill
extends Node2D
## The inside of a zone's walls, from one large seamless texture
## (assets/tiles/<zone>_fill.png, design bible 13.6) instead of one tile repeated:
## each ground cell shows the part of the texture under its place in the room.
## It is a child of the tile layer, drawn behind it (the layer's tiles then add
## the edges), and shares its scale and fading.

var _layer: TileMapLayer
var _tex: Texture2D


static func path(zone: String) -> String:
	return TilesetFactory.TILES_DIR + zone + "_fill.png"


## Adds a fill under `layer` when the zone has a fill texture.
static func attach(layer: TileMapLayer, zone: String) -> void:
	if zone == "" or not ResourceLoader.exists(path(zone)):
		return
	var fill := GroundFill.new()
	fill.name = "GroundFill"
	fill._layer = layer
	fill._tex = load(path(zone))
	fill.show_behind_parent = true
	layer.add_child(fill)
	layer.changed.connect(fill.queue_redraw)


func _draw() -> void:
	var size := float(TilesetFactory.TILE * TilesetFactory.DENSITY)
	var period := _tex.get_size()
	for cell: Vector2i in _layer.get_used_cells():
		var coords := _layer.get_cell_atlas_coords(cell)
		if not TilesetFactory.is_ground(coords):
			continue
		var at := Vector2(cell) * size
		var src := Vector2(fposmod(at.x, period.x), fposmod(at.y, period.y))
		draw_texture_rect_region(_tex, Rect2(at, Vector2(size, size)), Rect2(src, Vector2(size, size)))
