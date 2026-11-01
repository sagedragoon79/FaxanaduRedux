class_name DrownedStatue
extends Node2D
## The drowned king (room prop `drowned_statue`, pass 371), a Sunken Spring
## landmark in Spring Gate: a dwarf king carved in stone, taller than a house,
## standing on the floor of the flooded shaft with his hammer grounded and his
## crowned head bowed. The dwarves raised him over the spring; the water rose
## over him. Weed sways from his beard and crown, and now and then a bead of
## air escapes his lips. Scenery only, drawn behind the water (z -2) so the
## flood tints him. The origin is the bottom center, on the floor.

const HEIGHT := 224.0
const HALF_WIDTH := 46.0
const OUTLINE := Color("0c141c")
const STONE := Color("5a6a78")
const STONE_LIGHT := Color("8a9aa6")
const STONE_DARK := Color("36424e")
const MOSS := Color("3e7a5a")
const WEED := Color("4f9a6a")
const BUBBLE := Color("c8f4f0")
const CROWN := Color("8a8a6a")

var t := 0.0


func _ready() -> void:
	z_index = -2


func _process(delta: float) -> void:
	t += delta
	queue_redraw()


func _px(x: float, y: float, w: float, h: float, c: Color) -> void:
	draw_rect(Rect2(roundf(x), roundf(y), w, h), c)


## A block of carved stone, outlined, lit from the upper left.
func _block(x: float, y: float, w: float, h: float) -> void:
	_px(x - 1, y - 1, w + 2, h + 2, OUTLINE)
	_px(x, y, w, h, STONE)
	_px(x, y, w, 2, STONE_LIGHT)
	_px(x, y, 2, h, STONE_LIGHT)
	_px(x + w - 3, y, 3, h, STONE_DARK)


func _draw() -> void:
	# Plinth, cracked and slipped a little to one side.
	_block(-HALF_WIDTH, -18, HALF_WIDTH * 2.0, 18)
	_px(-6, -18, 2, 18, OUTLINE)
	# Legs under a long robe, and big square boots.
	_block(-30, -34, 24, 16)
	_block(6, -34, 24, 16)
	# The robe, widening to the hem.
	var y := -34.0
	while y > -120.0:
		var k := (y + 34.0) / -86.0
		var w := lerpf(36.0, 26.0, k)
		_px(-w - 1, y - 2, w * 2.0 + 2, 2, OUTLINE)
		_px(-w, y - 2, w * 2.0, 2, STONE)
		_px(-w, y - 2, 3, 2, STONE_LIGHT)
		_px(w - 4, y - 2, 4, 2, STONE_DARK)
		# Folds running down the robe.
		for f in 3:
			_px(lerpf(-w + 8, w - 8, (f + 0.5) / 3.0), y - 2, 2, 2, STONE_DARK)
		y -= 2.0
	# A belt with a square buckle.
	_block(-28, -96, 56, 6)
	_px(-4, -97, 8, 8, STONE_LIGHT)
	# The hammer: the head on the plinth beside him, the haft up into both fists.
	_block(28, -40, 18, 22)
	_px(35, -112, 5, 72, OUTLINE)
	_px(36, -112, 3, 72, STONE_DARK)
	# Shoulders and arms, the fists clasped over the haft's end.
	_block(-34, -140, 68, 22)
	_block(-34, -122, 12, 26)
	_block(22, -122, 12, 26)
	_block(26, -120, 20, 12)
	# The beard, a long wedge braided at the tip, down over the chest.
	var by := -128.0
	while by < -78.0:
		var k := (by + 128.0) / 50.0
		var bw := lerpf(22.0, 4.0, k)
		_px(-bw - 1, by, bw * 2.0 + 2, 2, OUTLINE)
		_px(-bw, by, bw * 2.0, 2, STONE_LIGHT if int(by) % 6 == 0 else STONE)
		by += 2.0
	# The head, bowed: a heavy brow over shut eyes, a broad nose.
	var head := Vector2(-2, -164)
	_block(head.x - 18, head.y, 36, 30)
	_px(head.x - 14, head.y + 10, 28, 3, STONE_DARK)
	_px(head.x - 10, head.y + 15, 6, 1, OUTLINE)
	_px(head.x + 4, head.y + 15, 6, 1, OUTLINE)
	_px(head.x - 3, head.y + 13, 6, 9, STONE_LIGHT)
	_px(head.x - 3, head.y + 21, 6, 1, STONE_DARK)
	# The crown: a band with five blunt points, one broken off.
	_px(head.x - 20, head.y - 6, 40, 7, OUTLINE)
	_px(head.x - 19, head.y - 5, 38, 5, CROWN)
	for i in 5:
		if i == 3:
			continue
		var cx := head.x - 18 + i * 9
		_px(cx - 1, head.y - 14, 6, 9, OUTLINE)
		_px(cx, head.y - 13, 4, 8, CROWN)
	# Moss on every upward face.
	for m: Vector2 in [Vector2(-34, -141), Vector2(-HALF_WIDTH, -19), Vector2(head.x - 19, head.y - 7), Vector2(14, -141)]:
		_px(m.x, m.y, 20, 2, MOSS)
	# Weed growing from the crown and the beard's tip, swaying in the current.
	for s: Array in [[Vector2(head.x - 14, head.y - 14), 28.0, 0.0], [Vector2(head.x + 12, head.y - 14), 20.0, 1.7], [Vector2(-1, -78), 22.0, 3.1]]:
		var base: Vector2 = s[0]
		var length: float = s[1]
		var phase: float = s[2]
		var h := 0.0
		while h < length:
			var sway := sin(t * 1.3 + phase + h * 0.12) * h * 0.18
			_px(base.x + sway, base.y - h - 2, 2, 2, WEED)
			h += 2.0
	# A bead of air slips from his lips every few seconds and climbs.
	var cycle := fmod(t, 3.2) / 3.2
	var mouth := Vector2(head.x, head.y + 25)
	var rise := cycle * 110.0
	if cycle < 0.85:
		_px(mouth.x + sin(t * 4.0) * 2.0 - 1, mouth.y - rise, 3, 3, Color(BUBBLE, 0.8 - cycle * 0.6))
