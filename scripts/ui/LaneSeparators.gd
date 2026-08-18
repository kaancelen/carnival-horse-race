class_name LaneSeparators
extends Control
## LaneSeparators
## -----------------------------------------------------------------------
## Dashed horizontal lines between race lanes (design/ui-prototype.html,
## "07 GAMEPLAY" .lane border-bottom).
## -----------------------------------------------------------------------

const DASH_COLOR := Color(1, 1, 1, 0.25)

var lane_count: int = 5


func _ready() -> void:
	resized.connect(queue_redraw)


func _draw() -> void:
	if lane_count <= 1:
		return
	var lane_h := size.y / float(lane_count)
	for i in range(1, lane_count):
		var y := lane_h * i
		draw_dashed_line(Vector2(0, y), Vector2(size.x, y), DASH_COLOR, 2.0, 8.0)
