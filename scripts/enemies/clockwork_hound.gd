class_name ClockworkHound
extends Enemy
## A Clockwork Hound of Vorrhallow (design bible 7): one of Thane Vorrund's brass
## hunting dogs, still running on the spring the king last wound. It trots after
## you. Near enough, it crouches and its key spins up, ratcheting, its eyes
## blazing (the telegraph), then it pounces in a long low arc and bites.
## Parry the bite and it tumbles onto its back, belly plates open, every blow
## landing. Otherwise its brass plating turns half of every blow. It is a thing
## of clockwork, so the Stillstone stops it dead where it stands, mid-leap or
## not. Legend `j`.

const TROT := 62.0
const SIGHT := Vector2(170, 56)
## It pounces when you are this near (px, centre to centre).
const REACH := 120.0
const WIND := 0.45
## Its leap: the rise, and the most it covers across (px/s); it aims to land on you.
const POUNCE := Vector2(320, -230)
const BITE_DAMAGE := 14
const SKID := 0.5
const COOLDOWN := 1.1
## A parried bite throws it on its back this long.
const FLIPPED := 1.3
## The share of a blow its plating lets through, except on its back.
const PLATING := 0.5
## The sheet's animation for each state (docs/art/enemy-style-guide.md 4).
const ANIMS := {"idle": "idle", "trot": "trot", "wind": "wind", "pounce": "pounce", "skid": "skid"}
## Its eye in the crouch (world px from its feet, facing right), where the tell's glow sits.
const EYE_AT := Vector2(7, -16)

const EYE := Color("ff5a3a")
const EYE_HOT := Color("ffe0a0")

var _cool := 0.0
var _bitten := false
## The key's turn, for drawing.
var _key := 0.0
## Its own clock for the looping animations: stopped time stops it with the hound.
var _clock := 0.0
var _died_at := -1.0


func _init() -> void:
	max_hp = 44
	gold_min = 8
	gold_max = 14
	xp = 22
	contact_damage = 10
	body_size = Vector2(24, 16)
	knockback = 60.0
	launchable = false


## On its back after a parry, plating up and belly bare.
func flipped() -> bool:
	return is_staggered()


func stagger() -> void:
	super.stagger()
	_stagger = FLIPPED
	velocity = Vector2(-facing * 60.0, -140.0)
	Sfx.play("guard", 0.1, -4.0)


func _modify_damage(damage: int, _dir: Vector2) -> int:
	if flipped():
		return damage
	return maxi(1, roundi(damage * PLATING))


func _physics_process(delta: float) -> void:
	# Clockwork: stopped time stops it dead, in the air or not.
	if TimeStop.active() and not dead:
		_flash -= delta
		queue_redraw()
		return
	super._physics_process(delta)


func _think(delta: float) -> void:
	_cool -= delta
	var off := player_offset()
	var seen := off.x != INF and absf(off.x) < SIGHT.x and absf(off.y) < SIGHT.y
	_key += delta * (14.0 if state == "wind" else 3.0)
	match state:
		"idle", "trot":
			if state == "idle":
				set_state("trot")
			if seen:
				face_player()
				if absf(off.x) < REACH and _cool <= 0.0 and is_on_floor():
					velocity.x = 0.0
					set_state("wind")
					Sfx.play("ratchet", 0.1, -4.0)
					return
			if _edge_ahead():
				facing = -facing
			velocity.x = facing * (TROT if seen else TROT * 0.5)
		"wind":
			velocity.x = 0.0
			if state_time >= WIND:
				_bitten = false
				var air := 2.0 * -POUNCE.y / GRAVITY
				var off_now := player_offset()
				var across := POUNCE.x if off_now.x == INF else clampf(absf(off_now.x) / air, 100.0, POUNCE.x)
				velocity = Vector2(facing * across, POUNCE.y)
				set_state("pounce")
				Sfx.play("slash", 0.15, -4.0)
		"pounce":
			if not _bitten:
				var res := hit_player_in_rect(bite_rect(), BITE_DAMAGE)
				if res != "":
					_bitten = true
			if state == "pounce" and state_time > 0.1 and is_on_floor():
				set_state("skid")
		"skid":
			velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
			if state_time >= SKID:
				_cool = COOLDOWN
				set_state("trot")
		_:
			set_state("trot")


## Where its jaws close: ahead of the body, at head height.
func bite_rect() -> Rect2:
	var c := center()
	return Rect2(c.x - 6.0 + facing * 10.0, c.y - 10.0, 12.0 + 6.0, 16.0)


func _edge_ahead() -> bool:
	if not is_on_floor():
		return false
	if test_move(global_transform, Vector2(facing * 4, 0)):
		return true
	var t := global_transform.translated(Vector2(facing * (body_size.x * 0.5 + 2), 0))
	return not test_move(t, Vector2(0, 6))


func die() -> void:
	_died_at = Time.get_ticks_msec() * 0.001
	super.die()


func _process(delta: float) -> void:
	if not TimeStop.active():
		_clock += delta
	# The dissolve runs after death, when the body no longer redraws itself: keep
	# the collapse playing under it.
	if dead and dissolving():
		queue_redraw()


## The animation and its time for what it is doing now.
func anim_now() -> Array:
	if dead:
		return ["death", Time.get_ticks_msec() * 0.001 - _died_at]
	if flipped():
		return ["stagger", state_time]
	if _hitstun > 0.0:
		return ["hurt", HITSTUN - _hitstun]
	var a: String = ANIMS.get(state, "idle")
	if a == "trot" and absf(velocity.x) < 1.0:
		a = "idle"
	return [a, state_time if a != "idle" and a != "trot" else _clock]


func _draw() -> void:
	var stopped := TimeStop.active()
	var winding := state == "wind" and not flipped()
	var now := anim_now()
	draw_sheet("clockwork_hound", now[0], now[1], flashing() or (winding and telegraph_pulse()))
	if winding:
		# Its eyes blaze as the key spins up: the tell.
		var eye := EYE_AT * Vector2(facing, 1)
		var k := 0.5 + 0.5 * absf(sin(state_time * 18.0))
		draw_circle(eye, 3.0, Color(EYE, 0.35 * k))
		draw_rect(Rect2(eye.x - 0.5, eye.y - 0.5, 1, 1), EYE_HOT)
	if stopped:
		# Stopped: a ring of clock-glyph ticks around it.
		for i in 4:
			var a := TAU * i / 4.0 + 0.4
			draw_rect(Rect2(roundf(cos(a) * 15.0), -12.0 + roundf(sin(a) * 9.0), 1, 1), Color(EYE_HOT, 0.8))
