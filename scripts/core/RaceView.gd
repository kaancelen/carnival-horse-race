extends Panel
## RaceView
## -----------------------------------------------------------------------
## Visual half of the race: one horse marker per lane, moved along the
## lane's width as GameEvents.race_positions_updated reports progress.
## Lane index -> racer_id mapping matches RaceManager.setup_race()'s
## racer_ids order (player first, then AI lanes).
## -----------------------------------------------------------------------

const HORSE_COLORS := [
	Color(0.95, 0.85, 0.2),  # player - gold
	Color(0.85, 0.3, 0.3),
	Color(0.3, 0.6, 0.85),
	Color(0.5, 0.8, 0.4),
	Color(0.75, 0.4, 0.85),
]

var _horse_by_racer: Dictionary = {}
var _lane_nodes: Array[Control] = []


func _ready() -> void:
	_lane_nodes = [$Lanes/Lane1, $Lanes/Lane2, $Lanes/Lane3, $Lanes/Lane4, $Lanes/Lane5]
	GameEvents.race_started.connect(_on_race_started)
	GameEvents.race_positions_updated.connect(_on_positions_updated)


func _on_race_started(_level_id: int) -> void:
	for horse in _horse_by_racer.values():
		horse.queue_free()
	_horse_by_racer.clear()
	for racer_id in GameState.RACER_COUNT:
		var lane: Control = _lane_nodes[racer_id]
		var marker := _make_horse_marker(racer_id)
		lane.add_child(marker)
		_horse_by_racer[racer_id] = marker
		_position_marker(marker, lane, 0.0)


func _on_positions_updated(progress_by_racer: Dictionary) -> void:
	for racer_id in progress_by_racer:
		var marker: Control = _horse_by_racer.get(racer_id)
		if marker == null:
			continue
		_position_marker(marker, _lane_nodes[racer_id], progress_by_racer[racer_id])


func _position_marker(marker: Control, lane: Control, progress: float) -> void:
	var usable_width: float = maxf(lane.size.x - marker.size.x, 1.0)
	var tween := create_tween()
	tween.tween_property(marker, "position:x", usable_width * progress, 0.25)


func _make_horse_marker(racer_id: int) -> Control:
	var marker := Panel.new()
	marker.size = Vector2(28, 16)
	marker.position = Vector2(0, 2)
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = HORSE_COLORS[racer_id % HORSE_COLORS.size()]
	style.set_corner_radius_all(6)
	marker.add_theme_stylebox_override("panel", style)
	return marker
