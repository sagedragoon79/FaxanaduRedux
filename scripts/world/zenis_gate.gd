class_name ZenisGate
extends Node2D
## The gate of Zenis (room prop `zenis_gate`, design bible 9): a great door of
## black meteor-iron set in the rock at the top of the Meteor Rise, four ring
## sockets in its face (Elf, Ruby, Dworf, Demon). Each socket glows once you
## hold that ring. It stays shut until all four are held and the shadow before
## it (Shadow Eura, bible 8.8) is beaten. Shut, it bars the way from floor to
## vault and walking up to it only tells you what it wants; open, its leaves
## stand wide on the cyan light of the meteor's insides and you walk through
## (the room's door 2 is behind it). Drawn at 2x density. The origin is the
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
## The bar while shut: from the gate's west face to the wall behind it, and up
## to the vault.
const BAR := Rect2(-WIDTH * 0.5 - 6.0, -208.0, WIDTH + 18.0, 208.0)
const FLAG := "boss:shadow_eura"
const LIGHT := Color("60e8f0")

var _told := false
var _t := 0.0
var _bar: CollisionShape2D
## How far the leaves have swung open, 0 to 1.
var swing := 0.0


func _ready() -> void:
	z_index = -2
	var body := StaticBody2D.new()
	body.collision_layer = Player.LAYER_WORLD
	body.collision_mask = 0
	add_child(body)
	_bar = CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = BAR.size
	_bar.shape = r
	_bar.position = BAR.get_center()
	body.add_child(_bar)
	if is_open():
		swing = 1.0
		_bar.disabled = true


## True once all four rings are held and the shadow before it is beaten.
func is_open() -> bool:
	return lit().size() == RINGS.size() and GameState.flag(FLAG)


## The rings the player holds, in socket order.
func lit() -> Array:
	var rings: Array = GameState.data.get("rings", [])
	return RINGS.filter(func(r: String) -> bool: return rings.has(r))


func message() -> String:
	var n := lit().size()
	if n < RINGS.size():
		return "The gate of Zenis. Four sockets for four rings: %d of them glow." % n
	if not GameState.flag(FLAG):
		return "All four rings burn in the gate. It does not open: something in the dark before it is watching you."
	return "All four rings burn and nothing watches from the dark. The gate of Zenis stands open."


func _process(delta: float) -> void:
	_t += delta
	if is_open() and swing < 1.0:
		if swing == 0.0:
			Sfx.play("break", 0.0, -2.0)
			Feel.add_trauma(0.3)
		swing = minf(1.0, swing + delta * 0.8)
		if not _bar.disabled:
			_bar.set_deferred("disabled", true)
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
	# The doorway behind the leaves: the meteor's light, seen as they part.
	if swing > 0.0:
		draw_rect(Rect2(-w * 0.5, -h + 4.0, w, h - 4.0), Color("0a0612"))
		var k := 0.6 + 0.4 * sin(_t * 2.5)
		for i in 5:
			var hh := (h - 4.0) * (0.3 + 0.14 * i)
			draw_rect(Rect2(-w * 0.5 + 4.0 + i * 2.0, -hh, w - 8.0 - i * 4.0, hh), Color(LIGHT, 0.06 * k * swing))
	# The two leaves of the door, folding back as it opens.
	for side in [-1, 1]:
		var lw := w * 0.5 * (1.0 - 0.8 * swing)
		var x0 := (w * 0.5 - lw) if side > 0 else -w * 0.5
		draw_rect(Rect2(x0, -h + 4.0, lw, h - 4.0), IRON)
		draw_rect(Rect2(x0 + 1.0, -h + 6.0, maxf(lw - 2.0, 1.0), 1.0), IRON_DARK)
		draw_rect(Rect2(x0 + 1.0, -h * 0.5, maxf(lw - 2.0, 1.0), 1.0), IRON_DARK)
	if swing <= 0.0:
		draw_rect(Rect2(-0.5, -h + 4.0, 1.0, h - 4.0), OUTLINE)
	# Crystal veins creeping over the iron, pulsing faintly.
	var k := 0.4 + 0.3 * sin(_t * 2.0)
	if swing <= 0.0:
		for v: Array in [[-22, -70, 1, 20], [-22, -50, 8, 1], [14, -60, 1, 26], [8, -34, 7, 1], [-12, -20, 1, 14]]:
			draw_rect(Rect2(v[0], v[1], v[2], v[3]), Color(VEIN, k))
	# The four ring sockets in a row across the arch, lit by the rings you hold.
	var held := lit()
	for i in RINGS.size():
		var r: String = RINGS[i]
		# Set in the arch, above the leaves.
		var at := Vector2(-21.0 + i * 14.0, -h - 3.0)
		draw_circle(at, 5.0, OUTLINE)
		draw_circle(at, 4.0, SOCKET)
		if held.has(r):
			var glow := 0.75 + 0.25 * sin(_t * 3.0 + i)
			draw_circle(at, 6.5, Color(RING_COLORS[r], 0.25 * glow))
			draw_circle(at, 3.0, Color(RING_COLORS[r], glow))
			draw_circle(at, 1.0, Color(1, 1, 1, 0.8))
