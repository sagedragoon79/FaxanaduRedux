class_name StrideVeil
extends StaticBody2D
## One tile of elven veil (room legend `|`, a column of three is usual; design
## bible 4.1 A5 and 4.5): a shimmering curtain of silver-green mist with a faint
## elven rune. It stops the player like a wall, but an air dash or a ground
## stride (Elven Stride) passes straight through it. Only the player is stopped:
## the veil is on its own collision layer (Player.LAYER_VEIL), which the player
## drops from its mask while dashing (Player.passes_veils). Drawn at 2x render
## density: `_px` takes half-pixels.

const VEIL := Color("a8d8c0")
const VEIL_DARK := Color("3f7a6c")
const VEIL_LIGHT := Color("e6f7ec")
const RUNE := Color("f4f0c8")

var _clock := 0.0
var _told := false
## Flares bright for a moment when the player strides through.
var _flare := 0.0


func _ready() -> void:
	collision_layer = Player.LAYER_VEIL
	collision_mask = 0
	add_to_group("stride_veil")
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 16)
	shape.shape = rect
	add_child(shape)
	_clock = fmod(global_position.x * 0.31 + global_position.y * 0.17, 10.0)


## The tile's rectangle in world space.
func rect() -> Rect2:
	return Rect2(global_position - Vector2(8, 8), Vector2(16, 16))


## Lights the veil as the player strides through it.
func flare() -> void:
	if _flare <= 0.0:
		Sfx.play("veil", 0.06, -4.0)
	_flare = 0.4


func _physics_process(delta: float) -> void:
	_clock += delta
	_flare = maxf(0.0, _flare - delta)
	queue_redraw()
	var p := get_tree().get_first_node_in_group("player") as Player
	if p == null or p.dead:
		return
	var d := (p.global_position + Vector2(0, -16)).distance_to(global_position)
	if d <= 26.0 and not p.abilities.get("stride", false):
		if not _told:
			# One message for the whole veil, not one per tile.
			for v in get_tree().get_nodes_in_group("stride_veil"):
				(v as StrideVeil)._told = true
			GameState.toast.emit("An elven veil. Only a warden's stride passes it.")
			Sfx.play("fizzle", 0.0)
	elif d > 48.0:
		_told = false


func _draw() -> void:
	var glow := 1.0 + _flare * 1.5
	# A soft body of mist behind the strands, so it reads against a pale sky.
	_px(-12, -16, 24, 32, Color(VEIL_DARK, 0.35 * minf(glow, 2.0)))
	# Thin vertical strands that ripple upward, brighter at the centre.
	for i in 6:
		var x := -12 + i * 5
		var ripple := roundi(sin(_clock * 2.2 + i * 1.3 + global_position.y * 0.07) * 1.5)
		var a := (0.5 if i == 0 or i == 5 else 0.85) * glow
		_px(x + ripple, -16, 3, 32, Color(VEIL if i % 2 == 0 else VEIL_DARK, minf(a, 1.0)))
		var spark_y := -16 + int(fposmod(-_clock * 24.0 + i * 11.0, 32.0))
		_px(x + ripple, spark_y, 2, 3, Color(VEIL_LIGHT, minf(0.7 * glow, 1.0)))
	# The rune: a faint elven mark that breathes, the same on every tile.
	var r := Color(RUNE, minf((0.55 + 0.25 * sin(_clock * 1.6)) * glow, 1.0))
	_px(-1, -8, 2, 16, r)
	_px(-5, -6, 10, 2, r)
	_px(-4, 3, 2, 2, r)
	_px(2, 3, 2, 2, r)


func _px(x: int, y: int, w: int, h: int, color: Color) -> void:
	draw_rect(Rect2(x * 0.5, y * 0.5, w * 0.5, h * 0.5), color)
