extends MonsterState
class_name MonsterFall

@export var gravity : float = 400.0

func enter() -> void:
	print("Falling!")

func physics_update(_delta: float) -> void:
	
	monster.velocity.y += gravity * _delta
	
	if monster.is_on_floor():
		finished.emit( self, "idle" )
