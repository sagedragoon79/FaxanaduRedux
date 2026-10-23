class_name IronDwarf
extends Enemy
## A dwarf of Forepaw in iron plate (design bible 7, Tower of Trunk). Plods on
## patrol with a two-handed hammer on his shoulder. With you in front of him he
## heaves it overhead (the telegraph) and slams it down: the blow crushes what
## is in front of him and sends a shockwave rolling along the floor, which you
## jump. The hammer bites into the floor and he must wrench it free, and that is
## the moment to hit him: his plate turns most blows the rest of the time.

const WALK_SPEED := 26.0
const SIGHT := Vector2(96, 44)
const WINDUP := 0.65
const SLAM_ACTIVE := 0.12
const STUCK := 0.95
const RECOVER := 0.4
const SLAM_DAMAGE := 24
const SLAM_SIZE := Vector2(34, 30)
## How much of a blow his plate lets through, outside the stuck window.
const ARMOR := 0.5
const TURN_DELAY := 0.8
const SHEET := "iron_dwarf"

var _slammed := false
var _behind_time := 0.0


func _init() -> void:
	max_hp = 64
	gold_min = 7
	gold_max = 12
	poison_drops = true
	xp = 18
	contact_damage = 12
	body_size = Vector2(20, 30)
	knockback = 25.0


## True while his hammer is stuck in the floor: blows land in full.
func exposed() -> bool:
	return state == "stuck" or is_staggered()


func _modify_damage(damage: int, dir: Vector2) -> int:
	# A pogo from above finds the gap at the top of his helm.
	if exposed() or dir.y > 0.0:
		return damage
	return maxi(1, roundi(damage * ARMOR))


func _think(delta: float) -> void:
	var off := player_offset()
	var seen := off.x != INF and absf(off.x) < SIGHT.x and absf(off.y) < SIGHT.y
	var in_front := seen and signf(off.x) == facing
	match state:
		"idle", "patrol":
			if state == "idle":
				set_state("patrol")
			if in_front and is_on_floor():
				velocity.x = 0.0
				set_state("windup")
				Sfx.play("guard", 0.1, -6.0)
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
				_slammed = false
				set_state("slam")
		"slam":
			velocity.x = 0.0
			if not _slammed:
				_slammed = true
				hit_player_in_rect(slam_rect(), SLAM_DAMAGE, false)
				_quake()
			if state_time >= SLAM_ACTIVE:
				set_state("stuck")
		"stuck":
			velocity.x = 0.0
			if state_time >= STUCK:
				set_state("recover")
		"recover":
			velocity.x = 0.0
			if state_time >= RECOVER:
				set_state("patrol")
		_:
			set_state("patrol")


## Where the hammer comes down, in front of him.
func slam_rect() -> Rect2:
	var x := global_position.x + facing * (body_size.x * 0.5 + SLAM_SIZE.x * 0.5) - SLAM_SIZE.x * 0.5
	return Rect2(Vector2(x, global_position.y - SLAM_SIZE.y), SLAM_SIZE)


func _quake() -> void:
	Feel.add_trauma(0.3)
	Sfx.play("land", 0.05, 4.0)
	var at := Vector2(global_position.x + facing * (body_size.x * 0.5 + 14.0), global_position.y)
	var d := Dust.new()
	d.setup("land")
	get_parent().add_child(d)
	d.global_position = at
	var wave := Shockwave.new()
	wave.direction = facing
	wave.room = get_parent() as Room
	get_parent().add_child(wave)
	wave.global_position = at


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
	elif state in ["windup", "slam", "stuck", "recover"]:
		anim = state
	elif absf(velocity.x) < 1.0:
		t = 0.0
	draw_sheet(SHEET, anim, t, white)
