extends Control
## Victory
## -----------------------------------------------------------------------
## Shown when the player's horse wins the race (design/ui-prototype.html,
## "10 VICTORY"). Stats (score, red hits, accuracy) are read straight off
## GameState — real per-race counters kept by GameState._on_ball_thrown/
## _on_racer_scored_stats, not fabricated. "Tickets earned" is dropped:
## no currency system yet. The rewarded-ad "watch for 3rd star" button is
## also dropped: no ad system, no star rating yet. NEXT LEVEL and HOME
## sit side by side.
## -----------------------------------------------------------------------

const NIGHT := Color("150f0e")
const GOLD := Color("f5b942")
const GOLD_DEEP := Color("c98716")
const RED_DARK := Color("8f2019")
const CREAM := Color("f8edd6")
const PARCHMENT_2 := Color("d8be8a")
const INK := Color("22120a")
const TEAL := Color("2e8c7e")
const RED := Color("c8352c")
const GREEN := Color("46a055")

const ALFA_SLAB := preload("res://assets/fonts/AlfaSlabOne-Regular.ttf")
const BUNGEE := preload("res://assets/fonts/Bungee-Regular.ttf")

const MAIN_MENU_SCENE_PATH := "res://scenes/menu/MainMenu.tscn"
const MAIN_SCENE_PATH := "res://scenes/main/Main.tscn"

const CONFETTI_PIECES := 18


func _ready() -> void:
	_build_background()
	_build_confetti()

	var content := VBoxContainer.new()
	content.anchor_right = 1.0
	content.anchor_bottom = 1.0
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 18)
	add_child(content)

	var trophy := Label.new()
	trophy.text = "🏆"
	trophy.add_theme_font_size_override("font_size", 72)
	trophy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(trophy)

	var title := Label.new()
	title.text = "FIRST PLACE!"
	title.add_theme_font_override("font", ALFA_SLAB)
	title.add_theme_font_size_override("font_size", 56)
	title.add_theme_color_override("font_color", GOLD)
	title.add_theme_color_override("font_outline_color", RED_DARK)
	title.add_theme_constant_override("outline_size", 6)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(title)

	content.add_child(_build_stats_card())

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


func _build_confetti() -> void:
	var colors := [GOLD, RED, TEAL, CREAM, GREEN]
	for i in CONFETTI_PIECES:
		var piece := ColorRect.new()
		piece.size = Vector2(10, 16)
		piece.color = colors[i % colors.size()]
		piece.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var x := randf() * 1080.0
		piece.position = Vector2(x, -40.0)
		add_child(piece)

		var duration := randf_range(2.4, 3.8)
		var tween := piece.create_tween().set_loops()
		tween.tween_interval(randf() * duration)
		tween.set_parallel(true)
		tween.tween_property(piece, "position:y", 2000.0, duration).from(-40.0)
		tween.tween_property(piece, "rotation", TAU * 1.5, duration).from(0.0)
		tween.chain().tween_callback(func() -> void: piece.position.x = randf() * 1080.0)


func _build_stats_card() -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(620, 0)
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

	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 10)
	margin.add_child(rows)

	rows.add_child(_stat_row("LEVEL", str(GameState.current_level)))
	rows.add_child(_stat_row("TOTAL SCORE", "%d / %d" % [GameState.last_race_player_score, GameState.WIN_SCORE]))
	rows.add_child(_stat_row("RED HITS", "%d × 6 pts" % GameState.red_hits))
	rows.add_child(_stat_row("ACCURACY", "%d%%" % roundi(GameState.player_accuracy() * 100.0)))

	return card


func _stat_row(label_text: String, value_text: String) -> HBoxContainer:
	var row := HBoxContainer.new()

	var label := Label.new()
	label.text = label_text
	label.add_theme_font_override("font", BUNGEE)
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", INK)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)

	var value := Label.new()
	value.text = value_text
	value.add_theme_font_override("font", BUNGEE)
	value.add_theme_font_size_override("font_size", 20)
	value.add_theme_color_override("font_color", INK)
	row.add_child(value)

	return row


func _build_action_row() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	var next_btn := _make_button("▶ NEXT LEVEL", GOLD, GOLD_DEEP, INK)
	next_btn.custom_minimum_size = Vector2(420, 88)
	next_btn.pressed.connect(_on_next_level_pressed)
	row.add_child(next_btn)

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


func _on_next_level_pressed() -> void:
	GameState.current_level = mini(GameState.current_level + 1, GameState.MAX_LEVEL)
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)


func _on_home_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
