class_name BomberSeed
extends Area2D
## The seed a Seed Bomber drops: a hard husk of thorns. Falling, it stings for
## DAMAGE whoever it lands on. On a floor it sticks and sputters for FUSE (its
## telegraph: the husk swells and its seams blink faster), then bursts into
## thorns that hit everything within BURST_RADIUS for BURST_DAMAGE; the burst
## can't be parried. Strike it at any time, or parry it as it falls, and it
## flies back up into its bird (`SeedBomber.struck_by_seed`). Pogo off it, too.

const GRAVITY := 700.0
const MAX_FALL := 360.0
const DAMAGE := 10
const FUSE := 0.6
const BURST_DAMAGE := 12
const BURST_RADIUS := 28.0
const RETURN_SPEED := 320.0
const RETURN_DAMAGE := 18
const LIFE := 4.0
const RADIUS := 4.0
const HUSK := Color("8a5a32")
const HUSK_DARK := Color("4a2c1a")
const SEAM := Color("f0c060")
const HOT := Color("ff7a4a")
const OUTLINE := Color("120f19")

var bomber: SeedBomber
var velocity := Vector2.ZERO
## "fall", "fuse" (stuck on a floor) or "return" (struck back at its bird).
var phase := "fall"
var _t := 0.0
var _life := 0.0


func _ready() -> void:
	z_index = 2
	collision_layer = Player.LAYER_ENEMY
	collision_mask = 0
	monitoring = false
	add_to_group("pogo")
	add_to_group("enemy_projectile")
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = RADIUS + 1.0
	shape.shape = circle
	add_child(shape)


func box() -> Rect2:
	return Rect2(global_position - Vector2(RADIUS, RADIUS), Vector2(RADIUS, RADIUS) * 2.0)


func _physics_process(delta: float) -> void:
	if TimeStop.active():
		return  # held still by the Hour Glass
	_t += delta
	_life += delta
	var room := get_parent() as Room
	match phase:
		"fall":
			velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)
			var p := get_tree().get_first_node_in_group("player") as Player
			if p != null and not p.dead and box().intersects(p.body_rect()):
				if p.receive_attack(DAMAGE, self, true) != "parried":
					_burst()
				return
			var next := global_position + velocity * delta
			if room != null and _lands(room, next + Vector2(0, RADIUS)):
				# It sticks where it lands and starts to sputter.
				var cell := room.cell_at(next + Vector2(0, RADIUS))
				global_position.y = room.to_global(Vector2(0, cell.y * Room.TILE)).y - RADIUS
				velocity = Vector2.ZERO
				phase = "fuse"
				_t = 0.0
				Sfx.play("seed_fuse", 0.06, -3.0)
			else:
				global_position = next
		"fuse":
			if _t >= FUSE:
				_burst()
				return
		"return":
			if bomber != null and is_instance_valid(bomber) and not bomber.dead:
				var to := bomber.center() - global_position
				velocity = to.normalized() * RETURN_SPEED
				if to.length() < 12.0:
					bomber.struck_by_seed(RETURN_DAMAGE, global_position)
					_burst(false)
					return
			else:
				velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)
			global_position += velocity * delta
			if room != null and room.is_solid_at(global_position):
				_burst(false)
				return
	if _life >= LIFE:
		_burst(phase != "return")
		return
	queue_redraw()


## A floor under `foot`: solid ground, or a one-way plank crossed from above.
func _lands(room: Room, foot: Vector2) -> bool:
	if room.is_solid_at(foot):
		return true
	return room.is_one_way_at(foot) and room.cell_at(foot).y != room.cell_at(global_position + Vector2(0, RADIUS)).y


## Struck by a blade: it flies back up at its bird.
func take_hit(_damage: int, _dir: Vector2) -> void:
	_send_back()


## Parried as it fell: the same.
func stagger() -> void:
	_send_back()


func _send_back() -> void:
	if phase == "return":
		return
	phase = "return"
	_t = 0.0
	_life = 0.0
	velocity = Vector2(0, -RETURN_SPEED)


## Bursts into thorns. A seed struck back is spent on its bird and hurts no one else.
func _burst(harmful := true) -> void:
	if harmful:
		var p := get_tree().get_first_node_in_group("player") as Player
		if p != null and not p.dead:
			var c := p.body_rect()
			var nearest := Vector2(clampf(global_position.x, c.position.x, c.end.x), clampf(global_position.y, c.position.y, c.end.y))
			if nearest.distance_to(global_position) <= BURST_RADIUS:
				p.receive_attack(BURST_DAMAGE, self, false)
	Sfx.play("seed_burst", 0.08, -1.0)
	var d := Dust.new()
	d.setup("debris")
	get_parent().add_child(d)
	d.global_position = global_position
	Feel.add_trauma(0.12)
	queue_free()


func _draw() -> void:
	var swell := 0.0
	var blink := false
	if phase == "fuse":
		swell = _t / FUSE
		# The seams blink faster as it nears the burst.
		blink = int(_t * (8.0 + 24.0 * swell)) % 2 == 0
	if phase == "fuse" and swell > 0.5:
		# The burst's reach, faintly, so it reads before it goes off.
		draw_arc(Vector2.ZERO, BURST_RADIUS, 0.0, TAU, 24, Color(HOT, 0.12 + 0.2 * (swell - 0.5)), 1.0)
	var rx := RADIUS + 0.5 + swell * 1.5
	var ry := RADIUS + 1.0 + swell * 1.0
	draw_set_transform(Vector2.ZERO, _t * 14.0 if phase == "return" else 0.0, Vector2(rx, ry) / RADIUS)
	# Thorns, a dark outline, the husk and its seams.
	for i in 6:
		var a := TAU * i / 6.0 + 0.5
		draw_line(Vector2.from_angle(a) * RADIUS, Vector2.from_angle(a) * (RADIUS + 2.0), OUTLINE, 1.0)
	draw_circle(Vector2.ZERO, RADIUS + 0.5, OUTLINE)
	draw_circle(Vector2.ZERO, RADIUS, HUSK)
	draw_circle(Vector2(1, 1), RADIUS * 0.55, HUSK_DARK)
	var seam := HOT if blink else (SEAM if phase != "fall" else HUSK_DARK)
	draw_line(Vector2(-1.5, -RADIUS + 0.5), Vector2(-1.0, RADIUS - 0.5), seam, 1.0)
	draw_line(Vector2(1.5, -RADIUS + 0.5), Vector2(1.0, RADIUS - 0.5), seam, 1.0)
	draw_set_transform(Vector2.ZERO)
