class_name KeyDoor
extends StaticBody2D
## A locked door (three tiles tall). Walk into it holding the right key and it
## unlocks for good; without one it tells you what it needs. The card doors of
## the original (design bible 3, "Key doors"), each with its suit: Jack (oak,
## a spade; legend `J`), and, set by a `lock: x, y, kind` header line on a `J`,
## Queen (red lacquer, a heart), King (blackened iron, a club), Ace (elf-silver,
## a diamond) and Joker (violet, a jester's star). Card doors guard treasure,
## never the way on. "sky" is Dartmoor's upper gate (pale shrine stone with a
## gold lightning glyph, legend `g`: Borabohra's Sky Key).

const IRON := Color("6b6380")
const GLYPH := Color("ffd24a")
const SIZE := Vector2(16, 48)
const SHRINE := Color("c9c4d6")
const SHRINE_DARK := Color("8d84a3")
const SKY := Color("b8a8ff")
## The card doors: their panel, its shade, the bands and the suit's glyph.
const CARDS := {
	"jack": {"panel": Color("8a5a34"), "dark": Color("5e3b22"), "band": Color("6b6380"), "glyph": Color("ffd24a"), "suit": "spade"},
	"queen": {"panel": Color("a8323e"), "dark": Color("6a1e28"), "band": Color("d8b060"), "glyph": Color("ffe6ea"), "suit": "heart"},
	"king": {"panel": Color("3a3848"), "dark": Color("1e1c28"), "band": Color("d8b060"), "glyph": Color("ffd24a"), "suit": "club"},
	"ace": {"panel": Color("b8c4d8"), "dark": Color("7a86a0"), "band": Color("eef4ff"), "glyph": Color("4aa3df"), "suit": "diamond"},
	"joker": {"panel": Color("5a3a8a"), "dark": Color("34205a"), "band": Color("8af0b0"), "glyph": Color("ffd24a"), "suit": "star"},
}

var kind := "jack"
var persist_id := ""

var _told := false


func _ready() -> void:
	collision_layer = Player.LAYER_WORLD
	collision_mask = 0
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = SIZE
	shape.shape = rect
	shape.position = Vector2(0, -SIZE.y * 0.5)
	add_child(shape)
	z_index = -1


func _physics_process(_delta: float) -> void:
	var p := get_tree().get_first_node_in_group("player") as Player
	if p == null or p.dead:
		return
	if kind == "sky" or kind == "joker":
		queue_redraw()
	var touching := absf(p.global_position.x - global_position.x) < SIZE.x * 0.5 + 8.0 and absf(p.global_position.y - global_position.y) < 8.0
	if not touching:
		_told = false
		return
	if GameState.key_count(kind) > 0:
		open()
	elif not _told:
		_told = true
		GameState.toast.emit("A %s door. You need a %s Key." % [kind.capitalize(), kind.capitalize()])
		Sfx.play("door_locked", 0.03)


func open() -> void:
	GameState.add_key(kind, -1)
	if persist_id != "":
		GameState.collect(persist_id)
	GameState.toast.emit("The %s Key turns." % kind.capitalize())
	# The wards click, the bolt draws back, and a small chime (not the plain door creak).
	Sfx.play("key_turn", 0.03)
	var d := Dust.new()
	d.setup("debris")
	get_parent().add_child(d)
	d.global_position = global_position + Vector2(0, -24)
	queue_free()


func _draw() -> void:
	if kind == "sky":
		_draw_sky_gate()
		return
	var card: Dictionary = CARDS.get(kind, CARDS.jack)
	draw_rect(Rect2(-8, -48, 16, 48), card.dark)
	draw_rect(Rect2(-7, -47, 14, 47), card.panel)
	for y in [-40, -24, -8]:
		draw_rect(Rect2(-8, y, 16, 3), card.band)
	_draw_suit(String(card.suit), Vector2(0, -31), card.glyph)


## The suit's glyph, about 8 px across, centered on `c`.
func _draw_suit(suit: String, c: Vector2, col: Color) -> void:
	match suit:
		"spade":
			draw_circle(c + Vector2(-2, 1), 2.0, col)
			draw_circle(c + Vector2(2, 1), 2.0, col)
			draw_colored_polygon(PackedVector2Array([c + Vector2(-4, 1), c + Vector2(0, -4), c + Vector2(4, 1)]), col)
			draw_rect(Rect2(c + Vector2(-1, 2), Vector2(2, 3)), col)
		"heart":
			draw_circle(c + Vector2(-2, -1), 2.2, col)
			draw_circle(c + Vector2(2, -1), 2.2, col)
			draw_colored_polygon(PackedVector2Array([c + Vector2(-4.2, -0.5), c + Vector2(4.2, -0.5), c + Vector2(0, 4)]), col)
		"club":
			draw_circle(c + Vector2(0, -2.5), 1.9, col)
			draw_circle(c + Vector2(-2.3, 0.6), 1.9, col)
			draw_circle(c + Vector2(2.3, 0.6), 1.9, col)
			draw_rect(Rect2(c + Vector2(-1, 0), Vector2(2, 5)), col)
		"diamond":
			draw_colored_polygon(PackedVector2Array([c + Vector2(0, -5), c + Vector2(3.5, 0), c + Vector2(0, 5), c + Vector2(-3.5, 0)]), col)
		_:
			# The Joker's star: five points, and a glint that winks.
			var pts := PackedVector2Array()
			for i in 10:
				var r := 4.5 if i % 2 == 0 else 2.0
				pts.append(c + Vector2.from_angle(-PI / 2 + i * PI / 5) * r)
			draw_colored_polygon(pts, col)
			var a := 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.005)
			draw_circle(c + Vector2(2, -3), 1.0, Color(1, 1, 1, a))


func _draw_sky_gate() -> void:
	draw_rect(Rect2(-8, -48, 16, 48), SHRINE_DARK)
	draw_rect(Rect2(-7, -47, 14, 47), SHRINE)
	for y in [-44, -6]:
		draw_rect(Rect2(-8, y, 16, 3), GLYPH)
	# A lightning glyph, pulsing faintly.
	var a := 0.75 + 0.25 * sin(Time.get_ticks_msec() * 0.004)
	var bolt := PackedVector2Array([Vector2(1, -38), Vector2(-3, -27), Vector2(1, -27), Vector2(-2, -16)])
	draw_polyline(bolt, SKY * Color(1, 1, 1, a), 3.0)
	draw_polyline(bolt, GLYPH, 1.0)
