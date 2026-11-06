class_name StoneColumn
extends Node2D
## One stone column of a Lithic Fracture wave (design bible 4, pass 497): it thrusts
## up out of the floor, bursts once as it rises, and sinks back. The burst strikes
## every foe in its span (the wave decides damage, stagger and slow, once per cast)
## and shatters a cracked stone seal if this is the column that reached one.

const RISE := 0.16
const LINGER := 0.12
const HEIGHT := 40.0
const WIDTH := 14.0
const STONE := Color("6b6380")
const EDGE := Color("8d84a3")
const DARK := Color("2a2538")

## The wave that owns this column; it tracks the once-per-cast struck foes.
var wave: LithicWave
## True for the one column that lands on a cracked stone seal.
var breaks_seal := false

var _t := 0.0
var _burst := false


func _ready() -> void:
	z_index = 3
	Sfx.play("lithic_hit", 0.02)
	var d := Dust.new()
	d.setup("debris")
	get_parent().add_child(d)
	d.global_position = global_position
	Feel.hitstop(0.02)


func _physics_process(delta: float) -> void:
	_t += delta
	if not _burst and _t >= RISE * 0.4:
		_burst = true
		_do_burst()
	if _t >= RISE + LINGER:
		queue_free()
		return
	queue_redraw()


## How far up the column has thrust now.
func height() -> float:
	var k := clampf(_t / RISE, 0.0, 1.0)
	return HEIGHT * ease(k, 0.3)


func _do_burst() -> void:
	var area := Rect2(global_position - Vector2(WIDTH * 0.5, HEIGHT), Vector2(WIDTH, HEIGHT + 8.0))
	for c: Variant in Query.rect(get_world_2d(), area, Player.LAYER_WORLD | Player.LAYER_ENEMY):
		if breaks_seal and c.is_in_group("stone_seal") and c.has_method("shatter"):
			c.shatter()
		elif c.is_in_group("enemy") and c.has_method("take_hit") and wave != null:
			wave.strike(c)


func _draw() -> void:
	var h := height()
	if h <= 1.0:
		return
	# A jagged slab of broken floor-stone, thrust up and lit along its leading edge.
	var w := WIDTH
	var top := -h
	draw_rect(Rect2(-w * 0.5, top, w, h), DARK)
	draw_rect(Rect2(-w * 0.5 + 1.0, top, w - 2.0, h), STONE)
	# A cracked, uneven crown.
	var crown := PackedVector2Array([
		Vector2(-w * 0.5, top + 4.0), Vector2(-w * 0.3, top), Vector2(-w * 0.1, top + 3.0),
		Vector2(w * 0.12, top - 2.0), Vector2(w * 0.32, top + 2.0), Vector2(w * 0.5, top + 5.0),
		Vector2(w * 0.5, top + 7.0), Vector2(-w * 0.5, top + 7.0)])
	draw_colored_polygon(crown, STONE)
	# Fracture lines and a bright edge where it splits the ground.
	draw_line(Vector2(-2.0, top + 4.0), Vector2(1.0, top + h * 0.5), DARK, 1.0)
	draw_line(Vector2(1.0, top + h * 0.5), Vector2(-1.0, top + h), DARK, 1.0)
	draw_rect(Rect2(-w * 0.5 + 1.0, top, 2.0, h), EDGE)
	# Dust shearing off the crown as it rises.
	var k := clampf(_t / RISE, 0.0, 1.0)
	for i in 3:
		var fx := -w * 0.4 + i * w * 0.4
		draw_rect(Rect2(fx, top - 3.0 - i * 2.0, 3.0, 3.0), Color(EDGE, 0.5 * (1.0 - k)))
