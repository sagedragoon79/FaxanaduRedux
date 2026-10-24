class_name Reach
extends RefCounted
## Reachability checker (design bible 14): proves, on the room grids alone,
## which places the player can get to with a given set of abilities, and
## whether they can always get back to a save point.
##
## It is a conservative approximation of the real controller. A node is a
## standing spot: room, tile column x and the tile row y holding the feet, with
## three clear tiles for the body and support below. Moves are walking, walking
## off ledges (with some drift), jumps within the safe envelope, doors, with
## the Climbing Glove climbing any wall face, and with the Mattock pogo bounces
## off spikes and thorn bulbs (see drop()), and with the Wing Boots a higher,
## longer jump (BOOT_JUMP), and from a bounce-pod a much higher one (POD_JUMP), and with the Elven
## Stride an air dash at the top of each (STRIDE_REACH). Numbers are a little under
## the movement spec so a route that passes here is comfortable in play.

## Safe jump envelope in tiles: rise -> max horizontal distance.
const JUMP := {0: 5, 1: 5, 2: 5, 3: 4, 4: 2}
## With the Wing Boots: a second jump at the top adds three tiles of rise
## (double_jump_height 48) and keeps the player in the air longer.
const BOOT_JUMP := {0: 7, 1: 7, 2: 7, 3: 6, 4: 6, 5: 5, 6: 3}
## Off a bounce-pod (legend `@`): pod_bounce 600 rises about nine tiles in play.
const POD_JUMP := {0: 5, 1: 5, 2: 5, 3: 5, 4: 5, 5: 5, 6: 4, 7: 3}
## With the Elven Stride: dash_speed 380 for 0.15 s is about 3.5 tiles, held level.
const STRIDE_REACH := 3
const DROP_DRIFT := 4
const RISE_FROM_FLOOR_DOOR := 4
const SOLID := "#CJu"
## Tiles the body can't stand in (hazards).
const HAZARD := "^o"

var rooms := {}        # room id -> {grid: Array[String], size: Vector2i, doors: {n: {...}}}
var abilities := {}    # ability -> bool
var keys := false      # may Jack doors be opened?

var _edges := {}       # node key -> Array of node keys
var _roots_open := {}  # room id -> true once its Root Heart is in reach


## `catalog_texts`: room id -> room text.
func _init(room_texts: Dictionary, ability_set: Dictionary, can_use_keys := false) -> void:
	abilities = ability_set
	keys = can_use_keys
	for id: String in room_texts:
		var parsed := Room.parse(room_texts[id])
		var grid: Array[String] = parsed.grid
		var width := 0
		for row in grid:
			width = maxi(width, row.length())
		var found := Room.scan_doors(grid)
		var doors := {}
		for spec: String in parsed.lists.get("door", []):
			var parts := spec.split(",")
			var n := int(parts[0])
			if found.has(n):
				doors[n] = {"rect": found[n].rect, "edge": found[n].edge, "target": parts[1].strip_edges(), "target_door": int(parts[2])}
		rooms[id] = {"grid": grid, "size": Vector2i(width, grid.size()), "doors": doors}


static func key(room_id: String, x: int, y: int) -> String:
	return "%s|%d|%d" % [room_id, x, y]


static func unkey(k: String) -> Array:
	var parts := k.split("|")
	return [parts[0], int(parts[1]), int(parts[2])]


# --- Tile queries ----------------------------------------------------------------

func ch(room_id: String, x: int, y: int) -> String:
	var g: Array[String] = rooms[room_id].grid
	if y < 0 or y >= g.size() or x < 0 or x >= g[y].length():
		return "#" if y >= 0 else "."
	return g[y][x]


func solid(room_id: String, x: int, y: int) -> bool:
	var c := ch(room_id, x, y)
	if c == "J":
		return not keys
	if c == "C":
		return not abilities.get("mattock", false)
	if c == "R":
		# A root-gate opens once the room's Root Heart can be struck.
		return not _roots_open.has(room_id)
	if c == "Q":
		# The flue damper stands open once Zoradohna falls and the winch turns.
		return not abilities.get("winch", false)
	if c == "Y":
		# Bound fog parts for the Lantern Key (Ripasheiku's reward).
		return not abilities.get("lantern", false)
	if c == "Z":
		# A fire seal goes out for good once a Deluge bolt strikes it.
		return not abilities.get("deluge", false)
	if c == "~":
		# Sap hardens into solid amber once the Spring of Trunk is restored.
		return abilities.get("amber", false)
	return SOLID.contains(c)


func clear(room_id: String, x: int, y: int) -> bool:
	return not solid(room_id, x, y)


## Room for the 3-tile body with the feet in row y.
func body_clear(room_id: String, x: int, y: int) -> bool:
	return clear(room_id, x, y) and clear(room_id, x, y - 1) and clear(room_id, x, y - 2)


func supported(room_id: String, x: int, y: int) -> bool:
	var below := ch(room_id, x, y + 1)
	return solid(room_id, x, y + 1) or below == "-" or (below == "=" and abilities.get("deluge", false)) \
		or (below == "b" and abilities.get("spring_mist", false))


func standable(room_id: String, x: int, y: int) -> bool:
	var size: Vector2i = rooms[room_id].size
	if x < 0 or x >= size.x or y < 0 or y >= size.y:
		return false
	return body_clear(room_id, x, y) and supported(room_id, x, y) and not HAZARD.contains(ch(room_id, x, y))


## Where something falling down column x from row y lands, or -1 if it leaves
## the room (through a floor door) or never lands. With the Mattock, a fall onto
## spikes or a thorn bulb is a pogo: it "lands" just above the hazard, and the
## bounce works like a jump from there.
func drop(room_id: String, x: int, y: int) -> int:
	var h: int = rooms[room_id].size.y
	var yy := y
	while yy < h:
		if not clear(room_id, x, yy):
			return -1
		if HAZARD.contains(ch(room_id, x, yy)):
			if abilities.get("mattock", false) and yy > y:
				return yy - 1
			return -1
		if supported(room_id, x, yy):
			return yy
		yy += 1
	return -1


# --- The graph ---------------------------------------------------------------------

func neighbors(k: String) -> Array:
	if _edges.has(k):
		return _edges[k]
	var out := []
	var n := Reach.unkey(k)
	var r: String = n[0]
	var x: int = n[1]
	var y: int = n[2]
	for s: int in [-1, 1]:
		# Walk.
		if standable(r, x + s, y):
			out.append(key(r, x + s, y))
		# Walk off a ledge, drifting up to DROP_DRIFT columns while falling.
		elif body_clear(r, x + s, y):
			for dx in range(1, DROP_DRIFT + 1):
				var cx := x + s * dx
				if not body_clear(r, cx, y):
					break
				var land := drop(r, cx, y)
				if land > y:
					out.append(key(r, cx, land))
		# Jumps up, across and down.
		_add_jumps(out, r, x, y, s)
	# Drop through a one-way platform (Down + Jump).
	if ch(r, x, y + 1) == "-":
		var below := drop(r, x, y + 1)
		if below > y:
			out.append(key(r, x, below))
	if abilities.get("glove", false):
		_add_climbs(out, r, x, y)
	_add_doors(out, r, x, y)
	_edges[k] = out
	return out


## With the Elven Stride, an air dash at the top of any jump carries the body
## STRIDE_REACH tiles further across.
static func _strided(envelope: Dictionary) -> Dictionary:
	var out := {}
	for rise: int in envelope:
		out[rise] = int(envelope[rise]) + STRIDE_REACH
	return out


## A jump from (x, y): rise straight up to the target's height (head room in
## column x), then travel across with the body clear, then land.
func _add_jumps(out: Array, r: String, x: int, y: int, s: int) -> void:
	var envelope: Dictionary = BOOT_JUMP if abilities.get("boots", false) else JUMP
	if ch(r, x, y) == "@":
		envelope = POD_JUMP
	if abilities.get("stride", false):
		envelope = _strided(envelope)
	for rise: int in envelope:
		var top := y - rise
		var ok := true
		for yy in range(top - 2, y - 2):
			if not clear(r, x, yy):
				ok = false
				break
		if not ok:
			break
		for dx in range(1, int(envelope[rise]) + 1):
			var cx := x + s * dx
			if not body_clear(r, cx, top):
				break
			if standable(r, cx, top):
				out.append(key(r, cx, top))
			else:
				var land := drop(r, cx, top)
				if land >= 0:
					out.append(key(r, cx, land))


## With the glove: jump at a wall (straight up, or one column over), then climb
## that column while a wall is beside it, and jump off from any height reached.
func _add_climbs(out: Array, r: String, x: int, y: int) -> void:
	for cx: int in [x, x - 1, x + 1]:
		for lift in range(0, 5):
			var y0 := y - lift
			if not body_clear(r, cx, y0) or not body_clear(r, x, y0):
				break
			var yy := y0
			while body_clear(r, cx, yy - 1) and (solid(r, cx - 1, yy - 2) or solid(r, cx + 1, yy - 2)):
				yy -= 1
				if standable(r, cx, yy):
					out.append(key(r, cx, yy))
				for s: int in [-1, 1]:
					_add_jumps(out, r, cx, yy, s)
			# Reaching a ceiling door by climbing.
			if yy <= 3:
				_door_at(out, r, cx, 0)


func _add_doors(out: Array, r: String, x: int, y: int) -> void:
	var size: Vector2i = rooms[r].size
	# Side doors: walk into the edge column.
	for s: int in [-1, 1]:
		if x + s == 0 or x + s == size.x - 1:
			for yy in range(y - 2, y + 1):
				_door_at(out, r, x + s, yy)
	# Floor doors: fall through a gap.
	for s: int in [-1, 0, 1]:
		var cx := x + s
		var yy := y + (1 if s == 0 else 0)
		while yy < size.y and clear(r, cx, yy):
			if Room.DOOR_CHARS.contains(ch(r, cx, yy)) and yy == size.y - 1:
				_door_at(out, r, cx, yy)
				break
			if s != 0 and supported(r, cx, yy):
				break
			yy += 1
	# Ceiling doors: jump into them.
	if y - 2 - 4 <= 0:
		var yy := y - 3
		while yy >= 0 and clear(r, x, yy):
			yy -= 1
		if yy < 0:
			_door_at(out, r, x, 0)
	# Inner doors: stand in them.
	if Room.DOOR_CHARS.contains(ch(r, x, y)):
		_door_at(out, r, x, y)


func _door_at(out: Array, r: String, x: int, y: int) -> void:
	var c := ch(r, x, y)
	if not Room.DOOR_CHARS.contains(c):
		return
	var d: Dictionary = rooms[r].doors.get(int(c), {})
	if d.is_empty() or not rooms.has(d.target):
		return
	var arrive: Dictionary = rooms[d.target].doors.get(d.target_door, {})
	if arrive.is_empty():
		return
	var t: String = d.target
	var rect: Rect2i = arrive.rect
	var cx := rect.position.x + rect.size.x / 2
	match arrive.edge:
		"left":
			var land := drop(t, rect.end.x, rect.end.y - 1)
			if land >= 0:
				out.append(key(t, rect.end.x, land))
		"right":
			var land := drop(t, rect.position.x - 1, rect.end.y - 1)
			if land >= 0:
				out.append(key(t, rect.position.x - 1, land))
		"top":
			var land := drop(t, cx, rect.end.y + 2)
			if land >= 0:
				out.append(key(t, cx, land))
		"bottom":
			# Popping up out of a floor door: land on a ledge near the top of the rise.
			var top := rect.position.y - RISE_FROM_FLOOR_DOOR
			for dx in range(-3, 4):
				for yy in range(top, rect.position.y):
					if standable(t, cx + dx, yy):
						out.append(key(t, cx + dx, yy))
		_:
			var land := drop(t, cx, rect.end.y - 1)
			if land >= 0:
				out.append(key(t, cx, land))


# --- Searches ----------------------------------------------------------------------

## Every node reachable from `start`, opening root-gates whose heart comes in
## reach along the way.
func reachable(start: String) -> Dictionary:
	while true:
		var seen := _flood(start)
		var opened := false
		for id: String in rooms:
			if _roots_open.has(id):
				continue
			var g: Array[String] = rooms[id].grid
			for y in g.size():
				var x := g[y].find("N")
				if x >= 0 and touchable(seen, id, x, y):
					_roots_open[id] = true
					opened = true
		if not opened:
			return seen
		_edges.clear()
	return {}


func _flood(start: String) -> Dictionary:
	var seen := {start: true}
	var queue := [start]
	while not queue.is_empty():
		var k: String = queue.pop_back()
		for nb: String in neighbors(k):
			if not seen.has(nb):
				seen[nb] = true
				queue.append(nb)
	return seen


## Nodes in `nodes` that can't get back to any node in `goals`.
func stuck(nodes: Dictionary, goals: Array) -> Array:
	# Reverse edges over the known nodes, then search back from the goals.
	var rev := {}
	for k: String in nodes:
		for nb: String in neighbors(k):
			if not rev.has(nb):
				rev[nb] = []
			rev[nb].append(k)
	var back := {}
	var queue := []
	for g: String in goals:
		if nodes.has(g):
			back[g] = true
			queue.append(g)
	while not queue.is_empty():
		var k: String = queue.pop_back()
		for prev: String in rev.get(k, []):
			if not back.has(prev):
				back[prev] = true
				queue.append(prev)
	var out := []
	for k: String in nodes:
		if not back.has(k):
			out.append(k)
	return out


## Standing spot for the first `ch` found in a room (feet in that tile, or the
## first landing below it for things that float).
func spot_of(room_id: String, marker: String) -> String:
	var g: Array[String] = rooms[room_id].grid
	for y in g.size():
		var x := g[y].find(marker)
		if x >= 0:
			var land := y if standable(room_id, x, y) else drop(room_id, x, y)
			return key(room_id, x, land) if land >= 0 else ""
	return ""


## True if a pickup at tile (x, y) can be touched from some reachable node:
## standing in it, or jumping into it from below (within 4 tiles).
func touchable(nodes: Dictionary, room_id: String, x: int, y: int) -> bool:
	for dy in range(0, 7):
		for dx in range(-1, 2):
			if nodes.has(key(room_id, x + dx, y + dy)):
				if dy <= 2 or _column_clear(room_id, x + dx, y, y + dy):
					return true
	return false


func _column_clear(room_id: String, x: int, from_y: int, to_y: int) -> bool:
	for yy in range(from_y, to_y + 1):
		if not clear(room_id, x, yy):
			return false
	return true
