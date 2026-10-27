class_name RetroFilter
extends CanvasLayer
## Eolis of Old (design bible 11, pass 152): over a room whose header says
## `retro: true`, the world is drawn as the NES drew it: chunky pixels in a 4:3
## frame and only the NES palette's colours (shaders/retro.gdshader). It sits
## under the game's UI layer, so the HUD stays as it is.

const SHADER := preload("res://shaders/retro.gdshader")
const LAYER := 4
## The world's view in world pixels is 360 tall (game.gd's BASE_SIZE).
const VIEW_HEIGHT := 360.0
## The 4:3 frame's shape (the shader's frame_aspect). A retro room is one screen
## wide, so the columns outside the frame must be wall: nothing there can be seen.
const FRAME_ASPECT := 4.0 / 3.0

var _rect: ColorRect
var _mat: ShaderMaterial


func _ready() -> void:
	layer = LAYER
	visible = false
	_rect = ColorRect.new()
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_mat = ShaderMaterial.new()
	_mat.shader = SHADER
	_rect.material = _mat
	add_child(_rect)


## Turns the filter on in a retro room and off everywhere else.
func set_room(room: Room) -> void:
	visible = is_retro(room)
	if visible:
		_mat.set_shader_parameter("detail", detail_for(get_viewport()))


## Render pixels per world pixel in `vp`: the game's world view draws at
## GameCamera.DETAIL with a margin, a bare window (tests) at 1.
static func detail_for(vp: Viewport) -> float:
	if vp == null:
		return 1.0
	var h: float = vp.get_visible_rect().size.y
	return maxf(1.0, floorf(h / VIEW_HEIGHT))


static func is_retro(room: Room) -> bool:
	return room != null and str(room.header.get("retro", "")) == "true"


## The tile columns [first, last] a one-screen room shows inside the 4:3 frame.
static func visible_columns(view := Vector2(640, 360), tile := 16) -> Vector2i:
	var margin := (view.x - view.y * FRAME_ASPECT) * 0.5
	return Vector2i(ceili(margin / tile), floori((view.x - margin) / tile) - 1)
