class_name EvilCore
extends Enemy
## The Evil One, phase 2: The Veins (design bible 8.9). The avatar is broken
## and the meteor's core, a vast crystal eye-flower rooted in the vault at the
## top of the shaft, fights for itself. No blade reaches it: it feeds through
## veins of light grown up the shaft (LightVein), and you climb, cutting them
## one by one, while it fires beams down at you. Each beam's line flickers for
## its tell first. Cut every vein and its light gutters out.
##
## Below half its light (phase 2) its tells are shorter (never under
## Enemy.MIN_TELEGRAPH), it fires more often, and every other volley is a pair
## of beams that fan out to either side of you. The Hour Glass holds the core
## and its beams.

signal defeated

const DISPLAY_NAME := "The Evil One"
const EPITHET := "Core of the Meteor"
const PHASES := [0.5]
## Health each vein carries (the bar empties as they are cut).
const VEIN_HP := 10
const BEAM_TELL := 0.6
const BEAM_TELL_P2 := 0.45
const VOLLEY_GAP := 2.2
const VOLLEY_GAP_P2 := 1.6
## How far apart the two beams of a fanned volley strike (radians).
const FAN := 0.18
const INTRO_TIME := 1.6
const DYING_TIME := 2.0
const SIZE := Vector2(96, 48)

const OUTLINE := Color("0c0812")
const FLESH := Color("4a1430")
const FLESH_LIGHT := Color("7a2448")
const PETAL := Color("2a1e3a")
const PETAL_LIGHT := Color("4a3a66")
const CRYSTAL := Color("4ae0d8")
const CRYSTAL_LIGHT := Color("b8fff4")
const IRIS := Color("ff4060")

## The shaft's interior in pixels.
var arena := Rect2(16, 64, 608, 960)
var phase := 1
var veins: Array[LightVein] = []
var _volley := 0.0
var _volleys := 0
var _look := Vector2.DOWN


func _init() -> void:
	max_hp = VEIN_HP
	contact_damage = 0
	gold_min = 150
	gold_max = 200
	xp = 500
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


## Starts the fight (called by the arena once the player is inside).
func begin() -> void:
	veins.clear()
	for v in get_parent().get_children():
		if v is LightVein and not v.is_cut:
			veins.append(v)
			v.cut.connect(_on_vein_cut)
	max_hp = maxi(1, veins.size()) * VEIN_HP
	hp = max_hp
	set_state("intro")
	Sfx.play("roar", 0.0, -6.0)
	Feel.add_trauma(0.4)
	GameState.banner.emit(DISPLAY_NAME, EPITHET)


func health_fraction() -> float:
	return clampf(float(hp) / max_hp, 0.0, 1.0)


func veins_left() -> int:
	return veins.filter(func(v: LightVein) -> bool: return is_instance_valid(v) and not v.is_cut).size()


func tell() -> float:
	return maxf(Enemy.MIN_TELEGRAPH, BEAM_TELL_P2 if phase == 2 else BEAM_TELL)


## No blade reaches the core itself.
func _modify_damage(_damage: int, _dir: Vector2) -> int:
	return 0


func _on_blocked(_dir: Vector2) -> void:
	var d := Dust.new()
	d.setup("guard")
	get_parent().add_child(d)
	d.global_position = global_position + Vector2(0, SIZE.y * 0.5)
	Sfx.play("guard")


func stagger() -> void:
	pass


func launch() -> bool:
	return false


func _on_vein_cut() -> void:
	if dead or state == "dying":
		return
	hp = veins_left() * VEIN_HP
	_flash = 0.15
	Sfx.play("roar", 0.1, -8.0)
	Feel.add_trauma(0.3)
	if phase == 1 and health_fraction() <= PHASES[0]:
		phase = 2
	if hp <= 0:
		die()


func _physics_process(delta: float) -> void:
	if TimeStop.active():
		queue_redraw()
		return
	super._physics_process(delta)


func _think(delta: float) -> void:
	velocity = Vector2.ZERO
	var p := player()
	if p != null:
		_look = _look.lerp((p.body_rect().get_center() - global_position).normalized(), minf(1.0, delta * 4.0))
	match state:
		"dormant":
			pass
		"intro":
			if state_time >= INTRO_TIME:
				set_state("watch")
				_volley = VOLLEY_GAP * 0.5
		"watch":
			_volley -= delta
			if _volley <= 0.0:
				_fire()
				_volley = VOLLEY_GAP_P2 if phase == 2 else VOLLEY_GAP


## A volley: one beam at you, or in the second phase every other volley, two
## fanned to either side of you (stand still between them).
func _fire() -> void:
	var p := player()
	if p == null or p.dead:
		return
	_volleys += 1
	var at := (p.body_rect().get_center() - eye()).normalized()
	var dirs: Array[Vector2] = [at]
	if phase == 2 and _volleys % 2 == 0:
		dirs = [at.rotated(-FAN), at.rotated(FAN)]
	for d in dirs:
		var b := CoreBeam.new()
		b.direction = d
		b.tell = tell()
		get_parent().add_child(b)
		b.global_position = eye()
	Sfx.play("zap", 0.1, -4.0)


## Where the beams come from: the eye at the heart of the flower.
func eye() -> Vector2:
	return global_position + Vector2(0, SIZE.y * 0.2)


func die() -> void:
	if state == "dying":
		return
	set_state("dying")
	dead = true
	collision_layer = 0
	for b in get_parent().get_children():
		if b is CoreBeam:
			b.queue_free()
	Feel.hitstop(0.15)
	Feel.slowmo(0.3, 1.2)
	Feel.add_trauma(0.9)
	Sfx.play("roar", 0.0, 3.0)


func _process(delta: float) -> void:
	if state != "dying":
		return
	state_time += delta
	queue_redraw()
	if int(state_time * 10.0) % 3 == 0:
		var d := Dust.new()
		d.setup("debris")
		get_parent().add_child(d)
		d.global_position = global_position + Vector2(randf_range(-40, 40), randf_range(-16, 20))
	if state_time >= DYING_TIME:
		state = "dead"
		defeated.emit()
		# It is not destroyed, only starved: phase 3 waits for it at the heart.
		dead = true
		visible = false
		queue_free()


func _draw() -> void:
	var t := state_time
	var white := flashing()
	var dim := 1.0
	if state == "dying":
		dim = maxf(0.0, 1.0 - t / DYING_TIME)
		white = int(t * 12.0) % 2 == 0 and t < 0.6
	var beat := maxf(0.0, 1.0 - fmod(Time.get_ticks_msec() / 1000.0 * 1.25, 1.0) * 4.0)
	# Petals of black crystal around it, splayed from the vault.
	for i in 7:
		var a := PI * (0.1 + 0.8 * i / 6.0)
		var dir := Vector2(cos(a), sin(a) * 0.6)
		var base := dir * 20.0
		var tip := dir * (54.0 + (6.0 if i % 2 else 0.0) + beat * 2.0)
		var side := dir.orthogonal() * 8.0
		draw_colored_polygon(PackedVector2Array([base + side * 1.2, tip, base - side * 1.2]), OUTLINE)
		draw_colored_polygon(PackedVector2Array([base + side, tip * 0.97, base - side]), PETAL if not white else Color.WHITE)
		draw_line(base, tip * 0.9, PETAL_LIGHT if not white else Color.WHITE, 1.0)
	# The fleshy bulb, veined, swelling on the heartbeat.
	var r := 22.0 + beat * 1.5
	draw_circle(Vector2.ZERO, r + 2.0, OUTLINE)
	draw_circle(Vector2.ZERO, r, FLESH.lerp(FLESH_LIGHT, beat * 0.5) if not white else Color.WHITE)
	# The eye, following you.
	var e := eye() - global_position
	draw_circle(e, 12.0, OUTLINE)
	draw_circle(e, 11.0, Color(CRYSTAL_LIGHT, dim))
	var pupil := e + _look * 4.0
	draw_circle(pupil, 6.0, Color(CRYSTAL, dim))
	draw_circle(pupil, 3.0, Color(IRIS, dim) if state != "dying" else Color(OUTLINE, 1.0))
	# Light gathering in it while a beam is aimed.
	var aiming := false
	for b in get_parent().get_children():
		if b is CoreBeam and not b.firing():
			aiming = true
	if aiming and state != "dying":
		draw_circle(pupil, 4.0 + 2.0 * absf(sin(t * 20.0)), Color(CRYSTAL_LIGHT, 0.7))
