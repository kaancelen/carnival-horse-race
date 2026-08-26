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

const SAVE_PATH := "user://save.cfg"

## racer_id -> current score
var scores: Dictionary = {}

## racer_id -> Difficulty (only meaningful for AI racers)
var ai_difficulty: Dictionary = {}

var current_level: int = 1
var player_racer_id: int = 0

var run_in_progress: bool = false

## Persisted across launches: the highest level the player has WON (not
## just played). Levels beyond this + 1 are locked. 0 means no wins yet.
var highest_completed_level: int = 0

## Transient result of the race that just ended — set by
## RaceManager._on_race_ended() right before it routes to Victory/Defeat,
## read by those screens. Not persisted.
var last_race_won: bool = false
var last_race_player_score: int = 0
var last_race_winner_score: int = 0

## Player-only throw stats for the CURRENT race, reset in reset_race()
## and read by Victory/Defeat after the race ends — real numbers derived
## from GameEvents, not display flavor. AI throws never count here.
var player_throws: int = 0
var player_hits: int = 0
var red_hits: int = 0
var yellow_hits: int = 0
var green_hits: int = 0


func _ready() -> void:
	_load_progress()
	GameEvents.ball_thrown.connect(_on_ball_thrown)
	GameEvents.racer_scored.connect(_on_racer_scored_stats)


func _on_ball_thrown(racer_id: int, _aim_vector: Vector2, _power: float) -> void:
	if racer_id == player_racer_id:
		player_throws += 1


func _on_racer_scored_stats(racer_id: int, _points: int, hole_id: StringName) -> void:
	if racer_id != player_racer_id:
		return
	player_hits += 1
	var id_str := str(hole_id)
	if id_str.begins_with("red"):
		red_hits += 1
	elif id_str.begins_with("yellow"):
		yellow_hits += 1
	elif id_str.begins_with("green"):
		green_hits += 1


## 0.0-1.0, hits / throws for the current race. 0 if no throws yet.
func player_accuracy() -> float:
	if player_throws <= 0:
		return 0.0
	return float(player_hits) / float(player_throws)


func _load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		highest_completed_level = int(cfg.get_value("progress", "highest_completed_level", 0))


func _save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "highest_completed_level", highest_completed_level)
	cfg.save(SAVE_PATH)


## Call once the player has WON level_id's race. No-ops (and doesn't
## re-save) if that level was already cleared or is behind the frontier.
func complete_level(level_id: int) -> void:
	if level_id > highest_completed_level:
		highest_completed_level = level_id
		_save_progress()


func has_progress() -> bool:
	return highest_completed_level > 0


## Sequential unlock: you can replay anything you've cleared, plus the
## one level right after your current frontier.
func is_level_unlocked(level_id: int) -> bool:
	return level_id <= highest_completed_level + 1


## What MainMenu's PLAY/CONTINUE button should jump to: level 1 for a
## fresh save, the first not-yet-cleared level otherwise, or the last
## level again once everything is cleared.
func next_playable_level() -> int:
	if highest_completed_level <= 0:
		return 1
	return mini(highest_completed_level + 1, MAX_LEVEL)


func reset_race() -> void:
	scores.clear()
	for i in range(RACER_COUNT):
		scores[i] = 0
	run_in_progress = true
	player_throws = 0
	player_hits = 0
	red_hits = 0
	yellow_hits = 0
	green_hits = 0
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
