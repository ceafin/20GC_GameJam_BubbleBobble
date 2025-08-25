extends Node
class_name Main

var _stage_number : int = 0
var stage_number : int:
	get:
		return _stage_number
	set( value ):
		value = max( 1, value )
		if value == _stage_number:
			return
		_stage_number = value
		GSB.stage_changed.emit( _stage_number )

var _lives : int = 3
var lives : int:
	get:
		return _lives
	set( value ):
		value = clamp( value, 0, 99 ) # No negative lives
		if value == _lives:
			return
		_lives = value
		GSB.lives_changed.emit( _lives )

var current_level_path : String = ""

func _ready() -> void:
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func start_game( first_level: String ) -> void:
	
	# Setter will emit signal
	stage_number = 0
	
	current_level_path = first_level
	
	SM.reset()
		
	# Manually emit this one
	GSB.stage_changed.emit( current_level_path )

func go_to_next_level( next_level_path: String, advance_stage: bool = true ) -> void:
	if advance_stage:
		stage_number = _stage_number + 1
	current_level_path = next_level_path
	GSB.stage_changed.emit( current_level_path )

func restart_current_level() -> void:
	if current_level_path != "":
		GSB.stage_changed.emit( current_level_path )
