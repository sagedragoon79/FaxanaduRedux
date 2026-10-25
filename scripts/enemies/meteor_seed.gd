class_name MeteorSeed
extends Enemy
## What a corrupted foe of Zenis leaves when it dies (design bible 8.9): the
## shard of meteor crystal that was growing in it hangs in the air, swells and
## flickers for TELL seconds, then bursts in a ring of cyan light that hurts
## anything inside it. Unparryable. Strike it first (a slash or a pogo) and it
## cracks harmlessly, so pressing on is safer than backing off. The Hour Glass
## holds it still. The origin is the seed's centre.

const TELL := 0.7
const BURST_TIME := 0.18
const RADIUS := 30.0
const DAMAGE := 10
const SIZE := 10.0
const LIGHT := Color("b8fff4")
const CYAN := Color("4ae0d8")
const DEEP := Color("1a6a78")
const OUTLINE := Color("13101f")

## True once a blow cracked it before it could burst.
var cracked := false
var _hit := false


func _init() -> void:
	max_hp = 1
	gold_min = 0
	gold_max = 0
	xp = 0
	contact_damage = 0
	body_size = Vector2(SIZE, SIZE)
	body_centered = true
	uses_gravity = false
	launchable = false
	knockback = 0.0


func _ready() -> void:
	super._ready()
	# It hangs in the air: walls don't hold it, and it doesn't shove the player.
	collision_mask = 0
	z_index = 2
	set_state("tell")
	Sfx.play("swell", 0.1, -6.0)


## The ring the burst covers.
func burst_rect() -> Rect2:
	return Rect2(global_position - Vector2(RADIUS, RADIUS), Vector2(RADIUS, RADIUS) * 2.0)


func _physics_process(delta: float) -> void:
	if TimeStop.active():
		queue_redraw()
		return
	super._physics_process(delta)


func _think(_delta: float) -> void:
	velocity = Vector2.ZERO
	match state:
		"tell":
			if state_time >= TELL:
				set_state("burst")
				collision_layer = 0  # too late to crack it now
				Sfx.play("break")
				Feel.add_trauma(0.15)
		"burst":
			if not _hit:
				var p := player()
				# A circle, not the square around it.
				if p != null and not p.dead and _touches(p.body_rect()):
					_hit = p.receive_attack(DAMAGE, self, false) != ""
			if state_time >= BURST_TIME:
				dead = true
				queue_free()


func _touches(r: Rect2) -> bool:
	var nearest := Vector2(clampf(global_position.x, r.position.x, r.end.x), clampf(global_position.y, r.position.y, r.end.y))
	return nearest.distance_to(global_position) <= RADIUS


## A blow cracks it before it bursts: no gold, no light, no harm.
func die() -> void:
	if dead:
		return
	dead = true
	cracked = true
	collision_layer = 0
	var d := Dust.new()
	d.setup("hit")
	get_parent().add_child(d)
	d.global_position = global_position
	Sfx.play("guard")
	queue_free()


func _draw() -> void:
	if state == "burst":
		var k := state_time / BURST_TIME
		draw_arc(Vector2.ZERO, RADIUS * (0.5 + 0.5 * k), 0.0, TAU, 24, Color(CYAN, 1.0 - k), 4.0)
		draw_circle(Vector2.ZERO, RADIUS * 0.6 * (1.0 - k), Color(LIGHT, 0.8 * (1.0 - k)))
		return
	var t := state_time / TELL
	# Swells and flickers faster as it nears the burst; the ring it will fill shows faint.
	var s := SIZE * 0.5 * (0.8 + 0.5 * t)
	var on := int(state_time * (8.0 + 16.0 * t)) % 2 == 0
	draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 24, Color(CYAN, 0.12 + 0.25 * t), 1.0)
	var pts := PackedVector2Array([Vector2(0, -s * 1.4), Vector2(s, 0), Vector2(0, s * 1.4), Vector2(-s, 0)])
	var rim := PackedVector2Array([Vector2(0, -s * 1.4 - 1.0), Vector2(s + 1.0, 0), Vector2(0, s * 1.4 + 1.0), Vector2(-s - 1.0, 0)])
	draw_colored_polygon(rim, OUTLINE)
	draw_colored_polygon(pts, LIGHT if (on or flashing()) else CYAN)
	draw_rect(Rect2(-1.0, -s * 0.8, 2.0, s * 1.2), DEEP if on else LIGHT)
