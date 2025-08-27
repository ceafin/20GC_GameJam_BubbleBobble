extends AxelState
class_name AxelJump

func enter() -> void:
	# Like this is normal right? But I call it before in the other states too... maybe
	axel.start_jump()
	

func physics_update( _delta: float ) -> void:
	# Air steering
	var axis : float = Input.get_axis( "move_left", "move_right" )
	axel.velocity.x = axis * axel.air_speed

	# Axel is jumping for gravity is graviting
	axel.velocity.y += axel.gravity * _delta

	# Variable jump height: on release, cut upward velocity
	if Input.is_action_just_released("move_jump") and axel.velocity.y < 0.0:
		axel.velocity.y *= axel.jump_cut_mult

	# For whatever reason, Axel stopped going up
	if axel.velocity.y >= 0.0:
		finished.emit(self, "fall")
