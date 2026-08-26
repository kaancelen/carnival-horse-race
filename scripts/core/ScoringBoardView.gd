extends Panel
## ScoringBoardView
## -----------------------------------------------------------------------
## Visual scoring board: maps each hole Panel in the scene to its
## ScoringHole data (id/tier/points) and lets BallThrower hit-test a
## swipe's release position against them. Also owns the "07 GAMEPLAY"
## juice from design/ui-prototype.html: the point value printed inside
## each hole, the "N PTS" caption under it, the pop-on-hit animation and
## the "+N!" toast when the player scores.
## -----------------------------------------------------------------------

const GOLD := Color("f5b942")
const RED_DARK := Color("8f2019")
const INK := Color("22120a")
const CREAM := Color("f8edd6")

const ALFA_SLAB := preload("res://assets/fonts/AlfaSlabOne-Regular.ttf")
const BUNGEE := preload("res://assets/fonts/Bungee-Regular.ttf")

## Real hitbox is a bit tighter than the drawn circle — a clean center hit
## should feel earned, not just "close enough".
const HOLE_HIT_FACTOR := 0.8

var _holes: Array[ScoringHole] = []
var _hole_nodes: Dictionary = {}


func _ready() -> void:
	add_to_group(&"scoring_board")
	_holes = ScoringHole.default_layout()
	_hole_nodes = {
		&"red": $Holes/RedRow/HoleRed,
		&"yellow_l": $Holes/YellowRow/HoleYellowL,
		&"yellow_r": $Holes/YellowRow/HoleYellowR,
		&"green_l": $Holes/GreenRow/HoleGreenL,
		&"green_c": $Holes/GreenRow/HoleGreenC,
		&"green_r": $Holes/GreenRow/HoleGreenR,
	}
	for hole in _holes:
		_decorate_hole(hole)

	GameEvents.ball_landed.connect(_on_ball_landed)
	GameEvents.racer_scored.connect(_on_racer_scored)


## Physical hit test for the thrown ball's current position — a real
## projectile either overlaps a hole's (slightly tightened) circle or it
## doesn't. No more "closest hole wins" auto-targeting.
func hole_at_point(global_pos: Vector2) -> ScoringHole:
	for hole in _holes:
		var node: Control = _hole_nodes.get(hole.id)
		if node == null:
			continue
		var rect := node.get_global_rect()
		var radius: float = rect.size.x / 2.0 * HOLE_HIT_FACTOR
		if rect.get_center().distance_to(global_pos) <= radius:
			return hole
	return null


func _decorate_hole(hole: ScoringHole) -> void:
	var node: Control = _hole_nodes.get(hole.id)
	if node == null:
		return

	var text_color := INK if hole.tier == ScoringHole.Tier.YELLOW else CREAM

	var value := Label.new()
	value.text = str(hole.points)
	value.anchor_right = 1.0
	value.anchor_bottom = 1.0
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	value.mouse_filter = Control.MOUSE_FILTER_IGNORE
	value.add_theme_font_override("font", BUNGEE)
	value.add_theme_font_size_override("font_size", int(node.custom_minimum_size.y * 0.38))
	value.add_theme_color_override("font_color", text_color)
	node.add_child(value)

	var caption := Label.new()
	caption.text = "%d PTS" % hole.points if hole.tier != ScoringHole.Tier.GREEN else str(hole.points)
	caption.anchor_left = 0.5
	caption.anchor_right = 0.5
	caption.anchor_top = 1.0
	caption.anchor_bottom = 1.0
	caption.offset_left = -60.0
	caption.offset_right = 60.0
	caption.offset_top = 6.0
	caption.offset_bottom = 26.0
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caption.add_theme_font_override("font", BUNGEE)
	caption.add_theme_font_size_override("font_size", 14)
	caption.add_theme_color_override("font_color", Color("d8be8a"))
	node.add_child(caption)

	node.pivot_offset = node.custom_minimum_size / 2.0


func _on_ball_landed(racer_id: int, hole_id: StringName) -> void:
	if racer_id != GameState.player_racer_id:
		return
	var node: Control = _hole_nodes.get(hole_id)
	if node == null:
		return
	var tween := create_tween()
	tween.tween_property(node, "scale", Vector2.ONE * 1.22, 0.15) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2.ONE, 0.2) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _on_racer_scored(racer_id: int, points: int, _hole_id: StringName) -> void:
	if racer_id != GameState.player_racer_id:
		return
	_show_toast(points)


func _show_toast(points: int) -> void:
	var label := Label.new()
	label.text = "+%d!" % points
	label.add_theme_font_override("font", ALFA_SLAB)
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", GOLD)
	label.add_theme_color_override("font_outline_color", RED_DARK)
	label.add_theme_constant_override("outline_size", 5)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.anchor_left = 0.5
	label.anchor_right = 0.5
	label.anchor_top = 0.16
	label.anchor_bottom = 0.16
	label.offset_left = -120.0
	label.offset_right = 120.0
	label.offset_top = 0.0
	label.offset_bottom = 70.0
	label.modulate.a = 0.0
	add_child(label)

	var start_y := label.position.y
	var tween := create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(label, "position:y", start_y - 30.0, 1.2)
	tween.tween_interval(0.6)
	tween.tween_property(label, "modulate:a", 0.0, 0.3)
	tween.tween_callback(label.queue_free)
