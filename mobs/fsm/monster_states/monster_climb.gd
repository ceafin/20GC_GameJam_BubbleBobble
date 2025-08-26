extends MonsterState
class_name MonsterClimb

@export var climb_time : float = 0.6
@export var climb_speed : float = 75

var _time_left : float = 0.0

func enter() -> void:
	print( monster.name + " Chose: Climbing!" )
	_time_left = climb_time
	monster.velocity = Vector2.ZERO

func update( _delta: float ) -> void:
	_time_left -= _delta
	if _time_left <= 0.0:
		finished.emit( self, "idle" )

func physics_update( _delta: float ) -> void:
	monster.velocity = climb_speed * Vector2.UP.normalized()
	
	if _time_left <= 0.0:
		finished.emit( self, "idle" )

func exit() -> void:
	# Stop vertical boost
	if monster:
		monster.velocity.y = 0.0
