class_name TentTop
extends Control
## TentTop
## -----------------------------------------------------------------------
## Festoon tent valance strip from the Retro Carnival design system
## (design/ui-prototype.html, .tent-top): candy-striped band with a
## scalloped trim along the bottom edge.
## -----------------------------------------------------------------------

const RED := Color("c8352c")
const CREAM := Color("f8edd6")
const STRIPE_WIDTH := 42.0
const SCALLOP_RADIUS := 21.0


func _ready() -> void:
	resized.connect(queue_redraw)


func _draw() -> void:
	var w := size.x
	var h := size.y

	var x := 0.0
	var i := 0
	while x < w:
		var color := RED if i % 2 == 0 else CREAM
		draw_rect(Rect2(x, 0, STRIPE_WIDTH, h), color)
		x += STRIPE_WIDTH
		i += 1

	var cx := 0.0
	while cx < w + SCALLOP_RADIUS:
		draw_circle(Vector2(cx, h), SCALLOP_RADIUS, RED)
		cx += SCALLOP_RADIUS * 2.0
