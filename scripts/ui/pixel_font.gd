class_name PixelFont
extends RefCounted
## The game's bitmap pixel font (design bible 12), built at runtime from
## assets/fonts/pixel.png and pixel.json (tools/art/fontgen.py). One texel per UI
## pixel; it only ever scales by whole numbers, so text stays crisp under the
## window's integer stretch (see `scale_for`).
##
## Bitmap fonts can't be outlined by the text server, so `draw` outlines by
## stamping the string one texel around in eight directions first.

const PNG := "res://assets/fonts/pixel.png"
const META := "res://assets/fonts/pixel.json"

static var _font: FontFile
static var _height := 11


## The shared FontFile.
static func font() -> FontFile:
	if _font == null:
		_font = _build()
	return _font


## The font's native line height in UI pixels (ascent plus descent).
static func height() -> int:
	font()
	return _height


## The whole-number scale a requested size draws at: the nearest multiple of the
## native height, at least 1 (so 8 to 16 draw at 1x, 17 to 27 at 2x).
static func scale_for(size: int) -> int:
	return maxi(1, roundi(float(size) / height()))


## The draw size that gives `scale_for(size)`: what to pass to the Font API.
static func size_for(size: int) -> int:
	return scale_for(size) * height()


static func width(text: String, size: int) -> float:
	return font().get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_for(size)).x


## Draws `text` with its baseline at `pos` (as draw_string does), in whole UI
## pixels, with an optional one-texel outline in `outline`.
static func draw(ci: CanvasItem, pos: Vector2, text: String, size: int, color: Color, outline := Color(0, 0, 0, 0)) -> void:
	var f := font()
	var s := size_for(size)
	var at := pos.round()
	if outline.a > 0.0:
		var k := float(scale_for(size))
		for d: Vector2 in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1), Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]:
			ci.draw_string(f, at + d * k, text, HORIZONTAL_ALIGNMENT_LEFT, -1, s, outline)
	ci.draw_string(f, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, s, color)


## Wrapped text, `width` UI pixels wide, lines `line_gap` pixels apart beyond the
## font's height. Returns the number of lines drawn.
static func draw_wrapped(ci: CanvasItem, pos: Vector2, text: String, width_px: float, size: int, color: Color, line_gap := 2) -> int:
	var lines := wrap_lines(text, width_px, size)
	var step := float(size_for(size) + line_gap * scale_for(size))
	for i in lines.size():
		draw(ci, pos + Vector2(0, i * step), lines[i], size, color)
	return lines.size()


## Splits `text` into lines no wider than `width_px` at `size`, on spaces and
## explicit newlines.
static func wrap_lines(text: String, width_px: float, size: int) -> PackedStringArray:
	var out := PackedStringArray()
	for para in text.split("\n"):
		var line := ""
		for word in para.split(" ", false):
			var tryline: String = word if line == "" else line + " " + word
			if line != "" and width(tryline, size) > width_px:
				out.append(line)
				line = word
			else:
				line = tryline
		out.append(line)
	return out


static func _build() -> FontFile:
	var meta: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(META))
	_height = int(meta.height)
	var ascent := int(meta.ascent)
	var img := (load(PNG) as Texture2D).get_image()
	var f := FontFile.new()
	f.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	f.generate_mipmaps = false
	f.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	f.hinting = TextServer.HINTING_NONE
	f.fixed_size = _height
	f.fixed_size_scale_mode = TextServer.FIXED_SIZE_SCALE_INTEGER_ONLY
	var sz := Vector2i(_height, 0)
	f.set_cache_ascent(0, _height, ascent)
	f.set_cache_descent(0, _height, _height - ascent)
	f.set_texture_image(0, sz, 0, img)
	var glyphs: Dictionary = meta.glyphs
	for key: String in glyphs:
		var g: Dictionary = glyphs[key]
		var code := int(key)
		f.set_glyph_advance(0, _height, code, Vector2(float(g.advance), 0))
		f.set_glyph_offset(0, sz, code, Vector2(0, -ascent))
		f.set_glyph_size(0, sz, code, Vector2(float(g.w), _height))
		f.set_glyph_uv_rect(0, sz, code, Rect2(float(g.x), 0, float(g.w), _height))
		f.set_glyph_texture_idx(0, sz, code, 0)
	f.set_glyph_advance(0, _height, 32, Vector2(float(meta.space), 0))
	f.set_glyph_size(0, sz, 32, Vector2.ZERO)
	f.set_glyph_texture_idx(0, sz, 32, -1)
	return f
