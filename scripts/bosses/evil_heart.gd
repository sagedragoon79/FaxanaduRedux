class_name EvilHeart
extends Enemy
## The Evil One, phase 3: The Core (design bible 8.9). Starved of its veins,
## the meteor's heart hangs in the dark of its last chamber, a crystal
## eye-flower too high for any blade, and lashes out: beams, seeds of crystal
## and waves of spikes. But the Tree has reached it. On a rhythm the floor
## under it glows green and a root whips up, binds it and drags it down; while
## it is held only the Dragon Slayer cuts it (every other blade, and magic,
## glances off). Each third of its life cut away frees a spring's stolen light
## (a HeartLight in the vault), which heals you and quickens the Tree's roots.
##
## Phases follow the lights freed: phase 2 adds the spike wave, phase 3
## shortens its tells (never under Enemy.MIN_TELEGRAPH) and makes it burst
## when the root lets go, the last half second flashing first. The Hour Glass
## holds it, its roots and its beams, so time stopped while it is bound is time
## to cut.

signal defeated

const DISPLAY_NAME := "The Evil One"
const EPITHET := "Heart of the Meteor"
const PHASES := [0.66, 0.33]
const MAX_HP := 300
const SIZE := Vector2(80, 56)
const INTRO_TIME := 1.6
const DYING_TIME := 2.5
## Seconds between its attacks, by phase.
const ATTACK_GAP := [2.0, 1.7, 1.4]
## Seconds between the Tree's roots, by phase (the first comes sooner).
const ROOT_EVERY := [7.0, 6.0, 5.0]
const FIRST_ROOT := 4.0
const HOLD := 2.4
const DRAG := 0.35
const RISE := 0.6
const TELL := 0.6
const TELL_P3 := 0.45
const SEED_SPREAD := 56.0
const WAVE_SPIKES := 8
const WAVE_GAP := 30.0
const WAVE_STEP := 0.07
## Its burst when a root lets go of it in the last phase.
const BURST_TELL := 0.5
const BURST_RADIUS := 56.0
const BURST_DAMAGE := 14
## How much of the player's health a freed light gives back.
const LIGHT_HEAL := 0.25
const DRIFT := 40.0

const OUTLINE := Color("0c0812")
const FLESH := Color("4a1430")
const FLESH_LIGHT := Color("7a2448")
const PETAL := Color("2a1e3a")
const PETAL_LIGHT := Color("4a3a66")
const CRYSTAL := Color("4ae0d8")
const CRYSTAL_LIGHT := Color("b8fff4")
const IRIS := Color("ff4060")

## The chamber's interior in pixels; its floor is the bottom edge.
var arena := Rect2(16, 64, 928, 272)
var phase := 1
var lights: Array[HeartLight] = []
## How many times a root has bound it.
var binds := 0
var _attack := 0.0
var _root := 0.0
var _last := ""
var _float_y := 0.0
var _from_y := 0.0
var _burst_hit := false
var _look := Vector2.DOWN
var _root_node: TreeRoot


func _init() -> void:
	max_hp = MAX_HP
	contact_damage = 0
	gold_min = 400
	gold_max = 500
	xp = 1000
	body_size = SIZE
	body_centered = true
	uses_gravity = false
	launchable = false
	knockback = 0.0
	state = "dormant"


func _ready() -> void:
	super._ready()
	add_to_group("boss")
	collision_mask = 0
	z_index = 1


## Starts the fight (called by the arena once the player is inside).
func begin() -> void:
	_float_y = global_position.y
	hp = max_hp
	for i in 3:
		var l := HeartLight.new()
		l.depth = arena.end.y - (arena.position.y + 20.0)
		get_parent().add_child(l)
		l.global_position = Vector2(arena.position.x + arena.size.x * (0.2 + 0.3 * i), arena.position.y + 20.0)
		lights.append(l)
	set_state("intro")
	Sfx.play("roar", 0.0, -4.0)
	Feel.add_trauma(0.5)
	GameState.banner.emit(DISPLAY_NAME, EPITHET)


func health_fraction() -> float:
	return clampf(float(hp) / max_hp, 0.0, 1.0)


func floor_y() -> float:
	return arena.end.y


## Its opening (Enemy.punishable): bound by the root of the Tree.
func punishable() -> bool:
	return bound()


func bound() -> bool:
	return state == "bound"


func tell() -> float:
	return maxf(Enemy.MIN_TELEGRAPH, TELL_P3 if phase == 3 else TELL)


func lights_freed() -> int:
	return lights.filter(func(l: HeartLight) -> bool: return l.lit).size()


## Only the Dragon Slayer's edge, and only while a root holds it down.
func _modify_damage(damage: int, _dir: Vector2) -> int:
	# Only the Dragon Slayer in hand: a thrown dagger glances off (pass 188).
	if not bound() or thrown:
		return 0
	var p := player()
	if p == null or not p.is_attacking:
		return 0
	if String(GameState.data.equipment.get("blade", "")) != "dragon_slayer":
		return 0
	return damage


func _on_blocked(dir: Vector2) -> void:
	var d := Dust.new()
	d.setup("guard")
	get_parent().add_child(d)
	d.global_position = global_position - Vector2(dir.x * 20.0, 0)
	Sfx.play("guard")


func stagger() -> void:
	pass


func launch() -> bool:
	return false


func take_hit(damage: int, dir: Vector2) -> void:
	if dead or state == "dying":
		return
	super.take_hit(damage, dir)
	if dead:
		return
	while phase <= PHASES.size() and health_fraction() <= PHASES[phase - 1]:
		_free_light(phase - 1)
		phase += 1


## A third of it is gone: a spring's stolen light goes home.
func _free_light(i: int) -> void:
	if i < lights.size():
		lights[i].light()
	var p := player()
	if p != null and not p.dead:
		p.hp = mini(p.max_hp, p.hp + roundi(p.max_hp * LIGHT_HEAL))
		p.health_changed.emit(p.hp, p.max_hp)
	Sfx.play("heal")
	Sfx.play("roar", 0.1, -6.0)
	Feel.add_trauma(0.4)


func _physics_process(delta: float) -> void:
	if TimeStop.active():
		queue_redraw()
		return
	super._physics_process(delta)


func _think(delta: float) -> void:
	velocity = Vector2.ZERO
	var p := player()
	if p != null:
		_look = _look.lerp((p.body_rect().get_center() - eye()).normalized(), minf(1.0, delta * 4.0))
	match state:
		"dormant":
			pass
		"intro":
			if state_time >= INTRO_TIME:
				set_state("float")
				_attack = ATTACK_GAP[0]
				_root = FIRST_ROOT
		"float":
			_drift(delta)
			_root -= delta
			_attack -= delta
			if _root <= 0.0:
				_call_root()
			elif _attack <= 0.0:
				_choose()
		"gather":
			# Crystal gathers under it before a wave of spikes.
			if state_time >= tell():
				_wave()
				set_state("float")
		"snared":
			# The floor under it glows; it strains against what is coming.
			global_position.x += sin(state_time * 60.0) * 0.6
		"bound":
			var k := minf(1.0, state_time / DRAG)
			global_position.y = lerpf(_from_y, floor_y() - SIZE.y * 0.5, k * k)
			if state_time >= HOLD:
				if phase == 3:
					_burst()
				_from_y = global_position.y
				set_state("rise")
		"rise":
			var k := minf(1.0, state_time / RISE)
			global_position.y = lerpf(_from_y, _float_y, 1.0 - (1.0 - k) * (1.0 - k))
			if state_time >= RISE:
				set_state("float")
				_attack = ATTACK_GAP[phase - 1] * 0.5
				_root = ROOT_EVERY[phase - 1]


func _drift(delta: float) -> void:
	var p := player()
	var to := global_position.x
	if p != null:
		to = clampf(p.global_position.x, arena.position.x + SIZE.x, arena.end.x - SIZE.x)
	global_position.x = move_toward(global_position.x, to, DRIFT * delta)
	global_position.y = _float_y + sin(state_time * 1.3) * 6.0


## The Tree answers: a root breaks the floor under the core.
func _call_root() -> void:
	set_state("snared")
	_root_node = TreeRoot.new()
	_root_node.target = self
	_root_node.hold = HOLD + DRAG
	get_parent().add_child(_root_node)
	_root_node.global_position = Vector2(global_position.x, floor_y())
	_root_node.struck.connect(_on_root_struck)
	Sfx.play("rumble", 0.1, -4.0)


func _on_root_struck() -> void:
	if dead or state == "dying":
		return
	binds += 1
	_from_y = global_position.y
	_burst_hit = false
	set_state("bound")
	Sfx.play("roar", 0.15, -2.0)


func _choose() -> void:
	var options := ["beam", "seeds"]
	if phase >= 2:
		options.append("wave")
	options.erase(_last)
	var pick: String = options[randi() % options.size()]
	_last = pick
	_attack = ATTACK_GAP[phase - 1]
	match pick:
		"beam":
			_beam()
		"seeds":
			_seeds()
		"wave":
			set_state("gather")
			Sfx.play("crackle", 0.05, -2.0)


## A beam at you (its line flickers for the tell first).
func _beam() -> void:
	var p := player()
	if p == null or p.dead:
		return
	var b := CoreBeam.new()
	b.direction = (p.body_rect().get_center() - eye()).normalized()
	b.tell = tell()
	get_parent().add_child(b)
	b.global_position = eye()
	Sfx.play("zap", 0.1, -4.0)


## Three seeds of crystal around you: each swells before it bursts, and a blow cracks it.
func _seeds() -> void:
	var p := player()
	if p == null or p.dead:
		return
	var c := p.body_rect().get_center()
	for dx in [-SEED_SPREAD, 0.0, SEED_SPREAD]:
		var s := MeteorSeed.new()
		get_parent().add_child(s)
		s.global_position = Vector2(clampf(c.x + dx, arena.position.x + 8.0, arena.end.x - 8.0), c.y - 6.0)


## Spikes erupt along the floor out from under it, both ways.
func _wave() -> void:
	Sfx.play("crackle", 0.05, 0.0)
	Feel.add_trauma(0.2)
	for side in [-1.0, 1.0]:
		for i in WAVE_SPIKES:
			var x: float = global_position.x + side * (24.0 + i * WAVE_GAP)
			if x < arena.position.x + 8.0 or x > arena.end.x - 8.0:
				break
			var s := CrystalSpike.new()
			s.delay = i * WAVE_STEP
			get_parent().add_child(s)
			s.global_position = Vector2(x, floor_y())


func bursting() -> bool:
	return state == "bound" and phase == 3 and state_time >= HOLD - BURST_TELL


func _burst() -> void:
	Sfx.play("break")
	Feel.add_trauma(0.4)
	var p := player()
	if p != null and not p.dead:
		var r := p.body_rect()
		var nearest := Vector2(clampf(global_position.x, r.position.x, r.end.x), clampf(global_position.y, r.position.y, r.end.y))
		if nearest.distance_to(global_position) <= BURST_RADIUS:
			_burst_hit = p.receive_attack(BURST_DAMAGE, self, false) != ""


## Where its beams come from.
func eye() -> Vector2:
	return global_position + Vector2(0, SIZE.y * 0.15)


func die() -> void:
	if state == "dying":
		return
	set_state("dying")
	dead = true
	collision_layer = 0
	for l in lights:
		l.light()
	for n in get_parent().get_children():
		if n is CoreBeam or n is MeteorSeed or n is CrystalSpike:
			n.queue_free()
	Feel.boss_kill(1.5)
	Feel.add_trauma(1.0)
	Sfx.play("roar", 0.0, 4.0)


func _process(delta: float) -> void:
	if state != "dying":
		return
	state_time += delta
	queue_redraw()
	if int(state_time * 10.0) % 2 == 0:
		var d := Dust.new()
		d.setup("debris")
		get_parent().add_child(d)
		d.global_position = global_position + Vector2(randf_range(-44, 44), randf_range(-24, 24))
	if state_time >= DYING_TIME:
		state = "dead"
		defeated.emit()
		visible = false
		queue_free()


func _draw() -> void:
	var t := state_time
	var white := flashing() or (bursting() and int(t * 16.0) % 2 == 0)
	var dim := 1.0
	if state == "dying":
		dim = maxf(0.0, 1.0 - t / DYING_TIME)
		white = int(t * 12.0) % 2 == 0 and t < 0.8
	var beat := maxf(0.0, 1.0 - fmod(Time.get_ticks_msec() / 1000.0 * 1.25, 1.0) * 4.0)
	var held := bound() or state == "rise"
	# Petals of black crystal all round it: splayed while it floats, crushed in while a root holds it.
	var reach := 0.7 if held else 1.0
	for i in 9:
		var dir := Vector2.from_angle(TAU * i / 9.0 + 0.2 * sin(t * 0.8))
		var base := dir * 22.0
		var tip := dir * (58.0 + (8.0 if i % 2 else 0.0) + beat * 2.0) * reach
		var side := dir.orthogonal() * 9.0
		draw_colored_polygon(PackedVector2Array([base + side * 1.2, tip, base - side * 1.2]), OUTLINE)
		draw_colored_polygon(PackedVector2Array([base + side, tip * 0.97, base - side]), PETAL if not white else Color.WHITE)
		draw_line(base, tip * 0.9, PETAL_LIGHT if not white else Color.WHITE, 1.0)
	# The bulb, swelling with the heartbeat, cracked with cyan when it is cut.
	var r := 26.0 + beat * 2.0
	draw_circle(Vector2.ZERO, r + 2.0, OUTLINE)
	draw_circle(Vector2.ZERO, r, FLESH.lerp(FLESH_LIGHT, beat * 0.5) if not white else Color.WHITE)
	var cracks := 1.0 - health_fraction()
	for i in int(cracks * 8.0):
		var a := i * 2.4
		draw_line(Vector2.from_angle(a) * 8.0, Vector2.from_angle(a + 0.3) * r, Color(CRYSTAL, dim), 1.0)
	# While held, the Tree's roots are wound over it from the floor.
	if bound():
		var grip := minf(1.0, state_time / DRAG)
		for side in [-1.0, 1.0]:
			var a := Vector2(side * 30.0, SIZE.y * 0.5 + 4.0)
			var c := Vector2(side * 44.0, -r * 1.2)
			var b := Vector2(-side * 14.0, -r - 2.0)
			var prev := a
			for i in range(1, 11):
				var k := float(i) / 10.0 * grip
				var pt := a.lerp(c, k).lerp(c.lerp(b, k), k)
				var w := lerpf(9.0, 4.0, k)
				draw_line(prev, pt, OUTLINE, w + 2.0)
				draw_line(prev, pt, TreeRoot.BARK, w)
				draw_line(prev, pt, TreeRoot.BARK_LIGHT, 1.0)
				prev = pt
	# The eye, following you.
	var e := eye() - global_position
	draw_circle(e, 14.0, OUTLINE)
	draw_circle(e, 13.0, Color(CRYSTAL_LIGHT, dim))
	var pupil := e + _look * 5.0
	draw_circle(pupil, 7.0, Color(CRYSTAL, dim))
	draw_circle(pupil, 3.5, Color(IRIS, dim) if state != "dying" else OUTLINE)
	if state == "gather":
		var k := state_time / tell()
		draw_arc(Vector2(0, floor_y() - global_position.y), 10.0 + 30.0 * k, PI, TAU, 16, Color(IRIS, 0.5 + 0.5 * k), 2.0)
	if bursting():
		draw_arc(Vector2.ZERO, BURST_RADIUS, 0.0, TAU, 28, Color(CRYSTAL_LIGHT, 0.6), 1.0)
