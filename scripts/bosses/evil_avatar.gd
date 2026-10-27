class_name EvilAvatar
extends Enemy
## The Evil One, phase 1: The Throne (design bible 8.9). The meteor wears a
## body of armor grown from its own black crystal and comes down off its throne
## to duel you with a crystal greatsword. A standard boss, and the first of the
## Evil One's three arenas.
##
## It stalks you and picks from four attacks:
## - Cleave (close): the greatsword goes up overhead (tell), then comes down
##   in a wide arc in front of it. Parryable; a parry staggers it, open.
## - Lunge (middle): it sinks into a crouch, blade back (tell), then drives
##   across the floor point first. Parryable.
## - Pull (any range): it plants the blade and raises a glowing palm (tell);
##   the meteor's wrong gravity drags you toward it for PULL_TIME, then bursts
##   out from it in a ring. Run or dash against the pull. Unparryable.
## - Rain (far): it lifts the blade to the vault (tell) and spikes of crystal
##   erupt from the floor in a line toward you, each marking its spot first.
## Its crystal plate halves blows from the front; strike it from behind, from
## above, or while it reels from a parry. Below half health (phase 2) its tells
## are shorter (never under Enemy.MIN_TELEGRAPH), a cleave comes back for a
## second swing, and its pull is stronger.

signal defeated

const DISPLAY_NAME := "The Evil One"
const EPITHET := "Avatar on the Throne"
const MAX_HP := 360
const PHASES := [0.5]
const WALK_SPEED := 50.0
const WALK_TIME := 0.8
const CLEAVE_RANGE := 72.0
const RAIN_RANGE := 170.0
const CLEAVE_TELL := 0.55
const LUNGE_TELL := 0.5
const PULL_TELL := 0.6
const RAIN_TELL := 0.6
## Phase 2 tells are this fraction as long.
const FAST := 0.75
const CLEAVE_DAMAGE := 20
const CLEAVE_SIZE := Vector2(76, 64)
const LUNGE_DAMAGE := 18
const LUNGE_SPEED := 260.0
const LUNGE_TIME := 0.35
const LUNGE_SIZE := Vector2(44, 20)
const PULL_TIME := 1.2
const PULL_SPEED := 70.0
const PULL_SPEED_P2 := 95.0
const BURST_RADIUS := 52.0
const BURST_DAMAGE := 14
const SPIKES := 6
const SPIKE_GAP := 26.0
const SPIKE_STEP := 0.09
const STRIKE_TIME := 0.18
const RECOVER := 0.7
const STAGGER := 1.2
const ARMOR := 0.5
const INTRO_TIME := 1.6
const DYING_TIME := 1.6
## The drawing is laid out small and drawn this much larger.
const SCALE := 1.3

const OUTLINE := Color("0c0812")
const PLATE := Color("2a1e3a")
const PLATE_LIGHT := Color("4a3a66")
const PLATE_DARK := Color("170f22")
const CRYSTAL := Color("4ae0d8")
const CRYSTAL_LIGHT := Color("b8fff4")
const VEIN := Color("d03050")
const CAPE := Color("4a0e24")
const CAPE_DARK := Color("2a0614")
const BLADE := Color("1a1428")
const EYE := Color("e8fffc")

## The hall's interior in pixels (walls and ceiling outside it).
var arena := Rect2(16, 64, 928, 256)
var phase := 1
var _last := ""
var _since_pull := 0
var _second := false
var _struck := false
var _burst_t := -1.0
var _rng := RandomNumberGenerator.new()


func _init() -> void:
	max_hp = MAX_HP
	contact_damage = 16
	gold_min = 120
	gold_max = 160
	xp = 400
	body_size = Vector2(30, 66)
	knockback = 0.0
	launchable = false
	state = "dormant"
	_rng.seed = 1987


func _ready() -> void:
	super._ready()
	add_to_group("boss")


## Starts the fight (called by the arena once the player is inside).
func begin() -> void:
	face_player()
	set_state("intro")
	Sfx.play("roar", 0.0, -4.0)
	Feel.add_trauma(0.4)
	GameState.banner.emit(DISPLAY_NAME, EPITHET)


func health_fraction() -> float:
	return clampf(float(hp) / max_hp, 0.0, 1.0)


func floor_y() -> float:
	return arena.end.y


func tell(base: float) -> float:
	return maxf(Enemy.MIN_TELEGRAPH, base * (FAST if phase == 2 else 1.0))


## Its opening (Enemy.punishable): reeling from a parry.
func punishable() -> bool:
	return open()


func open() -> bool:
	return state == "staggered"


func _modify_damage(damage: int, dir: Vector2) -> int:
	if state in ["dormant", "intro", "dying"]:
		return 0
	# The plate covers its front; its back, its crown and a reeling guard are bare.
	if open() or dir.y > 0.0 or (dir.x != 0.0 and signf(dir.x) == float(facing)):
		return damage
	return maxi(1, roundi(damage * ARMOR))


func take_hit(damage: int, dir: Vector2) -> void:
	super.take_hit(damage, dir)
	# A boss shrugs off hitstun: blows never interrupt its attacks.
	_hitstun = 0.0
	if not dead and phase == 1 and health_fraction() <= PHASES[0]:
		phase = 2
		Sfx.play("roar", 0.0, -2.0)
		Feel.add_trauma(0.4)


func _on_blocked(_dir: Vector2) -> void:
	pass


## A parried swing leaves it reeling, open to every blow.
func stagger() -> void:
	if dead or state in ["dormant", "intro", "dying"]:
		return
	set_state("staggered")
	_flash = 0.1
	velocity.x = -facing * 60.0


func _think(delta: float) -> void:
	velocity.x = 0.0
	match state:
		"dormant":
			pass
		"intro":
			if state_time >= INTRO_TIME:
				set_state("walk")
		"walk":
			face_player()
			var dx := _player_dx()
			if absf(dx) > 30.0:
				velocity.x = signf(dx) * WALK_SPEED
			if state_time >= WALK_TIME:
				_choose(absf(dx))
		"cleave_tell":
			if state_time >= tell(CLEAVE_TELL):
				set_state("cleave")
				_struck = false
				Sfx.play("heavy", 0.05, 0.0)
		"cleave":
			if not _struck:
				_struck = true
				hit_player_in_rect(cleave_rect(), CLEAVE_DAMAGE)
				Feel.add_trauma(0.3)
				_dust(Vector2(facing * 34.0, 0), "debris")
			if state_time >= STRIKE_TIME:
				if phase == 2 and not _second:
					# In the second phase the blade comes back for another swing.
					_second = true
					face_player()
					set_state("cleave_tell")
					Sfx.play("tell_blade", 0.05, -2.0)
				else:
					_second = false
					set_state("recover")
		"lunge_tell":
			if state_time >= tell(LUNGE_TELL):
				set_state("lunge")
				_struck = false
				Sfx.play("dash", 0.05, 0.0)
		"lunge":
			velocity.x = facing * LUNGE_SPEED
			if not _struck and hit_player_in_rect(lunge_rect(), LUNGE_DAMAGE) != "":
				_struck = true
			if int(state_time * 14.0) % 2 == 0:
				_dust(Vector2(-facing * 10.0, 0), "run")
			if state_time >= LUNGE_TIME or (is_on_wall() and state_time > 0.05):
				set_state("recover")
		"pull_tell":
			if state_time >= tell(PULL_TELL):
				set_state("pull")
				Sfx.play("swell", 0.0, 0.0)
		"pull":
			var p := player()
			if p != null and not p.dead:
				var dx := global_position.x - p.global_position.x
				if absf(dx) > 20.0:
					p.pull = Vector2(signf(dx) * (PULL_SPEED_P2 if phase == 2 else PULL_SPEED), 0)
			if state_time >= PULL_TIME:
				_burst()
		"rain_tell":
			if state_time >= tell(RAIN_TELL):
				_rain()
		"recover", "rain":
			if state_time >= RECOVER:
				set_state("walk")
		"burst":
			if state_time >= RECOVER:
				set_state("walk")
		"staggered":
			if state_time >= STAGGER:
				set_state("walk")
		_:
			set_state("walk")
	if _burst_t >= 0.0:
		_burst_t += delta
		if _burst_t > 0.3:
			_burst_t = -1.0


func _choose(dist: float) -> void:
	var pick := "lunge"
	if dist <= CLEAVE_RANGE:
		pick = "cleave"
	elif dist >= RAIN_RANGE:
		pick = "rain"
	if _since_pull >= 3 or (pick == _last and pick != "cleave"):
		pick = "pull"
	_last = pick
	_since_pull = 0 if pick == "pull" else _since_pull + 1
	face_player()
	set_state(pick + "_tell")


func cleave_rect() -> Rect2:
	var x0 := global_position.x + (facing * 2.0 if facing > 0 else -CLEAVE_SIZE.x - 2.0)
	return Rect2(x0, global_position.y - CLEAVE_SIZE.y, CLEAVE_SIZE.x, CLEAVE_SIZE.y)


func lunge_rect() -> Rect2:
	var x0 := global_position.x + (facing * 4.0 if facing > 0 else -LUNGE_SIZE.x - 4.0)
	return Rect2(x0, global_position.y - 44.0, LUNGE_SIZE.x, LUNGE_SIZE.y)


func _burst() -> void:
	set_state("burst")
	_burst_t = 0.0
	Sfx.play("break", 0.0, 2.0)
	Feel.add_trauma(0.4)
	var p := player()
	if p != null and not p.dead:
		var r := p.body_rect()
		var c := center()
		var nearest := Vector2(clampf(c.x, r.position.x, r.end.x), clampf(c.y, r.position.y, r.end.y))
		if nearest.distance_to(c) <= BURST_RADIUS:
			p.receive_attack(BURST_DAMAGE, self, false)


func _rain() -> void:
	set_state("rain")
	Sfx.play("crackle", 0.05, 0.0)
	var dir := float(facing)
	for i in SPIKES:
		var x := global_position.x + dir * (36.0 + i * SPIKE_GAP)
		if x < arena.position.x + 8.0 or x > arena.end.x - 8.0:
			break
		var s := CrystalSpike.new()
		s.delay = i * SPIKE_STEP
		get_parent().add_child(s)
		s.global_position = Vector2(x, floor_y())


func _player_dx() -> float:
	var p := player()
	return p.global_position.x - global_position.x if p != null else 0.0


func _dust(offset: Vector2, kind: String) -> void:
	var d := Dust.new()
	d.setup(kind)
	get_parent().add_child(d)
	d.global_position = global_position + offset


func die() -> void:
	if state == "dying":
		return
	set_state("dying")
	dead = true
	collision_layer = 0
	velocity = Vector2.ZERO
	Feel.boss_kill(1.2)
	Feel.add_trauma(0.9)
	Sfx.play("roar", 0.0, 4.0)


func _process(delta: float) -> void:
	if state != "dying":
		return
	state_time += delta
	if int(state_time * 10.0) % 3 == 0:
		_dust(Vector2(_rng.randf_range(-14, 14), _rng.randf_range(-50, -6)), "debris")
	queue_redraw()
	if state_time >= DYING_TIME:
		state = "dead"
		defeated.emit()
		super.die()


# --- Drawing ------------------------------------------------------------------
# Code-drawn at 2x: the origin is at its feet, x mirrored by facing.

func _draw() -> void:
	var white := flashing() or (state.ends_with("_tell") and telegraph_pulse())
	var f := float(facing)
	var jitter := 0.0
	if state == "dying":
		jitter = roundf(randf_range(-2.0, 2.0))
		white = int(state_time * 12.0) % 2 == 0
	draw_set_transform(Vector2(jitter, 0), 0.0, Vector2(f * SCALE, SCALE))
	var crouch := 6.0 if state in ["lunge_tell", "lunge"] else 0.0
	var reel := -4.0 if state == "staggered" else 0.0
	var plate := Color.WHITE if white else PLATE
	var light := Color.WHITE if white else PLATE_LIGHT
	var dark := Color("d8d0e8") if white else PLATE_DARK
	# The cape behind, torn into points and stirring.
	var stir := sin(state_time * 4.0) * 2.0
	var cape := PackedVector2Array([Vector2(-6, -46 + crouch), Vector2(-16 + stir, -4), Vector2(-12, 0), Vector2(-8 + stir, -6), Vector2(-4, 0), Vector2(2, -40 + crouch)])
	draw_colored_polygon(cape, CAPE_DARK if not white else Color.WHITE)
	# Legs: greaves, knees and sabatons.
	for side in [-1.0, 1.0]:
		var lx: float = side * 5.0 + (side * 2.0 if crouch > 0.0 else 0.0)
		draw_rect(Rect2(lx - 4.0, -22.0 + crouch * 0.5, 8.0, 22.0 - crouch * 0.5), OUTLINE)
		draw_rect(Rect2(lx - 3.0, -21.0 + crouch * 0.5, 6.0, 20.0 - crouch * 0.5), plate)
		draw_rect(Rect2(lx - 3.0, -14.0, 6.0, 2.0), light)
		draw_rect(Rect2(lx - 4.0, -3.0, 10.0, 3.0), dark)
	# Torso: a breastplate grown of crystal plates, a vein of red across it.
	var ty := -46.0 + crouch + reel * 0.25
	draw_rect(Rect2(-10.0, ty - 1.0, 20.0, 26.0), OUTLINE)
	draw_rect(Rect2(-9.0, ty, 18.0, 24.0), plate)
	draw_rect(Rect2(-9.0, ty, 18.0, 3.0), light)
	draw_rect(Rect2(-1.0, ty + 3.0, 2.0, 18.0), dark)
	if not white:
		draw_line(Vector2(-8, ty + 8), Vector2(0, ty + 14), Color(VEIN, 0.8), 1.0)
		draw_line(Vector2(0, ty + 14), Vector2(7, ty + 10), Color(VEIN, 0.8), 1.0)
		# The meteor's light at its heart.
		var k := 0.6 + 0.4 * sin(state_time * 6.0)
		draw_rect(Rect2(-2.0, ty + 9.0, 4.0, 4.0), Color(CRYSTAL, k))
	# Pauldrons: crystal spikes over each shoulder.
	for side in [-1.0, 1.0]:
		var sx: float = side * 10.0
		var spike := PackedVector2Array([Vector2(sx - 5.0, ty + 4.0), Vector2(sx + side * 4.0, ty - 10.0), Vector2(sx + 5.0, ty + 4.0)])
		draw_colored_polygon(spike, CRYSTAL if not white else Color.WHITE)
		draw_rect(Rect2(sx - 5.0, ty + 1.0, 10.0, 6.0), dark)
	# Helm: a horned crown of crystal and a slit of light for eyes.
	var hy := ty - 14.0
	draw_rect(Rect2(-7.0, hy - 1.0, 14.0, 15.0), OUTLINE)
	draw_rect(Rect2(-6.0, hy, 12.0, 13.0), plate)
	draw_rect(Rect2(-6.0, hy, 12.0, 2.0), light)
	for side in [-1.0, 1.0]:
		var horn := PackedVector2Array([Vector2(side * 3.0, hy + 1.0), Vector2(side * 9.0, hy - 12.0), Vector2(side * 6.0, hy + 2.0)])
		draw_colored_polygon(horn, CRYSTAL_LIGHT if not white else Color.WHITE)
	var glow := EYE if state.ends_with("_tell") or state == "pull" else CRYSTAL
	draw_rect(Rect2(-1.0, hy + 5.0, 7.0, 2.0), glow)
	# Arms and the greatsword, posed by what it is doing.
	_draw_blade(ty, white)
	draw_set_transform(Vector2.ZERO)
	# The pull's ring and the burst it ends in (not mirrored).
	if state == "pull":
		var k := state_time / PULL_TIME
		draw_arc(center() - global_position, BURST_RADIUS * (1.2 - 0.2 * k), 0.0, TAU, 32, Color(CRYSTAL, 0.25 + 0.5 * k), 2.0)
	if _burst_t >= 0.0:
		var k := _burst_t / 0.3
		draw_arc(center() - global_position, BURST_RADIUS * (0.6 + 0.4 * k), 0.0, TAU, 32, Color(CRYSTAL_LIGHT, 1.0 - k), 5.0)


## The greatsword: a long black blade with a cyan edge, in both hands.
func _draw_blade(ty: float, white: bool) -> void:
	var hand := Vector2(10, ty + 14.0)
	var tip := Vector2(46, ty + 14.0)
	match state:
		"cleave_tell":
			hand = Vector2(2, ty - 8.0)
			tip = Vector2(-18, ty - 40.0)
		"cleave":
			hand = Vector2(16, ty + 16.0)
			tip = Vector2(52, ty + 44.0)
		"lunge_tell":
			hand = Vector2(-6, ty + 14.0)
			tip = Vector2(-42, ty + 10.0)
		"lunge":
			hand = Vector2(16, ty + 12.0)
			tip = Vector2(58, ty + 12.0)
		"pull_tell", "pull", "burst":
			hand = Vector2(12, ty + 8.0)
			tip = Vector2(14, 6.0)
		"rain_tell":
			hand = Vector2(4, ty - 10.0)
			tip = Vector2(8, ty - 50.0)
		"staggered":
			hand = Vector2(8, ty + 18.0)
			tip = Vector2(30, ty + 40.0)
		"intro", "dormant":
			hand = Vector2(8, ty + 10.0)
			tip = Vector2(10, 6.0)
	# Arm from the shoulder to the hand.
	draw_line(Vector2(4, ty + 4.0), hand, OUTLINE, 6.0)
	draw_line(Vector2(4, ty + 4.0), hand, PLATE_LIGHT if not white else Color.WHITE, 4.0)
	var dir := (tip - hand).normalized()
	var side := dir.orthogonal()
	var blade := PackedVector2Array([hand + side * 3.0, tip + side * 1.0, tip + dir * 6.0, tip - side * 1.0, hand - side * 3.0])
	draw_colored_polygon(PackedVector2Array([hand + side * 4.0, tip + side * 2.0, tip + dir * 8.0, tip - side * 2.0, hand - side * 4.0]), OUTLINE)
	draw_colored_polygon(blade, BLADE if not white else Color.WHITE)
	draw_line(hand + side * 2.0, tip + side * 0.5 + dir * 4.0, CRYSTAL if not white else Color.WHITE, 1.0)
	# The guard and pommel.
	draw_line(hand + side * 7.0, hand - side * 7.0, OUTLINE, 4.0)
	draw_line(hand + side * 6.0, hand - side * 6.0, CRYSTAL_LIGHT if not white else Color.WHITE, 2.0)
	draw_circle(hand - dir * 6.0, 2.5, VEIN if not white else Color.WHITE)
	# The raised palm that pulls, glowing.
	if state in ["pull_tell", "pull"] and not white:
		var k := 0.5 + 0.5 * sin(state_time * 20.0)
		draw_circle(Vector2(-12, ty + 2.0), 4.0 + k * 2.0, Color(CRYSTAL, 0.4 + 0.4 * k))
