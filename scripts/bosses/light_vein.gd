class_name LightVein
extends Area2D
## One of the veins of light the meteor's core feeds through (the Evil One,
## phase 2: The Veins, design bible 8.9; legend `x`). A knot of cyan crystal
## grown into the shaft, pulsing up toward the core. One blow cuts it and its
## light goes out; cut them all and the core starves. A pogo bounces off it.
## The origin is its centre.

signal cut

const SIZE := Vector2(14, 22)
const LIGHT := Color("b8fff4")
const CYAN := Color("4ae0d8")
const DEEP := Color("1a6a78")
const DEAD := Color("3a2a48")
const OUTLINE := Color("13101f")

var is_cut := false
var _t := 0.0
var _flash := 0.0


func _ready() -> void:
	collision_layer = Player.LAYER_ENEMY
	collision_mask = 0
	z_index = 1
	add_to_group("pogo")
	add_to_group("light_vein")
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = SIZE
	shape.shape = rect
	add_child(shape)
	if is_cut:
		collision_layer = 0


## Called by the player's blade.
func take_hit(_damage: int, _dir: Vector2) -> void:
	if is_cut:
		return
	is_cut = true
	_flash = 0.15
	set_deferred("collision_layer", 0)
	var d := Dust.new()
	d.setup("parry")
	get_parent().add_child(d)
	d.global_position = global_position
	Sfx.play("lantern_break", 0.05, 0.0)
	Feel.hitstop(0.08)
	cut.emit()


func _process(delta: float) -> void:
	_t += delta
	_flash -= delta
	queue_redraw()


func _draw() -> void:
	var h := SIZE.y * 0.5
	var w := SIZE.x * 0.5
	var gem := PackedVector2Array([Vector2(0, -h), Vector2(w, -h * 0.2), Vector2(w * 0.6, h), Vector2(-w * 0.6, h), Vector2(-w, -h * 0.2)])
	var rim := PackedVector2Array([Vector2(0, -h - 1.5), Vector2(w + 1.5, -h * 0.2), Vector2(w * 0.6 + 1.0, h + 1.5), Vector2(-w * 0.6 - 1.0, h + 1.5), Vector2(-w - 1.5, -h * 0.2)])
	draw_colored_polygon(rim, OUTLINE)
	if is_cut:
		draw_colored_polygon(gem, DEAD if _flash <= 0.0 else Color.WHITE)
		draw_line(Vector2(-w * 0.6, -2), Vector2(w * 0.6, 3), OUTLINE, 1.5)
		return
	var k := 0.5 + 0.5 * sin(_t * 5.0)
	draw_colored_polygon(gem, CYAN)
	draw_colored_polygon(PackedVector2Array([Vector2(0, -h + 2.0), Vector2(w * 0.5, -h * 0.1), Vector2(0, h - 3.0), Vector2(-w * 0.5, -h * 0.1)]), LIGHT.lerp(CYAN, 1.0 - k))
	# Its light runs up a thread toward the core.
	for i in 4:
		var y := -h - 6.0 - fmod(_t * 30.0 + i * 8.0, 32.0)
		draw_rect(Rect2(-0.5, y, 1.0, 3.0), Color(CYAN, 0.7 * (1.0 - (-y - h) / 40.0)))
	draw_rect(Rect2(-1.0, -h - 40.0, 2.0, 40.0), Color(DEEP, 0.5))
