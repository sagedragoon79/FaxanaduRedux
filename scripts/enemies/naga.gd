class_name Naga
extends Enemy
## A Naga (design bible 7, pass 273): the original's serpent that floats up and
## down, most often over the ladders. A sea-green hooded serpent the length of
## a man, it rises and sinks along its own column, so a climb past it is timed
## to its swing. When you are level with it and in front, within about seven
## tiles, it draws its head back and flares its hood with a hiss (telegraph),
## then strikes straight out along that level, and glides back to its column.
## The strike is a bite, and a shield's parry meets it like any blade's: no
## harm, and the serpent reels (pass 274). Code-drawn at 2x.

## How far it floats above and below its home, and how long one swing takes.
const SWING := 40.0
const SWING_TIME := 3.2
const SIGHT := 112.0
## Level with it: the player's chest within this many px of its head.
const LEVEL := 24.0
const WINDUP := 0.5
## In the coil it follows your height along its column, slower than you climb
## (pass 275): a climber who keeps climbing is still met by the strike, and the
## safe way past is in its recovery after a strike.
const COIL_TRACK := 60.0
const STRIKE_SPEED := 260.0
const STRIKE_TIME := 0.4
const RETURN_SPEED := 120.0
const COOLDOWN := 2.0
## Its body brushed against: a scrape. The strike's bite is the real harm,
## and it can be parried.
const TOUCH_DAMAGE := 8
const BITE_DAMAGE := 16

const OUTLINE := Color("10201c")
const SCALE := Color("3c8a6a")
const SCALE_DARK := Color("24604a")
const BELLY := Color("d8e8b0")
const HOOD := Color("2c7458")
const HOOD_MARK := Color("e0c050")
const EYE := Color("f0e040")
const TONGUE := Color("e04050")

var _dir := Vector2.ZERO
var _cooldown := 0.0
## Whether this strike has bitten (or been parried) already.
var _bit := false
## Where in its swing it starts (0 to 1), so a room's Nagas need not swing
## together, and the game time it has floated (the swing follows game time,
## not the wall clock, so hitstop and slow motion hold it).
var _phase := 0.0
var _swung := 0.0


func _init() -> void:
	max_hp = 22
	contact_damage = TOUCH_DAMAGE
	gold_min = 3
	gold_max = 5
	xp = 6
	body_size = Vector2(22, 44)
	body_centered = true
	uses_gravity = false
	knockback = 160.0
	state = "float"


func _ready() -> void:
	super._ready()
	_phase = fposmod(global_position.x * 0.013, 1.0)


## The point on its column it floats toward at swing time `t` (seconds).
func swing_point(t: float) -> Vector2:
	return home + Vector2(0, sin((t / SWING_TIME + _phase) * TAU) * SWING)


## Where the jaws close in a strike: just ahead of it, along its level.
func bite_rect() -> Rect2:
	return Rect2(center() + Vector2(facing * 18.0 - 12.0, -12.0), Vector2(24, 20))


## True when the player is level with its head and in front of it, near enough to strike.
func sees_level(off: Vector2) -> bool:
	return off.x != INF and absf(off.y) <= LEVEL and absf(off.x) <= SIGHT


func _think(delta: float) -> void:
	_cooldown -= delta
	var off := player_offset()
	# In the strike the bite does the harm (parryable), not the touch.
	contact_damage = 0 if state == "strike" else TOUCH_DAMAGE
	match state:
		"float":
			_swung += delta
			var target := swing_point(_swung)
			velocity = ((target - global_position) * 4.0).limit_length(120.0)
			if off.x != INF:
				face_player()
			if _cooldown <= 0.0 and sees_level(off):
				velocity = Vector2.ZERO
				set_state("coil")
				Sfx.play("naga_hiss", 0.1, -4.0)
		"coil":
			velocity = Vector2.ZERO
			if off.x != INF:
				var want := clampf(center().y + off.y, home.y - SWING, home.y + SWING)
				velocity.y = clampf((want - global_position.y) / maxf(delta, 0.001), -COIL_TRACK, COIL_TRACK)
			face_player()
			if state_time >= WINDUP:
				_dir = Vector2(facing, 0)
				_bit = false
				set_state("strike")
				Sfx.play("naga_strike", 0.1, -4.0)
		"strike":
			velocity = _dir * STRIKE_SPEED
			if not _bit and hit_player_in_rect(bite_rect(), BITE_DAMAGE) != "":
				_bit = true
			if state != "strike":
				return
			if state_time >= STRIKE_TIME or is_on_wall():
				set_state("return")
		"return":
			var d := home - global_position
			velocity = d.normalized() * RETURN_SPEED
			if absf(d.x) < 4.0 or state_time > 3.0:
				_cooldown = COOLDOWN
				set_state("float")
		_:
			set_state("return")


func _draw() -> void:
	var white := flashing() or (state == "coil" and telegraph_pulse())
	var t := Time.get_ticks_msec() * 0.001 + _phase * 5.0
	var jitter := Vector2(randf_range(-1, 1), 0).round() if state == "coil" else Vector2.ZERO
	# Drawn at 2x, like the rest of the cast.
	draw_set_transform(jitter, 0.0, Vector2(facing * 2, 2))
	var coil := state == "coil"
	var strike := state == "strike"
	# The body: an S from the tail tip below up to the neck, waving as it floats.
	var pts := PackedVector2Array()
	for i in 9:
		var k := i / 8.0
		var y := lerpf(13.0, -5.0, k)
		var x := sin(t * 3.0 + k * 4.5) * 3.0 * (1.0 - k)
		if coil:
			x -= k * k * 4.0
		elif strike:
			x += k * k * 6.0
			y += k * 3.0
		pts.append(Vector2(x, y))
	for i in pts.size() - 1:
		var w := lerpf(2.0, 5.0, i / 8.0)
		draw_line(pts[i], pts[i + 1], OUTLINE, w + 2.0)
	for i in pts.size() - 1:
		var w := lerpf(2.0, 5.0, i / 8.0)
		draw_line(pts[i], pts[i + 1], SCALE if i % 2 == 0 else SCALE_DARK, w)
		draw_line(pts[i] + Vector2(1, 0), pts[i + 1] + Vector2(1, 0), BELLY, maxf(1.0, w * 0.35))
	# The head, with the hood behind it: flared wide in the coil.
	var neck := pts[pts.size() - 1]
	var head := neck + Vector2(2, -3)
	var flare := 7.0 if coil else 4.0
	var hood := PackedVector2Array([neck + Vector2(-2, 3), neck + Vector2(-flare, -2), head + Vector2(-1, -4), neck + Vector2(flare - 1.0, -2)])
	draw_colored_polygon(hood, OUTLINE)
	draw_colored_polygon(PackedVector2Array([hood[0] + Vector2(0, -1), hood[1] + Vector2(1, 0), hood[2] + Vector2(0, 1), hood[3] + Vector2(-1, 0)]), HOOD)
	if coil:
		draw_rect(Rect2(neck + Vector2(-4, -2), Vector2(2, 1)), HOOD_MARK)
		draw_rect(Rect2(neck + Vector2(3, -2), Vector2(2, 1)), HOOD_MARK)
	draw_circle(head, 3.0, OUTLINE)
	draw_circle(head, 2.2, SCALE)
	draw_rect(Rect2(head + Vector2(1, -1), Vector2(1, 1)), EYE)
	# The tongue flickers; in the strike the jaw is wide.
	if strike:
		draw_line(head + Vector2(2, 0), head + Vector2(6, 2), OUTLINE, 1.0)
		draw_line(head + Vector2(2, -1), head + Vector2(6, -3), OUTLINE, 1.0)
	elif int(t * 5.0) % 3 == 0 or coil:
		draw_line(head + Vector2(3, 0), head + Vector2(6, 0), TONGUE, 1.0)
	wash(white)
	draw_set_transform(Vector2.ZERO)
