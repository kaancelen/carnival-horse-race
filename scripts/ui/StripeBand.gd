class_name StripeBand
extends Control
## StripeBand
## -----------------------------------------------------------------------
## Generic vertical candy-stripe band (design/ui-prototype.html uses this
## pattern for both the crowd silhouette and the red/cream banner in the
## "07 GAMEPLAY" race track).
## -----------------------------------------------------------------------

@export var colors: Array[Color] = []
@export var stripe_width: float = 20.0


func _ready() -> void:
	resized.connect(queue_redraw)


func _draw() -> void:
	if colors.is_empty():
		return
	var w := size.x
	var h := size.y
	var x := 0.0
	var i := 0
	while x < w:
		draw_rect(Rect2(x, 0, stripe_width, h), colors[i % colors.size()])
		x += stripe_width
		i += 1
