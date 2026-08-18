class_name ArcHint
extends Control
## ArcHint
## -----------------------------------------------------------------------
## Faint upward-fading trajectory cue above the ball, hinting the throw
## direction (design/ui-prototype.html, "07 GAMEPLAY" .arc).
## -----------------------------------------------------------------------

const BOTTOM_COLOR := Color("ffe9a8")
const STEPS := 24


func _ready() -> void:
	resized.connect(queue_redraw)


func _draw() -> void:
	for i in STEPS:
		var t0 := float(i) / STEPS
		var t1 := float(i + 1) / STEPS
		var y0 := size.y * (1.0 - t0)
		var y1 := size.y * (1.0 - t1)
		var color := Color(BOTTOM_COLOR, 1.0 - t0)
		draw_line(Vector2(size.x / 2.0, y0), Vector2(size.x / 2.0, y1), color, 3.0)
