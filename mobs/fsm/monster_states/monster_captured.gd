extends MonsterState
class_name MonsterCaptured

@export var float_speed : float = 60.0
@export var accel       : float = 300.0
@export var stop_radius : float = 6.0

@export var separation_radius   : float = 16.0
@export var separation_strength : float = 120.0
@export var max_neighbors       : int = 6


func _ready() -> void:
	await owner.ready
	monster = owner as BaseMonster
	assert( monster != null, "The MonsterCaptured state type must be used only in the Monster scene. It needs the owner to be a BaseMonster node." )
	

func physics_update( _delta: float ) -> void:
	# Find the bubble magnet
	var to_target : Vector2 = monster.bubble_magnet_position - monster.global_position
	var desired := Vector2.ZERO
	if to_target.length() > stop_radius:
		desired = to_target.normalized() * float_speed
	# Push other monsters out of the way
	desired += _get_out_of_the_way()
	# Check where the magnet is one more time
	if desired.length() > float_speed:
		desired = desired.normalized() * float_speed
	# Actually move now
	monster.velocity = monster.velocity.move_toward( desired, accel * _delta )

func enter() -> void:
	# Cancel out any velocity
	monster.velocity = Vector2.ZERO
	# Put them in a temp group since they're bubblized
	monster.add_to_group( "captured_monsters" )
	# Set the flag
	monster.is_captured = true

func exit() -> void:
	# Leaving the state, leave the group!
	monster.remove_from_group( "captured_monsters" )
	# Unset the flag
	monster.is_captured = false

# How much to push others out of the way
func _get_out_of_the_way() -> Vector2:
	var push := Vector2.ZERO
	var count : int = 0
	
	# Get all those who are captured with me
	for cm : BaseMonster in get_tree().get_nodes_in_group( "captured_monsters" ) as Array[BaseMonster]:
		# If I found myself skip me
		if cm == monster:
			continue
		
		var diff : Vector2 = monster.global_position - cm.global_position
		var dist : float = diff.length()
		if dist > 0.001 and dist < separation_radius:
			# inverse-square falloff gives a nice “squeeze but not jitter”
			push += diff / ( dist * dist )
			count += 1
			if count >= max_neighbors:
				break
	# If no need to push, no pushie
	if push == Vector2.ZERO:
		return push
	# Otherwise, pushie
	return push.normalized() * separation_strength
