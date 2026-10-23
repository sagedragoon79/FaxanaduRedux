class_name RootGate
extends StaticBody2D
## One tile of a root-gate (design bible 3, Trunk Hollows): living roots grown
## across a passage. They are solid until the room's Root Heart is struck, then
## draw back into the ceiling and stay open (remembered per room). Room legend
## `R`; a gate is usually a column of three.

const RETRACT_TIME := 0.6
const ROOT := Color("5e3a22")
const ROOT_DARK := Color("3a2416")
const ROOT_LIGHT := Color("8a5a34")
const SAP := Color("f0c02e")

var open := false
var _t := 0.0
var _shape: CollisionShape2D


func _ready() -> void:
	collision_layer = Player.LAYER_WORLD
	collision_mask = 0
	add_to_group("root_gate")
	_shape = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 16)
	_shape.shape = rect
	# A gate opened before it entered the tree (a room rebuilt on a later visit) starts open.
	_shape.disabled = open
	add_child(_shape)


## Draws the roots back; `instant` skips the animation (a gate already opened on an earlier visit).
func retract(instant := false) -> void:
	if open:
		return
	open = true
	if _shape != null:
		_shape.set_deferred("disabled", true)
	_t = RETRACT_TIME if instant else 0.0
	queue_redraw()


func _physics_process(delta: float) -> void:
	if open and _t < RETRACT_TIME:
		_t += delta
		queue_redraw()


func _draw() -> void:
	# Drawn at 2x render density: `_px` takes half-pixels. The strands sway with
	# world height so a column of gate tiles reads as one tangle.
	var gone := clampf(_t / RETRACT_TIME, 0.0, 1.0) if open else 0.0
	if gone >= 1.0:
		return
	var top := -16
	var bottom := roundi(lerpf(16.0, -16.0, gone))
	var wy := global_position.y
	# A dark backing so the gate reads as a wall of roots, then five strands.
	_px(-15, top, 30, bottom - top, Color(ROOT_DARK, 0.85))
	for s in 5:
		var phase := s * 1.7
		for hy in range(top, bottom, 2):
			var w := sin((wy + hy * 0.5) * 0.17 + phase) * 3.0
			var x := roundi(-12 + s * 6 + w)
			_px(x - 3, hy, 7, 2, ROOT_DARK)
			_px(x - 2, hy, 5, 2, ROOT)
			_px(x - 2, hy, 2, 2, ROOT_LIGHT)
	# Cross roots and sap beads, fixed in world space.
	for hy in range(top, bottom, 2):
		if posmod(roundi(wy * 2.0) + hy, 22) == 0:
			_px(-15, hy, 30, 3, ROOT)
			_px(-15, hy, 30, 1, ROOT_LIGHT)
			_px(-4, hy + 1, 2, 2, SAP)


func _px(x: int, y: int, w: int, h: int, color: Color) -> void:
	draw_rect(Rect2(x * 0.5, y * 0.5, w * 0.5, h * 0.5), color)
