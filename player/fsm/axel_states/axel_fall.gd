extends AxelState
class_name AxelFall


func physics_update(delta: float) -> void:
	# Horizontal air control
	var axis : float = Input.get_axis("move_left", "move_right")
	axel.velocity.x = axis * axel.air_speed

	# Gravity and terminal velocty
	axel.velocity.y += axel.gravity * delta
	axel.velocity.y = min( axel.velocity.y, axel.max_fall )

	# Did Axel find some floors
	if axel.is_on_floor():
		# If a jump is in the pipe, jump; else legs
		if axel.jump_assist.has_buffered_jump():
			axel.start_jump() # STILL debating on calling it here, or only in the Jump, or both...
			finished.emit( self, "jump" )
		else:
			finished.emit( self, "walk" if axis != 0.0 else "idle" )
			return

	# Coyote jump (works only for a short time after leaving floor)
	if axel.jump_assist.has_buffered_jump() and axel.jump_assist.can_jump_now( axel.is_on_floor() ):
		axel.start_jump()
		finished.emit( self, "jump" )
