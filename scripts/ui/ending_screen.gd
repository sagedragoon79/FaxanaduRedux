class_name EndingScreen
extends Control
## The ending (design bible 8.9, Reward). It plays once the heart of the meteor
## is dead, in three parts:
##
## 1. **Epilogue**: the World Tree stands against the night with the dead
##    meteor at its crown. The meteor's light drains away, the three springs
##    in the trunk light one by one, and four cards tell what happened.
## 2. **Credits**: the view climbs the Tree from Eolis at its roots, past every
##    zone, to the crown at dawn, while the credits rise over it.
## 3. **Thanks**: the completion card (pass 106): how much of the world you saw
##    (Completion.tally: rooms, hidden rooms, treasures, bosses and their
##    average as one percent), then your rank, time, deaths and clears, until
##    you press a button. The rows count up as the card fades in.
##
## The secret ending (design bible 11: no deaths and the Battle Suit) adds three
## epilogue cards: the Sunken Spring wakes under the roots, its water climbs the
## whole trunk and the crown flowers. Its thanks card says so.
##
## Jump or attack moves to the next card in the epilogue, holds the climb at
## four times its speed during the credits and leaves the thanks card. Pause
## goes straight to the thanks card. `tick` advances it by hand (tests).

signal finished

const EPILOGUE := [
	"The heart of the meteor is dead.",
	"Its light drains out of Zenis like a fever breaking.",
	"Down the trunk, the springs run clear again.",
	"And in Eolis, the fountain fills.",
]
## The secret ending's cards, after the others.
const SECRET_EPILOGUE := [
	"Far under Dartmoor, the Sunken Spring wakes.",
	"Its water climbs the whole Tree, root to crown.",
	"No one saw you fall. The Tree remembers that.",
]
## The last cards, after any others: as in Faxanadu's ending, the town would
## thank you, and the wanderer walks on (pass 167).
const FAREWELL := [
	"In Eolis, the King waits by the full fountain to thank you.",
	"But the wanderer is already on the east road, walking on.",
]
## How fast the wanderer walks off under the farewell (px/s), and how fast the
## run cycle plays to make a walk of it.
const WALK_SPEED := 46.0
const WALK_RATE := 0.6
## Seconds each epilogue card shows (fading in and out).
const CARD_TIME := 4.0
const CREDITS := [
	["FAXANADU REDUX", 2],
	["", 0],
	["A remake of Faxanadu", 1],
	["Hudson Soft, 1987", 1],
	["", 0],
	["Direction", 0],
	["Sean", 1],
	["", 0],
	["Design, code, art and music", 0],
	["Claude", 1],
	["", 0],
	["Character animation", 0],
	["made with Autosprite", 1],
	["", 0],
	["Engine", 0],
	["Godot", 1],
	["", 0],
	["With thanks to everyone", 0],
	["who climbed the Tree in 1987", 0],
]
## Height of the climb in screen pixels, and how fast it scrolls (px/s).
const CLIMB := 2600.0
const SPEED := 60.0
const FAST := 4.0
const LINE_GAP := 22.0
## Height up the climb where the trunk ends in the crown's leaves (just under
## the top of the last screen).
const CROWN := CLIMB + 60.0
## The zones you pass, by how far up the climb they are (0 = the roots).
const ZONES := [
	["Eolis", 0.0], ["The Trunk", 0.13], ["The Tower", 0.26], ["The Mist", 0.38],
	["The Branches", 0.5], ["Daybreak", 0.63], ["Dartmoor", 0.75], ["The Crown", 0.9],
]
## Seconds before the thanks card takes a press (so a held button doesn't skip it).
const THANKS_GRACE := 1.0
## Seconds the completion card's numbers take to count up.
const COUNT_TIME := 1.2

const NIGHT := Color("120f19")
const DUSK := Color("2a1e3a")
const DAWN := Color("e8a86a")
const DAWN_HIGH := Color("6a7ac8")
const BARK := Color("4a3424")
const BARK_LIGHT := Color("7a5634")
const BARK_DARK := Color("2a1c14")
const LEAF := Color("3a6a3a")
const LEAF_LIGHT := Color("6aa04a")
const WATER := Color("7cc4f0")
const WATER_LIGHT := Color("d8f1ff")
const METEOR := Color("4ae0d8")
const GOLD := Color("f0c02e")
const TEXT := Color("f7f1de")
const SUB := Color("cec5d3")
const OUTLINE := Color("120f19")

var phase := "epilogue"
## Seconds into the current part.
var t := 0.0
## How far the climb has gone (0..CLIMB).
var climb := 0.0
var card := 0
## Rank and time shown on the thanks card (set by whoever starts the ending).
var rank := ""
var seconds := 0.0
var fast := false
## The secret ending (no deaths, the Battle Suit), and the deaths shown on the thanks card.
var secret := false
var deaths := 0
## Completion.tally of the save (empty: the card shows only rank, time and deaths).
var stats := {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	process_mode = Node.PROCESS_MODE_ALWAYS


## Starts the ending from the top.
func start(rank_name: String, play_seconds: float, secret_ending := false, death_count := 0, completion := {}) -> void:
	stats = completion
	rank = rank_name
	seconds = play_seconds
	secret = secret_ending
	deaths = death_count
	phase = "epilogue"
	t = 0.0
	climb = 0.0
	card = 0
	visible = true


## The epilogue's cards: the secret ending's follow the others, and the
## farewell comes last.
func cards() -> Array:
	return (EPILOGUE + SECRET_EPILOGUE if secret else EPILOGUE) + FAREWELL


## Seconds into the epilogue when the farewell begins.
func farewell_start() -> float:
	return (cards().size() - FAREWELL.size()) * CARD_TIME


## Where the wanderer is `t` seconds into the epilogue (x on the 640-wide
## card), or -1.0 before the farewell: from the foot of the Tree east, off the
## edge of the screen.
func wanderer_x() -> float:
	var into := t - farewell_start()
	if into < 0.0:
		return -1.0
	return 332.0 + into * WALK_SPEED


## Height of the credits block (it rises from below the screen to above it).
static func credits_height() -> float:
	return CREDITS.size() * LINE_GAP


func _process(delta: float) -> void:
	if not visible:
		return
	fast = phase == "credits" and (Input.is_action_pressed("jump") or Input.is_action_pressed("attack"))
	if Input.is_action_just_pressed("pause"):
		skip()
	elif Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("attack"):
		advance()
	tick(delta)


## Moves time on by `delta` seconds.
func tick(delta: float) -> void:
	t += delta
	match phase:
		"epilogue":
			card = int(t / CARD_TIME)
			if card >= cards().size():
				_to("credits")
		"credits":
			climb = minf(CLIMB, climb + SPEED * delta * (FAST if fast else 1.0))
			if climb >= CLIMB:
				_to("thanks")
	queue_redraw()


## What a press of jump or attack does.
func advance() -> void:
	match phase:
		"epilogue":
			# On to the next card.
			t = (card + 1) * CARD_TIME
		"thanks":
			if t >= THANKS_GRACE:
				phase = "done"
				visible = false
				finished.emit()


## Pause: straight to the thanks card.
func skip() -> void:
	if phase == "epilogue" or phase == "credits":
		climb = CLIMB
		_to("thanks")


func _to(p: String) -> void:
	phase = p
	t = 0.0


func _draw() -> void:
	match phase:
		"epilogue":
			_draw_epilogue()
		"credits":
			_draw_climb()
		"thanks":
			_draw_thanks()


func _centered(y: float, text: String, size: int, color: Color) -> void:
	var w := PixelFont.width(text, size)
	PixelFont.draw(self, Vector2(roundf(320.0 - w * 0.5), y), text, size, color, OUTLINE)


# --- The epilogue: the Tree at night, the meteor dying at its crown ------------------

func _draw_epilogue() -> void:
	draw_rect(Rect2(0, 0, 640, 360), NIGHT)
	var total := cards().size() * CARD_TIME
	var k := clampf(t / total, 0.0, 1.0)
	# The sky warms toward dawn as the story goes on.
	for i in 12:
		draw_rect(Rect2(0, 360 - (i + 1) * 30, 640, 30), Color(DUSK.lerp(DAWN, k * 0.35 * (1.0 - i / 12.0)), 0.6))
	for i in 40:
		var star := Vector2(fmod(i * 157.0, 640.0), fmod(i * 89.0, 200.0))
		draw_rect(Rect2(star, Vector2.ONE), Color(TEXT, (0.3 + 0.3 * sin(t * 2.0 + i)) * (1.0 - k)))
	# The Tree: a trunk from the ground to a spread crown.
	var base := Vector2(320, 360)
	draw_colored_polygon(PackedVector2Array([base + Vector2(-70, 0), Vector2(296, 120), Vector2(344, 120), base + Vector2(70, 0)]), BARK_DARK)
	for side in [-1.0, 1.0]:
		draw_line(Vector2(320, 150), Vector2(320 + side * 130, 90), BARK_DARK, 10.0)
		draw_line(Vector2(320, 190), Vector2(320 + side * 170, 150), BARK_DARK, 8.0)
	for i in 9:
		var c := Vector2(320 + (i - 4) * 36, 90 + absf(i - 4) * 10)
		draw_circle(c, 34.0, Color(LEAF, 0.85).darkened(0.5 - k * 0.3))
	# The meteor at the crown: its cyan light gutters out over the first two cards.
	var m := clampf(1.0 - t / (CARD_TIME * 2.0), 0.0, 1.0)
	if m > 0.0:
		draw_circle(Vector2(320, 70), 22.0, Color(DUSK, 1.0))
		draw_circle(Vector2(320, 70), 22.0 * m, Color(METEOR, 0.6 * m))
		draw_circle(Vector2(320, 70), 8.0 * m, Color(TEXT, m))
	# Its light falls away as motes.
	for i in 16:
		var f := fmod(t * 0.4 + i / 16.0, 1.0)
		var at := Vector2(320 + sin(i * 2.3) * 60.0 * f, 70 + f * 200.0)
		draw_rect(Rect2(at, Vector2(2, 2)), Color(METEOR, (1.0 - f) * clampf(2.0 - t / CARD_TIME, 0.0, 1.0)))
	# The three springs light up the trunk once the light is gone, one per second.
	for i in 3:
		var lit := clampf(t - CARD_TIME * 2.0 - i, 0.0, 1.0)
		var at := Vector2(320, 320 - i * 70)
		draw_circle(at, 7.0, Color(WATER, 0.25 + 0.75 * lit))
		draw_circle(at, 3.0, Color(WATER_LIGHT, lit))
		if lit > 0.0:
			draw_rect(Rect2(at.x - 1, at.y, 2, (360.0 - at.y) * lit), Color(WATER, 0.5 * lit))
	if secret:
		_draw_source()
	_draw_wanderer()
	# The card, fading in and out.
	if card < cards().size():
		var into := t - card * CARD_TIME
		var a := clampf(minf(into / 0.6, (CARD_TIME - into) / 0.6), 0.0, 1.0)
		_centered(300.0, cards()[card], 12, Color(TEXT, a))


## The farewell: the hero, a dark shape against the dawn, walks off east from
## the foot of the Tree with the cloak's own walk.
func _draw_wanderer() -> void:
	var x := wanderer_x()
	if x < 0.0 or x > 700.0:
		return
	var into := t - farewell_start()
	var f := Sheet.frame_at(PlayerVisual.SHEET_NAME, "run", into * WALK_RATE)
	var a := clampf(into / 0.8, 0.0, 1.0)
	draw_set_transform(Vector2(roundf(x), 358.0))
	PlayerVisual.draw_frame(self, "run", f, Color(BARK_DARK.darkened(0.4), a), true)
	draw_set_transform(Vector2.ZERO)


## The secret ending: the Source wakes under the roots, its water climbs the
## trunk to the crown, and the crown flowers in gold.
func _draw_source() -> void:
	var start := EPILOGUE.size() * CARD_TIME
	var wake := clampf((t - start) / 1.5, 0.0, 1.0)
	if wake <= 0.0:
		return
	# The spring at the roots, a ring of light pulsing out from it.
	var root := Vector2(320, 352)
	draw_circle(root, 30.0 * wake, Color(WATER, 0.18 * wake))
	draw_circle(root, 12.0 * wake, Color(WATER, 0.8 * wake))
	draw_circle(root, 5.0 * wake, Color(WATER_LIGHT, wake))
	var ring := fmod(t - start, 1.2) / 1.2
	draw_arc(root, 12.0 + ring * 50.0, PI, TAU, 24, Color(WATER_LIGHT, (1.0 - ring) * 0.6 * wake), 2.0)
	# Its water climbs the trunk over the second card, to the crown.
	var climb_k := clampf((t - start - CARD_TIME) / CARD_TIME, 0.0, 1.0)
	if climb_k > 0.0:
		var top := lerpf(352.0, 80.0, climb_k)
		draw_rect(Rect2(316, top, 8, 352.0 - top), Color(WATER, 0.55))
		draw_rect(Rect2(319, top, 2, 352.0 - top), Color(WATER_LIGHT, 0.8))
		for i in 6:
			var f := fmod((t - start) * 0.8 + i / 6.0, 1.0)
			var y := lerpf(352.0, top, f)
			draw_rect(Rect2(317 + sin(i * 2.1 + t) * 3.0, y, 2, 2), Color(WATER_LIGHT, 1.0 - f))
	# Then the crown flowers.
	var bloom := clampf((t - start - CARD_TIME * 2.0) / 1.5, 0.0, 1.0)
	for i in 22:
		var at := Vector2(320 + sin(i * 2.7) * 150.0, 96 + cos(i * 1.9) * 26.0 + absf(sin(i * 2.7)) * 30.0)
		var r := (2.0 + float(i % 3)) * bloom
		if r > 0.0:
			draw_circle(at, r + 1.0, Color(OUTLINE, 0.6))
			draw_circle(at, r, GOLD if i % 2 else Color("f0e0f0"))


# --- The credits: a climb up the whole Tree ------------------------------------------

## The trunk's half-width at a height up the climb (pixels from the roots).
func _half_width(h: float) -> float:
	return lerpf(110.0, 40.0, clampf(h / CLIMB, 0.0, 1.0))


func _draw_climb() -> void:
	var k := climb / CLIMB
	# The sky: night at the roots, dawn at the crown.
	_sky(k)
	# The sun comes up behind the crown at the very top.
	var sun := clampf((k - 0.8) / 0.2, 0.0, 1.0)
	if sun > 0.0:
		draw_circle(Vector2(470, 120 - sun * 40.0), 30.0, Color(GOLD, 0.25 * sun))
		draw_circle(Vector2(470, 120 - sun * 40.0), 20.0, Color(Color("fff0c0"), sun))
	# Screen y of a height h up the Tree (the view's bottom edge is at `climb`).
	var bottom := climb
	# The ground and the houses of Eolis at the roots.
	var ground_y := 360.0 + bottom - 40.0
	if ground_y < 400.0:
		draw_rect(Rect2(0, ground_y, 640, 400), BARK_DARK.darkened(0.3))
		for i in 6:
			var x := 40.0 + i * 100.0 + (60.0 if i >= 3 else 0.0)
			draw_rect(Rect2(x, ground_y - 30, 34, 30), Color("6b6380"))
			draw_colored_polygon(PackedVector2Array([Vector2(x - 4, ground_y - 30), Vector2(x + 17, ground_y - 48), Vector2(x + 38, ground_y - 30)]), Color("8a3a2a"))
			draw_rect(Rect2(x + 12, ground_y - 22, 8, 8), Color(GOLD, 0.8))
	# The trunk in slices, bark bands scrolling past.
	var step := 6.0
	var y := 0.0
	while y < 360.0:
		var h := bottom + (360.0 - y) - 40.0
		if h >= -40.0 and h <= CROWN:
			var hw := _half_width(h)
			draw_rect(Rect2(320 - hw - 2, y, hw * 2 + 4, step), OUTLINE)
			draw_rect(Rect2(320 - hw, y, hw * 2, step), BARK)
			var band := int(h / 6.0)
			if band % 7 == 0:
				draw_rect(Rect2(320 - hw * 0.8, y, hw * 1.6, 2), BARK_DARK)
			if band % 11 == 3:
				draw_rect(Rect2(320 - hw * 0.4 + sin(band) * hw * 0.3, y, 10, step), BARK_LIGHT)
		y += step
	# Branches every so often, alternating sides, with leaves; thicker leaves up high.
	var first := int(floor(bottom / 260.0))
	for b in range(first, first + 3):
		var h := b * 260.0 + 120.0
		var sy := 360.0 - (h - bottom) - 40.0
		if sy < -60.0 or sy > 420.0 or h > CLIMB:
			continue
		var side := -1.0 if b % 2 == 0 else 1.0
		var root := Vector2(320 + side * _half_width(h) * 0.8, sy)
		var tip := root + Vector2(side * 200.0, -60.0)
		draw_line(root, tip, OUTLINE, 14.0)
		draw_line(root, tip, BARK, 10.0)
		var leafy := clampf(h / CLIMB + 0.3, 0.3, 1.0)
		for i in 5:
			draw_circle(tip + Vector2(side * (i - 2) * 22.0, -10.0 + sin(i * 1.7) * 12.0), 20.0 * leafy, LEAF)
			draw_circle(tip + Vector2(side * (i - 2) * 22.0 - 4.0, -14.0 + sin(i * 1.7) * 12.0), 9.0 * leafy, LEAF_LIGHT)
	# The crown: a spread of leaves where the meteor was.
	var cy := 360.0 - (CROWN - bottom) - 40.0
	if cy > -80.0 and cy < 440.0:
		for layer in 2:
			for i in 11:
				var c := Vector2(320 + (i - 5) * 40.0, cy - 10.0 + absf(i - 5) * 8.0 - layer * 26.0)
				draw_circle(c, 34.0 - layer * 6.0, LEAF.lerp(LEAF_LIGHT, layer * 0.4))
				draw_circle(c + Vector2(-8, -10), 10.0, Color(LEAF_LIGHT, 0.6))
	# The springs in the trunk, running clear, at the Trunk, the Mist and Daybreak.
	for f in [0.13, 0.38, 0.63]:
		var h: float = f * CLIMB
		var sy := 360.0 - (h - bottom) - 40.0
		if sy > -20.0 and sy < 380.0:
			draw_circle(Vector2(320, sy), 9.0, WATER)
			draw_circle(Vector2(320, sy), 4.0, WATER_LIGHT)
			draw_rect(Rect2(318, sy, 4, 60), Color(WATER, 0.5))
	# The zone you are passing, at the left.
	for z: Array in ZONES:
		var h: float = float(z[1]) * CLIMB
		var sy := 360.0 - (h - bottom) - 40.0
		if sy > 20.0 and sy < 350.0:
			PixelFont.draw(self, Vector2(24, sy), String(z[0]), 12, Color(GOLD, 0.9), OUTLINE)
			draw_rect(Rect2(24, sy + 4, PixelFont.width(String(z[0]), 12), 1), Color(GOLD, 0.5))
	# The credits rise through the middle of the screen over the whole climb.
	var top := lerpf(380.0, -credits_height() - 20.0, k)
	for i in CREDITS.size():
		var line: Array = CREDITS[i]
		var ly := top + i * LINE_GAP
		if ly < -20.0 or ly > 380.0 or String(line[0]) == "":
			continue
		var size := 24 if int(line[1]) == 2 else 12
		var color := GOLD if int(line[1]) == 2 else (TEXT if int(line[1]) == 1 else SUB)
		_centered(ly, String(line[0]), size, color)
	if fast:
		PixelFont.draw(self, Vector2(560, 350), ">> x4", 12, Color(SUB, 0.7), OUTLINE)


# --- Thanks --------------------------------------------------------------------------

## Night at the roots warming to dawn: a gradient in thin bands.
func _sky(k: float) -> void:
	for i in 60:
		var low := float(i) / 59.0
		var c := NIGHT.lerp(DAWN_HIGH, k * 0.6).lerp(DAWN, k * 0.55 * low * low)
		draw_rect(Rect2(0, i * 6, 640, 6), c)


func _draw_thanks() -> void:
	_sky(1.0)
	var a := clampf(t / 0.8, 0.0, 1.0)
	_centered(56.0, "Thank you for playing", 24, Color(GOLD, a))
	var y := 100.0
	if not stats.is_empty():
		# The rows count up over COUNT_TIME as the card fades in.
		var k := clampf(t / COUNT_TIME, 0.0, 1.0)
		var shown := int(floor(int(stats.get("percent", 0)) * k))
		_centered(y, "%d%%" % shown, 24, Color(GOLD if shown >= 100 else TEXT, a))
		_centered(y + 26.0, "of the world", 12, Color(SUB, a))
		y += 52.0
		for row: Array in completion_rows():
			var label: String = row[0]
			var got := int(floor(int(row[1]) * k))
			_row(y, label, "%d / %d" % [got, int(row[2])], Color(GOLD if got >= int(row[2]) else TEXT, a))
			y += 16.0
		y += 8.0
	if rank != "":
		_row(y, "Rank", rank, Color(TEXT, a))
		y += 16.0
	var mins := int(seconds / 60.0)
	_row(y, "Time", "%d:%02d" % [mins / 60, mins % 60], Color(TEXT, a))
	_row(y + 16.0, "Deaths", "%d" % deaths, Color(TEXT, a))
	y += 32.0
	if int(stats.get("clears", 0)) > 1:
		_row(y, "Clears", "%d" % int(stats.clears), Color(TEXT, a))
		y += 16.0
	if secret:
		_centered(y + 6.0, "The Source runs again.", 12, Color(WATER_LIGHT, a))
		_centered(y + 22.0, "A flawless climb, in the Warden's Battle Suit.", 12, Color(GOLD, a))
	if t >= THANKS_GRACE:
		_centered(334.0, "Press jump to return to the title", 12, Color(SUB, 0.5 + 0.5 * sin(t * 3.0)))


## The completion card's counted rows: [label, found, total].
func completion_rows() -> Array:
	return [
		["Rooms explored", stats.get("rooms", 0), stats.get("rooms_total", 0)],
		["Hidden rooms", stats.get("secrets", 0), stats.get("secrets_total", 0)],
		["Treasures", stats.get("treasures", 0), stats.get("treasures_total", 0)],
		["Bosses", stats.get("bosses", 0), stats.get("bosses_total", 0)],
	]


## A label on the left of the middle and its value on the right, on one line.
func _row(y: float, label: String, value: String, color: Color) -> void:
	PixelFont.draw(self, Vector2(roundf(312.0 - PixelFont.width(label, 12)), y), label, 12, Color(SUB, color.a), OUTLINE)
	PixelFont.draw(self, Vector2(328.0, y), value, 12, color, OUTLINE)
