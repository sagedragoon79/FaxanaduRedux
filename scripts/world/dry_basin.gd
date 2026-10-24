class_name DryBasin
extends Area2D
## A dry basin (bible 4.5): a stone tank whose mud bed (legend `u`) has cracked
## under a water-line stain (legend `=`, a row across the tank). A Deluge bolt
## that crosses the tank (group "water_target") fills it: the water rises over
## FILL_TIME and floats a raft up to the stain, which then stands as a one-way
## platform along the `=` row. The flag "basin:<room id>:<x>" keeps it full.
## Enemies left in the tank drown when it fills. Several basins can share a
## room; each is one run of `=` tiles.

const FILL_TIME := 1.0
const MUD := Color("5a4632")
const CRACK := Color("2e2218")
const STAIN := Color("3a3a30")
const WATER := Color("3f7fb8")
const WATER_TOP := Color("9fd0f0")
const RAFT := Color("8a6038")
const RAFT_DARK := Color("4a3020")

var room: Room
var flag_id := ""
## Full from the start (a beaten boss's arena).
var start_full := false
## Tile columns x0..x1, the `=` row and the mud bed row (both in tiles).
var x0 := 0
var x1 := 0
var water_row := 0
var bed_row := 0
var filled := false
## 0 dry .. 1 full.
var level := 0.0


func _ready() -> void:
	collision_layer = Player.LAYER_WORLD
	collision_mask = 0
	monitoring = false
	add_to_group("water_target")
	add_to_group("dry_basin")
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	# The bolt counts from the rims and a little above the stain, so a cast
	# from the tank's edge (at chest height) fills it.
	rect.size = Vector2((x1 - x0 + 3) * Room.TILE, (bed_row - water_row + 2) * Room.TILE)
	shape.shape = rect
	shape.position = rect.size * 0.5 - Vector2(Room.TILE, Room.TILE * 2)
	add_child(shape)
	position = Vector2(x0, water_row) * Room.TILE
	if start_full or flag_id != "" and GameState.flag(flag_id):
		_fill(true)


## A Deluge bolt crossed the tank: it fills, and the raft rises.
func douse() -> void:
	if filled:
		return
	if flag_id != "":
		GameState.set_flag(flag_id)
	_fill(false)
	Sfx.play("splash", 0.0)
	Sfx.play("douse", 0.1, -6.0)


func _fill(instant: bool) -> void:
	filled = true
	remove_from_group("water_target")
	level = 1.0 if instant else 0.0
	if instant:
		_float_raft()
		_drown.call_deferred(true)
	queue_redraw()


func _float_raft() -> void:
	if room != null:
		room.float_raft(x0, x1, water_row)


## Enemies left in the tank drown when it fills. Already full on entering the
## room, they are simply gone (no second reward).
func _drown(silent: bool) -> void:
	var tank := Rect2(Vector2(x0, water_row) * Room.TILE, Vector2(x1 - x0 + 1, bed_row - water_row) * Room.TILE)
	for e in get_tree().get_nodes_in_group("enemy"):
		var en := e as Enemy
		if en == null or en.dead or not tank.has_point(en.center()):
			continue
		if silent:
			en.queue_free()
		else:
			en.die()


func _physics_process(delta: float) -> void:
	if filled and level < 1.0:
		level = minf(1.0, level + delta / FILL_TIME)
		if level >= 1.0:
			_float_raft()
			_drown(false)
		queue_redraw()


func _draw() -> void:
	var w := (x1 - x0 + 1) * Room.TILE
	var depth := (bed_row - water_row) * Room.TILE
	if not filled:
		# The stain the old water left, and the cracked mud bed.
		draw_rect(Rect2(-2, 6, w + 4, 1), STAIN)
		draw_rect(Rect2(0, depth - 3, w, 3), MUD)
		for i in range(0, x1 - x0 + 1):
			var cx := i * Room.TILE + 4 + (i * 7) % 8
			draw_rect(Rect2(cx, depth - 3, 1, 3), CRACK)
			draw_rect(Rect2(cx - 2, depth - 2, 3, 0.5), CRACK)
		return
	# Water up to the current level; the raft rides its surface until it stands.
	var top := depth - (depth - 8.0) * level
	draw_rect(Rect2(0, top, w, depth - top), Color(WATER, 0.6))
	draw_rect(Rect2(0, top, w, 1), Color(WATER_TOP, 0.9))
	if level < 1.0:
		draw_rect(Rect2(2, top - 4, w - 4, 5), RAFT_DARK)
		draw_rect(Rect2(3, top - 4, w - 6, 3), RAFT)
