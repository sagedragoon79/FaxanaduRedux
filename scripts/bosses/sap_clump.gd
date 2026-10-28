class_name SapClump
extends Node2D
## A clump of sap Rokusutahn shakes loose from the ceiling (phase 2). A drip
## swells on the ceiling first (the telegraph), then the clump falls. It hurts
## on contact; where it lands it hardens into a SapMound, a temporary platform.

const TELL := 0.7
const GRAVITY := 900.0
const MAX_FALL := 420.0
const SIZE := Vector2(14, 14)
const DAMAGE := 15
const SAP := Color("e0902a")
const SAP_LIGHT := Color("ffc76a")
const SHADOW := Color(0, 0, 0, 0.3)

var room: Room
var floor_y := 320.0

var _t := 0.0
var _vy := 0.0
var _falling := false


func _ready() -> void:
	z_index = 1


func _physics_process(delta: float) -> void:
	if TimeStop.active():
		return  # held still by the Hour Glass, dripping or falling
	_t += delta
	if not _falling:
		if _t >= TELL:
			_falling = true
			Sfx.play("splat", 0.1, -10.0)
		queue_redraw()
		return
	_vy = minf(_vy + GRAVITY * delta, MAX_FALL)
	var next := position + Vector2(0, _vy * delta)
	var p := get_tree().get_first_node_in_group("player") as Player
	if p != null and not p.dead and Rect2(next - SIZE * 0.5, SIZE).intersects(p.body_rect()):
		p.receive_attack(DAMAGE, self, false)
		_burst()
		return
	var land := _landing(position.y + SIZE.y * 0.5, next.y + SIZE.y * 0.5)
	if land != INF:
		var mound := SapMound.new()
		mound.position = Vector2(position.x, land)
		get_parent().add_child(mound)
		_burst()
		return
	position = next
	if room != null and position.y > room.pixel_rect().end.y:
		queue_free()
	queue_redraw()


## The top surface between this frame's and next frame's bottom edge, or INF.
func _landing(from_y: float, to_y: float) -> float:
	var top := INF
	for mound: SapMound in get_tree().get_nodes_in_group("sap_mound"):
		var r := mound.top_rect()
		if absf(mound.position.x - position.x) < r.size.x * 0.5 and r.position.y >= from_y and r.position.y <= to_y:
			top = minf(top, r.position.y)
	if room != null:
		var y := floorf(from_y / Room.TILE) * Room.TILE
		while y <= to_y:
			var probe := Vector2(position.x, y + 1)
			if y >= from_y - 1 and (room.is_solid_at(probe) or room.is_one_way_at(probe)):
				top = minf(top, y)
				break
			y += Room.TILE
	return top


func _burst() -> void:
	var d := Dust.new()
	d.setup("sap")
	get_parent().add_child(d)
	d.global_position = global_position
	Sfx.play("splat", 0.1, -4.0)
	queue_free()


func _draw() -> void:
	if not _falling:
		# A drip swelling on the ceiling, and its shadow on the floor below.
		var k := clampf(_t / TELL, 0.0, 1.0)
		draw_circle(Vector2(0, -2), 2.0 + k * 5.0, SAP)
		draw_rect(Rect2(-1, -2, 2, 2 + k * 4.0), SAP_LIGHT)
		var shadow_y := floor_y - position.y
		draw_rect(Rect2(-6 - k * 4.0, shadow_y - 2, 12 + k * 8.0, 2), Color(SHADOW, 0.1 + k * 0.3))
		return
	draw_circle(Vector2.ZERO, 7.0, Color("1d1a2b"))
	draw_circle(Vector2.ZERO, 6.0, SAP)
	draw_circle(Vector2(-2, -2), 2.0, SAP_LIGHT)
	draw_rect(Rect2(-1, -12, 2, 6), Color(SAP, 0.5))
