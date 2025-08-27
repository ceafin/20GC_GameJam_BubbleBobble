extends Node
class_name MonsterFSM

@export var initial_state : MonsterState = null
	
var current_state : MonsterState
var states : Dictionary[ String, MonsterState ] = {}

func _ready() -> void:
	# Check initial state, if not set, grab first child
	if initial_state == null:
		# As long as there is at least one child, set it as initial state
		if get_child_count() > 0:
			initial_state = get_child(0) as MonsterState
		else:
			push_error("MonsterFSM has no initial state set and no child states!")


	# Grab all child states and wire up their signals
	for i in range( get_child_count() ):
		if get_child(i) is MonsterState:
			var monster_state : MonsterState = get_child(i)
			states[monster_state.name.to_lower()] = monster_state
			monster_state.finished.connect( _transition_to_next_state )

	# Wait for owning parent node to be ready
	await owner.ready
	
	if initial_state:
		current_state = initial_state
		initial_state.enter()

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func _transition_to_next_state( acting_state: MonsterState, new_state_name: String ) -> void:
	# Make sure we aren't transitioning into ourselves
	if acting_state != current_state:
		return
	
	# Grab the new state's MonsterState Node, make sure real
	var new_state : MonsterState = states.get( new_state_name.to_lower() )
	if !new_state:
		return
	
	# If we have a current state, leave it
	if current_state:
		current_state.exit()
	
	# Update what is current MonsterState
	current_state = new_state
	
	# Enter the new MonsterState
	new_state.enter()
	
