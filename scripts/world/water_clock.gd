class_name WaterClock
extends Node2D
## The great water-clock of King Grieve's throne hall (room prop `water_clock`,
## design bible 8.7): a tall glass column in a bronze frame with a dial of
## hours, full of flood-water since the day the king made his pact. While you
## fight him it drains with his life, so the hall's own clock shows how near
## the end is; once he is beaten it stands empty. Scenery only, drawn at 2x
## density. The origin is the bottom centre (it stands on the floor).

const OUTLINE := Color("120f19")
const BRONZE := Color("8a6a3a")
const BRONZE_LIGHT := Color("d8b070")
const BRONZE_DARK := Color("4a3420")
const GLASS := Color("a8d8e0")
const WATER := Color("3f9ab0")
const WATER_LIGHT := Color("8fe0e8")
const CRYSTAL := Color("e05ad0")

const WIDTH := 28.0
const HEIGHT := 112.0
const FLAG := "boss:king_grieve"
## How fast the shown level follows the real one (fraction per second).
const FOLLOW := 0.6

## The water level shown, 0 (empty) to 1 (full).
var level := 1.0
var _t := 0.0


func _ready() -> void:
	z_index = -2
	level = target_level()


## Full before the fight, his health fraction during it, empty once he is beaten.
func target_level() -> float:
	if GameState.flag(FLAG):
		return 0.0
	var b := get_tree().get_first_node_in_group("boss") if is_inside_tree() else null
	if b is KingGrieve and not (b as KingGrieve).is_queued_for_deletion():
		return (b as KingGrieve).health_fraction()
	return 1.0


func _process(delta: float) -> void:
	_t += delta
	level = move_toward(level, target_level(), FOLLOW * delta)
	queue_redraw()


func _draw() -> void:
	var w := WIDTH
	var h := HEIGHT
	# The plinth and the crown of the frame.
	draw_rect(Rect2(-w * 0.5 - 6.0, -8.0, w + 12.0, 8.0), OUTLINE)
	draw_rect(Rect2(-w * 0.5 - 5.0, -7.0, w + 10.0, 6.0), BRONZE)
	draw_rect(Rect2(-w * 0.5 - 5.0, -7.0, w + 10.0, 1.0), BRONZE_LIGHT)
	draw_rect(Rect2(-w * 0.5 - 6.0, -h - 16.0, w + 12.0, 8.0), OUTLINE)
	draw_rect(Rect2(-w * 0.5 - 5.0, -h - 15.0, w + 10.0, 6.0), BRONZE)
	draw_rect(Rect2(-w * 0.5 - 5.0, -h - 15.0, w + 10.0, 1.0), BRONZE_LIGHT)
	# The glass column and the water left in it.
	var top := -h - 8.0
	draw_rect(Rect2(-w * 0.5 - 1.0, top, w + 2.0, h), OUTLINE)
	draw_rect(Rect2(-w * 0.5, top + 1.0, w, h - 2.0), Color(GLASS, 0.18))
	var fill := (h - 2.0) * clampf(level, 0.0, 1.0)
	if fill > 0.5:
		var y0 := top + 1.0 + (h - 2.0) - fill
		draw_rect(Rect2(-w * 0.5, y0, w, fill), Color(WATER, 0.85))
		draw_rect(Rect2(-w * 0.5, y0, w, 1.0), WATER_LIGHT)
		# A thin stream draining out at the bottom while it falls.
		if level > 0.01 and level < 0.999:
			for i in 3:
				var by := fmod(_t * 40.0 + i * 3.0, 8.0)
				draw_rect(Rect2(-0.5, -8.0 + by, 1.0, 1.5), Color(WATER_LIGHT, 0.8))
	# The glass's sheen and the hour marks up its side, a crystal at every fourth.
	draw_rect(Rect2(-w * 0.5 + 2.0, top + 3.0, 1.0, h - 6.0), Color(1, 1, 1, 0.3))
	for i in 12:
		var my := top + 1.0 + (h - 2.0) * (i + 0.5) / 12.0
		var c := CRYSTAL if i % 4 == 0 else BRONZE_LIGHT
		draw_rect(Rect2(w * 0.5 - 4.0, my, 3.0, 1.0), c)
	# The frame's posts.
	for x: float in [-w * 0.5 - 4.0, w * 0.5 + 1.0]:
		draw_rect(Rect2(x - 1.0, -h - 9.0, 5.0, h + 2.0), OUTLINE)
		draw_rect(Rect2(x, -h - 8.0, 3.0, h), BRONZE_DARK)
		draw_rect(Rect2(x, -h - 8.0, 1.0, h), BRONZE)
