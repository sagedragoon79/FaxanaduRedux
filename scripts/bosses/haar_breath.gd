class_name SteamBreath
extends Node2D
## A bellow of steam from one of the Haar Wyrm's jaws (design bible 8.4): a gout
## of hot white steam that vents along the ground (or the flood's surface) from
## the head that breathed it. It starts narrow at the mouth and billows wider and
## taller as it rolls, thinning and cooling as it goes. It is slow enough to
## dodge: jump it, or get up on the tank walls or rafts. It hurts once and can't
## be parried.

const WIDTH := 40.0
const HEIGHT := 44.0
const SPEED := 95.0
const LIFE := 3.2
const DAMAGE := 12
## How the gout swells as it rolls: narrow at the mouth, broad near the end.
const SPREAD_START := 0.4
const SPREAD_END := 1.9
const STEAM := Color("f4f7f6")
const STEAM_HOT := Color("fff1dc")
const STEAM_EDGE := Color("c3d2d4")

var dir := 1.0
## The ground it vents along (world y) and the arena's sides.
var ground_y := 0.0
var left := 0.0
var right := 0.0

var _time := 0.0
var _hit := false


func _ready() -> void:
	z_index = 3


## How far through its run the gout is (0 at the mouth, 1 as it fades).
func _k() -> float:
	return clampf(_time / LIFE, 0.0, 1.0)


## How wide the gout has billowed: narrow at the mouth, broad at the end.
func spread() -> float:
	return lerpf(SPREAD_START, SPREAD_END, _k())


## The hurt rect. It widens as it rolls, but its height stays under a single
## jump's apex (movement_tuning jump_height, 72 px), so a jump always clears it.
func rect() -> Rect2:
	var w := WIDTH * spread()
	var h := HEIGHT * lerpf(0.5, 1.0, _k())
	return Rect2(global_position.x - w * 0.5, ground_y - h, w, h)


func _physics_process(delta: float) -> void:
	if TimeStop.active():
		return  # held still by the Stillstone
	_time += delta
	global_position.x += dir * SPEED * delta
	global_position.y = ground_y
	var p := get_tree().get_first_node_in_group("player") as Player
	if not _hit and p != null and not p.dead and rect().intersects(p.body_rect()):
		_hit = true
		p.receive_attack(DAMAGE, self, false)
	if _time >= LIFE or global_position.x < left - WIDTH or global_position.x > right + WIDTH:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var k := _k()
	# Thin in as it leaves the jaws, thin out as it dissipates, and thin overall
	# as it cools over its run.
	var rise := clampf(_time / 0.18, 0.0, 1.0)
	var fade := clampf((LIFE - _time) / 0.6, 0.0, 1.0)
	var thin := lerpf(1.0, 0.5, k)
	var a := rise * fade * thin
	var s := spread()
	var shimmer := sin(_time * 18.0)
	# Billowing puffs, densest and hottest at the leading jaw, rising and cooling
	# toward the tail. The whole gout wavers with the heat.
	for i in 8:
		var q := float(i) / 7.0
		var lead := q if dir > 0.0 else 1.0 - q  # 1 at the leading edge
		var x := (q - 0.5) * WIDTH * s + sin(_time * 7.0 + i * 1.7) * 3.0
		var r := (8.0 + 7.0 * sin(q * PI)) * s + 2.0 * sin(_time * 5.0 + i)
		# Steam rises: the trailing puffs lift higher than the leading edge.
		var y := -r * 0.9 - 2.0 - (1.0 - lead) * 10.0 * s - (shimmer + 1.0) * 1.5
		var hot := clampf(0.2 + lead, 0.0, 1.0)
		var body := STEAM_HOT.lerp(STEAM, 1.0 - hot)
		draw_circle(Vector2(x, y), r + 1.5, Color(STEAM_EDGE, 0.35 * a))
		draw_circle(Vector2(x, y - 1.0), r, Color(body, (0.55 + 0.25 * hot) * a))
		draw_circle(Vector2(x - 1.0, y - 2.0), r * 0.45, Color(Color.WHITE, 0.5 * hot * a))
	# The jet of pressure where it vents at the ground.
	draw_rect(Rect2(-WIDTH * 0.5 * s, -5, WIDTH * s, 5), Color(STEAM, 0.7 * a))
