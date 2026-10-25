class_name MapScreen
extends Control
## Full-screen map, toggled with the map button. Pauses the game while open.
## Draws every visited room from the World's catalog as a block on a grid of
## screens, with door openings, save shrines and a blinking player marker.
## Rooms you have not seen show dimmed once you own the zone's chart (sold by
## the Cartographers), and Jump drops or lifts a pin where you stand.

const CELL := Vector2(40, 22)
const BACKDROP := Color(0.05, 0.04, 0.09, 0.96)
const GRID := Color(1, 1, 1, 0.04)
const OUTLINE := Color("1d1a2b")
const EDGE := Color("f1ead2")
const CURRENT := Color("fff4d6")
const SHRINE := Color("7ee0d6")
const PLAYER := Color("e0404a")
const TEXT := Color("f1ead2")
const DIM := Color("8d84a3")
const PIN := Color("f0c02e")
## Treasure Sense's mark on a room that still holds an item or chest.
const TREASURE := Color("ff9a3c")

var world: World
var is_open := false
## The frame the map last closed on (a Pause press that closes it must not also pause).
var closed_frame := -1

var _t := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("map"):
		toggle()
		get_viewport().set_input_as_handled()
	elif is_open and event.is_action_pressed("pause"):
		toggle()
		get_viewport().set_input_as_handled()
	elif is_open and event.is_action_pressed("jump"):
		pin()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	if world == null or world.player == null or world.busy:
		return
	if not is_open and (world.player.dead or world.player.frozen or get_tree().paused):
		return
	if is_open:
		closed_frame = Engine.get_process_frames()
	is_open = not is_open
	visible = is_open
	get_tree().paused = is_open
	Sfx.play("blip", 0.0, -4.0)


## Drops a pin where the player stands, or lifts the one already there.
func pin() -> String:
	if world == null or world.room == null or world.player == null:
		return ""
	var result := GameState.toggle_pin(world.room.id, world.player.global_position)
	Sfx.play("fizzle" if result == "full" else "blip", 0.0, -2.0 if result == "placed" else -6.0)
	return result


## How a room shows on the map: "here", "visited", "charted" (dimmed) or "" (hidden).
static func shown(room_id: String, info: Dictionary, here_id: String) -> String:
	if room_id == here_id:
		return "here"
	if GameState.is_visited(room_id):
		return "visited"
	if GameState.has_chart(String(info.get("zone", ""))):
		return "charted"
	return ""


func _process(delta: float) -> void:
	if is_open:
		_t += delta
		queue_redraw()


## Map-space rectangle (in pixels relative to the map origin) for a catalog room.
## Items and chests in a room not yet taken (Treasure Sense, design bible 9).
static func unfound(info: Dictionary) -> int:
	var n := 0
	for id: String in info.get("treasures", []):
		if not GameState.is_collected(id):
			n += 1
	return n


## Does the map mark this room for Treasure Sense? Only rooms the map shows.
static func senses_treasure(info: Dictionary, how: String) -> bool:
	return how != "" and GameState.has_skill("treasure_sense") and unfound(info) > 0


static func room_rect(info: Dictionary) -> Rect2:
	return Rect2(Vector2(info.map) * CELL, Vector2(info.screens) * CELL)


func _draw() -> void:
	if not is_open or world == null or world.room == null:
		return
	var screen := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, screen), BACKDROP)
	var here: Dictionary = world.catalog.get(world.room.id, {})
	var center := screen * 0.5
	var origin := center
	if not here.is_empty():
		origin = center - MapScreen.room_rect(here).get_center()
	# Faint grid of screens.
	var gx := fposmod(origin.x, CELL.x)
	while gx < screen.x:
		draw_line(Vector2(gx, 30), Vector2(gx, screen.y - 30), GRID)
		gx += CELL.x
	var gy := fposmod(origin.y, CELL.y)
	while gy < screen.y:
		draw_line(Vector2(0, gy), Vector2(screen.x, gy), GRID)
		gy += CELL.y

	for room_id: String in world.catalog:
		var info: Dictionary = world.catalog[room_id]
		var how := MapScreen.shown(room_id, info, world.room.id)
		if how == "":
			continue
		var r := MapScreen.room_rect(info)
		r.position += origin
		var zone: Dictionary = World.ZONES.get(info.zone, {"color": DIM})
		if how == "charted":
			draw_rect(r.grow(1), OUTLINE)
			draw_rect(r, zone.color.darkened(0.82))
			draw_rect(r, zone.color.darkened(0.5), false, 1.0)
			if MapScreen.senses_treasure(info, how):
				_draw_treasure(r)
			continue
		var fill: Color = zone.color.darkened(0.55)
		if how == "here":
			fill = zone.color.darkened(0.25 - 0.1 * sin(_t * 4.0))
		draw_rect(r.grow(1), OUTLINE)
		draw_rect(r, fill)
		draw_rect(r, EDGE.darkened(0.35), false, 1.0)
		_draw_doors(info, r, fill)
		for cell: Vector2i in info.shrines:
			var sp := r.position + Vector2(cell) / Vector2(info.size) * r.size
			draw_rect(Rect2(sp - Vector2(1.5, 2.5), Vector2(3, 4)), SHRINE)
		if MapScreen.senses_treasure(info, how):
			_draw_treasure(r)

	for p: Array in GameState.data.pins:
		var info: Dictionary = world.catalog.get(String(p[0]), {})
		if info.is_empty():
			continue
		var r := MapScreen.room_rect(info)
		var pp := origin + r.position + Vector2(float(p[1]), float(p[2])) / (Vector2(info.size) * Room.TILE) * r.size
		draw_colored_polygon(PackedVector2Array([pp + Vector2(0, -5), pp + Vector2(3, -2), pp + Vector2(0, 1), pp + Vector2(-3, -2)]), OUTLINE)
		draw_colored_polygon(PackedVector2Array([pp + Vector2(0, -4), pp + Vector2(2, -2), pp + Vector2(0, 0), pp + Vector2(-2, -2)]), PIN)

	if not here.is_empty() and fmod(_t, 0.6) < 0.4:
		var r := MapScreen.room_rect(here)
		var frac := world.player.global_position / (Vector2(here.size) * Room.TILE)
		var pp := origin + r.position + frac * r.size
		draw_rect(Rect2(pp - Vector2(2, 3), Vector2(4, 4)), OUTLINE)
		draw_rect(Rect2(pp - Vector2(1, 2), Vector2(2, 2)), PLAYER)

	var zone_name: String = World.ZONES.get(world.room.zone, {}).get("name", "")
	_text(Vector2(20, 22), "MAP", 14, TEXT)
	_text(Vector2(70, 22), zone_name, 10, DIM)
	_text(Vector2(20, screen.y - 12), world.room.title, 10, TEXT)
	var status := "%s   XP %d" % [GameState.rank_name(), int(GameState.data.xp)]
	if GameState.next_rank_xp() > 0:
		status += " / %d" % GameState.next_rank_xp()
	status += "   Skill points %d   Jack Keys %d" % [int(GameState.data.skill_points), GameState.key_count("jack")]
	_text(Vector2(20, 40), status, 9, DIM)
	# The legend, laid out right to left from measured widths: swatch, label, gap.
	var legend := [["Map: Tab", Color.TRANSPARENT, Vector2.ZERO], ["You", PLAYER, Vector2(2, 2)],
		["Shrine", SHRINE, Vector2(3, 4)], ["Pin: Jump (%d/%d)" % [GameState.data.pins.size(), GameState.MAX_PINS], PIN, Vector2(3, 3)]]
	if GameState.has_skill("treasure_sense"):
		legend.insert(3, ["Treasure", TREASURE, Vector2(3, 3)])
	var lx := screen.x - 16
	for item: Array in legend:
		var label: String = item[0]
		lx -= PixelFont.width(label, 8)
		_text(Vector2(lx, screen.y - 14), label, 8, DIM)
		var swatch: Vector2 = item[2]
		if swatch != Vector2.ZERO:
			lx -= swatch.x + 4
			draw_rect(Rect2(Vector2(lx, screen.y - 15 - swatch.y), swatch), item[1])
		lx -= 14


## A small twinkling star in the room's top-right corner.
func _draw_treasure(r: Rect2) -> void:
	var c := r.position + Vector2(r.size.x - 5, 5)
	var k := 2.0 + sin(_t * 5.0)
	draw_rect(Rect2(c - Vector2(1.5, k + 1.5), Vector2(3, k * 2 + 3)), OUTLINE)
	draw_rect(Rect2(c - Vector2(k + 1.5, 1.5), Vector2(k * 2 + 3, 3)), OUTLINE)
	draw_rect(Rect2(c - Vector2(0.5, k + 0.5), Vector2(1, k * 2 + 1)), TREASURE)
	draw_rect(Rect2(c - Vector2(k + 0.5, 0.5), Vector2(k * 2 + 1, 1)), TREASURE)


func _draw_doors(info: Dictionary, r: Rect2, fill: Color) -> void:
	for n: int in info.doors:
		var d: Dictionary = info.doors[n]
		var cell_rect: Rect2i = d.rect
		var c := (Vector2(cell_rect.position) + Vector2(cell_rect.size) * 0.5) / Vector2(info.size)
		var p := r.position + c * r.size
		match d.edge:
			"left":
				draw_rect(Rect2(r.position.x - 1, p.y - 2, 3, 4), fill)
			"right":
				draw_rect(Rect2(r.end.x - 2, p.y - 2, 3, 4), fill)
			"top":
				draw_rect(Rect2(p.x - 2, r.position.y - 1, 4, 3), fill)
			"bottom":
				draw_rect(Rect2(p.x - 2, r.end.y - 2, 4, 3), fill)
			"inner":
				draw_rect(Rect2(p.x - 1, p.y - 2, 3, 3), EDGE.darkened(0.2))


func _text(pos: Vector2, s: String, size: int, color: Color) -> void:
	PixelFont.draw(self, pos, s, size, color, OUTLINE)
