class_name Monodron
extends Enemy
## One-eyed hopper from the Trunk Hollows. Crouches (telegraph), then hops at you.

const SIGHT := Vector2(170, 90)
const WINDUP := 0.4
const HOP := Vector2(130, 300)
const REST := 0.7

const SKIN := Color("6c4f8f")
const SKIN_DARK := Color("4a3566")
const BELLY := Color("9c7fc0")
const EYE_WHITE := Color("f1ead2")
const PUPIL := Color("c3343f")
const OUTLINE := Color("1d1a2b")


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
	var squash := 0.0
	if state == "windup":
		squash = 3.0
	elif state == "hop":
		squash = -2.0
	var h := 16.0 - squash
	var w := 18.0 + squash
	var top := -h
	draw_rect(Rect2(-w * 0.5 - 1, top - 1, w + 2, h + 1), OUTLINE)
	draw_rect(Rect2(-w * 0.5, top, w, h), Color.WHITE if white else SKIN)
	if not white:
		draw_rect(Rect2(-w * 0.5, -4, w, 4), SKIN_DARK)
		draw_rect(Rect2(-w * 0.5 + 3, top + h * 0.55, w - 6, 3), BELLY)
	# The single eye looks at the player.
	var look := player_offset()
	var pupil_off := Vector2(clampf(look.x * 0.05, -2, 2), clampf(look.y * 0.05, -2, 2)) if look.x != INF else Vector2.ZERO
	var eye_c := Vector2(0, top + 6)
	draw_rect(Rect2(eye_c - Vector2(4, 3), Vector2(8, 6)), EYE_WHITE)
	draw_rect(Rect2((eye_c + pupil_off - Vector2(1, 1)).round(), Vector2(3, 3)), PUPIL)
	# Feet.
	draw_rect(Rect2(-w * 0.5 + 2, -2, 4, 2), OUTLINE)
	draw_rect(Rect2(w * 0.5 - 6, -2, 4, 2), OUTLINE)
