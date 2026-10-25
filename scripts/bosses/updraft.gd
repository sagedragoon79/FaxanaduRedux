class_name Updraft
extends Node2D
## The wind under Borabohra's wings in its third phase (design bible 8.6): a
## column of rising air from the floor up past the hovering roc. While `active`
## and the centre of the player's body is in it, the player rides it up
## (Player.updraft; holding Down drops out) and their air moves come back.
## The column tops out above the bird's head, so a rider rises past it, hangs
## at the top and falls back onto its head: the pogo the duel is built on.
## Before it is active it only stirs the dust on the floor, the tell for where
## it will rise. Placed with its origin at the column's foot (on the floor).

## The speed (px/s) it carries a rider up at.
const LIFT := 240.0
const HALF_WIDTH := 28.0
const WIND := Color("c8e8ff")
const DUST := Color("9a96c4")

## Height of the column above its foot (px).
var height := 200.0
var active := false
var _t := 0.0


func _ready() -> void:
	z_index = -1


## The column, in world space.
func column_rect() -> Rect2:
	return Rect2(global_position.x - HALF_WIDTH, global_position.y - height, HALF_WIDTH * 2.0, height)


func _physics_process(delta: float) -> void:
	_t += delta
	if active:
		var p := get_tree().get_first_node_in_group("player") as Player
		if p != null and not p.dead and column_rect().has_point(p.body_rect().get_center()):
			p.updraft = LIFT
	queue_redraw()


func _draw() -> void:
	if not active:
		# Dust stirring on the floor where the wind will rise.
		for i in 8:
			var k := fmod(_t * 1.8 + i * 0.13, 1.0)
			var x := (float(i) / 7.0 - 0.5) * HALF_WIDTH * 1.8 + sin(_t * 5.0 + i) * 3.0
			draw_rect(Rect2(x, -k * 18.0 - 2.0, 2, 2), Color(DUST, 0.9 * (1.0 - k)))
		return
	draw_rect(Rect2(-HALF_WIDTH, -height, HALF_WIDTH * 2.0, height), Color(WIND, 0.14))
	# Streaks of wind racing up the column, brighter in the middle.
	for i in 10:
		var lane := (float(i) / 9.0 - 0.5) * HALF_WIDTH * 1.7
		var y := -fmod(_t * LIFT * 1.3 + i * 37.0, height)
		var a := 0.8 - absf(lane) / HALF_WIDTH * 0.4
		draw_rect(Rect2(lane + sin(_t * 4.0 + i) * 2.0, y, 2, 16), Color(WIND, a))
	# Edges that sway.
	for side in [-1.0, 1.0]:
		for j in 6:
			var y := -fmod(_t * 60.0 + j * height / 6.0, height)
			draw_rect(Rect2(side * HALF_WIDTH + sin(_t * 3.0 + j) * 2.0 - 1.0, y, 2, 6), Color(WIND, 0.25))
