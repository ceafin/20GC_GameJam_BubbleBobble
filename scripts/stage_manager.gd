extends Node2D
class_name StageManager

@export var intro_stage : PackedScene

var _current_index  : int = -1
var _queued_index   : int = -1
var _queued_path    : String = ""
var _queued_packed  : PackedScene = null
var _is_loading     : bool = false

var viewport_size : Vector2

@onready var scroller       : Node2D = $Scroller
@onready var current_holder : Node2D = $Scroller/CurrentHolder
@onready var next_holder    : Node2D = $Scroller/NextHolder


func _ready() -> void:
	viewport_size = get_viewport_rect().size

	_current_index = 0
	_load_current_sync( _current_index )
	_prefetch_next()

	#transition_btn.pressed.connect( _on_transition_level_button_pressed )
	

func _process( _delta: float ) -> void:
	_poll_threaded_load()
	_load_next_if_ready()
	

func _load_current_sync( index: int ) -> void:
	var path : String = StageCatalog.path_at( index )
	if path.is_empty():
		push_error( "No stage at index %d" % index )
		return
	
	var packed : PackedScene = ResourceLoader.load(path, "PackedScene") as PackedScene
	if not packed:
		push_error( "Failed to load %s" % path )
		return
	
	current_holder.add_child( packed.instantiate() )

# Backbround load for the next stage/level
func _prefetch_next() -> void:
	_queued_index = StageCatalog.next_index( _current_index )
	_queued_path = StageCatalog.path_at( _queued_index )
	_queued_packed = null
	
	if _queued_path.is_empty():
		return
	
	var err : Error = ResourceLoader.load_threaded_request(
		_queued_path,
		"PackedScene",
		true
	)
	
	if err != OK:
		push_error( "Threaded request failed for %s (err=%d)" % [_queued_path, err] )
		_is_loading = false
	else:
		_is_loading = true

# Poll threadd for loading PackedScene into memory
func _poll_threaded_load() -> void:
	# Bounce out if it's blank or not loading
	if not _is_loading or _queued_path.is_empty():
		return
	
	var status := ResourceLoader.load_threaded_get_status( _queued_path )
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			pass
		ResourceLoader.THREAD_LOAD_LOADED:
			_queued_packed = ResourceLoader.load_threaded_get( _queued_path ) as PackedScene
			_is_loading = false
		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_error( "Threaded load failed for %s" % _queued_path )
			_is_loading = false

# Load up the next stage if NextHolder is empty and we got one in the queue
func _load_next_if_ready() -> void:
	if _queued_packed and next_holder.get_child_count() == 0:
		var that_new_stage : Node = _queued_packed.instantiate()
		next_holder.add_child( that_new_stage )
		next_holder.position = Vector2( 0, viewport_size.y )
	
# Good ol' manual loader like I had originally
func _fallback_sync_load_next() -> void:
	# If we queued up nothingness, boucne out
	if _queued_path.is_empty():
		return
		
	# If we have a PackedScene queued up; else go get it by path
	var packed : PackedScene = _queued_packed if _queued_packed else ResourceLoader.load( _queued_path, "PackedScene" ) as PackedScene
	if not packed:
		push_error( "Fallback sync load failed for %s" % _queued_path )
		return
	
	next_holder.add_child( packed.instantiate() )
	next_holder.position = Vector2( 0, viewport_size.y )
	

# This was hooked up to a button... but soon a "Level Finished" condition
func _on_transition_level_button_pressed() -> void:
	# If NextHolder is still empty, fall back to normal load
	if next_holder.get_child_count() == 0:
		_fallback_sync_load_next()

	var that_level_tween : Tween = create_tween().set_trans( Tween.TRANS_CUBIC ).set_ease( Tween.EASE_IN_OUT )
	that_level_tween.tween_property( scroller, "position:y", -viewport_size.y, 4.0 )
	that_level_tween.finished.connect( _finish_slide )
	

# In between frames after tweening, do all the clean up!
func _finish_slide() -> void:
	# Remove old current
	if current_holder.get_child_count() > 0:
		current_holder.get_child(0).queue_free()

	# Move new stage into current
	scroller.position = Vector2.ZERO
	next_holder.position = Vector2.ZERO

	if next_holder.get_child_count() > 0:
		var arrived : Node = next_holder.get_child(0)
		next_holder.remove_child( arrived )
		current_holder.add_child( arrived )

	# Clear NextHolder container entirely
	for stage in next_holder.get_children():
		stage.queue_free()

	# Advance index and immediately prefetch the next level
	_current_index = _queued_index
	_prefetch_next()
