class_name Mothling
extends Enemy
## A Mothling, Snapcrown's brood (design bible 8.5): a winged imp the size of a
## hand, violet with petal wings, three loosed at a time from the Bloom's
## petals as in the original. It flutters up out of the bulb, hangs above and
## to one side of you, screeches with its wings flared (telegraph), then dives
## at where you were and climbs back. It never comes back once struck down, and
## the brood dies with the Bloom. Drawn from its PixelLab sheet (art loop pass 4).

## Fluttering up out of the bulb, harmless until it is clear of the petals.
const RISE := 0.5
const HOVER_OFFSET := Vector2(56, -52)
const HOVER_TIME := 1.1
const WINDUP := 0.4
const DIVE_SPEED := 250.0
const DIVE_TIME := 0.45
const TOUCH_DAMAGE := 8


## Which side of the player this one hangs on, and how far it sits from the
## others in its brood (each of the three keeps its own place).
var side := 1
var slot := 0
var _dir := Vector2.ZERO


func _init() -> void:
	max_hp = 20
	contact_damage = 0
	gold_min = 1
	gold_max = 2
	xp = 3
	body_size = Vector2(12, 10)
	body_centered = true
	uses_gravity = false
	knockback = 200.0
	state = "rise"


func _think(delta: float) -> void:
	var off := player_offset()
	contact_damage = 0 if state == "rise" else TOUCH_DAMAGE
	match state:
		"rise":
			velocity = velocity.move_toward(Vector2.ZERO, 300.0 * delta)
			if state_time >= RISE:
				set_state("hover")
		"hover":
			face_player()
			if off.x == INF:
				velocity = velocity.move_toward(Vector2.ZERO, 300.0 * delta)
				return
			var t := Time.get_ticks_msec() * 0.001 + slot * 1.7
			var target := center() + off + Vector2(side * (HOVER_OFFSET.x + slot * 14.0), HOVER_OFFSET.y - slot * 10.0)
			target += Vector2(sin(t * 2.3) * 10.0, sin(t * 4.1) * 6.0)
			velocity = ((target - global_position) * 3.0).limit_length(150.0)
			if state_time >= HOVER_TIME + slot * 0.35:
				velocity = Vector2.ZERO
				set_state("windup")
				Sfx.play("mothling_screech", 0.15, -6.0)
		"windup":
			velocity = velocity.move_toward(Vector2.ZERO, 500.0 * delta)
			face_player()
			if state_time >= WINDUP:
				_dir = off.normalized() if off.x != INF else Vector2(facing, 0)
				set_state("dive")
				Sfx.play("mothling_dive", 0.15, -6.0)
		"dive":
			velocity = _dir * DIVE_SPEED
			if state_time >= DIVE_TIME or get_slide_collision_count() > 0:
				side = -side
				set_state("hover")
		_:
			set_state("hover")


## The sheet's animation for each state (docs/art/enemy-style-guide.md 4): its wingbeat
## rising and hovering, wings flared in the screech (the tell), swept back in the dive.
const ANIMS := {"rise": "fly", "hover": "fly", "windup": "windup", "dive": "dive"}

var _died_at := -1.0


func die() -> void:
	_died_at = Time.get_ticks_msec() * 0.001
	super.die()


func _process(_delta: float) -> void:
	# Keep the crumple playing under the dissolve.
	if dead and dissolving():
		queue_redraw()


## The animation and its time for what it is doing now.
func anim_now() -> Array:
	var now := Time.get_ticks_msec() * 0.001
	if dead:
		return ["death", now - _died_at]
	if _hitstun > 0.0 or is_staggered():
		return ["hurt", HITSTUN - _hitstun]
	var a: String = ANIMS.get(state, "fly")
	# Each of the brood beats its wings out of step with the others.
	return [a, now + slot * 0.13 if a == "fly" else state_time]


func _draw() -> void:
	var now := anim_now()
	var white := flashing() or (state == "windup" and telegraph_pulse())
	# It trembles as it screeches.
	var jitter := Vector2(randf_range(-1, 1), 0).round() if state == "windup" else Vector2.ZERO
	draw_sheet("mothling", now[0], now[1], white, jitter)
