extends CharacterBody2D
class_name Axel

@export var walk_speed    : float = 75.0
@export var air_speed     : float = 50.0
@export var gravity       : float = 400.0
@export var max_fall      : float = 50.0
@export var jump_speed    : float = 200.0
@export var jump_cut_mult : float = 0.5  # variable jump height, maybe, no sure

@onready var collision_shape_2d : CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d : AnimatedSprite2D = $AnimatedSprite2D
@onready var my_state: Label = $MyState

@onready var axel_fsm : AxelFSM = $AxelFSM
@onready var jump_assist : JumpAssist = $JumpAssist

func _ready() -> void:
	axel_fsm.process_priority = -10
	

func _unhandled_input( event: InputEvent ) -> void:
	# Grab the jump input before the FSM does to do the JumperAssister flags
	if event.is_action_pressed( "jump" ):
		jump_assist.note_jump_pressed()

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
