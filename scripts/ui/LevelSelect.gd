extends Control
## LevelSelect
## -----------------------------------------------------------------------
## Level picker, styled to match the Retro Carnival system (tent-top +
## wood board from MainMenu). Loosely based on design/ui-prototype.html's
## "05 LEVEL MAP" screen, simplified to a scrollable grid of level tickets
## instead of the winding path (same done/now/locked idea, flatter layout).
##
## Each unlocked ticket shows the level's 4 AI opponents as easy/medium/
## hard pips (GameState.level_composition), so the difficulty curve is
## legible at a glance instead of hidden behind a number. Lock state comes
## straight from GameState.is_level_unlocked() — sequential, one level
## ahead of your saved progress.
## -----------------------------------------------------------------------

const WOOD := Color("4a2c1a")
const WOOD_DARK := Color("2f1b10")
const TENT_2 := Color("3a1e17")
const CREAM := Color("f8edd6")
const PARCHMENT := Color("e9d5ac")
const PARCHMENT_2 := Color("d8be8a")
const INK := Color("22120a")
const GOLD := Color("f5b942")
const GOLD_DEEP := Color("c98716")
const RED := Color("c8352c")
const RED_DARK := Color("8f2019")
const GREEN := Color("46a055")

const ALFA_SLAB := preload("res://assets/fonts/AlfaSlabOne-Regular.ttf")
const BUNGEE := preload("res://assets/fonts/Bungee-Regular.ttf")

const MAIN_MENU_SCENE_PATH := "res://scenes/menu/MainMenu.tscn"
const MAIN_SCENE_PATH := "res://scenes/main/Main.tscn"

const HEADER_HEIGHT := 96.0
const CARD_SIZE := Vector2(316, 200)


func _ready() -> void:
	_build_background()
	_build_header()
	_build_grid()


func _build_background() -> void:
	var bg := TextureRect.new()
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([WOOD, WOOD_DARK])
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.width = 8
	tex.height = 512
	tex.fill = GradientTexture2D.FILL_LINEAR
	tex.fill_from = Vector2(0.5, 0.0)
	tex.fill_to = Vector2(0.5, 1.0)
	bg.texture = tex
	add_child(bg)


func _build_header() -> void:
	var header := Panel.new()
	header.anchor_right = 1.0
	header.custom_minimum_size = Vector2(0, HEADER_HEIGHT)
	var style := StyleBoxFlat.new()
	style.bg_color = TENT_2
	style.shadow_size = 8
	style.shadow_color = Color(0, 0, 0, 0.35)
	header.add_theme_stylebox_override("panel", style)
	add_child(header)

	var row := HBoxContainer.new()
	row.anchor_right = 1.0
	row.anchor_bottom = 1.0
	row.add_theme_constant_override("separation", 12)
	header.add_child(row)

	var margin := MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	header.add_child(margin)
	margin.add_child(row)

	var back := Button.new()
	back.text = "‹"
	back.custom_minimum_size = Vector2(56, 56)
	back.add_theme_font_size_override("font_size", 28)
	back.add_theme_color_override("font_color", GOLD)
	back.add_theme_color_override("font_hover_color", GOLD)
	back.add_theme_color_override("font_pressed_color", GOLD)
	var back_style := StyleBoxFlat.new()
	back_style.bg_color = Color(0, 0, 0, 0.4)
	back_style.set_corner_radius_all(28)
	back.add_theme_stylebox_override("normal", back_style)
	back.add_theme_stylebox_override("hover", back_style)
	back.add_theme_stylebox_override("pressed", back_style)
	back.add_theme_stylebox_override("focus", back_style)
	back.pressed.connect(_on_back_pressed)
	row.add_child(back)

	var title := Label.new()
	title.text = "THE MIDWAY"
	title.add_theme_font_override("font", ALFA_SLAB)
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", GOLD)
	title.add_theme_color_override("font_outline_color", RED_DARK)
	title.add_theme_constant_override("outline_size", 4)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title)


func _build_grid() -> void:
	var scroll := ScrollContainer.new()
	scroll.anchor_right = 1.0
	scroll.anchor_bottom = 1.0
	scroll.offset_top = HEADER_HEIGHT
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 40)
	scroll.add_child(margin)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	margin.add_child(grid)

	for level_id in range(1, GameState.MAX_LEVEL + 1):
		grid.add_child(_make_level_card(level_id))


func _make_level_card(level_id: int) -> Control:
	var unlocked := GameState.is_level_unlocked(level_id)
	var cleared := level_id <= GameState.highest_completed_level

	var card := Button.new()
	card.custom_minimum_size = CARD_SIZE
	card.text = ""
	card.disabled = not unlocked
	if unlocked:
		card.pressed.connect(_on_level_pressed.bind(level_id))

	var bg_color := PARCHMENT if unlocked else Color("5c4433")
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.set_corner_radius_all(18)
	style.border_color = WOOD if unlocked else Color("3a2416")
	style.set_border_width_all(3)
	style.border_width_bottom = 8
	style.shadow_size = 4
	style.shadow_color = Color(0, 0, 0, 0.3)
	card.add_theme_stylebox_override("normal", style)
	card.add_theme_stylebox_override("hover", style)
	card.add_theme_stylebox_override("disabled", style)

	var pressed_style := style.duplicate()
	pressed_style.border_width_bottom = 3
	pressed_style.content_margin_top = 5.0
	card.add_theme_stylebox_override("pressed", pressed_style)
	card.add_theme_stylebox_override("focus", style)

	var content := VBoxContainer.new()
	content.anchor_right = 1.0
	content.anchor_bottom = 1.0
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_theme_constant_override("separation", 10)
	card.add_child(content)

	var number := Label.new()
	number.text = "LEVEL %d" % level_id
	number.add_theme_font_override("font", BUNGEE)
	number.add_theme_font_size_override("font_size", 24)
	number.add_theme_color_override("font_color", INK if unlocked else PARCHMENT_2)
	number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(number)

	if not unlocked:
		var lock := Label.new()
		lock.text = "🔒"
		lock.add_theme_font_size_override("font_size", 30)
		lock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		content.add_child(lock)

		var hint := Label.new()
		hint.text = "CLEAR LEVEL %d FIRST" % (level_id - 1)
		hint.add_theme_font_override("font", BUNGEE)
		hint.add_theme_font_size_override("font_size", 12)
		hint.add_theme_color_override("font_color", PARCHMENT_2)
		hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		content.add_child(hint)

		return card

	var pips := HBoxContainer.new()
	pips.alignment = BoxContainer.ALIGNMENT_CENTER
	pips.add_theme_constant_override("separation", 8)
	pips.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content.add_child(pips)

	var counts: Array = GameState.level_composition(level_id)
	var pip_colors := [GREEN, GOLD, RED]
	for tier in 3:
		for i in int(counts[tier]):
			pips.add_child(_make_pip(pip_colors[tier]))

	var tag := Label.new()
	tag.text = "✓ CLEARED" if cleared else _difficulty_tag(counts)
	tag.add_theme_font_override("font", BUNGEE)
	tag.add_theme_font_size_override("font_size", 14)
	tag.add_theme_color_override("font_color", Color("2c6b37") if cleared else _difficulty_tag_color(counts))
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(tag)

	return card


func _make_pip(color: Color) -> Control:
	var pip := Panel.new()
	pip.custom_minimum_size = Vector2(20, 20)
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(10)
	style.border_color = Color(0, 0, 0, 0.25)
	style.set_border_width_all(1)
	pip.add_theme_stylebox_override("panel", style)
	return pip


func _difficulty_tag(counts: Array) -> String:
	if int(counts[2]) > 0:
		return "HARD"
	if int(counts[1]) > 0:
		return "MEDIUM"
	return "EASY"


func _difficulty_tag_color(counts: Array) -> Color:
	if int(counts[2]) > 0:
		return RED_DARK
	if int(counts[1]) > 0:
		return GOLD_DEEP
	return Color("2c6b37")


func _on_level_pressed(level_id: int) -> void:
	GameState.current_level = level_id
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
