extends Node
class_name GameManager

enum GameState {
	TITLE,
	PLAYING,
	GAME_OVER
}

var _state : GameState = GameState.TITLE
var _stage_number : int = 0
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


var state : GameState:
	get:
		return _state
	set( value ):
		if value == _state:
			return
		_state = value
		GSB.game_state_changed.emit( _state )

var stage_number : int:
	get:
		return _stage_number
	set( value ):
		value = max( 1, value )
		if value == _stage_number:
			return
		_stage_number = value
		GSB.stage_changed.emit( _stage_number )

var current_level_path : String = ""

func _ready() -> void:
	
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Yell out them signal emissions
	GSB.game_state_changed.emit( _state )
	GSB.stage_changed.emit( _stage_number )

func start_game( first_level: String ) -> void:
	
	# Setter will emit signal
	stage_number = 0
	
	current_level_path = first_level
	
	SM.reset()
	
	# Setter will emit signal
	state = GameState.PLAYING
	
	# Manually emit this one
	GSB.stage_changed.emit( current_level_path )

func go_to_title() -> void:
	state = GameState.TITLE

func go_to_next_level( next_level_path: String, advance_stage: bool = true ) -> void:
	if advance_stage:
		stage_number = _stage_number + 1
	current_level_path = next_level_path
	GSB.stage_changed.emit( current_level_path )

func restart_current_level() -> void:
	if current_level_path != "":
		GSB.stage_changed.emit( current_level_path )
