class_name Motes
extends Node2D
## The particle layer in front of a room (design bible 12.5): spores rising in
## the Trunk, dust drifting down in Eolis. Motes live in screen space around
## the camera and wrap at its edges, and some sit at a deeper parallax than
## others, so the air has depth without spawning or freeing anything.

const VIEW := Vector2(640, 360)
## zone: [count, color, drift velocity, sway, size 2 chance, streak length (optional:
## draws each mote as a short line along its drift, for rain)]
const ZONES := {
	"trunk": [46, Color("84cbd6"), Vector2(0, -7), 7.0, 0.25],
	"eolis": [28, Color("f0dfa8"), Vector2(3, 4), 4.0, 0.1],
	"tower": [34, Color("f0a050"), Vector2(-2, -12), 3.0, 0.15],
	"mist": [40, Color("b8c8b0"), Vector2(6, 1), 9.0, 0.12],
	"branches": [30, Color("d8f0a0"), Vector2(14, 3), 6.0, 0.1],
	# Daybreak: rain driven hard on the storm wind.
	"daybreak": [52, Color("c8c0f0"), Vector2(-60, 140), 1.0, 0.05, 6.0],
}

## Zones whose air settles once their spring runs: spring flag -> share of motes
## left. The Spring of Sky breaks the storm, so Daybreak's rain thins to a drizzle.
const SETTLES := {"daybreak": ["spring:sky", 0.3]}

var zone := ""
var _motes: Array = []  # [screen position, depth 0.5..1.2, phase]
var _spec: Array = []
var _t := 0.0
var _last_view := Vector2.INF
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	z_index = 4


func set_zone(next: String) -> void:
	if next == zone:
		return
	zone = next
	_motes.clear()
	_spec = ZONES.get(zone, [])
	if _spec.is_empty():
		return
	_rng.seed = zone.hash()
	for i in count():
		_motes.append([Vector2(_rng.randf() * VIEW.x, _rng.randf() * VIEW.y), _rng.randf_range(0.5, 1.2), _rng.randf() * TAU])


## How many motes the zone has now.
func count() -> int:
	var n := int(_spec[0])
	if SETTLES.has(zone) and GameState.flag(SETTLES[zone][0]):
		n = roundi(n * float(SETTLES[zone][1]))
	return n


## Rebuilds the motes (after a spring changes the weather).
func refresh() -> void:
	var z := zone
	zone = ""
	set_zone(z)


func _process(delta: float) -> void:
	if _motes.is_empty():
		return
	_t += delta
	var view := _view_origin()
	var moved := Vector2.ZERO if _last_view == Vector2.INF else view - _last_view
	_last_view = view
	var drift: Vector2 = _spec[2]
	for m: Array in _motes:
		var depth: float = m[1]
		# Nearer motes drift faster and slide further against the camera.
		var p: Vector2 = m[0] + drift * depth * delta - moved * (depth - 1.0)
		p.x = fposmod(p.x, VIEW.x)
		p.y = fposmod(p.y, VIEW.y)
		m[0] = p
	queue_redraw()


func _draw() -> void:
	if _motes.is_empty():
		return
	var origin := _view_origin()
	var color: Color = _spec[1]
	var sway: float = _spec[3]
	var streak := Vector2.ZERO
	if _spec.size() > 5:
		streak = (_spec[2] as Vector2).normalized() * float(_spec[5])
	for i in _motes.size():
		var m: Array = _motes[i]
		var depth: float = m[1]
		var phase: float = m[2]
		var p: Vector2 = m[0] + Vector2(sin(_t * 0.9 + phase) * sway * depth, 0)
		var a := (0.25 + 0.35 * depth) * (0.6 + 0.4 * sin(_t * 2.1 + phase * 3.0))
		var s := 2.0 if float(i) / _motes.size() < float(_spec[4]) else 1.0
		if streak != Vector2.ZERO:
			var at := (origin + p).floor()
			draw_line(at, at - streak * depth, Color(color, a * 0.8), 1.0)
		else:
			draw_rect(Rect2((origin + p).floor(), Vector2(s, s)), Color(color, a))


## The world position of the screen's top-left corner.
func _view_origin() -> Vector2:
	var t := get_viewport().get_canvas_transform()
	return -t.origin / t.get_scale()
