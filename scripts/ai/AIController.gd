class_name AIController
extends Node
## Drives one AI-controlled horse. Scores through the exact same
## GameEvents.report_score() funnel a human player's ball-landing code
## uses — RaceManager can't tell the difference, which is also what
## will let a future networked remote player slot in without changes
## to RaceManager or Horse.

var racer_id: int
var difficulty: GameState.Difficulty = GameState.Difficulty.EASY

## Per-difficulty tuning. accuracy: chance to hit the INTENDED hole vs.
## slipping to a neighboring lower tier. throw_interval: seconds between
## throws (lower = plays faster/more aggressively).
const PROFILES := {
	GameState.Difficulty.EASY: {
		"accuracy": 0.55,
		"throw_interval": 2.2,
		"red_bias": 0.10,   # how often it even attempts the risky red hole
	},
	GameState.Difficulty.MEDIUM: {
		"accuracy": 0.72,
		"throw_interval": 1.7,
		"red_bias": 0.25,
	},
	GameState.Difficulty.HARD: {
		"accuracy": 0.88,
		"throw_interval": 1.2,
		"red_bias": 0.45,
	},
}

var _timer: float = 0.0
var _holes: Array[ScoringHole] = []
var _rng := RandomNumberGenerator.new()


func _init(p_racer_id: int, p_difficulty: GameState.Difficulty) -> void:
	racer_id = p_racer_id
	difficulty = p_difficulty
	_holes = ScoringHole.default_layout()
	_rng.randomize()


func _ready() -> void:
	_timer = _profile()["throw_interval"]


func _process(delta: float) -> void:
	if not GameState.run_in_progress:
		return
	_timer -= delta
	if _timer <= 0.0:
		_take_throw()
		_timer = _profile()["throw_interval"]


func _profile() -> Dictionary:
	return PROFILES[difficulty]


func _take_throw() -> void:
	var target := _choose_target_hole()
	var landed := _resolve_throw(target)
	GameEvents.ball_thrown.emit(racer_id, Vector2.ZERO, 1.0)
	GameEvents.ball_landed.emit(racer_id, landed.id)
	GameEvents.report_score(racer_id, landed.points, landed.id)


func _choose_target_hole() -> ScoringHole:
	var profile := _profile()
	if _rng.randf() < profile["red_bias"]:
		return _hole_by_tier(ScoringHole.Tier.RED)
	elif _rng.randf() < 0.5:
		return _hole_by_tier(ScoringHole.Tier.YELLOW)
	return _hole_by_tier(ScoringHole.Tier.GREEN)


func _hole_by_tier(tier: ScoringHole.Tier) -> ScoringHole:
	var candidates: Array[ScoringHole] = _holes.filter(func(h): return h.tier == tier)
	return candidates[_rng.randi_range(0, candidates.size() - 1)]


func _resolve_throw(target: ScoringHole) -> ScoringHole:
	# Miss chance: falls back to a lower/neighboring tier rather than a
	# total whiff, so misses still feel fair rather than wasted turns.
	var profile := _profile()
	if _rng.randf() <= profile["accuracy"]:
		return target
	if target.tier == ScoringHole.Tier.RED:
		return _hole_by_tier(ScoringHole.Tier.YELLOW)
	elif target.tier == ScoringHole.Tier.YELLOW:
		return _hole_by_tier(ScoringHole.Tier.GREEN)
	return target # green miss just stays green, nowhere lower to fall to
