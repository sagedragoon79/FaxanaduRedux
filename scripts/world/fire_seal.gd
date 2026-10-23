class_name FireSeal
extends StaticBody2D
## One tile of a fire seal (room legend `Z`, a column of three is usual, bible
## 4.5): red runic flames that block like a wall and burn whoever touches them.
## A Deluge bolt (group "water_target") douses every seal in the room for good,
## in a hiss of steam. The flames light the Mist's fog (group "light").
## Drawn at 2x render density: `_px` takes half-pixels.

## Damage for touching the flames, and how often they can burn you.
const BURN := 10
const BURN_EVERY := 0.6
const DOUSE_TIME := 0.7
const FLAME := Color("e0402a")
const FLAME_HOT := Color("ffb040")
const FLAME_CORE := Color("fff0b0")
const RUNE := Color("ffe070")
const ASH := Color("4a3a3a")

## The flag that remembers the room's seals went out: "seal:<room id>".
var flag_id := ""
var doused := false
var light_radius := 30.0
## 0 burning, 1 out.
var _t := 0.0
var _burn_cd := 0.0
var _shape: CollisionShape2D
var _clock := 0.0


func _ready() -> void:
	collision_layer = Player.LAYER_WORLD
	collision_mask = 0
	add_to_group("fire_seal")
	add_to_group("water_target")
	add_to_group("light")
	_shape = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 16)
	_shape.shape = rect
	add_child(_shape)
	_clock = fmod(global_position.x * 0.53 + global_position.y * 0.29, 10.0)
	if flag_id != "" and GameState.flag(flag_id):
		_go_out(true)


## A Deluge bolt struck this tile: every seal in the room goes out and stays out.
func douse() -> void:
	if doused:
		return
	if flag_id != "":
		GameState.set_flag(flag_id)
	for s in get_tree().get_nodes_in_group("fire_seal"):
		(s as FireSeal)._go_out(false)
	Sfx.play("douse", 0.0)
	Feel.add_trauma(0.15)


func _go_out(instant: bool) -> void:
	if doused:
		return
	doused = true
	_t = 1.0 if instant else 0.0
	_shape.set_deferred("disabled", true)
	remove_from_group("water_target")
	remove_from_group("light")
	queue_redraw()


func _physics_process(delta: float) -> void:
	_clock += delta
	if doused:
		if _t < 1.0:
			_t = minf(1.0, _t + delta / DOUSE_TIME)
			queue_redraw()
		return
	_burn_cd -= delta
	queue_redraw()
	var p := get_tree().get_first_node_in_group("player") as Player
	if p == null or p.dead or _burn_cd > 0.0:
		return
	if p.body_rect().grow(1.5).intersects(Rect2(global_position - Vector2(8, 8), Vector2(16, 16))):
		if p.receive_attack(BURN, self, false) != "":
			_burn_cd = BURN_EVERY


func _draw() -> void:
	var fade := 1.0 - _t
	if fade <= 0.0:
		# Out: a scorched socket of ash.
		_px(-12, 10, 24, 6, ASH, 1.0)
		return
	if doused:
		# Steam rises off the dying flames.
		for i in 3:
			var sx := -8 + i * 8 + roundi(sin(_clock * 3.0 + i) * 2.0)
			_px(sx, -8 - roundi(_t * 20.0) - i * 4, 6, 6, Color(1, 1, 1), 0.5 * fade)
	# Tongues of flame, licking upward at their own pace.
	for i in 4:
		var x := -14 + i * 7
		var h := 30 + roundi(sin(_clock * (6.0 + i) + i * 1.9) * 4.0)
		var bottom := 16
		_px(x, bottom - h, 8, h, FLAME, fade)
		_px(x + 1, bottom - h + 4, 5, h - 6, FLAME_HOT, fade)
		_px(x + 2, bottom - h + 9, 3, maxi(1, h - 12), FLAME_CORE, fade)
	# The rune that binds the fire, pulsing.
	var k := 0.6 + 0.4 * sin(_clock * 4.0)
	_px(-1, -8, 2, 14, RUNE, k * fade)
	_px(-5, -5, 10, 2, RUNE, k * fade)
	_px(-4, 2, 3, 2, RUNE, k * fade)
	_px(2, 2, 3, 2, RUNE, k * fade)


func _px(x: int, y: int, w: int, h: int, color: Color, alpha: float) -> void:
	draw_rect(Rect2(x * 0.5, y * 0.5, w * 0.5, h * 0.5), Color(color, color.a * alpha))
