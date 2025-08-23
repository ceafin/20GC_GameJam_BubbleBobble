extends Node2D
class_name StageManager


var _current_index  : int = -1
var _queued_index   : int = -1
var _queued_path    : String = ""
var _queued_packed  : PackedScene = null
var _is_loading     : bool = false
var _is_sliding     : bool = false

var viewport_size : Vector2

@export var slide_time: float = 1.5

@onready var scroller       : Node2D = $Scroller
@onready var current_holder : Node2D = $Scroller/CurrentHolder
@onready var next_holder    : Node2D = $Scroller/NextHolder


func _ready() -> void:
	viewport_size = get_viewport_rect().size
	get_viewport().size_changed.connect(_on_viewport_resized)
	
	_current_index = 0
	_load_current_sync( _current_index )
	_prefetch_next()

func _process( _delta: float ) -> void:
	_poll_threaded_load()
	_load_next_if_ready()

# Just for now to jump out to Title
func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("back"):
		get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

func _load_current_sync( index: int ) -> void:
	var path : String = StageCatalog.path_at( index )
	if path.is_empty():
		push_error( "No stage at index %d" % index )
		return
	
	var packed : PackedScene = ResourceLoader.load(path, "PackedScene") as PackedScene
	if not packed:
		push_error( "Failed to load %s" % path )
		return
	
	_clear_children( current_holder )
	current_holder.add_child( packed.instantiate() )
	scroller.position = Vector2.ZERO
	next_holder.position = Vector2.ZERO

func _clear_children( node: Node ) -> void:
	for child in node.get_children():
		child.queue_free()

# Backbround load for the next stage/level
func _prefetch_next() -> void:
	# Don't double fetch
	if _is_loading:
		return

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
			_queued_packed = null

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
	
	if next_holder.get_child_count() == 0:
		next_holder.add_child( packed.instantiate() )
	next_holder.position = Vector2( 0, viewport_size.y )
	
# This was hooked up to a button... but soon a "Level Finished" condition
func _advance_to_next_stage() -> void:
	# If sliding, kick out
	if _is_sliding:
		return
	
	# If NextHolder is still empty, fall back to normal load
	if next_holder.get_child_count() == 0:
		_fallback_sync_load_next()
	
	# Still nothing? Kick out
	if next_holder.get_child_count() == 0:
		return
	
	_is_sliding = true
	var that_level_tween : Tween = create_tween().set_trans( Tween.TRANS_CUBIC ).set_ease( Tween.EASE_IN_OUT )
	that_level_tween.tween_property( scroller, "position:y", -viewport_size.y, slide_time)
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
		arrived.reparent( current_holder )
	
	# Clear NextHolder container entirely
	_clear_children(next_holder)
	
	# Advance index
	_current_index = _queued_index
	
	# Reset queued queue stuff
	_queued_path = ""
	_queued_packed = null
	_is_sliding = false
	
	# Prep next
	_prefetch_next()

func _on_advance_stage_pressed() -> void:
	_advance_to_next_stage()

func _on_viewport_resized() -> void:
	viewport_size = get_viewport_rect().size
	# Keep the "next" panel parked one screen below if it's staged
	if next_holder.get_child_count() > 0 and not _is_sliding:
		next_holder.position = Vector2(0, viewport_size.y)
