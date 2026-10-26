class_name MarshHag
extends Enemy
## A Marsh Hag of the Mist (design bible 7): a bent old crone of the drowned
## villages in a shawl of reeds, moss for hair, leaning on a crooked willow staff
## with a marsh-wisp caught in its crook. The wisp is a light, so she shows
## through the fog from far off. She keeps her distance: come within about four
## tiles and she hobbles away from you. From farther off she hexes the mire under
## your feet. She raises the staff and the wisp flares green, while a ring of
## bubbling bog light marks the ground where you stood (`MireGrasp`), for 0.6 s
## (the telegraph). Then a hand of black mud bursts up out of the mark for 12,
## which can't be parried: step off the mark. Strike her while she hexes and the
## spell breaks: the mark fizzles, she fumbles her staff for 1.0 s and takes every
## blow at half again. So the answer is to close in, through the fog, toward her
## light. Legend `?`.

## She spots you from this far (px), and shuffles nearer until she can hex.
const SIGHT := 240.0
## She hexes from anywhere this near (about 11 tiles).
const HEX_RANGE := 176.0
## Too close: she backs away while you are nearer than this.
const SHY := 64.0
const LEVEL := 96.0
const WALK_SPEED := 22.0
const BACK_SPEED := 34.0
## She gives up backing away after this long and hexes anyway.
const BACK_TIME := 1.2
const HEX := 0.6
const CAST := 0.3
const COOLDOWN := 1.6
const FUMBLE := 1.0
const SOFT := 1.5
const CONTACT := 6

var _cool := 0.6
var _backed := 0.0
var _mark: MireGrasp
var _wisp: HagWisp


## The marsh-wisp in the crook of her staff, lighting the fog.
class HagWisp:
	extends Node2D
	var light_radius := 40.0

	func _ready() -> void:
		add_to_group("light")


func _init() -> void:
	max_hp = 30
	gold_min = 8
	gold_max = 12
	xp = 18
	contact_damage = CONTACT
	body_size = Vector2(16, 26)
	knockback = 70.0
	state = "idle"


func _ready() -> void:
	super()
	_wisp = HagWisp.new()
	add_child(_wisp)
	_place_wisp()


func is_fumbling() -> bool:
	return state == "fumble"


func is_hexing() -> bool:
	return state == "windup"


## The mark of the hex now being cast, or null.
func mark() -> MireGrasp:
	return _mark if _mark != null and is_instance_valid(_mark) else null


func _modify_damage(damage: int, _dir: Vector2) -> int:
	if is_hexing():
		_break_hex()
		return ceili(damage * SOFT)
	return ceili(damage * SOFT) if is_fumbling() else damage


func die() -> void:
	_fizzle()
	super()


func _respawn() -> void:
	super()
	_cool = 0.6
	_backed = 0.0
	_fizzle()


## Struck mid-hex: the mark fizzles and she fumbles her staff.
func _break_hex() -> void:
	_fizzle()
	set_state("fumble")
	Sfx.play("hag_fumble", 0.06, -2.0)


func _fizzle() -> void:
	if mark() != null:
		_mark.fizzle()
	_mark = null


func _place_wisp() -> void:
	if _wisp != null:
		var raise := 6.0 if state in ["windup", "cast"] else 0.0
		_wisp.position = Vector2(facing * 11.0, -body_size.y - 4.0 - raise)
		_wisp.light_radius = 64.0 if state == "windup" else 40.0


func _think(delta: float) -> void:
	_cool -= delta
	var off := player_offset()
	var sees := off.x != INF and absf(off.x) < SIGHT and absf(off.y) < LEVEL
	_place_wisp()
	match state:
		"idle", "walk":
			if state == "idle":
				set_state("walk")
			velocity.x = 0.0
			if not sees:
				return
			face_player()
			if absf(off.x) < SHY and _backed < BACK_TIME:
				set_state("withdraw")
				return
			if absf(off.x) <= HEX_RANGE:
				if _cool <= 0.0:
					_begin_hex()
			elif _can_step(facing):
				# Out of hexing reach she shuffles nearer, slowly.
				velocity.x = facing * WALK_SPEED
		"withdraw":
			# She backs away from you, still facing you.
			face_player()
			_backed += delta
			if not sees or absf(off.x) >= SHY * 1.4 or _backed >= BACK_TIME or not _can_step(-facing):
				velocity.x = 0.0
				set_state("walk")
				return
			velocity.x = -facing * BACK_SPEED
		"windup":
			velocity.x = 0.0
			if state_time >= HEX:
				if mark() != null:
					_mark.erupt()
					Sfx.play("mire_grasp", 0.06, -1.0)
				_mark = null
				_cool = COOLDOWN
				set_state("cast")
		"cast":
			velocity.x = 0.0
			if state_time >= CAST:
				_backed = 0.0
				set_state("walk")
		"fumble":
			velocity.x = 0.0
			if state_time >= FUMBLE:
				_cool = COOLDOWN * 0.5
				_backed = 0.0
				set_state("walk")
		_:
			set_state("walk")


## Marks the floor under you and raises the staff. False if you stand over no floor.
func _begin_hex() -> bool:
	var p := player()
	var room := get_parent() as Room
	if p == null or room == null:
		return false
	var foot := MireGrasp.floor_below(room, p.global_position)
	if foot == Vector2.INF:
		return false
	_mark = MireGrasp.new()
	_mark.hag = self
	room.add_child(_mark)
	_mark.global_position = foot
	velocity.x = 0.0
	set_state("windup")
	Sfx.play("hag_hex", 0.06, -2.0)
	return true


func _can_step(dir: int) -> bool:
	if test_move(global_transform, Vector2(dir * 4, 0)):
		return false
	var t := global_transform.translated(Vector2(dir * (body_size.x * 0.5 + 2), 0))
	return test_move(t, Vector2(0, 6))


func _draw() -> void:
	var white := flashing() or (state == "windup" and telegraph_pulse())
	var anim := "walk"
	var t := state_time
	if is_staggered():
		anim = "stagger"
	elif state == "windup":
		anim = "hex"
	elif state in ["cast", "fumble"]:
		anim = state
	elif absf(velocity.x) < 1.0:
		anim = "idle"
		t = Time.get_ticks_msec() * 0.001
	draw_sheet("marsh_hag", anim, t, white)
	# The wisp in the crook of the staff: a pale green flame that flares as she hexes.
	if _wisp != null and not is_fumbling():
		var w := _wisp.position
		var now := Time.get_ticks_msec() * 0.001
		var hot := state == "windup"
		var r := (3.0 if hot else 2.0) + sin(now * 9.0) * 0.5
		draw_circle(w, r * 3.0, Color(0.55, 1.0, 0.6, 0.12 if not hot else 0.25))
		draw_circle(w, r + 1.0, Color("2e5a3a"))
		draw_circle(w, r, Color("8af0a0"))
		draw_circle(w + Vector2(-0.5, -0.5), r * 0.45, Color("e8fff0"))
