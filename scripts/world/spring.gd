class_name Spring
extends Interactable
## One of the World Tree's three springs (design bible 4.2). Dry and choked
## until restored by pressing Up; restoring it sets the `spring:<id>` flag,
## which hardens sap into amber and fills a third of the Eolis fountain.

const STONE := Color("6b6380")
const STONE_DARK := Color("4a4458")
const WATER := Color("7cc4f0")
const WATER_LIGHT := Color("d8f1ff")
const SLUDGE := Color("6e4a2c")

var spring_id := "trunk"
var spring_name := "Spring of Trunk"
var text := "The sap hardens to amber. Water returns to Eolis."
## A flag that must be set before the spring can be cleared ("" = none).
var needs_flag := ""

var _burst := 0.0


func _ready() -> void:
	super()
	prompt_height = 40.0
	z_index = -1


func flowing() -> bool:
	return GameState.flag("spring:" + spring_id)


func _process(delta: float) -> void:
	super(delta)
	_burst = move_toward(_burst, 0.0, delta * 0.6)
	if flowing():
		remove_from_group("interactable")
	elif needs_flag != "" and not GameState.flag(needs_flag):
		remove_from_group("interactable")
	elif not is_in_group("interactable"):
		add_to_group("interactable")


func interact(_p: Player) -> void:
	if flowing() or needs_flag != "" and not GameState.flag(needs_flag):
		return
	GameState.set_flag("spring:" + spring_id)
	_burst = 1.0
	var d := Dust.new()
	d.setup("splash")
	get_parent().add_child(d)
	d.global_position = global_position + Vector2(0, -20)
	Sfx.play("secret", 0.0)
	Feel.add_trauma(0.3)
	GameState.banner.emit(spring_name + " restored", text)


func _draw() -> void:
	# Basin.
	draw_rect(Rect2(-30, -12, 60, 12), STONE_DARK)
	draw_rect(Rect2(-28, -14, 56, 4), STONE)
	draw_rect(Rect2(-24, -10, 48, 6), WATER if flowing() else SLUDGE)
	# The spout, a root-carved head in the wall of the trunk.
	draw_rect(Rect2(-6, -44, 12, 30), STONE)
	draw_rect(Rect2(-6, -44, 2, 30), STONE_DARK.lightened(0.3))
	draw_circle(Vector2(0, -38), 4.0, STONE_DARK)
	if flowing():
		var wobble := sin(t * 12.0) * 0.8
		draw_rect(Rect2(-1.5 + wobble, -36, 3, 28), WATER)
		draw_rect(Rect2(-0.5 + wobble, -36, 1, 28), WATER_LIGHT)
		for i in 3:
			var k := fmod(t * 1.5 + i / 3.0, 1.0)
			draw_arc(Vector2(0, -8), 4.0 + k * 18.0, PI, TAU, 12, Color(WATER_LIGHT, 0.6 * (1.0 - k)), 1.0)
		if _burst > 0.0:
			draw_circle(Vector2(0, -24), 30.0 * _burst, Color(WATER_LIGHT, 0.25 * _burst))
	else:
		draw_rect(Rect2(-2, -36, 4, 3), SLUDGE)
	draw_prompt()
