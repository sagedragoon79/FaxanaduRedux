class_name KingGrieve
extends Enemy
## King Grieve, the Drowned Sovereign (design bible 8.7): the dwarf king who
## bargained with the meteor to save his people. Regal, tragic, half of him
## grown over with magenta crystal, a great-axe in his hands. The boss of
## Dartmoor, in his flooded throne hall.
##
## Phase 1, the duel: he walks you down and swings heavy two-blow combos, a
## chop (the axe raised overhead, its edge glinting) then a low sweep. Both can
## be parried, and a parry leaves him reeling and open. Otherwise his crystal
## half turns half of every blow. Run from him and he leaps after you and
## brings the axe down, shaking shockwaves across the floor.
##
## Phase 2 (below half), the throne: he leaps up onto his dais, plants the axe
## and wards himself in crystal, untouchable from the sides; crystal thorns line
## the dais. From the throne he calls crystal shards up out of the floor, nearest
## the dais first. Each glows before it bursts out and shoots up to the vault.
## Hold them in the air with the Hour Glass and they are a stair up to his
## crown: strike down on it and he is thrown from the dais, open, to duel again
## until he climbs back.
##
## Phase 3 (below a fifth), the meteor takes him: his body cracks open, the
## crystal blazing through, and he comes down off the throne for good. Frantic
## now, he walks you down faster, his tells shorter (never under
## MIN_TELEGRAPH), and every combo ends with the axe driven into the floor and
## a line of crystal spikes bursting out toward you. Cracked, he no longer turns
## half a blow, and a parry still throws him reeling.

signal defeated

const DISPLAY_NAME := "King Grieve"
const EPITHET := "the Drowned Sovereign"
const MAX_HP := 320
const PHASES := [0.5, 0.2]
const WALK_SPEED := 40.0
const COMBO_RANGE := 70.0
const LEAP_RANGE := 150.0
const CHOP_TELL := 0.6
const SWEEP_TELL := 0.4
const LEAP_TELL := 0.6
const SUMMON_TELL := 0.5
## Phase 2 duel tells are this fraction as long (never under MIN_TELEGRAPH).
const FAST := 0.8
## Phase 3 tells are this fraction as long, and he walks this much faster.
const FRANTIC := 0.65
const FRANTIC_WALK := 1.8
const BURST_TELL := 0.45
const SPIKES := 6
const SPIKE_GAP := 22.0
const SPIKE_STEP := 0.08
## The meteor taking him: he roars and cracks, untouchable, this long.
const POSSESSED := 1.4
const STRIKE_TIME := 0.16
const CHOP_DAMAGE := 20
const SWEEP_DAMAGE := 16
const SLAM_DAMAGE := 22
const THORN_DAMAGE := 10
const RECOVER := 0.8
const LEAP_AIR := 0.7
const STAGGER := 1.2
## Thrown from the throne: down and open this long.
const FALLEN := 1.8
## How long he duels in phase 2 before he climbs back to the throne.
const DUEL_TIME := 7.0
## Seconds between waves of shards while he holds the throne.
const WAVE_GAP := 3.2
const SHARDS := 4
## Across between shards, and between their launches: a stair 48 across and
## 35 up while they rise together.
const SHARD_STEP := 48.0
const SHARD_STAGGER := 0.25
const ARMOR := 0.5
const INTRO_TIME := 1.4
const DYING_TIME := 1.6
## The drawing is laid out in half-pixels at this scale.
const SCALE := 2.5

const OUTLINE := Color("120c16")
const ROBE := Color("2e4f5a")
const ROBE_LIGHT := Color("4f7f88")
const ROBE_DARK := Color("1c3038")
const MANTLE := Color("6a2a3a")
const SKIN := Color("b88a6a")
const BEARD := Color("b8b8c0")
const BEARD_DARK := Color("7a7a88")
const GOLD := Color("e0b050")
const GOLD_DARK := Color("8a6a2a")
const CRYSTAL := Color("e05ad0")
const CRYSTAL_LIGHT := Color("ffb8f0")
const CRYSTAL_DARK := Color("7a2a78")
const STEEL := Color("a8b4bc")
const STEEL_LIGHT := Color("e8f0f4")
const HAFT := Color("5a3a22")
const EYE := Color("ffe0f8")

## The hall's interior in pixels (walls and ceiling outside it).
var arena := Rect2(16, 64, 928, 256)
## The throne dais, in pixels (its top edge is where he stands on it).
var dais := Rect2(736, 224, 192, 96)
var phase := 1
var _struck := false
var _next := ""
var _wave := 0.0
var _duel := 0.0


func _init() -> void:
	max_hp = MAX_HP
	contact_damage = 16
	gold_min = 120
	gold_max = 160
	xp = 400
	body_size = Vector2(34, 62)
	knockback = 0.0
	launchable = false
	state = "dormant"


func _ready() -> void:
	super._ready()
	add_to_group("boss")


## Starts the fight (called by the arena once the player is inside).
func begin() -> void:
	face_player()
	set_state("intro")
	Sfx.play("roar", 0.0, -4.0)
	Feel.add_trauma(0.3)
	GameState.banner.emit(DISPLAY_NAME, EPITHET)


func health_fraction() -> float:
	return clampf(float(hp) / max_hp, 0.0, 1.0)


func floor_y() -> float:
	return arena.end.y


func tell(base: float) -> float:
	var k := 1.0
	match phase:
		2:
			k = FAST
		3:
			k = FRANTIC
	return maxf(Enemy.MIN_TELEGRAPH, base * k)


## Cracked open by the meteor: phase 3.
func cracked() -> bool:
	return phase == 3


## Warded on his throne: only a blow to the crown gets through.
func warded() -> bool:
	return state in ["ward", "summon_tell"]


## Open to every blow: reeling from a parry, or thrown from the throne.
func open() -> bool:
	return is_staggered() or state == "fallen"


func _modify_damage(damage: int, dir: Vector2) -> int:
	if state in ["dormant", "intro", "dying", "to_throne", "possessed"]:
		return 0
	if warded():
		if dir.y > 0.0:
			_thrown.call_deferred()
			return damage
		return 0
	if open() or cracked():
		return damage
	return maxi(1, roundi(damage * ARMOR))


func take_hit(damage: int, dir: Vector2) -> void:
	super.take_hit(damage, dir)
	# A boss shrugs off hitstun: blows never interrupt his attacks.
	_hitstun = 0.0
	if not dead and phase == 1 and health_fraction() <= PHASES[0]:
		phase = 2
		Sfx.play("roar", 0.0, -2.0)
		Feel.add_trauma(0.4)
		if not open():
			_to_throne()
	elif not dead and phase == 2 and health_fraction() <= PHASES[1]:
		_possess()


## A parried chop or sweep leaves him reeling, shield-arm wide.
func stagger() -> void:
	if dead or state in ["ward", "summon_tell", "to_throne", "fallen", "dormant", "intro", "possessed"]:
		return
	super.stagger()
	_stagger = STAGGER


func _think(delta: float) -> void:
	if state not in ["leap", "to_throne", "fallen", "possessed"]:
		velocity.x = 0.0
	if phase == 2 and state not in ["to_throne", "ward", "summon_tell"]:
		_duel += delta
	match state:
		"dormant":
			pass
		"intro":
			if state_time >= INTRO_TIME:
				set_state("walk")
		"idle", "walk":
			if state == "idle":
				set_state("walk")
			if phase == 2 and _duel >= DUEL_TIME:
				_to_throne()
				return
			face_player()
			var dx := _player_dx()
			if absf(dx) <= COMBO_RANGE:
				_open("chop_tell", "chop")
			elif absf(dx) >= LEAP_RANGE and state_time > 0.6:
				set_state("leap_tell")
				Sfx.play("swell", 0.1, -4.0)
			else:
				velocity.x = signf(dx) * WALK_SPEED * (FRANTIC_WALK if cracked() else 1.0)
		"chop_tell", "sweep_tell":
			var base := CHOP_TELL if state == "chop_tell" else SWEEP_TELL
			if state_time >= tell(base):
				_struck = false
				set_state(_next)
				Sfx.play("slash", 0.05, 2.0)
		"chop", "sweep":
			if not _struck:
				var res := hit_player_in_rect(axe_rect(), CHOP_DAMAGE if state == "chop" else SWEEP_DAMAGE)
				_struck = res != ""
			if state == "chop" and state_time >= STRIKE_TIME:
				Feel.add_trauma(0.2)
				_open("sweep_tell", "sweep")
			elif state == "sweep" and state_time >= STRIKE_TIME:
				if cracked():
					_open("burst_tell", "burst")
				else:
					set_state("recover")
		"burst_tell":
			if state_time >= tell(BURST_TELL):
				_burst()
				set_state("recover")
		"possessed":
			if collision_mask == 0 and state_time >= LEAP_AIR:
				# Down off the throne, onto the hall floor.
				global_position = Vector2(dais.position.x - 40.0, floor_y())
				velocity = Vector2.ZERO
				collision_mask = Player.LAYER_WORLD
			if state_time >= POSSESSED and collision_mask != 0:
				set_state("walk")
		"leap_tell":
			face_player()
			if state_time >= tell(LEAP_TELL):
				_leap_to(Vector2(clampf(_player_x(), arena.position.x + 24.0, dais.position.x - 24.0), floor_y()))
				set_state("leap")
		"leap":
			if state_time > 0.15 and is_on_floor():
				_slam()
		"recover":
			if state_time >= RECOVER:
				set_state("walk")
		"to_throne":
			# He sails over the dais's face and comes down on top of it.
			if state_time >= LEAP_AIR:
				global_position = Vector2(dais.get_center().x, dais.position.y)
				velocity = Vector2.ZERO
				collision_mask = Player.LAYER_WORLD
				_wave = WAVE_GAP - 0.8
				set_state("ward")
				Sfx.play("break", 0.0, -2.0)
		"ward":
			face_player()
			_thorns()
			_wave += delta
			if _wave >= WAVE_GAP:
				_wave = 0.0
				set_state("summon_tell")
				Sfx.play("swell", 0.1, -2.0)
		"summon_tell":
			_thorns()
			if state_time >= SUMMON_TELL:
				_summon()
				set_state("ward")
		"fallen":
			if state_time >= FALLEN and phase == 3:
				set_state("walk")
			elif state_time >= FALLEN:
				_duel = 0.0
				set_state("walk")
		_:
			set_state("walk")


func _open(tell_state: String, next: String) -> void:
	velocity.x = 0.0
	face_player()
	_next = next
	set_state(tell_state)


## Where the axe bites: the chop high and long, the sweep low and wide.
func axe_rect() -> Rect2:
	var x := global_position.x
	if state == "sweep":
		return Rect2(x if facing > 0 else x - 64.0, global_position.y - 22.0, 64.0, 22.0)
	return Rect2(x if facing > 0 else x - 54.0, global_position.y - 58.0, 54.0, 58.0)


## The thorns along the dais top while he wards: no standing beside him.
func thorn_rect() -> Rect2:
	return Rect2(dais.position.x, dais.position.y - 10.0, dais.size.x, 10.0)


func _thorns() -> void:
	hit_player_in_rect(thorn_rect(), THORN_DAMAGE, false)


## A ballistic leap that lands at `to` after LEAP_AIR seconds.
func _leap_to(to: Vector2) -> void:
	var t := LEAP_AIR
	var d := to - global_position
	velocity = Vector2(d.x / t, (d.y - 0.5 * GRAVITY * t * t) / t)
	Sfx.play("dash", 0.05, -2.0)


func _slam() -> void:
	set_state("recover")
	var at := global_position
	hit_player_in_rect(Rect2(at.x - 36.0, at.y - 30.0, 72.0, 30.0), SLAM_DAMAGE, false)
	Sfx.play("break", 0.05, 1.0)
	Feel.add_trauma(0.45)
	Feel.rumble(0.7, 0.7, 0.25)
	for dir in [-1, 1]:
		var w := Shockwave.new()
		w.room = get_parent() as Room
		w.direction = dir
		get_parent().add_child(w)
		w.global_position = at + Vector2(dir * 18.0, 0)


func _to_throne() -> void:
	set_state("to_throne")
	_stagger = 0.0
	collision_mask = 0
	_leap_to(Vector2(dais.get_center().x, dais.position.y))


## The meteor takes him: wherever he is, he roars, cracks open and comes down
## to the hall floor, never to go back to the throne.
func _possess() -> void:
	phase = 3
	_stagger = 0.0
	set_state("possessed")
	Sfx.play("roar", 0.0, 2.0)
	Feel.add_trauma(0.7)
	Feel.rumble(1.0, 1.0, 0.4)
	if global_position.y < floor_y() - 2.0:
		# Off the throne: a leap down in front of the dais.
		collision_mask = 0
		_leap_to(Vector2(dais.position.x - 40.0, floor_y()))
	else:
		velocity = Vector2.ZERO


## The axe driven into the floor: crystal spikes burst out in a line toward you.
func _burst() -> void:
	face_player()
	Sfx.play("break", 0.05, 3.0)
	Feel.add_trauma(0.35)
	var room := get_parent() as Room
	for i in SPIKES:
		var at := Vector2(global_position.x + facing * (body_size.x * 0.5 + 12.0 + i * SPIKE_GAP), floor_y())
		if not arena.has_point(at - Vector2(0, 4)):
			break
		var sp := CrystalSpike.new()
		sp.delay = i * SPIKE_STEP
		room.add_child(sp)
		sp.global_position = at


## A blow to his crown throws him down off the dais, open to every blow.
func _thrown() -> void:
	if dead or not warded():
		return
	set_state("fallen")
	velocity = Vector2(-260.0, -220.0)
	Sfx.play("break", 0.0, 2.0)
	Feel.hitstop(0.08)
	Feel.add_trauma(0.5)


## Calls a wave of shards up out of the floor, nearest the dais first.
func _summon() -> void:
	var room := get_parent()
	for k in SHARDS:
		var s := CrystalShard.new()
		s.delay = SHARD_STAGGER * k
		s.ceiling_y = arena.position.y
		room.add_child(s)
		s.global_position = Vector2(dais.position.x - 24.0 - SHARD_STEP * k, floor_y() - CrystalShard.SIZE.y * 0.5)


func _player_x() -> float:
	var p := player()
	return p.global_position.x if p != null else global_position.x


func _player_dx() -> float:
	return _player_x() - global_position.x


func _on_blocked(_dir: Vector2) -> void:
	var d := Dust.new()
	d.setup("guard")
	get_parent().add_child(d)
	d.global_position = center()
	Sfx.play("guard")


func die() -> void:
	if state == "dying":
		return
	set_state("dying")
	dead = true
	collision_layer = 0
	velocity = Vector2.ZERO
	Feel.hitstop(0.12)
	Feel.slowmo(0.3, 1.0)
	Feel.add_trauma(0.8)
	Sfx.play("roar", 0.0, 0.0)


func _process(delta: float) -> void:
	if state != "dying":
		return
	state_time += delta
	if int(state_time * 10.0) % 3 == 0:
		var d := Dust.new()
		d.setup("debris")
		get_parent().add_child(d)
		d.global_position = global_position + Vector2(randf_range(-14, 14), randf_range(-48, -6))
	if state_time >= DYING_TIME:
		state = "dead"
		defeated.emit()
		super.die()


func _draw() -> void:
	var t := Time.get_ticks_msec() * 0.001
	var telling := state.ends_with("_tell")
	var white := flashing() or (state == "dying" and int(state_time * 12.0) % 2 == 0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1))
	var crouch := 0
	var lean := 0
	match state:
		"leap_tell":
			crouch = 4
		"chop":
			lean = 3
		"sweep":
			crouch = 3
			lean = 4
		"fallen", "stagger":
			lean = -4
			crouch = 2
		"dying":
			crouch = mini(int(state_time * 8.0), 10)
		"possessed":
			crouch = 2 + (int(state_time * 20.0) % 2)
	var bob := roundi(sin(t * 2.0)) if state in ["walk", "ward", "idle"] else 0
	# The ward: a shell of crystal light around him on the throne.
	if warded():
		var k := 0.5 + 0.5 * sin(t * 4.0)
		_px(-20, -60, 40, 60, Color(CRYSTAL, 0.12 + 0.08 * k), 1.0)
		_px(-20, -60, 40, 2, Color(CRYSTAL_LIGHT, 0.4 + 0.3 * k), 1.0)
		_px(-20, -60, 2, 60, Color(CRYSTAL_LIGHT, 0.3 + 0.3 * k), 1.0)
		_px(18, -60, 2, 60, Color(CRYSTAL_LIGHT, 0.3 + 0.3 * k), 1.0)
	# Boots and a robe to the ankles, its hem rotted by the flood.
	_px(-10, -6, 8, 6, OUTLINE, 1.0)
	_px(2, -6, 8, 6, OUTLINE, 1.0)
	var by := -44 + crouch + bob
	var bx := -13 + lean
	_px(bx - 1, by - 1, 28, 40 - crouch - bob + 1, OUTLINE, 1.0)
	_px(bx, by, 26, 38 - crouch - bob, ROBE, 1.0)
	_px(bx, by, 26, 3, ROBE_LIGHT, 1.0)
	for i in 5:
		_px(bx + 2 + i * 5, by + 34 - crouch - bob, 3, 2, ROBE_DARK, 1.0)
	# The royal mantle across his shoulders, gold-edged.
	_px(bx - 2, by - 2, 30, 7, OUTLINE, 1.0)
	_px(bx - 1, by - 1, 28, 5, MANTLE, 1.0)
	_px(bx - 1, by + 3, 28, 1, GOLD, 1.0)
	# His crystal half: the back of him grown over with meteor crystal.
	for c: Array in [[-14, -6, 6, 12], [-16, 2, 5, 10], [-12, 10, 5, 8], [-17, -12, 4, 7]]:
		_px(bx + 13 + c[0] - 1, by + 8 + c[1] - 1, c[2] + 2, c[3] + 2, OUTLINE, 1.0)
		_px(bx + 13 + c[0], by + 8 + c[1], c[2], c[3], CRYSTAL, 1.0)
		_px(bx + 13 + c[0], by + 8 + c[1], 1, c[3], CRYSTAL_LIGHT, 1.0)
	# Head: a broad face, a beard to his belt, the crown with crystal grown up it.
	var hx := -7 + lean
	var hy := by - 13
	_px(hx - 1, hy - 1, 16, 15, OUTLINE, 1.0)
	_px(hx, hy, 14, 13, SKIN, 1.0)
	_px(hx + 8, hy + 4, 2, 2, EYE, 1.0)
	_px(hx + 3, hy + 4, 2, 2, CRYSTAL_LIGHT, 1.0)
	_px(hx - 1, hy + 7, 16, 20, OUTLINE, 1.0)
	_px(hx, hy + 7, 14, 19, BEARD, 1.0)
	for i in 3:
		_px(hx + 2 + i * 4, hy + 10, 1, 15, BEARD_DARK, 1.0)
	var glow := state == "summon_tell" or (warded() and telegraph_pulse())
	_px(hx - 2, hy - 6, 18, 7, OUTLINE, 1.0)
	_px(hx - 1, hy - 5, 16, 5, GOLD, 1.0)
	_px(hx - 1, hy - 1, 16, 1, GOLD_DARK, 1.0)
	for sx in [0, 5, 10]:
		_px(hx + sx - 1, hy - 10, 4, 5, OUTLINE, 1.0)
		_px(hx + sx, hy - 9, 2, 4, CRYSTAL_LIGHT if glow else CRYSTAL, 1.0)
	if state == "summon_tell":
		var k := 0.5 + 0.5 * absf(sin(state_time * 18.0))
		_px(hx - 6, hy - 16, 26, 12, Color(CRYSTAL, 0.3 * k), 1.0)
	if cracked():
		# The meteor through him: cracks of crystal light across robe and face.
		var k := 0.6 + 0.4 * absf(sin(t * (14.0 if state == "possessed" else 6.0)))
		for c: Array in [[2, 6, 1, 6], [3, 11, 4, 1], [6, 12, 1, 7], [-4, 16, 6, 1], [-4, 17, 1, 9], [10, 20, 1, 6], [8, 25, 4, 1]]:
			_px(bx + 8 + c[0], by + c[1], c[2], c[3], Color(CRYSTAL_LIGHT, k), 1.0)
		_px(hx + 2, hy + 2, 1, 4, Color(CRYSTAL_LIGHT, k), 1.0)
		_px(hx + 2, hy + 6, 4, 1, Color(CRYSTAL_LIGHT, k), 1.0)
		_px(hx + 8, hy + 4, 2, 2, CRYSTAL_LIGHT, 1.0)
		if state == "possessed":
			_px(-22, -70, 44, 70, Color(CRYSTAL, 0.18 * k), 1.0)
	# The great-axe, by state.
	var tip := Vector2i.ZERO
	match state:
		"chop_tell", "burst_tell":
			tip = _axe(4 + lean, by + 10, -6, -34, telling)
		"possessed":
			tip = _axe(10, by + 30, 22, 8, false)
		"chop":
			tip = _axe(8 + lean, by + 6, 30, 30, false)
		"sweep_tell":
			tip = _axe(-6 + lean, by + 24, -24, 6, telling)
		"sweep":
			tip = _axe(10 + lean, by + 30, 34, 0, false)
		"leap_tell", "leap":
			tip = _axe(6, by + 8, 4, -30, telling)
		"ward", "summon_tell":
			tip = _axe(12, by + 4, 2, 40 - crouch, false)
		"fallen", "stagger", "dying":
			tip = _axe(10, by + 30, 22, 8, false)
		_:
			tip = _axe(12, by + 12, 6, 30, false)
	if telling and state != "summon_tell":
		# The axe's edge catches the light: the tell.
		var k := 0.5 + 0.5 * absf(sin(state_time * 14.0))
		_px(tip.x - 1, tip.y - 6, 3, 13, Color(STEEL_LIGHT, 0.9 * k), 1.0)
		_px(tip.x - 6, tip.y - 1, 13, 3, Color(STEEL_LIGHT, 0.9 * k), 1.0)
	if white:
		_px(-16, -62, 32, 62, Color(1, 1, 1), 0.55)
	draw_set_transform(Vector2.ZERO)


## The axe from his hands at (x, y) along (dx, dy); returns the head's position.
func _axe(x: int, y: int, dx: int, dy: int, bright: bool) -> Vector2i:
	var steps := maxi(absi(dx), absi(dy))
	for i in steps + 1:
		_px(x + roundi(dx * float(i) / steps) - 1, y + roundi(dy * float(i) / steps) - 1, 4, 4, OUTLINE, 1.0)
	for i in steps + 1:
		_px(x + roundi(dx * float(i) / steps), y + roundi(dy * float(i) / steps), 2, 2, HAFT, 1.0)
	var hx := x + dx
	var hy := y + dy
	# A broad bearded blade, half of it crystal like its master.
	_px(hx - 7, hy - 7, 14, 14, OUTLINE, 1.0)
	_px(hx - 6, hy - 6, 12, 12, STEEL_LIGHT if bright else STEEL, 1.0)
	_px(hx - 6, hy - 6, 5, 12, CRYSTAL, 1.0)
	_px(hx - 1, hy - 6, 2, 12, OUTLINE, 1.0)
	return Vector2i(hx, hy)


## Draws a rect of the design (laid out in units of 1/SCALE half-pixels),
## snapped to the half-pixel grid so neighbouring rects still tile.
func _px(x: int, y: int, w: int, h: int, color: Color, alpha: float) -> void:
	var x0 := floorf(x * SCALE)
	var y0 := floorf(y * SCALE)
	var x1 := maxf(floorf((x + w) * SCALE), x0 + 1.0)
	var y1 := maxf(floorf((y + h) * SCALE), y0 + 1.0)
	draw_rect(Rect2(x0 * 0.5, y0 * 0.5, (x1 - x0) * 0.5, (y1 - y0) * 0.5), Color(color, color.a * alpha))
