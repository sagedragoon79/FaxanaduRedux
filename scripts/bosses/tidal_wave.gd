class_name TidalWave
extends Node2D
## A wave the Drowned Warden raises (design bible 8.10): a wall of water that
## runs across the surface of the Wellspring. It hits anything at the surface or
## standing level with it, once, for DAMAGE; jump it, or dive under it. It can't
## be parried. The origin is on the surface at its foot.

const SPEED := 230.0
const HEIGHT := 40.0
## How far below the surface it reaches (a body deeper than this is safe).
const DEPTH := 24.0
const WIDTH := 28.0
const DAMAGE := 16
const FOAM := Color("e8fff8")
const WATER := Color("5ac8d0")
const DEEP := Color("1f6a78")

var dir := 1.0
## The run of the surface it can cross, in x (room pixels).
var lane := Vector2(0, 640)
var speed := SPEED
var _hit := false
var _t := 0.0


func _ready() -> void:
	z_index = 2


func hit_rect() -> Rect2:
	return Rect2(global_position.x - WIDTH * 0.5, global_position.y - HEIGHT, WIDTH, HEIGHT + DEPTH)


func _physics_process(delta: float) -> void:
	_t += delta
	if TimeStop.active():
		queue_redraw()
		return
	global_position.x += dir * speed * delta
	# It rises out of the water over its first tenth of a second.
	if not _hit and _t > 0.1:
		var p := get_tree().get_first_node_in_group("player") as Player
		if p != null and not p.dead and hit_rect().intersects(p.body_rect()):
			_hit = true
			p.receive_attack(DAMAGE, self, false)
	if global_position.x < lane.x - WIDTH or global_position.x > lane.y + WIDTH:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var rise := minf(1.0, _t / 0.1)
	var h := HEIGHT * rise
	# A curling crest leaning the way it runs, foam on its lip and spray behind.
	var pts := PackedVector2Array([
		Vector2(-WIDTH * 0.9 * dir, 4), Vector2(-WIDTH * 0.5 * dir, -h * 0.55), Vector2(-WIDTH * 0.05 * dir, -h),
		Vector2(WIDTH * 0.35 * dir, -h * 0.9), Vector2(WIDTH * 0.5 * dir, -h * 0.55), Vector2(WIDTH * 0.25 * dir, 4)])
	draw_colored_polygon(pts, Color(WATER, 0.85))
	draw_colored_polygon(PackedVector2Array([pts[0], pts[1], Vector2(-WIDTH * 0.2 * dir, -h * 0.4), Vector2(0, 4)]), Color(DEEP, 0.8))
	draw_polyline(PackedVector2Array([pts[1], pts[2], pts[3], pts[4]]), FOAM, 2.0)
	for i in 5:
		var k := fmod(_t * 3.0 + i * 0.2, 1.0)
		draw_rect(Rect2(-dir * (WIDTH * 0.6 + k * 26.0), -h * (1.0 - k) - 4.0, 2, 2), Color(FOAM, 1.0 - k))
