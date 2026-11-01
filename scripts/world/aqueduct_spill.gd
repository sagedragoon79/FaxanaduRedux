class_name AqueductSpill
extends Node2D
## The broken aqueduct (room prop `aqueduct_spill`, pass 371), a Sunken Spring
## landmark in the Drowned Aqueduct: the end of the dwarves' stone channel,
## snapped off where it left the ceiling, still pouring the spring in a white
## fall into the flood below. The sheet ripples, foam churns where it lands,
## and spray jumps off the surface. Scenery only (the fall never pushes the
## player). The origin is the channel's mouth, under the ceiling; the fall
## drops FALL pixels to the water.
##
## It is heard (pass 374): a looping pour (`falls_pour`) that is loudest beside
## the fall and fades over HEAR pixels, silent beyond, the way the forge's
## anvil carries (`heard_db`).

const FALL := 112.0
const WIDTH := 10.0
const OUTLINE := Color("0c141c")
const STONE := Color("5a6a78")
const STONE_LIGHT := Color("8a9aa6")
const STONE_DARK := Color("36424e")
const WATER := Color("8ad0e0")
const WATER_LIGHT := Color("d8f6f8")
const WATER_DARK := Color("4a90a8")
const FOAM := Color("f0fcfc")

## The pour's loop and how far it carries: LOUD dB over the sound volume where
## the water lands, falling FADE dB across HEAR pixels, and silent past it.
const SOUND := "falls_pour"
const HEAR := 320.0
const LOUD := -4.0
const FADE := 22.0

var t := 0.0
var _voice: AudioStreamPlayer


func _ready() -> void:
	z_index = -1
	_voice = AudioStreamPlayer.new()
	_voice.bus = "Sfx"
	var wav := load(Sfx.SFX_DIR + SOUND + ".wav") as AudioStreamWAV
	if wav != null:
		wav = wav.duplicate() as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = int(wav.get_length() * wav.mix_rate)
		_voice.stream = wav
	add_child(_voice)


## Where the water lands, in the world.
func foot() -> Vector2:
	return global_position + Vector2(0, FALL)


## How loud the pour is for a listener at `at` (dB, over the sound volume), or
## -INF out of earshot.
func heard_db(at: Vector2) -> float:
	var d := at.distance_to(foot())
	if d >= HEAR:
		return -INF
	return LOUD - FADE * d / HEAR


func _process(delta: float) -> void:
	t += delta
	queue_redraw()
	var p := get_tree().get_first_node_in_group("player") as Node2D
	var db := heard_db(p.global_position) if p != null else -INF
	if db == -INF or Sfx.silent or _voice.stream == null:
		if _voice.playing:
			_voice.stop()
		return
	_voice.volume_db = Sfx.volume_db + db
	if not _voice.playing:
		_voice.play()


func _px(x: float, y: float, w: float, h: float, c: Color) -> void:
	draw_rect(Rect2(roundf(x), roundf(y), w, h), c)


func _draw() -> void:
	# The channel: a stone trough jutting from the left, its broken end jagged.
	_px(-41, -1, 38, 13, OUTLINE)
	_px(-40, 0, 36, 11, STONE)
	_px(-40, 0, 36, 2, STONE_LIGHT)
	_px(-40, 9, 36, 2, STONE_DARK)
	for j: Vector2 in [Vector2(-5, 2), Vector2(-3, 5), Vector2(-6, 8)]:
		_px(j.x, j.y, 3, 3, OUTLINE)
	# Brackets that once held it to the wall, one still there, one sheared.
	_px(-34, 11, 4, 8, OUTLINE)
	_px(-33, 11, 2, 7, STONE_DARK)
	_px(-14, 11, 4, 3, OUTLINE)
	# The lip of water leaving the trough and curving down.
	_px(-WIDTH * 0.5 - 1, 2, WIDTH + 2, 6, OUTLINE)
	_px(-WIDTH * 0.5, 3, WIDTH, 5, WATER)
	_px(-WIDTH * 0.5, 3, WIDTH, 1, WATER_LIGHT)
	# The fall: a sheet with streaks running down it, a little wider as it drops.
	var y := 8.0
	while y < FALL:
		var w := WIDTH + (y / FALL) * 4.0
		_px(-w * 0.5, y, w, 2, WATER)
		_px(-w * 0.5, y, 1, 2, WATER_DARK)
		_px(w * 0.5 - 1, y, 1, 2, WATER_DARK)
		y += 2.0
	for s in 3:
		var sx := -WIDTH * 0.5 + 2 + s * 3
		var off := fmod(t * 160.0 + s * 37.0, 24.0)
		var sy := 8.0 + off
		while sy < FALL:
			_px(sx, sy, 1, 6, WATER_LIGHT)
			sy += 24.0
	# Foam where it lands, churning, and spray thrown off either side.
	for i in 5:
		var fx := -12.0 + i * 6.0 + sin(t * 6.0 + i) * 1.5
		var fh := 3.0 + 2.0 * (0.5 + 0.5 * sin(t * 9.0 + i * 1.9))
		_px(fx, FALL - fh, 5, fh + 1, FOAM)
	for i in 4:
		var phase := fmod(t * 1.6 + i * 0.25, 1.0)
		var side := -1.0 if i % 2 == 0 else 1.0
		var px := side * (8.0 + phase * 14.0)
		var py := FALL - 4.0 - sin(phase * PI) * 12.0
		_px(px, py, 2, 2, Color(FOAM, 1.0 - phase))
