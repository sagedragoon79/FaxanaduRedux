class_name SetPiece
extends Node2D
## A still building or monument from Sean's PixelLab objects (design bible 13.6),
## drawn from its Sheet (packed by tools/art/pixellab_objects.py) behind the
## people in front of it. The origin is the bottom center, on the floor.

## Room prop names that are set pieces; each is a sheet in assets/sprites/.
const NAMES := ["shop_arms", "shop_sundries", "shop_dyeworks", "shop_cartographer"]

var sheet := ""
var _t := 0.0


func _ready() -> void:
	z_index = -2


func _process(delta: float) -> void:
	if Sheet.get_sheet(sheet).animations.idle.seq.size() > 1:
		_t += delta
		queue_redraw()


func _draw() -> void:
	Sheet.draw(self, sheet, "idle", Sheet.frame_at(sheet, "idle", _t))
