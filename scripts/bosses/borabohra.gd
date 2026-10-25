class_name Borabohra
extends Enemy
## Borabohra, the Storm Roc (design bible 8.6): a titanic thunderbird nesting
## on the highest spire, its wings made of rain clouds. Code-drawn at 2x.
##
## In the air it is mostly cloud: blows land at a third. Three dead conduits
## stand on the roost's islands; wake all three with Thunder and the lightning
## grounds the bird. It crashes onto the cloud-stone floor and lies stunned,
## and every blow lands in full. Then it shakes the charge off, the conduits
## go dead, and it climbs back into the storm.
## - Feather volley: it hangs in the air and throws its wings wide (tell), then
##   flings a fan of five storm feathers. A parried feather flies back at it.
## - Dive bomb: it rises, screaming, and fixes on you (tell), then stoops through
##   where you stood and climbs away. Can't be parried; stride through it.
## Phase 2 (below half): the storm breaks. Every few seconds a bolt marks the
## tallest point and strikes it: you, if you stand up on an island or a landing,
## or else one of the dead conduits, which wakes it. Stay low and let the storm
## help, or climb and risk it. But now a woken conduit drains after a few
## seconds unless all three wake together, and the volley throws seven.
## Phase 3 (below a quarter): the duel. Between dives and volleys it hovers
## over one of the open lanes between the islands and beats its wings (tell,
## dust stirring where the wind will rise), then holds there over a column of
## rising air (Updraft) while the storm waits. Ride the wind up past it and
## pogo its head: blows from above land in full while it holds the gale. It
## doesn't touch you while it beats. Grounding it with the conduits still works.

signal defeated

const DISPLAY_NAME := "Borabohra"
const EPITHET := "the Storm Roc"
const MAX_HP := 320
const INTRO_TIME := 1.6
const CIRCLE_TIME := 1.6
const VOLLEY_TELL := 0.6
const VOLLEY_FEATHERS := 5
const VOLLEY_FAN := 0.22
const DIVE_TELL := 0.65
const DIVE_TIME := 0.5
const CLIMB_TIME := 0.9
const FALL_TIME := 0.5
const GROUND_TIME := 4.5
const RISE_TIME := 0.9
const DYING_TIME := 1.6
## Health fraction where the storm breaks.
const PHASE_2 := 0.5
const VOLLEY_FEATHERS_2 := 7
## Health fraction where the duel begins.
const PHASE_3 := 0.25
## The phase marks on the health bar (GameHud).
const PHASES := [PHASE_2, PHASE_3]
const GALE_TELL := 0.8
const GALE_TIME := 3.5
## How high over the arena's top it hovers to hold the gale.
const GALE_HOVER := 120.0
## How far above its body's top the updraft reaches.
const GALE_HEADROOM := 24.0
## Seconds between storm bolts in phase 2 (the first comes sooner).
const STORM_EVERY := 3.2
## In phase 2 a woken conduit goes dead again after this long, unless all three are awake.
const DRAIN_TIME := 6.0
## Standing this far above the floor makes you the tallest point.
const ELEVATED := 3.0 * 16.0
const DIVE_DAMAGE := 22
const TOUCH_DAMAGE := 14
## Share of a blow that gets through its cloud while it flies.
const CLOUD := 0.3
## How far past the target the dive carries on.
const DIVE_OVERSHOOT := 60.0
## It's drawn larger than its body box: the cloud wings don't take blows.
const SCALE := 1.5
const OUTLINE := Color("13101f")
const CLOUD_DARK := Color("3a3658")
const CLOUD_MID := Color("5e5a86")
const CLOUD_LIGHT := Color("9a96c4")
const BODY := Color("2a2448")
const BODY_LIGHT := Color("4a4278")
const CHEST := Color("e8e0c8")
const BEAK := Color("e8c04a")
const BEAK_DARK := Color("a8781a")
const EYE := Color("f8f8ff")
const BOLT := Color("f8f0b0")
const ARC := Color("b8a8ff")

## The arena's interior in pixels.
var arena := Rect2(16, 64, 928, 256)
var phase := 1
var _last := ""
## The last of the volley and the dive (the gale comes between them in phase 3).
var _last_move := ""
var _gale: Updraft
var _from := Vector2.ZERO
var _to := Vector2.ZERO
var _hit_done := false
var _clock := 0.0
var _rng := RandomNumberGenerator.new()
var _storm := 0.0
## Conduit instance id -> seconds it has been awake (phase 2 drain).
var _charged := {}


func _init() -> void:
	max_hp = MAX_HP
	contact_damage = 0
	gold_min = 150
	gold_max = 200
	xp = 260
	body_size = Vector2(64, 52)
	body_centered = true
	uses_gravity = false
	knockback = 0.0
	state = "dormant"
	_rng.seed = 1987


func _ready() -> void:
	super._ready()
	add_to_group("boss")
	# It flies through the islands; nothing stops a storm.
	collision_mask = 0
	launchable = false


## Starts the fight (called by the arena once the player is inside).
func begin() -> void:
	global_position = Vector2(arena.get_center().x, arena.position.y - 60.0)
	set_state("intro")
	Sfx.play("roar", 0.1, 0.0)
	Feel.add_trauma(0.4)
	GameState.banner.emit(DISPLAY_NAME, EPITHET)


func health_fraction() -> float:
	return clampf(float(hp) / max_hp, 0.0, 1.0)


func tell(base: float) -> float:
	return maxf(Enemy.MIN_TELEGRAPH, base)


func grounded() -> bool:
	return state == "grounded"


## Hovering over its updraft in phase 3: blows from above land in full.
func holding_gale() -> bool:
	return state == "gale"


## Where it hovers for the gale: over the open lane between the islands nearest x.
func gale_point(x: float) -> Vector2:
	var left := arena.position.x + arena.size.x / 3.0
	var right := arena.position.x + arena.size.x * 2.0 / 3.0
	var lane := left if absf(x - left) <= absf(x - right) else right
	return Vector2(lane, arena.position.y + GALE_HOVER)


func set_state(s: String) -> void:
	if not s.begins_with("gale") and is_instance_valid(_gale):
		_gale.queue_free()
		_gale = null
	super.set_state(s)


func airborne() -> bool:
	return not state in ["dormant", "fall", "grounded", "dying", "dead"]


## Where it likes to fly: a slow figure-eight across the sky over the islands.
func sky_point() -> Vector2:
	var c := Vector2(arena.get_center().x, arena.position.y + 52.0)
	return c + Vector2(sin(_clock * 0.7) * arena.size.x * 0.36, sin(_clock * 1.4) * 22.0)


func floor_y() -> float:
	return arena.end.y


## The three conduits on the islands.
func conduits() -> Array:
	return get_tree().get_nodes_in_group("conductor")


func all_awake() -> bool:
	var cs := conduits()
	if cs.is_empty():
		return false
	for c in cs:
		if not (c as Conduit).powered:
			return false
	return true


func _modify_damage(damage: int, dir: Vector2) -> int:
	if grounded():
		return damage
	if holding_gale() and dir.y > 0.0:
		return damage
	return maxi(1, roundi(damage * CLOUD))


func take_hit(damage: int, dir: Vector2) -> void:
	if state in ["dormant", "intro", "dying", "dead"]:
		return
	super.take_hit(damage, dir)
	_hitstun = 0.0
	velocity = Vector2.ZERO
	_check_phase()


func _check_phase() -> void:
	if phase == 1 and not dead and hp <= roundi(max_hp * PHASE_2):
		phase = 2
		_storm = STORM_EVERY * 0.5
		Sfx.play("roar", 0.05, 1.0)
		Feel.add_trauma(0.5)
		GameState.flash.emit(0.4)
	if phase == 2 and not dead and hp <= roundi(max_hp * PHASE_3):
		phase = 3
		Sfx.play("roar", 0.05, 3.0)
		Sfx.play("hydra_roar", 0.05, 0.0)
		Feel.add_trauma(0.6)
		GameState.flash.emit(0.5)


func _on_blocked(_dir: Vector2) -> void:
	pass


## Nothing staggers a storm.
func stagger() -> void:
	pass


func _think(delta: float) -> void:
	_clock += delta
	contact_damage = TOUCH_DAMAGE if airborne() and not state.begins_with("gale") else 0
	if phase >= 2:
		_drain(delta)
		# It draws the storm into its wings while it holds the gale.
		if airborne() and state != "intro" and not state.begins_with("gale"):
			_storm -= delta
			if _storm <= 0.0:
				_storm = STORM_EVERY
				_call_storm()
	match state:
		"dormant":
			velocity = Vector2.ZERO
		"intro":
			var k := clampf(state_time / INTRO_TIME, 0.0, 1.0)
			velocity = (sky_point() - global_position) * 3.0 * k
			if state_time >= INTRO_TIME:
				set_state("circle")
		"circle":
			face_player()
			velocity = ((sky_point() - global_position) * 2.5).limit_length(220.0)
			if _check_grounding():
				return
			if state_time >= CIRCLE_TIME:
				_choose()
		"volley_tell":
			velocity = Vector2.ZERO
			face_player()
			if _check_grounding():
				return
			if state_time >= tell(VOLLEY_TELL):
				_volley()
				set_state("circle")
		"dive_tell":
			face_player()
			velocity = Vector2(0, -40.0)
			if _check_grounding():
				return
			if state_time >= tell(DIVE_TELL):
				var p := player()
				_from = global_position
				var target := p.global_position + Vector2(0, -16) if p != null else Vector2(global_position.x, floor_y())
				_to = target + (target - _from).normalized() * DIVE_OVERSHOOT
				_to.y = minf(_to.y, floor_y() - body_size.y * 0.5)
				_hit_done = false
				set_state("dive")
				Sfx.play("hydra_roar", 0.05, -2.0)
		"gale_tell":
			face_player()
			velocity = ((_to - global_position) * 6.0).limit_length(320.0)
			if _check_grounding():
				return
			if state_time >= tell(GALE_TELL):
				global_position = _to
				velocity = Vector2.ZERO
				_gale.active = true
				set_state("gale")
				Sfx.play("hydra_roar", 0.05, -4.0)
				Feel.add_trauma(0.25)
		"gale":
			face_player()
			velocity = Vector2.ZERO
			if _check_grounding():
				return
			if state_time >= GALE_TIME:
				_from = global_position
				set_state("climb")
		"dive":
			var k := clampf(state_time / DIVE_TIME, 0.0, 1.0)
			velocity = Vector2.ZERO
			global_position = _from.lerp(_to, k * k)
			if not _hit_done:
				_hit_done = hit_player_in_rect(body_rect(), DIVE_DAMAGE, false) != ""
			if state_time >= DIVE_TIME:
				Feel.add_trauma(0.3)
				_from = global_position
				set_state("climb")
		"climb":
			var k := clampf(state_time / CLIMB_TIME, 0.0, 1.0)
			velocity = Vector2.ZERO
			global_position = _from.lerp(sky_point(), k * (2.0 - k))
			if state_time >= CLIMB_TIME:
				set_state("circle")
		"fall":
			# Struck down: it tumbles out of the sky onto the floor.
			var k := clampf(state_time / FALL_TIME, 0.0, 1.0)
			velocity = Vector2.ZERO
			global_position = _from.lerp(Vector2(_from.x, floor_y() - body_size.y * 0.5), k * k)
			if state_time >= FALL_TIME:
				Feel.add_trauma(0.6)
				Sfx.play("break", 0.0, 2.0)
				var d := Dust.new()
				d.setup("land")
				get_parent().add_child(d)
				d.global_position = Vector2(global_position.x, floor_y())
				set_state("grounded")
		"grounded":
			velocity = Vector2.ZERO
			if state_time >= GROUND_TIME:
				for c in conduits():
					(c as Conduit).reset()
				_charged.clear()
				_from = global_position
				set_state("rise")
				Sfx.play("hydra_roar", 0.05, 0.0)
		"rise":
			var k := clampf(state_time / RISE_TIME, 0.0, 1.0)
			velocity = Vector2.ZERO
			global_position = _from.lerp(sky_point(), k * k)
			if state_time >= RISE_TIME:
				set_state("circle")
		_:
			set_state("circle")


## All three conduits awake: the lightning grounds it.
func _check_grounding() -> bool:
	if not all_awake():
		return false
	_from = global_position
	set_state("fall")
	Sfx.play("zap", 0.0, 4.0)
	Feel.add_trauma(0.5)
	GameState.flash.emit(0.5)
	for c in conduits():
		LightningArc.spawn(get_parent(), (c as Conduit).spark_point(), center())
	return true


## Where the next bolt falls: the tallest point. That's you when you stand up
## on the islands; otherwise a dead conduit. INF when there is nothing to strike.
func strike_target() -> Vector2:
	var p := player()
	if p != null and not p.dead and p.global_position.y < floor_y() - ELEVATED:
		return p.global_position
	var dead_ones := conduits().filter(func(c: Conduit) -> bool: return not c.powered)
	if dead_ones.is_empty():
		return Vector2.INF
	return (dead_ones[_rng.randi_range(0, dead_ones.size() - 1)] as Conduit).global_position


func _call_storm() -> void:
	var at := strike_target()
	if at.x == INF:
		return
	var s := StormStrike.new()
	s.boss = self
	s.top = arena.position.y
	get_parent().add_child(s)
	s.global_position = at


## Phase 2: a lone woken conduit loses its charge unless all three wake together.
func _drain(delta: float) -> void:
	if all_awake():
		return
	for c in conduits():
		var cd := c as Conduit
		var id := cd.get_instance_id()
		if not cd.powered:
			_charged.erase(id)
			continue
		_charged[id] = float(_charged.get(id, 0.0)) + delta
		if _charged[id] >= DRAIN_TIME:
			cd.reset()
			_charged.erase(id)


func _choose() -> void:
	var p := player()
	if p == null:
		return
	# Alternate, but a player perched high on the islands gets feathers.
	var pick := "dive" if _last_move == "volley" else "volley"
	if p.global_position.y < arena.end.y - 5 * Room.TILE and _last_move == "dive":
		pick = "volley"
	# In the duel every other move is the gale.
	if phase >= 3 and _last != "gale":
		pick = "gale"
	_last = pick
	if pick != "gale":
		_last_move = pick
	if pick == "gale":
		_begin_gale(p.global_position.x)
		return
	set_state(pick + "_tell")
	if pick == "volley":
		Sfx.play("screech", 0.05, 2.0)
	else:
		Sfx.play("screech", 0.05, 4.0)


## It flies to the lane nearest x and beats its wings: dust stirs where the wind will rise.
func _begin_gale(x: float) -> void:
	_to = gale_point(x)
	set_state("gale_tell")
	_gale = Updraft.new()
	_gale.height = floor_y() - (_to.y - body_size.y * 0.5 - GALE_HEADROOM)
	get_parent().add_child(_gale)
	_gale.global_position = Vector2(_to.x, floor_y())
	Sfx.play("screech", 0.05, 0.0)


func _volley() -> void:
	var off := player_offset()
	var aim := off.normalized() if off.x != INF else Vector2(facing, 1).normalized()
	var half := (VOLLEY_FEATHERS if phase == 1 else VOLLEY_FEATHERS_2) / 2
	for k in range(-half, half + 1):
		var f := HarpyFeather.new()
		f.thrower = self
		f.velocity = aim.rotated(k * VOLLEY_FAN) * 220.0
		get_parent().add_child(f)
		f.global_position = center() + aim * 20.0
	Sfx.play("feather", 0.05, 2.0)


func body_rect() -> Rect2:
	return Rect2(global_position - body_size * 0.5, body_size)


func die() -> void:
	if state == "dying":
		return
	set_state("dying")
	dead = true
	collision_layer = 0
	contact_damage = 0
	Feel.hitstop(0.12)
	Feel.slowmo(0.3, 1.0)
	Feel.add_trauma(0.8)
	Sfx.play("roar", 0.0, 2.0)


func _process(delta: float) -> void:
	queue_redraw()
	if state != "dying":
		return
	state_time += delta
	if int(state_time * 10.0) % 3 == 0:
		var d := Dust.new()
		d.setup("feathers")
		get_parent().add_child(d)
		d.global_position = global_position + Vector2(_rng.randf_range(-30, 30), _rng.randf_range(-16, 16))
	if state_time >= DYING_TIME:
		state = "dead"
		defeated.emit()
		super.die()


func _draw() -> void:
	if state == "dormant":
		return
	var t := Time.get_ticks_msec() * 0.001
	var white := flashing() or (state.ends_with("_tell") and telegraph_pulse())
	if state == "dying":
		white = int(state_time * 12.0) % 2 == 0
	var flap := sin(t * 5.0) * 0.35
	match state:
		"volley_tell":
			flap = -0.7
		"dive_tell":
			flap = -0.5 + sin(t * 30.0) * 0.05
		"dive":
			flap = 0.9
		"gale_tell":
			flap = -0.6 + sin(t * 18.0) * 0.25
		"gale":
			flap = sin(t * 14.0) * 0.6
		"fall", "grounded", "dying":
			flap = 0.75
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1) * SCALE)
	_draw_wing(-1, flap - 0.12, t)
	_draw_body(t)
	_draw_wing(1, flap, t)
	if white:
		draw_circle(Vector2(0, -2), 22.0, Color(1, 1, 1, 0.45))
	draw_set_transform(Vector2.ZERO)
	if state == "grounded" or state.ends_with("_tell"):
		_draw_sparks(t)


## A wing of storm cloud: billows swelling out from the shoulder along a raised
## arc, dark beneath and lit on top, with long flight feathers and rain trailing
## under the trailing edge.
func _draw_wing(layer: int, angle: float, t: float) -> void:
	var shoulder := Vector2(-4, -8) if layer > 0 else Vector2(2, -11)
	var base := CLOUD_MID if layer > 0 else CLOUD_DARK
	var pts: Array[Vector2] = []
	for i in 7:
		pts.append(shoulder + Vector2(-6.0 - i * 9.5, -8.0 - i * 4.0 + i * i * 0.45).rotated(angle))
	# Flight feathers and rain hang from the trailing edge.
	for i in range(2, 7):
		var root := pts[i] + Vector2(0, 4)
		var tip := root + Vector2(-5.0 - i, 14.0 + i * 1.5).rotated(angle * 0.5)
		draw_line(root, tip, OUTLINE, 5.0)
		draw_line(root, tip, base.darkened(0.25), 3.0)
		if layer > 0:
			var drop := fmod(t * 1.6 + i * 0.37, 1.0)
			draw_line(tip + Vector2(0, 4 + drop * 16.0), tip + Vector2(-1, 8 + drop * 16.0), ARC * Color(1, 1, 1, 1.0 - drop), 1.0)
	for i in 7:
		var r := 7.0 + sin(PI * i / 6.0) * 6.0 + sin(t * 2.0 + i) * 0.6
		draw_circle(pts[i], r + 1.5, OUTLINE)
	for i in 7:
		var r := 7.0 + sin(PI * i / 6.0) * 6.0 + sin(t * 2.0 + i) * 0.6
		draw_circle(pts[i], r, base)
		draw_circle(pts[i] + Vector2(1, -r * 0.35), r * 0.6, base.lightened(0.18))
		draw_circle(pts[i] + Vector2(0, -r * 0.5), r * 0.25, CLOUD_LIGHT if layer > 0 else CLOUD_MID)


func _draw_body(t: float) -> void:
	# Tail fan behind.
	for i in 3:
		var a := 2.6 + i * 0.25
		var tip := Vector2(cos(a), sin(a)) * 34.0
		draw_line(Vector2(-10, 4), tip + Vector2(-6, 6), OUTLINE, 7.0)
		draw_line(Vector2(-10, 4), tip + Vector2(-6, 6), CLOUD_DARK, 4.0)
	# Body: a dark storm-blue oval with a pale chest.
	draw_circle(Vector2(0, 0), 17.0, OUTLINE)
	draw_circle(Vector2(0, 0), 15.5, BODY)
	draw_circle(Vector2(3, 3), 10.0, CHEST)
	draw_circle(Vector2(-3, -5), 8.0, BODY_LIGHT)
	# Talons tucked under.
	draw_rect(Rect2(-4, 14, 3, 6), BEAK_DARK)
	draw_rect(Rect2(4, 14, 3, 6), BEAK_DARK)
	# Head with a crest, white eye and a gold hooked beak.
	var h := Vector2(16, -14)
	draw_circle(h, 10.0, OUTLINE)
	draw_circle(h, 8.5, BODY)
	for i in 3:
		draw_line(h + Vector2(-4, -6), h + Vector2(-14 - i * 4, -14 + i * 4 + sin(t * 6.0 + i) * 2.0), CLOUD_LIGHT, 2.0)
	var beak := PackedVector2Array([h + Vector2(6, -3), h + Vector2(19, 1), h + Vector2(15, 6), h + Vector2(7, 4)])
	draw_colored_polygon(beak, OUTLINE)
	draw_colored_polygon(PackedVector2Array([h + Vector2(7, -2), h + Vector2(17, 1), h + Vector2(14, 5), h + Vector2(8, 3)]), BEAK)
	draw_line(h + Vector2(8, 2), h + Vector2(15, 4), BEAK_DARK, 1.0)
	var shut := state in ["grounded", "dying"]
	if shut:
		draw_line(h + Vector2(1, -2), h + Vector2(6, -2), OUTLINE, 1.5)
	else:
		draw_circle(h + Vector2(3, -2), 2.5, EYE)
		draw_circle(h + Vector2(4, -2), 1.0, OUTLINE)


## Lightning crawling over it: the tell's charge, or the bolt that grounded it.
func _draw_sparks(t: float) -> void:
	for k in 3:
		var a := Vector2(_rng.randf_range(-60, 60), _rng.randf_range(-36, 15))
		var b := a + Vector2(_rng.randf_range(-14, 14), _rng.randf_range(-14, 14))
		var mid := (a + b) * 0.5 + Vector2(_rng.randf_range(-4, 4), _rng.randf_range(-4, 4))
		var col := BOLT if int(t * 20.0 + k) % 2 == 0 else ARC
		draw_polyline(PackedVector2Array([a, mid, b]), col, 1.0)
