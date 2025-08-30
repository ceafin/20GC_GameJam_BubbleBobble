extends CharacterBody2D
class_name Axel

const AXEL_BUBBLE = preload("res://player/axel_bubble.tscn")

@export var walk_speed     : float = 75.0
@export var air_speed      : float = 50.0
@export var gravity        : float = 400.0
@export var max_fall       : float = 50.0
@export var jump_speed     : float = 200.0
@export var jump_cut_mult  : float = 0.5
@export var shoot_cooldown : float = 0.15

var _can_shoot   : bool = true
var _shoot_timer : Timer

@onready var collision_shape_2d : CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d : AnimatedSprite2D = $AnimatedSprite2D
@onready var popper_top         : Area2D = $PopperTop
@onready var popper_bottom      : Area2D = $PopperBottom
@onready var my_state           : Label = $MyState

@onready var axel_fsm    : AxelFSM = $AxelFSM
@onready var jump_assist : JumpAssist = $JumpAssist

func _ready() -> void:
	axel_fsm.process_priority = -10


func _unhandled_input( event: InputEvent ) -> void:
	# Grab the jump input before the FSM does to do the JumperAssister flags
	if event.is_action_pressed( "jump" ):
		jump_assist.note_jump_pressed()
	# Grab the shoot input before any other children might
	if event.is_action_pressed("bubble"):
		_shoot_bubble()

func _process( _delta: float ) -> void:
	
	# Write the State on the Label
	my_state.text = axel_fsm.current_state.name
	
	# Animation Facing
	if velocity.x > 0:
		animated_sprite_2d.flip_h = false
	elif velocity.x < 0:
		animated_sprite_2d.flip_h = true
	
	# Animation Selection
	if !is_on_floor():
		animated_sprite_2d.play( "jump" )
	else:
		if abs( velocity.x ) > 0.1:
			animated_sprite_2d.play( "walk" )
		else:
			animated_sprite_2d.play( "idle" )
	

func _physics_process( _delta: float ) -> void:
	
	move_and_slide()
	
	# Send some delta ticks to the JumperAssister
	jump_assist.physics_tick( _delta, is_on_floor() )
	

# Special jump function to be used just anywhere, even called on by signals
func start_jump() -> void:
	velocity.y = jump_speed * Vector2.UP.y
	jump_assist.consume_after_jump()

func _shoot_bubble() -> void:

	if not _can_shoot:
			return

	var new_bubble : AxelBubble = AXEL_BUBBLE.instantiate() as AxelBubble
	var dir : int = -1 if animated_sprite_2d.flip_h else 1
	var mouth_offset := Vector2( 8.0 * dir, -6.0 )
	new_bubble.global_position = global_position + mouth_offset
	new_bubble.dir = dir
	
	get_tree().current_scene.add_child( new_bubble )

func _try_to_pop( in_bound_area: Area2D ) -> void:
	var owner_node : Node = in_bound_area.get_owner()
	if owner_node and owner_node.has_method( "get_popped" ):
		owner_node.get_popped()
		return


func _on_popper_top_area_entered( area: Area2D ) -> void:
	_try_to_pop( area )


func _on_popper_bottom_area_entered( area: Area2D ) -> void:
	_try_to_pop( area )
