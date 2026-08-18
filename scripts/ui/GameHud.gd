extends Control
## GameHud
## -----------------------------------------------------------------------
## Top HUD bar for the gameplay screen (design/ui-prototype.html,
## "07 GAMEPLAY"): a pause button (inert for now — no pause system yet)
## plus live progress meters for the player and the current lead rival,
## both driven by GameEvents/GameState (score / WIN_SCORE, same number
## that drives each horse's lane position).
## -----------------------------------------------------------------------

const GOLD := Color("f5b942")
const GOLD_DEEP := Color("c98716")
const PARCHMENT_2 := Color("d8be8a")
const TEAL := Color("2e8c7e")
const RED_DARK := Color("8f2019")
const HUD_HEIGHT := 128.0

var _you_label: Label
var _you_fill: Panel
var _you_track: Panel
var _rival_label: Label
var _rival_fill: Panel
var _rival_track: Panel


func _ready() -> void:
	anchor_left = 0.0
	anchor_right = 1.0
	anchor_top = 0.0
	anchor_bottom = 0.0
	offset_bottom = HUD_HEIGHT
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_build_backdrop()

	var margin := MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 10)
	add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	margin.add_child(row)

	row.add_child(_make_pause_button())

	var meters := VBoxContainer.new()
	meters.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	meters.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	meters.add_theme_constant_override("separation", 6)
	row.add_child(meters)

	var you := _build_meter("🐎 YOU", TEAL)
	meters.add_child(you.root)
	_you_label = you.value_label
	_you_fill = you.fill
	_you_track = you.track

	var rival := _build_meter("🤖 LEAD RIVAL", RED_DARK)
	meters.add_child(rival.root)
	_rival_label = rival.value_label
	_rival_fill = rival.fill
	_rival_track = rival.track

	GameEvents.race_started.connect(_on_race_state_changed)
	GameEvents.race_positions_updated.connect(_on_positions_updated)
	_refresh()


func _build_backdrop() -> void:
	var bg := TextureRect.new()
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color(0, 0, 0, 0.65), Color(0, 0, 0, 0)])
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.width = 8
	tex.height = 128
	tex.fill = GradientTexture2D.FILL_LINEAR
	tex.fill_from = Vector2(0.5, 0.0)
	tex.fill_to = Vector2(0.5, 1.0)
	bg.texture = tex
	add_child(bg)


func _make_pause_button() -> Button:
	var btn := Button.new()
	btn.text = "⏸"
	btn.custom_minimum_size = Vector2(56, 56)
	btn.add_theme_font_size_override("font_size", 22)
	btn.add_theme_color_override("font_color", GOLD)
	btn.add_theme_color_override("font_hover_color", GOLD)
	btn.add_theme_color_override("font_pressed_color", GOLD)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.5)
	style.border_color = GOLD_DEEP
	style.set_border_width_all(2)
	style.set_corner_radius_all(28)
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_stylebox_override("focus", style)
	return btn


func _build_meter(caption: String, fill_color: Color) -> Dictionary:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)

	var lbl_row := HBoxContainer.new()
	var caption_label := Label.new()
	caption_label.text = caption
	caption_label.add_theme_font_size_override("font_size", 15)
	caption_label.add_theme_color_override("font_color", PARCHMENT_2)
	caption_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_row.add_child(caption_label)

	var value_label := Label.new()
	value_label.text = "0 / %d" % GameState.WIN_SCORE
	value_label.add_theme_font_size_override("font_size", 15)
	value_label.add_theme_color_override("font_color", PARCHMENT_2)
	lbl_row.add_child(value_label)
	box.add_child(lbl_row)

	var track := Panel.new()
	track.custom_minimum_size = Vector2(0, 16)
	track.clip_contents = true
	var track_style := StyleBoxFlat.new()
	track_style.bg_color = Color(0, 0, 0, 0.55)
	track_style.border_color = Color("6b4a2e")
	track_style.set_border_width_all(1)
	track_style.set_corner_radius_all(8)
	track.add_theme_stylebox_override("panel", track_style)
	box.add_child(track)

	var fill := Panel.new()
	fill.anchor_bottom = 1.0
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = fill_color
	fill_style.set_corner_radius_all(8)
	fill.add_theme_stylebox_override("panel", fill_style)
	track.add_child(fill)

	return {"root": box, "value_label": value_label, "fill": fill, "track": track}


func _on_race_state_changed(_level_id: int) -> void:
	_refresh()


func _on_positions_updated(_progress_by_racer: Dictionary) -> void:
	_refresh()


func _refresh() -> void:
	var player_id := GameState.player_racer_id
	var player_score: int = GameState.scores.get(player_id, 0)
	_set_meter(_you_label, _you_fill, _you_track, player_score)

	var lead_score := 0
	for rid in GameState.scores:
		if rid == player_id:
			continue
		var s: int = GameState.scores[rid]
		if s > lead_score:
			lead_score = s
	_set_meter(_rival_label, _rival_fill, _rival_track, lead_score)


func _set_meter(label: Label, fill: Panel, track: Panel, score: int) -> void:
	label.text = "%d / %d" % [score, GameState.WIN_SCORE]
	var t := clampf(float(score) / float(GameState.WIN_SCORE), 0.0, 1.0)
	fill.size.x = track.size.x * t
