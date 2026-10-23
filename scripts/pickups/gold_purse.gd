class_name GoldPurse
extends Node2D
## The gold you drop on death. Touch it to get it back; die again first and it's gone.

const GLOW := Color("ffe27a")
const BAG := Color("8a5a34")
const BAG_DARK := Color("5e3b22")
const TIE := Color("ffd24a")

var value := 0

var _t := 0.0


func _ready() -> void:
	z_index = 1
	add_to_group("purse")


func _physics_process(delta: float) -> void:
	_t += delta
	var p := get_tree().get_first_node_in_group("player") as Player
	if p != null and not p.dead and p.body_rect().grow(4.0).has_point(global_position + Vector2(0, -6)):
		p.add_gold(value)
		Sfx.play("coin", 0.0, 2.0)
		var d := Dust.new()
		d.setup("parry")
		get_parent().add_child(d)
		d.global_position = global_position + Vector2(0, -6)
		if p.purse == self:
			p.purse = null
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var bob := roundf(sin(_t * 3.0) * 2.0)
	draw_circle(Vector2(0, -6 + bob), 10.0 + sin(_t * 4.0), Color(GLOW, 0.18))
	draw_rect(Rect2(-5, -10 + bob, 10, 9), BAG_DARK)
	draw_rect(Rect2(-4, -9 + bob, 8, 7), BAG)
	draw_rect(Rect2(-2, -12 + bob, 4, 2), TIE)
