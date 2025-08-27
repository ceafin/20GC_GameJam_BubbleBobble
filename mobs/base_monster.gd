extends CharacterBody2D
class_name BaseMonster

@export var move_speed : float = 50

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var monster_fsm: MonsterFSM = $MonsterFSM

var is_pissed : bool

func _ready() -> void:
	monster_fsm.process_priority = -10
	animated_sprite_2d.play("default")
	

func _physics_process(delta: float) -> void:
	if velocity.x > 0:
		animated_sprite_2d.flip_h = true
	elif velocity.x < 0:
		animated_sprite_2d.flip_h = false
	
	move_and_slide()
	
