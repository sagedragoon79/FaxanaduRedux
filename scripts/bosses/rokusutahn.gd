class_name Rokusutahn
extends Node2D
## Rokusutahn, the Root-Gnawer (design bible 8.1): a colossal bark-plated grub.
##
## The body is a chain of BossSegment hitboxes on a "rail", a straight line
## with a start point and a direction: the head sits `_head_s` pixels along it
## and segment i sits SPACING * i behind the head. Each attack picks a rail and
## moves the head along it, so the body follows the same path in and out of
## the walls. Segments inside a wall or the ceiling are switched off.
##
## Phase 1: bursts from a wall and lunges along the floor (climb the walls to
## dodge); every second lunge it bites into the far wall and is stuck, with its
## tail (the weak point) near the wall it came from.
## Phase 2 (below 60%): burrows into the ceiling, rains sap clumps that harden
## into platforms, dangles its tail, and plunges at the player.
## Phase 3 (below 30%): tears the floor away and lunges along the wall ledges.
##
## The arena is the Root Chamber's layout (levels/trunk/root_chamber.room).

signal defeated
signal phase_changed(phase: int)

const DISPLAY_NAME := "Rokusutahn"
const EPITHET := "the Root-Gnawer"
const MAX_HP := 600
## Health fractions where phases 2 and 3 begin (shown on the health bar).
const PHASES := [0.6, 0.3]
const SEGMENTS := 26
const SPACING := 22.0
const TAIL_SEGMENTS := 3
const HEAD_RADIUS := 22.0
const BODY_RADIUS := 17.0
const TAIL_RADIUS := 16.0
## Bark plates: hits on the head and body do a quarter of their damage.
const BODY_DAMAGE_MULT := 0.25
const CONTACT_DAMAGE := 20
const LUNGE_SPEED := 360.0
const WITHDRAW_SPEED := 300.0
const PLUNGE_SPEED := 560.0
const RISE_SPEED := 360.0
const DANGLE_SPEED := 480.0
## Wind-ups (all at least Enemy.MIN_TELEGRAPH).
const LUNGE_TELL := 0.9
const PLUNGE_TELL := 0.8
const DANGLE_TELL := 0.8
const STUCK_TIME := 2.6
const STUCK_TIME_P3 := 3.2
const DANGLE_TIME := 4.0
const PLUNGE_HOLD := 0.6
const ROAR_TIME := 1.6
const REST := 0.6
const RAIN_CLUMPS := 5
const RAIN_GAP := 0.45
const XP := 200
const GOLD := 120

## Arena interior in pixels; the walls and ceiling are outside it.
const ARENA := Rect2(16, 32, 608, 288)
const FLOOR_Y := 320.0
const FLOOR_LANE := 300.0
const LOW_LANE := 204.0
const HIGH_LANE := 124.0
const DANGLE_TIP := 160.0
## Floor columns (tiles) torn away in phase 3, and the floor rows removed.
const TEAR_COLUMNS := Vector2i(7, 32)
const TEAR_ROWS := Vector2i(20, 21)

const BARK := Color("6e4a2c")
const BARK_LIGHT := Color("9a6a3e")
const BARK_DARK := Color("432a19")
const FLESH := Color("c9a27a")
const AMBER := Color("ffb84a")
const AMBER_HOT := Color("ffe9a8")
const OUTLINE := Color("1d1a2b")
const MAW := Color("2a1418")
const EYE := Color("ff5a3a")

var room: Room
var hp := MAX_HP
var phase := 1
var state := "idle"
var state_time := 0.0
var dead := false
var segments: Array[BossSegment] = []

var _rail_from := Vector2.ZERO
var _rail_dir := Vector2.LEFT
var _head_s := 0.0
var _head_stop := 0.0
var _moves := 0
var _lane_index := 0
var _stuck_lunge := false
var _target_x := 0.0
var _rain_left := 0
var _rain_timer := 0.0
var _shatter_index := 0
var _shatter_timer := 0.0
var _hit_frame := -1
var _hit_dealt := 0
var _t := 0.0
var _fx: Node2D
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	add_to_group("boss")
	z_index = -1
	_rng.seed = 1987
	for i in SEGMENTS:
		var s := BossSegment.new()
		s.boss = self
		s.index = i
		s.is_head = i == 0
		s.is_tail = i >= SEGMENTS - TAIL_SEGMENTS
		s.radius = HEAD_RADIUS if s.is_head else (TAIL_RADIUS if s.is_tail else BODY_RADIUS)
		s.contact_damage = CONTACT_DAMAGE
		add_child(s)
		segments.append(s)
	# Telegraphs draw above the tiles so wall and ceiling warnings show.
	_fx = Node2D.new()
	_fx.z_as_relative = false
	_fx.z_index = 3
	_fx.draw.connect(_draw_fx)
	add_child(_fx)
	_hide_body()


## Starts the fight (called by the arena once the player is inside).
func begin() -> void:
	Sfx.play("roar", 0.0)
	Feel.add_trauma(0.6)
	Feel.rumble(0.6, 0.8, 1.0)
	_set_state("intro")


func health_fraction() -> float:
	return clampf(float(hp) / MAX_HP, 0.0, 1.0)


func _set_state(s: String) -> void:
	state = s
	state_time = 0.0


func _player() -> Player:
	return get_tree().get_first_node_in_group("player") as Player


func _player_x() -> float:
	var p := _player()
	return p.global_position.x if p != null else ARENA.get_center().x


# --- Moving along the rail ---------------------------------------------------------

func _rail_point(s: float) -> Vector2:
	return _rail_from + _rail_dir * s


func _set_rail(from: Vector2, dir: Vector2, head_s: float) -> void:
	_rail_from = from
	_rail_dir = dir
	_head_s = head_s


func head_position() -> Vector2:
	return segments[0].position


func tail_position() -> Vector2:
	return segments[SEGMENTS - 1].position


func _place_segments() -> void:
	var perp := Vector2(-_rail_dir.y, _rail_dir.x)
	for s in segments:
		var along := _head_s - s.index * SPACING
		var wiggle := sin(along * 0.045 - _t * 9.0) * (2.0 if state != "stuck" else 4.0)
		var pos := _rail_point(along) + perp * wiggle
		if state in ["dangle", "dangle_down", "dangle_up"]:
			# The hanging tail sways like a pendulum from the ceiling.
			var depth := maxf(pos.y - ARENA.position.y, 0.0)
			pos.x += sin(_t * 2.2) * depth * 0.12
		s.position = pos
		var inside := ARENA.grow(-s.radius * 0.4).has_point(pos)
		s.set_active(inside and not dead)
		s.visible = not s.dead
		s.flash = maxf(s.flash - get_physics_process_delta_time(), 0.0)


func _hide_body() -> void:
	_set_rail(Vector2(-400, -400), Vector2.LEFT, 0.0)
	_place_segments()


## True once every segment is back inside a wall or the ceiling.
func _all_hidden() -> bool:
	for s in segments:
		if ARENA.grow(s.radius).has_point(s.position):
			return false
	return true


# --- The fight -------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	_t += delta
	state_time += delta
	match state:
		"intro":
			if state_time >= ROAR_TIME:
				_next_move()
		"rest":
			if state_time >= (REST * 0.6 if phase == 3 else REST):
				_next_move()
		"lunge_tell":
			_head_s = lerpf(0.0, 26.0, minf(state_time / LUNGE_TELL, 1.0))
			if int(state_time * 8.0) != int((state_time - delta) * 8.0):
				_wall_debris(_rail_point(_head_s + 24.0))
				Feel.add_trauma(0.08)
			if state_time >= LUNGE_TELL:
				Sfx.play("roar", 0.1, -4.0)
				Feel.add_trauma(0.35)
				_set_state("lunge")
		"lunge":
			_head_s += LUNGE_SPEED * delta
			if _stuck_lunge and _head_s >= _head_stop:
				_head_s = _head_stop
				Feel.add_trauma(0.55)
				Feel.rumble(0.8, 0.5, 0.25)
				Sfx.play("crumble", 0.05)
				_wall_debris(head_position())
				_set_state("stuck")
			elif state_time > 0.5 and _all_hidden():
				_set_state("rest")
		"stuck":
			if int(state_time * 4.0) != int((state_time - delta) * 4.0):
				_wall_debris(head_position())
			if state_time >= (STUCK_TIME_P3 if phase == 3 else STUCK_TIME):
				Sfx.play("roar", 0.1, -6.0)
				_set_state("withdraw")
		"withdraw":
			_head_s += WITHDRAW_SPEED * delta
			if _all_hidden():
				_set_state("rest")
		"roar":
			Feel.add_trauma(delta * 0.8)
			if int(state_time * 6.0) != int((state_time - delta) * 6.0):
				_ceiling_dust(_rng.randf_range(ARENA.position.x, ARENA.end.x))
			if state_time >= ROAR_TIME:
				if phase == 3:
					_tear_floor()
				_next_move()
		"rain":
			_rain_timer -= delta
			if _rain_left > 0 and _rain_timer <= 0.0:
				_drop_clump()
			if _rain_left == 0 and state_time > RAIN_CLUMPS * RAIN_GAP + 1.4:
				_set_state("rest")
		"dangle_tell":
			if int(state_time * 10.0) != int((state_time - delta) * 10.0):
				_ceiling_dust(_target_x)
			if state_time >= DANGLE_TELL:
				Sfx.play("rumble", 0.1)
				_set_state("dangle_down")
		"dangle_down":
			_head_s = maxf(_head_s - DANGLE_SPEED * delta, _head_stop)
			if _head_s <= _head_stop:
				_set_state("dangle")
		"dangle":
			if state_time >= DANGLE_TIME:
				_set_state("dangle_up")
		"dangle_up":
			_head_s += DANGLE_SPEED * 0.8 * delta
			if _all_hidden():
				_set_state("rest")
		"plunge_tell":
			if int(state_time * 10.0) != int((state_time - delta) * 10.0):
				_ceiling_dust(_target_x)
			if state_time >= PLUNGE_TELL:
				Sfx.play("roar", 0.1, -6.0)
				_set_state("plunge")
		"plunge":
			_head_s = minf(_head_s + PLUNGE_SPEED * delta, _head_stop)
			if _head_s >= _head_stop:
				Feel.add_trauma(0.6)
				Feel.rumble(0.9, 0.6, 0.2)
				Sfx.play("crumble", 0.05)
				var d := Dust.new()
				d.setup("debris")
				get_parent().add_child(d)
				d.position = Vector2(_target_x, FLOOR_Y)
				_set_state("plunge_hold")
		"plunge_hold":
			if state_time >= PLUNGE_HOLD:
				_set_state("plunge_up")
		"plunge_up":
			_head_s -= RISE_SPEED * delta
			if _all_hidden():
				_set_state("rest")
		"dying":
			_shatter_timer -= delta
			if _shatter_timer <= 0.0 and _shatter_index < SEGMENTS:
				_shatter(segments[SEGMENTS - 1 - _shatter_index])
				_shatter_index += 1
				_shatter_timer = 0.07
			if _shatter_index >= SEGMENTS and state_time > 0.4:
				_finish()
	if state != "dead":
		_place_segments()
	queue_redraw()
	_fx.queue_redraw()


func _next_move() -> void:
	var due := 1
	for i in PHASES.size():
		if health_fraction() <= PHASES[i]:
			due = i + 2
	if due > phase:
		phase = due
		_moves = 0
		phase_changed.emit(phase)
		Sfx.play("roar", 0.0, 2.0)
		Feel.rumble(0.7, 0.9, 1.2)
		_set_state("roar")
		return
	_moves += 1
	match phase:
		1:
			_start_lunge(FLOOR_LANE, _moves % 2 == 0)
		2:
			match _moves % 4:
				1:
					_start_rain()
				2:
					_start_dangle()
				_:
					_start_plunge()
		_:
			var lanes := [LOW_LANE, HIGH_LANE, FLOOR_LANE]
			_start_lunge(lanes[_lane_index % lanes.size()], true)
			_lane_index += 1


## Bursts from the wall on the far side from the player and lunges along `lane`.
func _start_lunge(lane: float, stuck: bool) -> void:
	var from_right := _player_x() < ARENA.get_center().x
	var start_x := ARENA.end.x + 40.0 if from_right else ARENA.position.x - 40.0
	_set_rail(Vector2(start_x, lane), Vector2.LEFT if from_right else Vector2.RIGHT, 0.0)
	# A stuck lunge stops with the head bitten into the far wall.
	var far_x := ARENA.position.x - 8.0 if from_right else ARENA.end.x + 8.0
	_head_stop = absf(far_x - start_x)
	_stuck_lunge = stuck
	_set_state("lunge_tell")


func _start_rain() -> void:
	_rain_left = RAIN_CLUMPS
	_rain_timer = 0.3
	Sfx.play("rumble", 0.05)
	Feel.add_trauma(0.3)
	_set_state("rain")


func _drop_clump() -> void:
	_rain_left -= 1
	_rain_timer = RAIN_GAP
	# One clump falls where the player stands; the rest spread across the room.
	var x := _player_x() if _rain_left == RAIN_CLUMPS - 2 else _rng.randf_range(ARENA.position.x + 30.0, ARENA.end.x - 30.0)
	var clump := SapClump.new()
	clump.room = room
	clump.floor_y = FLOOR_Y
	clump.position = Vector2(clampf(x, ARENA.position.x + 24.0, ARENA.end.x - 24.0), ARENA.position.y + 2.0)
	get_parent().add_child(clump)


## The tail drops out of the ceiling above the player and hangs there.
func _start_dangle() -> void:
	_target_x = clampf(_player_x(), ARENA.position.x + 70.0, ARENA.end.x - 70.0)
	# The rail runs up from the tail's lowest point; the head is far up in the ceiling.
	var tail_len := (SEGMENTS - 1) * SPACING
	_head_stop = tail_len
	var hidden := tail_len + (DANGLE_TIP - ARENA.position.y) + TAIL_RADIUS * 2.0
	_set_rail(Vector2(_target_x, DANGLE_TIP), Vector2.UP, hidden)
	_set_state("dangle_tell")


func _start_plunge() -> void:
	_target_x = clampf(_player_x(), ARENA.position.x + 30.0, ARENA.end.x - 30.0)
	var top := ARENA.position.y - HEAD_RADIUS * 1.5
	_set_rail(Vector2(_target_x, top), Vector2.DOWN, 0.0)
	_head_stop = FLOOR_Y - HEAD_RADIUS - top
	_set_state("plunge_tell")


func _tear_floor() -> void:
	if room != null:
		room.tear_floor(TEAR_COLUMNS.x, TEAR_COLUMNS.y, TEAR_ROWS.x, TEAR_ROWS.y)
	Sfx.play("crumble", 0.0, 4.0)
	Feel.add_trauma(0.9)
	Feel.rumble(1.0, 1.0, 0.6)
	for x in range(TEAR_COLUMNS.x, TEAR_COLUMNS.y + 1, 3):
		var d := Dust.new()
		d.setup("debris")
		get_parent().add_child(d)
		d.position = Vector2(x * Room.TILE + 8, FLOOR_Y)
	# Falling into the pit returns the player to the nearer side of the floor.
	var p := _player()
	if p != null:
		var left := Vector2((TEAR_COLUMNS.x - 3) * Room.TILE, FLOOR_Y)
		var right := Vector2((TEAR_COLUMNS.y + 4) * Room.TILE, FLOOR_Y)
		p.safe_position = left if p.global_position.x < ARENA.get_center().x else right


# --- Taking damage -----------------------------------------------------------------

## Called by a segment the player hit. The tail takes full damage, the plated
## head and body a quarter. One swing that touches several segments counts once,
## at the best rate among them.
func hit_segment(seg: BossSegment, damage: int, _dir: Vector2) -> void:
	if dead or state == "intro":
		return
	var mult := 1.0 if seg.is_tail else BODY_DAMAGE_MULT
	var dealt := maxi(1, roundi(damage * mult))
	var frame := Engine.get_physics_frames()
	if frame == _hit_frame:
		if dealt <= _hit_dealt:
			return
		hp -= dealt - _hit_dealt
	else:
		hp -= dealt
	_hit_frame = frame
	_hit_dealt = dealt
	seg.flash = 0.08
	var d := Dust.new()
	d.setup("hit" if seg.is_tail else "guard")
	get_parent().add_child(d)
	d.global_position = seg.global_position
	if not seg.is_tail:
		Sfx.play("guard", 0.1, -6.0)
	if hp <= 0:
		hp = 0
		_die()


func _die() -> void:
	dead = true
	for s in segments:
		s.set_active(false)
		s.contact_damage = 0
	Feel.hitstop(0.12)
	Feel.slowmo(0.3, 1.4)
	Feel.add_trauma(1.0)
	Feel.rumble(1.0, 1.0, 0.8)
	GameState.flash.emit(1.0)
	Sfx.play("roar", 0.0, 4.0)
	_shatter_index = 0
	_shatter_timer = 0.25
	_set_state("dying")


func _shatter(s: BossSegment) -> void:
	s.dead = true
	s.visible = false
	if ARENA.grow(s.radius).has_point(s.position):
		var d := Dust.new()
		d.setup("bark")
		get_parent().add_child(d)
		d.global_position = s.global_position
		Sfx.play("crumble", 0.15, -6.0)


func _finish() -> void:
	_set_state("dead")
	var at := head_position().clamp(ARENA.position + Vector2(40, 40), ARENA.end - Vector2(40, 20))
	Coin.spray(get_parent(), at, GOLD)
	GameState.add_xp(XP)
	defeated.emit()


# --- Effects -----------------------------------------------------------------------

func _wall_debris(at: Vector2) -> void:
	var d := Dust.new()
	d.setup("debris")
	get_parent().add_child(d)
	d.position = at.clamp(ARENA.position, ARENA.end)


func _ceiling_dust(x: float) -> void:
	var d := Dust.new()
	d.setup("debris")
	get_parent().add_child(d)
	d.position = Vector2(x + _rng.randf_range(-8, 8), ARENA.position.y + 2)


# --- Drawing -----------------------------------------------------------------------

func _draw() -> void:
	var stuck_glow := state == "stuck" or state == "dangle"
	for i in range(SEGMENTS - 1, -1, -1):
		var s := segments[i]
		if s.dead:
			continue
		var p := s.position
		var white := s.flash > 0.0
		var r := s.radius
		draw_circle(p, r + 1.5, OUTLINE)
		if s.is_head:
			_draw_head(p, white)
			continue
		var base := FLESH if s.is_tail else BARK
		if s.is_tail:
			var pulse := 0.5 + 0.5 * sin(_t * (10.0 if stuck_glow else 4.0))
			base = AMBER.lerp(AMBER_HOT, pulse * (0.8 if stuck_glow else 0.3))
		draw_circle(p, r, Color.WHITE if white else base)
		if not white:
			if s.is_tail:
				draw_circle(p + Vector2(-r * 0.3, -r * 0.35), r * 0.35, Color(AMBER_HOT, 0.8))
			else:
				# Bark plate: a lighter crown and dark seams.
				draw_circle(p + Vector2(0, -r * 0.25), r * 0.7, BARK_LIGHT)
				draw_circle(p + Vector2(0, -r * 0.1), r * 0.55, BARK)
				var a := _rail_dir.angle() + PI * 0.5
				var seam := Vector2.from_angle(a) * r * 0.9
				draw_line(p - seam, p + seam, BARK_DARK, 2.0)
				draw_rect(Rect2(p + Vector2(-2, r * 0.45), Vector2(4, 3)), FLESH)


func _draw_head(p: Vector2, white: bool) -> void:
	var r := HEAD_RADIUS
	draw_circle(p, r, Color.WHITE if white else BARK_DARK)
	if white:
		return
	# A wheel of mandibles around the maw, turning while it chews.
	var spin := _t * (14.0 if state in ["stuck", "lunge", "plunge"] else 3.0)
	for k in 6:
		var a := spin + k * TAU / 6.0
		var dir := Vector2.from_angle(a)
		var side := Vector2(-dir.y, dir.x)
		var tip := p + dir * (r + 7.0)
		draw_colored_polygon(PackedVector2Array([p + dir * (r - 6.0) + side * 5.0, tip, p + dir * (r - 6.0) - side * 5.0]), BARK_LIGHT)
	draw_circle(p, r * 0.62, MAW)
	draw_circle(p, r * 0.3, Color("120a0c"))
	for k in 3:
		var a := -spin * 0.5 + k * TAU / 3.0
		draw_circle(p + Vector2.from_angle(a) * r * 0.45, 2.5, EYE)


## Telegraphs, drawn above the tiles: a glowing crack in the wall it will burst
## from, a dust column where it will plunge or dangle.
func _draw_fx() -> void:
	match state:
		"lunge_tell":
			var k := clampf(state_time / LUNGE_TELL, 0.0, 1.0)
			var wall_x := ARENA.position.x if _rail_dir.x > 0.0 else ARENA.end.x
			var y := _rail_from.y
			var c := Color(AMBER, 0.35 + 0.5 * k * (0.5 + 0.5 * sin(_t * 30.0)))
			var out := -_rail_dir.x
			for i in 5:
				var ang := (i - 2) * 0.5
				var len := (10.0 + 16.0 * k) * (1.0 - absf(i - 2) * 0.15)
				var end := Vector2(wall_x + out * 2.0, y) + Vector2(out * cos(ang), sin(ang)) * len
				_fx.draw_line(Vector2(wall_x + out * 2.0, y), end, c, 2.0)
			_fx.draw_circle(Vector2(wall_x + out * 4.0, y), 4.0 + 10.0 * k, Color(AMBER, 0.15 + 0.2 * k))
		"plunge_tell", "dangle_tell":
			var tell := PLUNGE_TELL if state == "plunge_tell" else DANGLE_TELL
			var k := clampf(state_time / tell, 0.0, 1.0)
			var w := 10.0 + 22.0 * k
			_fx.draw_rect(Rect2(_target_x - w * 0.5, ARENA.position.y, w, 6.0 + 10.0 * k), Color(AMBER, 0.25 + 0.4 * k))
			if state == "plunge_tell":
				_fx.draw_rect(Rect2(_target_x - w * 0.5, FLOOR_Y - 3, w, 3), Color(0, 0, 0, 0.2 + 0.4 * k))
				_fx.draw_rect(Rect2(_target_x - 1, ARENA.position.y, 2, FLOOR_Y - ARENA.position.y), Color(AMBER, 0.1 + 0.15 * k))
		"roar":
			if phase == 3:
				# Cracks spreading across the floor that is about to fall away.
				var k := clampf(state_time / ROAR_TIME, 0.0, 1.0)
				var x0 := TEAR_COLUMNS.x * Room.TILE
				var x1 := (TEAR_COLUMNS.y + 1) * Room.TILE
				var n := int(k * 14.0)
				for i in n:
					var x := lerpf(x0, x1, (i + 0.5) / 14.0)
					_fx.draw_line(Vector2(x - 6, FLOOR_Y + 1), Vector2(x + 2, FLOOR_Y + 6), Color(AMBER, 0.8), 1.0)
					_fx.draw_line(Vector2(x + 2, FLOOR_Y + 6), Vector2(x - 1, FLOOR_Y + 12), Color(AMBER, 0.6), 1.0)
