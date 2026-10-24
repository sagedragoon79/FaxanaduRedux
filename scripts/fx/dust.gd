class_name Dust
extends Node2D
## One-shot pixel particle puff: run, land, jump, wall, feathers, pogo, debris.

const KINDS := {
	"run": {"count": 3, "speed": Vector2(40, 15), "life": 0.25, "color": Color("cdbfa6"), "size": 2, "rise": -20.0},
	"jump": {"count": 5, "speed": Vector2(55, 10), "life": 0.25, "color": Color("cdbfa6"), "size": 2, "rise": -10.0},
	"land": {"count": 8, "speed": Vector2(90, 15), "life": 0.3, "color": Color("cdbfa6"), "size": 3, "rise": -15.0},
	"wall": {"count": 1, "speed": Vector2(15, 10), "life": 0.25, "color": Color("cdbfa6"), "size": 2, "rise": -25.0},
	"walljump": {"count": 6, "speed": Vector2(50, 50), "life": 0.3, "color": Color("cdbfa6"), "size": 2, "rise": 0.0},
	"feathers": {"count": 7, "speed": Vector2(60, 40), "life": 0.45, "color": Color("f3f0e2"), "size": 2, "rise": 40.0},
	"pogo": {"count": 8, "speed": Vector2(80, 50), "life": 0.25, "color": Color("ffe27a"), "size": 2, "rise": 0.0},
	"hit": {"count": 6, "speed": Vector2(120, 90), "life": 0.2, "color": Color("fff4d6"), "size": 2, "rise": 0.0},
	"splash": {"count": 9, "speed": Vector2(90, 90), "life": 0.35, "color": Color("7cc4f0"), "size": 2, "rise": 250.0},
	"parry": {"count": 12, "speed": Vector2(160, 160), "life": 0.3, "color": Color("fff1a8"), "size": 2, "rise": 0.0},
	"guard": {"count": 5, "speed": Vector2(90, 60), "life": 0.2, "color": Color("c9c4d6"), "size": 2, "rise": 0.0},
	"heal": {"count": 10, "speed": Vector2(30, 40), "life": 0.6, "color": Color("ff8a8a"), "size": 2, "rise": -60.0},
	"coin": {"count": 4, "speed": Vector2(40, 40), "life": 0.25, "color": Color("ffe27a"), "size": 1, "rise": 0.0},
	"debris": {"count": 10, "speed": Vector2(90, 120), "life": 0.6, "color": Color("8a7d6b"), "size": 3, "rise": 300.0},
	"sap": {"count": 9, "speed": Vector2(80, 70), "life": 0.4, "color": Color("ffb84a"), "size": 2, "rise": 260.0},
	"bark": {"count": 14, "speed": Vector2(150, 150), "life": 0.8, "color": Color("6e4a2c"), "size": 4, "rise": 320.0},
	"embers": {"count": 12, "speed": Vector2(110, 110), "life": 0.45, "color": Color("f8a040"), "size": 2, "rise": -60.0},
}

var _particles: Array = []  # [pos, vel, life, max_life]
var _color := Color.WHITE
var _size := 2
var _rise := 0.0


func setup(kind: String, facing := 1) -> void:
	var k: Dictionary = KINDS.get(kind, KINDS["run"])
	_color = k["color"]
	_size = k["size"]
	_rise = k["rise"]
	var speed: Vector2 = k["speed"]
	for i in int(k["count"]):
		var dir := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 0.2))
		if kind == "run":
			dir.x = -absf(dir.x) * facing
		if kind in ["debris", "hit", "pogo", "walljump", "splash", "parry", "guard", "coin", "sap", "bark", "embers"]:
			dir = Vector2.from_angle(randf() * TAU)
		var life: float = k["life"] * randf_range(0.7, 1.2)
		_particles.append([Vector2.ZERO, dir * speed, life, life])
	z_index = 2


func _physics_process(delta: float) -> void:
	var alive := false
	for p: Array in _particles:
		p[2] -= delta
		if p[2] > 0.0:
			alive = true
			p[1] = p[1] * 0.92 + Vector2(0, _rise) * delta
			p[0] += p[1] * delta
	if not alive:
		queue_free()
	queue_redraw()


func _draw() -> void:
	for p: Array in _particles:
		if p[2] <= 0.0:
			continue
		var k: float = p[2] / p[3]
		var s := maxf(1.0, round(_size * k + 0.4))
		draw_rect(Rect2((p[0] as Vector2).round(), Vector2(s, s)), Color(_color, k))
