extends Control
## BallThrower
## -----------------------------------------------------------------------
## Full-screen input layer for the player's throw. Swipe anywhere on
## screen: the horizontal release position picks the nearest hole on the
## ScoringBoard, the ball flies there, then scores through the exact same
## GameEvents.report_score() funnel AI opponents use.
## -----------------------------------------------------------------------

const BALL_RADIUS := 30.0
const FLIGHT_TIME := 0.45
const ARC_HEIGHT := 220.0
const MIN_SWIPE_DISTANCE := 20.0
const BALL_PARK_MARGIN_BOTTOM := 140.0

var _drag_start: Vector2 = Vector2.ZERO
var _dragging: bool = false
var _current_ball: Control = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_spawn_ready_ball()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_press_release(event.pressed, event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_press_release(event.pressed, event.position)


func _handle_press_release(pressed: bool, pos: Vector2) -> void:
	if pressed:
		_drag_start = pos
		_dragging = true
	elif _dragging:
		_dragging = false
		_on_swipe_released(_drag_start, pos)


func _on_swipe_released(start: Vector2, end: Vector2) -> void:
	if not GameState.run_in_progress:
		return
	if _current_ball == null:
		return
	if start.distance_to(end) < MIN_SWIPE_DISTANCE:
		return
	var board := get_tree().get_first_node_in_group(&"scoring_board")
	if board == null:
		return
	var hole: ScoringHole = board.closest_hole_to_x(end.x)
	if hole == null:
		return
	_throw_ball(start, board.global_landing_point(hole.id), hole)


func _throw_ball(start: Vector2, target: Vector2, hole: ScoringHole) -> void:
	GameEvents.ball_thrown.emit(GameState.player_racer_id, (target - start).normalized(), 1.0)

	var ball := _current_ball
	_current_ball = null
	var origin := ball.global_position + ball.size / 2.0

	var tween := create_tween()
	tween.tween_method(
		func(t: float) -> void:
			var pos := origin.lerp(target, t)
			pos.y -= sin(t * PI) * ARC_HEIGHT
			ball.global_position = pos - ball.size / 2.0,
		0.0, 1.0, FLIGHT_TIME
	)
	tween.finished.connect(func() -> void:
		ball.queue_free()
		GameEvents.ball_landed.emit(GameState.player_racer_id, hole.id)
		GameEvents.report_score(GameState.player_racer_id, hole.points, hole.id)
		_spawn_ready_ball()
	)


func _spawn_ready_ball() -> void:
	var ball := _make_ball()
	add_child(ball)
	ball.position = _parked_position() - ball.size / 2.0
	_current_ball = ball


func _parked_position() -> Vector2:
	return Vector2(size.x / 2.0, size.y - BALL_PARK_MARGIN_BOTTOM)


func _make_ball() -> Control:
	var ball := Panel.new()
	ball.size = Vector2(BALL_RADIUS * 2, BALL_RADIUS * 2)
	ball.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.95, 0.95, 0.9)
	style.set_corner_radius_all(int(BALL_RADIUS))
	ball.add_theme_stylebox_override("panel", style)
	return ball
