extends AxelState
class_name AxelWalk

func physics_update( _delta: float ) -> void:
	# Axel lost the floor
	if not axel.is_on_floor():
		finished.emit( self, "fall" )
		return

	# Horizontal move
	var axis : float = Input.get_axis("move_left", "move_right")
	axel.velocity.x = axis * axel.walk_speed

	# I feel like this is too complicated, maybe just if is on floor?
	if axel.jump_assist.has_buffered_jump() and axel.jump_assist.can_jump_now( axel.is_on_floor() ):
		axel.start_jump()
		finished.emit( self, "jump" )
		return

	# Let go of input? Transition to Idle when nearly stopped
	if axis == 0.0 and is_zero_approx( axel.velocity.x ):
		finished.emit( self, "idle" )
