extends Control
## Defeat
## -----------------------------------------------------------------------
## Shown when another horse wins the race (design/ui-prototype.html,
## "11 DEFEAT"). Coaching tone, not blaming — the score gap, YOU-vs-WINNER
## bars and accuracy are real numbers from GameState (score gap set by
## RaceManager._on_race_ended, accuracy tracked live off GameEvents),
## not placeholders. The rewarded-ad "watch for 3 more balls" button is
## dropped: no ad system yet. TRY AGAIN and HOME sit side by side.
## -----------------------------------------------------------------------

const NIGHT := Color("150f0e")
const GOLD := Color("f5b942")
const GOLD_DEEP := Color("c98716")
const RED_DARK := Color("8f2019")
const CREAM := Color("f8edd6")
const PARCHMENT_2 := Color("d8be8a")
const INK := Color("22120a")
const TEAL := Color("2e8c7e")
const WOOD_LINE := Color("6b4a2e")

const ALFA_SLAB := preload("res://assets/fonts/AlfaSlabOne-Regular.ttf")
const BUNGEE := preload("res://assets/fonts/Bungee-Regular.ttf")
const RUBIK := preload("res://assets/fonts/Rubik-Variable.ttf")

const MAIN_MENU_SCENE_PATH := "res://scenes/menu/MainMenu.tscn"
const MAIN_SCENE_PATH := "res://scenes/main/Main.tscn"


func _ready() -> void:
	_build_background()

	var content := VBoxContainer.new()
	content.anchor_right = 1.0
	content.anchor_bottom = 1.0
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 16)
	add_child(content)

	var ribbon := Label.new()
	ribbon.text = "🎗️"
	ribbon.add_theme_font_size_override("font_size", 60)
	ribbon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(ribbon)

	var title := Label.new()
	title.text = "SO CLOSE"
	title.add_theme_font_override("font", ALFA_SLAB)
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", CREAM)
	title.add_theme_color_override("font_outline_color", RED_DARK)
	title.add_theme_constant_override("outline_size", 5)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(title)

	var gap := maxi(GameState.last_race_winner_score - GameState.last_race_player_score, 0)
	var subtitle := Label.new()
	subtitle.text = "You finished %d point%s short." % [gap, "" if gap == 1 else "s"]
	subtitle.add_theme_font_override("font", RUBIK)
	subtitle.add_theme_font_size_override("font_size", 20)
	subtitle.add_theme_color_override("font_color", PARCHMENT_2)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(subtitle)

	content.add_child(_build_comparison_card())

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	content.add_child(spacer)

	content.add_child(_build_action_row())


func _build_background() -> void:
	var bg := Panel.new()
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	var style := StyleBoxFlat.new()
	style.bg_color = NIGHT
	bg.add_theme_stylebox_override("panel", style)
	add_child(bg)


func _build_comparison_card() -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(660, 0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("e9d5ac")
	style.set_corner_radius_all(18)
	style.border_color = Color("4a2c1a")
	style.set_border_width_all(3)
	card.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	card.add_child(margin)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	margin.add_child(col)

	col.add_child(_meter_label("YOU"))
	col.add_child(_meter_bar(GameState.last_race_player_score, TEAL))

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	col.add_child(spacer)

	col.add_child(_meter_label("WINNER"))
	col.add_child(_meter_bar(GameState.last_race_winner_score, RED_DARK))

	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 10)
	col.add_child(spacer2)

	col.add_child(_stat_row("ACCURACY", "%d%%" % roundi(GameState.player_accuracy() * 100.0)))

	var spacer3 := Control.new()
	spacer3.custom_minimum_size = Vector2(0, 10)
	col.add_child(spacer3)

	var tip := Label.new()
	tip.text = "💡 Green is easy but only worth 2 — one red hole equals three greens."
	tip.add_theme_font_override("font", RUBIK)
	tip.add_theme_font_size_override("font_size", 15)
	tip.add_theme_color_override("font_color", Color("5c4433"))
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD
	col.add_child(tip)

	return card


func _stat_row(label_text: String, value_text: String) -> HBoxContainer:
	var row := HBoxContainer.new()

	var label := Label.new()
	label.text = label_text
	label.add_theme_font_override("font", BUNGEE)
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", INK)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)

	var value := Label.new()
	value.text = value_text
	value.add_theme_font_override("font", BUNGEE)
	value.add_theme_font_size_override("font_size", 15)
	value.add_theme_color_override("font_color", INK)
	row.add_child(value)

	return row


func _meter_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", BUNGEE)
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", INK)
	return label


func _meter_bar(score: int, fill_color: Color) -> Panel:
	var track := Panel.new()
	track.custom_minimum_size = Vector2(0, 18)
	track.clip_contents = true
	var track_style := StyleBoxFlat.new()
	track_style.bg_color = Color(0, 0, 0, 0.25)
	track_style.border_color = WOOD_LINE
	track_style.set_border_width_all(1)
	track_style.set_corner_radius_all(9)
	track.add_theme_stylebox_override("panel", track_style)

	var fill := Panel.new()
	fill.anchor_bottom = 1.0
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = fill_color
	fill_style.set_corner_radius_all(9)
	fill.add_theme_stylebox_override("panel", fill_style)
	track.add_child(fill)

	var t := clampf(float(score) / float(GameState.WIN_SCORE), 0.0, 1.0)
	call_deferred("_set_fill_width", fill, track, t)

	return track


func _set_fill_width(fill: Panel, track: Panel, t: float) -> void:
	fill.size.x = track.size.x * t


func _build_action_row() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	var retry_btn := _make_button("↻ TRY AGAIN", GOLD, GOLD_DEEP, INK)
	retry_btn.custom_minimum_size = Vector2(420, 88)
	retry_btn.pressed.connect(_on_try_again_pressed)
	row.add_child(retry_btn)

	var home_btn := _make_icon_button("🏠")
	home_btn.pressed.connect(_on_home_pressed)
	row.add_child(home_btn)

	return row


func _make_button(text: String, bg: Color, shadow: Color, fg: Color) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.add_theme_font_override("font", BUNGEE)
	btn.add_theme_font_size_override("font_size", 28)
	btn.add_theme_color_override("font_color", fg)
	btn.add_theme_color_override("font_hover_color", fg)
	btn.add_theme_color_override("font_pressed_color", fg)

	var normal := StyleBoxFlat.new()
	normal.bg_color = bg
	normal.set_corner_radius_all(16)
	normal.border_color = shadow
	normal.border_width_bottom = 7
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", normal)

	var pressed := StyleBoxFlat.new()
	pressed.bg_color = bg
	pressed.set_corner_radius_all(16)
	pressed.border_color = shadow
	pressed.border_width_bottom = 2
	pressed.content_margin_top = 5
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", normal)

	return btn


func _make_icon_button(glyph: String) -> Button:
	var btn := Button.new()
	btn.text = glyph
	btn.custom_minimum_size = Vector2(88, 88)
	btn.add_theme_font_size_override("font_size", 34)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.4)
	style.border_color = PARCHMENT_2
	style.set_border_width_all(2)
	style.set_corner_radius_all(16)
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_stylebox_override("focus", style)

	return btn


func _on_try_again_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)


func _on_home_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
