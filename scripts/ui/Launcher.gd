extends Control
## Launcher
## -----------------------------------------------------------------------
## Cold-start splash screen, built to the Retro Carnival spec in
## design/ui-ux-decisions.md (see design/ui-prototype.html, screen 01
## "SPLASH"): radial night backdrop, circular gold/cream/red logo badge,
## marquee title, animated loading bar, quiet caption.
## Everything is built in code — a handful of nodes, no interaction.
## -----------------------------------------------------------------------

const DISPLAY_TIME := 1.6
const FADE_TIME := 0.4
const LOADBAR_HALF_CYCLE := 1.1
const LOADBAR_MIN := 0.12
const LOADBAR_MAX := 0.88
const LOADBAR_TRACK_WIDTH := 360.0

const NIGHT := Color("150f0e")
const RADIAL_CENTER := Color("4a2119")
const GOLD := Color("f5b942")
const RED_DARK := Color("8f2019")
const CREAM := Color("f8edd6")
const MUTED := Color("7a6247")
const WOOD_LINE := Color("6b4a2e")

const ALFA_SLAB := preload("res://assets/fonts/AlfaSlabOne-Regular.ttf")
const RUBIK := preload("res://assets/fonts/Rubik-Variable.ttf")

var _loadbar_fill: Panel


func _ready() -> void:
	modulate.a = 0.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_build_background()

	var content := VBoxContainer.new()
	content.anchor_right = 1.0
	content.anchor_bottom = 1.0
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_theme_constant_override("separation", 28)
	add_child(content)

	var badge := TextureRect.new()
	badge.texture = load("res://assets/sprites/ui/splash_badge.png")
	badge.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	badge.custom_minimum_size = Vector2(360, 360)
	badge.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(badge)

	content.add_child(_make_title_label("FINAL LAP", 64, GOLD))
	content.add_child(_make_title_label("FINAL RACE", 40, CREAM))

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	content.add_child(spacer)

	_loadbar_fill = _build_loadbar(content)

	var caption := Label.new()
	caption.text = "Saddling up…"
	caption.add_theme_font_override("font", RUBIK)
	caption.add_theme_font_size_override("font_size", 22)
	caption.add_theme_color_override("font_color", MUTED)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(caption)

	_animate_loadbar()

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, FADE_TIME)
	tween.tween_interval(DISPLAY_TIME)
	tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)
	tween.tween_callback(_go_to_menu)


func _build_background() -> void:
	var bg := TextureRect.new()
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.stretch_mode = TextureRect.STRETCH_SCALE

	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([RADIAL_CENTER, NIGHT])
	gradient.offsets = PackedFloat32Array([0.0, 1.0])

	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.width = 512
	tex.height = 512
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.4)
	tex.fill_to = Vector2(0.5, 1.15)
	bg.texture = tex
	add_child(bg)


func _make_title_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", ALFA_SLAB)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", RED_DARK)
	label.add_theme_constant_override("outline_size", 6)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _build_loadbar(parent: Control) -> Panel:
	var track := Panel.new()
	track.custom_minimum_size = Vector2(LOADBAR_TRACK_WIDTH, 18)
	track.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	track.clip_contents = true
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var track_style := StyleBoxFlat.new()
	track_style.bg_color = Color(0, 0, 0, 0.5)
	track_style.border_color = WOOD_LINE
	track_style.set_border_width_all(2)
	track_style.set_corner_radius_all(9)
	track.add_theme_stylebox_override("panel", track_style)
	parent.add_child(track)

	var fill := Panel.new()
	fill.anchor_bottom = 1.0
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = GOLD
	fill_style.set_corner_radius_all(9)
	fill.add_theme_stylebox_override("panel", fill_style)
	track.add_child(fill)
	return fill


func _animate_loadbar() -> void:
	_set_loadbar_width(LOADBAR_MIN)
	var tween := create_tween().set_loops()
	tween.tween_method(_set_loadbar_width, LOADBAR_MIN, LOADBAR_MAX, LOADBAR_HALF_CYCLE) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(_set_loadbar_width, LOADBAR_MAX, LOADBAR_MIN, LOADBAR_HALF_CYCLE) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)


func _set_loadbar_width(t: float) -> void:
	_loadbar_fill.size.x = LOADBAR_TRACK_WIDTH * t


func _go_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/MainMenu.tscn")
