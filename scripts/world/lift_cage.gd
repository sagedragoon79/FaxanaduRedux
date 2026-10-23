class_name LiftCage
extends Interactable
## The Forepaw lift (design bible 4.4): an iron cage on a chain between freed
## Forepaw and the Tower Foot. Room prop `lift`. It runs only once Zoradohna is
## beaten; until then its chain hangs slack. Press Up inside it to ride.

const OUTLINE := Color("120f19")
const IRON := Color("4a4560")
const IRON_LIGHT := Color("7a7296")
const BRASS := Color("cb8d16")
const CHAIN := Color("867ba2")
const FLOOR := Color("6e3a1a")
## Room id -> [room the cage goes to, tile the rider steps out on].
const LINKS := {
	"tower/forepaw": ["tower/foot", Vector2i(24, 41)],
	"tower/foot": ["tower/forepaw", Vector2i(71, 19)],
}
const FLAG := "boss:zoradohna"
const W := 28.0
const H := 44.0

var room_id := ""


func _ready() -> void:
	super()
	prompt_height = H + 4.0
	z_index = -1


func running() -> bool:
	return GameState.flag(FLAG)


func destination() -> Array:
	return LINKS.get(room_id, [])


func interact(p: Player) -> void:
	var to := destination()
	if to.is_empty():
		return
	if not running():
		GameState.say("", ["The cage hangs still. Its chain runs up into the dark, toward Forepaw.",
			"Somewhere above, something is holding the lift."])
		return
	var world := get_tree().get_first_node_in_group("world") as World
	if world == null:
		return
	Sfx.play("heavy", 0.0, -2.0)
	var cell: Vector2i = to[1]
	world.travel(String(to[0]), Vector2(cell.x * Room.TILE + Room.TILE * 0.5, (cell.y + 1) * Room.TILE))
	p.velocity = Vector2.ZERO


func _draw() -> void:
	# The chain up out of sight, swaying a little when the lift runs.
	var sway := sin(t * 1.3) * (1.0 if running() else 0.0)
	var x := 0.0
	var y := -H
	while y > -H - 160.0:
		draw_rect(Rect2(x - 1 + sway * (y + H) / -160.0, y - 4, 2, 3), CHAIN)
		y -= 5.0
	# The cage: a floor plate, two posts, a roof and bars.
	var r := Rect2(-W * 0.5, -H, W, H)
	draw_rect(r.grow(1), OUTLINE, false, 2.0)
	draw_rect(Rect2(r.position.x, r.end.y - 3, W, 3), FLOOR)
	draw_rect(Rect2(r.position.x, r.position.y, W, 4), IRON)
	draw_rect(Rect2(r.position.x, r.position.y, W, 1), IRON_LIGHT)
	for bx in [r.position.x, r.end.x - 2]:
		draw_rect(Rect2(bx, r.position.y, 2, H), IRON_LIGHT)
	var bar := r.position.x + 6.0
	while bar < r.end.x - 4.0:
		draw_rect(Rect2(bar, r.position.y + 4, 1, H - 7), IRON)
		bar += 5.0
	draw_rect(Rect2(r.position.x, r.position.y + H * 0.45, W, 2), BRASS)
	# A lamp on the roof: lit when the lift runs.
	draw_rect(Rect2(-2, r.position.y - 4, 4, 4), BRASS if running() else IRON)
	draw_prompt()
