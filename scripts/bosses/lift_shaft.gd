class_name LiftShaft
extends Node2D
## The Forepaw Lift's shaft behind Zoradohna's fight (design bible 8.2): iron
## girders and cable runs on the back wall. While the boss's `rising` is set,
## the lift climbs, so the girders stream downward past it and the cables hum.

const GIRDER := Color("3a3550")
const GIRDER_EDGE := Color("5c5478")
const RIVET := Color("8a7a52")
const CABLE := Color("2a2438")
const SPACING := 72.0
const RISE_SPEED := 90.0

var area := Rect2()
var boss: Node2D
var scroll := 0.0
var _speed := 0.0


func _ready() -> void:
	z_index = -1


func _process(delta: float) -> void:
	var want := RISE_SPEED if boss != null and is_instance_valid(boss) and bool(boss.get("rising")) else 0.0
	_speed = move_toward(_speed, want, RISE_SPEED * delta)
	scroll = fmod(scroll + _speed * delta, SPACING)
	queue_redraw()


func is_rising() -> bool:
	return _speed > 1.0


func _draw() -> void:
	# Two cables run the height of the shaft.
	for x: float in [area.position.x + area.size.x * 0.3, area.position.x + area.size.x * 0.7]:
		draw_line(Vector2(x, area.position.y), Vector2(x, area.end.y), CABLE, 2.0)
		var notch := fmod(scroll * 2.0, 24.0)
		var y := area.position.y + notch
		while y < area.end.y:
			draw_rect(Rect2(x - 1.5, y, 3, 2), GIRDER_EDGE)
			y += 24.0
	# Girders crossing the back wall, streaming down while the lift rises.
	var gy := area.position.y - SPACING + scroll
	while gy < area.end.y:
		if gy > area.position.y - 8.0:
			var r := Rect2(area.position.x, gy, area.size.x, 6)
			draw_rect(r, GIRDER)
			draw_rect(Rect2(r.position, Vector2(r.size.x, 1)), GIRDER_EDGE)
			var rx := area.position.x + 8.0
			while rx < area.end.x:
				draw_rect(Rect2(rx, gy + 2, 2, 2), RIVET)
				rx += 32.0
		gy += SPACING
