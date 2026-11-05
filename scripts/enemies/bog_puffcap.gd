class_name BogPuffcap
extends Enemy
## A Bog Puffcap of the Haar (design bible 7): a squat marsh mushroom rooted in
## the boardwalk mud. Come near and its cap swells and its gills glow (the
## telegraph, a light that shows through the fog), then it bursts into a cloud
## of spores that hangs in the air and stings anyone inside. Spent, its cap
## sags open and soft: strike it then for half again the damage. Legend `V`.
## As in the original, where the Puffcap always drops health-restoring bread,
## a slain one always leaves a loaf of bread (pass 289).

## How near you must come (px, centre to centre) before it swells.
const SIGHT_X := 84.0
const SIGHT_Y := 60.0
const WINDUP := 0.6
const BURST := 0.25
const SPENT := 1.1
const COOLDOWN := 1.4
## Spent, it takes this much more damage.
const SOFT := 1.5
## How far its glowing gills light the fog while it swells.
const GLOW_RADIUS := 34.0
const SHEET := "bog_puffcap"

var _cooldown := 0.3
var _died_at := -1.0
## Read by the fog (group "light") while it swells.
var light_radius := 0.0


func _init() -> void:
	max_hp = 26
	launchable = false
	gold_min = 3
	gold_max = 7
	xp = 8
	sure_drop = "bread"
	body_size = Vector2(20, 26)
	knockback = 0.0
	contact_damage = 10


func _think(delta: float) -> void:
	_cooldown -= delta
	velocity.x = 0.0
	var off := player_offset()
	match state:
		"idle":
			if _cooldown <= 0.0 and off.x != INF and absf(off.x) < SIGHT_X and absf(off.y) < SIGHT_Y:
				face_player()
				set_state("windup")
				_glow(true)
				Sfx.play("swell", 0.08, -4.0)
		"windup":
			if state_time >= WINDUP:
				_glow(false)
				_burst()
				set_state("burst")
		"burst":
			if state_time >= BURST:
				set_state("spent")
		"spent":
			if state_time >= SPENT:
				_cooldown = COOLDOWN
				set_state("idle")
		_:
			_glow(false)
			set_state("idle")


func _modify_damage(damage: int, _dir: Vector2) -> int:
	return roundi(damage * SOFT) if state == "spent" or state == "burst" else damage


## The cap's centre, where the spores burst from.
func cap() -> Vector2:
	var c: Array = Sheet.info(SHEET, "windup", 1).cap
	return global_position + Vector2(float(c[0]) * facing, float(c[1]))


func _burst() -> void:
	var cloud := SporeCloud.new()
	get_parent().add_child(cloud)
	cloud.global_position = cap()
	Sfx.play("spore", 0.08, -2.0)


func _glow(on: bool) -> void:
	light_radius = GLOW_RADIUS if on else 0.0
	if on:
		add_to_group("light")
	elif is_in_group("light"):
		remove_from_group("light")


func die() -> void:
	_glow(false)
	_died_at = Time.get_ticks_msec() * 0.001
	super()


func _process(_delta: float) -> void:
	# The dissolve runs after death, when the body no longer redraws itself: keep
	# the wilt playing under it.
	if dead and dissolving():
		queue_redraw()


## The animation and its time for what it is doing now (docs/art/enemy-style-guide.md 4).
func anim_now() -> Array:
	if dead:
		return ["death", Time.get_ticks_msec() * 0.001 - _died_at]
	if _hitstun > 0.0 and state == "idle":
		return ["hurt", HITSTUN - _hitstun]
	if state in ["windup", "burst", "spent"]:
		return [state, state_time]
	return ["idle", Time.get_ticks_msec() * 0.001]


func _draw() -> void:
	var white := flashing() or (state == "windup" and telegraph_pulse())
	var now := anim_now()
	draw_sheet(SHEET, now[0], now[1], white)
