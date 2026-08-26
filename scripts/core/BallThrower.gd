extends Control
## BallThrower
## -----------------------------------------------------------------------
## Full-screen input layer for the player's throw. This is real 2D
## projectile motion, not an auto-aimed lock-on: the swipe's direction and
## speed set the ball's launch velocity, gravity pulls it down every
## frame, and it only scores if its actual flight path overlaps a hole.
## Bad swipes miss — short throws fall short, wild angles fly wide.
## -----------------------------------------------------------------------

const BALL_RADIUS := 30.0
const BALL_PARK_MARGIN_BOTTOM := 140.0
const MIN_SWIPE_DISTANCE := 40.0

## Tuning: how a swipe (measured in screen px) becomes a launch velocity
## (px/s), and how hard gravity pulls it back down. Bigger GRAVITY or
## smaller VELOCITY_SCALE both make the throw feel heavier/harder.
const GRAVITY := 2500.0
const VELOCITY_SCALE := 4.4
const MAX_LAUNCH_SPEED := 2800.0
const PHYSICS_SUBSTEP := 1.0 / 240.0
const OUT_OF_BOUNDS_MARGIN := 120.0

var _drag_start: Vector2 = Vector2.ZERO
var _dragging: bool = false
var _current_ball: Control = null

var _flying: bool = false
var _flight_ball: Control = null
var _ball_pos: Vector2 = Vector2.ZERO
var _ball_velocity: Vector2 = Vector2.ZERO
var _board: Node = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_arc_hint()
	_build_swipe_hint()
	_spawn_ready_ball()
	set_process(false)


func _build_arc_hint() -> void:
	var arc := ArcHint.new()
	var h := 220.0
	arc.size = Vector2(6, h)
	arc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var parked := _parked_position()
	arc.position = Vector2(parked.x - 3.0, parked.y - BALL_RADIUS - h)
	add_child(arc)


func _build_swipe_hint() -> void:
	var hint := Label.new()
	hint.text = "👆 FLICK — aim & power matter"
	hint.add_theme_font_size_override("font_size", 18)
	hint.add_theme_color_override("font_color", Color("d8be8a"))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint.anchor_left = 0.5
	hint.anchor_right = 0.5
	hint.anchor_top = 1.0
	hint.anchor_bottom = 1.0
	hint.offset_left = -220.0
	hint.offset_right = 220.0
	hint.offset_top = -(BALL_PARK_MARGIN_BOTTOM - BALL_RADIUS - 34.0)
	hint.offset_bottom = -(BALL_PARK_MARGIN_BOTTOM - BALL_RADIUS - 8.0)
	add_child(hint)


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
	if not GameState.run_in_progress or _current_ball == null or _flying:
		return
	var swipe := end - start
	if swipe.length() < MIN_SWIPE_DISTANCE:
		return
	_board = get_tree().get_first_node_in_group(&"scoring_board")
	_launch_ball(swipe)


func _launch_ball(swipe: Vector2) -> void:
	var ball := _current_ball
	_current_ball = null

	var speed: float = clampf(swipe.length() * VELOCITY_SCALE, 0.0, MAX_LAUNCH_SPEED)
	_ball_velocity = swipe.normalized() * speed
	_ball_pos = ball.global_position + ball.size / 2.0
	_flight_ball = ball
	_flying = true
	set_process(true)

	GameEvents.ball_thrown.emit(GameState.player_racer_id, swipe.normalized(), speed / MAX_LAUNCH_SPEED)


func _process(delta: float) -> void:
	if not _flying:
		return
	var remaining := delta
	while remaining > 0.0:
		var dt: float = minf(PHYSICS_SUBSTEP, remaining)
		remaining -= dt
		_ball_velocity.y += GRAVITY * dt
		_ball_pos += _ball_velocity * dt

		var hole: ScoringHole = _board.hole_at_point(_ball_pos) if _board != null else null
		if hole != null:
			_score_hole(hole)
			return
		if _is_out_of_bounds():
			_miss_ball()
			return
	_flight_ball.global_position = _ball_pos - _flight_ball.size / 2.0


func _is_out_of_bounds() -> bool:
	return (
		_ball_pos.y > size.y + OUT_OF_BOUNDS_MARGIN
		or _ball_pos.y < -OUT_OF_BOUNDS_MARGIN
		or _ball_pos.x < -OUT_OF_BOUNDS_MARGIN
		or _ball_pos.x > size.x + OUT_OF_BOUNDS_MARGIN
	)


func _score_hole(hole: ScoringHole) -> void:
	_end_flight()
	GameEvents.ball_landed.emit(GameState.player_racer_id, hole.id)
	GameEvents.report_score(GameState.player_racer_id, hole.points, hole.id)
	_spawn_ready_ball()


func _miss_ball() -> void:
	_end_flight()
	_spawn_ready_ball()


func _end_flight() -> void:
	_flying = false
	set_process(false)
	_flight_ball.queue_free()
	_flight_ball = null
	_board = null


func _spawn_ready_ball() -> void:
	var ball := _make_ball()
	add_child(ball)
	ball.position = _parked_position() - ball.size / 2.0
	_current_ball = ball


func _parked_position() -> Vector2:
	return Vector2(size.x / 2.0, size.y - BALL_PARK_MARGIN_BOTTOM)


func _make_ball() -> Control:
	var ball := Control.new()
	ball.size = Vector2(BALL_RADIUS * 2, BALL_RADIUS * 2)
	ball.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var base := Panel.new()
	base.anchor_right = 1.0
	base.anchor_bottom = 1.0
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var base_style := StyleBoxFlat.new()
	base_style.bg_color = Color("c8352c")
	base_style.set_corner_radius_all(int(BALL_RADIUS))
	base_style.shadow_size = 6
	base_style.shadow_color = Color(0, 0, 0, 0.4)
	base.add_theme_stylebox_override("panel", base_style)
	ball.add_child(base)

	var shine_r := BALL_RADIUS * 0.5
	var shine := Panel.new()
	shine.position = Vector2(BALL_RADIUS * 0.3, BALL_RADIUS * 0.22)
	shine.size = Vector2(shine_r, shine_r)
	shine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shine_style := StyleBoxFlat.new()
	shine_style.bg_color = Color(1, 1, 1, 0.9)
	shine_style.set_corner_radius_all(int(shine_r / 2.0))
	shine.add_theme_stylebox_override("panel", shine_style)
	ball.add_child(shine)

	return ball
