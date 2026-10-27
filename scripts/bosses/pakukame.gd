class_name Pakukame
extends Enemy
## Pakukame, the Devouring Bloom (design bible 8.5): a carnivorous flower the
## size of a house, rooted in the middle of the crown-leaf, its head a
## turtle-shell bulb that snaps shut. Code-drawn at 2x.
##
## Its only hitbox is the head (a BossSegment). The shell turns most of a blow;
## after a bite the jaws hang open on the leaf (the weak point) and every blow
## lands in full.
## - Bite (close): the head rears back, jaws parting (tell), then lunges down
##   at where you stand. Parry it and the head lies open longer.
## - Vine whip (far): a vine coils at the root (tell), then lashes along the
##   leaf on your side. Jump it, or stride through it (the dash's invulnerability).
## - Seed spit (far): the bulb swells (tell) and spits three seeds in arcs.
## Phase 2 (below half): tells a fifth shorter (never under Enemy.MIN_TELEGRAPH),
## and every other bite tears a chunk out of the leaf where it lands, leaving a
## thorny gap to stride or bounce over.
## Phase 3 (below a quarter): it tears its root out of the leaf (tell), and the
## crown-leaf, cut loose, falls through the sky (LeafFall: wind rushing up, and
## you weigh a little less). The Bloom scuttles after you on its roots, and its
## bites lunge: the whole plant hops in behind the jaws. Run under its head or
## stride through it to get past, and strike the jaws where they land.

signal defeated

const DISPLAY_NAME := "Pakukame"
const EPITHET := "the Devouring Bloom"
const MAX_HP := 260
const PHASES := [0.5, 0.25]
## Phase 3: tearing the root out of the leaf (the tell before the chase).
const UPROOT_TIME := 1.2
## How fast it scuttles after you on its roots (px/s); a walk, slower than your run.
const CHASE_SPEED := 80.0
## It stops this close to you (px) and lets the bite do the rest.
const CHASE_NEAR := 40.0
## How far a phase-3 bite carries the whole plant (px).
const LUNGE := 80.0
## It keeps this far from the walls (px).
const WALL_MARGIN := 48.0
const INTRO_TIME := 1.4
const IDLE_TIME := 0.9
const BITE_RANGE := 110.0
const BITE_TELL := 0.55
const BITE_TIME := 0.18
const GAPE_TIME := 1.3
## A parried bite leaves the jaws open this much longer.
const GAPE_PARRIED := 0.9
const RETRACT_TIME := 0.4
const WHIP_TELL := 0.6
const WHIP_TIME := 0.35
const WHIP_REACH := 170.0
const SPIT_TELL := 0.5
const SPIT_FLIGHT := 0.8
const FAST := 0.8
const BITE_DAMAGE := 24
const WHIP_DAMAGE := 16
## The shell turns this much of a blow when the jaws are shut.
const SHELL := 0.3
const HEAD_RADIUS := 22.0
const HEAD_SCALE := 1.4
const DYING_TIME := 1.4
## Leaf columns a chomp may tear (the root and the walls are left whole).
const TEAR_MIN_FROM_ROOT := 2
const TEAR_MIN_FROM_WALL := 5
const TEAR_WIDTH := 4
const MAX_GAPS := 3

const OUTLINE := Color("13200f")
const STEM := Color("4c8a34")
const STEM_LIGHT := Color("7cbf52")
const STEM_DARK := Color("2f5a22")
const SHELL_COL := Color("3e6b2c")
const SHELL_PLATE := Color("6e9a3e")
const SHELL_RIM := Color("c9b45a")
const PETAL := Color("d0508a")
const PETAL_LIGHT := Color("f08ab8")
const MAW := Color("6a1422")
const MAW_DEEP := Color("2a060c")
const TOOTH := Color("f4ecd0")

## The arena's interior in pixels (walls and ceiling outside it).
var arena := Rect2(16, 64, 928, 256)
var phase := 1
var head: BossSegment
var gaps: Array[Vector2i] = []
## How far the jaws are open, 0..1, for the drawing.
var open := 0.0

var _bites := 0
var _last := ""
var _hit_done := false
var _gape_for := GAPE_TIME
var _from := Vector2.ZERO
var _to := Vector2.ZERO
var _whip_dir := 1
var _rng := RandomNumberGenerator.new()
var _root_from := 0.0
var _root_to := 0.0
## Phase 3: torn out of the leaf and chasing.
var uprooted := false
var leaf_fall: LeafFall


func _init() -> void:
	max_hp = MAX_HP
	contact_damage = 0
	gold_min = 120
	gold_max = 160
	xp = 220
	body_size = Vector2(20, 60)
	knockback = 0.0
	uses_gravity = false
	state = "dormant"
	_rng.seed = 1988


func _ready() -> void:
	super._ready()
	add_to_group("boss")
	# Only the head can be struck; the stem is scenery.
	collision_layer = 0
	collision_mask = 0
	remove_from_group("enemy")
	remove_from_group("pogo")
	head = BossSegment.new()
	head.boss = self
	head.is_head = true
	head.radius = HEAD_RADIUS
	add_child(head)
	head.global_position = rest_point()
	head.set_active(false)


## The leaf's surface under the root.
func floor_y() -> float:
	return global_position.y


## Where the head sways when it is not attacking.
func rest_point() -> Vector2:
	return global_position + Vector2(facing * 16.0, -96.0)


## Starts the fight (called by the arena once the player is inside).
func begin() -> void:
	face_player()
	set_state("intro")
	Sfx.play("roar", 0.1, 2.0)
	Feel.add_trauma(0.35)
	GameState.banner.emit(DISPLAY_NAME, EPITHET)


func health_fraction() -> float:
	return clampf(float(hp) / max_hp, 0.0, 1.0)


func tell(base: float) -> float:
	return maxf(Enemy.MIN_TELEGRAPH, base * (FAST if phase >= 2 else 1.0))


## Its opening (Enemy.punishable): after a bite the jaws hang open.
func punishable() -> bool:
	return gaping()


func gaping() -> bool:
	return state == "gape"


## A blow on the head: full while the jaws hang open, else the shell turns most of it.
func hit_segment(seg: BossSegment, damage: int, dir: Vector2) -> void:
	if seg != head or state in ["dormant", "intro", "dying", "dead"]:
		return
	head.flash = 0.12
	take_hit(damage if gaping() else maxi(1, roundi(damage * SHELL)), dir)


func take_hit(damage: int, dir: Vector2) -> void:
	super.take_hit(damage, dir)
	_hitstun = 0.0
	velocity = Vector2.ZERO
	if not dead and phase == 1 and health_fraction() <= PHASES[0]:
		phase = 2
		Sfx.play("roar", 0.0, 0.0)
		Feel.add_trauma(0.35)
	if not dead and phase == 2 and health_fraction() <= PHASES[1]:
		# It finishes what it's doing, then uproots (from idle).
		phase = 3


func _on_blocked(_dir: Vector2) -> void:
	pass


## A parried bite: the jaws hang open a while longer.
func stagger() -> void:
	if state == "bite":
		_gape_for = GAPE_TIME + GAPE_PARRIED
		head.flash = 0.12
		Feel.add_trauma(0.2)


func _think(delta: float) -> void:
	velocity = Vector2.ZERO
	head.flash -= delta
	match state:
		"dormant":
			head.global_position = rest_point() + Vector2(0, 60)
		"intro":
			# The bloom rises out of the leaf.
			var k := clampf(state_time / INTRO_TIME, 0.0, 1.0)
			head.global_position = rest_point() + Vector2(0, 60.0 * (1.0 - k))
			open = 0.3 * k
			if state_time >= INTRO_TIME:
				head.set_active(true)
				head.contact_damage = 10
				set_state("idle")
		"idle":
			face_player()
			open = move_toward(open, 0.1, delta * 3.0)
			var t := Time.get_ticks_msec() * 0.001
			head.global_position = rest_point() + Vector2(sin(t * 1.3) * 6.0, sin(t * 2.1) * 4.0)
			if phase == 3 and not uprooted:
				_from = head.global_position
				set_state("uproot")
				Sfx.play("roar", 0.0, 1.0)
				Sfx.play("break", 0.05, -2.0)
				return
			if uprooted:
				_chase(delta)
			if state_time >= IDLE_TIME * (FAST if phase >= 2 else 1.0):
				_choose()
		"uproot":
			# It rears and wrenches its root out of the leaf.
			var k := clampf(state_time / UPROOT_TIME, 0.0, 1.0)
			open = 0.6 + sin(state_time * 30.0) * 0.2
			head.global_position = _from.lerp(rest_point() + Vector2(0, -20), k) + Vector2(sin(state_time * 50.0) * 3.0 * (1.0 - k), 0)
			Feel.add_trauma(delta * 0.6)
			if state_time >= UPROOT_TIME:
				_uproot()
				set_state("idle")
		"bite_tell":
			var k := clampf(state_time / tell(BITE_TELL), 0.0, 1.0)
			open = k
			head.global_position = _from.lerp(rest_point() + Vector2(-facing * 18.0, -16.0), k)
			if state_time >= tell(BITE_TELL):
				_to = _bite_target()
				_from = head.global_position
				_root_from = global_position.x
				_root_to = _root_from
				if uprooted:
					# The whole plant hops in behind its jaws.
					var dir := signf(_to.x - _root_from)
					_root_to = _arena_x(_root_from + dir * minf(LUNGE, maxf(0.0, absf(_to.x - _root_from) - CHASE_NEAR)))
				_hit_done = false
				_gape_for = GAPE_TIME
				set_state("bite")
				Sfx.play("hydra_bite", 0.08, 2.0)
		"bite":
			var k := clampf(state_time / BITE_TIME, 0.0, 1.0)
			global_position.x = lerpf(_root_from, _root_to, k)
			head.global_position = _from.lerp(_to, k * k)
			if not _hit_done:
				var res := hit_player_in_rect(bite_rect(), BITE_DAMAGE)
				_hit_done = res != ""
			if state_time >= BITE_TIME:
				open = 1.0
				Feel.add_trauma(0.3)
				if _chomps():
					_tear_leaf(_to.x)
				set_state("gape")
		"gape":
			open = 1.0
			if state_time >= _gape_for:
				_from = head.global_position
				set_state("retract")
		"retract":
			var k := clampf(state_time / RETRACT_TIME, 0.0, 1.0)
			open = 1.0 - k * 0.9
			head.global_position = _from.lerp(rest_point(), k)
			if state_time >= RETRACT_TIME:
				set_state("idle")
		"whip_tell":
			if state_time >= tell(WHIP_TELL):
				_hit_done = false
				set_state("whip")
				Sfx.play("reel", 0.1, 0.0)
		"whip":
			if not _hit_done:
				_hit_done = hit_player_in_rect(whip_rect(), WHIP_DAMAGE, false) != ""
			if state_time >= WHIP_TIME:
				set_state("idle")
		"spit_tell":
			open = clampf(state_time / tell(SPIT_TELL), 0.0, 1.0) * 0.5
			if state_time >= tell(SPIT_TELL):
				_spit()
				set_state("idle")
		_:
			set_state("idle")


## Phase 3: the Bloom tears free and the leaf begins to fall.
func _uproot() -> void:
	uprooted = true
	Feel.add_trauma(0.6)
	GameState.flash.emit(0.3)
	if leaf_fall == null and get_parent() != null:
		leaf_fall = LeafFall.new()
		leaf_fall.area = arena
		get_parent().add_child(leaf_fall)


## Scuttles toward the player along the leaf, stopping short of them.
func _chase(delta: float) -> void:
	var p := player()
	if p == null:
		return
	var dx := p.global_position.x - global_position.x
	if absf(dx) > CHASE_NEAR:
		global_position.x = _arena_x(global_position.x + signf(dx) * CHASE_SPEED * delta)


func _arena_x(x: float) -> float:
	return clampf(x, arena.position.x + WALL_MARGIN, arena.end.x - WALL_MARGIN)


func _choose() -> void:
	var p := player()
	if p == null:
		return
	var dx := p.global_position.x - global_position.x
	_from = head.global_position
	var pick := "bite" if absf(dx) <= BITE_RANGE else ("spit" if _last == "whip" else "whip")
	if pick == "bite" and _last == "bite" and absf(dx) > 48.0:
		# Don't bite twice running unless the player is right at the root.
		pick = "whip"
	_last = pick
	face_player()
	_whip_dir = int(signf(dx)) if dx != 0.0 else facing
	set_state(pick + "_tell")
	if pick == "bite":
		_bites += 1


## Phase 2: every other bite tears the leaf.
func _chomps() -> bool:
	return phase >= 2 and _bites % 2 == 0 and gaps.size() < MAX_GAPS


func _bite_target() -> Vector2:
	var p := player()
	var x := p.global_position.x if p != null else global_position.x + facing * 60.0
	x = clampf(x, global_position.x - BITE_RANGE, global_position.x + BITE_RANGE)
	return Vector2(x, floor_y() - 22.0)


func bite_rect() -> Rect2:
	return Rect2(head.global_position - Vector2(28, 24), Vector2(56, 44))


## The lash runs along the leaf on the player's side of the root.
func whip_rect() -> Rect2:
	var x0 := global_position.x + (12.0 if _whip_dir > 0 else -12.0 - WHIP_REACH)
	return Rect2(x0, floor_y() - 14.0, WHIP_REACH, 14.0)


## Tears a chunk out of the leaf where the jaws came down (bible 8.5 phase 2),
## if it is far enough from the root and the walls and not already torn.
func _tear_leaf(x: float) -> void:
	var room := get_parent() as Room
	if room == null:
		return
	var col := int(x / Room.TILE)
	var root_col := int(global_position.x / Room.TILE)
	var c0 := col - TEAR_WIDTH / 2
	var c1 := c0 + TEAR_WIDTH - 1
	var wall_l := int(arena.position.x / Room.TILE) + TEAR_MIN_FROM_WALL
	var wall_r := int(arena.end.x / Room.TILE) - 1 - TEAR_MIN_FROM_WALL
	if c0 < wall_l or c1 > wall_r:
		return
	if c1 >= root_col - TEAR_MIN_FROM_ROOT and c0 <= root_col + TEAR_MIN_FROM_ROOT:
		return
	for g in gaps:
		if c0 <= g.y + 1 and c1 >= g.x - 1:
			return
	var row := int(floor_y() / Room.TILE)
	room.tear_floor(c0, c1, row, row + 1)
	gaps.append(Vector2i(c0, c1))
	Sfx.play("break", 0.0, 2.0)
	Feel.add_trauma(0.5)
	var d := Dust.new()
	d.setup("debris")
	room.add_child(d)
	d.global_position = Vector2((c0 + c1 + 1) * 0.5 * Room.TILE, floor_y())


func _spit() -> void:
	var p := player()
	var from := head.global_position + Vector2(facing * 10.0, 0)
	var target := p.global_position + Vector2(0, -10) if p != null else from + Vector2(facing * 120.0, 60)
	for k in [-28.0, 0.0, 28.0]:
		var s := SeedShot.new()
		s.velocity = Rubble.launch(from, target + Vector2(k, 0), SPIT_FLIGHT)
		get_parent().add_child(s)
		s.global_position = from
	Sfx.play("web_shoot", 0.1, -2.0)


func die() -> void:
	if state == "dying":
		return
	set_state("dying")
	dead = true
	head.set_active(false)
	if is_instance_valid(leaf_fall):
		leaf_fall.settle()
	Feel.boss_kill(1.0)
	Feel.add_trauma(0.8)
	Sfx.play("roar", 0.0, 3.0)


func _process(delta: float) -> void:
	queue_redraw()
	if state != "dying":
		return
	state_time += delta
	open = 1.0
	head.global_position += Vector2(0, 30.0 * delta)
	if int(state_time * 10.0) % 3 == 0:
		var d := Dust.new()
		d.setup("debris")
		get_parent().add_child(d)
		d.global_position = head.global_position + Vector2(_rng.randf_range(-14, 14), _rng.randf_range(-14, 14))
	if state_time >= DYING_TIME:
		state = "dead"
		defeated.emit()
		super.die()


func _draw() -> void:
	var t := Time.get_ticks_msec() * 0.001
	var white := flashing() or head.flash > 0.0 or (state.ends_with("_tell") and telegraph_pulse())
	if state == "dying":
		white = int(state_time * 12.0) % 2 == 0
	if state == "dormant":
		_draw_leaves(t)
		return
	_draw_whip(t)
	_draw_stem(t)
	if uprooted:
		_draw_roots(t)
	else:
		_draw_leaves(t)
	_draw_head(t, white)


## Two great leaves at the root, over the stem's base.
func _draw_leaves(t: float) -> void:
	for s in [-1, 1]:
		var sway := sin(t * 1.2 + s) * 1.5
		var pts := PackedVector2Array()
		for i in 9:
			var k := i / 8.0
			pts.append(Vector2(s * (4 + k * 34.0), -k * 10.0 - sin(k * PI) * 8.0 + sway * k))
		for i in range(8, -1, -1):
			var k := i / 8.0
			pts.append(Vector2(s * (4 + k * 34.0), -k * 10.0 + sin(k * PI) * 3.0 + sway * k))
		draw_colored_polygon(_grow(pts, 1.0), OUTLINE)
		draw_colored_polygon(pts, STEM if s < 0 else STEM_DARK)
		draw_line(Vector2(s * 4, 0), Vector2(s * 38, -10 + sway), STEM_LIGHT, 1.0)


## Uprooted: a tangle of roots it scuttles on, torn leaf still clinging.
func _draw_roots(t: float) -> void:
	var walking := state == "idle" or state == "bite"
	for i in 6:
		var s := -1.0 if i % 2 == 0 else 1.0
		var row := i >> 1
		var reach := 10.0 + row * 9.0
		var step := sin(t * 14.0 + i * 1.7) * (4.0 if walking else 1.0)
		var knee := Vector2(s * reach * 0.6, -10.0 - row * 2.0)
		var foot := Vector2(s * reach + step, -absf(step) * 0.5)
		draw_line(Vector2(0, -6), knee, OUTLINE, 5.0)
		draw_line(knee, foot, OUTLINE, 4.0)
		draw_line(Vector2(0, -6), knee, STEM_DARK, 3.0)
		draw_line(knee, foot, Color("8a6a3a"), 2.0)
	draw_circle(Vector2(0, -6), 7.0, OUTLINE)
	draw_circle(Vector2(0, -6), 6.0, STEM_DARK)


## A thick stem curving from the root up to the head.
func _draw_stem(_t: float) -> void:
	var tip := to_local(head.global_position)
	var ctrl := Vector2(-facing * 20.0, -50.0)
	var pts: Array[Vector2] = []
	for i in 13:
		var k := i / 12.0
		pts.append(Vector2.ZERO.lerp(ctrl, k).lerp(ctrl.lerp(tip, k), k))
	for p in pts:
		draw_circle(p, 6.0, OUTLINE)
	for p in pts:
		draw_circle(p, 5.0, STEM)
	for p in pts:
		draw_circle(p + Vector2(-1.5, 0), 1.5, STEM_LIGHT)


## The bulb: petals behind, a domed turtle shell, the jaws and the maw.
func _draw_head(t: float, white: bool) -> void:
	# Drawn small and scaled up: the bulb is as wide as a cart.
	draw_set_transform(to_local(head.global_position), 0.0, Vector2.ONE * HEAD_SCALE)
	var c := Vector2.ZERO
	var f := float(facing)
	var gap := open * 12.0
	# Petals, fanning out behind the head and pulsing slowly.
	for i in 6:
		var a := TAU * i / 6.0 + t * 0.3
		var r := 22.0 + sin(t * 2.0 + i) * 1.5
		var tip := c + Vector2(cos(a), sin(a)) * r
		var side := Vector2(-sin(a), cos(a)) * 6.0
		var petal := PackedVector2Array([c + side, tip, c - side])
		draw_colored_polygon(_grow(petal, 1.0), OUTLINE)
		draw_colored_polygon(petal, PETAL if i % 2 else PETAL_LIGHT)
	# The maw, showing between the jaws.
	if gap > 1.0:
		var maw := PackedVector2Array([c + Vector2(-14 * f, -gap * 0.5), c + Vector2(16 * f, -gap * 0.6), c + Vector2(16 * f, gap * 0.6), c + Vector2(-14 * f, gap * 0.5)])
		draw_colored_polygon(_grow(maw, 1.0), OUTLINE)
		draw_colored_polygon(maw, MAW)
		draw_circle(c + Vector2(-2 * f, 0), gap * 0.35, MAW_DEEP)
	# Upper jaw: the shell dome with plates and a gold rim.
	var up := c + Vector2(0, -gap * 0.5)
	var dome := PackedVector2Array()
	for i in 13:
		var a := PI + PI * i / 12.0
		dome.append(up + Vector2(cos(a) * 18.0, sin(a) * 14.0))
	draw_colored_polygon(_grow(dome, 1.0), OUTLINE)
	draw_colored_polygon(dome, SHELL_COL)
	for i in 3:
		var pc := up + Vector2((-9 + i * 9) * f, -6 - (3 if i == 1 else 0))
		draw_colored_polygon(_hex(pc, 4.0), SHELL_PLATE)
	draw_rect(Rect2(up + Vector2(-18, -1.5), Vector2(36, 2)), SHELL_RIM)
	# Lower jaw.
	var lo := c + Vector2(0, gap * 0.5)
	var jaw := PackedVector2Array()
	for i in 13:
		var a := PI * i / 12.0
		jaw.append(lo + Vector2(cos(a) * 17.0, sin(a) * 9.0))
	draw_colored_polygon(_grow(jaw, 1.0), OUTLINE)
	draw_colored_polygon(jaw, STEM_DARK)
	draw_rect(Rect2(lo + Vector2(-17, -0.5), Vector2(34, 2)), SHELL_RIM)
	# Teeth along both rims.
	for i in 6:
		var x := -14.0 + i * 5.5
		draw_colored_polygon(PackedVector2Array([up + Vector2(x, 0.5), up + Vector2(x + 2.5, 0.5), up + Vector2(x + 1.25, 4.0)]), TOOTH)
		draw_colored_polygon(PackedVector2Array([lo + Vector2(x + 2, -0.5), lo + Vector2(x + 4.5, -0.5), lo + Vector2(x + 3.25, -4.0)]), TOOTH)
	# An eye-spot on the shell, toward the front.
	draw_circle(up + Vector2(10 * f, -5), 2.0, OUTLINE)
	draw_circle(up + Vector2(10 * f, -5), 1.2, Color("f0d040"))
	wash(white)
	draw_set_transform(Vector2.ZERO)


## The vine: coiled at the root during its tell, a lash along the leaf after.
func _draw_whip(t: float) -> void:
	var s := float(_whip_dir)
	if state == "whip_tell":
		var k := clampf(state_time / tell(WHIP_TELL), 0.0, 1.0)
		for i in 10:
			var a := i * 0.7 + k * 3.0
			var p := Vector2(s * (14 + cos(a) * 8.0 * (1.0 - i / 12.0)), -10 + sin(a) * 8.0 - i)
			draw_circle(p, 3.0, OUTLINE)
			draw_circle(p, 2.0, STEM_LIGHT if int(state_time * 16.0) % 2 == 0 else STEM)
	elif state == "whip":
		var k := clampf(state_time / WHIP_TIME * 2.0, 0.0, 1.0)
		var n := 24
		for i in n:
			var u := i / float(n - 1)
			var p := Vector2(s * (12 + u * WHIP_REACH * k), -6 + sin(u * 12.0 + t * 30.0) * 3.0 * u)
			draw_circle(p, 3.0, OUTLINE)
		for i in n:
			var u := i / float(n - 1)
			var p := Vector2(s * (12 + u * WHIP_REACH * k), -6 + sin(u * 12.0 + t * 30.0) * 3.0 * u)
			draw_circle(p, 2.0, STEM)
			if i % 4 == 2:
				draw_circle(p + Vector2(0, -3), 1.2, PETAL)


static func _hex(c: Vector2, r: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in 6:
		var a := TAU * i / 6.0
		out.append(c + Vector2(cos(a), sin(a)) * r)
	return out


static func _grow(pts: PackedVector2Array, by: float) -> PackedVector2Array:
	var center := Vector2.ZERO
	for p in pts:
		center += p
	center /= pts.size()
	var out := PackedVector2Array()
	for p in pts:
		out.append(p + (p - center).normalized() * by)
	return out
