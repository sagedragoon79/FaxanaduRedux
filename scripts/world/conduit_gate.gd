class_name ConduitGate
extends StaticBody2D
## One tile of a conduit gate (room legend `k`, a column of three is usual,
## design bible 4.5): an elf-silver shutter with a lightning glyph, dark while
## the room's conduits are dead. When the last conduit wakes it slides up into
## its frame for good (flag "conduits:<room id>").
## Drawn at 2x render density: `_px` takes half-pixels.

const OPEN_TIME := 0.8
const SILVER := Color("a8a4c0")
const SILVER_LIGHT := Color("d8d4ec")
const SILVER_DARK := Color("5a5670")
const OUTLINE := Color("13101f")
const GLYPH_DEAD := Color("3a3a5a")
const GLYPH_LIVE := Color("e8c04a")

var flag_id := ""
var opened := false
## 0 shut, 1 fully up.
var _t := 0.0
var _shape: CollisionShape2D


func _init() -> void:
	collision_layer = Player.LAYER_WORLD
	collision_mask = 0
	_shape = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 16)
	_shape.shape = rect
	add_child(_shape)


func _ready() -> void:
	add_to_group("conduit_gate")
	if flag_id != "" and GameState.flag(flag_id):
		open(true)


func open(instant: bool) -> void:
	if opened:
		return
	opened = true
	_t = 1.0 if instant else 0.0
	if is_inside_tree():
		_shape.set_deferred("disabled", true)
	else:
		_shape.disabled = true
	if not instant:
		Sfx.play("rumble", 0.0, -6.0)
	queue_redraw()


func _process(delta: float) -> void:
	if opened and _t < 1.0:
		_t = minf(1.0, _t + delta / OPEN_TIME)
		queue_redraw()


func _draw() -> void:
	if _t >= 1.0:
		return
	# The shutter slides up out of view: clip by drawing only what is left.
	var lift := roundi(_t * 32.0)
	var h := 32 - lift
	_px(-16, -16, 32, h, OUTLINE)
	_px(-14, -16, 28, h, SILVER_DARK)
	for i in 4:
		if i * 8 + 2 < h:
			_px(-14, -16 + i * 8, 28, mini(6, h - i * 8), SILVER)
			_px(-14, -16 + i * 8, 28, 1, SILVER_LIGHT)
	if h > 20:
		var glyph := GLYPH_LIVE if opened else GLYPH_DEAD
		_px(1, -12, 3, 6, glyph)
		_px(-2, -7, 5, 2, glyph)
		_px(-3, -5, 3, 6, glyph)


func _px(x: int, y: int, w: int, h: int, color: Color, alpha := 1.0) -> void:
	draw_rect(Rect2(x * 0.5, y * 0.5, w * 0.5, h * 0.5), Color(color, color.a * alpha))
