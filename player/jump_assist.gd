extends Node
class_name JumpAssist

@export var coyote_time : float = 0.2
@export var jump_buffer_time : float = 0.2

var _coyote_left : float = 0.0
var _buffer_left : float = 0.0
var _was_on_floor : bool = false

func note_jump_pressed() -> void:
	_buffer_left = jump_buffer_time

func physics_tick( _delta: float, is_on_floor: bool ) -> void:
	# Refresh coyote when leaving floor this frame
	if _was_on_floor and not is_on_floor:
		_coyote_left = coyote_time
	_was_on_floor = is_on_floor

	if _coyote_left > 0.0:
		_coyote_left = maxf( 0.0, _coyote_left - _delta )

	if _buffer_left > 0.0:
		_buffer_left = maxf( 0.0, _buffer_left - _delta )

func can_jump_now( is_on_floor: bool ) -> bool:
	return is_on_floor or _coyote_left > 0.0

func has_buffered_jump() -> bool:
	return _buffer_left > 0.0

func consume_after_jump() -> void:
	_coyote_left = 0.0
	_buffer_left = 0.0
