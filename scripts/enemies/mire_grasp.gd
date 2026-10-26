class_name MireGrasp
extends Node2D
## A Marsh Hag's hex (design bible 7): a ring of bubbling green bog light on the
## floor where you stood, the telegraph, while she raises her staff. Then a hand
## of black mud bursts up out of it for DAMAGE (it can't be parried), clutches
## for a moment and sinks. If she is struck mid-hex the mark fizzles out. Its
## glow is a light, so the mark shows through the Mist's fog.

const DAMAGE := 12
## Half the width of the mark, and of the hand's reach.
const HALF_WIDTH := 12.0
const REACH := 30.0
const ACTIVE := 0.2
const SINK := 0.45
const BOG := Color("6fd08a")
const BOG_LIGHT := Color("c8ffd0")
const MUD := Color("1e1a16")
const MUD_LIGHT := Color("4a3e30")

var hag: MarshHag
## "mark" (bubbling, the telegraph), "grasp" (the hand is up), "sink" or "fizzle".
var phase := "mark"
var light_radius := 28.0
var _t := 0.0
var _hit := false


func _ready() -> void:
	z_index = 2
	add_to_group("light")
	add_to_group("enemy_projectile")


## The floor point under `from` (the top of the first solid tile or plank below
## it, up to six tiles down), or Vector2.INF when there is none.
static func floor_below(room: Room, from: Vector2) -> Vector2:
	var cell := room.cell_at(from - Vector2(0, 2))
	for i in 7:
		var c := cell + Vector2i(0, i)
		var at := room.to_global(Vector2(c) * Room.TILE + Vector2(8, 8))
		if room.is_solid_at(at) or room.is_one_way_at(at):
			if i == 0:
				return Vector2.INF
			return Vector2(from.x, room.to_global(Vector2(0, c.y * Room.TILE)).y)
	return Vector2.INF


## The space the hand fills while it is up.
func hand_rect() -> Rect2:
	return Rect2(global_position + Vector2(-HALF_WIDTH * 0.7, -REACH), Vector2(HALF_WIDTH * 1.4, REACH))


func erupt() -> void:
	if phase != "mark":
		return
	phase = "grasp"
	_t = 0.0
	light_radius = 40.0
	var d := Dust.new()
	d.setup("land")
	get_parent().add_child(d)
	d.global_position = global_position
	Feel.add_trauma(0.1)


func fizzle() -> void:
	if phase == "mark":
		phase = "fizzle"
		_t = 0.0


func _physics_process(delta: float) -> void:
	_t += delta
	match phase:
		"mark":
			# Orphaned (the hag gone without a word): it fades.
			if hag == null or not is_instance_valid(hag) or hag.dead:
				fizzle()
		"grasp":
			if not _hit:
				var p := get_tree().get_first_node_in_group("player") as Player
				if p != null and not p.dead and hand_rect().intersects(p.body_rect()):
					_hit = true
					p.receive_attack(DAMAGE, self, false)
			if _t >= ACTIVE:
				phase = "sink"
				_t = 0.0
		"sink":
			light_radius = 28.0 * (1.0 - _t / SINK)
			if _t >= SINK:
				queue_free()
				return
		"fizzle":
			if _t >= 0.3:
				queue_free()
				return
	queue_redraw()


func _draw() -> void:
	match phase:
		"mark", "fizzle":
			var k := 1.0 - (_t / 0.3 if phase == "fizzle" else 0.0)
			var grow := clampf(_t / 0.2, 0.3, 1.0) if phase == "mark" else 1.0
			var w := HALF_WIDTH * grow
			# A flat ellipse of bog light, and bubbles welling up out of it faster and faster.
			draw_set_transform(Vector2(0, -1), 0.0, Vector2(1.0, 0.3))
			draw_circle(Vector2.ZERO, w + 3.0, Color(BOG, 0.18 * k))
			draw_arc(Vector2.ZERO, w, 0.0, TAU, 20, Color(BOG, 0.9 * k), 2.0)
			draw_arc(Vector2.ZERO, w * 0.55, 0.0, TAU, 16, Color(BOG_LIGHT, 0.6 * k), 1.0)
			draw_set_transform(Vector2.ZERO)
			var rate := 3.0 + _t * 10.0
			for i in 4:
				var f := fmod(_t * rate * 0.25 + i * 0.25, 1.0)
				var x := (float(i) - 1.5) * w * 0.45 + sin(i * 2.3 + _t * 5.0) * 1.5
				draw_arc(Vector2(x, -1.0 - f * 7.0), 1.0 + f * 1.2, 0.0, TAU, 8, Color(BOG_LIGHT, (1.0 - f) * k), 1.0)
		"grasp", "sink":
			var up := clampf(_t / 0.06, 0.0, 1.0) if phase == "grasp" else 1.0 - _t / SINK
			var h := REACH * up
			# A splash ring, then the hand: a mud forearm with four clawed fingers.
			draw_set_transform(Vector2(0, -1), 0.0, Vector2(1.0, 0.3))
			draw_arc(Vector2.ZERO, HALF_WIDTH + 2.0, 0.0, TAU, 20, Color(BOG, 0.6 * up), 2.0)
			draw_set_transform(Vector2.ZERO)
			if h < 2.0:
				return
			draw_rect(Rect2(-4.5, -h + 6.0, 9.0, h - 6.0), MUD)
			draw_rect(Rect2(-3.0, -h + 6.0, 2.0, h - 8.0), MUD_LIGHT)
			for i in 4:
				var fx := -6.0 + i * 4.0
				var curl := 2.0 if i in [0, 3] else 0.0
				draw_line(Vector2(fx * 0.6, -h + 7.0), Vector2(fx, -h + curl), MUD, 2.5)
				draw_line(Vector2(fx, -h + curl), Vector2(fx + signf(fx + 0.1) * 1.5, -h + curl + 2.0), MUD, 1.5)
			for i in 3:
				draw_circle(Vector2(-3.0 + i * 3.0, -h * (0.3 + i * 0.2)), 1.0, Color(BOG, 0.7 * up))
