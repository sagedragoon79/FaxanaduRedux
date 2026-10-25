class_name PlayerVisual
extends Node2D
## The elf's sprite: plays the sheet (tools/art/spritegen.py with the Autosprite
## clips from art/autosprite/, assets/sprites/player.*) and draws the shield,
## and the blade and potion where the frame does not already show them, from
## each frame's hand point. Handles squash and stretch, facing and hurt
## blinking. Origin is at the feet.

const SHEET_NAME := "player"
const SHEET := "res://assets/sprites/player.png"

const OUTLINE := Color("120f19")
const STEEL := Color("cec5d3")
const STEEL_EDGE := Color("ece8ed")
const STEEL_DARK := Color("867ba2")
const HILT := Color("cb8d16")
const SHIELD := Color("aa6336")
const SHIELD_BOSS := Color("cec5d3")
const POTION := Color("c02a20")
const GLASS := Color("e68c75")
const OINTMENT := Color("f0c02e")
const POISON := Color("8fd14f")
## Blade length in pixels before the weapon's reach bonus.
const BLADE_LENGTH := 11.0
## Animations that hold on until they finish even when the action behind them
## ends (the recovery frames of a swing).
const FINISH := ["slash1", "slash2", "slash3", "slash_up", "cast"]
## Poses an unfinished swing may play over.
const OVERRIDABLE := ["idle", "run", "rise", "apex", "fall"]

## "anim:frame" holds the player in one frame (screenshots: --shot-pose).
static var forced := ""

var player: Player
var squash_scale := Vector2.ONE
var pose := "idle"
## The animation playing, its time and the frame shown.
var anim := "idle"
var anim_time := 0.0
var frame := 0

var _blink_time := 0.0
var _red_time := 0.0
var _swings := 0


## The sheet: {"cell", "origin", "columns", "animations", ...} (see Sheet).
static func data() -> Dictionary:
	return Sheet.get_sheet(SHEET_NAME)


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
	visible = player.dead or not (_blink_time > 0.0 and _red_time <= 0.0 and int(_blink_time * 20.0) % 2 == 0)
	pose = current_pose(player)
	var next := anim_for(player, pose)
	var restart := player.swing_count != _swings
	_swings = player.swing_count
	if anim in FINISH and not finished() and pose in OVERRIDABLE and not restart:
		next = anim
	if next != anim or restart:
		anim = next
		anim_time = 0.0
	var rate := 1.0
	if anim == "run":
		rate = clampf(absf(player.velocity.x) / player.tuning.run_speed, 0.4, 1.3)
	anim_time += delta * rate
	frame = frame_at(anim, anim_time)
	if forced != "":
		var parts := forced.split(":")
		anim = parts[0]
		frame = int(parts[1]) if parts.size() > 1 else 0
	queue_redraw()


static func current_pose(p: Player) -> String:
	if p.dead:
		return "death"
	if p.is_hurt:
		return "hurt"
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
	if p.is_casting:
		return "cast"
	if p.is_gliding:
		# Feather Fall: the cloak-spread hang of the apex, held.
		return "apex"
	if not p.is_on_floor():
		if absf(p.velocity.y) < 60.0:
			return "apex"
		return "rise" if p.velocity.y < 0.0 else "fall"
	if absf(p.velocity.x) > 10.0:
		return "run"
	return "idle"


## The sheet animation for a pose.
static func anim_for(p: Player, body_pose: String) -> String:
	match body_pose:
		"attack_side":
			if p.is_heavy_swing:
				return "slash3"
			return "slash2" if p.combo_index == 2 else "slash1"
		"attack_up":
			return "slash_up"
		"attack_down":
			return "strike_down"
	return body_pose


## The frame of `name` shown at time `t`.
static func frame_at(name: String, t: float) -> int:
	return Sheet.frame_at(SHEET_NAME, name, t)


func finished() -> bool:
	return Sheet.finished(SHEET_NAME, anim, anim_time)


## The current frame's metadata: hand and neck points (relative to the feet,
## facing right) and, in a swing, the blade angle.
func frame_info() -> Dictionary:
	return Sheet.info(SHEET_NAME, anim, frame)


## The neck in world space, where the scarf hangs from.
func neck_position() -> Vector2:
	var n: Array = frame_info().neck
	return global_position + Vector2(n[0] * player.facing * squash_scale.x, n[1] * squash_scale.y)


## Draws one frame of the sheet (or its flat silhouette, tinted) with the feet at the origin.
static func draw_frame(ci: CanvasItem, name: String, f: int, tint: Color, flat: bool) -> void:
	Sheet.draw(ci, SHEET_NAME, name, f, tint, flat)


func _draw() -> void:
	var tint := Color(1.0, 0.45, 0.45) if _red_time > 0.0 else Color.WHITE
	if player.poison_left > 0.0 and _red_time <= 0.0:
		# Poison: a sickly green cast that throbs with each tick.
		var t := 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.006)
		tint = Color.WHITE.lerp(POISON, 0.35 + 0.2 * t)
	draw_frame(self, anim, frame, tint, false)
	var oint := player.ointment_left
	if oint > 0.0:
		# The Ointment: a gold sheen that pulses, and flickers as it runs out.
		var a := 0.38 + 0.14 * sin(Time.get_ticks_msec() * 0.008)
		if oint < 2.0 and int(oint * 8.0) % 2 == 0:
			a *= 0.3
		draw_frame(self, anim, frame, Color(OINTMENT, a), true)
	var info := frame_info()
	var hand := Vector2(info.hand[0], info.hand[1])
	if info.has("blade"):
		_draw_blade(hand, deg_to_rad(float(info.blade)), BLADE_LENGTH + player.reach_bonus * 0.75, tint)
	if anim == "block":
		_draw_shield(hand + Vector2(2, 0), tint)
	elif anim == "drink" and not info.get("art_prop", false):
		draw_rect(Rect2(hand + Vector2(-2, -6), Vector2(4, 6)), OUTLINE)
		draw_rect(Rect2(hand + Vector2(-1, -5), Vector2(2, 4)), POTION * tint)
		draw_rect(Rect2(hand + Vector2(-1, -5), Vector2(1, 1)), GLASS * tint)


func _draw_blade(hand: Vector2, angle: float, length: float, tint: Color) -> void:
	var dir := Vector2.from_angle(angle)
	var side := dir.orthogonal()
	var base := hand + dir * 2.0
	var tip := base + dir * length
	# A broad blade (the Giant Blade's arc) is drawn two pixels thicker.
	var broad := 2.0 if player.arc_bonus > 0.0 else 0.0
	# Outline, steel with a bright edge, then the crossguard and pommel.
	draw_line(base, tip + dir, OUTLINE, 4.0 + broad)
	draw_line(base, tip, STEEL * tint, 2.0 + broad)
	draw_line(base + side * 0.5, tip + side * 0.5, STEEL_EDGE * tint, 1.0)
	draw_line(base - side * 0.5 + dir * 2.0, tip - side * 0.5 - dir, STEEL_DARK * tint, 1.0)
	draw_line(base - side * (3.0 + broad), base + side * (3.0 + broad), OUTLINE, 3.0)
	draw_line(base - side * 2.0, base + side * 2.0, HILT * tint, 1.0)
	draw_rect(Rect2((hand - dir * 2.0).round() - Vector2(1, 1), Vector2(2, 2)), HILT * tint)


func _draw_shield(at: Vector2, tint: Color) -> void:
	var r := Rect2(at + Vector2(-2, -7), Vector2(6, 14))
	draw_rect(r.grow(1.0), OUTLINE)
	draw_rect(r, SHIELD * tint)
	draw_rect(Rect2(r.position + Vector2(1, 0), Vector2(1, r.size.y)), Color(SHIELD.lightened(0.25), 1.0) * tint)
	draw_rect(Rect2(r.position + Vector2(2, 5), Vector2(2, 4)), SHIELD_BOSS * tint)
