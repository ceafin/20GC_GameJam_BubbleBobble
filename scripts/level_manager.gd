extends Node2D
class_name LevelManager

# Decorative bubble scene (overlay)
const DECORATIVE_BUBBLE_SCN := preload( "res://scenes/decorative_bubble.tscn" )

# First Actual Stage
@export var first_stage_path : String = "res://levels/stage_001.tscn"

var _loaded_level : Node = null
var _intro_bubbles : Array[ Node2D ] = []
var _first_load_done : bool = false

@onready var scroller : Node2D     = $Scroller
@onready var holder_current : Node = $Scroller/CurrentLevel
@onready var holder_next : Node2D  = $Scroller/NextLevel
@onready var overlay : CanvasLayer = $TransitionLayer

func _ready() -> void:
	# Allow tweens during pause (used in transition)
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func load_first_level( level_path: String ) -> void:
	_free_children( holder_current )
	var ps : PackedScene = load( level_path )
	_loaded_level = ps.instantiate()
	holder_current.add_child( _loaded_level )
	
	if _first_load_done:
		# For regular stage-to-stage transitions
		return

	# First load is the Intro scene → prepare overlay intro bubbles then slide into Stage 001
	_first_load_done = true
	
	_show_intro_overlay( true )
	_spawn_intro_bubbles()
	await _intro_delay_or_input()
	await _transition_intro_to_first()

# ----------------- Intro helpers -----------------

func _spawn_intro_bubbles() -> void:
	_clear_intro_bubbles()
	if _loaded_level == null:
		return
	var p1: Node2D = _loaded_level.get_node_or_null("Markers/P1Float")
	var p2: Node2D = _loaded_level.get_node_or_null("Markers/P2Float")
	if p1:
		var b1 := DECORATIVE_BUBBLE_SCN.instantiate() as Node2D
		overlay.add_child(b1)
		b1.global_position = p1.global_position
		_intro_bubbles.append(b1)
	if p2:
		var b2 := DECORATIVE_BUBBLE_SCN.instantiate() as Node2D
		overlay.add_child(b2)
		b2.global_position = p2.global_position
		_intro_bubbles.append(b2)

func _clear_intro_bubbles() -> void:
	for b in _intro_bubbles:
		if is_instance_valid(b):
			b.queue_free()
	_intro_bubbles.clear()

func _intro_delay_or_input() -> void:
	# Give the intro text a moment; allow skip with Start/Jump/Bubble
	var wait := true
	var timer := get_tree().create_timer(1.2, false)
	while wait:
		await get_tree().process_frame
		if timer.time_left <= 0.0:
			wait = false
		if Input.is_action_just_pressed("start") or Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("bubble"):
			wait = false

# ----------------- Transition: Intro → Stage 001 -----------------

func _transition_intro_to_first() -> void:
	# Preload Stage 001 under NextLevel, positioned BELOW the screen
	_free_children(holder_next)
	var ps: PackedScene = load(first_stage_path)
	var stage := ps.instantiate() as Node2D
	holder_next.add_child(stage)

	var vp: Vector2 = get_viewport_rect().size
	holder_next.position = Vector2(0, vp.y)  # place below
	scroller.position = Vector2.ZERO         # ensure starting at 0

	# Compute overlay bubble targets = PlayerSpawn(s) in Stage 001 (screen-space)
	var p1_spawn: Node2D = stage.get_node_or_null("Markers/PlayerSpawn")
	var p2_spawn: Node2D = stage.get_node_or_null("Markers/Player2Spawn")
	var targets: Array[Vector2] = []
	if p1_spawn: targets.append(p1_spawn.get_global_transform_with_canvas().origin)
	if p2_spawn: targets.append(p2_spawn.get_global_transform_with_canvas().origin)

	# Pause gameplay; let overlay + this node process during pause
	var old_paused := get_tree().paused
	get_tree().paused = true
	overlay.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	# Tween world up; bubbles down to spawn points
	var dur := 1.2
	var t_world := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	t_world.tween_property(scroller, "position:y", -vp.y, dur)

	for i in range( _intro_bubbles.size() ):
		if i < targets.size():
			var b := _intro_bubbles[i]
			var tb := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			tb.tween_property(b, "global_position", targets[i], dur)

	await t_world.finished

	# Pop bubbles and finalize scene swap
	for b in _intro_bubbles:
		if is_instance_valid(b):
			if b.has_method("pop"): b.call("pop")
			else: b.queue_free()
	_intro_bubbles.clear()
	_show_intro_overlay(false)

	_free_children(holder_current)
	holder_current.add_child(stage)
	holder_next.position = Vector2.ZERO
	scroller.position = Vector2.ZERO

	get_tree().paused = old_paused

# ----------------- Utilities -----------------

func _free_children( node: Node ) -> void:
	for child in node.get_children():
		child.queue_free()

func _show_intro_overlay(visible: bool) -> void:
	pass
