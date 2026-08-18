extends Control
## Launcher
## -----------------------------------------------------------------------
## Cold-start splash screen: app icon + a looping running-horse animation,
## then hands off to the main menu. Everything is built in code since it's
## a handful of static nodes with no interaction.
## -----------------------------------------------------------------------

const DISPLAY_TIME := 1.8
const FADE_TIME := 0.4
const BG_COLOR := Color(0.086, 0.086, 0.11, 1)


func _ready() -> void:
	modulate.a = 0.0

	var bg := Panel.new()
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = BG_COLOR
	bg.add_theme_stylebox_override("panel", style)
	add_child(bg)

	var icon := TextureRect.new()
	icon.texture = load("res://icon.png")
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.size = Vector2(320, 320)
	icon.position = Vector2(size.x / 2.0 - icon.size.x / 2.0, size.y * 0.26)
	add_child(icon)

	var horse := HorseMarker.new()
	horse.size = Vector2(240, 180)
	horse.mouse_filter = Control.MOUSE_FILTER_IGNORE
	horse.set_horse_texture(load("res://assets/sprites/horses/horse_gold.png"))
	horse.position = Vector2(size.x / 2.0 - horse.size.x / 2.0, size.y * 0.62)
	add_child(horse)

	var title := Label.new()
	title.text = "Carnival Horse Race"
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.2, 1))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.size = Vector2(size.x, 60)
	title.position = Vector2(0, size.y * 0.8)
	add_child(title)

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, FADE_TIME)
	tween.tween_interval(DISPLAY_TIME)
	tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)
	tween.tween_callback(_go_to_menu)


func _go_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/MainMenu.tscn")
