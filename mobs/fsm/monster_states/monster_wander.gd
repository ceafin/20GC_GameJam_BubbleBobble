extends MonsterState
class_name MonsterWander

var move_direction : Vector2 = Vector2.ZERO

@export var wander_time : float
@export var move_speed : float = 50

func enter() -> void:
	print( "Wander!" )
	_randomize_wander()


func update(_delta: float) -> void:
	if wander_time > 0:
		wander_time -= _delta
	else:
		_randomize_wander()

func physics_update(_delta: float) -> void:
	if monster:
		monster.velocity = move_direction * move_speed
	
	if !monster.is_on_floor():
		finished.emit( self, "fall" )


func _randomize_wander() -> void:
	move_direction = Vector2( randf_range( -1, 1 ), 0 ).normalized()
	wander_time = randf_range( 1, 3 )
