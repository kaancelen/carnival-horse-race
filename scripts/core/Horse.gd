class_name Horse
extends RefCounted
## Pure logic representation of one lane's horse. The scene-tree Horse
## visual (sprite/animation) reads from an instance of this rather than
## owning the state itself — keeps race math testable without the tree.

var racer_id: int
var lane_index: int
var score: int = 0
var progress: float = 0.0 # 0.0 start -> 1.0 finish line, driven by score/target
var is_player: bool = false

func _init(p_racer_id: int, p_lane_index: int, p_is_player: bool = false) -> void:
	racer_id = p_racer_id
	lane_index = p_lane_index
	is_player = p_is_player


func add_score(points: int, win_score: int) -> void:
	score += points
	progress = clampf(float(score) / float(win_score), 0.0, 1.0)


func has_finished(win_score: int) -> bool:
	return score >= win_score
