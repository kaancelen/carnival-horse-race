class_name FinishLine
extends Control
## FinishLine
## -----------------------------------------------------------------------
## Checkered finish-line strip along the right edge of the race track
## (design/ui-prototype.html, "07 GAMEPLAY" .finish).
## -----------------------------------------------------------------------

const SQUARE := 12.0
const LIGHT := Color("ffffff")
const DARK := Color("111111")


func _ready() -> void:
	resized.connect(queue_redraw)


func _draw() -> void:
	var cols := int(ceil(size.x / SQUARE))
	var rows := int(ceil(size.y / SQUARE))
	for row in rows:
		for col in cols:
			var light := (row + col) % 2 == 0
			draw_rect(Rect2(col * SQUARE, row * SQUARE, SQUARE, SQUARE), LIGHT if light else DARK)
