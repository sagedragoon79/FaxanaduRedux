class_name RotDwarf
extends Enemy
## A dwarf rotted by the meteor's influence. Patrols behind a shield that blocks
## frontal hits; raises an axe (telegraph) to swing. Parry the swing to stagger
## him, or hit him from behind or above.

const WALK_SPEED := 35.0
const SIGHT_FRONT := 70.0
const WINDUP := 0.5
const SWING_ACTIVE := 0.15
const RECOVER := 0.6
const SWING_DAMAGE := 20
const SWING_SIZE := Vector2(36, 30)
const TURN_DELAY := 0.6


var _swung := false
var _behind_time := 0.0


func _init() -> void:
	max_hp = 40
	gold_min = 5
	gold_max = 9
	xp = 12
	body_size = Vector2(18, 28)
	knockback = 60.0


## Shield up whenever he isn't committed to an attack or staggered.
func shield_up() -> bool:
	return state in ["patrol", "idle", "recover"] and not is_staggered()


func _modify_damage(damage: int, dir: Vector2) -> int:
	# A hit travelling against his facing comes from the front.
	if shield_up() and dir.y == 0.0 and signf(dir.x) == -facing:
		return 0
	return damage


func _think(delta: float) -> void:
	var off := player_offset()
	var in_front := off.x != INF and signf(off.x) == facing and absf(off.x) < SIGHT_FRONT and absf(off.y) < 40.0
	var behind := off.x != INF and signf(off.x) == -facing and absf(off.x) < SIGHT_FRONT and absf(off.y) < 40.0
	match state:
		"idle", "patrol":
			if state == "idle":
				set_state("patrol")
			if in_front:
				velocity.x = 0.0
				set_state("windup")
				return
			_behind_time = _behind_time + delta if behind else 0.0
			if _behind_time > TURN_DELAY:
				facing = -facing
				_behind_time = 0.0
			if is_on_floor() and (_wall_ahead() or not _floor_ahead()):
				facing = -facing
			velocity.x = facing * WALK_SPEED
		"windup":
			velocity.x = 0.0
			if state_time >= WINDUP:
				_swung = false
				Sfx.play("slash", 0.05, 2.0)
				set_state("swing")
		"swing":
			velocity.x = 0.0
			if not _swung:
				var rect := Rect2(global_position + Vector2(facing * (body_size.x * 0.5 + SWING_SIZE.x * 0.5) - SWING_SIZE.x * 0.5, -SWING_SIZE.y), SWING_SIZE)
				if hit_player_in_rect(rect, SWING_DAMAGE, true) != "":
					_swung = true
			if state_time >= SWING_ACTIVE:
				set_state("recover")
		"recover":
			velocity.x = 0.0
			if state_time >= RECOVER:
				set_state("patrol")
		_:
			set_state("patrol")


func _wall_ahead() -> bool:
	return test_move(global_transform, Vector2(facing * 4, 0))


func _floor_ahead() -> bool:
	var t := global_transform.translated(Vector2(facing * (body_size.x * 0.5 + 2), 0))
	return test_move(t, Vector2(0, 6))


func _draw() -> void:
	var white := flashing() or (state == "windup" and telegraph_pulse())
	var anim := "walk"
	var t := state_time
	if is_staggered():
		anim = "stagger"
	elif state in ["windup", "swing", "recover"]:
		anim = state
	elif absf(velocity.x) < 1.0:
		t = 0.0
	draw_sheet("rot_dwarf", anim, t, white)
