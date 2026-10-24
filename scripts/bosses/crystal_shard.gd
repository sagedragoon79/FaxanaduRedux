class_name CrystalShard
extends Node2D
## A shard of meteor crystal King Grieve calls up out of his throne-hall floor
## (design bible 8.7). It glows on the floor for GLOW seconds (the telegraph),
## then shoots up to the vault, burning what it passes through. The Hour Glass
## holds it in the air, and while it is held its flat top is a foothold: a
## string of them, frozen in time, is a stair up to the king's crown. When time
## runs again a held shard cracks and falls to pieces. The origin is the
## shard's centre.

const SPEED := 140.0
const GLOW := 0.4
const DAMAGE := 12
const SIZE := Vector2(20, 10)
const CRYSTAL := Color("e05ad0")
const CRYSTAL_LIGHT := Color("ffb8f0")
const CRYSTAL_DARK := Color("7a2a78")
const FROZEN := Color("d8c8f8")
const OUTLINE := Color("1a0f1f")

## Seconds before it starts to glow.
var delay := 0.0
## Where it shatters against the vault (px).
var ceiling_y := 64.0
var state := "wait"
var _t := 0.0
var _was_held := false
var _body: StaticBody2D
var _shape: CollisionShape2D


func _ready() -> void:
	z_index = 2
	add_to_group("enemy_projectile")
	_body = StaticBody2D.new()
	_body.collision_layer = Player.LAYER_WORLD
	_body.collision_mask = 0
	add_child(_body)
	_shape = CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(SIZE.x + 2.0, 4.0)
	_shape.shape = r
	_shape.one_way_collision = true
	_shape.position = Vector2(0, -SIZE.y * 0.5 + 2.0)
	_shape.disabled = true
	_body.add_child(_shape)


func hit_rect() -> Rect2:
	return Rect2(global_position - SIZE * 0.5, SIZE)


## True while the Hour Glass holds it in the air as a foothold.
func held() -> bool:
	return state == "rise" and TimeStop.active()


func _physics_process(delta: float) -> void:
	if TimeStop.active():
		if state == "rise" and not _was_held:
			_was_held = true
			_shape.set_deferred("disabled", false)
		queue_redraw()
		return
	if _was_held:
		# Time runs again: a held shard cracks and falls to pieces.
		_shatter()
		return
	_t += delta
	match state:
		"wait":
			if _t >= delay:
				_t = 0.0
				state = "glow"
		"glow":
			if _t >= GLOW:
				_t = 0.0
				state = "rise"
				Sfx.play("thorn", 0.15, -6.0)
		"rise":
			global_position.y -= SPEED * delta
			var p := get_tree().get_first_node_in_group("player") as Player
			if p != null and not p.dead and hit_rect().intersects(p.body_rect()):
				p.receive_attack(DAMAGE, self, false)
			if global_position.y - SIZE.y * 0.5 <= ceiling_y:
				_shatter()
				return
	queue_redraw()


func _shatter() -> void:
	var d := Dust.new()
	d.setup("debris")
	get_parent().add_child(d)
	d.global_position = global_position
	queue_free()


func _draw() -> void:
	match state:
		"wait":
			return
		"glow":
			# A crack of light in the floor where it will burst out.
			var k := 0.5 + 0.5 * absf(sin(_t * 22.0))
			draw_rect(Rect2(-SIZE.x * 0.5, SIZE.y * 0.5 - 2.0, SIZE.x, 2.0), Color(CRYSTAL_LIGHT, 0.5 + 0.5 * k))
			draw_rect(Rect2(-3.0, SIZE.y * 0.5 - 6.0 * k, 6.0, 6.0 * k), Color(CRYSTAL, 0.6 * k))
			return
	var body := FROZEN if TimeStop.active() else CRYSTAL
	var hx := SIZE.x * 0.5
	var hy := SIZE.y * 0.5
	# A flat-topped crystal with a point beneath, so the top reads as a step.
	draw_rect(Rect2(-hx - 1.0, -hy - 1.0, SIZE.x + 2.0, 6.0), OUTLINE)
	draw_rect(Rect2(-hx, -hy, SIZE.x, 4.0), body)
	draw_rect(Rect2(-hx, -hy, SIZE.x, 1.0), CRYSTAL_LIGHT)
	draw_colored_polygon(PackedVector2Array([Vector2(-hx - 1.0, -hy + 4.0), Vector2(hx + 1.0, -hy + 4.0), Vector2(0, hy + 3.0)]), OUTLINE)
	draw_colored_polygon(PackedVector2Array([Vector2(-hx + 1.0, -hy + 4.0), Vector2(hx - 1.0, -hy + 4.0), Vector2(0, hy + 1.0)]), CRYSTAL_DARK if not TimeStop.active() else Color(FROZEN, 0.7))
	draw_rect(Rect2(-2.0, -hy + 4.0, 2.0, 5.0), Color(CRYSTAL_LIGHT, 0.6))
	if TimeStop.active():
		draw_rect(Rect2(-hx, -hy - 2.0, SIZE.x, 1.0), Color(1, 1, 1, 0.8))
