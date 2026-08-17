extends Node
## AudioDirector
## -----------------------------------------------------------------------
## Audio is a race-position FEEDBACK channel, not background music.
## Hoofbeat tempo scales with a racer's speed/lead; a crowd-tension bed
## rises as the race tightens near the finish. Stubbed for now — wiring
## real AudioStreamPlayers happens once we have actual audio assets.
## -----------------------------------------------------------------------

@export var base_hoofbeat_bpm: float = 100.0
@export var max_hoofbeat_bpm: float = 160.0

var _leader_progress: float = 0.0
var _spread: float = 0.0 # gap between leader and 2nd place; drives tension


func _ready() -> void:
	GameEvents.race_positions_updated.connect(_on_positions_updated)
	GameEvents.race_started.connect(_on_race_started)
	GameEvents.race_ended.connect(_on_race_ended)


func _on_race_started(_level_id: int) -> void:
	_leader_progress = 0.0
	_spread = 0.0
	# TODO: fade in hoofbeat loop + crowd murmur bed


func _on_positions_updated(progress_by_racer: Dictionary) -> void:
	if progress_by_racer.is_empty():
		return
	var values: Array = progress_by_racer.values()
	values.sort()
	values.reverse()
	_leader_progress = values[0]
	_spread = values[0] - (values[1] if values.size() > 1 else 0.0)
	# TODO: map _leader_progress -> hoofbeat tempo (base_hoofbeat_bpm..max_hoofbeat_bpm)
	# TODO: map inverse of _spread -> crowd tension volume/intensity (closer race = louder)


func _on_race_ended(_results: Array) -> void:
	pass # TODO: fade out loops, play crowd cheer sting
