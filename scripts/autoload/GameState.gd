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

## Every level is just "how are the 4 AI opponents split across
## easy/medium/hard" — [easy_count, medium_count, hard_count], each
## triple summing to RACER_COUNT - 1. This is literally every multiset
## of size 4 drawn from {easy, medium, hard} (15 of them), ordered so
## total difficulty (easy=1, medium=2, hard=3 weight) never decreases
## from one level to the next. When a 4th/5th tier shows up later, add
## more triples the same way — nothing else needs to change.
const LEVEL_AI_COMPOSITION: Array[Array] = [
	[4, 0, 0],  # 1
	[3, 1, 0],  # 2
	[2, 2, 0],  # 3
	[3, 0, 1],  # 4
	[1, 3, 0],  # 5
	[2, 1, 1],  # 6
	[0, 4, 0],  # 7
	[1, 2, 1],  # 8
	[2, 0, 2],  # 9
	[0, 3, 1],  # 10
	[1, 1, 2],  # 11
	[0, 2, 2],  # 12
	[1, 0, 3],  # 13
	[0, 1, 3],  # 14
	[0, 0, 4],  # 15
]
const MAX_LEVEL: int = 15 # keep in sync with LEVEL_AI_COMPOSITION.size()

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


## [easy_count, medium_count, hard_count] for this level's 4 AI opponents.
func level_composition(level_id: int) -> Array:
	var index: int = clampi(level_id - 1, 0, LEVEL_AI_COMPOSITION.size() - 1)
	return LEVEL_AI_COMPOSITION[index]


## One Difficulty per AI opponent (length RACER_COUNT - 1), expanded from
## level_composition() — easiest opponents first.
func ai_difficulties_for_level(level_id: int) -> Array[Difficulty]:
	var counts: Array = level_composition(level_id)
	var result: Array[Difficulty] = []
	for i in int(counts[0]):
		result.append(Difficulty.EASY)
	for i in int(counts[1]):
		result.append(Difficulty.MEDIUM)
	for i in int(counts[2]):
		result.append(Difficulty.HARD)
	return result
