class_name Conduit
extends Node2D
## A dead lightning conduit (room legend `c`, design bible 4.5): a copper coil
## on a stone plinth, a dim blue spark at its crown. A Thunder bolt that passes
## near leaps to it (group "conductor") and wakes it for good: the coil glows,
## arcs crawl up it, and it lights the fog. Once every conduit in the room is
## awake, the room's conduit gates slide open (flag "conduits:<room id>").
## Drawn at 2x render density: `_px` takes half-pixels. Not solid.

const COPPER := Color("c88a3a")
const COPPER_LIGHT := Color("f0b860")
const COPPER_DARK := Color("6e4220")
const STONE := Color("8a84a0")
const STONE_DARK := Color("4a4560")
const OUTLINE := Color("13101f")
const DIM := Color("4a6ab8")
const LIVE := Color("b8a8ff")
const SPARK := Color("f8f0b0")

## "conduit:<room>:<x>,<y>": this conduit is awake.
var flag_id := ""
## "conduits:<room>": every conduit in the room is awake.
var room_flag := ""
var powered := false
var light_radius := 0.0
var _clock := 0.0


func _ready() -> void:
	z_index = -1
	add_to_group("conductor")
	_clock = fmod(global_position.x * 0.37, 5.0)
	if flag_id != "" and GameState.flag(flag_id):
		_wake(true)


## Where the bolt's arc lands: the coil's crown.
func spark_point() -> Vector2:
	return global_position + Vector2(0, -28)


## A Thunder bolt woke it.
func power() -> void:
	if powered:
		return
	_wake(false)
	if flag_id != "":
		GameState.set_flag(flag_id)
	Sfx.play("spark_up", 0.05)
	Feel.add_trauma(0.12)
	for n in get_tree().get_nodes_in_group("conductor"):
		if not (n as Conduit).powered:
			return
	# The last one: the room's gates open.
	if room_flag != "":
		GameState.set_flag(room_flag)
	for g in get_tree().get_nodes_in_group("conduit_gate"):
		(g as ConduitGate).open(false)


func _wake(_instant: bool) -> void:
	powered = true
	light_radius = 40.0
	add_to_group("light")
	queue_redraw()


func _process(delta: float) -> void:
	_clock += delta
	queue_redraw()


func _draw() -> void:
	# The plinth.
	_px(-12, -8, 24, 8, OUTLINE)
	_px(-11, -7, 22, 7, STONE_DARK)
	_px(-11, -7, 22, 2, STONE)
	# The coil: a copper post wound with bands.
	_px(-5, -52, 10, 45, OUTLINE)
	_px(-4, -51, 8, 44, COPPER_DARK)
	_px(-4, -51, 3, 44, COPPER)
	for i in 8:
		var y := -48 + i * 5
		_px(-7, y, 14, 3, OUTLINE)
		_px(-6, y + 1, 12, 1, COPPER_LIGHT if powered else COPPER)
	# The crown: a ball that holds the spark.
	_px(-5, -60, 10, 9, OUTLINE)
	_px(-4, -59, 8, 7, COPPER)
	_px(-3, -58, 3, 2, COPPER_LIGHT)
	if not powered:
		# A dim blue spark, guttering.
		var on := fmod(_clock, 1.6) < 0.25
		if on:
			_px(-1, -64, 2, 3, DIM)
		return
	# Awake: a halo and arcs crawling up and down the coil.
	draw_circle(Vector2(0, -28), 6.0 + sin(_clock * 8.0), Color(LIVE, 0.18))
	for k in 2:
		var y := -48 + int(fposmod(_clock * 60.0 + k * 22.0, 40.0))
		_px(-8, y, 4, 1, SPARK)
		_px(4, y + 2, 4, 1, LIVE)
	_px(-2, -64, 4, 4, SPARK, 0.7 + 0.3 * sin(_clock * 20.0))


func _px(x: int, y: int, w: int, h: int, color: Color, alpha := 1.0) -> void:
	draw_rect(Rect2(x * 0.5, y * 0.5, w * 0.5, h * 0.5), Color(color, color.a * alpha))
