class_name CrystalDwarf
extends Enemy
## A dwarf of Dartmoor fused with the meteor (design bible 7, Dartmoor). Magenta
## crystal has grown out of his back like a shell and swallowed his right arm.
## He trudges toward you, and with you ahead of him he raises the crystal fist
## (it brightens: the telegraph) and drives it into the floor. A chain of crystal
## spikes erupts along the floor toward you, one after another: jump them. His
## fist stays rooted for a moment after, and that is the time to hit him. His
## crystal back turns any blow from behind; only a pogo from above gets past it.

const WALK_SPEED := 22.0
const SIGHT := Vector2(150, 48)
const REACH := 120.0
const WINDUP := 0.6
const ROOTED := 0.9
const RECOVER := 0.35
const COOLDOWN := 0.8
const TURN_DELAY := 0.6
const SPIKES := 6
const SPIKE_GAP := 20.0
const SPIKE_STEP := 0.09
const FIST_DAMAGE := 16
const SKIN := Color("8d84a3")
const SKIN_DARK := Color("5a5470")
const TUNIC := Color("2e5a64")
const TUNIC_DARK := Color("1d3a44")
const BEARD := Color("c9c4d6")
const HELM := Color("6b6380")
const CRYSTAL := Color("c050c8")
const CRYSTAL_LIGHT := Color("f0a0f0")
const CRYSTAL_DARK := Color("6a2a78")
const OUTLINE := Color("13101f")

var _struck := false
var _behind_time := 0.0
var _cool := 0.0


func _init() -> void:
	max_hp = 48
	gold_min = 9
	gold_max = 15
	poison_drops = true
	xp = 24
	contact_damage = 14
	body_size = Vector2(20, 28)
	knockback = 30.0


## True while his fist is rooted in the floor.
func rooted() -> bool:
	return state == "rooted"


func _modify_damage(damage: int, dir: Vector2) -> int:
	# The crystal on his back turns a blow from behind, unless it comes down from
	# above or his fist is stuck in the floor.
	if dir.y > 0.0 or rooted() or is_staggered():
		return damage
	if dir.x != 0.0 and signf(dir.x) == facing:
		return 0
	return damage


func _think(delta: float) -> void:
	_cool -= delta
	var off := player_offset()
	var seen := off.x != INF and absf(off.x) < SIGHT.x and absf(off.y) < SIGHT.y
	var in_front := seen and signf(off.x) == facing
	match state:
		"idle", "walk":
			if state == "idle":
				set_state("walk")
			if in_front and absf(off.x) < REACH and is_on_floor() and _cool <= 0.0:
				velocity.x = 0.0
				set_state("windup")
				Sfx.play("swell", 0.1, -4.0)
				return
			_behind_time = _behind_time + delta if seen and not in_front else 0.0
			if _behind_time > TURN_DELAY:
				facing = -facing
				_behind_time = 0.0
			if is_on_floor() and (_wall_ahead() or not _floor_ahead()):
				facing = -facing
			velocity.x = facing * WALK_SPEED
		"windup":
			velocity.x = 0.0
			if state_time >= WINDUP:
				_struck = false
				set_state("rooted")
		"rooted":
			velocity.x = 0.0
			if not _struck:
				_struck = true
				hit_player_in_rect(fist_rect(), FIST_DAMAGE, false)
				_erupt()
			if state_time >= ROOTED:
				set_state("recover")
		"recover":
			velocity.x = 0.0
			if state_time >= RECOVER:
				_cool = COOLDOWN
				set_state("walk")
		_:
			set_state("walk")


## Where the fist comes down, just in front of him.
func fist_rect() -> Rect2:
	var x := global_position.x + facing * (body_size.x * 0.5 + 6.0)
	return Rect2(Vector2(x - 8.0, global_position.y - 16.0), Vector2(16, 16))


## The spikes burst along the floor away from him, stopping at a wall or a ledge.
func _erupt() -> void:
	Feel.add_trauma(0.25)
	Sfx.play("break", 0.05, 3.0)
	var room := get_parent() as Room
	for i in SPIKES:
		var at := Vector2(global_position.x + facing * (body_size.x * 0.5 + 14.0 + i * SPIKE_GAP), global_position.y)
		if room != null and (room.is_solid_at(at + Vector2(0, -6)) or not (room.is_solid_at(at + Vector2(0, 4)) or room.is_one_way_at(at + Vector2(0, 4)))):
			break
		var s := CrystalSpike.new()
		s.delay = i * SPIKE_STEP
		get_parent().add_child(s)
		s.global_position = at


## One crystal shard: a long diamond from `base` along `dir`, lit down one face.
func _shard(base: Vector2, dir: Vector2, length: float, half_width: float) -> void:
	var side := dir.orthogonal() * half_width
	var tip := base + dir * length
	var tail := base - dir * 2.0
	var pts := PackedVector2Array([tail, base + side, tip, base - side])
	var rim := PackedVector2Array([tail - dir, base + side * 1.35, tip + dir * 1.5, base - side * 1.35])
	draw_colored_polygon(rim, OUTLINE)
	draw_colored_polygon(pts, CRYSTAL)
	draw_colored_polygon(PackedVector2Array([tail, base + side, tip]), CRYSTAL_DARK)
	draw_line(base, tip, CRYSTAL_LIGHT, 1.0)


func _wall_ahead() -> bool:
	return test_move(global_transform, Vector2(facing * 4, 0))


func _floor_ahead() -> bool:
	var t := global_transform.translated(Vector2(facing * (body_size.x * 0.5 + 2), 0))
	return test_move(t, Vector2(0, 6))


func _draw() -> void:
	var t := Time.get_ticks_msec() * 0.001
	var glow := state == "windup" and telegraph_pulse()
	var white := flashing()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1))
	var step := roundf(sin(t * 7.0)) if state == "walk" and absf(velocity.x) > 1.0 else 0.0
	# Legs: short and thick, in iron boots.
	draw_rect(Rect2(-8, -7 + step, 6, 7 - step), OUTLINE)
	draw_rect(Rect2(2, -7 - step, 6, 7 + step), OUTLINE)
	draw_rect(Rect2(-7, -6 + step, 4, 5 - step), HELM)
	draw_rect(Rect2(3, -6 - step, 4, 5 + step), HELM)
	# The crystal shell over his back: three great shards.
	for k in 3:
		var base := Vector2(-7 - k, -24 + k * 6)
		var dir := Vector2(-0.75 - k * 0.1, -1.0 + k * 0.35).normalized()
		_shard(base, dir, 15.0 - k * 2.0, 4.5 - k * 0.5)
	# Body: a squat teal tunic, a belt.
	draw_rect(Rect2(-9, -22, 18, 16), OUTLINE)
	draw_rect(Rect2(-8, -21, 16, 14), TUNIC)
	draw_rect(Rect2(-8, -12, 16, 2), TUNIC_DARK)
	draw_rect(Rect2(-1, -12, 3, 2), CRYSTAL_DARK)
	# Head: grey stone skin, a horned helm, a long pale beard, glowing eyes.
	draw_rect(Rect2(-6, -30, 12, 9), OUTLINE)
	draw_rect(Rect2(-5, -29, 10, 7), SKIN)
	draw_rect(Rect2(-6, -32, 12, 4), HELM)
	draw_line(Vector2(-6, -31), Vector2(-9, -35), BEARD, 1.5)
	draw_rect(Rect2(-4, -24, 10, 8), BEARD)
	draw_rect(Rect2(-2, -17, 6, 3), BEARD)
	draw_rect(Rect2(2, -27, 2, 1.5), CRYSTAL_LIGHT)
	# The crystal fist: raised and blazing in the windup, buried while rooted.
	var fist := Vector2(10, -16)
	match state:
		"windup":
			fist = Vector2(6, -34 - minf(state_time / WINDUP, 1.0) * 4.0)
		"rooted":
			fist = Vector2(14, -4)
		"recover":
			fist = Vector2(12, -10)
	draw_line(Vector2(5, -18), fist, OUTLINE, 6.0)
	draw_line(Vector2(5, -18), fist, SKIN_DARK, 4.0)
	var r := 6.0
	var gem := PackedVector2Array([fist + Vector2(0, -r - 2), fist + Vector2(r, -1), fist + Vector2(r - 1, r), fist + Vector2(-r + 1, r), fist + Vector2(-r, -1)])
	draw_colored_polygon(PackedVector2Array(Array(gem).map(func(v: Vector2) -> Vector2: return fist + (v - fist) * 1.25)), OUTLINE)
	draw_colored_polygon(gem, CRYSTAL_LIGHT if glow else CRYSTAL)
	draw_line(fist + Vector2(-2, -r), fist + Vector2(2, r - 2), CRYSTAL_LIGHT if not glow else Color.WHITE, 1.0)
	if white:
		draw_rect(Rect2(-10, -34, 26, 34), Color(1, 1, 1, 0.6))
	draw_set_transform(Vector2.ZERO)
	if state == "windup":
		draw_circle(Vector2(6 * facing, -36), 8.0 + 3.0 * sin(state_time * 30.0), Color(CRYSTAL_LIGHT, 0.25))
