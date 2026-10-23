class_name Ripasheiku
extends Enemy
## Ripasheiku, the Lantern Widow (design bible 8.3): a spider-wraith that
## carries the souls of the drowned as lanterns on her legs. In the Mist's fog
## she is all but invisible; she shows only where light reaches her, and her
## own lanterns are the light. Each lantern you break frees a soul that clings
## to her as pale fire, so she shows a little more.
##
## Phase 1 (floor): she stalks you in the dark and either sweeps her front legs
## (close) or rears and pounces at where you stand.
## Phase 2 (below 66%): she climbs to the vault and hangs there. She drops web
## lines: a thread flickers toward you (the tell), then a strand shoots along
## it; if it catches you it reels you toward her (dash to break free). Or she
## shivers and drops on you, and lies stunned where she lands, open to blows.
## Phase 3 (below 30%, or every lantern broken): she comes down for good, fully
## visible, fast and desperate: tells are a quarter shorter, never under
## Enemy.MIN_TELEGRAPH.
## Drawn from her Autosprite sheet at 2x (`ripasheiku`, design bible 13.2); the
## lanterns, souls and web stay code-drawn (`_px` and `_seg` take half-pixels).
## Without the sheet she falls back to a code-drawn body.

signal defeated

const DISPLAY_NAME := "Ripasheiku"
const SHEET := "ripasheiku"
const EPITHET := "The Lantern Widow"
const MAX_HP := 260
const PHASES := [0.66, 0.3]
const LANTERNS := 4
## Lantern spots on her legs, from her body's centre (world pixels, facing right,
## standing on the floor; mirrored on the ceiling).
const LANTERN_SPOTS := [Vector2(-30, 2), Vector2(-15, -14), Vector2(15, -14), Vector2(30, 2)]
const LANTERN_DAMAGE := 18
const FLINCH := 0.6
const STALK_SPEED := 62.0
const STALK_TIME := 0.9
const SWEEP_RANGE := 70.0
const SWEEP_TELL := 0.55
const SWEEP_TIME := 0.3
const SWEEP_DAMAGE := 20
const SWEEP_REACH := Vector2(62, 28)
const POUNCE_TELL := 0.65
const POUNCE_TIME := 0.6
const POUNCE_HEIGHT := 70.0
const RECOVER := 0.65
const CLIMB_TIME := 1.0
const HANG_SPEED := 70.0
const HANG_TIME := 1.1
const HANG_STRIKE_DX := 170.0
const WEB_TELL := 0.6
const WEB_SPEED := 420.0
const WEB_RANGE := 360.0
const REEL_TIME := 0.9
const REEL_PULL := 150.0
const DROP_TELL := 0.6
const DROP_SPEED := 560.0
const DROPPED_TIME := 1.3
## Blows while she lies stunned after a drop.
const DROPPED_BONUS := 1.5
const FAST := 0.75
const INTRO_TIME := 1.4
const DYING_TIME := 1.4
const BODY_H := 18.0
const MIN_SEEN := 0.08
## How much each broken lantern adds to how much of her always shows.
const SEEN_PER_LANTERN := 0.16
const TELL_SEEN := 0.8

const OUTLINE := Color("120f19")
const BODY := Color("39324a")
const BODY_LIGHT := Color("5d5472")
const BODY_DARK := Color("241f30")
const BONE := Color("ddd5c0")
const VEIL := Color("9a93b4")
const EYE := Color("f4e48c")
const LAMP := Color("f2c14e")
const LAMP_CORE := Color("fff2b0")
const SOUL := Color("bfe8e0")
const WEB := Color("d8e2e6")

## The chapel's interior in pixels.
var arena := Rect2(16, 64, 608, 256)
var phase := 1
var lanterns: Array[BossLantern] = []
## Hanging from the vault (phase 2) rather than standing on the floor.
var on_ceiling := false
var seen := 1.0
var web_target := Vector2.ZERO
var web_tip := Vector2.ZERO
var _from := Vector2.ZERO
var _to := Vector2.ZERO
var _last := ""
var _next_hang := "web"
var _rng := RandomNumberGenerator.new()


func _init() -> void:
	max_hp = MAX_HP
	contact_damage = 18
	gold_min = 70
	gold_max = 90
	xp = 160
	body_size = Vector2(40, 26)
	body_centered = true
	uses_gravity = false
	knockback = 0.0
	state = "dormant"
	_rng.seed = 1991


func _ready() -> void:
	super._ready()
	add_to_group("boss")
	collision_mask = 0
	for i in LANTERNS:
		var l := BossLantern.new()
		l.boss = self
		l.index = i
		lanterns.append(l)
		get_parent().add_child.call_deferred(l)
	_place_lanterns()


## Starts the fight (called by the arena once the player is inside).
func begin() -> void:
	face_player()
	set_state("intro")
	for l in lanterns:
		l.set_active(true)
	Sfx.play("wail", 0.0, 2.0)
	Feel.add_trauma(0.25)
	GameState.banner.emit(DISPLAY_NAME, EPITHET)


func health_fraction() -> float:
	return clampf(float(hp) / max_hp, 0.0, 1.0)


func tell(base: float) -> float:
	return maxf(Enemy.MIN_TELEGRAPH, base * (FAST if phase == 3 else 1.0))


func floor_y() -> float:
	return arena.end.y - BODY_H


func ceiling_y() -> float:
	return arena.position.y + BODY_H


func broken() -> int:
	var n := 0
	for l in lanterns:
		if l.dead:
			n += 1
	return n


func _modify_damage(damage: int, _dir: Vector2) -> int:
	if state in ["dormant", "intro", "dying", "climb"]:
		return 0
	if state == "dropped":
		return roundi(damage * DROPPED_BONUS)
	return damage


func take_hit(damage: int, dir: Vector2) -> void:
	super.take_hit(damage, dir)
	_hitstun = 0.0
	_check_phase()


## A blow on one of her lanterns breaks it, frees the soul, and makes her flinch.
func hit_segment(seg: BossSegment, _damage: int, _dir: Vector2) -> void:
	var l := seg as BossLantern
	if l == null or l.dead or state in ["dormant", "intro", "dying"]:
		return
	l.shatter()
	Sfx.play("lantern_break", 0.05, 0.0)
	Sfx.play("wail", 0.1, -6.0)
	Feel.hitstop(0.06)
	var d := Dust.new()
	d.setup("heal")
	get_parent().add_child(d)
	d.global_position = l.global_position
	hp = maxi(1, hp - LANTERN_DAMAGE)
	_flash = 0.15
	if state in ["stalk", "hang", "recover"]:
		set_state("flinch")
	_check_phase()


func _check_phase() -> void:
	if dead:
		return
	var f := health_fraction()
	if phase < 3 and (f <= PHASES[1] or broken() == LANTERNS):
		phase = 3
		Sfx.play("wail", 0.0, 4.0)
		Feel.add_trauma(0.3)
		if on_ceiling and state not in ["drop", "dropped"]:
			_start_drop()
	elif phase == 1 and f <= PHASES[0]:
		phase = 2
		Sfx.play("wail", 0.0, 0.0)
		if state not in ["pounce"]:
			_start_climb()


func _on_blocked(_dir: Vector2) -> void:
	pass


func stagger() -> void:
	pass


func _think(delta: float) -> void:
	velocity = Vector2.ZERO
	match state:
		"dormant":
			pass
		"intro":
			if state_time >= INTRO_TIME:
				set_state("stalk")
		"stalk":
			face_player()
			var dx := _player_dx()
			if absf(dx) > 20.0:
				velocity.x = signf(dx) * STALK_SPEED * (1.4 if phase == 3 else 1.0)
			if state_time >= STALK_TIME * (0.6 if phase == 3 else 1.0):
				_choose_floor(absf(dx))
		"sweep_tell":
			if state_time >= tell(SWEEP_TELL):
				set_state("sweep")
				Sfx.play("slash", 0.1, 0.0)
				hit_player_in_rect(sweep_rect(), SWEEP_DAMAGE)
		"sweep":
			if state_time >= SWEEP_TIME:
				set_state("recover")
		"pounce_tell":
			if state_time >= tell(POUNCE_TELL):
				_from = global_position
				var p := player()
				var tx := p.global_position.x if p != null else global_position.x
				_to = Vector2(clampf(tx, arena.position.x + 30.0, arena.end.x - 30.0), floor_y())
				set_state("pounce")
				Sfx.play("dash", 0.05, 0.0)
		"pounce":
			var k := clampf(state_time / POUNCE_TIME, 0.0, 1.0)
			global_position = _from.lerp(_to, k) + Vector2(0, -sin(k * PI) * POUNCE_HEIGHT)
			if k >= 1.0:
				set_state("recover")
				Sfx.play("land", 0.05, 2.0)
				Feel.add_trauma(0.25)
		"recover", "flinch":
			if state_time >= (FLINCH if state == "flinch" else RECOVER):
				if phase == 2 and on_ceiling:
					set_state("hang")
				elif phase == 2:
					_start_climb()
				else:
					set_state("stalk")
		"climb":
			var k := clampf(state_time / CLIMB_TIME, 0.0, 1.0)
			global_position.y = lerpf(_from.y, ceiling_y(), k)
			if k >= 1.0:
				on_ceiling = true
				set_state("hang")
		"hang":
			face_player()
			var dx := _player_dx()
			if absf(dx) > 12.0:
				velocity.x = signf(dx) * HANG_SPEED
			# She creeps over the player before she strikes (or gives up waiting).
			if state_time >= HANG_TIME and (absf(dx) < HANG_STRIKE_DX or state_time >= HANG_TIME * 3.0):
				if _next_hang == "web":
					_next_hang = "drop"
					var p := player()
					web_target = p.global_position + Vector2(0, -16) if p != null else global_position + Vector2(0, 200)
					set_state("web_tell")
				else:
					_next_hang = "web"
					set_state("drop_tell")
					Sfx.play("skitter", 0.1, 0.0)
		"web_tell":
			if state_time >= tell(WEB_TELL):
				web_tip = center()
				set_state("web")
				Sfx.play("web_shoot", 0.1, 0.0)
		"web":
			var to := web_target - center()
			web_tip = web_tip.move_toward(center() + to.normalized() * WEB_RANGE, WEB_SPEED * delta)
			var p := player()
			if p != null and not p.dead and p.body_rect().grow(4.0).has_point(web_tip):
				set_state("reel")
				Sfx.play("web_catch", 0.05, 0.0)
				Sfx.play("reel", 0.05, -2.0)
			elif web_tip.distance_to(center()) >= WEB_RANGE - 1.0 or not arena.grow(8.0).has_point(web_tip):
				set_state("hang")
		"reel":
			var p := player()
			if p == null or p.dead or p.is_dashing or state_time >= REEL_TIME:
				set_state("hang")
			else:
				web_tip = p.global_position + Vector2(0, -16)
				p.pull = (center() - web_tip).normalized() * REEL_PULL
		"drop_tell":
			if state_time >= tell(DROP_TELL):
				_start_drop()
		"drop":
			velocity.y = DROP_SPEED
			if global_position.y >= floor_y():
				global_position.y = floor_y()
				velocity = Vector2.ZERO
				on_ceiling = false
				set_state("dropped")
				Sfx.play("heavy", 0.05, 2.0)
				Feel.add_trauma(0.45)
				hit_player_in_rect(Rect2(global_position - Vector2(30, 14), Vector2(60, BODY_H + 14)), SWEEP_DAMAGE, false)
		"dropped":
			if state_time >= DROPPED_TIME:
				if phase == 3:
					set_state("stalk")
				else:
					_start_climb()
		_:
			set_state("stalk")
	global_position.x = clampf(global_position.x + velocity.x * delta, arena.position.x + 24.0, arena.end.x - 24.0)
	velocity.x = 0.0


func _choose_floor(dist: float) -> void:
	var pick := "sweep" if dist <= SWEEP_RANGE else "pounce"
	if pick == _last and pick == "sweep":
		pick = "pounce"
	_last = pick
	face_player()
	set_state(pick + "_tell")
	Sfx.play("wail", 0.1, -10.0)


func _start_climb() -> void:
	_from = global_position
	set_state("climb")
	Sfx.play("skitter", 0.1, -2.0)


func _start_drop() -> void:
	set_state("drop")
	Sfx.play("dash", 0.05, -2.0)


func sweep_rect() -> Rect2:
	var x0 := global_position.x + (4.0 if facing > 0 else -SWEEP_REACH.x - 4.0)
	return Rect2(x0, arena.end.y - SWEEP_REACH.y, SWEEP_REACH.x, SWEEP_REACH.y)


func _player_dx() -> float:
	var p := player()
	return p.global_position.x - global_position.x if p != null else 0.0


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_place_lanterns()


func _place_lanterns() -> void:
	var t := Time.get_ticks_msec() * 0.001
	for i in lanterns.size():
		var spot: Vector2 = LANTERN_SPOTS[i]
		var o := Vector2(spot.x * facing, spot.y * (-1.0 if on_ceiling else 1.0))
		o += Vector2(sin(t * 2.0 + i) * 1.5, 6.0 * (-1.0 if on_ceiling else 1.0))
		lanterns[i].global_position = global_position + o


func _process(delta: float) -> void:
	if state == "dying":
		state_time += delta
		if state_time >= DYING_TIME:
			state = "dead"
			for l in lanterns:
				if is_instance_valid(l):
					l.queue_free()
			defeated.emit()
			super.die()
		queue_redraw()
	var fog := Fog.current(get_tree())
	var clear := fog.clear_at(center()) if fog != null else 1.0
	var floor_seen := minf(1.0, MIN_SEEN + SEEN_PER_LANTERN * broken())
	seen = maxf(floor_seen, lerpf(MIN_SEEN, 1.0, clear))
	if phase == 3 or state in ["dormant", "intro", "dying"]:
		seen = 1.0
	elif state.ends_with("_tell"):
		seen = maxf(seen, TELL_SEEN)


func die() -> void:
	if state == "dying":
		return
	set_state("dying")
	dead = true
	collision_layer = 0
	for l in lanterns:
		l.set_active(false)
	Feel.hitstop(0.12)
	Feel.slowmo(0.3, 1.0)
	Feel.add_trauma(0.7)
	Sfx.play("wail", 0.0, 4.0)


# --- Drawing ---------------------------------------------------------------------

func _draw() -> void:
	var t := Time.get_ticks_msec() * 0.001
	var a := seen
	var flip := -1.0 if on_ceiling else 1.0
	var white := flashing() or (state.ends_with("_tell") and telegraph_pulse())
	if state == "dying":
		a = 1.0 - clampf(state_time / DYING_TIME, 0.0, 1.0) * 0.8
		white = int(state_time * 12.0) % 2 == 0
	var jitter := Vector2(randf_range(-1, 1), 0).round() if state in ["drop_tell", "dying"] else Vector2.ZERO
	draw_set_transform(jitter, 0.0, Vector2(facing, flip))
	if Sheet.exists(SHEET):
		if on_ceiling or state == "climb":
			_seg(Vector2(0, -BODY_H * 2), Vector2(0, -BODY_H * 2 - 400), WEB, a * 0.5, 1.0)
		# The sheet's origin is at her feet, BODY_H below her middle (above it, hanging).
		draw_set_transform(jitter + Vector2(0, BODY_H * flip), 0.0, Vector2(facing, flip))
		var anim := sheet_anim()
		var f := Sheet.frame_at(SHEET, anim, state_time)
		Sheet.draw(self, SHEET, anim, f, Color(1, 1, 1, a))
		if white:
			Sheet.draw(self, SHEET, anim, f, Color(1, 1, 1, 0.6 * maxf(a, 0.5)), true)
		draw_set_transform(jitter, 0.0, Vector2(facing, flip))
		_draw_souls(Vector2(-20, -10), t, a)
		draw_set_transform(Vector2.ZERO)
		_draw_lanterns(t)
		_draw_web()
		return
	var rear := state == "pounce_tell" or state == "sweep_tell"
	var walk := t * (9.0 if absf(_player_dx()) > 20.0 and state in ["stalk", "hang"] else 2.0)
	# Web lines while she hangs: up to the vault.
	if on_ceiling or state == "climb":
		_seg(Vector2(0, -BODY_H * 2), Vector2(0, -BODY_H * 2 - 400), WEB, a * 0.5, 1.0)
	# Eight legs, four a side: a knee high above the body, the foot on the ground.
	for side in [-1, 1]:
		for k in 4:
			var reach := 14.0 + k * 9.0
			var swing := sin(walk + k * 1.6 + (0.0 if side > 0 else PI)) * 3.0
			var root := Vector2(side * (4.0 + k * 3.0), -2.0)
			var knee := Vector2(side * (reach * 0.7), -BODY_H - 4.0 - k * 2.0 + swing * 0.5)
			var foot := Vector2(side * (reach + swing), BODY_H)
			if rear and side == 1 and k < 2:
				# The front legs raised: the tell.
				knee = Vector2(reach * 0.6, -BODY_H - 14.0)
				foot = Vector2(reach + 10.0, -BODY_H - 4.0 + k * 6.0)
			if state == "sweep" and side == 1 and k < 2:
				foot = Vector2(reach + 22.0, BODY_H - 2.0)
			_line(root, knee, OUTLINE, a, 3.0)
			_line(knee, foot, OUTLINE, a, 2.5)
			_line(root, knee, BODY_LIGHT if k % 2 else BODY, a, 1.5)
			_line(knee, foot, BONE.darkened(0.35), a, 1.0)
			_line(knee + Vector2(0, -1), knee + Vector2(0, 1), BONE, a, 1.5)
	# The abdomen: a great shrouded sac behind her, ringed with bone.
	var ab := Vector2(-12, -6)
	draw_circle(ab, 13.0, Color(OUTLINE, a))
	draw_circle(ab, 12.0, Color(BODY, a))
	draw_circle(ab + Vector2(-2, -3), 8.0, Color(BODY_LIGHT, a))
	for r in [9.0, 5.0]:
		draw_arc(ab, r, PI * 1.1, PI * 1.9, 10, Color(BONE, a * 0.8), 1.0)
	_draw_souls(ab, t, a)
	# The head: a veiled widow's face, bone-pale, lantern eyes.
	var hd := Vector2(8, -6)
	draw_circle(hd, 9.0, Color(OUTLINE, a))
	draw_circle(hd, 8.0, Color(BODY_DARK, a))
	_px(10, -26, 14, 12, BONE, a)
	_px(12, -24, 10, 3, BONE.lightened(0.2), a)
	_px(10, -27, 18, 3, Color(VEIL, 0.8), a)
	_px(4, -30, 20, 4, Color(VEIL, 0.7), a)
	var eye := Color(1, 1, 0.85) if rear or state in ["web_tell", "drop_tell"] else EYE
	var eye_a := maxf(a, 0.6)
	_px(13, -22, 3, 2, eye, eye_a)
	_px(19, -22, 3, 2, eye, eye_a)
	_px(16, -17, 3, 1, OUTLINE, a)
	if white:
		draw_circle(ab, 12.0, Color(1, 1, 1, 0.5 * maxf(a, 0.5)))
		draw_circle(hd, 8.0, Color(1, 1, 1, 0.5 * maxf(a, 0.5)))
	draw_set_transform(Vector2.ZERO)
	_draw_lanterns(t)
	_draw_web()


## The sheet animation for her state. The stills cover her key poses; the rest
## borrow the nearest one (rearing for the web, the leap for the drop).
func sheet_anim() -> String:
	match state:
		"stalk", "hang":
			return "walk" if absf(velocity.x) > 1.0 else "idle"
		"climb":
			return "walk"
		"intro", "web_tell", "reel":
			return "sweep_tell"
		"web":
			return "sweep"
		"drop":
			return "pounce"
		"flinch":
			return "pounce_tell"
		"dying":
			return "dropped"
		"sweep_tell", "sweep", "pounce_tell", "pounce", "dropped":
			return state
	return "idle"


## Freed souls cling to her abdomen as pale fire, one for each lantern broken.
func _draw_souls(ab: Vector2, t: float, a: float) -> void:
	for i in broken():
		var sp := ab + Vector2(-6 + i * 5, -12 + sin(t * 5.0 + i) * 1.5)
		draw_circle(sp, 2.5, Color(SOUL, a * 0.8))
		draw_circle(sp + Vector2(0, -2), 1.2, Color(1, 1, 1, a))


func _draw_lanterns(t: float) -> void:
	for l in lanterns:
		if not is_instance_valid(l):
			continue
		var at := l.global_position - global_position
		var cord := at + Vector2(0, -8.0 * (-1.0 if on_ceiling else 1.0))
		if l.dead:
			# A shattered cage, dark, swinging on its cord.
			_seg(cord * 2.0, at * 2.0 + Vector2(0, -6), BONE.darkened(0.4), 1.0, 1.0)
			_px(roundi(at.x * 2.0) - 4, roundi(at.y * 2.0) - 6, 8, 8, Color(OUTLINE, 0.9), 1.0)
			_px(roundi(at.x * 2.0) - 3, roundi(at.y * 2.0) - 5, 2, 6, BODY_LIGHT, 1.0)
			continue
		var flick := 0.85 + 0.15 * sin(t * 13.0 + l.index * 2.0)
		draw_circle(at, 10.0, Color(LAMP, 0.12 * flick))
		_seg(cord * 2.0, at * 2.0 + Vector2(0, -8), BONE.darkened(0.3), 1.0, 1.0)
		var x := roundi(at.x * 2.0)
		var y := roundi(at.y * 2.0)
		_px(x - 5, y - 9, 10, 15, OUTLINE, 1.0)
		_px(x - 4, y - 8, 8, 13, LAMP, flick)
		_px(x - 2, y - 6, 4, 8, LAMP_CORE, flick)
		_px(x - 5, y - 10, 10, 2, BONE.darkened(0.3), 1.0)
		if l.flash > 0.0:
			_px(x - 4, y - 8, 8, 13, Color(1, 1, 1), 0.8)


func _draw_web() -> void:
	if state == "web_tell":
		# A faint thread flickers toward where she'll shoot.
		if int(state_time * 14.0) % 2 == 0:
			var to := (web_target - center()).normalized() * WEB_RANGE
			_seg(Vector2.ZERO, to * 2.0, WEB, 0.35, 1.0)
	elif state == "web" or state == "reel":
		_seg(Vector2.ZERO, (web_tip - global_position) * 2.0, WEB, 0.95, 2.0)
		draw_circle(web_tip - global_position, 2.0, Color(WEB, 0.9))
	if state == "drop_tell":
		# Her shadow on the floor below marks where she'll land.
		var y := arena.end.y - global_position.y - 1.0
		var w := 26.0 + 8.0 * sin(state_time * 20.0)
		draw_rect(Rect2(-w, y - 2.0, w * 2.0, 3.0), Color(OUTLINE, 0.55))


## A line between two points in world pixels.
func _line(a: Vector2, b: Vector2, color: Color, alpha: float, width: float) -> void:
	draw_line(a, b, Color(color, color.a * alpha), width)


## A line between two points in half-pixels.
func _seg(a: Vector2, b: Vector2, color: Color, alpha: float, width: float) -> void:
	draw_line(a * 0.5, b * 0.5, Color(color, color.a * alpha), width)


func _px(x: int, y: int, w: int, h: int, color: Color, alpha: float) -> void:
	draw_rect(Rect2(x * 0.5, y * 0.5, w * 0.5, h * 0.5), Color(color, color.a * alpha))
