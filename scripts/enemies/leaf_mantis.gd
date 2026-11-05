class_name LeafMantis
extends Enemy
## A Leaf Mantis of the High Boughs (design bible 7): a mantis the green of the
## Ylden's leaves, folded up on a bough so it looks like one more leaf
## cluster. It does not hurt to touch while it hides. Come near and it rears up
## and spreads its scythe arms (the telegraph), then lunges along the bough and
## slashes. A lunge that misses leaves it overreached, arms low: strike it then
## for half again the damage. Its slash can be parried. Legend `m`.

## How near you must come (px, centre to centre) before it unfolds.
const SIGHT_X := 110.0
const SIGHT_Y := 48.0
const UNFOLD := 0.5
const LUNGE_SPEED := 260.0
const LUNGE_TIME := 0.25
const RECOVER := 0.8
const STALK_SPEED := 40.0
## Out of sight this long while stalking, it folds back into a leaf.
const LOSE_TIME := 2.0
const SLASH_DAMAGE := 16
const TOUCH_DAMAGE := 10
## Overreached, it takes this much more damage.
const SOFT := 1.5
## The scythes' reach in front of the body while lunging.
const SLASH_REACH := 24.0

var _struck := false
var _lost := 0.0


func _init() -> void:
	max_hp = 30
	gold_min = 4
	gold_max = 8
	xp = 9
	body_size = Vector2(22, 32)
	knockback = 60.0
	contact_damage = 0
	state = "hide"


func _think(delta: float) -> void:
	var off := player_offset()
	var seen := off.x != INF and absf(off.x) < SIGHT_X and absf(off.y) < SIGHT_Y
	contact_damage = 0 if state == "hide" else TOUCH_DAMAGE
	match state:
		"hide":
			velocity.x = 0.0
			if seen:
				_unfold()
		"unfold":
			velocity.x = 0.0
			face_player()
			if state_time >= UNFOLD:
				_struck = false
				set_state("lunge")
				Sfx.play("scythe", 0.1, -3.0)
		"lunge":
			if _edge_ahead():
				velocity.x = 0.0
			else:
				velocity.x = facing * LUNGE_SPEED
			if not _struck:
				var res := hit_player_in_rect(slash_rect(), SLASH_DAMAGE)
				if res != "":
					_struck = true
			if state_time >= LUNGE_TIME and state == "lunge":
				velocity.x = 0.0
				set_state("recover")
		"recover":
			velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
			if state_time >= RECOVER:
				_lost = 0.0
				set_state("stalk")
		"stalk":
			if seen:
				_lost = 0.0
				face_player()
				velocity.x = 0.0 if _edge_ahead() else facing * STALK_SPEED
				if state_time >= 0.4:
					_unfold()
			else:
				velocity.x = 0.0
				_lost += delta
				if _lost >= LOSE_TIME:
					set_state("hide")
		_:
			set_state("stalk")


func _unfold() -> void:
	velocity.x = 0.0
	face_player()
	set_state("unfold")
	Sfx.play("mantis_unfold", 0.1, -4.0)


## Where its scythes cut during a lunge.
func slash_rect() -> Rect2:
	var c := center()
	var x := c.x if facing > 0 else c.x - SLASH_REACH - body_size.x * 0.5
	return Rect2(x, c.y - 16.0, SLASH_REACH + body_size.x * 0.5, 30.0)


func _modify_damage(damage: int, _dir: Vector2) -> int:
	if state == "hide":
		# Struck while folded: it springs open, and the next swing is yours.
		_unfold()
	return roundi(damage * SOFT) if state == "recover" else damage


func _edge_ahead() -> bool:
	if not is_on_floor():
		return false
	if test_move(global_transform, Vector2(facing * 4, 0)):
		return true
	var t := global_transform.translated(Vector2(facing * (body_size.x * 0.5 + 2), 0))
	return not test_move(t, Vector2(0, 6))


## The sheet's animation for each state (docs/art/enemy-style-guide.md 4): folded flat
## like a leaf cluster, reared with its scythes up (the tell), the lunge, overreached.
const ANIMS := {
	"hide": "hide", "unfold": "unfold", "lunge": "lunge", "recover": "recover", "stalk": "stalk",
}

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
	var now := Time.get_ticks_msec() * 0.001
	if dead:
		return ["death", now - _died_at]
	if is_staggered():
		return ["stagger", state_time]
	if _hitstun > 0.0:
		return ["hurt", HITSTUN - _hitstun]
	var a: String = ANIMS.get(state, "idle")
	if a == "stalk" and absf(velocity.x) < 1.0:
		a = "idle"
	if a in ["idle", "stalk", "hide"]:
		# Looping clips run on the clock; a folded one sways with its own bough.
		return [a, now + home.x * 0.01]
	return [a, state_time]


func _draw() -> void:
	var now := anim_now()
	var white := flashing() or (state == "unfold" and telegraph_pulse())
	draw_sheet("leaf_mantis", now[0], now[1], white)
