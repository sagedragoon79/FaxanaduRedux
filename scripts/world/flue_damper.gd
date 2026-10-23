class_name FlueDamper
extends StaticBody2D
## One tile of the iron damper that seals the Old Flue (room legend `Q`, a row
## of three is usual): riveted louvers shut flat across a shaft. Its chain runs
## up to the great winch in Winch Hall; once Zoradohna falls and the winch
## turns again (design bible 4.4), the louvers stand open and the flue can be
## climbed. Drawn at 2x render density: `_px` takes half-pixels.

const FLAG := "boss:zoradohna"
const OPEN_TIME := 0.5
const OUTLINE := Color("120f19")
const IRON := Color("4a4560")
const IRON_LIGHT := Color("7a7296")
const IRON_DARK := Color("2a2638")
const RUST := Color("783c2b")

var open := false
## 0 shut, 1 standing open.
var _t := 0.0
var _shape: CollisionShape2D


func _ready() -> void:
	collision_layer = Player.LAYER_WORLD
	collision_mask = 0
	add_to_group("flue_damper")
	_shape = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 16)
	_shape.shape = rect
	add_child(_shape)
	if GameState.flag(FLAG):
		set_open(true)


## Stands the louvers open; `instant` skips the swing.
func set_open(instant := false) -> void:
	open = true
	_t = 1.0 if instant else 0.0
	if _shape != null:
		_shape.set_deferred("disabled", true)
	queue_redraw()


func _physics_process(delta: float) -> void:
	if open and _t < 1.0:
		_t = minf(1.0, _t + delta / OPEN_TIME)
		queue_redraw()


func _draw() -> void:
	# A frame lip on each side, then four louvers: flat when shut, edge-on when open.
	_px(-16, -16, 3, 32, OUTLINE)
	_px(13, -16, 3, 32, OUTLINE)
	_px(-15, -16, 1, 32, IRON_LIGHT)
	var tilt := _t if open else 0.0
	for i in 4:
		var cy := -12 + i * 8
		var h := roundi(lerpf(8.0, 2.0, tilt))
		var y := cy - h / 2
		_px(-13, y, 26, h, OUTLINE)
		if h > 2:
			_px(-12, y + 1, 24, h - 2, IRON)
			_px(-12, y + 1, 24, 1, IRON_LIGHT)
			_px(-12, y + h - 2, 24, 1, IRON_DARK)
			_px(-9, y + 2, 2, 2, IRON_LIGHT)
			_px(7, y + 2, 2, 2, IRON_LIGHT)
			if (i + roundi(global_position.x / 16.0)) % 3 == 0:
				_px(2, y + h - 3, 4, 1, RUST)
		else:
			_px(-12, y, 24, 1, IRON_LIGHT)


func _px(x: int, y: int, w: int, h: int, color: Color) -> void:
	draw_rect(Rect2(x * 0.5, y * 0.5, w * 0.5, h * 0.5), color)
