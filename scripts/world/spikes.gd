class_name Spikes
extends Area2D
## A tile of floor spikes. Hurts on touch, and can be pogoed with the Mattock.

const COLOR := Color("b9b4c4")
const SHADE := Color("6f6982")


func _ready() -> void:
	collision_layer = Player.LAYER_HAZARD
	collision_mask = 0
	monitoring = false
	add_to_group("hazard")
	add_to_group("pogo")
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(14, 9)
	shape.shape = rect
	shape.position = Vector2(0, -4.5)
	add_child(shape)


func _draw() -> void:
	for i in 4:
		var x := -8.0 + i * 4.0
		draw_colored_polygon(PackedVector2Array([Vector2(x, 0), Vector2(x + 2, -10), Vector2(x + 4, 0)]), SHADE)
		draw_colored_polygon(PackedVector2Array([Vector2(x + 1, 0), Vector2(x + 2, -10), Vector2(x + 3, 0)]), COLOR)
