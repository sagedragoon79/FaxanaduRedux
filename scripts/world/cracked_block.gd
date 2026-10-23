class_name CrackedBlock
extends StaticBody2D
## Cracked stone that the Mattock breaks. Rebuilds itself in the gym so the
## test routes stay repeatable.

const RESPAWN_TIME := 4.0
const STONE := Color("6b6380")
const CRACK := Color("2a2538")
const HIGHLIGHT := Color("8d84a3")

@export var respawns := true
## When set, breaking the block is remembered in GameState (it stays broken).
var persist_id := ""

var _broken := false
var _timer := 0.0
var _shape: CollisionShape2D


func _ready() -> void:
	collision_layer = Player.LAYER_WORLD
	collision_mask = 0
	add_to_group("breakable")
	_shape = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 16)
	_shape.shape = rect
	add_child(_shape)


func break_block() -> void:
	if _broken:
		return
	_broken = true
	_timer = RESPAWN_TIME
	if persist_id != "":
		GameState.collect(persist_id)
	_shape.set_deferred("disabled", true)
	visible = false
	var d := Dust.new()
	d.setup("debris")
	get_parent().add_child(d)
	d.global_position = global_position
	Sfx.play("break")
	Feel.hitstop(0.06)
	Feel.add_trauma(0.2)


func _physics_process(delta: float) -> void:
	if not _broken or not respawns:
		return
	_timer -= delta
	if _timer <= 0.0 and not _player_inside():
		_broken = false
		_shape.set_deferred("disabled", false)
		visible = true


func _player_inside() -> bool:
	var p := get_tree().get_first_node_in_group("player") as Node2D
	if p == null:
		return false
	return absf(p.global_position.x - global_position.x) < 16.0 and p.global_position.y > global_position.y - 8.0 and p.global_position.y - 40.0 < global_position.y + 8.0


func _draw() -> void:
	draw_rect(Rect2(-8, -8, 16, 16), STONE)
	draw_rect(Rect2(-8, -8, 16, 2), HIGHLIGHT)
	draw_line(Vector2(-6, -5), Vector2(-1, 0), CRACK, 1.0)
	draw_line(Vector2(-1, 0), Vector2(-3, 6), CRACK, 1.0)
	draw_line(Vector2(-1, 0), Vector2(5, -3), CRACK, 1.0)
	draw_line(Vector2(5, -3), Vector2(6, 4), CRACK, 1.0)
