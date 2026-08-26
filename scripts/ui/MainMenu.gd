extends Control
## MainMenu
## -----------------------------------------------------------------------
## Landing screen, built to the Retro Carnival spec in
## design/ui-ux-decisions.md (see design/ui-prototype.html, screen 02
## "MAIN MENU"): tent valance, wood board, bulb string, marquee title,
## progress chips, a dominant CONTINUE/PLAY CTA, and secondary actions.
##
## NEW GAME/CONTINUE and LEVEL SELECT are wired up — everything else is
## present for visual fidelity but intentionally inert until its system
## exists (stats, settings, sound, profile, info, ads).
## -----------------------------------------------------------------------

const NIGHT := Color("150f0e")
const WOOD := Color("4a2c1a")
const WOOD_DARK := Color("2f1b10")
const CREAM := Color("f8edd6")
const PARCHMENT := Color("e9d5ac")
const PARCHMENT_2 := Color("d8be8a")
const RED := Color("c8352c")
const RED_DARK := Color("8f2019")
const GOLD := Color("f5b942")
const GOLD_DEEP := Color("c98716")
const BULB := Color("ffe9a8")
const INK := Color("22120a")

const ALFA_SLAB := preload("res://assets/fonts/AlfaSlabOne-Regular.ttf")
const BUNGEE := preload("res://assets/fonts/Bungee-Regular.ttf")

const TENT_TOP_HEIGHT := 48.0
const AD_SLOT_HEIGHT := 130.0


func _ready() -> void:
	_build_background()

	var layout := VBoxContainer.new()
	layout.anchor_right = 1.0
	layout.anchor_bottom = 1.0
	layout.add_theme_constant_override("separation", 0)
	add_child(layout)

	var tent_top := TentTop.new()
	tent_top.custom_minimum_size = Vector2(0, TENT_TOP_HEIGHT)
	layout.add_child(tent_top)

	var wall := MarginContainer.new()
	wall.size_flags_vertical = Control.SIZE_EXPAND_FILL
	wall.add_theme_constant_override("margin_left", 48)
	wall.add_theme_constant_override("margin_right", 48)
	wall.add_theme_constant_override("margin_top", 30)
	wall.add_theme_constant_override("margin_bottom", 24)
	layout.add_child(wall)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 0)
	wall.add_child(content)

	content.add_child(_build_bulb_row())

	var spacer1 := Control.new()
	spacer1.custom_minimum_size = Vector2(0, 18)
	content.add_child(spacer1)

	content.add_child(_make_title_label("FINAL LAP", 66, GOLD))
	content.add_child(_make_title_label("FINAL RACE", 38, CREAM))

	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 36)
	content.add_child(spacer2)

	content.add_child(_build_chip_row())

	var button_area := CenterContainer.new()
	button_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(button_area)
	button_area.add_child(_build_button_stack())

	content.add_child(_build_hud_row())

	var ad_slot := _build_ad_slot()
	layout.add_child(ad_slot)


func _build_background() -> void:
	var bg := TextureRect.new()
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.stretch_mode = TextureRect.STRETCH_SCALE

	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([WOOD, WOOD_DARK])
	gradient.offsets = PackedFloat32Array([0.0, 1.0])

	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.width = 8
	tex.height = 512
	tex.fill = GradientTexture2D.FILL_LINEAR
	tex.fill_from = Vector2(0.5, 0.0)
	tex.fill_to = Vector2(0.5, 1.0)
	bg.texture = tex
	add_child(bg)


func _make_title_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", ALFA_SLAB)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", RED_DARK)
	label.add_theme_constant_override("outline_size", 5)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label


func _build_bulb_row() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 34)
	for i in 7:
		var bulb := _make_bulb()
		row.add_child(bulb)
		var tween := bulb.create_tween().set_loops()
		tween.tween_interval(float(i % 3) * 0.4)
		tween.tween_property(bulb, "modulate:a", 0.35, 0.8).set_trans(Tween.TRANS_SINE)
		tween.tween_property(bulb, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE)
	return row


func _make_bulb() -> Control:
	var wrap := Control.new()
	wrap.custom_minimum_size = Vector2(26, 26)
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var halo := Panel.new()
	halo.size = Vector2(26, 26)
	var halo_style := StyleBoxFlat.new()
	halo_style.bg_color = Color(BULB.r, BULB.g, BULB.b, 0.35)
	halo_style.set_corner_radius_all(13)
	halo.add_theme_stylebox_override("panel", halo_style)
	wrap.add_child(halo)

	var core := Panel.new()
	core.position = Vector2(8, 8)
	core.size = Vector2(10, 10)
	var core_style := StyleBoxFlat.new()
	core_style.bg_color = BULB
	core_style.set_corner_radius_all(5)
	core.add_theme_stylebox_override("panel", core_style)
	wrap.add_child(core)

	return wrap


func _build_chip_row() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 14)
	row.add_child(_make_chip("🏅 Level %d" % GameState.next_playable_level()))
	row.add_child(_make_chip("🎟️ 12 tickets"))
	row.add_child(_make_chip("🔥 3-day streak"))
	return row


func _make_chip(text: String) -> Panel:
	var chip := Panel.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.35)
	style.border_color = Color(GOLD.r, GOLD.g, GOLD.b, 0.4)
	style.set_border_width_all(2)
	style.set_corner_radius_all(999)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	chip.add_theme_stylebox_override("panel", style)

	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", BUNGEE)
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", GOLD)
	chip.add_child(label)
	chip.custom_minimum_size = label.get_minimum_size() + Vector2(32, 12)

	return chip


func _build_button_stack() -> VBoxContainer:
	var stack := VBoxContainer.new()
	stack.custom_minimum_size = Vector2(600, 0)
	stack.add_theme_constant_override("separation", 22)

	var continue_label := "▶ NEW GAME" if not GameState.has_progress() else "▶ CONTINUE"
	var continue_btn := _make_button(continue_label, GOLD, GOLD_DEEP, INK, 96, 34)
	continue_btn.pressed.connect(_on_continue_pressed)
	stack.add_child(continue_btn)

	var level_select_btn := _make_button("🎯 LEVEL SELECT", RED, RED_DARK, CREAM, 84, 30)
	level_select_btn.pressed.connect(_on_level_select_pressed)
	stack.add_child(level_select_btn)

	var stats := _make_ghost_button("🏆 STATS", 64, 22)
	stack.add_child(stats)

	return stack


func _make_button(text: String, bg: Color, shadow: Color, fg: Color, min_height: float, font_size: int) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(0, min_height)
	btn.add_theme_font_override("font", BUNGEE)
	btn.add_theme_font_size_override("font_size", font_size)
	btn.add_theme_color_override("font_color", fg)
	btn.add_theme_color_override("font_hover_color", fg)
	btn.add_theme_color_override("font_pressed_color", fg)

	var normal := StyleBoxFlat.new()
	normal.bg_color = bg
	normal.set_corner_radius_all(16)
	normal.border_color = shadow
	normal.set_border_width_all(0)
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


func _make_ghost_button(text: String, min_height: float, font_size: int) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(0, min_height)
	btn.add_theme_font_override("font", BUNGEE)
	btn.add_theme_font_size_override("font_size", font_size)
	btn.add_theme_color_override("font_color", PARCHMENT)
	btn.add_theme_color_override("font_hover_color", CREAM)
	btn.add_theme_color_override("font_pressed_color", CREAM)

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0, 0, 0, 0)
	normal.border_color = PARCHMENT_2
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(10)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", normal)
	btn.add_theme_stylebox_override("pressed", normal)
	btn.add_theme_stylebox_override("focus", normal)

	return btn


func _build_hud_row() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 40)
	for glyph in ["⚙", "🔊", "👤", "ℹ"]:
		row.add_child(_make_hud_button(glyph))
	return row


func _make_hud_button(glyph: String) -> Button:
	var btn := Button.new()
	btn.text = glyph
	btn.custom_minimum_size = Vector2(72, 72)
	btn.add_theme_font_size_override("font_size", 28)
	btn.add_theme_color_override("font_color", CREAM)
	btn.add_theme_color_override("font_hover_color", GOLD)
	btn.add_theme_color_override("font_pressed_color", GOLD)

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0, 0, 0, 0.3)
	normal.set_corner_radius_all(36)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", normal)
	btn.add_theme_stylebox_override("pressed", normal)
	btn.add_theme_stylebox_override("focus", normal)

	return btn


func _build_ad_slot() -> Panel:
	var slot := Panel.new()
	slot.custom_minimum_size = Vector2(0, AD_SLOT_HEIGHT)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.55)
	slot.add_theme_stylebox_override("panel", style)

	var label := Label.new()
	label.text = "— BANNER AD 320×50 —"
	label.add_theme_font_override("font", BUNGEE)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(PARCHMENT_2.r, PARCHMENT_2.g, PARCHMENT_2.b, 0.5))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.anchor_right = 1.0
	label.anchor_bottom = 1.0
	slot.add_child(label)

	return slot


func _on_continue_pressed() -> void:
	GameState.current_level = GameState.next_playable_level()
	get_tree().change_scene_to_file("res://scenes/main/Main.tscn")


func _on_level_select_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/LevelSelect.tscn")
