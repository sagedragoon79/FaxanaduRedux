class_name Query
extends RefCounted
## Immediate physics shape queries. Used instead of Area2D signals so that hit
## detection resolves within the frame that asks, deterministically.

static func rect(world: World2D, area: Rect2, mask: int, exclude: Array[RID] = []) -> Array:
	var shape := RectangleShape2D.new()
	shape.size = area.size
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0.0, area.get_center())
	params.collision_mask = mask
	params.collide_with_areas = true
	params.collide_with_bodies = true
	params.exclude = exclude
	var out: Array = []
	for r in world.direct_space_state.intersect_shape(params, 32):
		var c: Object = r.get("collider")
		if c != null and not out.has(c):
			out.append(c)
	return out
