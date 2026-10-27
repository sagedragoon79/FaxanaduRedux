class_name BarkKnight
extends Enemy
## A Bark Knight of the Branches (design bible 7): a knight the World Tree grew
## for itself, armored in living bark, with a lance of green bough. He paces the
## branch roads. Come level with him within about five tiles in front and he
## braces, lance back and eyes lit, for 0.6 s (the telegraph), then drives it out
## to its full reach (about four tiles) for 16. The thrust can be parried. Then
## he roots: his feet sink into the branch for 1.1 s and the lance stays out,
## stiff as a bough. You can stand on it, or pogo off it, to get over him.
##
## The bark is his guard. While he wears it every blow only chips it (a quarter
## damage, rounded up) and knocks off one of its three plates; with the plates
## gone he is bare heartwood and takes full damage. While he is rooted the bark
## doesn't guard him at all, but he draws it back up through the roots: one plate
## grows back as he pulls free. So strip him quickly, or strike while he roots.
## Legend `!`.

const WALK_SPEED := 22.0
## Braces when you are this near in front, level with him.
const REACH := 84.0
const LEVEL_Y := 36.0
const BRACE := 0.6
const THRUST := 0.16
const THRUST_DAMAGE := 16
## The lance, in his local space facing right: from the grip to the thorn.
const LANCE_FROM := 10.0
const LANCE_TO := 72.0
const LANCE_Y := -18.0
const LANCE_HALF := 6.0
const ROOTED := 1.1
const COOLDOWN := 0.8
const BARK := 3
const GUARD := 0.25
const CONTACT := 10

var bark := BARK
var _thrust_hit := false
var _cool := 0.0
var _bough: StaticBody2D
var _bough_shape: CollisionShape2D


func _init() -> void:
	max_hp = 54
	gold_min = 8
	gold_max = 12
	xp = 20
	contact_damage = CONTACT
	body_size = Vector2(18, 32)
	knockback = 40.0


func _ready() -> void:
	super()
	_bough = StaticBody2D.new()
	_bough.collision_layer = Player.LAYER_WORLD
	_bough.collision_mask = 0
	_bough.add_to_group("pogo")
	_bough_shape = CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(LANCE_TO - LANCE_FROM - 8.0, 4.0)
	_bough_shape.shape = r
	_bough_shape.one_way_collision = true
	_bough_shape.disabled = true
	_bough.add_child(_bough_shape)
	add_child(_bough)
	add_collision_exception_with(_bough)


## The rooted lance is a bough you can stand on.
func bough_solid() -> bool:
	return _bough_shape != null and not _bough_shape.disabled


func _set_bough(on: bool) -> void:
	if on:
		_bough.position = Vector2(facing * (LANCE_FROM + LANCE_TO + 8.0) * 0.5, LANCE_Y)
	_bough_shape.set_deferred("disabled", not on)


func is_rooted() -> bool:
	return state == "rooted"


func _modify_damage(damage: int, _dir: Vector2) -> int:
	if bark <= 0 or is_rooted():
		return damage
	# A thrown dagger's point sticks in the bark and splits nothing (pass 188).
	if thrown:
		return ceili(damage * GUARD)
	bark -= 1
	var d := Dust.new()
	d.setup("debris")
	get_parent().add_child(d)
	d.global_position = center()
	Sfx.play("bark_chip", 0.1, -3.0 if bark > 0 else 1.0)
	return ceili(damage * GUARD)


## Fire burns the whole bark coat off at once (pass 177): what's left is bare
## heartwood until he roots and regrows a plate.
func burn_bark() -> void:
	if bark <= 0 or dead:
		return
	bark = 0
	var d := Dust.new()
	d.setup("embers")
	get_parent().add_child(d)
	d.global_position = center()
	Sfx.play("bark_chip", 0.1, 3.0)


func _respawn() -> void:
	super()
	bark = BARK
	_cool = 0.0
	_set_bough(false)


func die() -> void:
	_set_bough(false)
	super()


func stagger() -> void:
	_set_bough(false)
	super()


func _think(delta: float) -> void:
	_cool = maxf(_cool - delta, 0.0)
	var off := player_offset()
	match state:
		"idle", "walk":
			if state == "idle":
				set_state("walk")
			if off.x != INF and absf(off.y) < LEVEL_Y and absf(off.x) < REACH and _cool <= 0.0:
				face_player()
				velocity.x = 0.0
				set_state("windup")
				Sfx.play("bark_creak", 0.06, -2.0)
				return
			if off.x != INF and absf(off.x) < REACH * 2.5 and absf(off.y) < LEVEL_Y * 2.0:
				face_player()
			if is_on_floor() and (_wall_ahead() or not _floor_ahead()):
				facing = -facing
			velocity.x = facing * WALK_SPEED
		"windup":
			velocity.x = 0.0
			if state_time >= BRACE:
				_thrust_hit = false
				set_state("thrust")
				Sfx.play("lance_thrust", 0.05, -1.0)
		"thrust":
			velocity.x = 0.0
			if not _thrust_hit and hit_player_in_rect(lance_rect(), THRUST_DAMAGE, true) != "":
				_thrust_hit = true
			if state_time >= THRUST:
				_set_bough(true)
				set_state("rooted")
				Sfx.play("root_grip", 0.08, -3.0)
				var d := Dust.new()
				d.setup("land")
				get_parent().add_child(d)
				d.global_position = global_position
		"rooted":
			velocity.x = 0.0
			if state_time >= ROOTED:
				_set_bough(false)
				if bark < BARK:
					bark += 1
				_cool = COOLDOWN
				set_state("walk")
		_:
			_set_bough(false)
			set_state("walk")


## Where the lance reaches, at full thrust.
func lance_rect() -> Rect2:
	var x0 := facing * LANCE_FROM
	var x1 := facing * LANCE_TO
	return Rect2(global_position + Vector2(minf(x0, x1), LANCE_Y - LANCE_HALF),
		Vector2(LANCE_TO - LANCE_FROM, LANCE_HALF * 2.0))


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
	elif state == "windup":
		anim = "brace"
	elif state in ["thrust", "rooted"]:
		anim = state
	elif absf(velocity.x) < 1.0:
		t = 0.0
	draw_sheet("bark_knight", ("" if bark > 0 else "bare_") + anim, t, white)
	if bark > 0 and bark < BARK:
		# Pale scars where plates came off.
		for i in BARK - bark:
			draw_rect(Rect2(Vector2(-4.0 + i * 4.0 * facing, -30.0 + i * 6.0), Vector2(3, 3)), Color(0.87, 0.74, 0.52, 0.9))
