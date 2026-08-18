extends Control
## MainMenu
## -----------------------------------------------------------------------
## Landing screen shown after the launcher and after every race ends.
## "New Game" is the only action for now.
## -----------------------------------------------------------------------

func _ready() -> void:
	$Content/NewGameButton.pressed.connect(_on_new_game_pressed)


func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/Main.tscn")
