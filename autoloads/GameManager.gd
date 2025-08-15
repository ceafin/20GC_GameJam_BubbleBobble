extends Node

## Signals to yell
signal game_state_changed( state: String)
signal level_changed( path: String)
signal stage_changed( stage_number: int)

# State Strings... might use enums later? I dunno...
const STATE_TITLE : String = "TITLE"
const STATE_PLAYING : String = "PLAYING"
const STATE_GAME_OVER :String = "GAME_OVER"

# The /REAL/ Variables
var _state: String = STATE_TITLE
var _stage_number: int = 1

## Getter/Setter for the game's state
var state : String:
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
	# Wake up when scenetree gets the pause
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Yell out them signal emissions
	emit_signal( "game_state_changed", _state )
	emit_signal( "stage_changed", _stage_number )


func start_game( first_level: String ) -> void:
	stage_number = 1                # uses the property -> emits stage_changed
	current_level_path = first_level
	ScoreManager.reset_run()
	state = STATE_PLAYING           # uses the property -> emits game_state_changed
	emit_signal("level_changed", current_level_path)

func go_to_title() -> void:
	state = STATE_TITLE

func go_to_next_level(next_level_path: String, advance_stage: bool = true) -> void:
	if advance_stage:
		stage_number = _stage_number + 1
	current_level_path = next_level_path
	emit_signal("level_changed", current_level_path)

func restart_current_level() -> void:
	if current_level_path != "":
		emit_signal("level_changed", current_level_path)
