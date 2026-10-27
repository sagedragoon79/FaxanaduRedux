class_name BarkCaptain
extends Enemy
## The Bark Knight Captain (design bible 7 and 8): the first knight the World
## Tree grew, older than Conflate, still keeping the watch it was grown for.
## The mini-boss of the Branches, in the Thorn Yard east of Conflate (room
## header `boss: bark_captain`).
##
## He is a Bark Knight grown half again as tall, with the same guard:
## - Thrust (level with you and near): he braces, lance back and eyes lit
##   (tell), then drives a bough lance six tiles out. Parryable. Then he roots,
##   the lance stiff as a branch: stand on it or pogo off it, and strike him,
##   since a rooted knight is open.
## - Vault (phase 2, when you keep your distance): he plants the lance and
##   crouches (tell), then pole-vaults high and comes down lance-first where you
##   stood. The lance sticks in the floor and he hangs there, open.
## His bark is five plates. While he wears it every blow only chips one plate
## off (a quarter of the damage); bare, or open, he takes it all. Each time he
## pulls free of a root one plate grows back. Below half his tells are shorter
## (never under Enemy.MIN_TELEGRAPH).

signal defeated

const DISPLAY_NAME := "The Bark Knight Captain"
const EPITHET := "First Knight of the Tree"
const MAX_HP := 240
const PHASES := [0.5]
const WALK_SPEED := 44.0
## He thrusts when you are this near in front (px) and about level.
const REACH := 120.0
const LEVEL_Y := 48.0
const THRUST_TELL := 0.65
const VAULT_TELL := 0.7
## Phase 2 tells are this fraction as long.
const FAST := 0.8
const THRUST := 0.18
const THRUST_DAMAGE := 18
## The lance, in his local space facing right: from the grip to the thorn.
const LANCE_FROM := 14.0
const LANCE_TO := 110.0
const LANCE_Y := -26.0
const LANCE_HALF := 7.0
const ROOTED := 1.3
const VAULT_UP := -430.0
## The most he covers across in a vault (px/s); he aims to land where you stand.
const VAULT_ACROSS := 360.0
const VAULT_DAMAGE := 20
## Stuck lance-first in the floor after a vault, open.
const PLANTED := 1.4
const RECOVER := 0.5
const BARK := 5
const GUARD := 0.25
const INTRO_TIME := 1.4
const DYING_TIME := 1.4
## The drawing is laid out small and drawn this much larger.
const SCALE := 3.0

const OUTLINE := Color("1c140c")
const BARK_DARK := Color("4a3420")
const BARK_MID := Color("6e4e2e")
const BARK_LIGHT := Color("9a7444")
const HEART := Color("d8b878")
const LEAF := Color("5aa83c")
const LEAF_LIGHT := Color("9ad86a")
const BOUGH := Color("7a9a3a")
const EYE := Color("b8ff7a")

## The yard's interior in pixels (walls and ceiling outside it).
var arena := Rect2(16, 64, 608, 256)
var phase := 1
var bark := BARK
var _thrust_hit := false
var _vault_hit := false
var _vaults := 0
var _bough: StaticBody2D
var _bough_shape: CollisionShape2D
var _rng := RandomNumberGenerator.new()


func _init() -> void:
	max_hp = MAX_HP
	contact_damage = 12
	gold_min = 60
	gold_max = 80
	xp = 120
	body_size = Vector2(28, 52)
	knockback = 0.0
	launchable = false
	state = "dormant"
	_rng.seed = 1987


func _ready() -> void:
	super._ready()
	add_to_group("boss")
	_bough = StaticBody2D.new()
	_bough.collision_layer = Player.LAYER_WORLD
	_bough.collision_mask = 0
	_bough.add_to_group("pogo")
	_bough_shape = CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(LANCE_TO - LANCE_FROM - 12.0, 4.0)
	_bough_shape.shape = r
	_bough_shape.one_way_collision = true
	_bough_shape.disabled = true
	_bough.add_child(_bough_shape)
	add_child(_bough)
	add_collision_exception_with(_bough)


## Starts the fight (called by the arena once the player is inside).
func begin() -> void:
	face_player()
	set_state("intro")
	Sfx.play("bark_creak", 0.0, 4.0)
	Feel.add_trauma(0.3)
	GameState.banner.emit(DISPLAY_NAME, EPITHET)


func health_fraction() -> float:
	return clampf(float(hp) / max_hp, 0.0, 1.0)


func tell(base: float) -> float:
	return maxf(Enemy.MIN_TELEGRAPH, base * (FAST if phase == 2 else 1.0))


## The rooted lance is a bough you can stand on.
func bough_solid() -> bool:
	return _bough_shape != null and not _bough_shape.disabled


func _set_bough(on: bool) -> void:
	if on:
		_bough.position = Vector2(facing * (LANCE_FROM + LANCE_TO + 12.0) * 0.5, LANCE_Y)
	_bough_shape.set_deferred("disabled", not on)


## His opening (Enemy.punishable): rooted after a thrust, planted after a vault,
## or reeling from a parry.
func punishable() -> bool:
	return is_staggered() or state in ["rooted", "planted"]


func stagger() -> void:
	if state in ["dormant", "intro", "dying"]:
		return
	_set_bough(false)
	super.stagger()
	_stagger = 1.4
	velocity = Vector2.ZERO
	Sfx.play("guard", 0.1, -2.0)


func _modify_damage(damage: int, _dir: Vector2) -> int:
	if state in ["dormant", "intro", "dying"]:
		return 0
	if punishable() or bark <= 0:
		return damage
	# A thrown dagger's point sticks in the bark and splits nothing (pass 188).
	if thrown:
		return ceili(damage * GUARD)
	bark -= 1
	_dust(Vector2(0, -30), "debris")
	Sfx.play("bark_chip", 0.1, -2.0 if bark > 0 else 2.0)
	return ceili(damage * GUARD)


## Fire burns his whole bark coat off at once (pass 177), as it does his
## knights'; a plate still regrows each time he pulls free.
func burn_bark() -> void:
	if bark <= 0 or dead or state in ["dormant", "intro", "dying"]:
		return
	bark = 0
	_dust(Vector2(0, -30), "embers")
	Sfx.play("bark_chip", 0.1, 4.0)


func take_hit(damage: int, dir: Vector2) -> void:
	super.take_hit(damage, dir)
	# A boss shrugs off hitstun: blows never interrupt its attacks.
	_hitstun = 0.0
	if not dead and phase == 1 and health_fraction() <= PHASES[0]:
		phase = 2
		Sfx.play("bark_creak", 0.0, 6.0)
		Feel.add_trauma(0.3)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_clamp_to_arena()


func _think(delta: float) -> void:
	if is_staggered():
		velocity.x = 0.0
		return
	var dx := _player_dx()
	match state:
		"dormant":
			velocity.x = 0.0
		"intro":
			velocity.x = 0.0
			if state_time >= INTRO_TIME:
				set_state("walk")
		"walk":
			face_player()
			velocity.x = facing * WALK_SPEED if absf(dx) > 24.0 else 0.0
			if state_time >= 0.6 and is_on_floor():
				_choose(dx)
		"thrust_tell":
			velocity.x = 0.0
			if state_time >= tell(THRUST_TELL):
				_thrust_hit = false
				set_state("thrust")
				Sfx.play("lance_thrust", 0.05, 2.0)
		"thrust":
			velocity.x = 0.0
			if not _thrust_hit and hit_player_in_rect(lance_rect(), THRUST_DAMAGE, true) != "":
				_thrust_hit = true
			if state == "thrust" and state_time >= THRUST:
				_set_bough(true)
				set_state("rooted")
				Sfx.play("root_grip", 0.08, 0.0)
				_dust(Vector2.ZERO, "land")
		"rooted":
			velocity.x = 0.0
			if state_time >= ROOTED:
				_pull_free()
		"vault_tell":
			velocity.x = 0.0
			if state_time >= tell(VAULT_TELL):
				_vault()
		"vault":
			if not _vault_hit and velocity.y > 0.0 and hit_player_in_rect(plunge_rect(), VAULT_DAMAGE, false) != "":
				_vault_hit = true
			if state_time > 0.15 and is_on_floor():
				velocity.x = 0.0
				set_state("planted")
				Sfx.play("lance_plant", 0.05, 2.0)
				Feel.add_trauma(0.4)
				_dust(Vector2.ZERO, "land")
		"planted":
			velocity.x = 0.0
			if state_time >= PLANTED:
				_pull_free()
		"recover":
			velocity.x = 0.0
			if state_time >= RECOVER:
				set_state("walk")
		_:
			set_state("walk")


func _choose(dx: float) -> void:
	face_player()
	var off := player_offset()
	var level := off.x != INF and absf(off.y) < LEVEL_Y
	if level and absf(dx) < REACH:
		set_state("thrust_tell")
		Sfx.play("bark_creak", 0.06, 0.0)
	elif phase == 2 and (absf(dx) > REACH * 1.5 or not level) and _rng.randf() < 0.6:
		set_state("vault_tell")
		Sfx.play("bough_vault", 0.05, 0.0)


## Pulls the lance free and draws one plate of bark back up through the roots.
func _pull_free() -> void:
	_set_bough(false)
	if bark < BARK:
		bark += 1
	set_state("recover")
	Sfx.play("bark_creak", 0.1, -4.0)


func _vault() -> void:
	_vault_hit = false
	_vaults += 1
	var air := 2.0 * -VAULT_UP / GRAVITY
	velocity = Vector2(clampf(_player_dx() / air, -VAULT_ACROSS, VAULT_ACROSS), VAULT_UP)
	set_state("vault")
	Sfx.play("dash", 0.05, 0.0)


## Where the lance reaches, at full thrust.
func lance_rect() -> Rect2:
	var x0 := facing * LANCE_FROM
	var x1 := facing * LANCE_TO
	return Rect2(global_position + Vector2(minf(x0, x1), LANCE_Y - LANCE_HALF),
		Vector2(LANCE_TO - LANCE_FROM, LANCE_HALF * 2.0))


## Under him as he comes down: the lance's point and his weight.
func plunge_rect() -> Rect2:
	return Rect2(global_position + Vector2(-22.0, -20.0), Vector2(44.0, 26.0))


func _clamp_to_arena() -> void:
	var half := body_size.x * 0.5
	global_position.x = clampf(global_position.x, arena.position.x + half, arena.end.x - half)


func _player_dx() -> float:
	var p := player()
	return p.global_position.x - global_position.x if p != null else 0.0


func _dust(offset: Vector2, kind: String) -> void:
	var d := Dust.new()
	d.setup(kind)
	get_parent().add_child(d)
	d.global_position = global_position + offset


func die() -> void:
	if state == "dying":
		return
	_set_bough(false)
	set_state("dying")
	dead = true
	collision_layer = 0
	velocity = Vector2.ZERO
	Feel.boss_kill(1.0)
	Feel.add_trauma(0.7)
	Sfx.play("break", 0.0, 4.0)


func _process(delta: float) -> void:
	if state != "dying":
		return
	state_time += delta
	if int(state_time * 10.0) % 3 == 0:
		_dust(Vector2(_rng.randf_range(-16, 16), _rng.randf_range(-50, -4)), "debris")
	if state_time >= DYING_TIME:
		state = "dead"
		defeated.emit()
		super.die()


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1))
	var hot := state.ends_with("_tell") and telegraph_pulse()
	var crouch := 0
	var lean := 0
	match state:
		"thrust_tell":
			lean = -2
		"vault_tell":
			crouch = 2
		"thrust", "rooted":
			lean = 2
		"dying":
			lean = roundi(sin(state_time * 40.0))
	var by := -17 + crouch
	# Legs: two root-thick trunks; rooted, they run into the floor.
	for lx in [-5, 2]:
		_px(lx - 1, by + 9, 5, 8 - crouch, OUTLINE)
		_px(lx, by + 9, 3, 7 - crouch, BARK_DARK)
	if state in ["rooted", "planted"]:
		for rx in [-7, -3, 4, 7]:
			_px(rx, -1, 1, 1, BARK_MID)
	# Body: plates of bark over pale heartwood; each lost plate bares a scar.
	_px(-8 + lean, by - 6, 16, 16, OUTLINE)
	_px(-7 + lean, by - 5, 14, 14, HEART)
	var plates := [[-7, -5], [0, -5], [-7, 0], [0, 0], [-4, 5]]
	for i in plates.size():
		if i < bark:
			var pl: Array = plates[i]
			_px(pl[0] + lean, by + pl[1], 7, 5, BARK_MID)
			_px(pl[0] + lean, by + pl[1], 7, 1, BARK_LIGHT)
	# Head: a bark helm with a crown of living leaves.
	_px(-5 + lean, by - 13, 10, 8, OUTLINE)
	_px(-4 + lean, by - 12, 8, 6, BARK_MID)
	_px(1 + lean, by - 10, 3, 1, EYE if not hot else Color.WHITE)
	for k in 4:
		_px(-5 + k * 3 + lean, by - 16 + (k % 2), 2, 3, LEAF if k % 2 == 0 else LEAF_LIGHT)
	if hot:
		_px(0 + lean, by - 11, 5, 3, Color(EYE, 0.35))
	# The lance: a long green bough with a thorn.
	match state:
		"thrust", "rooted":
			var y := int(LANCE_Y / SCALE * 2.0)
			_px(int(LANCE_FROM / SCALE * 2.0), y - 1, int((LANCE_TO - LANCE_FROM) / SCALE * 2.0), 3, OUTLINE)
			_px(int(LANCE_FROM / SCALE * 2.0), y, int((LANCE_TO - LANCE_FROM) / SCALE * 2.0), 1, BOUGH)
			_px(int(LANCE_TO / SCALE * 2.0), y, 2, 1, HEART)
		"vault", "planted", "vault_tell":
			_px(5, by - 18, 3, 35, OUTLINE)
			_px(6, by - 17, 1, 34, BOUGH)
		_:
			var back := -4 if state == "thrust_tell" else 0
			_px(-2 + back, by - 1, 22, 3, OUTLINE)
			_px(-2 + back, by, 22, 1, BOUGH)
			_px(20 + back, by, 2, 1, HEART)
	wash(flashing())
	draw_set_transform(Vector2.ZERO)


## Draws a rect of the design (laid out in units of 1/SCALE half-pixels),
## snapped to the half-pixel grid so neighbouring rects still tile.
func _px(x: int, y: int, w: int, h: int, color: Color) -> void:
	var x0 := floorf(x * SCALE)
	var y0 := floorf(y * SCALE)
	var x1 := maxf(floorf((x + w) * SCALE), x0 + 1.0)
	var y1 := maxf(floorf((y + h) * SCALE), y0 + 1.0)
	draw_rect(Rect2(x0 * 0.5, y0 * 0.5, (x1 - x0) * 0.5, (y1 - y0) * 0.5), color)
