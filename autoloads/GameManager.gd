extends Node

signal game_state_changed( state: GameState )
signal stage_changed( path: String )
#signal stage_changed( stage_number: int)

enum GameState {
	TITLE,
	PLAYING,
	GAME_OVER
}

var _state : GameState = GameState.TITLE
var _stage_number : int = 0

var state : GameState:
	get:
		return _state
	set( value ):
		if value == _state:
			return
		_state = value
		emit_signal( "game_state_changed", _state )

var stage_number : int:
	get:
		return _stage_number
	set( value ):
		value = max( 1, value )
		if value == _stage_number:
			return
		_stage_number = value
		emit_signal( "stage_changed", _stage_number )

var current_level_path : String = ""

func _ready() -> void:
	
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Yell out them signal emissions
	emit_signal( "game_state_changed", _state )
	emit_signal( "stage_changed", _stage_number )

func start_game( first_level: String ) -> void:
	
	# Setter will emit signal
	stage_number = 0
	
	current_level_path = first_level
	
	ScoreManager.reset_run()
	
	# Setter will emit signal
	state = GameState.PLAYING
	
	# Manually emit this one
	emit_signal( "stage_changed", current_level_path )

func go_to_title() -> void:
	state = GameState.TITLE

func go_to_next_level( next_level_path: String, advance_stage: bool = true ) -> void:
	if advance_stage:
		stage_number = _stage_number + 1
	current_level_path = next_level_path
	emit_signal("stage_changed", current_level_path)

func restart_current_level() -> void:
	if current_level_path != "":
		emit_signal( "stage_changed", current_level_path )
