class_name RaceManager
extends Node
## Owns the set of Horse logic objects for the current race and reacts to
## GameEvents.racer_scored — the single funnel every scoring source
## (player, AI, future remote players) reports through. RaceManager never
## needs to know WHO scored, only that a racer_id did.

var horses: Dictionary = {} # racer_id (int) -> Horse
var win_score: int = GameState.WIN_SCORE


func _ready() -> void:
	GameEvents.racer_scored.connect(_on_racer_scored)


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
