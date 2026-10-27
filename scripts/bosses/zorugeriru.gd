class_name Zorugeriru
extends Enemy
## Zorugeriru, the Mist Hydra (design bible 8.4): a three-headed serpent of fog
## and bone coiled around the Spring of Mist. Only the head that is solid at the
## moment can be hurt; the others are fog the blade passes through.
##
## Phase 1: the heads take turns being solid. The solid one sinks low and bites
## (it rears back first, then lies where it struck, open to blows); a mist head
## breathes a bank of fog that rolls along the floor (jump it, or get up on the
## tank walls).
## Phase 2 (below 60%): all three turn to mist and keep breathing. A fourth head
## hides in the coil, and shows only once all three tanks are full: Deluge each
## one and its raft floats up, the high ground to reach it from.
## Phase 3 (below 30%): the coil bursts and the spring floods the arena to the
## tanks' rims (HydraFlood). The three heads take turns again, faster (tells a
## quarter shorter, never under Enemy.MIN_TELEGRAPH), breathing on the water.
## The body is never hit; only HydraHead hitboxes are. Code-drawn at 2x (`_px`
## takes half-pixels).

signal defeated

const DISPLAY_NAME := "Zorugeriru"
const EPITHET := "The Mist Hydra"
const MAX_HP := 300
const PHASES := [0.6, 0.3]
## The three lanes' x, from the coil's centre (over the three tanks).
const LANES := [-256.0, 0.0, 256.0]
## How far a solid head drifts from its lane after the player.
const LANE := 110.0
## Heights in world y: a mist head hangs high, a solid head low.
const MIST_Y := 96.0
const SOLID_Y := 176.0
## The fourth head, hidden in the coil and out.
const HIDDEN_AT := Vector2(0, 22)
const EMERGED_Y := 196.0
## How low the fourth head reaches: rafts and walls, not the floor.
const FOURTH_REACH_Y := 236.0
const SOLID_TIME := 3.4
const IDLE_BEFORE_BITE := 0.7
const BITE_RANGE := 190.0
const BITE_TELL := 0.6
const BITE_TIME := 0.2
const BITE_DAMAGE := 16
const BITE_SIZE := 36.0
const DOWN_TIME := 1.1
const STAGGER_EXTRA := 0.8
const RISE_TIME := 0.5
const BREATH_EVERY := 2.6
const BREATH_TELL := 0.7
const BREATH_TIME := 0.5
const EMERGE_TIME := 1.0
const FAST := 0.75
const INTRO_TIME := 1.6
const DYING_TIME := 1.6

const OUTLINE := Color("141a1c")
const SCALE := Color("4f6b62")
const SCALE_LIGHT := Color("7d9c8c")
const SCALE_DARK := Color("2d3f3a")
const BONE := Color("ddd5c0")
const EYE := Color("f4e48c")
const MIST := Color("dfe8ee")

## The arena's interior in pixels (the room sets it).
var arena := Rect2(16, 64, 928, 256)
var phase := 1
var heads: Array[HydraHead] = []
var flood: HydraFlood
## Which of the three heads is solid (phases 1 and 3).
var solid_index := 0

var _turn := 0.0
var _breath := 0.0


func _init() -> void:
	max_hp = MAX_HP
	contact_damage = 0
	gold_min = 80
	gold_max = 100
	xp = 200
	body_size = Vector2(8, 8)
	body_centered = true
	uses_gravity = false
	knockback = 0.0
	state = "dormant"


func _ready() -> void:
	super._ready()
	add_to_group("boss")
	# Only the heads are ever hit.
	collision_layer = 0
	collision_mask = 0
	for i in 4:
		var h := HydraHead.new()
		h.boss = self
		h.index = i
		h.is_head = true
		if i == 3:
			h.coiled = true
		heads.append(h)
		h.position = rest_point(h)
		get_parent().add_child.call_deferred(h)


## Starts the fight (called by the arena once the player is inside).
func begin() -> void:
	set_state("intro")
	Sfx.play("hydra_roar", 0.0, 2.0)
	Feel.add_trauma(0.3)
	GameState.banner.emit(DISPLAY_NAME, EPITHET)


func health_fraction() -> float:
	return clampf(float(hp) / max_hp, 0.0, 1.0)


func tell(base: float) -> float:
	return maxf(Enemy.MIN_TELEGRAPH, base * (FAST if phase == 3 else 1.0))


## What the breath rolls on: the floor, or the flood's surface.
func ground_y() -> float:
	return flood.surface_y() if is_instance_valid(flood) else arena.end.y


## True once every tank in the arena is full (the fourth head shows).
func tanks_full() -> bool:
	for b in get_tree().get_nodes_in_group("dry_basin"):
		var basin := b as DryBasin
		if basin.room == get_parent() and (not basin.filled or basin.level < 1.0):
			return false
	return true


## Where head `h` rests: its lane, high as mist or low when solid.
func rest_point(h: HydraHead) -> Vector2:
	if h.index == 3:
		return global_position + HIDDEN_AT if h.coiled else Vector2(global_position.x, EMERGED_Y)
	var lane: float = global_position.x + LANES[h.index]
	if not h.solid:
		return Vector2(lane, MIST_Y)
	var p := player()
	var x := lane
	if p != null:
		x = clampf(p.global_position.x, lane - LANE, lane + LANE)
	return Vector2(x, SOLID_Y)


func _modify_damage(damage: int, _dir: Vector2) -> int:
	if state != "fight":
		return 0
	if phase == 1:
		# One phase at a time: phase 1 can't cut through phase 2.
		return clampi(damage, 0, hp - int(max_hp * PHASES[1]) - 1)
	return damage


func take_hit(damage: int, dir: Vector2) -> void:
	super.take_hit(damage, dir)
	_hitstun = 0.0
	_check_phase()


## A blow on a head: only a solid one is hurt.
func hit_segment(seg: BossSegment, damage: int, dir: Vector2) -> void:
	var h := seg as HydraHead
	if h == null or not h.solid or h.coiled or state != "fight":
		return
	h.flash = 0.12
	take_hit(damage, dir)


## A parried bite: the head lies stunned a while longer.
## A head is open while it lies where it bit (Enemy.punishable).
func segment_punishable(seg: BossSegment) -> bool:
	var h := seg as HydraHead
	return h != null and h.solid and not h.coiled and h.mode == "down"


func stagger_head(h: HydraHead) -> void:
	if h.mode in ["bite", "down"]:
		h.set_mode("down")
		h.mode_time = -STAGGER_EXTRA
		h.flash = 0.12
		Feel.add_trauma(0.2)


func stagger() -> void:
	pass


func _on_blocked(_dir: Vector2) -> void:
	pass


func _check_phase() -> void:
	if dead:
		return
	var f := health_fraction()
	if phase == 1 and f <= PHASES[0]:
		_enter_phase(2)
	elif phase == 2 and f <= PHASES[1]:
		_enter_phase(3)


func _enter_phase(n: int) -> void:
	phase = n
	_breath = 0.0
	_turn = 0.0
	Feel.add_trauma(0.4)
	if n == 2:
		# The three heads dissolve; the fourth waits in the coil for the water.
		for i in 3:
			heads[i].set_solid(false)
			if heads[i].mode != "idle":
				heads[i].set_mode("rise")
		Sfx.play("hydra_roar", 0.0, 2.0)
		GameState.toast.emit("The heads dissolve into the mist. Something stirs in the coil, waiting for water.")
	else:
		# The coil bursts and the spring floods the arena.
		var h4 := heads[3]
		h4.coiled = true
		h4.set_solid(false)
		h4.set_mode("rise")
		solid_index = 0
		heads[0].set_solid(true)
		flood = HydraFlood.new()
		flood.floor_y = arena.end.y
		flood.full_y = arena.end.y - 4 * Room.TILE
		flood.left = arena.position.x
		flood.right = arena.end.x
		flood.target = 1.0
		get_parent().add_child(flood)
		Sfx.play("flood", 0.0, 2.0)
		Sfx.play("hydra_roar", 0.1, 0.0)
		GameState.toast.emit("The coil bursts and the spring floods the basin!")


func _think(delta: float) -> void:
	velocity = Vector2.ZERO
	match state:
		"intro":
			if state_time >= INTRO_TIME:
				set_state("fight")
				if phase != 2:
					heads[solid_index].set_solid(true)
		"fight":
			_fight(delta)
	_move_heads(delta)


func _fight(delta: float) -> void:
	_turn += delta
	_breath += delta
	var p := player()
	var px := p.global_position.x if p != null else global_position.x
	if phase == 2:
		var h4 := heads[3]
		if h4.coiled and tanks_full():
			h4.coiled = false
			h4.set_solid(true)
			h4.set_mode("emerge")
			Sfx.play("hydra_roar", 0.15, 0.0)
			Feel.add_trauma(0.4)
		elif not h4.coiled and h4.mode == "idle" and h4.mode_time >= IDLE_BEFORE_BITE and absf(px - h4.global_position.x) < BITE_RANGE:
			_rear(h4, FOURTH_REACH_Y)
	else:
		var s := heads[solid_index]
		if _turn >= SOLID_TIME * (FAST if phase == 3 else 1.0) and s.mode == "idle":
			s.set_solid(false)
			solid_index = (solid_index + 1) % 3
			heads[solid_index].set_solid(true)
			heads[solid_index].mode_time = 0.0
			_turn = 0.0
			Sfx.play("swell", 0.1, -6.0)
		elif s.mode == "idle" and s.mode_time >= IDLE_BEFORE_BITE and absf(px - s.global_position.x) < BITE_RANGE:
			_rear(s, ground_y() - 14.0)
	if _breath >= BREATH_EVERY * (FAST if phase == 3 else 1.0):
		# The mist head nearest the player breathes.
		var best: HydraHead = null
		for i in 3:
			var h := heads[i]
			if h.solid or h.mode != "idle":
				continue
			if best == null or absf(h.global_position.x - px) < absf(best.global_position.x - px):
				best = h
		if best != null:
			_breath = 0.0
			best.set_mode("breath_tell")
			Sfx.play("swell", 0.1, -2.0)


## Head `h` rears back to bite where the player is now (no lower than `low_y`).
func _rear(h: HydraHead, low_y: float) -> void:
	var p := player()
	if p == null or p.dead:
		return
	var lane: float = global_position.x + (LANES[h.index] if h.index < 3 else 0.0)
	var target := p.global_position + Vector2(0, -20)
	target.x = clampf(target.x, lane - LANE - 30.0, lane + LANE + 30.0)
	target.y = minf(target.y, low_y)
	h.set_mode("rear")
	h.to = target
	Sfx.play("swell", 0.1, -8.0)


func _move_heads(delta: float) -> void:
	for h in heads:
		if not is_instance_valid(h):
			continue
		h.mode_time += delta
		h.flash -= delta
		var k := 1.0 - exp(-5.0 * delta)
		match h.mode:
			"idle":
				var t := Time.get_ticks_msec() * 0.001
				var sway := Vector2(sin(t * 1.3 + h.index * 2.0) * 6.0, sin(t * 2.1 + h.index) * 4.0)
				h.global_position = h.global_position.lerp(rest_point(h) + sway, k)
			"rear":
				var back := Vector2(-signf(h.to.x - h.from.x) * 10.0, -18.0)
				h.global_position = h.from.lerp(h.from + back, clampf(h.mode_time / 0.2, 0.0, 1.0))
				if h.mode_time >= tell(BITE_TELL):
					h.set_mode("bite")
					Sfx.play("hydra_bite", 0.08, 0.0)
			"bite":
				var b := clampf(h.mode_time / BITE_TIME, 0.0, 1.0)
				h.global_position = h.from.lerp(h.to, b)
				var p := player()
				if not h.bit and p != null and not p.dead and _bite_rect(h).intersects(p.body_rect()):
					h.bit = true
					p.receive_attack(BITE_DAMAGE, h, true)
				if b >= 1.0 and h.mode == "bite":
					var at := h.to
					h.set_mode("down")
					h.global_position = at
					Sfx.play("heavy", 0.05, -2.0)
					Feel.add_trauma(0.2)
			"down":
				if h.mode_time >= DOWN_TIME:
					h.set_mode("rise")
			"rise", "emerge":
				var r := clampf(h.mode_time / (EMERGE_TIME if h.mode == "emerge" else RISE_TIME), 0.0, 1.0)
				h.global_position = h.from.lerp(rest_point(h), smoothstep(0.0, 1.0, r))
				if r >= 1.0:
					h.set_mode("idle")
			"breath_tell":
				h.global_position = h.global_position.lerp(rest_point(h) + Vector2(0, 24), k)
				if h.mode_time >= tell(BREATH_TELL):
					_breathe(h)
					h.set_mode("breath")
			"breath":
				if h.mode_time >= BREATH_TIME:
					h.set_mode("idle")


func _bite_rect(h: HydraHead) -> Rect2:
	return Rect2(h.global_position - Vector2(BITE_SIZE, BITE_SIZE) * 0.5, Vector2(BITE_SIZE, BITE_SIZE))


## A bank of mist rolls out from under the head, toward the player.
func _breathe(h: HydraHead) -> void:
	var b := MistBreath.new()
	var p := player()
	b.dir = signf(p.global_position.x - h.global_position.x) if p != null else 1.0
	if b.dir == 0.0:
		b.dir = 1.0
	b.ground_y = ground_y()
	b.left = arena.position.x
	b.right = arena.end.x
	b.position = Vector2(h.global_position.x, b.ground_y)
	get_parent().add_child(b)
	Sfx.play("mist_breath", 0.08, 0.0)


func _process(delta: float) -> void:
	if state == "dying":
		state_time += delta
		if state_time >= DYING_TIME:
			state = "dead"
			for h in heads:
				if is_instance_valid(h):
					h.queue_free()
			defeated.emit()
			super.die()
	queue_redraw()


func die() -> void:
	if state == "dying":
		return
	set_state("dying")
	dead = true
	collision_layer = 0
	for h in heads:
		h.set_solid(false)
		h.remove_from_group("light")
	if is_instance_valid(flood):
		flood.target = 0.0
	Feel.boss_kill(1.0)
	Feel.add_trauma(0.7)
	Sfx.play("hydra_roar", 0.0, 4.0)


# --- Drawing ---------------------------------------------------------------------

func _draw() -> void:
	var t := Time.get_ticks_msec() * 0.001
	var fade := 1.0
	if state == "dying":
		fade = 1.0 - clampf(state_time / DYING_TIME, 0.0, 1.0)
	# Necks first, from the coil to each head.
	for h in heads:
		if is_instance_valid(h) and not (h.index == 3 and h.coiled):
			_draw_neck(h, fade)
	_draw_coil(t, fade)
	for h in heads:
		if is_instance_valid(h):
			_draw_head(h, t, fade)


## The coil: rings of scaled body wrapped around the spring's shelf.
func _draw_coil(t: float, fade: float) -> void:
	var n := 16
	for i in n:
		var a := TAU * i / n + t * 0.15
		var c := Vector2(cos(a) * 66.0, 18.0 + sin(a) * 20.0)
		var r := 12.0 + 2.0 * sin(a * 2.0)
		var shade := SCALE_DARK if sin(a) < 0.0 else SCALE
		draw_circle(c, r + 1.0, Color(OUTLINE, fade))
		draw_circle(c, r, Color(shade, fade))
		draw_circle(c + Vector2(-2, -3), r * 0.45, Color(SCALE_LIGHT, 0.6 * fade))
		if i % 2 == 0:
			draw_rect(Rect2(c + Vector2(-1, -r + 1), Vector2(2, 3)), Color(BONE, fade))
	if heads.size() == 4 and is_instance_valid(heads[3]) and heads[3].coiled and phase == 2:
		# Eyes glinting in the coil: the hidden fourth head.
		var blink := 0.5 + 0.5 * sin(t * 3.0)
		var e := heads[3].global_position - global_position
		draw_rect(Rect2(e + Vector2(-6, -1), Vector2(3, 2)), Color(EYE, blink * fade))
		draw_rect(Rect2(e + Vector2(3, -1), Vector2(3, 2)), Color(EYE, blink * fade))


func _draw_neck(h: HydraHead, fade: float) -> void:
	var base := Vector2(signf(h.global_position.x - global_position.x) * 40.0, 24.0) if h.index != 3 else Vector2(0, 30)
	if h.index == 1:
		base = Vector2(0, -2)
	var head := h.global_position - global_position
	var ctrl := Vector2(lerpf(base.x, head.x, 0.8), minf(base.y, head.y) - 30.0)
	var steps := 28
	for i in steps:
		var k := float(i) / steps
		var pt := base.lerp(ctrl, k).lerp(ctrl.lerp(head, k), k)
		var r := lerpf(9.0, 6.0, k)
		if h.solid:
			draw_circle(pt, r + 1.0, Color(OUTLINE, fade))
			draw_circle(pt, r, Color(SCALE, fade))
			draw_circle(pt + Vector2(-1, -2), r * 0.4, Color(SCALE_LIGHT, 0.5 * fade))
		else:
			draw_circle(pt, r, Color(MIST, 0.22 * fade))


func _draw_head(h: HydraHead, t: float, fade: float) -> void:
	if h.index == 3 and h.coiled:
		return
	var p := player()
	var f := 1.0
	if p != null and p.global_position.x < h.global_position.x:
		f = -1.0
	var gape := 0.0
	match h.mode:
		"rear":
			gape = 0.3
		"bite", "breath_tell", "breath":
			gape = 1.0
		"down":
			gape = 0.4
	var telling := h.mode in ["rear", "breath_tell"]
	var white := h.flash > 0.0 or telling and int(h.mode_time * 16.0) % 2 == 0
	var a := fade
	var body := SCALE
	var light := SCALE_LIGHT
	var dark := SCALE_DARK
	var line := OUTLINE
	if not h.solid:
		# Fog in the shape of a head: no outline, see-through, wavering.
		a = fade * (0.4 + 0.1 * sin(t * 4.0 + h.index))
		body = MIST
		light = Color.WHITE
		dark = MIST.darkened(0.25)
		line = Color(MIST.darkened(0.4), 0.5)
	# The head's pixels are whole world pixels (twice the body's): it reads big.
	draw_set_transform(h.global_position - global_position, 0.0, Vector2(f * 2.0, 2.0))
	var g := roundi(gape * 8.0)
	# The skull and snout.
	_px(-18, -14, 28, 26, line, a)
	_px(0, -8, 26, 16, line, a)
	_px(-16, -12, 24, 22, body, a)
	_px(2, -6, 22, 10, body, a)
	_px(-12, -10, 12, 4, light, a)
	_px(4, -4, 16, 2, light, a)
	# The lower jaw, open as it bites or breathes.
	_px(0, 4 + g, 24, 6, line, a)
	_px(2, 4 + g, 20, 4, dark, a)
	for i in 4:
		_px(5 + i * 5, 2 + g, 2, 3, BONE, a)
		_px(5 + i * 5, 3, 2, 2, BONE, a)
	# Bone crest and horns.
	_px(-18, -18, 16, 4, BONE, a)
	_px(-22, -22, 6, 6, BONE, a)
	_px(-14, -24, 4, 6, BONE, a)
	var eye := Color.WHITE if telling else EYE
	_px(4, -8, 5, 3, eye, maxf(a, 0.6) if h.solid else a)
	if h.mode in ["breath_tell", "breath"]:
		# Mist welling at the jaws.
		draw_circle(Vector2(12, 4 + g * 0.5), 5.0 + sin(t * 20.0), Color(MIST, 0.7 * fade))
	if white:
		_px(-16, -12, 24, 22, Color.WHITE, 0.6 * maxf(a, 0.5))
		_px(2, -6, 22, 10, Color.WHITE, 0.6 * maxf(a, 0.5))
	draw_set_transform(Vector2.ZERO)
	if h.mode == "breath_tell":
		# The mist pools on the ground under the head before it rolls.
		var gy := ground_y() - global_position.y
		var w := 10.0 + 24.0 * clampf(h.mode_time / tell(BREATH_TELL), 0.0, 1.0)
		var hx := h.global_position.x - global_position.x
		draw_rect(Rect2(hx - w, gy - 4.0, w * 2.0, 4.0), Color(MIST, 0.6))
	elif h.mode == "rear":
		# Where it will strike.
		var to := h.to - global_position
		draw_arc(to, 10.0, 0.0, TAU, 16, Color(EYE, 0.5 if int(h.mode_time * 14.0) % 2 == 0 else 0.25), 1.0)


func _px(x: int, y: int, w: int, h: int, color: Color, alpha: float) -> void:
	draw_rect(Rect2(x * 0.5, y * 0.5, w * 0.5, h * 0.5), Color(color, color.a * alpha))
