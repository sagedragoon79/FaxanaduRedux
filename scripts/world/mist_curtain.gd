class_name MistCurtain
extends StaticBody2D
## One tile of bound fog (room legend `Y`, a row or column of three is usual):
## a wall of pale, unmoving mist with drowned souls glinting in it. Nothing
## passes it but a lantern's light: carry the Lantern Key (Ripasheiku's reward,
## design bible 4.4) within RANGE and every curtain in the room parts for good.
## Without the key, touching it says what it needs. The key is not used up.
## Drawn at 2x render density: `_px` takes half-pixels.

const KEY := "lantern"
## How close the player must bring the lantern (px from the tile's centre).
const RANGE := 100.0
const PART_TIME := 0.9
const FOG := Color("b9c4b4")
const FOG_DARK := Color("7d8c80")
const FOG_LIGHT := Color("e4ebdc")
const SOUL := Color("f0d070")

## The flag that remembers the room's curtains parted: "curtain:<room id>".
var flag_id := ""
var parted := false
## 0 standing, 1 gone.
var _t := 0.0
var _told := false
var _shape: CollisionShape2D
var _clock := 0.0


func _ready() -> void:
	collision_layer = Player.LAYER_WORLD
	collision_mask = 0
	add_to_group("mist_curtain")
	_shape = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 16)
	_shape.shape = rect
	add_child(_shape)
	_clock = fmod(global_position.x * 0.37 + global_position.y * 0.11, 10.0)
	if flag_id != "" and GameState.flag(flag_id):
		part(true)


## Parts this tile; `instant` skips the fade.
func part(instant := false) -> void:
	if parted:
		return
	parted = true
	_t = 1.0 if instant else 0.0
	_shape.set_deferred("disabled", true)
	queue_redraw()


## Parts every curtain in the room and remembers it.
func part_all() -> void:
	if flag_id != "":
		GameState.set_flag(flag_id)
	for c in get_tree().get_nodes_in_group("mist_curtain"):
		(c as MistCurtain).part()
	Sfx.play("curtain", 0.0)
	GameState.toast.emit("The Lantern Key's light parts the bound fog.")


func _physics_process(delta: float) -> void:
	_clock += delta
	if parted:
		if _t < 1.0:
			_t = minf(1.0, _t + delta / PART_TIME)
			queue_redraw()
		return
	queue_redraw()
	var p := get_tree().get_first_node_in_group("player") as Player
	if p == null or p.dead:
		return
	var d := (p.global_position + Vector2(0, -16)).distance_to(global_position)
	if GameState.key_count(KEY) > 0:
		if d <= RANGE:
			part_all()
	elif d <= 30.0:
		if not _told:
			# One message for the whole wall, not one per tile.
			for c in get_tree().get_nodes_in_group("mist_curtain"):
				(c as MistCurtain)._told = true
			GameState.toast.emit("Bound fog. Only a lantern's light will part it.")
			Sfx.play("fizzle", 0.0)
	elif d > 48.0:
		_told = false


func _draw() -> void:
	var fade := 1.0 - _t
	if fade <= 0.0:
		return
	var lift := -_t * 12.0
	# Wet folds of fog that sway but never drift: three bands per tile.
	for i in 4:
		var y := -16 + i * 8
		var sway := roundi(sin(_clock * 1.3 + i * 1.7 + global_position.x * 0.05) * 2.0)
		_px(-16 + sway, y, 32, 8, Color(FOG if i % 2 == 0 else FOG_DARK, 0.8 * fade), lift)
		_px(-14 + sway, y + 1, 26, 1, Color(FOG_LIGHT, 0.6 * fade), lift)
	# A drowned soul glints in the fold now and then.
	var glint := fmod(_clock * 0.7, 3.0)
	if glint < 0.6:
		var gx := roundi(sin(_clock * 0.9) * 8.0)
		var gy := roundi(cos(_clock * 0.6) * 6.0)
		_px(gx - 1, gy - 1, 3, 3, Color(SOUL, (0.6 - glint) * 1.4 * fade), lift)


func _px(x: int, y: int, w: int, h: int, color: Color, lift := 0.0) -> void:
	draw_rect(Rect2(x * 0.5, y * 0.5 + roundf(lift), w * 0.5, h * 0.5), color)
