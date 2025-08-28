extends StaticBody2D
class_name AxelBubble

var velocity : Vector2 = Vector2( 1, 0 )

const SPEED : float = 300.0

func _ready() -> void:
	rotation_degrees = randf_range( -5.0, 5.0 )
	velocity = velocity.rotated( rotation )
	

func _physics_process( _delta: float ) -> void:
	global_position += velocity * SPEED * _delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
