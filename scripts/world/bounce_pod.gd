class_name BouncePod
extends Node2D
## A bounce-pod (Branches, design bible 3.2 and 6.6): a fat seed-pod growing on
## the bough. Land on it from above and it squashes and throws you about nine
## tiles up (MovementTuning.pod_bounce). It isn't solid: walk into it and you
## walk through, so a hop onto it is all it takes. Legend `@`, standing on the
## floor of its cell.

## The pod's top, above its base (world pixels), and its half width.
const HEIGHT := 10.0
const HALF_W := 9.0
## How far below the top the feet may be and still count as landing on it.
const CATCH := 10.0
const SQUASH_TIME := 0.3
const SKIN := Color("8cc050")
const SKIN_LIGHT := Color("c8e880")
const SKIN_DARK := Color("4a7a30")
const OUTLINE := Color("1c2418")
const SEED := Color("f0d070")

var _squash := 0.0
var _feet_before := INF


func _ready() -> void:
	add_to_group("bounce_pod")


func top_y() -> float:
	return global_position.y - HEIGHT


func _physics_process(delta: float) -> void:
	_squash = maxf(0.0, _squash - delta)
	var p := get_tree().get_first_node_in_group("player") as Player
	if p == null or p.dead:
		return
	var feet := p.global_position
	var over := absf(feet.x - global_position.x) <= HALF_W + 4.0
	# Landing: the feet come down through the pod's top while falling.
	if over and p.velocity.y >= 0.0 and _feet_before <= top_y() + 2.0 and feet.y >= top_y() and feet.y <= top_y() + CATCH:
		launch(p)
	_feet_before = feet.y
	if _squash > 0.0:
		queue_redraw()


func launch(p: Player) -> void:
	p.global_position.y = top_y()
	p.pod_launch()
	_squash = SQUASH_TIME
	_feet_before = INF
	Sfx.play("pod", 0.1, 0.0)
	queue_redraw()


func _draw() -> void:
	# Squashed flat at the launch, then springing back past round.
	var k := _squash / SQUASH_TIME
	var sy := 1.0 - 0.45 * k * k + 0.15 * sin(k * PI) * (1.0 - k)
	var sx := 1.0 + 0.3 * k * k
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(sx, sy))
	# The stalk, the bulb, its lit side, the seam and a seed showing through.
	_px(-2, -4, 4, 4, OUTLINE)
	_px(-1, -4, 2, 4, SKIN_DARK)
	_px(-18, -20, 36, 17, OUTLINE)
	_px(-16, -21, 32, 19, OUTLINE)
	_px(-16, -19, 32, 15, SKIN)
	_px(-14, -20, 28, 17, SKIN)
	_px(-12, -19, 12, 4, SKIN_LIGHT)
	_px(-14, -9, 28, 3, SKIN_DARK)
	_px(-1, -20, 2, 15, SKIN_DARK)
	_px(4, -15, 4, 4, SEED)
	_px(-10, -13, 3, 3, SEED)
	draw_set_transform(Vector2.ZERO)


## A rect in half-pixels (the 2x render density), y up from the base.
func _px(x: int, y: int, w: int, h: int, color: Color) -> void:
	draw_rect(Rect2(x * 0.5, y * 0.5, w * 0.5, h * 0.5), color)
