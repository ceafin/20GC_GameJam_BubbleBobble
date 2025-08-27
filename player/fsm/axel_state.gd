extends Node
class_name AxelState


var axel : Axel

signal finished( acting_state: AxelState, new_state_name: String )

func _ready() -> void:
	await owner.ready
	axel = owner as Axel
	assert(
		axel != null,
		"The AxelState state type must be used only in the Axel scene. It needs the owner to be a Axel node."
	)
	

# Called by the state machine when receiving unhandled input events
func handle_input( _event: InputEvent ) -> void: pass

# Called by the state machine on the engine's main loop tick
func update( _delta: float ) -> void: pass

# Called by the state machine on the engine's physics update tick
func physics_update( _delta: float ) -> void: pass

# Called by the state machine upon changing the active state
func enter() -> void: pass

# Called by the state machine before changing the active state
# Use this function to clean up the state
func exit() -> void: pass
