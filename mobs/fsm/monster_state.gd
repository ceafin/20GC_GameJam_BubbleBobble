extends Node
class_name MonsterState

@export var selectable_in_idle : bool = false
@export var idle_weight : float = 1.0  # Weighted random pick for Idle

var monster : BaseMonster

signal finished(acting_state: MonsterState, new_state_name: String)

func _ready() -> void:
	await owner.ready
	monster = owner as CharacterBody2D
	assert(
		monster != null,
		"The MonsterState state type must be used only in the Monster scene. It needs the owner to be a BaseMonster node."
	)
	

# Called by the state machine when receiving unhandled input events
func handle_input(_event: InputEvent) -> void: pass

# Called by the state machine on the engine's main loop tick
func update(_delta: float) -> void: pass

# Called by the state machine on the engine's physics update tick
func physics_update(_delta: float) -> void: pass

# Called by the state machine upon changing the active state
func enter() -> void: pass

# Called by the state machine before changing the active state
# Use this function to clean up the state
func exit() -> void: pass
