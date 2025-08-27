extends AxelState
class_name AxelIdle


func physics_update( _delta: float ) -> void:
	axel.velocity.x = 0.0
	
	# If we somehow lose the floor, go to falling
	if not axel.is_on_floor():
		finished.emit( self, "fall" )
		return

	# Buffered jump or just plain jump jump, call that jump function
	if axel.jump_assist.has_buffered_jump() and axel.jump_assist.can_jump_now( axel.is_on_floor() ):
		finished.emit( self, "jump" )
		return

	# If the player went left or right FROM IDLE, walk
	var axis := Input.get_axis( "move_left", "move_right" )
	if axis != 0.0:
		finished.emit( self, "walk" )
	
