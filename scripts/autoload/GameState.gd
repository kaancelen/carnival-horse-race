extends Node
## GameState
## -----------------------------------------------------------------------
## Plain-data holder for the current race/session. No node references,
## no inspector wiring — everything here is trivially serializable so it
## can be dumped to JSON for save files and is easy for both us and an
## AI assistant to reason about from the script alone.
## -----------------------------------------------------------------------

const WIN_SCORE: int = 24
const RACER_COUNT: int = 5 # 1 player + 4 AI, tune freely

enum Difficulty { EASY, MEDIUM, HARD }

## racer_id -> current score
var scores: Dictionary = {}

## racer_id -> Difficulty (only meaningful for AI racers)
var ai_difficulty: Dictionary = {}

var current_level: int = 1
var player_racer_id: int = 0

var run_in_progress: bool = false


func reset_race() -> void:
	scores.clear()
	for i in range(RACER_COUNT):
		scores[i] = 0
	run_in_progress = true
	GameEvents.race_reset.emit()


func apply_score(racer_id: int, points: int) -> void:
	scores[racer_id] = int(scores.get(racer_id, 0)) + points
	if scores[racer_id] >= WIN_SCORE and run_in_progress:
		run_in_progress = false
		GameEvents.racer_finished.emit(racer_id, scores[racer_id], 0.0)


func difficulty_for_level(level_id: int) -> Difficulty:
	# Early levels lean easy, later levels ramp up. Tune the thresholds
	# once real levels exist — kept simple/linear for the v1 scaffold.
	if level_id <= 3:
		return Difficulty.EASY
	elif level_id <= 7:
		return Difficulty.MEDIUM
	return Difficulty.HARD
