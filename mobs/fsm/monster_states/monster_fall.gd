extends MonsterState
class_name MonsterFall

@export var gravity : float = 400.0
@export var max_fall : float = 50.0


func physics_update( _delta: float ) -> void:
	
	monster.velocity.y += gravity * _delta
	monster.velocity.y = min( monster.velocity.y, max_fall )
	
	if monster.is_on_floor():
		finished.emit( self, "idle" )
		return
	
	if not monster.is_on_floor():
		monster.velocity.x = move_toward( monster.velocity.x, 0.0, 5.0 )
