class_name PlayerVisual
extends Node2D
## Placeholder elf drawn from pixel rectangles until the Autosprite art lands.
## Handles squash and stretch, facing and hurt blinking. Origin is at the feet.

const OUTLINE := Color("1d1a2b")
const TUNIC := Color("3f7d3a")
const TUNIC_DARK := Color("2b5a2c")
const LEATHER := Color("6b4a2b")
const BOOTS := Color("4a3020")
const SKIN := Color("e8c39e")
const HAIR := Color("e8d27c")
const EYE := Color("1d1a2b")
const SHIELD := Color("8a6a44")
const SHIELD_BOSS := Color("c9c4d6")
const POTION := Color("e0404a")

var player: Player
var squash_scale := Vector2.ONE
var pose := "idle"

var _blink_time := 0.0
var _red_time := 0.0
var _anim_time := 0.0


func squash(amount: Vector2) -> void:
	squash_scale = amount


func flash_hurt() -> void:
	_blink_time = player.tuning.hurt_invuln
	_red_time = 0.12


func _physics_process(delta: float) -> void:
	squash_scale = squash_scale.lerp(Vector2.ONE, 1.0 - exp(-delta * 16.0))
	scale = Vector2(player.facing * squash_scale.x, squash_scale.y)
	_blink_time -= delta
	_red_time -= delta
	visible = not player.dead and not (_blink_time > 0.0 and _red_time <= 0.0 and int(_blink_time * 20.0) % 2 == 0)
	pose = current_pose(player)
	_anim_time += delta * (absf(player.velocity.x) / 165.0 * 10.0 if pose == "run" else 3.0)
	queue_redraw()


static func current_pose(p: Player) -> String:
	if p.is_dashing:
		return "dash"
	if p.is_wall_sliding:
		return "wall"
	if p.is_attacking:
		return "attack_" + p.attack_kind
	if p.is_drinking:
		return "drink"
	if p.is_blocking:
		return "block"
	if not p.is_on_floor():
		return "rise" if p.velocity.y < 0.0 else "fall"
	if absf(p.velocity.x) > 10.0:
		return "run"
	return "idle"


func _draw() -> void:
	var tint := Color(1.0, 0.35, 0.35) if _red_time > 0.0 else Color.WHITE
	draw_body(self, pose, _anim_time, tint, false)
	if pose == "block":
		# Small Shield held in front.
		draw_rect(Rect2(5, -32, 6, 14), OUTLINE)
		draw_rect(Rect2(6, -31, 4, 12), SHIELD * tint)
		draw_rect(Rect2(7, -28, 2, 6), SHIELD_BOSS * tint)
	elif pose == "drink":
		draw_rect(Rect2(3, -38, 4, 6), OUTLINE)
		draw_rect(Rect2(4, -37, 2, 4), POTION)


## Draws the figure facing right. `flat` paints everything one tint (afterimages).
static func draw_body(ci: CanvasItem, body_pose: String, t: float, tint: Color, flat: bool) -> void:
	var parts: Array = []  # [Rect2, Color]
	var leg_a := 0
	var leg_b := 0
	var lean := 0
	var arm_up := false
	match body_pose:
		"run":
			leg_a = int(round(sin(t) * 3.0))
			leg_b = -leg_a
		"rise":
			leg_a = -3
			leg_b = 1
		"fall":
			leg_a = 2
			leg_b = -1
		"dash":
			lean = 2
			leg_a = -3
			leg_b = 3
		"wall":
			leg_a = -2
			arm_up = true
		"attack_up", "drink":
			arm_up = true
	var bob := 0 if body_pose != "idle" else int(round(sin(t) * 0.6))
	# Legs and boots.
	parts.append([Rect2(-5 + leg_a, -16, 4, 10), LEATHER])
	parts.append([Rect2(1 + leg_b, -16, 4, 10), LEATHER])
	parts.append([Rect2(-6 + leg_a, -6, 5, 6), BOOTS])
	parts.append([Rect2(1 + leg_b, -6, 5, 6), BOOTS])
	# Tunic and belt.
	parts.append([Rect2(-6 + lean, -31 + bob, 12, 16), TUNIC])
	parts.append([Rect2(-6 + lean, -18 + bob, 12, 2), LEATHER])
	# Head, hair and the elf ear.
	parts.append([Rect2(-4 + lean, -41 + bob, 10, 10), SKIN])
	parts.append([Rect2(-6 + lean, -43 + bob, 12, 4), HAIR])
	parts.append([Rect2(-6 + lean, -40 + bob, 3, 8), HAIR])
	parts.append([Rect2(-8 + lean, -37 + bob, 3, 2), SKIN])
	parts.append([Rect2(3 + lean, -37 + bob, 2, 2), EYE])
	# Front arm.
	if arm_up:
		parts.append([Rect2(1 + lean, -38 + bob, 3, 9), TUNIC_DARK])
	else:
		parts.append([Rect2(0 + lean, -29 + bob, 3, 10), TUNIC_DARK])

	for part: Array in parts:
		var r: Rect2 = part[0]
		ci.draw_rect(r.grow(1.0), OUTLINE * tint if not flat else Color(tint, tint.a * 0.6))
	for part: Array in parts:
		var c: Color = part[1]
		ci.draw_rect(part[0], tint if flat else c * tint)
