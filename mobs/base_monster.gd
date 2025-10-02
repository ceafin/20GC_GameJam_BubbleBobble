extends CharacterBody2D
class_name BaseMonster

const COLLECTABLE = preload("res://scenes/collectable.tscn")

@export var move_speed: float = 50

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var monster_fsm: MonsterFSM = $MonsterFSM

var is_pissed: bool
var bubble_magnet_position: Vector2
var is_captured: bool = false

func _ready() -> void:
	# Take processing priority for itself
	monster_fsm.process_priority = -10
	get_bubble_magnet_pos()
	animated_sprite_2d.play("default")
	

func _physics_process(delta: float) -> void:
	if velocity.x > 0:
		animated_sprite_2d.flip_h = true
	elif velocity.x < 0:
		animated_sprite_2d.flip_h = false
	
	move_and_slide()
	
func turn_into_bubble() -> void:
	animated_sprite_2d.play("normal_bubble")
	if is_instance_valid(monster_fsm):
		monster_fsm.call_deferred("change_state", "captured")
	is_captured = true

func get_bubble_magnet_pos() -> void:
	# Go scan for and store where ever the BubbleMagnet is in the scene
	var magnet: Marker2D = get_tree().root.find_child("BubbleMagnet", true, false) as Marker2D
	assert(magnet != null, "BubbleMagnet not found in scene tree!")
	bubble_magnet_position = magnet.global_position

func get_popped() -> void:
	if !is_captured:
		return
	
	# Do a small random arch and then fall to the ground with Vector2.ZERO velocity
	#
	#
	#
	
	# Spawn a Collectable in the same position
	var pick_em_up: Collectable = COLLECTABLE.instantiate() as Collectable
	pick_em_up.global_position = position
	get_tree().current_scene.add_child(pick_em_up)
	
	# Zoink out
	queue_free()
