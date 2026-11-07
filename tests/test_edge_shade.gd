extends TestSuite
## EdgeShade: the ambient-occlusion rim overlay's geometry (design bible 12.3).
## These cover the pure rules for which solid cells are rimmed and on which
## edges, so the drawing in _draw() is driven by tested logic.


## A floor along the bottom row and a wall up the left column of a `size` grid.
func _room(size := Vector2i(6, 6)) -> Dictionary:
	var solids := {}
	for x in size.x:
		solids[Vector2i(x, size.y - 1)] = true
	for y in size.y:
		solids[Vector2i(0, y)] = true
	return solids


func test_out_of_bounds_counts_as_solid_not_air() -> void:
	var size := Vector2i(6, 6)
	var solids := _room(size)
	check(not EdgeShade.is_air(solids, size, Vector2i(-1, 2)), "left of the room is not air")
	check(not EdgeShade.is_air(solids, size, Vector2i(6, 2)), "right of the room is not air")
	check(not EdgeShade.is_air(solids, size, Vector2i(0, 0)), "a solid cell is not air")
	check(EdgeShade.is_air(solids, size, Vector2i(3, 3)), "an open interior cell is air")


func test_air_cells_get_no_rim() -> void:
	var size := Vector2i(6, 6)
	var solids := _room(size)
	check(EdgeShade.bands_for(solids, size, Vector2i(3, 3)) == 0, "the open centre draws nothing")
	check(EdgeShade.bands_for(solids, size, Vector2i(2, 2)) == 0, "an air cell beside no wall draws nothing")


func test_buried_cell_gets_no_rim() -> void:
	var size := Vector2i(5, 5)
	var solids := {}
	for y in size.y:
		for x in size.x:
			solids[Vector2i(x, y)] = true
	check(EdgeShade.bands_for(solids, size, Vector2i(2, 2)) == 0, "a cell with no open-air neighbour is not rimmed")


func test_room_frame_is_not_rimmed_on_its_outer_edge() -> void:
	var size := Vector2i(6, 6)
	var solids := _room(size)
	# The left wall cell (0,2): air is to its right only, never off the left edge of the room.
	var m := EdgeShade.bands_for(solids, size, Vector2i(0, 2))
	check(m & EdgeShade.LEFT_BAND == 0, "the room's outer frame casts no rim outward")
	check(m & EdgeShade.RIGHT_BAND != 0, "but the wall's inner face is rimmed")


func test_floor_top_gets_the_faint_walking_rim() -> void:
	var size := Vector2i(6, 6)
	var solids := _room(size)
	var m := EdgeShade.bands_for(solids, size, Vector2i(3, 5))
	check(m & EdgeShade.TOP_BAND != 0, "the floor's walking surface is rimmed")
	check(m & EdgeShade.UNDER_BAND == 0, "the floor sits on the room's edge, so no underside rim")


func test_ledge_underside_is_rimmed() -> void:
	var size := Vector2i(6, 6)
	# A single floating ledge tile with open air all round but the room edges far off.
	var solids := {Vector2i(3, 3): true}
	var m := EdgeShade.bands_for(solids, size, Vector2i(3, 3))
	check(m & EdgeShade.UNDER_BAND != 0, "a ledge's underside is rimmed")
	check(m & EdgeShade.TOP_BAND != 0 and m & EdgeShade.LEFT_BAND != 0 and m & EdgeShade.RIGHT_BAND != 0, "and every exposed face")


func test_block_corner_rims_two_faces() -> void:
	var size := Vector2i(6, 6)
	# A 2x2 floating block; its top-left cell has air above and to the left.
	var solids := {Vector2i(2, 2): true, Vector2i(3, 2): true, Vector2i(2, 3): true, Vector2i(3, 3): true}
	var m := EdgeShade.bands_for(solids, size, Vector2i(2, 2))
	check(m & EdgeShade.TOP_BAND != 0 and m & EdgeShade.LEFT_BAND != 0, "a block's outer corner gets two overlapping rims")
	check(m & EdgeShade.RIGHT_BAND == 0 and m & EdgeShade.UNDER_BAND == 0, "and none on the faces buried in the block")
