class_name WindCurrent
extends Node2D
## A wind current across the Branches' open sky (design bible 6.9; legend `>`
## for a current blowing east and `<` west, a rectangle of cells). In the air
## with the middle of the body inside it, the player is carried along: the run
## target shifts by wind_speed with the wind (no headway against it) and the
## current bears them level. On a floor you brace and it doesn't move you; hold
## Down to drop out. Once the Spring of Sky is restored (`spring:sky`) the storm
## breaks and every current in the Branches blows the other way.
## Drawn as streaks of air and drifting leaves racing along the band.

const FLAG := "spring:sky"
const STREAK := Color("f4fbff")
const EDGE := Color("4a86b8")
const LEAF := Color("7cbf52")
## The mantra-space has no leaves: pale flecks of the void ride its winds.
const FLECK := Color("c9c6d6")

## The current's cells (tiles).
var cells := Rect2i()
## The way it blows as drawn in the room: 1 east, -1 west (before the reversal).
var drawn_dir := 1

var _t := 0.0


## The way it blows now: reversed once the storm over Daybreak breaks. The
## mantra-space has no weather: a trial's winds blow as drawn (pass 160).
func dir() -> int:
	var room := get_parent() as Room
	if room != null and room.zone == "trials":
		return drawn_dir
	return -drawn_dir if GameState.flag(FLAG) else drawn_dir


func pixel_rect() -> Rect2:
	return Rect2(Vector2(cells.position * Room.TILE), Vector2(cells.size * Room.TILE))


func _ready() -> void:
	z_index = -1
	position = Vector2(cells.position * Room.TILE)


func _physics_process(delta: float) -> void:
	_t += delta
	var p := get_tree().get_first_node_in_group("player") as Player
	if p != null and not p.dead and not p.is_on_floor() and not p.input.down \
			and pixel_rect().has_point(p.body_rect().get_center()):
		p.wind = dir() * p.tuning.wind_speed
	queue_redraw()


func _draw() -> void:
	var w := float(cells.size.x * Room.TILE)
	var h := float(cells.size.y * Room.TILE)
	var d := float(dir())
	# A faint wash over the band, so its edges read.
	draw_rect(Rect2(0, 0, w, h), Color(STREAK, 0.07))
	# Streaks racing along the band, a darker edge so they read on a pale sky.
	for i in int(w / 12.0) + 6:
		var y := fmod(i * 37.0, h - 4.0) + 2.0
		var len := 14.0 + (i % 3) * 8.0
		var x := fmod(_t * 260.0 + i * 71.0, w + len)
		if d < 0.0:
			x = w - x
		x -= len * 0.5
		var x0 := clampf(x, 0.0, w)
		var x1 := clampf(x + len, 0.0, w)
		if x1 - x0 < 2.0:
			continue
		draw_rect(Rect2(x0, y + 1.0, x1 - x0, 1.0), Color(EDGE, 0.35))
		draw_rect(Rect2(x0, y, x1 - x0, 1.0), Color(STREAK, 0.85))
	# A few leaves tumbling along with it.
	var room := get_parent() as Room
	var leaf := FLECK if room != null and room.zone == "trials" else LEAF
	for i in 6:
		var x := fmod(_t * 200.0 + i * w / 6.0, w)
		if d < 0.0:
			x = w - x
		var y := h * (0.15 + 0.14 * i) + sin(_t * 3.0 + i) * 4.0
		var spin := _t * 8.0 + i
		var r := Vector2(cos(spin), sin(spin)) * 3.0
		draw_line(Vector2(x, y) - r, Vector2(x, y) + r, Color(leaf.darkened(0.5), 0.8), 3.0)
		draw_line(Vector2(x, y) - r, Vector2(x, y) + r, leaf, 1.5)
