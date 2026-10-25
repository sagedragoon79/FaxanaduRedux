class_name HeartLight
extends Node2D
## A spring's stolen light, caught in a dead socket of the meteor's heart (the
## Evil One, phase 3, design bible 8.9). Each third of the core's life cut away
## with the Dragon Slayer frees one: the socket fills with spring water's blue
## light and a shaft of it pours down. The origin is the socket's centre.

const STONE := Color("2a1e3a")
const DARK := Color("13101f")
const WATER := Color("7cc4f0")
const WATER_LIGHT := Color("d8f1ff")

var lit := false
## How far down the shaft of light pours (pixels).
var depth := 220.0
var _t := 0.0
var _since := 0.0


func light() -> void:
	if lit:
		return
	lit = true
	_since = 0.0
	Sfx.play("flood")


func _ready() -> void:
	z_index = -1


func _process(delta: float) -> void:
	_t += delta
	_since += delta
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 12.0, DARK)
	draw_circle(Vector2.ZERO, 10.0, STONE)
	if not lit:
		# A dull ember of the stolen light, barely there.
		draw_circle(Vector2.ZERO, 3.0 + sin(_t * 2.0), Color(WATER, 0.25))
		return
	var k := minf(1.0, _since / 0.6)
	var shimmer := 0.8 + 0.2 * sin(_t * 5.0)
	draw_rect(Rect2(-6.0, 0, 12.0, depth * k), Color(WATER, 0.18 * shimmer))
	draw_rect(Rect2(-2.0, 0, 4.0, depth * k), Color(WATER_LIGHT, 0.25 * shimmer))
	draw_circle(Vector2.ZERO, 8.0, Color(WATER, shimmer))
	draw_circle(Vector2.ZERO, 4.0, WATER_LIGHT)
	if _since < 0.5:
		draw_arc(Vector2.ZERO, 12.0 + _since * 60.0, 0.0, TAU, 20, Color(WATER_LIGHT, 1.0 - _since * 2.0), 2.0)
