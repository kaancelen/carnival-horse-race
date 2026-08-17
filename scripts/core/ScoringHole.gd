class_name ScoringHole
extends RefCounted
## Plain data description of one of the six scoring holes. Not a scene —
## the visual hole is a Node2D/Area2D in the scene tree that HOLDS a
## reference to one of these, keeping scoring rules independent of
## presentation.
##
## Symmetry by design: 1 red (6) + 2 yellow (3 each, =6) + 3 green
## (2 each, =6) — every color tier is worth the same total, so choosing
## a hole is a risk-vs-reliability decision, not a strictly-better choice.

enum Tier { RED, YELLOW, GREEN }

const POINTS_BY_TIER := {
	Tier.RED: 6,
	Tier.YELLOW: 3,
	Tier.GREEN: 2,
}

var id: StringName
var tier: Tier
var points: int

func _init(p_id: StringName, p_tier: Tier) -> void:
	id = p_id
	tier = p_tier
	points = POINTS_BY_TIER[p_tier]


static func default_layout() -> Array[ScoringHole]:
	# Standard six-hole board: 1 red, 2 yellow, 3 green.
	var holes: Array[ScoringHole] = []
	holes.append(ScoringHole.new(&"red", Tier.RED))
	holes.append(ScoringHole.new(&"yellow_l", Tier.YELLOW))
	holes.append(ScoringHole.new(&"yellow_r", Tier.YELLOW))
	holes.append(ScoringHole.new(&"green_l", Tier.GREEN))
	holes.append(ScoringHole.new(&"green_c", Tier.GREEN))
	holes.append(ScoringHole.new(&"green_r", Tier.GREEN))
	return holes
