extends Panel
## RaceView
## -----------------------------------------------------------------------
## Visual half of the race, styled to the Retro Carnival "07 GAMEPLAY"
## spec (design/ui-prototype.html): sky-to-ground gradient, crowd band,
## candy-stripe banner, dashed lane separators, numbered lane badges and
## a checkered finish line. Horses stay our own pixel-art sprites
## (HorseMarker) — not the design's emoji placeholders, ours are better.
## Lane index -> racer_id mapping matches RaceManager.setup_race()'s
## racer_ids order (player first, then AI lanes).
## -----------------------------------------------------------------------

const HORSE_TEXTURES := [
	preload("res://assets/sprites/horses/horse_gold.png"),      # player
	preload("res://assets/sprites/horses/horse_chestnut.png"),
	preload("res://assets/sprites/horses/horse_grey.png"),
	preload("res://assets/sprites/horses/horse_white.png"),
	preload("res://assets/sprites/horses/horse_pinto.png"),
]

const MARKER_SIZE := Vector2(176, 132)
const LANES_TOP_FRACTION := 0.26
const CROWD_HEIGHT_FRACTION := 0.22
const CROWD_COLORS: Array[Color] = [Color("2b2140"), Color("3a2b52"), Color("4a2f45")]
const BANNER_COLORS: Array[Color] = [Color("c8352c"), Color("f8edd6")]
const BADGE_TEXT_COLOR := Color("f8edd6")

var _horse_by_racer: Dictionary = {}
var _lane_nodes: Array[Control] = []


func _ready() -> void:
	_lane_nodes = [$Lanes/Lane1, $Lanes/Lane2, $Lanes/Lane3, $Lanes/Lane4, $Lanes/Lane5]
	$Lanes.anchor_top = LANES_TOP_FRACTION

	_build_sky()
	_build_crowd()
	_build_banner()
	_build_finish_line()
	_build_lane_separators()
	_build_lane_badges()
	move_child($Lanes, get_child_count() - 1)

	GameEvents.race_started.connect(_on_race_started)
	GameEvents.race_positions_updated.connect(_on_positions_updated)


func _build_sky() -> void:
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([
		Color("3e6e8c"), Color("6fa3b8"), Color("c9a96b"), Color("a8814b"),
	])
	gradient.offsets = PackedFloat32Array([0.0, 0.45, 0.46, 1.0])
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.width = 8
	tex.height = 512
	tex.fill = GradientTexture2D.FILL_LINEAR
	tex.fill_from = Vector2(0.5, 0.0)
	tex.fill_to = Vector2(0.5, 1.0)
	var bg := TextureRect.new()
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.texture = tex
	add_child(bg)


func _build_crowd() -> void:
	var band := StripeBand.new()
	band.anchor_right = 1.0
	band.anchor_bottom = CROWD_HEIGHT_FRACTION
	band.colors = CROWD_COLORS
	band.stripe_width = 15.0
	band.modulate.a = 0.85
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(band)


func _build_banner() -> void:
	var band := StripeBand.new()
	band.anchor_right = 1.0
	band.anchor_top = 0.18
	band.anchor_bottom = 0.18
	band.offset_bottom = 27.0
	band.colors = BANNER_COLORS
	band.stripe_width = 30.0
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(band)


func _build_finish_line() -> void:
	var finish := FinishLine.new()
	finish.anchor_left = 1.0
	finish.anchor_right = 1.0
	finish.anchor_top = LANES_TOP_FRACTION
	finish.anchor_bottom = 1.0
	finish.offset_left = -48.0
	finish.offset_right = -24.0
	finish.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(finish)


func _build_lane_separators() -> void:
	var sep := LaneSeparators.new()
	sep.anchor_right = 1.0
	sep.anchor_top = LANES_TOP_FRACTION
	sep.anchor_bottom = 1.0
	sep.lane_count = _lane_nodes.size()
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sep)


func _build_lane_badges() -> void:
	for i in _lane_nodes.size():
		_lane_nodes[i].add_child(_make_lane_badge(i + 1))


func _make_lane_badge(number: int) -> Control:
	var badge := Panel.new()
	badge.anchor_top = 0.5
	badge.anchor_bottom = 0.5
	badge.offset_left = 9.0
	badge.offset_top = -19.0
	badge.offset_right = 47.0
	badge.offset_bottom = 19.0
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.5)
	style.border_color = Color(1, 1, 1, 0.3)
	style.set_border_width_all(1)
	style.set_corner_radius_all(19)
	badge.add_theme_stylebox_override("panel", style)

	var label := Label.new()
	label.text = str(number)
	label.anchor_right = 1.0
	label.anchor_bottom = 1.0
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", BADGE_TEXT_COLOR)
	badge.add_child(label)

	return badge


func _on_race_started(_level_id: int) -> void:
	for horse in _horse_by_racer.values():
		horse.queue_free()
	_horse_by_racer.clear()
	for racer_id in GameState.RACER_COUNT:
		var lane: Control = _lane_nodes[racer_id]
		var marker := _make_horse_marker(racer_id)
		lane.add_child(marker)
		marker.position.y = (lane.size.y - marker.size.y) / 2.0
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
	var marker := HorseMarker.new()
	marker.size = MARKER_SIZE
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marker.set_horse_texture(HORSE_TEXTURES[racer_id % HORSE_TEXTURES.size()])
	return marker
