extends Node
class_name AxelFSM

@export var initial_state : AxelState = null
	
var current_state : AxelState
var states : Dictionary[ String, AxelState ] = {}

func _ready() -> void:
	# Check initial state, if not set, grab first child
	if initial_state == null:
		# As long as there is at least one child, set it as initial state
		if get_child_count() > 0:
			initial_state = get_child(0) as AxelState
		else:
			push_error( "AxelFSM has no initial state set and no child states!" )


	# Grab all child states and wire up their signals
	for i in range( get_child_count() ):
		if get_child(i) is AxelState:
			var axel_state : AxelState = get_child(i)
			states[axel_state.name.to_lower()] = axel_state
			axel_state.finished.connect( _transition_to_next_state )

	# Wait for owning parent node to be ready
	await owner.ready
	
	if initial_state:
		current_state = initial_state
		initial_state.enter()

func _unhandled_input( event: InputEvent ) -> void:
	if current_state:
		current_state.handle_input( event )


func _process( delta: float ) -> void:
	if current_state:
		current_state.update( delta )


func _physics_process( delta: float ) -> void:
	if current_state:
		current_state.physics_update( delta )


func _transition_to_next_state( acting_state: AxelState, new_state_name: String ) -> void:
	# Make sure we aren't transitioning into ourselves
	if acting_state != current_state:
		return
	
	# Grab the new state's AxelState Node, make sure real
	var new_state: AxelState = states.get( new_state_name.to_lower() )
	if !new_state:
		return
	
	# If we have a current state, leave it
	if current_state:
		current_state.exit()
	
	# Update what is current AxelState
	current_state = new_state
	
	# Enter the new AxelState
	new_state.enter()
	
