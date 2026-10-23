class_name MapScreen
extends Control
## Full-screen map, toggled with the map button. Pauses the game while open.
## Draws every visited room from the World's catalog as a block on a grid of
## screens, with door openings, save shrines and a blinking player marker.

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

var world: World
var is_open := false

var _font: Font
var _t := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_font = ThemeDB.fallback_font
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("map"):
		toggle()
		get_viewport().set_input_as_handled()
	elif is_open and event.is_action_pressed("pause"):
		toggle()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	if world == null or world.player == null or world.busy:
		return
	if not is_open and (world.player.dead or world.player.frozen):
		return
	is_open = not is_open
	visible = is_open
	get_tree().paused = is_open
	Sfx.play("blip", 0.0, -4.0)


func _process(delta: float) -> void:
	if is_open:
		_t += delta
		queue_redraw()


## Map-space rectangle (in pixels relative to the map origin) for a catalog room.
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
		if not GameState.is_visited(room_id) and room_id != world.room.id:
			continue
		var info: Dictionary = world.catalog[room_id]
		var r := MapScreen.room_rect(info)
		r.position += origin
		var zone: Dictionary = World.ZONES.get(info.zone, {"color": DIM})
		var fill: Color = zone.color.darkened(0.55)
		if room_id == world.room.id:
			fill = zone.color.darkened(0.25 - 0.1 * sin(_t * 4.0))
		draw_rect(r.grow(1), OUTLINE)
		draw_rect(r, fill)
		draw_rect(r, EDGE.darkened(0.35), false, 1.0)
		_draw_doors(info, r, fill)
		for cell: Vector2i in info.shrines:
			var sp := r.position + Vector2(cell) / Vector2(info.size) * r.size
			draw_rect(Rect2(sp - Vector2(1.5, 2.5), Vector2(3, 4)), SHRINE)

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
	draw_rect(Rect2(screen.x - 150, screen.y - 19, 3, 4), SHRINE)
	_text(Vector2(screen.x - 143, screen.y - 14), "Shrine", 8, DIM)
	draw_rect(Rect2(screen.x - 100, screen.y - 18, 2, 2), PLAYER)
	_text(Vector2(screen.x - 94, screen.y - 14), "You", 8, DIM)
	_text(Vector2(screen.x - 64, screen.y - 14), "Map: Tab", 8, DIM)


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
	draw_string_outline(_font, pos, s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 3, OUTLINE)
	draw_string(_font, pos, s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
