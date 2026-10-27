class_name TrialGoal
extends Node2D
## The bell at the end of a Guru Trial (design bible 3.1; `prop: x, y, trial_goal`).
## It runs the trial's clock while you are in the room, and touching it clears
## the trial: it rings, shows your time, and the mantra carries you back to the
## Guru. A pale bell on a thin frame, drawn in the mantra-space's greys, with a
## slow glow so it reads across the room.

## How close (px) the middle of the player's body must come.
const REACH := 16.0
## Seconds the bell rings before the mantra carries you back.
const RING := 1.2
const PALE := Color("e8e4dc")
const MID := Color("a8a49c")
const DARK := Color("3a3836")

var rung := false
var _t := 0.0
var _ring_t := 0.0


func _ready() -> void:
	add_to_group("trial_goal")


func _physics_process(delta: float) -> void:
	_t += delta
	if rung:
		_ring_t += delta
		if _ring_t >= RING:
			set_physics_process(false)
			_return()
		queue_redraw()
		return
	Trials.tick(delta)
	var p := get_tree().get_first_node_in_group("player") as Player
	if p != null and not p.dead and p.body_rect().get_center().distance_to(global_position + Vector2(0, -20)) <= REACH + 8.0:
		ring(p)
	queue_redraw()


func ring(p: Player) -> void:
	if rung:
		return
	rung = true
	var result := Trials.finish()
	Sfx.play("trial_bell", 0.0)
	GameState.flash.emit(0.25)
	Feel.rumble(0.3, 0.0, 0.1)
	if not result.is_empty():
		var line := "Trial cleared: %s" % Trials.format_time(result.time)
		if result.record and not result.first:
			line += ". A new best!"
		elif not result.record:
			line += ". Best %s." % Trials.format_time(result.best)
		if result.first:
			line += " A Mantra Shard rings out of the bell."
		if result.dye != "":
			line += " Within the mantra: your cloak takes %s." % GameData.item(result.dye).name
			Sfx.play("dye_won", 0.0)
		GameState.toast.emit(line)
		if result.record and not result.first:
			Sfx.play("trial_record", 0.0)
	if p != null:
		p.velocity = Vector2.ZERO


## Back a step from the Guru, where the trial began.
func _return() -> void:
	var back_room := Trials.TEMPLE
	var back_pos := Vector2.INF
	if Trials.active():
		back_room = Trials.run.back_room
		back_pos = Trials.run.back_pos
	Trials.abandon()
	var world := get_tree().get_first_node_in_group("world") as World
	if world != null and back_pos != Vector2.INF:
		world.travel(back_room, back_pos)


func _draw() -> void:
	var glow := 0.5 + 0.5 * sin(_t * 2.0)
	var swing := sin(_ring_t * 18.0) * 0.25 * (1.0 - _ring_t / RING) if rung else 0.0
	draw_circle(Vector2(0, -22), 18.0 + glow * 3.0, Color(PALE, 0.10 + 0.06 * glow + (0.3 if rung else 0.0)))
	# The frame: a stone step, two posts and a beam, outlined so it reads on the void.
	draw_rect(Rect2(-16, -4, 32, 4), DARK)
	draw_rect(Rect2(-15, -3, 30, 2), MID)
	for x: float in [-13.0, 10.0]:
		draw_rect(Rect2(x - 1, -43, 5, 40), DARK)
		draw_rect(Rect2(x, -42, 3, 38), MID)
	draw_rect(Rect2(-16, -45, 32, 5), DARK)
	draw_rect(Rect2(-15, -44, 30, 3), PALE)
	# The bell hangs from the beam and swings when struck.
	var top := Vector2(0, -39)
	var pts := PackedVector2Array()
	for v: Vector2 in [Vector2(-3, 0), Vector2(3, 0), Vector2(6, 9), Vector2(9, 16), Vector2(-9, 16), Vector2(-6, 9)]:
		pts.append(top + v.rotated(swing))
	draw_colored_polygon(pts, PALE)
	draw_polyline(pts + PackedVector2Array([pts[0]]), DARK, 1.0)
	draw_circle(top + Vector2(0, 18).rotated(swing), 2.0, MID)
