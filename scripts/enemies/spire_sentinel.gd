class_name SpireSentinel
extends Enemy
## A Spire Sentinel of Carillon (design bible 7): a knight of pale shrine stone
## the elves set to guard their stairs, helmed and holding a halberd, with the
## Sky Key's gold lightning cut into its breastplate. It is stone while you watch
## it: it never moves while you face it, and blows clink off it. Turn your back
## and it grinds after you across the floor, and stops dead the moment you turn
## round. Come within its reach and it raises the halberd while the glyph and its
## eyes blaze (0.6 s, the telegraph), then slams it down in front for 16. The
## slam can be parried. A parry staggers it, and a slam that misses buries the
## blade in the floor for 1.2 s: either way the stone cracks open and every blow
## lands. Legend `]`.

## It notices you from this far (px) when you are about level with it.
const SIGHT := 208.0
const LEVEL := 72.0
## It strikes when you are nearer than this.
const REACH := 40.0
const STALK_SPEED := 64.0
const RAISE := 0.6
const SLAM := 0.2
const SPENT := 1.2
const COOLDOWN := 1.0
const SLAM_DAMAGE := 16
const CONTACT := 8

const STONE_DARK := Color("8d84a3")
const GLYPH := Color("ffd24a")
const CRACK := Color("fff0a0")

var _cool := 0.6
var _struck := false
## True while you have your back to it (it moves only then).
var _unwatched := false


func _init() -> void:
	max_hp = 40
	gold_min = 10
	gold_max = 16
	xp = 20
	contact_damage = CONTACT
	body_size = Vector2(18, 38)
	knockback = 0.0
	launchable = false
	state = "stone"


## Cracked open: struck by a parry, or with its blade buried after a slam.
func exposed() -> bool:
	return state == "spent" or is_staggered()


func is_stalking() -> bool:
	return state == "stalk"


func _modify_damage(damage: int, _dir: Vector2) -> int:
	return damage if exposed() else 0


## Does the player face it? A statue moves only when no one is looking.
func watched() -> bool:
	var p := player()
	if p == null or p.dead:
		return false
	var dx := global_position.x - p.global_position.x
	return absf(dx) < 2.0 or int(signf(dx)) == p.facing


func _respawn() -> void:
	super()
	_cool = 0.6
	set_state("stone")


func _think(delta: float) -> void:
	_cool -= delta
	var off := player_offset()
	var sees := off.x != INF and absf(off.x) < SIGHT and absf(off.y) < LEVEL
	var near := sees and absf(off.x) < REACH
	_unwatched = sees and not watched()
	match state:
		"stone":
			velocity.x = 0.0
			if near and _cool <= 0.0:
				_raise()
			elif _unwatched and not near:
				face_player()
				if _can_step(facing):
					set_state("stalk")
					Sfx.play("sentinel_grind", 0.06, -4.0)
		"stalk":
			face_player()
			if near and _cool <= 0.0:
				_raise()
			elif not _unwatched or near or not _can_step(facing):
				# Seen again (or at a wall or an edge): it is stone at once.
				velocity.x = 0.0
				set_state("stone")
			else:
				velocity.x = facing * STALK_SPEED
		"raise":
			velocity.x = 0.0
			if state_time >= RAISE:
				_struck = false
				set_state("slam")
				Sfx.play("sentinel_slam", 0.05, -1.0)
				Feel.add_trauma(0.3)
		"slam":
			velocity.x = 0.0
			if not _struck:
				_struck = true
				if hit_player_in_rect(slam_rect(), SLAM_DAMAGE) == "parried":
					return
			if state_time >= SLAM:
				set_state("spent")
		"spent":
			velocity.x = 0.0
			if state_time >= SPENT:
				_cool = COOLDOWN
				set_state("stone")
		_:
			_cool = COOLDOWN
			set_state("stone")


func _raise() -> void:
	velocity.x = 0.0
	face_player()
	set_state("raise")
	Sfx.play("sentinel_raise", 0.05, -2.0)


## Where the halberd comes down: from its front edge out past its reach.
func slam_rect() -> Rect2:
	var top := global_position.y - body_size.y
	var w := REACH + 12.0
	var x := global_position.x if facing > 0 else global_position.x - w
	return Rect2(x, top, w, body_size.y)


func _can_step(dir: int) -> bool:
	if test_move(global_transform, Vector2(dir * 4, 0)):
		return false
	var t := global_transform.translated(Vector2(dir * (body_size.x * 0.5 + 2), 0))
	return test_move(t, Vector2(0, 6))


## The sheet's animation for each state (docs/art/enemy-style-guide.md 4).
const ANIMS := {"stone": "idle", "stalk": "stalk", "raise": "raise", "slam": "slam", "spent": "spent"}
## Where its eye slit and the glyph on its breastplate are (world px from its feet,
## facing right), for the gold light that wakes in them.
const EYE := Vector2(5, -33)
const GLYPH_AT := Vector2(6, -25)
## Where the halberd's head meets the floor in the slam (world px in front of its feet).
## The art's reach ends here; the stone shock carries the blow out to the end of slam_rect.
const HEAD_X := 20.0
## How long the shock along the floor takes to fade after the impact (s).
const SHOCK_FADE := 0.2

var _died_at := -1.0


func die() -> void:
	_died_at = Time.get_ticks_msec() * 0.001
	super.die()


func _process(_delta: float) -> void:
	# The dissolve runs after death, when the body no longer redraws itself: keep
	# the collapse playing under it.
	if dead and dissolving():
		queue_redraw()


## The animation and its time for what it is doing now.
func anim_now() -> Array:
	if dead:
		return ["death", Time.get_ticks_msec() * 0.001 - _died_at]
	if is_staggered():
		return ["stagger", state_time]
	if _hitstun > 0.0:
		return ["hurt", HITSTUN - _hitstun]
	var a: String = ANIMS.get(state, "idle")
	if a == "stalk" and absf(velocity.x) < 1.0:
		a = "idle"
	return [a, state_time if a != "stalk" else Time.get_ticks_msec() * 0.001]


func _draw() -> void:
	var t := Time.get_ticks_msec() * 0.001
	var now := anim_now()
	draw_sheet("spire_sentinel", now[0], now[1], flashing() or (state == "raise" and telegraph_pulse()))
	if dead:
		return
	var f := Vector2(facing, 1)
	var hot := state == "raise" or state == "slam"
	var awake := _unwatched or state in ["stalk", "raise", "slam"]
	# Its eyes wake behind the visor while you are not looking, and blaze with the glyph
	# as it raises the halberd (the telegraph's light; the pose is the art's).
	if (awake or exposed()) and now[0] in ["idle", "stalk", "raise"]:
		var e := EYE * f
		draw_rect(Rect2(e.x - 1.5, e.y - 0.5, 3, 1), GLYPH)
		draw_circle(e, 2.5, Color(GLYPH, 0.3))
	if state == "raise":
		var r := 3.0 + sin(t * 30.0)
		draw_circle(GLYPH_AT * f, r * 2.0, Color(GLYPH, 0.25))
	# Cracked open: bright seams across the stone.
	if exposed():
		for seam: Rect2 in SEAMS:
			draw_rect(Rect2(seam.position * f - Vector2(seam.size.x if facing < 0 else 0.0, 0), seam.size), Color(CRACK, 0.9))
	# The slam's reach, drawn: a stone shock along the floor from the halberd's head to the
	# far edge of slam_rect, bright on the impact and gone in SHOCK_FADE. During the tell a
	# faint line marks where it will run.
	if state == "slam" or (state == "spent" and state_time < SHOCK_FADE - SLAM):
		var k := clampf((state_time + (SLAM if state == "spent" else 0.0)) / SHOCK_FADE, 0.0, 1.0)
		_draw_shock(1.0 - k, t)
	elif state == "raise":
		var x0 := HEAD_X * facing
		var x1 := shock_reach() * facing
		for i in int((shock_reach() - HEAD_X) / 4.0):
			draw_rect(Rect2(lerpf(x0, x1, i / ((shock_reach() - HEAD_X) / 4.0)), -1, 2, 1), Color(GLYPH, 0.25))
	# Grit kicked up while it grinds along.
	if state == "stalk":
		for k in 3:
			var gx := -facing * (8.0 + fposmod(t * 40.0 + k * 5.0, 10.0))
			draw_rect(Rect2(gx, -2.0 - k, 1, 1), Color(STONE_DARK, 0.8))


## The seams that glow when it cracks open (world px from its feet, facing right).
const SEAMS: Array[Rect2] = [Rect2(3, -30, 1, 4), Rect2(4, -26, 3, 1), Rect2(9, -22, 1, 4), Rect2(4, -14, 1, 4)]


## How far in front of its feet the drawn shock reaches: the far edge of slam_rect.
func shock_reach() -> float:
	return slam_rect().size.x


## The shock: a jagged crack along the floor and a low wave of stone dust over it.
func _draw_shock(a: float, t: float) -> void:
	if a <= 0.0:
		return
	var pts := PackedVector2Array()
	var x := HEAD_X
	var i := 0
	while x <= shock_reach():
		pts.append(Vector2(x * facing, -1.0 - float((i + int(t * 20.0)) % 3 == 0)))
		x += 3.0
		i += 1
	pts.append(Vector2(shock_reach() * facing, -1.0))
	draw_polyline(pts, Color(CRACK, a), 1.0)
	var span := shock_reach() - HEAD_X
	for j in 6:
		var dx := HEAD_X + span * (j + 0.5) / 6.0
		var h := 2.0 + 3.0 * (1.0 - a) * (1.0 - j / 6.0) + float(j % 2)
		draw_rect(Rect2(dx * facing - 2.0, -h - 1.0, 4.0, h), Color(STONE_DARK, 0.7 * a))
