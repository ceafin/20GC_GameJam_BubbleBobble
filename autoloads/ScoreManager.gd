extends Node
class_name ScoreManager

## The REAL Variables
var _score : int = 0
var _high_score : int = 0


## Getter/Setter for grabbing them vegetables
var score : int:
	get:
		return _score
	set( value ):
		value = max( value, 0 ) # Don't need negative scores being set
		if value == _score:
			return
		_score = value
		GSB.score_changed.emit( _score )
		
		# Update highscore if it's higher
		if _score > _high_score:
			# Using Setter to Trigger Signal
			high_score = _score

var high_score : int:
	get:
		return _high_score
	set( value ):
		value = max( value, 0 )
		if value == _high_score:
			return
		_high_score = value
		GSB.high_score_changed.emit( _high_score )
		# Go write it down immediately
		SaveData.set_high_score( _high_score )


func _ready() -> void:
	
	# Go read the highscore and signal for it
	_high_score = SaveData.get_high_score()
	GSB.high_score_changed.emit( _high_score )

func reset() -> void:
	score = 0


func add( points: int ) -> void:
	score = _score + points
