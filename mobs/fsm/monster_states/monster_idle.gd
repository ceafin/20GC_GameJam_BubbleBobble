extends MonsterState
class_name MonsterIdle

var move_direction : Vector2 = Vector2.ZERO

var _think_left : float = 0.0
var _candidates : Array[MonsterState] = []

@export var think_min : float = 1.0
@export var think_max : float = 3.0


func enter() -> void:
	print( "Idle!" )
	_gather_candidates()
	_reset_think()


func update( _delta: float ) -> void:
	_think_left -= _delta
	if _think_left <= 0.0:
		var next : MonsterState = _pick_candidate()
		if next:
			finished.emit( self, next.name )
		_reset_think()

func physics_update( _delta: float ) -> void:
	monster.velocity = Vector2.ZERO

	# Maybe some looking around animation here?
	
	if !monster.is_on_floor():
		finished.emit( self, "fall" )


func _gather_candidates() -> void:
	# Blank out the sibling states list
	_candidates.clear()
	
	# Get parent, should be the FSM
	var parent : Node = get_parent()
	
	# If no parent or not the MonsterFSM, just return
	if ( parent == null ) or ( not parent is MonsterFSM ):
		return
	
	# Iterate through children, looking for other MonsterStates
	for child in parent.get_children():
		if child is MonsterState and child != self:
			var sibling_state: MonsterState = child
			if sibling_state.selectable_in_idle:
				_candidates.append( sibling_state )


func _pick_candidate() -> MonsterState:
	# No siblings? Bounce
	if _candidates.is_empty():
		return null

	# Weighted random idle_weight
	var total : float = 0.0

	for st in _candidates:
		total += max( st.idle_weight, 0.0 )
	
	if total <= 0.0:
		return _candidates[randi() % _candidates.size()]
	
	var roll : float = randf() * total
	var acc : float = 0.0
	
	for st in _candidates:
		acc += max( st.idle_weight, 0.0 )
		if roll <= acc:
			return st
	
	return _candidates.back()


func _reset_think() -> void:
	_think_left = randf_range( think_min, think_max )
