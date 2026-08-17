extends Node
## GameEvents
## -----------------------------------------------------------------------
## Central event bus. This is the ONLY place scoring gets reported from.
## AI opponents, the local player, and (future) remote multiplayer racers
## all funnel through racer_scored — nothing downstream needs to know
## or care where a point came from.
## -----------------------------------------------------------------------

## Emitted the instant any racer earns points from a hole.
## racer_id: int (0 = player, 1..4 = AI lanes; stable across a race)
## points: int (2, 3, or 6 depending on hole tier)
## hole_id: StringName, e.g. &"red", &"yellow_l", &"green_r" — useful for
## audio/vfx feedback and analytics without re-deriving it from points.
signal racer_scored(racer_id: int, points: int, hole_id: StringName)

## Emitted when a racer's cumulative score crosses the win target (24 by default).
signal racer_finished(racer_id: int, final_score: int, race_time: float)

## Emitted once all racers have finished (or race is otherwise concluded).
signal race_ended(results: Array)

## Fired every physics/process tick with each racer's current lane progress
## (0.0 -> 1.0). UI and AudioDirector's crowd-tension system subscribe to this
## rather than polling racer nodes directly.
signal race_positions_updated(progress_by_racer: Dictionary)

## Player-input side, kept separate from scoring so ball physics/aim code
## doesn't need to reach into RaceManager directly.
signal ball_thrown(racer_id: int, aim_vector: Vector2, power: float)
signal ball_landed(racer_id: int, hole_id: StringName)

## Meta / flow events.
signal race_started(level_id: int)
signal level_completed(level_id: int, stars: int)
signal race_reset()


func report_score(racer_id: int, points: int, hole_id: StringName) -> void:
	# Single funnel point — call this instead of emitting racer_scored directly
	# so we always have one place to add logging/analytics later.
	racer_scored.emit(racer_id, points, hole_id)
