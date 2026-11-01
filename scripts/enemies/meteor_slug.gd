class_name MeteorSlug
extends Enemy
## A Meteor Slug of Dartmoor (design bible 7): a great grey slug that has
## grown a shell of meteor-rock, molten in its cracks. It creeps along the
## floor. When you come near, its shell swells and glows (the telegraph), then
## it heaves three gobbets of molten rock at you in high arcs: they burn on
## contact and leave embers where they land. The Hour Glass holds them in the
## air. The shell turns blows from above; its soft sides take everything.
## Legend `s`.

const CRAWL := 14.0
const SIGHT := Vector2(170, 80)
const SWELL := 0.6
const RECOVER := 0.7
const COOLDOWN := 1.6
const GLOBS := 3
const SPREAD := 26.0
const FLIGHT := 0.75
## The drawing is laid out small and drawn this much larger.
const SCALE := 2.4

const OUTLINE := Color("13101f")
const SKIN := Color("7a7088")
const SKIN_LIGHT := Color("a89cb8")
const SKIN_DARK := Color("4a4258")
const SHELL := Color("3a2a3a")
const SHELL_LIGHT := Color("5a4258")
const MAGMA := Color("ff7a2a")
const MAGMA_CORE := Color("ffe08a")
const EYE := Color("f0e0a0")

var _cool := 0.0


func _init() -> void:
	max_hp = 40
	gold_min = 8
	gold_max = 12
	xp = 20
	contact_damage = 10
	body_size = Vector2(30, 18)
	knockback = 20.0
	launchable = false


func _modify_damage(damage: int, dir: Vector2) -> int:
	# The meteor shell on its back turns anything coming down on it.
	return 0 if dir.y > 0.0 and state != "recover" else damage


func _think(delta: float) -> void:
	_cool -= delta
	var off := player_offset()
	var seen := off.x != INF and absf(off.x) < SIGHT.x and absf(off.y) < SIGHT.y
	match state:
		"idle", "crawl":
			if state == "idle":
				set_state("crawl")
			if seen and _cool <= 0.0 and is_on_floor():
				velocity.x = 0.0
				face_player()
				set_state("swell")
				Sfx.play("swell", 0.1, -4.0)
				return
			if _edge_ahead():
				facing = -facing
			velocity.x = facing * CRAWL
		"swell":
			velocity.x = 0.0
			if state_time >= SWELL:
				_heave()
				set_state("recover")
		"recover":
			velocity.x = 0.0
			if state_time >= RECOVER:
				_cool = COOLDOWN
				set_state("crawl")
		_:
			set_state("crawl")


## Three gobbets in high arcs: one at you, one short, one long.
func _heave() -> void:
	var p := player()
	var from := center() + Vector2(0, -12)
	var target := p.global_position if p != null else from + Vector2(facing * 80, 0)
	for i in GLOBS:
		var g := MeteorGlob.new()
		g.room = get_parent() as Room
		get_parent().add_child(g)
		g.global_position = from
		var aim := target + Vector2((i - 1) * SPREAD * facing, 0)
		g.velocity = MeteorGlob.launch(from, aim, FLIGHT + 0.08 * i)
	Sfx.play("spore", 0.1, -2.0)
	Feel.add_trauma(0.08)


func _edge_ahead() -> bool:
	if not is_on_floor():
		return false
	if test_move(global_transform, Vector2(facing * 4, 0)):
		return true
	var t := global_transform.translated(Vector2(facing * (body_size.x * 0.5 + 2), 0))
	return not test_move(t, Vector2(0, 6))


func _draw() -> void:
	var t := Time.get_ticks_msec() * 0.001
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1))
	var swell := 0
	var glow := 0.35 + 0.15 * sin(t * 3.0)
	match state:
		"swell":
			swell = mini(int(state_time / SWELL * 4.0), 3)
			glow = 0.5 + 0.5 * absf(sin(state_time * 16.0))
		"recover":
			swell = -1
			glow = 0.15
	var creep := roundi(sin(t * 4.0) * 1.0) if state == "crawl" else 0
	# The foot: a long low body hugging the floor, rippling as it creeps.
	_px(-12, -6, 26 + creep, 6, OUTLINE, 1.0)
	_px(-11, -5, 24 + creep, 5, SKIN, 1.0)
	_px(-11, -5, 24 + creep, 1, SKIN_LIGHT, 1.0)
	_px(-11, -1, 24 + creep, 1, SKIN_DARK, 1.0)
	# The head and eye stalks at the front.
	_px(10 + creep, -10, 7, 9, OUTLINE, 1.0)
	_px(11 + creep, -9, 5, 8, SKIN, 1.0)
	_px(12 + creep, -16, 1, 7, OUTLINE, 1.0)
	_px(15 + creep, -15, 1, 6, OUTLINE, 1.0)
	_px(11 + creep, -18, 3, 3, EYE, 1.0)
	_px(14 + creep, -17, 3, 3, EYE, 1.0)
	# The meteor shell: a lumpy dome of dark rock, molten in its cracks.
	var sh := 10 + swell
	for r in sh:
		var k := float(r) / sh
		var half := roundi(11.0 * sqrt(maxf(0.0, 1.0 - k * k)))
		_px(-3 - half - 1, -6 - r - 1, half * 2 + 2, 2, OUTLINE, 1.0)
	for r in sh:
		var k := float(r) / sh
		var half := roundi(11.0 * sqrt(maxf(0.0, 1.0 - k * k)))
		_px(-3 - half, -6 - r, half * 2, 1, SHELL if r % 3 else SHELL_LIGHT, 1.0)
	# Cracks of magma across the shell, brightest while it swells.
	for c: Array in [[-10, -8, 5, 1], [-6, -11, 1, 4], [-2, -9, 6, 1], [2, -13, 1, 4], [-4, -14, 4, 1], [4, -8, 4, 1]]:
		_px(c[0], c[1] - (swell if c[1] < -10 else 0), c[2], c[3], MAGMA, glow + 0.3)
	_px(-4, -12 - swell, 2, 2, MAGMA_CORE, glow)
	wash(flashing() or (state == "swell" and telegraph_pulse()))
	draw_set_transform(Vector2.ZERO)


## Draws a rect of the design (laid out in units of 1/SCALE half-pixels),
## snapped to the half-pixel grid so neighbouring rects still tile.
func _px(x: int, y: int, w: int, h: int, color: Color, alpha: float) -> void:
	var x0 := floorf(x * SCALE)
	var y0 := floorf(y * SCALE)
	var x1 := maxf(floorf((x + w) * SCALE), x0 + 1.0)
	var y1 := maxf(floorf((y + h) * SCALE), y0 + 1.0)
	draw_rect(Rect2(x0 * 0.5, y0 * 0.5, (x1 - x0) * 0.5, (y1 - y0) * 0.5), Color(color, color.a * alpha))
