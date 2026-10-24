class_name HydraFlood
extends Node2D
## The flood in Zorugeriru's last phase (bible 8.4): the spring bursts and the
## arena fills to the tanks' rims. Feet under the water burn with cold mist;
## the rafts, the tank walls and the floating debris stand clear of it.

const RISE_TIME := 2.0
const TICK := 1.0
const DAMAGE := 8
## How far under the surface the feet must be before it hurts.
const DEPTH := 4.0
const WATER := Color("3f7fb8")
const WATER_TOP := Color("cfe6f4")

## The arena's floor and the surface when full (world y), and its sides.
var floor_y := 320.0
var full_y := 256.0
var left := 16.0
var right := 624.0
## 0 dry .. 1 full; it moves toward `target`.
var level := 0.0
var target := 0.0

var _tick := 0.0


func _ready() -> void:
	z_index = 2


func surface_y() -> float:
	return lerpf(floor_y, full_y, level)


## True if feet at `y` are under the water.
func under(y: float) -> bool:
	return level > 0.0 and y > surface_y() + DEPTH


func _physics_process(delta: float) -> void:
	level = move_toward(level, target, delta / RISE_TIME)
	var p := get_tree().get_first_node_in_group("player") as Player
	if p != null and not p.dead and under(p.global_position.y):
		_tick -= delta
		if _tick <= 0.0:
			_tick = TICK
			p.take_damage(DAMAGE)
			Sfx.play("splash", 0.1, -4.0)
	else:
		_tick = 0.0
	if level <= 0.0 and target <= 0.0:
		queue_free()
	queue_redraw()


func _draw() -> void:
	if level <= 0.0:
		return
	var top := surface_y()
	var t := Time.get_ticks_msec() * 0.001
	draw_rect(Rect2(left, top, right - left, floor_y - top), Color(WATER, 0.55))
	var x := left
	while x < right:
		var w := minf(16.0, right - x)
		var y := top + roundf(sin(t * 3.0 + x * 0.07))
		draw_rect(Rect2(x, y, w, 1), Color(WATER_TOP, 0.85))
		x += 16.0
