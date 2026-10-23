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


## Drawn at 2x render density: _hp() and the polygons take half-pixels.
func _draw() -> void:
	var bob := roundf(sin(_t * 2.5) * 4.0) * 0.5
	var c: Color = INFO[kind].color
	var o := Vector2(0, bob)
	var dark := c.darkened(0.45)
	var light := c.lightened(0.45)
	# A soft halo and two twinkles orbiting it.
	draw_circle(o, 11.0 + sin(_t * 4.0), Color(c, 0.12))
	draw_circle(o, 7.5 + sin(_t * 4.0) * 0.5, Color(c, 0.1))
	for i in 2:
		var a := _t * 1.6 + i * PI
		var tw := o + Vector2(cos(a) * 10.0, sin(a) * 5.0 - 1.0)
		var k := 0.5 + 0.5 * sin(_t * 6.0 + i * 2.0)
		_hp(tw, -1, -3, 2, 6, Color(light, k))
		_hp(tw, -3, -1, 6, 2, Color(light, k))
	match kind:
		"glove":
			# A leather climbing gauntlet: four fingers, a thumb, a gold cuff, stitching.
			_poly(o, [Vector2(-10, -2), Vector2(10, -2), Vector2(10, 12), Vector2(-10, 12)], dark, 2.0)
			for i in 4:
				_hp(o, -10 + i * 5, -14 + (2 if i == 0 or i == 3 else 0), 5, 14, Color("120f19"))
				_hp(o, -9 + i * 5, -13 + (2 if i == 0 or i == 3 else 0), 3, 13, c)
				_hp(o, -9 + i * 5, -13 + (2 if i == 0 or i == 3 else 0), 1, 9, light)
			_hp(o, -9, -2, 18, 13, c)
			_hp(o, -9, 2, 18, 1, dark)
			_hp(o, -15, 0, 6, 9, Color("120f19"))
			_hp(o, -14, 1, 5, 7, c)
			_hp(o, -14, 1, 2, 5, light)
			_hp(o, -11, 10, 22, 6, Color("120f19"))
			_hp(o, -10, 11, 20, 4, Color("ffd24a"))
			_hp(o, -10, 11, 20, 1, Color("fff4c0"))
			_hp(o, -10, 14, 20, 1, Color("b8860b"))
			for i in 4:
				_hp(o, -7 + i * 4, 6, 2, 1, dark)
		"life_fruit":
			# A red fruit of the Tree: shaded crescent, highlight, stem and leaf.
			var f := o + Vector2(0, 1)
			draw_circle(f, 6.5, Color("120f19"))
			draw_circle(f, 5.5, dark)
			draw_circle(f + Vector2(-0.5, -0.5), 4.8, c)
			draw_circle(f + Vector2(-1.5, -1.5), 2.6, c.lightened(0.15))
			_hp(f, -5, -6, 3, 2, Color("ffd0d0"))
			_hp(f, -6, -4, 2, 3, Color("ffd0d0"))
			_hp(f, 5, 5, 3, 2, Color(dark.darkened(0.3), 0.8))
			_hp(f, -1, -16, 2, 6, Color("5e3b22"))
			_poly(f, [Vector2(1, -15), Vector2(6, -18), Vector2(11, -16), Vector2(6, -12)], Color("3f6a32"), 1.5)
			_poly(f, [Vector2(1, -15), Vector2(6, -18), Vector2(11, -16), Vector2(6, -12)], Color("5f8a4a"))
			_hp(f, 3, -15, 6, 1, Color("8fbf6a"))
		"mana_dew":
			# A drop of the Tree's dew: three tones and a bright glint.
			var drop := [Vector2(0, -16), Vector2(5, -6), Vector2(9, 2), Vector2(8, 8), Vector2(4, 12), Vector2(-4, 12), Vector2(-8, 8), Vector2(-9, 2), Vector2(-5, -6)]
			_poly(o, drop, Color("120f19"), 2.0)
			_poly(o, drop, dark)
			_poly(o + Vector2(-0.5, -0.5), drop, c, -2.0)
			_poly(o + Vector2(-1.5, -0.5), [Vector2(0, -10), Vector2(3, -3), Vector2(4, 4), Vector2(-4, 4), Vector2(-3, -3)], light)
			_hp(o, -5, 0, 2, 5, Color("e8f8ff"))
			_hp(o, -3, -6, 2, 3, Color("e8f8ff"))
		"potion_shard":
			# A curved shard of a Red Potion flask, a bead of potion still in it.
			var shard := [Vector2(-4, -15), Vector2(7, -7), Vector2(5, 11), Vector2(-2, 13), Vector2(-8, 5)]
			_poly(o, shard, Color("120f19"), 2.0)
			_poly(o, shard, Color("c9c4d6"))
			_poly(o + Vector2(0.5, 1), [Vector2(-5, 0), Vector2(5, -2), Vector2(4, 9), Vector2(-2, 11), Vector2(-6, 5)], c)
			_poly(o + Vector2(0.5, 1), [Vector2(-5, 0), Vector2(5, -2), Vector2(4, 1), Vector2(-5, 3)], light)
			_hp(o, -4, -12, 2, 8, Color("f7f1de"))
			_hp(o, 3, 6, 2, 3, dark)
		"mantra_shard":
			# A violet crystal turning slowly: the lit facet sweeps across it.
			var spin := sin(_t * 3.0)
			var wx := 6.0 + absf(spin) * 3.0
			var gem := [Vector2(0, -17), Vector2(wx, -2), Vector2(0, 17), Vector2(-wx, -2)]
			_poly(o, gem, Color("120f19"), 2.0)
			_poly(o, gem, dark)
			var mid := spin * wx * 0.6
			_poly(o, [Vector2(0, -17), Vector2(mid, -2), Vector2(0, 17), Vector2(-wx, -2)], c)
			_poly(o, [Vector2(0, -17), Vector2(mid, -2), Vector2(-wx, -2)], light)
			_hp(o, -2, -9, 2, 5, Color("efe4ff"))


func _hp(at: Vector2, x: float, y: float, w: float, h: float, col: Color) -> void:
	draw_rect(Rect2(at + Vector2(x, y) * 0.5, Vector2(w, h) * 0.5), col)


## A polygon in half-pixels around `at`, grown outward by `grow` half-pixels.
func _poly(at: Vector2, pts: Array, col: Color, grow := 0.0) -> void:
	var center := Vector2.ZERO
	for p: Vector2 in pts:
		center += p
	center /= pts.size()
	var out := PackedVector2Array()
	for p: Vector2 in pts:
		out.append(at + (p + (p - center).normalized() * grow) * 0.5)
	draw_colored_polygon(out, col)
