class_name SpireSentinel
extends Enemy
## A Spire Sentinel of Daybreak (design bible 7): a knight of pale shrine stone
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
## Design units per half-pixel (2.0: one unit is one world pixel).
const SCALE := 2.0

const OUTLINE := Color("1e1a2a")
const STONE_DARK := Color("8d84a3")
const STONE := Color("c9c4d6")
const STONE_LIGHT := Color("e8e4f0")
const GLYPH := Color("ffd24a")
const GLYPH_DIM := Color("8a6a2a")
const HAFT := Color("6b6380")
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


func _draw() -> void:
	var t := Time.get_ticks_msec() * 0.001
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1))
	var hot := state == "raise" or state == "slam"
	var awake := _unwatched or state in ["stalk", "raise", "slam"]
	# Plinth feet and greaves.
	_px(-8, -3, 16, 3, OUTLINE)
	_px(-7, -2, 14, 2, STONE_DARK)
	_px(-6, -12, 5, 10, OUTLINE)
	_px(1, -12, 5, 10, OUTLINE)
	_px(-5, -11, 3, 9, STONE)
	_px(2, -11, 3, 9, STONE_DARK)
	# Tabard of stone over the hips.
	_px(-7, -18, 14, 7, OUTLINE)
	_px(-6, -17, 12, 5, STONE_DARK)
	_px(-2, -17, 4, 5, STONE)
	# Breastplate with the gold lightning glyph.
	_px(-8, -29, 16, 12, OUTLINE)
	_px(-7, -28, 14, 10, STONE)
	_px(-7, -28, 3, 10, STONE_LIGHT)
	var gl := GLYPH if hot or exposed() else (GLYPH if awake else GLYPH_DIM)
	_px(1, -27, 2, 3, gl)
	_px(-1, -25, 3, 2, gl)
	_px(-2, -23, 2, 3, gl)
	# Pauldrons.
	_px(-10, -30, 5, 4, OUTLINE)
	_px(5, -30, 5, 4, OUTLINE)
	_px(-9, -29, 3, 2, STONE_LIGHT)
	_px(6, -29, 3, 2, STONE)
	# The helm: a tall crest, a slit visor, eyes that glow when it wakes.
	_px(-5, -37, 10, 9, OUTLINE)
	_px(-4, -36, 8, 7, STONE)
	_px(-1, -41, 3, 5, OUTLINE)
	_px(0, -40, 1, 4, STONE_LIGHT)
	_px(-3, -33, 7, 1, OUTLINE)
	if awake or hot or exposed():
		_px(1, -33, 2, 1, GLYPH)
		_px(-2, -33, 1, 1, GLYPH)
	# The halberd: upright at its side, raised overhead in the telegraph,
	# swung down in front in the slam, buried in the floor while spent.
	match state:
		"raise":
			var lift := minf(state_time / RAISE, 1.0)
			var top := -50 - roundi(lift * 6.0)
			_px(8, top, 2, -top - 20, HAFT)
			_px(6, top - 1, 7, 5, OUTLINE)
			_px(7, top, 5, 3, STONE_LIGHT)
			_px(9, -27, 3, 4, STONE)
		"slam", "spent":
			# The haft swept down forward, the blade in the floor ahead.
			for i in 7:
				_px(10 + i * 4, -26 + i * 3, 4, 2, HAFT)
			_px(36, -10, 7, 10, OUTLINE)
			_px(37, -9, 5, 8, STONE_LIGHT)
			_px(9, -27, 3, 4, STONE)
		_:
			_px(9, -44, 2, 43, HAFT)
			_px(7, -49, 6, 6, OUTLINE)
			_px(8, -48, 4, 4, STONE_LIGHT)
			_px(11, -46, 3, 2, STONE)
			_px(8, -27, 3, 4, STONE)
	# Cracked open: bright seams across the stone.
	if exposed():
		_px(-5, -26, 1, 4, CRACK)
		_px(-4, -22, 3, 1, CRACK)
		_px(3, -20, 1, 4, CRACK)
		_px(-3, -9, 1, 4, CRACK)
	if hot and state == "raise":
		var r := 3.0 + sin(t * 30.0)
		draw_circle(Vector2(1, -25), r * 2.0, Color(GLYPH, 0.25))
	wash(flashing() or (state == "raise" and telegraph_pulse()))
	draw_set_transform(Vector2.ZERO)
	# Grit kicked up while it grinds along.
	if state == "stalk":
		for k in 3:
			var gx := -facing * (8.0 + fposmod(t * 40.0 + k * 5.0, 10.0))
			draw_rect(Rect2(gx, -2.0 - k, 1, 1), Color(STONE_DARK, 0.8))


## Draws a rect of the design (in units of 1/SCALE half-pixels), snapped to
## the half-pixel grid so neighbouring rects still tile.
func _px(x: int, y: int, w: int, h: int, color: Color, alpha := 1.0) -> void:
	var x0 := floorf(x * SCALE)
	var y0 := floorf(y * SCALE)
	var x1 := maxf(floorf((x + w) * SCALE), x0 + 1.0)
	var y1 := maxf(floorf((y + h) * SCALE), y0 + 1.0)
	draw_rect(Rect2(x0 * 0.5, y0 * 0.5, (x1 - x0) * 0.5, (y1 - y0) * 0.5), Color(color, color.a * alpha))
