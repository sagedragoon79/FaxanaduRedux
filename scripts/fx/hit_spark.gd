class_name HitSpark
extends Node2D
## The flash where a blade meets a foe (design bible 6.7): a white core, a ring and
## sharp rays thrown along the swing. It holds through the hit-stop, because hit-stop
## stops the game clock it counts down on, so the frozen frame shows the impact.

const LIFE := 0.14
const CORE := Color("ffffff")
const RAY := Color("fff4d6")
const RING := Color("ffe9a8")
## A hot rim under each ray, so the spark reads even over a foe's white hit flash.
const RIM := Color("f07a28")
const RAYS := 5

var dir := Vector2.RIGHT
var size := 1.0
var _life := LIFE
var _angles: Array[float] = []


## Adds a spark to `parent` at global `at`, its rays thrown along `swing_dir`.
static func spawn(parent: Node, at: Vector2, swing_dir: Vector2, scale_by := 1.0) -> HitSpark:
	var s := HitSpark.new()
	s.dir = swing_dir.normalized() if swing_dir != Vector2.ZERO else Vector2.RIGHT
	s.size = scale_by
	parent.add_child(s)
	s.global_position = at
	return s


func _ready() -> void:
	z_index = 4
	# Most rays fan forward along the swing; one kicks back.
	var base := dir.angle()
	for i in RAYS - 1:
		_angles.append(base + lerpf(-1.0, 1.0, float(i) / (RAYS - 2)) * 0.9 + randf_range(-0.15, 0.15))
	_angles.append(base + PI + randf_range(-0.4, 0.4))


func _physics_process(delta: float) -> void:
	_life -= delta
	if _life <= 0.0:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var k := clampf(_life / LIFE, 0.0, 1.0)
	var grow := 1.0 - k
	# The ring opens as it fades.
	draw_arc(Vector2.ZERO, (5.0 + 9.0 * grow) * size, 0.0, TAU, 16, Color(RING, k * 0.8), 1.5)
	for i in _angles.size():
		var a: float = _angles[i]
		var reach := (20.0 if i < _angles.size() - 1 else 10.0) * size
		var v := Vector2.from_angle(a)
		var from := v * reach * grow * 0.5
		var to := v * reach * (0.55 + 0.45 * grow)
		var w := 2.0 if i % 2 == 0 else 1.0
		draw_line(from, to, Color(RIM, k), w + 2.0)
		draw_line(from, to, Color(RAY, k), w)
	draw_circle(Vector2.ZERO, (4.0 * size + 1.5) * k, Color(RIM, k))
	draw_circle(Vector2.ZERO, 4.0 * size * k, Color(CORE, k))
