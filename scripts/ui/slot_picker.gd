class_name SlotPicker
extends Control
## The title's three journeys (Sean, 2026-10-31; bible 14): three flasks on a
## shelf, one per save, with no number or letter on any of them. A flask holding
## a journey is stoppered and glows with its spring's color, filled as high as
## the hero's rank. An empty one stands open and dark. Focus one (Left/Right,
## or the mouse over it) and the shelf below tells its journey: where you last
## rested, your rank, gold, the springs restored and the time on the road.
## Choose a full flask to take that journey up, an empty one to begin anew in
## it. Block on a full flask asks to pour it out (the save is deleted).

signal chosen(slot: int, fresh: bool)
signal cancelled

## The save slots behind the three flasks; tests point them elsewhere.
var slots: Array = [1, 2, 3]
## The three springs' colors: amber Trunk, pale Mist, blue Sky.
const COLORS := [Color("e8a23c"), Color("8fd8c4"), Color("8fb4ff")]
const GLASS := Color(0.75, 0.82, 0.9, 0.55)
const GLASS_DARK := Color(0.08, 0.07, 0.12, 0.8)
const CORK := Color("8a5a32")
const TEXT := Color("f1ead2")
const SOFT := Color("c9b98f")
const DIM := Color("6b6380")
const ACCENT := Color("ffd24a")
const BG := Color(0.07, 0.06, 0.11, 0.92)
const PANEL := Rect2(130, 136, 380, 196)
const SPACING := 112.0
const BODY_R := 24.0
const INPUT_GRACE := 0.12

var cursor := 0
var is_open := false
## True while asking whether to pour the focused journey out.
var pouring := false
## Per flask: the slot's summary (see summary()), or {} when empty.
var saves: Array = []

var _t := 0.0
var _grace := 0.0
var _lift: Array = [0.0, 0.0, 0.0]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false


## Shows the shelf, focused on the journey last rested in (or the first empty
## flask when there is none).
func open() -> void:
	refresh()
	cursor = 0
	var newest := 0
	var found := false
	for i in slots.size():
		var t := GameState.slot_time(int(slots[i]))
		if not saves[i].is_empty() and t >= newest:
			newest = t
			cursor = i
			found = true
	if not found:
		for i in saves.size():
			if saves[i].is_empty():
				cursor = i
				break
	pouring = false
	is_open = true
	visible = true
	_grace = INPUT_GRACE


func close() -> void:
	is_open = false
	visible = false
	pouring = false


## Reads every slot again (after a pour).
func refresh() -> void:
	saves = []
	for s: Variant in slots:
		saves.append(summary(GameState.read_slot(int(s))))


## The few things a flask's shelf says about a save, or {} for none.
static func summary(data: Dictionary) -> Dictionary:
	if data.is_empty():
		return {}
	var room_id := String(data.get("save_room", ""))
	var room := "somewhere forgotten"
	var zone := ""
	if World.room_exists(room_id):
		for line: String in FileAccess.get_file_as_string(World.room_path(room_id)).split("\n"):
			if line.begins_with("name:"):
				room = line.trim_prefix("name:").strip_edges()
			elif line.begins_with("zone:"):
				zone = String(World.ZONES.get(line.trim_prefix("zone:").strip_edges(), {}).get("name", ""))
			elif line == "---":
				break
	var rank := clampi(int(data.get("rank", 0)), 0, GameState.RANKS.size() - 1)
	var springs := 0
	for s: String in Fountain.SPRINGS:
		if bool(data.get("flags", {}).get("spring:" + s, false)):
			springs += 1
	return {
		"room": room, "zone": zone, "rank": GameState.RANKS[rank],
		"fill": 0.25 + 0.7 * float(rank) / float(GameState.RANKS.size() - 1),
		"gold": int(data.get("gold", 0)), "springs": springs,
		"minutes": int(float(data.get("play_time", 0.0)) / 60.0),
	}


## The lines the shelf shows for the focused flask.
func details() -> Array:
	if saves.is_empty():
		return []
	var s: Dictionary = saves[cursor]
	if pouring:
		return ["Pour this journey out?", "It cannot be gathered up again."]
	if s.is_empty():
		return ["An empty flask.", "Choose it to begin a new journey at the West Gate of Eolis."]
	var where := String(s.room) if String(s.zone) == "" or String(s.zone) == String(s.room) else "%s, %s" % [s.room, s.zone]
	var hours := int(s.minutes) / 60
	var played := ("%d h %d min" % [hours, int(s.minutes) % 60]) if hours > 0 else "%d min" % int(s.minutes)
	var springs: String = "No spring flows yet" if int(s.springs) == 0 else ("All three springs flow" if int(s.springs) == 3 else ["", "One spring of three flows", "Two springs of three flow"][int(s.springs)])
	var gold := int(s.gold)
	var coins := ("%d,%03d" % [gold / 1000, gold % 1000]) if gold >= 1000 else str(gold)
	return ["Rested at %s" % where, "%s   %s gold   %s" % [s.rank, coins, played], springs]


func move(step: int) -> void:
	if pouring:
		return
	cursor = wrapi(cursor + step, 0, slots.size())
	Sfx.play("blip", 0.0, -8.0)


## Takes the focused journey up, begins one in an empty flask, or (when asked)
## pours the focused one out.
func confirm() -> void:
	if pouring:
		GameState.delete_save(int(slots[cursor]))
		pouring = false
		refresh()
		Sfx.play("splash", 0.0, -4.0)
		return
	var fresh: bool = saves[cursor].is_empty()
	Sfx.play("title" if fresh else "save", 0.0, -6.0)
	var slot := int(slots[cursor])
	close()
	chosen.emit(slot, fresh)


## Block on a full flask: ask to pour it out.
func pour() -> void:
	if pouring or saves[cursor].is_empty():
		return
	pouring = true
	Sfx.play("blip", 0.0, -4.0)


func back() -> void:
	if pouring:
		pouring = false
		return
	close()
	cancelled.emit()


## Where flask `i` stands (the middle of its round body).
func flask_center(i: int) -> Vector2:
	return Vector2(320.0 + (i - (slots.size() - 1) * 0.5) * SPACING, PANEL.position.y + 72.0)


## The box the mouse must be in to focus flask `i`.
func flask_box(i: int) -> Rect2:
	var c := flask_center(i)
	return Rect2(c.x - 40, c.y - 56, 80, 88)


## The flask under a point, or -1.
func flask_at(point: Vector2) -> int:
	for i in slots.size():
		if flask_box(i).has_point(point):
			return i
	return -1


func _input(event: InputEvent) -> void:
	if not is_open or _grace > 0.0:
		return
	if event is InputEventMouseMotion and not pouring:
		var i := flask_at(get_local_mouse_position())
		if i >= 0 and i != cursor:
			cursor = i
			Sfx.play("blip", 0.0, -8.0)
	elif event is InputEventMouseButton and event.pressed:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			var i := flask_at(get_local_mouse_position())
			if pouring:
				get_viewport().set_input_as_handled()
				confirm()
			elif i >= 0:
				get_viewport().set_input_as_handled()
				cursor = i
				confirm()
		elif mb.button_index == MOUSE_BUTTON_RIGHT:
			get_viewport().set_input_as_handled()
			back()


func _process(delta: float) -> void:
	if not is_open:
		return
	_t += delta
	_grace -= delta
	for i in _lift.size():
		_lift[i] = move_toward(_lift[i], 4.0 if i == cursor else 0.0, delta * 30.0)
	if _grace <= 0.0:
		if Input.is_action_just_pressed("move_right"):
			move(1)
		elif Input.is_action_just_pressed("move_left"):
			move(-1)
		elif Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("attack"):
			confirm()
		elif Input.is_action_just_pressed("block") and not pouring:
			pour()
		elif Input.is_action_just_pressed("dash") or Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("block"):
			back()
	queue_redraw()


func _draw() -> void:
	if not is_open:
		return
	draw_rect(PANEL.grow(2), SOFT)
	draw_rect(PANEL, BG)
	var title := "Choose a flask"
	PixelFont.draw(self, Vector2(roundf(320 - PixelFont.width(title, 14) * 0.5), PANEL.position.y + 20), title, 14, ACCENT)
	# The shelf the flasks stand on.
	var shelf_y := flask_center(0).y + BODY_R + 2
	draw_rect(Rect2(PANEL.position.x + 24, shelf_y, PANEL.size.x - 48, 3), Color("5a4630"))
	draw_rect(Rect2(PANEL.position.x + 24, shelf_y + 3, PANEL.size.x - 48, 2), Color("2e2318"))
	for i in slots.size():
		_flask(i)
	# The focused flask's journey.
	var box := Rect2(PANEL.position.x + 10, shelf_y + 12, PANEL.size.x - 20, 46)
	draw_rect(box, Color(1, 1, 1, 0.04))
	var lines := details()
	for j in lines.size():
		var size := 10 if j == 0 else 9
		var color := (Color("ff8a7a") if pouring else TEXT) if j == 0 else SOFT
		var w := PixelFont.width(lines[j], size)
		PixelFont.draw(self, Vector2(roundf(320 - w * 0.5), box.position.y + 13 + j * 13), lines[j], size, color)
	var hint := "Jump: pour it out   Dash: keep it" if pouring else ("Left/Right: choose   Jump: take it up   Block: pour out   Dash: back" if not saves[cursor].is_empty() else "Left/Right: choose   Jump: begin   Dash: back")
	PixelFont.draw(self, Vector2(roundf(PANEL.end.x - 12 - PixelFont.width(hint, 8)), PANEL.end.y - 8), hint, 8, DIM.lightened(0.2))


## One flask: a round body and a neck of glass, the spring's color inside as
## high as the rank, stoppered when it holds a journey.
func _flask(i: int) -> void:
	var c := flask_center(i) - Vector2(0, roundf(_lift[i]))
	var s: Dictionary = saves[i]
	var color: Color = COLORS[i % COLORS.size()]
	var full := not s.is_empty()
	var focused := i == cursor
	if focused:
		# A soft glow behind the focused flask, breathing.
		var a := 0.10 + 0.05 * sin(_t * 3.0)
		for k in 4:
			draw_circle(c, BODY_R + 14 - k * 4, Color(color if full else SOFT, a * (0.5 + k * 0.25)))
	# Neck and body, dark glass first.
	var neck := Rect2(c.x - 7, c.y - BODY_R - 16, 14, 18)
	var dark := GLASS_DARK.lerp(Color(color.darkened(0.7), GLASS_DARK.a), 0.25)
	draw_rect(neck, dark)
	draw_circle(c, BODY_R, dark)
	if full:
		var level := c.y + BODY_R - 2.0 * BODY_R * float(s.fill) + sin(_t * 2.0 + i) * 0.8
		draw_colored_polygon(_below(c, BODY_R - 2, level), Color(color, 0.85))
		draw_colored_polygon(_below(c, BODY_R - 6, level + 3), Color(color.lightened(0.25), 0.5))
		# Bubbles rise through it.
		for b in 3:
			var phase := fmod(_t * (0.35 + b * 0.12) + b * 0.37 + i * 0.21, 1.0)
			var bx := c.x - 9 + b * 9 + sin(_t * 2.0 + b) * 2.0
			var by := lerpf(c.y + BODY_R - 6, level + 2, phase)
			if by > level + 1:
				draw_rect(Rect2(roundf(bx), roundf(by), 2, 2), Color(1, 1, 1, 0.55))
	# The glass: an outline, a highlight, the lip. Each flask's glass keeps a
	# hint of its spring's color, full or empty, so the three are told apart
	# by color alone.
	var glass := GLASS.lerp(Color(color, GLASS.a), 0.35)
	draw_arc(c, BODY_R, deg_to_rad(-62), deg_to_rad(242), 40, Color(glass, 0.9 if focused else 0.6), 2.0)
	draw_line(Vector2(neck.position.x, neck.end.y - 2), neck.position, Color(glass, 0.9 if focused else 0.6), 2.0)
	draw_line(Vector2(neck.end.x, neck.end.y - 2), Vector2(neck.end.x, neck.position.y), Color(glass, 0.9 if focused else 0.6), 2.0)
	draw_rect(Rect2(neck.position.x - 3, neck.position.y - 3, neck.size.x + 6, 4), Color(glass, 0.9 if focused else 0.65))
	draw_arc(c + Vector2(-7, -7), BODY_R * 0.55, deg_to_rad(190), deg_to_rad(250), 8, Color(1, 1, 1, 0.5), 2.0)
	if full:
		# The cork, and a thread round the neck in the spring's color.
		draw_rect(Rect2(c.x - 6, neck.position.y - 10, 12, 8), CORK)
		draw_rect(Rect2(c.x - 6, neck.position.y - 10, 12, 2), CORK.lightened(0.25))
		draw_rect(Rect2(neck.position.x, neck.end.y - 7, neck.size.x, 2), color.darkened(0.2))
	else:
		# An empty flask stands open, a little dust in its foot.
		draw_rect(Rect2(c.x - 10, c.y + BODY_R - 5, 20, 2), Color(SOFT, 0.25))


## The part of a circle below the line y = `level`, as a polygon.
static func _below(c: Vector2, r: float, level: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var dy := clampf((level - c.y) / r, -1.0, 1.0)
	var a0 := asin(dy)
	var a1 := PI - a0
	var steps := 24
	for k in steps + 1:
		var a := lerpf(a0, a1, float(k) / steps)
		pts.append(c + Vector2(cos(a), sin(a)) * r)
	return pts
