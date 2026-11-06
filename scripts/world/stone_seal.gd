class_name StoneSeal
extends StaticBody2D
## One tile of a cracked stone seal (room legend `[`, design bible 4.5, pass 497):
## rune-bound stone that blocks like a wall and yields to nothing but a Lithic
## Fracture cast. A column of the wave that reaches it shatters every seal of the
## run in the room for good. Only ever used to hide an optional cache, never the
## way on (the Lithic Fracture spell is itself an optional find).

const STONE := Color("4a4258")
const FACE := Color("6b6380")
const CRACK := Color("c9a86a")
const RUNE := Color("e8c488")
const EDGE := Color("8d84a3")

## Remembered broken in GameState so a shattered seal stays open.
var persist_id := ""

var _broken := false
var _shape: CollisionShape2D
var _clock := 0.0


func _ready() -> void:
	collision_layer = Player.LAYER_WORLD
	collision_mask = 0
	add_to_group("stone_seal")
	_shape = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 16)
	_shape.shape = rect
	add_child(_shape)
	_clock = fmod(global_position.x * 0.41 + global_position.y * 0.23, 10.0)
	if persist_id != "" and GameState.is_collected(persist_id):
		_open(true)


## A Lithic Fracture column reached this seal: every seal of the run in the room
## breaks for good, in a burst of stone.
func shatter() -> void:
	if _broken:
		return
	for s in get_tree().get_nodes_in_group("stone_seal"):
		(s as StoneSeal)._open(false)
	Sfx.play("break", -0.1)
	Feel.hitstop(0.06)
	Feel.add_trauma(0.25)


func is_broken() -> bool:
	return _broken


func _open(instant: bool) -> void:
	if _broken:
		return
	_broken = true
	if persist_id != "":
		GameState.collect(persist_id)
	_shape.set_deferred("disabled", true)
	visible = false
	if instant:
		return
	var d := Dust.new()
	d.setup("debris")
	get_parent().add_child(d)
	d.global_position = global_position


func _physics_process(delta: float) -> void:
	if _broken:
		set_physics_process(false)
		return
	_clock += delta
	queue_redraw()


func _draw() -> void:
	if _broken:
		return
	# A block of dark stone, its face split by a bound fracture-rune that pulses.
	draw_rect(Rect2(-8, -8, 16, 16), STONE)
	draw_rect(Rect2(-7, -7, 14, 14), FACE)
	draw_rect(Rect2(-7, -7, 14, 2), EDGE)
	# A jagged seam held shut.
	var seam := PackedVector2Array([Vector2(-1, -7), Vector2(1, -2), Vector2(-2, 2), Vector2(0, 7)])
	for i in seam.size() - 1:
		draw_line(seam[i], seam[i + 1], CRACK, 1.0)
	# The rune that binds it, breathing.
	var k := 0.5 + 0.5 * sin(_clock * 3.0)
	draw_rect(Rect2(-4, -1, 8, 1), Color(RUNE, k))
	draw_rect(Rect2(-1, -4, 1, 8), Color(RUNE, k))
	draw_rect(Rect2(-3, -3, 1, 1), Color(RUNE, k * 0.7))
	draw_rect(Rect2(3, 3, 1, 1), Color(RUNE, k * 0.7))
