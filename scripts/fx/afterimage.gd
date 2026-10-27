class_name Afterimage
extends Node2D
## A fading ghost of the player left behind during a dash.

const LIFE := 0.22
const TINT := Color("7fe0a0")

var _sheet := PlayerVisual.SHEET_NAME
var _anim := "dash"
var _frame := 0
var _life := LIFE


func setup(p: Player) -> void:
	global_position = p.global_position
	scale = Vector2(p.facing, 1)
	_sheet = p.visual.sheet
	_anim = p.visual.anim
	_frame = p.visual.frame
	z_index = -1


func _physics_process(delta: float) -> void:
	_life -= delta
	if _life <= 0.0:
		queue_free()
	queue_redraw()


func _draw() -> void:
	Sheet.draw(self, _sheet, _anim, _frame, Color(TINT, 0.55 * _life / LIFE), true)
