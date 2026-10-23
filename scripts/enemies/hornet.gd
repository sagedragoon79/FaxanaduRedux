class_name Hornet
extends Enemy
## A Trunk Hollows hornet. Hovers, buzzes in place (telegraph), then swoops at
## where you were, and flies back to its post.

const SIGHT := 180.0
const WINDUP := 0.45
const SWOOP_SPEED := 280.0
const SWOOP_TIME := 0.55
const RETURN_SPEED := 110.0
const COOLDOWN := 0.8


var _dir := Vector2.ZERO
var _cooldown := 0.0


func _init() -> void:
	max_hp = 16
	gold_min = 2
	gold_max = 4
	xp = 5
	body_size = Vector2(16, 12)
	body_centered = true
	uses_gravity = false
	knockback = 180.0


func _think(delta: float) -> void:
	_cooldown -= delta
	var off := player_offset()
	match state:
		"idle":
			var t := Time.get_ticks_msec() * 0.001
			var target := home + Vector2(sin(t * 1.3) * 18.0, sin(t * 2.6) * 6.0)
			velocity = (target - global_position) * 4.0
			if _cooldown <= 0.0 and off.length() < SIGHT:
				face_player()
				velocity = Vector2.ZERO
				set_state("windup")
				Sfx.play("buzz", 0.1, -6.0)
		"windup":
			velocity = Vector2.ZERO
			face_player()
			if state_time >= WINDUP:
				_dir = player_offset().normalized() if player_offset().x != INF else Vector2(facing, 0)
				set_state("swoop")
		"swoop":
			velocity = _dir * SWOOP_SPEED
			if state_time >= SWOOP_TIME or get_slide_collision_count() > 0:
				set_state("return")
		"return":
			var d := home - global_position
			velocity = d.normalized() * RETURN_SPEED
			if d.length() < 6.0 or state_time > 2.5:
				_cooldown = COOLDOWN
				set_state("idle")
		_:
			set_state("return")


func _draw() -> void:
	var white := flashing() or (state == "windup" and telegraph_pulse())
	var jitter := Vector2(randf_range(-1, 1), 0).round() if state == "windup" else Vector2.ZERO
	var anim := "fly"
	if state == "windup":
		anim = "windup"
	elif state == "swoop":
		anim = "swoop"
	draw_sheet("hornet", anim, Time.get_ticks_msec() * 0.001, white, jitter)
