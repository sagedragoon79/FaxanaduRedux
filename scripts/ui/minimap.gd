class_name Minimap
extends RefCounted
## The minimap (bible 12's UI list, pass 373): a small window in the HUD's top
## right corner showing the map around you at half the full map's scale. It
## shows what the full map shows (rooms you have walked, dimmed rooms a chart
## gives you, your room pulsing, shrines, still-shut key doors, and a blinking
## dot where you stand) so you can keep your bearings without opening the map.
## It hides while the full map, a menu or a dialog is up, and in the Guru Trials
## and the Boss Rush, whose clocks hold the top of the screen.

## The window's size in HUD pixels, and its gap from the screen's corner.
const SIZE := Vector2(96, 54)
const MARGIN := 10.0
## Half the full map's scale: one screen of a room is 20 x 11 here.
const SCALE := 0.5


## Where the window sits on a screen of `screen` size.
static func window(screen: Vector2) -> Rect2:
	return Rect2(Vector2(screen.x - MARGIN - SIZE.x, MARGIN), SIZE)


## What the window shows: each room in view as {id, rect, how}, `how` as the full
## map has it ("here", "visited" or "charted"), and the dot where you stand, all
## in window space (the window's top left is 0, 0). Your room's middle is the
## window's middle, so the map scrolls as you move from room to room.
static func layout(world: World) -> Dictionary:
	var out := {"rooms": [], "player": Vector2.INF}
	if world == null or world.room == null:
		return out
	var here: Dictionary = world.catalog.get(world.room.id, {})
	if here.is_empty():
		return out
	var here_rect := _rect(here)
	var origin := SIZE * 0.5 - here_rect.get_center()
	var view := Rect2(Vector2.ZERO, SIZE)
	for room_id: String in world.catalog:
		var info: Dictionary = world.catalog[room_id]
		var how := MapScreen.shown(room_id, info, world.room.id)
		if how == "":
			continue
		var r := _rect(info)
		r.position += origin
		if not r.intersects(view):
			continue
		out.rooms.append({"id": room_id, "rect": r, "how": how, "info": info})
	if world.player != null:
		var frac := world.player.global_position / (Vector2(here.size) * Room.TILE)
		out.player = origin + here_rect.position + frac.clamp(Vector2.ZERO, Vector2.ONE) * here_rect.size
	return out


static func _rect(info: Dictionary) -> Rect2:
	var r := MapScreen.room_rect(info)
	return Rect2(r.position * SCALE, r.size * SCALE)


## Whether the HUD should draw it now: not while the full map, a menu or a
## dialog beside it on the UI layer is open, nor in a Trial or the Rush.
static func showing(hud: Node) -> bool:
	if Trials.active() or BossRush.active():
		return false
	var layer := hud.get_parent()
	if layer == null:
		return true
	for c in layer.get_children():
		if (c is MapScreen and (c as MapScreen).is_open) or (c is ListMenu and (c as ListMenu).is_open) \
				or (c is DialogBox and (c as DialogBox).is_open):
			return false
	return true


## Draws the window on `canvas` (the HUD) at `at`, pulsing with `t`.
static func draw(canvas: CanvasItem, at: Rect2, world: World, t: float) -> void:
	var lay := layout(world)
	canvas.draw_rect(at.grow(1), MapScreen.OUTLINE)
	canvas.draw_rect(at, Color(0.05, 0.04, 0.09, 0.62))
	for room: Dictionary in lay.rooms:
		var r: Rect2 = (room.rect as Rect2).intersection(Rect2(Vector2.ZERO, SIZE))
		if r.size.x < 1.0 or r.size.y < 1.0:
			continue
		r.position += at.position
		var info: Dictionary = room.info
		var zone: Dictionary = World.ZONES.get(info.zone, {"color": MapScreen.DIM})
		var color: Color = zone.color
		match String(room.how):
			"charted":
				canvas.draw_rect(r, color.darkened(0.82))
				canvas.draw_rect(r, color.darkened(0.5), false, 1.0)
				continue
			"here":
				canvas.draw_rect(r, color.darkened(0.25 - 0.1 * sin(t * 4.0)))
			_:
				canvas.draw_rect(r, color.darkened(0.55))
		canvas.draw_rect(r, MapScreen.EDGE.darkened(0.35), false, 1.0)
		var full := (room.rect as Rect2)
		full.position += at.position
		for cell: Vector2i in info.get("shrines", []):
			var sp := full.position + Vector2(cell) / Vector2(info.size) * full.size
			if at.has_point(sp):
				canvas.draw_rect(Rect2(sp - Vector2(1, 2), Vector2(2, 3)), MapScreen.SHRINE)
		for lock: Dictionary in MapScreen.locked_doors(info):
			var lp := full.position + (Vector2(lock.cell) + Vector2(0.5, 1)) / Vector2(info.size) * full.size
			if at.has_point(lp):
				canvas.draw_rect(Rect2(lp - Vector2(1, 3), Vector2(2, 3)), MapScreen.LOCK)
	var dot: Vector2 = lay.player
	if dot != Vector2.INF and fmod(t, 0.6) < 0.4:
		var p := at.position + dot
		canvas.draw_rect(Rect2(p - Vector2(2, 3), Vector2(4, 4)), MapScreen.OUTLINE)
		canvas.draw_rect(Rect2(p - Vector2(1, 2), Vector2(2, 2)), MapScreen.PLAYER)
	canvas.draw_rect(at, Color(MapScreen.EDGE, 0.35), false, 1.0)
