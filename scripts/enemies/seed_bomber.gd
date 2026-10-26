class_name SeedBomber
extends Enemy
## A Seed Bomber of the Branches (design bible 7): a pod-bellied canopy bird the
## World Tree grew to sow itself, with leaf wings and a husk of hard seeds for a
## belly. It beats along high over the branch roads. Once it sees you it keeps
## about five tiles over your head, out of reach of a plain slash. Right above
## you it squeezes its husk, wings up, belly swelling and glowing, seeds
## rattling, for 0.5 s (the telegraph), then drops a seed (`BomberSeed`). The
## seed stings for 10 if it lands on you; on the branch it sputters for 0.6 s
## and bursts into thorns for 12 around it. Strike the seed, or parry it as it
## falls, and it flies back up into the bird: it bursts there for 18 and knocks
## the bird out of the sky, dazed on its back for 1.4 s and taking every blow at
## half again. Then it climbs back up. Legend `;`.

## How far it spots you from (px).
const SIGHT := 240.0
## How far above your head it likes to hang.
const HOVER := 84.0
const FLY_SPEED := 72.0
## Squeezes the husk once it is this near right over you.
const OVER := 16.0
const WINDUP := 0.5
const DROP := 0.25
const COOLDOWN := 1.8
const DAZED := 1.4
const DAZED_MULT := 1.5
const RISE := 0.7
const TOUCH_DAMAGE := 8

var _cool := 0.4
var _landed := false


func _init() -> void:
	max_hp = 28
	gold_min = 6
	gold_max = 10
	xp = 14
	body_size = Vector2(18, 18)
	body_centered = true
	uses_gravity = false
	knockback = 90.0
	contact_damage = TOUCH_DAMAGE
	state = "hover"


func is_downed() -> bool:
	return state == "downed"


func _modify_damage(damage: int, _dir: Vector2) -> int:
	return ceili(damage * DAZED_MULT) if is_downed() else damage


## Its own seed flew back into it: it bursts on the husk and the bird falls.
func struck_by_seed(damage: int, from: Vector2) -> void:
	if dead:
		return
	uses_gravity = true
	_landed = false
	take_hit(damage, (center() - from).normalized())
	if dead:
		return
	set_state("downed")
	Feel.add_trauma(0.2)


func _respawn() -> void:
	super()
	uses_gravity = false
	_cool = 0.4
	set_state("hover")


func _think(delta: float) -> void:
	_cool -= delta
	var off := player_offset()
	var sees := off.x != INF and off.length() < SIGHT
	match state:
		"hover":
			if sees:
				face_player()
			var goal := home
			if sees:
				goal = center() + off + Vector2(0, -HOVER)
			goal += Vector2(0, sin(Time.get_ticks_msec() * 0.003) * 3.0)
			velocity = ((goal - center()) * 2.2).limit_length(FLY_SPEED)
			if sees and _cool <= 0.0 and absf(off.x) < OVER and off.y > HOVER * 0.5:
				velocity = Vector2.ZERO
				set_state("windup")
				Sfx.play("seed_rattle", 0.06, -2.0)
		"windup":
			# It shivers in place, squeezing the husk.
			velocity = Vector2(sin(state_time * 70.0) * 20.0, 0.0)
			if state_time >= WINDUP:
				_drop_seed()
				set_state("drop")
		"drop":
			velocity = Vector2(0, -20.0)
			if state_time >= DROP:
				_cool = COOLDOWN
				set_state("hover")
		"downed":
			velocity.x = move_toward(velocity.x, 0.0, 400.0 * delta)
			if is_on_floor() and not _landed:
				_landed = true
				state_time = 0.0
				var d := Dust.new()
				d.setup("land")
				get_parent().add_child(d)
				d.global_position = global_position + Vector2(0, body_size.y * 0.5)
			if _landed and state_time >= DAZED:
				uses_gravity = false
				set_state("rise")
		"rise":
			velocity = Vector2(0, -FLY_SPEED)
			if state_time >= RISE:
				_cool = COOLDOWN * 0.5
				set_state("hover")
		_:
			uses_gravity = false
			set_state("hover")


func _drop_seed() -> void:
	var s := BomberSeed.new()
	s.bomber = self
	s.velocity = Vector2(velocity.x * 0.2, 40.0)
	get_parent().add_child(s)
	s.global_position = center() + Vector2(0, 12)
	Sfx.play("seed_drop", 0.08, -2.0)


func _draw() -> void:
	var white := flashing() or (state == "windup" and telegraph_pulse())
	var anim := "fly"
	var t := Time.get_ticks_msec() * 0.001
	if is_staggered():
		anim = "stagger"
	elif state == "windup":
		anim = "windup"
		t = state_time
	elif state == "drop":
		anim = "drop"
	elif state == "downed":
		anim = "downed"
	elif _cool > COOLDOWN * 0.4:
		# The husk hangs open a moment after a drop.
		anim = "empty"
	draw_sheet("seed_bomber", anim, t, white)
