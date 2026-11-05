class_name GlassSlug
extends Enemy
## A Glass Slug of Vorrhallow (design bible 7): a great grey slug that has
## grown a shell of stillglass-rock, molten in its cracks. It creeps along the
## floor. When you come near, its shell swells and glows (the telegraph), then
## it heaves three gobbets of molten rock at you in high arcs: they burn on
## contact and leave embers where they land. The Stillstone holds them in the
## air. The shell turns blows from above; its soft sides take everything.
## Legend `s`.

const CRAWL := 14.0
const SIGHT := Vector2(170, 80)
const SWELL := 0.6
const RECOVER := 0.7
const COOLDOWN := 1.6
const GLOBS := 3
const SPREAD := 26.0
const FLIGHT := 0.75
## The sheet's animation for each state (docs/art/enemy-style-guide.md 4): the heave
## and its slack after it play as one, through the recover.
const ANIMS := {"idle": "idle", "crawl": "crawl", "swell": "swell", "recover": "recover"}

var _cool := 0.0
var _died_at := -1.0


func _init() -> void:
	max_hp = 40
	gold_min = 8
	gold_max = 12
	xp = 20
	contact_damage = 10
	body_size = Vector2(30, 18)
	knockback = 20.0
	launchable = false


func _modify_damage(damage: int, dir: Vector2) -> int:
	# The stillglass shell on its back turns anything coming down on it.
	return 0 if dir.y > 0.0 and state != "recover" else damage


func _think(delta: float) -> void:
	_cool -= delta
	var off := player_offset()
	var seen := off.x != INF and absf(off.x) < SIGHT.x and absf(off.y) < SIGHT.y
	match state:
		"idle", "crawl":
			if state == "idle":
				set_state("crawl")
			if seen and _cool <= 0.0 and is_on_floor():
				velocity.x = 0.0
				face_player()
				set_state("swell")
				Sfx.play("swell", 0.1, -4.0)
				return
			if _edge_ahead():
				facing = -facing
			velocity.x = facing * CRAWL
		"swell":
			velocity.x = 0.0
			if state_time >= SWELL:
				_heave()
				set_state("recover")
		"recover":
			velocity.x = 0.0
			if state_time >= RECOVER:
				_cool = COOLDOWN
				set_state("crawl")
		_:
			set_state("crawl")


## Three gobbets in high arcs: one at you, one short, one long.
func _heave() -> void:
	var p := player()
	var from := center() + Vector2(0, -12)
	var target := p.global_position if p != null else from + Vector2(facing * 80, 0)
	for i in GLOBS:
		var g := MeteorGlob.new()
		g.room = get_parent() as Room
		get_parent().add_child(g)
		g.global_position = from
		var aim := target + Vector2((i - 1) * SPREAD * facing, 0)
		g.velocity = MeteorGlob.launch(from, aim, FLIGHT + 0.08 * i)
	Sfx.play("spore", 0.1, -2.0)
	Feel.add_trauma(0.08)


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
	if a == "crawl" and absf(velocity.x) < 1.0:
		a = "idle"
	return [a, state_time if a != "idle" and a != "crawl" else Time.get_ticks_msec() * 0.001]


func _draw() -> void:
	var now := anim_now()
	draw_sheet("meteor_slug", now[0], now[1], flashing() or (state == "swell" and telegraph_pulse()))
