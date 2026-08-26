class_name RaceManager
extends Node
## Owns the set of Horse logic objects for the current race and reacts to
## GameEvents.racer_scored — the single funnel every scoring source
## (player, AI, future remote players) reports through. RaceManager never
## needs to know WHO scored, only that a racer_id did.

const VICTORY_SCENE_PATH := "res://scenes/menu/Victory.tscn"
const DEFEAT_SCENE_PATH := "res://scenes/menu/Defeat.tscn"
const RACE_END_RETURN_DELAY := 1.2

var horses: Dictionary = {} # racer_id (int) -> Horse
var win_score: int = GameState.WIN_SCORE


func _ready() -> void:
	GameEvents.racer_scored.connect(_on_racer_scored)
	GameEvents.race_ended.connect(_on_race_ended)
	_start_default_race.call_deferred()


func _start_default_race() -> void:
	var racer_ids: Array[int] = []
	for i in GameState.RACER_COUNT:
		racer_ids.append(i)
	setup_race(racer_ids, GameState.player_racer_id)
	_spawn_ai_controllers(racer_ids)


func _spawn_ai_controllers(racer_ids: Array[int]) -> void:
	var difficulties := GameState.ai_difficulties_for_level(GameState.current_level)
	var i := 0
	for rid in racer_ids:
		if rid == GameState.player_racer_id:
			continue
		var difficulty: GameState.Difficulty = difficulties[i] if i < difficulties.size() else GameState.Difficulty.EASY
		add_child(AIController.new(rid, difficulty))
		i += 1


func setup_race(racer_ids: Array[int], player_id: int) -> void:
	horses.clear()
	for i in racer_ids.size():
		var rid: int = racer_ids[i]
		horses[rid] = Horse.new(rid, i, rid == player_id)
	GameState.reset_race()
	GameEvents.race_started.emit(GameState.current_level)


func _on_racer_scored(racer_id: int, points: int, _hole_id: StringName) -> void:
	if not horses.has(racer_id):
		return
	var horse: Horse = horses[racer_id]
	horse.add_score(points, win_score)
	GameState.apply_score(racer_id, points)

	_broadcast_positions()

	if horse.has_finished(win_score):
		GameEvents.racer_finished.emit(racer_id, horse.score, 0.0)
		_check_race_end()


func _broadcast_positions() -> void:
	var progress_by_racer: Dictionary = {}
	for rid in horses:
		progress_by_racer[rid] = (horses[rid] as Horse).progress
	GameEvents.race_positions_updated.emit(progress_by_racer)


func _check_race_end() -> void:
	# v1 rule: race ends the instant ANY horse reaches the win score.
	# Adjust here later if we want "all racers finish" or a timed cutoff.
	var results: Array = []
	for rid in horses:
		var h: Horse = horses[rid]
		results.append({"racer_id": rid, "score": h.score})
	results.sort_custom(func(a, b): return a["score"] > b["score"])
	GameEvents.race_ended.emit(results)


func _on_race_ended(results: Array) -> void:
	var player_id := GameState.player_racer_id
	var winner_id: int = results[0]["racer_id"]
	var won: bool = winner_id == player_id

	GameState.last_race_won = won
	GameState.last_race_player_score = int(GameState.scores.get(player_id, 0))
	GameState.last_race_winner_score = int(results[0]["score"])
	if won:
		GameState.complete_level(GameState.current_level)

	await get_tree().create_timer(RACE_END_RETURN_DELAY).timeout
	get_tree().change_scene_to_file(VICTORY_SCENE_PATH if won else DEFEAT_SCENE_PATH)
