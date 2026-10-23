class_name ItemPickup
extends Node2D
## A permanent item lying in the world: an ability, Life Fruit, Mana Dew, a
## Potion Shard or a Mantra Shard. Touch it to take it; it never comes back.

const KIND_BY_CHAR := {
	"G": "glove",
	"L": "life_fruit",
	"W": "mana_dew",
	"F": "potion_shard",
	"*": "mantra_shard",
}

const INFO := {
	"glove": {"title": "Climbing Glove", "text": "Slide down walls. Jump to leap off them.", "color": Color("c08a5a")},
	"life_fruit": {"title": "Life Fruit", "text": "", "color": Color("e0404a")},
	"mana_dew": {"title": "Mana Dew", "text": "", "color": Color("4aa3df")},
	"potion_shard": {"title": "Potion Shard", "text": "", "color": Color("ff6a6a")},
	"mantra_shard": {"title": "Mantra Shard", "text": "", "color": Color("b58cff")},
}

var kind := "life_fruit"
var pickup_id := ""

var _t := 0.0


func _ready() -> void:
	z_index = 1


func _physics_process(delta: float) -> void:
	_t += delta
	var p := get_tree().get_first_node_in_group("player") as Player
	if p != null and not p.dead and not p.frozen and p.body_rect().grow(4.0).has_point(global_position):
		grant(p)
		return
	queue_redraw()


func grant(p: Player) -> void:
	var info: Dictionary = INFO[kind]
	var subtitle: String = info.text
	if kind == "glove":
		p.abilities["glove"] = true
	else:
		subtitle = GameState.grant_stat_item(kind, p)
	if pickup_id != "":
		GameState.collect(pickup_id)
	GameState.capture(p)
	GameState.banner.emit(info.title, subtitle)
	Sfx.play("item", 0.0)
	Feel.hitstop(0.12)
	var d := Dust.new()
	d.setup("parry")
	get_parent().add_child(d)
	d.global_position = global_position
	queue_free()


func _draw() -> void:
	var bob := roundf(sin(_t * 2.5) * 2.0)
	var c: Color = INFO[kind].color
	draw_circle(Vector2(0, bob), 11.0 + sin(_t * 4.0), Color(c, 0.15))
	var o := Vector2(0, bob)
	var dark := c.darkened(0.45)
	match kind:
		"glove":
			draw_rect(Rect2(o + Vector2(-5, -3), Vector2(10, 9)), dark)
			draw_rect(Rect2(o + Vector2(-4, -2), Vector2(8, 7)), c)
			for i in 4:
				draw_rect(Rect2(o + Vector2(-5 + i * 3, -7), Vector2(2, 5)), c if i > 0 else dark)
			draw_rect(Rect2(o + Vector2(-6, 0), Vector2(2, 4)), c)
			draw_rect(Rect2(o + Vector2(-4, 4), Vector2(8, 2)), Color("ffd24a"))
		"life_fruit":
			draw_circle(o + Vector2(0, 1), 6.0, dark)
			draw_circle(o + Vector2(0, 1), 5.0, c)
			draw_rect(Rect2(o + Vector2(-2, -2), Vector2(2, 2)), Color("ffc0c0"))
			draw_rect(Rect2(o + Vector2(0, -7), Vector2(1, 3)), Color("5e3b22"))
			draw_rect(Rect2(o + Vector2(1, -7), Vector2(3, 2)), Color("5f8a4a"))
		"mana_dew":
			draw_colored_polygon(PackedVector2Array([o + Vector2(0, -8), o + Vector2(5, 1), o + Vector2(0, 6), o + Vector2(-5, 1)]), dark)
			draw_circle(o + Vector2(0, 1), 4.0, c)
			draw_colored_polygon(PackedVector2Array([o + Vector2(0, -6), o + Vector2(3, 0), o + Vector2(-3, 0)]), c)
			draw_rect(Rect2(o + Vector2(-2, 0), Vector2(1, 2)), Color("d6f0ff"))
		"potion_shard":
			draw_colored_polygon(PackedVector2Array([o + Vector2(-2, -7), o + Vector2(4, -3), o + Vector2(2, 6), o + Vector2(-4, 3)]), dark)
			draw_colored_polygon(PackedVector2Array([o + Vector2(-1, -5), o + Vector2(3, -2), o + Vector2(1, 4), o + Vector2(-3, 2)]), c)
		"mantra_shard":
			var spin := sin(_t * 3.0) * 3.0
			draw_colored_polygon(PackedVector2Array([o + Vector2(0, -8), o + Vector2(spin + 1, 0), o + Vector2(0, 8), o + Vector2(-spin - 1, 0)]), c)
			draw_rect(Rect2(o + Vector2(-1, -3), Vector2(1, 3)), Color("efe4ff"))
