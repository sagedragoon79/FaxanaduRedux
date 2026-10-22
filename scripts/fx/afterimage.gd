class_name Afterimage
extends Node2D
## A fading ghost of the player left behind during a dash.

const LIFE := 0.22
const TINT := Color("7fe0a0")

var _pose := "dash"
var _life := LIFE


func setup(p: Player) -> void:
	global_position = p.global_position
	scale = Vector2(p.facing, 1)
	_pose = PlayerVisual.current_pose(p)
	z_index = -1


func _physics_process(delta: float) -> void:
	_life -= delta
	if _life <= 0.0:
		queue_free()
	queue_redraw()


func _draw() -> void:
	PlayerVisual.draw_body(self, _pose, 0.0, Color(TINT, 0.55 * _life / LIFE), true)
