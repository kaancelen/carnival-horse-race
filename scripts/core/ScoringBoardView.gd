extends Panel
## ScoringBoardView
## -----------------------------------------------------------------------
## Visual scoring board: maps each hole Panel in the scene to its
## ScoringHole data (id/tier/points) and lets BallThrower hit-test a
## swipe's release position against them.
## -----------------------------------------------------------------------

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


func closest_hole_to_x(global_x: float) -> ScoringHole:
	var best: ScoringHole = null
	var best_dist := INF
	for hole in _holes:
		var node: Control = _hole_nodes.get(hole.id)
		if node == null:
			continue
		var center_x: float = node.get_global_rect().get_center().x
		var dist: float = absf(center_x - global_x)
		if dist < best_dist:
			best_dist = dist
			best = hole
	return best


func global_landing_point(hole_id: StringName) -> Vector2:
	var node: Control = _hole_nodes.get(hole_id)
	if node == null:
		return get_global_rect().get_center()
	return node.get_global_rect().get_center()
