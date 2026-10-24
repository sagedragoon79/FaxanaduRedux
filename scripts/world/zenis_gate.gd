class_name ZenisGate
extends Node2D
## The gate of Zenis (room prop `zenis_gate`, design bible 9): a great door of
## black meteor-iron set in the rock at the top of the Meteor Rise, four ring
## sockets in its face (Elf, Ruby, Dworf, Demon). Each socket glows once you
## hold that ring. It stays shut until all four are held and the shadow before
## it is beaten (bible 8.8; neither is built yet), so walking up to it only
## tells you what it wants. Scenery, drawn at 2x density. The origin is the
## bottom centre (it stands on the floor).

const OUTLINE := Color("0c0a12")
const IRON := Color("2a2438")
const IRON_LIGHT := Color("4a4260")
const IRON_DARK := Color("181424")
const VEIN := Color("e05ad0")
const SOCKET := Color("3a3448")
const RINGS := ["elf", "ruby", "dworf", "demon"]
const RING_COLORS := {"elf": Color("8fe07a"), "ruby": Color("e0405a"), "dworf": Color("e0b050"), "demon": Color("b070f0")}
const WIDTH := 56.0
const HEIGHT := 80.0
## How near (px) you must come for it to speak.
const NEAR := 40.0

var _told := false
var _t := 0.0


func _ready() -> void:
	z_index = -2


## The rings the player holds, in socket order.
func lit() -> Array:
	var rings: Array = GameState.data.get("rings", [])
	return RINGS.filter(func(r: String) -> bool: return rings.has(r))


func message() -> String:
	var n := lit().size()
	if n < RINGS.size():
		return "The gate of Zenis. Four sockets for four rings: %d of them glow." % n
	return "All four rings burn in the gate. It does not open: something in the dark before it is watching you."


func _process(delta: float) -> void:
	_t += delta
	var p := get_tree().get_first_node_in_group("player") as Player
	if p != null and not p.dead:
		var near := absf(p.global_position.x - global_position.x) < WIDTH * 0.5 + NEAR and absf(p.global_position.y - global_position.y) < 24.0
		if near and not _told:
			_told = true
			GameState.toast.emit(message())
		elif not near:
			_told = false
	queue_redraw()


func _draw() -> void:
	var w := WIDTH
	var h := HEIGHT
	# The arch: a pointed frame of meteor-iron, veined with crystal.
	draw_rect(Rect2(-w * 0.5 - 6.0, -h, w + 12.0, h), OUTLINE)
	draw_colored_polygon(PackedVector2Array([Vector2(-w * 0.5 - 6.0, -h), Vector2(0, -h - 24.0), Vector2(w * 0.5 + 6.0, -h)]), OUTLINE)
	draw_rect(Rect2(-w * 0.5 - 4.0, -h + 2.0, w + 8.0, h - 2.0), IRON_LIGHT)
	draw_colored_polygon(PackedVector2Array([Vector2(-w * 0.5 - 4.0, -h + 2.0), Vector2(0, -h - 20.0), Vector2(w * 0.5 + 4.0, -h + 2.0)]), IRON_LIGHT)
	# The two leaves of the door.
	for side in [-1, 1]:
		var x0 := 0.0 if side > 0 else -w * 0.5
		draw_rect(Rect2(x0, -h + 4.0, w * 0.5, h - 4.0), IRON)
		draw_rect(Rect2(x0 + 2.0, -h + 6.0, w * 0.5 - 4.0, 1.0), IRON_DARK)
		draw_rect(Rect2(x0 + 2.0, -h * 0.5, w * 0.5 - 4.0, 1.0), IRON_DARK)
	draw_rect(Rect2(-0.5, -h + 4.0, 1.0, h - 4.0), OUTLINE)
	# Crystal veins creeping over the iron, pulsing faintly.
	var k := 0.4 + 0.3 * sin(_t * 2.0)
	for v: Array in [[-22, -70, 1, 20], [-22, -50, 8, 1], [14, -60, 1, 26], [8, -34, 7, 1], [-12, -20, 1, 14]]:
		draw_rect(Rect2(v[0], v[1], v[2], v[3]), Color(VEIN, k))
	# The four ring sockets in a row across the middle, lit by the rings you hold.
	var held := lit()
	for i in RINGS.size():
		var r: String = RINGS[i]
		var at := Vector2(-21.0 + i * 14.0, -h * 0.62)
		draw_circle(at, 5.0, OUTLINE)
		draw_circle(at, 4.0, SOCKET)
		if held.has(r):
			var glow := 0.75 + 0.25 * sin(_t * 3.0 + i)
			draw_circle(at, 6.5, Color(RING_COLORS[r], 0.25 * glow))
			draw_circle(at, 3.0, Color(RING_COLORS[r], glow))
			draw_circle(at, 1.0, Color(1, 1, 1, 0.8))
