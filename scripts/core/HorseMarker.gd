class_name HorseMarker
extends Control
## HorseMarker
## -----------------------------------------------------------------------
## Race lane marker: plays the gallop cycle sliced out of a Horse Pack
## sheet (see assets/sprites/horses, credited in README.md). Each sheet is
## a grid of 64x48 cells; row RUN_ROW holds the side-view running frames.
## -----------------------------------------------------------------------

const FRAME_SIZE := Vector2i(64, 48)
const RUN_ROW := 12
const RUN_FRAME_COUNT := 6
const FRAME_DURATION := 0.08

var _frames: Array[AtlasTexture] = []
var _frame_index: int = 0
var _elapsed: float = 0.0
var _rect: TextureRect


func _ready() -> void:
	_rect = TextureRect.new()
	_rect.anchor_right = 1.0
	_rect.anchor_bottom = 1.0
	_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Sheet frames face left; lanes fill left-to-right as progress increases.
	_rect.flip_h = true
	add_child(_rect)
	if _frames.is_empty():
		set_process(false)
	else:
		_rect.texture = _frames[_frame_index]
		set_process(true)


func set_horse_texture(sheet: Texture2D) -> void:
	_frames.clear()
	for i in RUN_FRAME_COUNT:
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2(
			Vector2(i * FRAME_SIZE.x, RUN_ROW * FRAME_SIZE.y),
			Vector2(FRAME_SIZE)
		)
		_frames.append(atlas)
	_frame_index = 0
	_elapsed = 0.0
	if _rect != null and not _frames.is_empty():
		_rect.texture = _frames[0]
	set_process(not _frames.is_empty())


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed < FRAME_DURATION:
		return
	_elapsed -= FRAME_DURATION
	_frame_index = (_frame_index + 1) % _frames.size()
	_rect.texture = _frames[_frame_index]
