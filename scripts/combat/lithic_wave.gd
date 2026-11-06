class_name LithicWave
extends Node2D
## The Lithic Fracture spell (design bible 4, a supporting spell, pass 497): a cascade
## of stone columns erupts one after another along the floor in front of the caster,
## about 32 px apart and 0.08 s apart. It steps down ledges, stops at walls and pits,
## and the one column that reaches a cracked stone seal shatters it. Every foe the
## wave strikes takes its light hit once per cast, a slow for Enemy.SLOW_TIME, and,
## unless it is a boss, a stagger.

## The wave is planned in tiles; TILE must match the room's.
const TILE := 16.0
const COLUMNS := 6
## The first column stands this far in front of the caster's feet, the rest STEP on.
const FIRST := 32.0
const STEP := 32.0
## Seconds between one column's eruption and the next.
const INTERVAL := 0.08
## How far the wave will step down to follow a ledge before a gap stops it (px).
const MAX_DROP := 48.0

var damage := 6
var facing := 1
## The caster's feet, set by Spells.cast before the wave enters the tree.
var origin := Vector2.ZERO

## Column base positions (world), in order; set in _ready.
var _columns: Array[Vector2] = []
## The index of the column that lands on a cracked stone seal, or -1 for none.
var _seal_at := -1
var _spawned := 0
var _t := 0.0
## Foe instance ids already struck this cast (damage, stagger and slow are once-per-cast).
var _struck := {}


func _ready() -> void:
	add_to_group("projectile")
	var plan := plan_columns(get_world_2d().direct_space_state, origin, facing)
	_columns = plan.positions
	_seal_at = plan.seal
	Sfx.play("lithic_cast", 0.0)
	Feel.add_trauma(0.14)


func _physics_process(delta: float) -> void:
	_t += delta
	while _spawned < _columns.size() and _t >= _spawned * INTERVAL:
		_erupt(_spawned)
		_spawned += 1
	if _spawned >= _columns.size() and get_child_count() == 0:
		queue_free()


func _erupt(i: int) -> void:
	var col := StoneColumn.new()
	col.wave = self
	col.breaks_seal = i == _seal_at
	add_child(col)
	col.global_position = _columns[i]


## A foe caught by a column's burst: struck once per cast. It takes the light hit,
## the slow, and — unless it is a boss — a stagger (bosses take the hit and slow only).
func strike(foe: Node) -> void:
	if foe.get("dead") == true:
		return
	var id := foe.get_instance_id()
	if _struck.has(id):
		return
	_struck[id] = true
	foe.take_hit(damage, Vector2(facing, -0.4).normalized())
	if foe.has_method("slow"):
		foe.slow(Enemy.SLOW_TIME)
	if not foe.is_in_group("boss") and foe.has_method("stagger"):
		foe.stagger()


## Plans the column bases from the caster's feet along the floor, in tiles, using
## only the world collision at each candidate cell. Returns {positions, seal}: the
## ordered base positions and the index of the column that lands on a seal (-1 if
## none). The wave steps down a ledge up to MAX_DROP, stops at a plain wall or a
## gap, and treats a cracked stone seal as the place to stop and shatter.
static func plan_columns(space: PhysicsDirectSpaceState2D, origin: Vector2, facing: int) -> Dictionary:
	var positions: Array[Vector2] = []
	var seal := -1
	var row := int(round(origin.y / TILE))
	var max_step := int(MAX_DROP / TILE)
	for i in COLUMNS:
		var x := origin.x + facing * (FIRST + i * STEP)
		var col := int(floor(x / TILE))
		# Follow the floor down a ledge: the first solid tile at or below `row`.
		var found := false
		for d in max_step + 1:
			if _tile_solid(space, col, row):
				found = true
				break
			row += 1
		if not found:
			break  # a gap in the floor: the wave stops at the pit's edge
		# The body stands on the tile above the floor. A solid there is a wall.
		var standing := _tile_colliders(space, col, row - 1)
		var on_seal := false
		var plain_wall := false
		for c: Object in standing:
			if c.is_in_group("stone_seal"):
				on_seal = true
			else:
				plain_wall = true
		if plain_wall:
			break  # a wall across the floor: the wave stops
		positions.append(Vector2(col * TILE + TILE * 0.5, row * TILE))
		if on_seal:
			seal = i  # this column shatters the seal, and the wave stops here
			break
	return {"positions": positions, "seal": seal}


## Colliders of the world layer overlapping the centre of tile (col, row).
static func _tile_colliders(space: PhysicsDirectSpaceState2D, col: int, row: int) -> Array:
	var shape := RectangleShape2D.new()
	shape.size = Vector2(10, 10)
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0.0, Vector2(col * TILE + TILE * 0.5, row * TILE + TILE * 0.5))
	params.collision_mask = Player.LAYER_WORLD
	params.collide_with_areas = true
	params.collide_with_bodies = true
	var out: Array = []
	for r in space.intersect_shape(params, 8):
		var c: Object = r.get("collider")
		if c != null and not out.has(c):
			out.append(c)
	return out


static func _tile_solid(space: PhysicsDirectSpaceState2D, col: int, row: int) -> bool:
	return not _tile_colliders(space, col, row).is_empty()
