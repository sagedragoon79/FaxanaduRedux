class_name Monodron
extends Enemy
## One-eyed hopper from the Trunk Hollows. Crouches (telegraph), then hops at you.

const SIGHT := Vector2(170, 90)
const WINDUP := 0.4
const HOP := Vector2(130, 300)
const REST := 0.7

const PUPIL := Color("861d25")


func _init() -> void:
	max_hp = 24
	gold_min = 3
	gold_max = 6
	xp = 5
	body_size = Vector2(18, 16)


func _think(_delta: float) -> void:
	var off := player_offset()
	match state:
		"idle":
			velocity.x = 0.0
			if absf(off.x) < SIGHT.x and absf(off.y) < SIGHT.y and is_on_floor():
				face_player()
				set_state("windup")
				Sfx.play("swell", 0.12, -8.0)
		"windup":
			velocity.x = 0.0
			if state_time >= WINDUP:
				velocity = Vector2(facing * HOP.x, -HOP.y)
				Sfx.play("hop", 0.1, -4.0)
				set_state("hop")
		"hop":
			if is_on_floor() and state_time > 0.1:
				velocity.x = 0.0
				set_state("rest")
		"rest":
			velocity.x = 0.0
			if state_time >= REST:
				set_state("idle")
		_:
			set_state("idle")


func _draw() -> void:
	var white := flashing() or (state == "windup" and telegraph_pulse())
	var anim := "idle"
	var t := Time.get_ticks_msec() * 0.001
	if state in ["windup", "hop"]:
		anim = state
		t = state_time
	var f := draw_sheet("monodron", anim, t, white)
	if white:
		return
	# The single eye follows the player.
	var e: Array = Sheet.info("monodron", anim, f).eye
	var look := player_offset()
	var pupil_off := Vector2(clampf(look.x * 0.05, -2, 2), clampf(look.y * 0.05, -1.5, 1.5)) if look.x != INF else Vector2.ZERO
	var eye_c := Vector2(e[0] * facing, e[1])
	draw_rect(Rect2((eye_c + pupil_off - Vector2(1, 1)).round(), Vector2(2, 2)), PUPIL)
