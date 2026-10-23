class_name LiftCage
extends Interactable
## The Forepaw lift (design bible 4.4): an iron cage on a chain that stops at
## freed Forepaw, the Tower Foot and, down the outside of the trunk, the East
## Gate of Eolis. Room prop `lift`. It runs only once Zoradohna is beaten;
## until then its chain hangs slack. Press Up inside it to pick a stop (or,
## with no menu open to pick from, ride to its usual stop).

const OUTLINE := Color("120f19")
const IRON := Color("4a4560")
const IRON_LIGHT := Color("7a7296")
const BRASS := Color("cb8d16")
const CHAIN := Color("867ba2")
const FLOOR := Color("6e3a1a")
const FLOOR_LIGHT := Color("9a5a2c")
const IRON_DARK := Color("2a2638")
const BACK := Color("1d1928")
const SHADOW := Color(0.07, 0.06, 0.1, 0.6)
const BRASS_LIGHT := Color("f2c14e")
const BRASS_DARK := Color("8a5a12")
const RUST := Color("783c2b")
const LAMP := Color("ffb347")
const LAMP_CORE := Color("fff2b0")
## Every stop, top to bottom: [room, display name, tile the rider steps out on].
const STOPS := [
	["tower/forepaw", "Forepaw", Vector2i(71, 19)],
	["tower/foot", "Tower Foot", Vector2i(24, 41)],
	["eolis/east_gate", "Eolis, East Gate", Vector2i(4, 19)],
]
## Room id -> the stop a ride goes to by default.
const USUAL := {"tower/forepaw": "tower/foot", "tower/foot": "tower/forepaw", "eolis/east_gate": "tower/foot"}
const FLAG := "boss:zoradohna"
const W := 28.0
const H := 44.0

var room_id := ""


func _ready() -> void:
	super()
	prompt_height = H + 4.0
	z_index = -1


func running() -> bool:
	return GameState.flag(FLAG)


## The stop a ride from here goes to with no choice made: [room, tile].
func destination() -> Array:
	var to: String = USUAL.get(room_id, "")
	for stop: Array in STOPS:
		if stop[0] == to:
			return [stop[0], stop[2]]
	return []


## The other stops, as [room, name, tile].
func other_stops() -> Array:
	return STOPS.filter(func(s: Array) -> bool: return s[0] != room_id)


func interact(p: Player) -> void:
	if destination().is_empty():
		return
	if not running():
		GameState.say("", ["The cage hangs still. Its chain runs up into the dark, toward Forepaw.",
			"Somewhere above, something is holding the lift."])
		return
	if Menus.open_lift(get_tree(), p, self):
		return
	ride(p, destination()[0])


## Rides the cage to `stop_id`, stepping out beside the cage there.
func ride(p: Player, stop_id: String) -> void:
	var world := get_tree().get_first_node_in_group("world") as World
	if world == null:
		return
	for stop: Array in STOPS:
		if stop[0] == stop_id:
			Sfx.play("heavy", 0.0, -2.0)
			var cell: Vector2i = stop[2]
			world.travel(stop_id, Vector2(cell.x * Room.TILE + Room.TILE * 0.5, (cell.y + 1) * Room.TILE))
			p.velocity = Vector2.ZERO
			return


func _draw() -> void:
	# Drawn at 2x render density: `_px` takes half-pixels, origin at the floor's centre.
	var w := int(W * 2.0)
	var h := int(H * 2.0)
	var left := -w / 2
	var top := -h
	# The chain up out of sight, links alternating face-on and edge-on, swaying a
	# little when the lift runs.
	var sway := sin(t * 1.3) * (1.0 if running() else 0.0)
	var i := 0
	var y := top - 13
	while y > top - 340:
		var x := roundi(sway * float(top - 13 - y) / 160.0)
		if i % 2 == 0:
			_px(x - 3, y - 8, 6, 9, OUTLINE)
			_px(x - 2, y - 7, 4, 7, CHAIN)
			_px(x - 1, y - 6, 2, 5, OUTLINE)
			_px(x - 2, y - 7, 1, 3, IRON_LIGHT)
		else:
			_px(x - 2, y - 8, 4, 9, OUTLINE)
			_px(x - 1, y - 7, 2, 7, CHAIN)
		y -= 8
		i += 1
	# The shackle: a brass ring and a block over the roof.
	_px(-6, top - 8, 12, 6, OUTLINE)
	_px(-5, top - 7, 10, 4, IRON)
	_px(-5, top - 7, 10, 1, IRON_LIGHT)
	_px(-4, top - 13, 8, 6, OUTLINE)
	_px(-3, top - 12, 6, 4, BRASS)
	_px(-1, top - 11, 2, 2, OUTLINE)
	# Outline, then the back wall in shadow so the bars read against it.
	_px(left - 2, top - 2, w + 4, h + 2, OUTLINE)
	_px(left, top, w, h, BACK)
	# Bars, each with a lit edge and a dark one.
	var bar := left + 8
	while bar < left + w - 8:
		_px(bar, top + 8, 3, h - 18, OUTLINE)
		_px(bar, top + 8, 2, h - 18, IRON)
		_px(bar, top + 8, 1, h - 18, IRON_LIGHT)
		bar += 9
	# Corner posts.
	for px: int in [left, left + w - 5]:
		_px(px, top, 5, h, OUTLINE)
		_px(px + 1, top, 3, h, IRON)
		_px(px + 1, top, 1, h, IRON_LIGHT)
		_px(px + 3, top, 1, h, IRON_DARK)
	# The roof: a riveted plate with a lit rim and a shadow under it.
	_px(left - 2, top - 2, w + 4, 11, OUTLINE)
	_px(left, top, w, 8, IRON)
	_px(left, top, w, 2, IRON_LIGHT)
	_px(left, top + 7, w, 1, IRON_DARK)
	_px(left + 1, top + 9, w - 2, 2, SHADOW)
	var rv := left + 5
	while rv < left + w - 3:
		_px(rv, top + 3, 2, 2, IRON_LIGHT)
		_px(rv + 1, top + 4, 1, 1, IRON_DARK)
		rv += 10
	_px(left + 14, top + 5, 5, 1, RUST)
	# A brass band across the bars at hand height, riveted at every bar.
	var band := top + roundi(h * 0.45)
	_px(left, band - 1, w, 6, OUTLINE)
	_px(left, band, w, 4, BRASS)
	_px(left, band, w, 1, BRASS_LIGHT)
	_px(left, band + 3, w, 1, BRASS_DARK)
	bar = left + 8
	while bar < left + w - 8:
		_px(bar, band + 1, 2, 2, BRASS_LIGHT)
		bar += 9
	# The floor: wooden planks on an iron lip.
	var fl := -10
	_px(left - 2, fl - 1, w + 4, 11, OUTLINE)
	_px(left, fl, w, 6, FLOOR)
	_px(left, fl, w, 1, FLOOR_LIGHT)
	var seam := left + 11
	while seam < left + w:
		_px(seam, fl + 1, 1, 5, OUTLINE)
		seam += 13
	_px(left, fl + 6, w, 3, IRON)
	_px(left, fl + 6, w, 1, IRON_LIGHT)
	# A lantern hung from the roof's corner: lit when the lift runs.
	var lx := left + w - 12
	var ly := top + 11
	_px(lx + 2, ly, 1, 4, OUTLINE)
	_px(lx, ly + 4, 6, 9, OUTLINE)
	_px(lx + 1, ly + 5, 4, 7, LAMP if running() else IRON_DARK)
	if running():
		_px(lx + 2, ly + 6, 2, 3, LAMP_CORE)
		var glow := 0.12 + 0.03 * sin(t * 6.0)
		_px(lx - 4, ly + 2, 14, 15, Color(LAMP, glow))
		_px(lx - 2, ly, 10, 19, Color(LAMP, glow))
	draw_prompt()


func _px(x: int, y: int, w: int, h: int, color: Color) -> void:
	draw_rect(Rect2(x * 0.5, y * 0.5, w * 0.5, h * 0.5), color)
