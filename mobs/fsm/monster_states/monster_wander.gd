extends MonsterState
class_name MonsterWander

var move_direction : Vector2 = Vector2.ZERO

@export var wander_time : float

func enter() -> void:
	_randomize_wander()


func update(_delta: float) -> void:
	if wander_time > 0:
		wander_time -= _delta

func physics_update(_delta: float) -> void:
	
	if !monster.is_on_floor():
		finished.emit( self, "fall" )
		return
	
	if wander_time <= 0.0:
		finished.emit(self, "idle")
		return
	
	monster.velocity = move_direction * monster.move_speed




func _randomize_wander() -> void:
	move_direction = Vector2( randf_range( -1, 1 ), 0 ).normalized()
	wander_time = randf_range( .5, 2 )
