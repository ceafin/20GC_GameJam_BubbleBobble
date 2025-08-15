extends Node

## Signals for changes
signal score_changed( value: int )
signal lives_changed( value: int )
signal high_score_changed( value: int )

## The REAL Variables
var _score : int = 0
var _lives : int = 3
var _high_score : int = 0


## Getter/Setter for grabbing them vegetables
var score : int:
	get:
		return _score
	set( value ):
		value = max( value, 0 )
		if value == _score:
			return
		_score = value
		emit_signal( "score_changed", _score )
		
		# Update highscore if it's higher
		if _score > _high_score:
			# Using Setter to Trigger Signal
			high_score = _score


## Getter/Setter for when you need another quarter
var lives : int:
	get:
		return _lives
	set( value ):
		value = clamp( value, 0, 99 )
		if value == _lives:
			return
		_lives = value
		emit_signal( "lives_changed", _lives )


## Getter/Setter for the Highest of Scores
var high_score : int:
	get:
		return _high_score
	set( value ):
		value = max( value, 0 )
		if value == _high_score:
			return
		_high_score = value
		emit_signal( "high_score_changed", _high_score )
		# Go write it down immediately
		SaveData.set_high_score( _high_score )


func _ready() -> void:
	
	# Pause if you're paused
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	# Go read the highscore and signal for it
	_high_score = SaveData.get_high_score()
	emit_signal( "high_score_changed", _high_score )


func reset_run() -> void:
	score = 0
	lives = 3


func add( points: int ) -> void:
	score = _score + points


func lose_life() -> void:
	lives = _lives - 1
